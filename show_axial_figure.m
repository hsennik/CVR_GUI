function show_axial_figure(subj,directories,main_GUI,funct)
% Function to show the axial slices in a figure so that the user can select
% an ROI and pull the timeseries. This is used so that they can find the
% general peaks and troughs of the data and adjust the boxcar if needed.
% 
% INPUTS 
%     subj - subject data (name,date,breathhold)
%     directories - all of the directories for the subject
%     main_GUI - structure that has information linked to the main figure
%     bhselection - stores breathhold selection data (BH1, BH2 OR HV)
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 13, 2016
% Author - Hannah Sennik


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Close all the figures except for the main GUI where all of the options
%  are 
close(findobj('type','figure','name',['Axial Subject Data: ' subj.breathhold]));
close(findobj('type','figure','name',['Timeseries vs. Customized Boxcar: ' subj.breathhold]));
close(findobj('type','figure','name',['Create customized boxcar for: ' subj.breathhold]));
close(findobj('type','figure','name',['Timeseries: ' subj.breathhold]));
close(findobj('type','figure','name',['Entire Brain Average Timeseries: ' subj.breathhold]));

set(main_GUI.start,'Enable','off'); % disable the analyze subject button 

GUI = 1; % indicates to slider_position.m which GUI the slider belongs to - processing GUI (1) OR viewing GUI (2)

anat_filelocation = ['data/recon/' subj.name '/' subj.name '_anat_brain.nii']; % find the subject's anatomical data
fname_anat = anat_filelocation;

anat = load_nii([directories.subject '/' fname_anat]); % Load the subject's 3D skull stripped anatomical 
[anat.x,anat.y,anat.z] = size(anat.img); % get the size of anatomical

%  CONSTRUCTING ANATOMICAL SLICES

%  Initial slice position - values can be changed 
anat.slice_x = 120;
anat.slice_y = 104; 
anat.slice_z = 69; 

global ax_slider_value;
ax_slider_value = anat.slice_z; % initial value of the slider

%  Slice ranges
anat.xrange = (1:anat.x);
anat.yrange = (1:anat.y);
anat.zrange = (1:anat.z); 

%  Adjusting the contrast of the anatomical scans (shrink the window of the range of values)
global sigmin;
global sigmax; 

%  Create the entire interface panel
axial.f = figure('Name', ['Axial Subject Data: ' subj.breathhold],...
                'Visible','on',...
                'Position',[358,800,600,500],...
                'numbertitle','off');
set(axial.f, 'MenuBar', 'none'); % remove the menu bar 
set(axial.f, 'ToolBar', 'none'); % remove the tool bar  

%  Create description for contrast values
axial.contrast_text = uicontrol('Style','text',...
                    'units','normalized',...
                    'Position',[0.05,0.2,0.1,0.1],...
                    'String','Contrast Values: ');

%  Create edit box for sigmin value                      
axial.sigmin_val = uicontrol('Style','edit',...
                            'Units','pixels',...
                            'Enable','on',...
                            'String',sigmin,...
                            'Position',[20,90,75,20]);   

%  Create edit box for sigmax value                       
axial.sigmax_val = uicontrol('Style','edit',...
                            'Units','pixels',...
                            'Enable','on',...
                            'String',sigmax,...
                            'Position',[20,60,75,20]);    
                        
%  Pushbutton to confirm updated sig values
axial.save_sig_vals = uicontrol('Style','pushbutton',...
                                'Visible','on',...
                                'String','Update Values',...
                                'Value',0,'Position',[5,10,100,30],...
                                'Callback',{@adjust_sig_vals,directories}); 
                        
guidata(axial.f,axial);

%  Preparing slices to be displayed
%  AXIAL slice
anat.slice_ax = (double(repmat(imresize(squeeze(anat.img(:,:,anat.slice_z)),[anat.x anat.y]), [1 1 3])) - sigmin) / sigmax ;
anat.slice_ax = imresize(anat.slice_ax,[anat.x anat.y/anat.hdr.dime.pixdim(1)]);
anat.slice_ax = rot90(anat.slice_ax(anat.xrange,anat.yrange,:));
anat.slice_ax = flip(anat.slice_ax,2);      

%  functional time data 
funct.time = funct.hdr.dime.dim(5);

if main_GUI.boxcar(2).Value == 1
    userprompt_string = 'adjust the standard boxcar';
elseif main_GUI.boxcar(3).Value == 1
    userprompt_string = 'create a customized boxcar';
end

axial.userprompt = uicontrol('Style','text',...
                    'units','normalized',...
                    'Position',[0.05,0.9,0.9,0.1],...
                    'String',['Specify an ROI to extract the ' subj.breathhold ' timeseries and ' userprompt_string ' or refer to the entire brain timeseries.']);

%  Text that displays the slider/slice position
axial.position_slider = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'String',anat.slice_z,...
                                    'position',[0.03 0.35 0.1 0.05]);   

%  Button to draw ROI and graph the timeseries 
axial.drawROI = uicontrol('Style','pushbutton',...
                                'Visible','on',...
                                'String','Draw ROI',...
                                'Value',0,'Position',[250,5,100,40],...
                                'Callback',{@drawROI_copy,anat,directories,subj,main_GUI,funct}); 

%  Slider to control axial slice position                       
axial.slider = uicontrol('style', 'slider',...
                            'Min',1,'Max',anat.z,'Value',anat.slice_z,... 
                            'units', 'normalized',...
                            'SliderStep',[1/anat.z,10/anat.z],...
                            'position',[0.04 0.45 0.08 0.25],...
                            'callback',{@sliderpos_ax,anat,main_GUI,funct,axial,directories,subj,GUI});

%  Descriptive text of slider/slice position    
axial.text_slider = uicontrol('Style', 'text',...
                                'units', 'normalized',...
                                'position', [0.03 0.73 0.1 0.15],...
                                'String', 'Axial Slice Position');                        

axes,      
imshow(anat.slice_ax);  

if main_GUI.boxcar(2).Value == 1
    shift_custom_capability = 1;
else
    shift_custom_capability = 2;
end   

%  DISPLAY BRAIN AVERAGE TIMESERIES WINDOW standard boxcar plotted against
pos = [958,800,900,670]; % initialize the position of the window to show the average brain timeseries plot
stim = [directories.subject '/' directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D']; % initialize the stimfile selection as the standard boxcar
boxcar_name = 'Standard Boxcar';
average_brain_timeseries(subj,directories,funct,pos,stim,boxcar_name,shift_custom_capability,main_GUI); % call the function to plot the average brain timeseries against the standard boxcar
   
end