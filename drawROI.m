function drawROI(source,callbackdata,anat,directories,subj,mp,stim)
% Function to display timeseries from user drawn ROI 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     directories - strings for all relevant directories
%     subj - subject data (name,date,breathhold)
%     mp - GUI data
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 27, 2016
% Author - Hannah Sennik

global ax_slider_value;

addpath('/data/wayne/matlab/NIFTI'); % add path to nii functions
addpath('/data/wayne/matlab/general');

mkdir(directories.subject,directories.timeseries); % make a directory to save ROI mask and timeseries text file 

data_out = anat; % creating a struct with same header info as anat (this will be used for the mask)

fileID = fopen([directories.textfilesdir '/processing.txt'],'r'); % open processing text file to see if user selected processed or raw data 
format = '%d';
A = fscanf(fileID,format);

if A == 1
    tag = 'processed';
else
    tag = 'processed_not';
end

fclose(fileID);

fname = ['data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii'];
processed = load_nii([directories.subject '/' fname]); % load "processed" functional data 

[processed.x,processed.y,processed.z] = size(processed.img);

z_index = floor(ax_slider_value); % get the z index for the mask 

h = imfreehand('Closed','True'); % user draws freehand ROI 
binaryImage = h.createMask(); % create a mask from the ROI 
binaryImage = flip(binaryImage,2);
binaryImage = rot90(binaryImage(anat.xrange,anat.yrange,:),3);

new = zeros(size(anat.img)); % create new img the size of anat, fill with zeros
new(:,:,z_index) = binaryImage; % fill correct indices of new img with mask 
display('new img created');

data_out.img = new; % use new as the img for the data_out struct
save_mask = [directories.timeseries '/mask.nii']; % save the mask as a nii to timeseries directory
save_nii(data_out,save_mask);

display('nii mask saved');
 
% Transform the mask from anatomical space to functional space - save as
% finalmask.nii 
command = ['flirt -in ' directories.timeseries '/mask.nii -ref data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii -out ' directories.timeseries '/finalmask.nii -init ' 'data/recon/' subj.name '/' subj.name '_anat_' subj.proc_rec_sel '.xfm -applyxfm'];
status= system(command);

% Use 3dmaskave to mask the functional data with finalmask.nii and save the
% timeseries to timeseries.1D in timeseries directory 
command = ['3dmaskave -q -mask ' directories.timeseries '/finalmask.nii data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii > ' directories.timeseries '/timeseries.1D'];
status = system(command);

%  Load in the 1D timeseries file and display as plot 
timeseries = [directories.timeseries '/timeseries.1D'];

shift_custom_capability = 5;
boxcar_name = mp.menu(1).String(mp.menu(1).Value);
boxcar_name = boxcar_name{1};
figname = ['ROI Timeseries'];
pos = [1130,400,600,410];
funct_space = (['data/processed/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii']);
funct_space = load_nii([directories.subject '/' funct_space]);
timeseries_name = 'Timeseries from Drawn ROI';

plotfiles(directories,subj,timeseries,stim,pos,figname,shift_custom_capability,timeseries_name,boxcar_name,funct_space,mp);


end