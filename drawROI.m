function drawROI(source,callbackdata,anat,directories,subj,mp)
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

fileID = fopen([directories.textfilesdir '/standard_shifted_customized.txt'],'r'); % open the customize boxcar file
format = '%d';
B = fscanf(fileID,format);

% Determine which stimfile was used so that it can be displayed with the
% timeseries 
if(mp.menu(1).Value == 2) % boxcar
    if B == 1
        stim = [directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D'];
    elseif B == 2
        stim = [directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_shifted.1D'];
    elseif B == 3
        stim = [directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_customized.1D'];
    end
elseif(mp.menu(1).Value == 3)
    if mp.menu(2).Value == 2
        stim = [directories.metadata '/stim/pf_stim_' subj.proc_rec_sel '_processed.1D'];
    elseif mp.menu(2).Value == 3
        stim = [directories.metadata '/stim/pf_stim_' subj.proc_rec_sel '_processed.1D'];
    end
end

fclose(fileID);
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
timeseries_plot = load(timeseries);

ts = figure('Name','Timeseries',...
       'Visible','on',...
       'Numbertitle','off',...
       'Position', [1130,400,600,410]);
set(mp.f, 'MenuBar', 'none'); % remove the menu bar 
set(mp.f, 'ToolBar', 'none'); % remove the tool bar   

plot(timeseries_plot,'Linewidth',2);  % plot the timeseries from the ROI 
title('Timeseries vs. Stimulus')
xlabel('Number of TRs')
ylabel('BOLD Signal')
hold; % hold the plot 

stimfile = load(stim); % load the stimfile used to generate the parametric map 
stimfile = stimfile/10;
stimfile = stimfile + (median(timeseries_plot) - median(stimfile)) + 50; % move the plot up so that user can easily compare timeseries and stim
plot(stimfile,'Color','red','Linewidth',2); % plot the stimfile 
legend('Timeseries from ROI','Stimfile signal')

end