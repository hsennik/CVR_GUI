function drawROI_copy(source,callbackdata,anat,directories,subj,main_GUI,breathhold,funct)

global ax_slider_value;

tag = 'processed';

close(findobj('type','figure','name',['Timeseries: ' subj.breathhold]));

addpath('/data/wayne/matlab/NIFTI'); % add path to nii functions
addpath('/data/wayne/matlab/general');

cd(directories.subject); % change in to subject's directory 

directories.timeseries = 'timeseries';
mkdir(directories.subject, ['/' directories.timeseries]); % make a directory to save ROI mask and timeseries text file 

data_out = anat; % creating a struct with same header info as anat (this will be used for the mask)

[funct.x,funct.y,funct.z] = size(funct.img);

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

stim = [directories.subject '/' directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D'];

copyfile(['data/recon/' subj.name '/' subj.name '_anat_' subj.breathhold '.xfm'], [directories.timeseries '/anat2' subj.breathhold '.xfm']);

% Transform the mask from anatomical space to functional space - save as
% finalmask.nii 
command = ['flirt -in ' directories.timeseries '/mask.nii -ref data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii -out ' directories.timeseries '/finalmask.nii -init ' directories.timeseries '/anat2' subj.breathhold '.xfm -applyxfm'];
status= system(command);

% Use 3dmaskave to mask the functional data with finalmask.nii and save the
% timeseries to timeseries.1D in timeseries directory 
command = ['3dmaskave -q -mask timeseries/finalmask.nii data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii > timeseries/timeseries.1D'];
status = system(command);

%  Load in the 1D timeseries file and display as plot 
timeseries = [directories.subject '/timeseries/timeseries.1D'];
timeseries_plot = load(timeseries);

stimfile = load(stim); % load the stimfile used to generate the parametric map 
stimfile = stimfile/10;
stimfile = stimfile + (median(timeseries_plot) - median(stimfile)) + 50; % move the plot up so that user can easily compare timeseries and stim

ts.f = figure('Name',['Timeseries: ' subj.breathhold],...
       'Visible','on',...
       'Numbertitle','off',...
       'Position', [950,800,600,500]);

set(ts.f, 'MenuBar', 'none'); % remove the menu bar 
set(ts.f, 'ToolBar', 'none'); % remove the tool bar     

starting_value = 0;    

timeplot = plot(timeseries_plot,'Linewidth',2);  % plot the timeseries from the ROI 
title('Timeseries vs. Stimulus')
xlabel('Scan Time')
ylabel('BOLD Signal')
hold; % hold the plot 

stimplot = plot(stimfile,'Color','red','Linewidth',2); 

legend('Timeseries from ROI','Standard Boxcar');

ax = gca;
ax.XTick = [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180];

if main_GUI.boxcar(2).Value == 1
    %  Slider to control boxcar shifting                     
    ts.shift_boxcar = uicontrol('style', 'slider',...
                                'Min',-20,'Max',20,'Value',starting_value,... 
                                'units', 'normalized',...
                                'SliderStep',[1/40,10/40],...
                                'position',[0.6 0 0.25 0.05],...
                                'callback',{@shift_boxcar,stimfile,starting_value,funct});   

    %  Create radiobuttons to select between shifted and customized boxcar (can
    %  only choose one or the other) 

    %  Checkbox for shifted boxcar
    ts.shift_boxcar = uicontrol('Style','checkbox',...
                                'Visible','on',...
                                'String','Use Adjusted Boxcar',...
                                'HandleVisibility','on',...
                                'Position',[35,0,225,25],...
                                'Enable','on',...
                                'callback',{@save_shifted_to_file,subj,ts,directories,funct});
else
    create_boxcar(subj,directories,main_GUI,timeseries_plot);
end

% %  Radiobutton for shifted boxcar                       
% ts.boxcar(1) = uicontrol('Style','radiobutton',...
%                         'Visible','on',...
%                         'Units','pixels',...
%                         'String','Use Adjusted Boxcar',...
%                         'HandleVisibility','on',...
%                         'Position',[35,15,225,25],...
%                         'Enable','on',...
%                         'callback',{@myRadio,subj,directories});
% 
% %  Radiobutton for customized boxcar
% ts.boxcar(2) = uicontrol('Style','radiobutton',...
%                         'Visible','on',...
%                         'String','Create customized boxcar',...
%                         'HandleVisibility','on',...
%                         'Position',[35,0,225,25],...
%                         'Enable','on',...
%                         'callback',{@myRadio,subj,directories});                    

end