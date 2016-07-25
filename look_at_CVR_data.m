% GUI for clinician view CVR subject data
% 
% Parameters:
%   Processing: Processed OR unprocessed
%   Stimfiles: boxcar, posterior fossa (pf)
%   Breathholds: BH1,BH2,HV
%   T-statistic: change for the parametric map 

% Data that can be displayed:
%   Anatomical slices: axial,coronal,sagittal
%   Parametric maps overlain on anatomicals
%   Pull timeseries from drawn ROI - plot of timeseries against stimfile 
%   Pull timeseries from predetermined 3D ROI of brain region 
%   Axial anatomical images with white matter masked (mask this on the CVR
%   maps as well)
%   Montage of parametric maps 
% 
% File Name: basic_UI_function.m
% 
% NOTES - HS - 16/05/18 - Initial Creation
% 
% AUTHOR - Hannah Sennik
% Created - 2016-05-18

clear all; % clear all the variables
close all; % close all windows 

GUI = 2;

addpath('/data/wayne/matlab/NIFTI'); % add path to nifti functions 
directories.matlabdir = '/data/hannahsennik/MATLAB/CVR_GUI';
fileID = fopen([directories.matlabdir '/subject_name.txt'],'r'); % Subject name is pulled from this textfile (this is the subject that was just fully processed and analyzed)
subj.name = fscanf(fileID,'%s\n');
fclose(fileID);
directories.subject = ['/data/projects/CVR/GUI_subjects/' subj.name];
cd(directories.subject); % Move in to subject directory
directories.flirtdir = 'flirt';
directories.matlab = 'matlab';
directories.timeseries = 'timeseries';
directories.textfilesdir = 'textfiles';
directories.REDCapdir = 'REDCap_import_files';
directories.metadata = 'metadata';
directories.montagedir = 'montage';

subj.date = '160314';

fileID = fopen([directories.textfilesdir '/breathhold_selection.txt'],'r'); % Subject name is pulled from this textfile (this is the subject that was just fully processed and analyzed)
subj.breathhold = fscanf(fileID,'%s\n');

%  Step 1: Clinician specifies processing parameters and selects stimfile

%  Create the MAIN PANEL (mp)
mp.f = figure('Name', 'CVR Menu',...
                    'Visible','on',...
                    'Position',[25,750,300,700],...
                    'numbertitle','off');

%  Descriptive text for the processing dropdown menu                
mp.text(1) = uicontrol('Style','text',...
                'units','normalized',...
                'Position',[0.2,0.59,0.6,0.1],...
                'String','Apply pre-processing?');

%  Descriptive text for subject name               
mp.text(1) = uicontrol('Style','text',...
                'units','normalized',...
                'Position',[0.2,0.8,0.6,0.15],...
                'String',['Subject name: ' subj.name]);
            
 %  User prompt              
mp.text(4) = uicontrol('Style','text',...
                'units','normalized',...
                'Position',[0.2,0.75,0.6,0.15],...
                'String',['Breathhold: ' subj.breathhold]);           

%  Descriptive text for the stimfile selection dropdown menu                        
mp.text(2) = uicontrol('Style','text',...
                    'units','normalized',...
                    'Position',[0.2,0.72,0.6,0.1],...
                    'String','Select stimfile');
                
% %  Descriptive text for the breathhold selection dropdown menu
% mp.text(3) = uicontrol('Style','text',...
%                        'units','normalized',...
%                        'Position',[0.2,0.59,0.6,0.1],...
%                        'String','Select breath hold');
        
%  Popupmenus to select processing options and stimfile to generate map

mp.STR = {'','boxcar','pf'}; % String for stimfile popup
mp.STR2 = {'','yes','no'}; % String for pre-processing popup
% mp.STR3 = {'','BH1','BH2','HV'}; % String for breathhold popup

%  Create menu for pre-processing (options are yes or no)
mp.menu(2) = uicontrol('Style','popupmenu',...
                'Visible','on',...
                'String',mp.STR2,...
                'Position',[50,395,200,60]);
 
%  Create menu for stimfile selection (options are boxcar or pf)
mp.menu(1) = uicontrol('Style','popupmenu',...
                        'Visible','on',...
                        'Enable','off',...
                        'String',mp.STR,...
                        'Position',[50,485,200,60]);
% 
% %  Create menu for breathhold selection (options are BH1,BH2,HV)
% mp.menu(3) = uicontrol('Style','popupmenu',...
%                        'Visible','on',...
%                        'Enable','off',...
%                        'String',mp.STR3,...
%                        'Position',[50,395,200,60]);

%  Toggle button to overlay CVR map
mp.CVRb = uicontrol('Style','togglebutton',...
                'Visible','on',...
                'String','Overlay CVR map',...
                'Enable','off',...
                'Value',0,'Position',[20,300,150,60],...
                'callback',@pushstate);
                       
%  Toggle button to allow user to start program again using a different
%  method
mp.program_again = uicontrol('Style','togglebutton',...
                    'Visible','on',...
                    'String','Use another method',...
                    'Enable','off',...
                    'Value',0,'Position',[75,150,150,60],...
                    'callback',@run_again);
                
%  Button to terminate the program (close all windows)
mp.quit = uicontrol('Style','togglebutton',...
                    'Visible','on',...
                    'String','End CVR program',...
                    'Value',0,'Position',[75,50,150,60],...
                    'callback',@quit_program);
                
%  Descriptive text for t_stat slider 
mp.t_text = uicontrol('Style','text',...
                    'units','normalized',...
                    'String','Threshold value: ',...
                    'position',[0.05 0.33 0.5 0.05]);  

%  Text that displays the t_stat slider value
mp.t_number = uicontrol('Style','text',...
                        'units','normalized',...
                        'String',0,...
                        'position',[0.49 0.33 0.18 0.05]);
                    
%  Slider bar to adjust the t_stat for CVR map
mp.t = uicontrol('Style','slider',...
                'Min',0,'Max',1,...
                'units','normalized',...
                'Enable','off',...
                'SliderStep',[0.0001,0.001],...
                'position',[0.70 0.34 0.25 0.2],...
                'callback',{@t_slider,mp});
            
set(mp.f, 'MenuBar', 'none'); % remove the menu bar 
set(mp.f, 'ToolBar', 'none'); % remove the tool bar 
            

s = ['data/recon/' subj.name '/' subj.name '_anat_brain.nii'];
fname_anat = s;

anat = load_nii([directories.subject '/' fname_anat]); % Load the subject's 3D skull stripped anatomical 
[anat.x,anat.y,anat.z] = size(anat.img);

%  CONSTRUCTING ANATOMICAL SLICES

%  Initial slice position - values can be changed 
anat.slice_x = 120;
anat.slice_y = 104; 
anat.slice_z = 69; 

global ax_slider_value;
ax_slider_value = anat.slice_z;

%  Slice ranges
anat.xrange = (1:anat.x);
anat.yrange = (1:anat.y);
anat.zrange = (1:anat.z); 

%  Adjusting the contrast of the anatomical scans (shrink the window of the range of values)
anat.sigmin = 10; 
anat.sigmax = 300; % make this user driven (used to be 500)

%  Preparing slices to be displayed in each dimension 
%  AXIAL slice
anat.slice_ax = (double(repmat(imresize(squeeze(anat.img(:,:,anat.slice_z)),[anat.x anat.y]), [1 1 3]))- anat.sigmin) / anat.sigmax ;
anat.slice_ax = imresize(anat.slice_ax,[anat.x anat.y/anat.hdr.dime.pixdim(1)]);
anat.slice_ax = rot90(anat.slice_ax(anat.xrange,anat.yrange,:));
anat.slice_ax = flip(anat.slice_ax,2);

%  CORONAL slice
anat.slice_cor = (double(repmat(imresize(squeeze(anat.img(:,anat.slice_y,:)),[anat.x anat.z]), [1 1 3])) - anat.sigmin) / anat.sigmax;
anat.slice_cor = imresize(anat.slice_cor,[anat.x anat.z/anat.hdr.dime.pixdim(2)]);
anat.slice_cor = rot90(anat.slice_cor(anat.xrange,anat.zrange,:));
anat.slice_cor = flip(anat.slice_cor,2);

%  SAGITTAL slice
anat.slice_sag = (double(repmat(imresize(squeeze(anat.img(anat.slice_x,:,:)),[anat.y anat.z]), [1 1 3])) - anat.sigmin) / anat.sigmax;
anat.slice_sag = imresize(anat.slice_sag,[anat.y anat.z/anat.hdr.dime.pixdim(3)]);
anat.slice_sag = rot90(anat.slice_sag(anat.yrange,anat.zrange,:));
anat.slice_sag = flip(anat.slice_sag,2);
                 
%  LOAD THE FUNCTIONAL DATA

set(mp.menu(1),'Enable','on'); % enable stimfile selection dropdown
waitfor(mp.menu(1),'Value'); % wait for user response
set(mp.menu(1),'Enable','off'); % disable stimfile selection dropdown 
set(mp.menu(2),'Enable','on'); % enable processing selection dropdown 
waitfor(mp.menu(2),'Value'); % wait for user response 
set(mp.menu(2),'enable','off'); 

fileID = fopen([directories.subject '/textfiles/standard_shifted_customized.txt'],'r'); % read from customize_boxcar text file 
format = '%d';
standard_shifted_custom = fscanf(fileID,format);
fclose(fileID);

fileID = fopen([directories.subject '/textfiles/stimsel.txt'],'r');
format = '%d\n';
stimsel = fscanf(fileID,format);
fclose(fileID);

if stimsel == 2
    prefix = 'BH';
elseif stimsel == 3
    prefix = 'GA';
end

if(standard_shifted_custom == 1) % customized boxcars were created for some or all breathholds 
    placeholder = [prefix '_standard'];
elseif standard_shifted_custom == 2
    placeholder = [prefix '_shifted'];
elseif standard_shifted_custom == 2
    placeholder = [prefix '_customized'];
end

fileID = fopen([directories.subject '/textfiles/processing.txt'],'w+'); % open the file that indicates whether or not to do processing 
format = '%d';

if(mp.menu(2).Value == 2) % if the user chooses to display the processed data, write 1 to the file 
    fprintf(fileID,format,1); 
    fclose(fileID);
    display('processing');
elseif(mp.menu(2).Value == 3) % if the user chooses to display the raw data, write 0 to the file 
    fprintf(fileID,format,0);
    fclose(fileID);
    display('no processing');
end

if(mp.menu(1).Value == 2) % boxcar was selected as stimfile option by user on the GUI 
    show_boxcar_string = ['Boxcar selection: ' placeholder]; % indicate to the user if the boxcar for that breathhold is the standard boxcar or customized
    
%  Text that displays the boxcar selection (standard/customized). Shows up
%  once the breathhold has been selected, and if pf is not selected as the
%  stimfile
mp.boxcarsel = uicontrol('Style','text',...
                        'units','normalized',...
                        'String',show_boxcar_string,...
                        'position',[0.15,0.54,0.7,0.05]); 
end

switch(mp.menu(1).Value) % stimfile menu selection
    case(2) % stimfile selection is boxcar 
        if (mp.menu(2).Value == 2) % processed data 
            type = [placeholder '_boxcar']; 
            functional_data = [directories.flirtdir '/' type '/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_FIVE_anat_space.nii'];
        elseif(mp.menu(2).Value == 3) % raw data 
            type = [placeholder '_boxcar_raw'];
            functional_data = [directories.flirtdir '/' type '/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_FIVE_anat_space.nii'];
        end    
        montage_info = [placeholder '_boxcar']; % variable used in make_montage.m to find the correct REDCap text file 
        
    case(3) % stimfile selection is pf 
        if (mp.menu(2).Value == 2) % processed data 
            type = 'pf';
            functional_data = [directories.flirtdir '/' type '/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_FIVE_anat_space.nii'];
        elseif(mp.menu(2).Value == 3) % raw data
            type = 'pf_raw';
            functional_data = [directories.flirtdir '/' type '/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_FIVE_anat_space.nii'];
        end    
        montage_info = 'pf';
end

%  Load the functional file that was transformed to anatomical space 
funct.mapped_anat = load_nii([directories.subject '/' functional_data]);

%  DISPLAY THE SLICES IN WINDOWS
%  AXIAL WINDOW

%  Create window to display axial slices
ax_window.f = figure('Name', 'Axial',...
                    'Visible','on',...
                    'Position',[327,750,800,850],...
                    'numbertitle','off');
                
set(ax_window.f, 'MenuBar', 'none'); % remove the menu bar 
set(ax_window.f, 'ToolBar', 'none'); % remove the tool bar                
    
%  Text that displays the slider/slice position
ax_window.position_slider = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'String',anat.slice_z,...
                                    'position',[0.03 0.22 0.1 0.15]);   
                                
%  Button to draw ROI and graph the timeseries 
ax_window.drawROI = uicontrol('Style','pushbutton',...
                                'Visible','on',...
                                'String','Draw ROI',...
                                'Value',0,'Position',[300,30,150,75],...
                                'Callback',{@drawROI,anat,directories,subj,mp}); 

%  Text that describes regional mask dropdown
ax_window.regional_mask_text = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'String','Apply regional masks',...
                                    'position',[0.65 0.08 0.25 0.05]);                            
                            
%  Create menu for selecting pre-determined ROI to pull the timeseries 
ax_window.predetermined_ROI = uicontrol('Style','popupmenu',...
                                'Visible','on',...
                                'String',{'None','Remove Ventricles and Venosinuses','Only White Matter','Only Gray Matter','Only Cerebellum'},...
                                'Position',[500,2,235,75],...
                                'callback',{@predetermined_ROI,anat,funct,directories,mp,subj});
                            
%  Slider to control axial slice position                       
ax_window.slider = uicontrol('style', 'slider',...
                            'Min',1,'Max',anat.z,'Value',anat.slice_z,... 
                            'units', 'normalized',...
                            'SliderStep',[1/anat.z,10/anat.z],...
                            'position',[0.04 0.45 0.08 0.25],...
                            'callback',{@sliderpos_ax,anat,mp,funct,ax_window,directories,subj,GUI});

%  Descriptive text of slider/slice position    
ax_window.text_slider = uicontrol('Style', 'text',...
                                'units', 'normalized',...
                                'position', [0.03 0.73 0.1 0.15],...
                                'String', 'Axial Slice Position');
    
%  Button to generate and show montage of CVR maps (5 by 5 as jpeg)
dimension_value_ax = 1;
ax_window.montage_b = uicontrol('Style','pushbutton',...
                                'Visible','on',...
                                'String','Generate Montage',...
                                'Value',0,'Position',[100,30,150,75],...
                                'callback',{@make_montage,anat,funct,mp,type,subj,directories,montage_info});       
                            
% Display the axial slice 
ax_window.image = imshow(anat.slice_ax);

guidata(ax_window.f,ax_window);

%  CORONAL WINDOW

%  Create window to display coronal slices
cor_window.f = figure('Name', 'Coronal',...
        'Visible','on',...
        'Position',[1130,750,600,410],...
        'numbertitle','off');

set(cor_window.f, 'MenuBar', 'none'); % remove the menu bar 
set(cor_window.f, 'ToolBar', 'none'); % remove the tool bar   
    
%  Text that displays the slider/slice position
cor_window.position_slider = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'String',anat.slice_y,...
                                    'position',[0.03 0.22 0.1 0.15]); 

%  Slider object to control coronal slice position
cor_window.slider = uicontrol('style', 'slider',...
                            'Min',1,'Max',anat.y,'Value',anat.slice_y,... 
                            'units', 'normalized',...
                            'SliderStep',[1/anat.y,10/anat.y],...
                            'position',[0.04 0.45 0.08 0.25],...
                            'callback',{@sliderpos_cor,anat,mp,funct,cor_window,directories,subj,GUI});
    
%  Descriptive text of slider/slice position 
cor_window.text_slider = uicontrol('Style', 'text',....
                                'units', 'normalized',...
                                'position', [0.03 0.73 0.1 0.15],...
                                'String', 'Coronal Slice Position');
    
%  Display the coronal slice                             
imshow(anat.slice_cor);

%  SAGITTAL WINDOW

%  Create window to display sagittal slices
sag_window.f = figure('Name', 'Sagittal',...  
                    'Visible','on',...
                    'Position',[1130,208,600,410],...
                    'numbertitle','off');
                
set(sag_window.f, 'MenuBar', 'none'); % remove the menu bar 
set(sag_window.f, 'ToolBar', 'none'); % remove the tool bar

%  Text that displays the slider/slice position
sag_window.position_slider = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'String',anat.slice_x,...
                                    'position',[0.03 0.22 0.1 0.15]); 
                        
%  Slider object to control sagittal slice position
sag_window.slider = uicontrol('style', 'slider',...
                            'Min',1,'Max',anat.x,'Value',anat.slice_x,... 
                            'units', 'normalized',...
                            'SliderStep',[1/anat.x,10/anat.x],...
                            'position',[0.04 0.45 0.08 0.25],...
                            'callback',{@sliderpos_sag,anat,mp,funct,sag_window,directories,subj,GUI});

%  Descriptive text of slider/slice position    
sag_window.text_slider = uicontrol('Style', 'text',...
                                'units', 'normalized',...
                                'position', [0.03 0.73 0.1 0.15],...
                                'String', 'Sagittal Slice Position');
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
%  Display the sagittal slice 
imshow(anat.slice_sag);

set(mp.CVRb,'enable','on'); % enable the button for user to overlay CVR maps on to anatomical slices 
set(mp.t,'enable','on'); % enable t_stat slider 
set(mp.program_again,'enable','on'); % allow user to run the program again to select different parameters 
