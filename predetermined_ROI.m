function predetermined_ROI(source,callbackdata,anat,funct,dir_input,mp,subj)
% Function to display timeseries from a predetermined 3D ROI of a specified
% brain region 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     dir_input - main subject directory 
%     mp - GUI data
%     subj - subject data (name,date,breathhold)
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 11, 2016
% Author - Hannah Sennik

global ax_slider_value;
slice = floor(ax_slider_value);
mask_sel = get(source,'Value'); % get the mask selection (which brain region)
processing_file = [dir_input '/textfiles/processing.txt'];
fileID = fopen(processing_file,'r'); % open processing text file to see if user selected processed or raw data 
format = '%d';
process_val = fscanf(fileID,format);

%  variables to pass in masked_slice to the CVRmap.m function 
sliceval = 0; % don't need this var
gen_file_location = ''; % don't need this var
dimension = 'axial'; % variable to be fed in to the CVRmap function

if mask_sel == 6 % Cerebellum  
    region = 'Cerebellum';
    % this step will just be getting the pf stimfile for the correct breathhold 
    if mp.menu(2).Value == 2
        processing_ext = '';
        timeseries = strcat(dir_input,'/flirt/pf',processing_ext,'/pf_',subj.breathhold,'_stim.1D');
    else
        processing_ext = '_not_processed';
        timeseries = strcat(dir_input,'/flirt/pf',processing_ext,'/pf_',subj.breathhold,'_stim',processing_ext,'.1D');
    end
    
    timeseries_plot = load(timeseries);
    
    %  Load cerebellar region mapped to anatomical space in order to
    %  display edge mask on top 
    mask = load_nii('flirt/standard_to_anat/cerebellum_to_anat.nii');
    
    %  Get the edge of the region 
    masked_slice = edge(double(mask.img(:,:,slice)),'Canny');
    masked_slice = rot90(masked_slice(anat.xrange,anat.yrange,:));
    masked_slice = flip(masked_slice,2);
       
elseif mask_sel == 'Other options'
end
    % map selected file to subject's functional
    % space
    % use 3dmaskave to get timeseries from cerebellum masked functional
    % show the timeseries against boxcar
  
CVRmap(dimension,anat,funct,mp,sliceval,masked_slice,gen_file_location)    
    
fileID = fopen(strcat(dir_input,'/textfiles/standard_or_custom.txt'),'r'); % open the customize boxcar file
format = '%d';
custom_val = fscanf(fileID,format);     

% Determine which stimfile was used so that it can be displayed with the
% timeseries 
if(mp.menu(1).Value == 2)
    if custom_val == 1 && strcmp(mp.boxcarsel.String,'Boxcar selection: customized') == 1
        stim = strcat('metadata/stim/bhonset',subj.name,'_',subj.breathhold,'_customized.1D');
    else
        stim = strcat('metadata/stim/bhonset',subj.name,'_',subj.breathhold,'.1D');
    end
elseif(mp.menu(1).Value == 3)
    if process_val~='1'
        stim = strcat('metadata/stim/pf_',subj.breathhold,'_stim_not_processed.1D');
    else
        stim = strcat('metadata/stim/pf_',subj.breathhold,'_stim.1D');
    end
end

ts = figure('Name',['Timeseries from 3D ROI: ' region],...
       'Visible','on',...
       'Numbertitle','off');  
set(ts, 'MenuBar', 'none'); % remove the menu bar 
set(ts, 'ToolBar', 'none'); % remove the tool bar    
plot(timeseries_plot);
title('Timeseries vs. Stimulus');
xlabel('Time');
ylabel('BOLD Signal');
hold; % hold the plot 
stimfile = load(stim); % load the stimfile used to generate the parametric map 
stimfile = stimfile + (median(timeseries_plot) - median(stimfile)) + 25; % move the plot up so that user can easily compare timeseries and stim
plot(stimfile); % plot the stimfile 
legend('Timeseries from ROI','Stimfile signal');
end
