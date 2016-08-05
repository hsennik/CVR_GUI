function drawROI_copy(source,callbackdata,anat,directories,subj,main_GUI,funct)
% Function to draw an ROI and extract the timeseries to make boxcar
% adjustments 
% 
% INPUTS 
%     anat - subject's anatomical data
%     directories - all of the directories for the subject
%     subj - subject data (name,date,breathhold)
%     main_GUI - has all gui data from the main interface
%     funct - functional subject data  (need the time)
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 5, 2016
% Author - Hannah Sennik

global ax_slider_value; % axial slider value 

tag = 'processed'; % pulling timeseries from the processed data 

%  Close all other timeseries windows that are open 
close(findobj('type','figure','name',['Timeseries: ' subj.breathhold]));
close(findobj('type','figure','name',['Create customized boxcar for: ' subj.breathhold]));
close(findobj('type','figure','name',['Timeseries vs. Customized Boxcar: ' subj.breathhold]));

data_out = anat; % creating a struct with same header info as anat (this will be used for the mask)

[funct.x,funct.y,funct.z] = size(funct.img); % getting the dimensions of the functional data 

z_index = floor(ax_slider_value); % get the z index for the mask 

h = imfreehand('Closed','True'); % user draws freehand ROI 
binaryImage = h.createMask(); % create a mask from the ROI 
binaryImage = flip(binaryImage,2); % flip and rotate the mask for viewing purposes 
binaryImage = rot90(binaryImage(anat.xrange,anat.yrange,:),3);

new = zeros(size(anat.img)); % create new img the size of anat, fill with zeros
new(:,:,z_index) = binaryImage; % fill correct indices of new img with mask 
display('new img created');

data_out.img = new; % use new as the img for the data_out struct
save_mask = 'timeseries/mask.nii'; % save the mask as a nii to timeseries directory
save_nii(data_out,save_mask);

display('nii mask saved');

stim = [directories.subject '/' directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D']; % standard stimulus file 

copyfile(['data/recon/' subj.name '/' subj.name '_anat_' subj.proc_rec_sel '.xfm'], [directories.timeseries '/anat2' subj.proc_rec_sel '.xfm']); % copy the transformation matrix for anatomical to functional space

% Transform the mask from anatomical space to functional space - save as
% finalmask.nii 
command = ['flirt -in ' directories.timeseries '/mask.nii -ref data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii -out ' directories.timeseries '/finalmask.nii -init ' directories.timeseries '/anat2' subj.proc_rec_sel '.xfm -applyxfm'];
status= system(command);

% Use 3dmaskave to mask the functional data with finalmask.nii and save the
% timeseries to timeseries.1D in timeseries directory 
command = ['3dmaskave -q -mask timeseries/finalmask.nii data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii > ' directories.timeseries '/timeseries.1D'];
status = system(command);

%  Initialize the variables to be passed into the plotfiles function 
timeseries = [directories.subject '/timeseries/timeseries.1D'];
pos = [965,800,900,670];
figname = ['Timeseries: ' subj.breathhold];
timeseries_name = 'Timeseries from drawn ROI';
boxcar_name = 'Standard Boxcar';

if main_GUI.boxcar(2).Value == 1
    shift_custom_capability = 1; % shifted was selected 
else 
    shift_custom_capability = 2; % customize was selected 
end

plotfiles(directories,subj,timeseries,stim,pos,figname,shift_custom_capability,timeseries_name,boxcar_name,funct,main_GUI); % plot the timeseries vs. stim 

end