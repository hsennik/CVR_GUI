function drawROI(source,callbackdata,anat,dir_input,subj,mp)
% Function to display timeseries from user drawn ROI 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     dir_input - main subject directory 
%     subj - subject data (name,date,breathhold)
%     mp - GUI data
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 27, 2016
% Author - Hannah Sennik

global ax_slider_value;

addpath('/data/wayne/matlab/NIFTI'); % add path to nii functions
addpath('/data/wayne/matlab/general');

cd(dir_input); % change in to subject's directory 

mkdir(dir_input,'/timeseries'); % make a directory to save ROI mask and timeseries text file 

data_out = anat; % creating a struct with same header info as anat (this will be used for the mask)

fileID = fopen([dir_input '/textfiles/processing.txt'],'r'); % open processing text file to see if user selected processed or raw data 
format = '%d';
A = fscanf(fileID,format);

if A == 1
    tag = 'processed';
else
    tag = 'processed_not';
end

fname = ['data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii'];
processed = load_nii([dir_input '/' fname]); % load "processed" functional data 

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
save_mask = 'timeseries/mask.nii'; % save the mask as a nii to timeseries directory
save_nii(data_out,save_mask);

display('nii mask saved');

fileID = fopen([dir_input '/textfiles/standard_or_custom.txt'],'r'); % open the customize boxcar file
format = '%d';
B = fscanf(fileID,format);

% Determine which stimfile was used so that it can be displayed with the
% timeseries 
if(mp.menu(1).Value == 2) % boxcar was selected on the main GUI 
    if B == 1 && strcmp(mp.boxcarsel.String,'Boxcar selection: customized') == 1
        stim = ['metadata/stim/bhonset' subj.name '_' subj.breathhold '_customized.1D'];
    else
        stim = ['metadata/stim/bhonset' subj.name '_' subj.breathhold '.1D'];
    end
elseif(mp.menu(1).Value == 3) % pf was selected on the main GUI 
    if strcmp(tag,'processed_not') == 1
        stim = ['metadata/stim/pf_' subj.breathhold '_stim_not_processed.1D'];
    else
        stim = ['metadata/stim/pf_' subj.breathhold '_stim.1D'];
    end
end

% Transform the mask from anatomical space to functional space - save as
% finalmask.nii 
command = ['flirt -in timeseries/mask.nii -ref data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii -out timeseries/finalmask.nii -init timeseries/anat2funct.mat -applyxfm'];
status= system(command);

% Use 3dmaskave to mask the functional data with finalmask.nii and save the
% timeseries to timeseries.1D in timeseries directory 
command = ['3dmaskave -q -mask timeseries/finalmask.nii data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii > timeseries/timeseries.1D'];
status = system(command);

%  Load in the 1D timeseries file and display as plot 
timeseries = [dir_input '/timeseries/timeseries.1D'];
timeseries_plot = load(timeseries);

ts = figure('Name','Timeseries',...
       'Visible','on',...
       'Numbertitle','off',...
       'Position', [1130,400,600,410]);
set(mp.f, 'MenuBar', 'none'); % remove the menu bar 
set(mp.f, 'ToolBar', 'none'); % remove the tool bar   

plot(timeseries_plot);  % plot the timeseries from the ROI 
title('Timeseries vs. Stimulus')
xlabel('Time')
ylabel('BOLD Signal')
hold; % hold the plot 

stimfile = load(stim); % load the stimfile used to generate the parametric map 
stimfile = stimfile + (median(timeseries_plot) - median(stimfile)) + 50; % move the plot up so that user can easily compare timeseries and stim
plot(stimfile); % plot the stimfile 
legend('Timeseries from ROI','Stimfile signal')

end