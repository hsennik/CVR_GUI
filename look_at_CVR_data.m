% GUI for clinician view CVR subject data
% 
% Parameters:
%   Processing: Processed OR unprocessed
%   Stimfiles: boxcar, posterior fossa (pf)
%   T-statistic: change to threshold parametric map 

% Data that can be displayed:
%   Anatomical slices: axial,coronal,sagittal
%   Parametric maps overlain on anatomicals
%   Pull timeseries from drawn ROI - plot of timeseries against stimfile 
%   Pull timeseries from predetermined 3D ROI of brain region 
%   Axial anatomical images with brain regions masked
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  INITIALIZE VARIABLES

GUI = 2; % indicates that this is the second GUI (after process/analyze)
addpath('/data/wayne/matlab/NIFTI'); % add path to nifti functions 

%  DIRECTORIES
directories.matlabdir = '/data/hannahsennik/MATLAB/CVR_GUI';
directories.flirtdir = 'flirt';
directories.matlab = 'matlab';
directories.timeseries = 'timeseries';
directories.textfilesdir = 'textfiles';
directories.REDCapdir = 'REDCap_import_files';
directories.metadata = 'metadata';
directories.montagedir = 'montage';

%  SUBJECT DATA
fileID = fopen([directories.matlabdir '/subject_name.txt'],'r'); % Subject name is pulled from this textfile (this is the subject that was just fully processed and analyzed)
subj.name = fscanf(fileID,'%s\n');
fclose(fileID);

directories.subject = ['/data/projects/CVR/GUI_subjects/' subj.name];
cd(directories.subject); % Move in to subject directory

fileID = fopen([directories.textfilesdir '/breathhold_selection.txt'],'r'); % Subject name is pulled from this textfile (this is the subject that was just fully processed and analyzed)
subj.breathhold = fscanf(fileID,'%s\n');
fclose(fileID);

fileID = fopen([directories.textfilesdir '/gen_selection.txt'],'r'); 
subj.proc_rec_sel = fscanf(fileID,'%s\n');
fclose(fileID);

subj.date = '160314';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CREATING THE INTERFACE

%  Create the MAIN PANEL
mp.f = figure('Name', 'View Data',...
                    'Visible','on',...
                    'Position',[25,750,300,700],...
                    'numbertitle','off');

%  Create refresh button.
mp.again = uicontrol('Style','pushbutton',...
                    'Visible','on',...
                    'Enable','on',...
                    'Value',0,'Position',[260,665,30,30],...
                    'callback',@run_again);     
                
icon=imread([directories.matlabdir '/refresh.png']);
set(mp.again,'CData',icon);              

%  Subject name            
mp.text(1) = uicontrol('Style','text',...
                        'units','normalized',...
                        'Position',[0.2,0.8,0.6,0.15],...
                        'String',['Subject name: ' subj.name]);

 %  Subject breathhold             
mp.text(2) = uicontrol('Style','text',...
                        'units','normalized',...
                        'Position',[0.2,0.75,0.6,0.15],...
                        'String',['Study: ' subj.breathhold]);           

%  Descriptive text for the stimfile selection dropdown menu                        
mp.text(3) = uicontrol('Style','text',...
                        'units','normalized',...
                        'Position',[0.2,0.72,0.6,0.1],...
                        'String','Select stimfile');
                
%  Descriptive text for the processing dropdown menu                
mp.text(4) = uicontrol('Style','text',...
                        'units','normalized',...
                        'Position',[0.2,0.59,0.6,0.1],...
                        'String','Select data to view');                

%  Descriptive text for the stimfile selection dropdown menu                        
mp.text(5) = uicontrol('Style','text',...
                        'units','normalized',...
                        'Position',[0.2,0.46,0.6,0.1],...
                        'String','Select glm bucket');                          

%  Establishing what should be in stimfile dropdown based on what stimfiles
%  have been used for subject's breathhold analysis
C{1} = '';
if exist(['data/analyzed_standard_boxcar/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2     
    C{2} = 'Standard Boxcar';
    if exist(['data/analyzed_shifted_boxcar/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2  
        C{3} = 'Shifted Boxcar';
        if exist(['data/analyzed_customized_boxcar/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2 
            C{4} = 'Customized Boxcar';
            if exist(['data/analyzed_pf/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2  
                C{5} = 'Cerebellum';
                if exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
                    C{6} = 'Sawtooth';
                end
            elseif exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
                C{5} = 'Sawtooth';
            end
        elseif exist(['data/analyzed_pf/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2  
            C{4} = 'Cerebellum';
            if exist (['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
                C{5} = 'Sawtooth';
            end
        elseif exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
            C{4} = 'Sawtooth';
        end
    elseif exist(['data/analyzed_customized_boxcar/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2 
        C{3} = 'Customized Boxcar';
        if exist(['data/analyzed_pf/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2  
            C{4} = 'Cerebellum';
            if exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
                C{5} = 'Sawtooth';
            end
        elseif exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
            C{4} = 'Sawtooth';
        end
    elseif exist(['data/analyzed_pf/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2  
        C{3} = 'Cerebellum';
        if exist (['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
            C{4} = 'Sawtooth';
        end
    elseif exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
        C{3} = 'Sawtooth';
    end
elseif exist(['data/analyzed_shifted_boxcar/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2  
    C{2} = 'Shifted Boxcar';
    if exist(['data/analyzed_customized_boxcar/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2 
        C{3} = 'Customized Boxcar';
        if exist(['data/analyzed_pf/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2  
            C{4} = 'Cerebellum';
            if exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
                C{5} = 'Sawtooth';
            end
        elseif exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
            C{4} = 'Sawtooth';
        end
    elseif exist(['data/analyzed_pf/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2  
        C{3} = 'Cerebellum';
        if exist (['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
            C{4} = 'Sawtooth';
        end
    elseif exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
        C{3} = 'Sawtooth';
    end
elseif exist(['data/analyzed_customized_boxcar/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2 
    C{2} = 'Customized Boxcar';
    if exist(['data/analyzed_pf/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2  
        C{3} = 'Cerebellum';
        if exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
            C{4} = 'Sawtooth';
        end
    elseif exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
        C{3} = 'Sawtooth';
    end
elseif exist(['data/analyzed_pf/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2  
    C{2} = 'Cerebellum';
    if exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
        C{3} = 'Sawtooth';
    end
elseif exist(['data/analyzed_sawtooth/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
    C{2} = 'Sawtooth';
end       
 
%  Create menu for stimfile selection
mp.menu(1) = uicontrol('Style','popupmenu',...
                        'Visible','on',...
                        'Enable','off',...
                        'String',C,...
                        'Position',[50,485,200,60]);

%  Create menu for pre-processing (options are pre-processed or raw)
mp.menu(2) = uicontrol('Style','popupmenu',...
                    'Visible','on',...
                    'Enable','off',...
                    'String',{'','pre-processed','raw'},...
                    'Position',[50,395,200,60]);

mp.STR3 = {'','coefficient','t-statistic','R-squared'}; % String for glm bucket                    
%  Create menu for glm bucket selection (options are t-statistic,coefficient,R2)
mp.menu(3) = uicontrol('Style','popupmenu',...
                        'Visible','on',...
                        'Enable','off',...
                        'String',mp.STR3,...
                        'Position',[50,305,200,60]);                    
                    
%  Toggle button to overlay CVR map
mp.CVRb = uicontrol('Style','togglebutton',...
                'Visible','on',...
                'String','Overlay CVR map',...
                'Enable','off',...
                'Value',0,'Position',[20,210,150,60],...
                'callback',@pushstate);              
                
%  Button to go back to SickKids_CVR.m
mp.quit = uicontrol('Style','pushbutton',...
                    'Visible','on',...
                    'String','BACK TO MAIN',...
                    'Value',0,'Position',[75,20,150,60],...
                    'callback',@go_to_main);
                
%  Descriptive text for threshold slider 
mp.t_text = uicontrol('Style','text',...
                    'units','normalized',...
                    'String','Threshold value: ',...
                    'position',[0.05 0.20 0.5 0.05]);  

%  Text that displays the threshold slider value
mp.t_number = uicontrol('Style','text',...
                        'units','normalized',...
                        'String',0,...
                        'position',[0.49 0.20 0.18 0.05]);                   
                    
%  Descriptive text for p-value
mp.p_text = uicontrol('Style','text',...
                    'units','normalized',...
                    'String','P-value: ',...
                    'position',[0.05 0.17 0.5 0.05]);  

%  Text that displays the p-value
mp.p_number = uicontrol('Style','text',...
                        'units','normalized',...
                        'String',0,...
                        'position',[0.49 0.17 0.18 0.05]);                                   
           
set(mp.f, 'MenuBar', 'none'); % remove the menu bar 
set(mp.f, 'ToolBar', 'none'); % remove the tool bar 

s = ['data/recon/' subj.name '/' subj.name '_anat_brain.nii'];
fname_anat = s;

anat = load_nii([directories.subject '/' fname_anat]); % Load the subject's 3D skull stripped anatomical 
[anat.x,anat.y,anat.z] = size(anat.img);

%  Slider bar to adjust the threshold for CVR map
mp.t = uicontrol('Style','slider',...
                'Min',0,'Max',1,...
                'units','normalized',...
                'Enable','off',...
                'SliderStep',[0.0001,0.001],...
                'position',[0.70 0.21 0.25 0.2],...
                'callback',{@t_slider,mp,anat}); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
%  CONSTRUCTING ANATOMICAL SLICES

%  Initial slice position - values can be changed 
anat.slice_x = 104;
anat.slice_y = 104; 
anat.slice_z = 104; 

global ax_slider_value;
ax_slider_value = anat.slice_z;

%  Slice ranges
anat.xrange = (1:anat.x);
anat.yrange = (1:anat.y);
anat.zrange = (1:anat.z); 

%  Adjusting the contrast of the anatomical scans (shrink the window of the range of values)
global sigmin;
global sigmax;

fileID = fopen([directories.textfilesdir '/sigvals.txt'],'r'); 
format = '%d\n';
sigmin = fgetl(fileID);
sigmax = fgetl(fileID);
fclose(fileID);

sigmin = str2double(sigmin);
sigmax = str2double(sigmax);

%  Preparing slices to be displayed in each dimension 
%  AXIAL slice
anat.slice_ax = (double(repmat(imresize(squeeze(anat.img(:,:,anat.slice_z)),[anat.x anat.y]), [1 1 3]))- sigmin) / sigmax ;
anat.slice_ax = imresize(anat.slice_ax,[anat.x anat.y/anat.hdr.dime.pixdim(1)]);
anat.slice_ax = rot90(anat.slice_ax(anat.xrange,anat.yrange,:));
anat.slice_ax = flip(anat.slice_ax,2);

%  CORONAL slice
anat.slice_cor = (double(repmat(imresize(squeeze(anat.img(:,anat.slice_y,:)),[anat.x anat.z]), [1 1 3])) - sigmin) / sigmax;
anat.slice_cor = imresize(anat.slice_cor,[anat.x anat.z/anat.hdr.dime.pixdim(2)]);
anat.slice_cor = rot90(anat.slice_cor(anat.xrange,anat.zrange,:));
anat.slice_cor = flip(anat.slice_cor,2);

%  SAGITTAL slice
anat.slice_sag = (double(repmat(imresize(squeeze(anat.img(anat.slice_x,:,:)),[anat.y anat.z]), [1 1 3])) - sigmin) / sigmax;
anat.slice_sag = imresize(anat.slice_sag,[anat.y anat.z/anat.hdr.dime.pixdim(3)]);
anat.slice_sag = rot90(anat.slice_sag(anat.yrange,anat.zrange,:));
anat.slice_sag = flip(anat.slice_sag,2);
                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LOAD THE FUNCTIONAL DATA

set(mp.menu(1),'Enable','on'); % enable stimfile selection dropdown
waitfor(mp.menu(1),'Value'); % wait for user response

if strcmp(mp.menu(1).String(mp.menu(1).Value),'Standard Boxcar') == 1
    flirtext = 'standard_boxcar';
    stim = [directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D'];
elseif strcmp(mp.menu(1).String(mp.menu(1).Value),'Shifted Boxcar') == 1
    flirtext = 'shifted_boxcar';
    stim = [directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_shifted.1D'];
elseif strcmp(mp.menu(1).String(mp.menu(1).Value),'Customized Boxcar') == 1
    flirtext = 'customized_boxcar';
    stim = [directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_customized.1D'];
elseif strcmp(mp.menu(1).String(mp.menu(1).Value),'Cerebellum') == 1    
    flirtext = 'pf';
    stim = [directories.metadata '/stim/pf_stim_' subj.breathhold '_processed.1D'];
elseif strcmp(mp.menu(1).String(mp.menu(1).Value),'Sawtooth') == 1
    flirtext = 'sawtooth';
    stim = [directories.metadata '/stim/bhonset' subj.name '_sawtooth.1D'];
end

montage_info = flirtext;

if exist(['data/analyzed_' flirtext '_raw/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2 
    set(mp.menu(2),'String',{'','pre-processed','raw'}); % String for pre-processing popup
else 
    set(mp.menu(2),'String',{'','pre-processed'});
end

set(mp.menu(1),'Enable','off'); % disable stimfile selection dropdown 
set(mp.menu(2),'Enable','on'); % enable processing selection dropdown 
waitfor(mp.menu(2),'Value'); % wait for user response 
set(mp.menu(2),'enable','off'); 
set(mp.menu(3),'Enable','on'); % enable glm selection dropdown
waitfor(mp.menu(3),'Value'); % wait for user response
set(mp.menu(3),'Enable','off'); % disable glm selection dropdown 

if strcmp(mp.menu(3).String(mp.menu(3).Value),'t-statistic') == 1
    funct_name = 'tstat';
elseif strcmp(mp.menu(3).String(mp.menu(3).Value),'coefficient') == 1
    funct_name = 'coeff';
elseif strcmp(mp.menu(3).String(mp.menu(3).Value),'R-squared') == 1
    funct_name = 'R2';
end

fileID = fopen([directories.subject '/textfiles/processing.txt'],'w+'); % open the file that indicates whether or not to do processing 
format = '%d';

if(mp.menu(2).Value == 2) % if the user chooses to display the processed data, write 1 to the file 
    fprintf(fileID,format,1); 
    fclose(fileID);
    display('processing');
    type = flirtext;
elseif(mp.menu(2).Value == 3) % if the user chooses to display the raw data, write 0 to the file 
    fprintf(fileID,format,0);
    fclose(fileID);
    display('no processing');
    type = [flirtext '_raw'];
end

functional_data = [directories.flirtdir '/' type '/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_' funct_name '_anat_space.nii'];

%  Load the functional file that was transformed to anatomical space 
funct.mapped_anat = load_nii([directories.subject '/' functional_data]);

%  Find the max and min values from the statistical bucket (use these for
%  the slider)
max_funct = max(funct.mapped_anat.img(:));
min_funct = min(funct.mapped_anat.img(:));

thresh_near = max(abs(max_funct),abs(min_funct)); % set max threshold value to the absolute value of either the max or min bucket value 

thresh_near = round(thresh_near,3);

set(mp.t,'Max',thresh_near);
set(mp.t,'SliderStep',[thresh_near/1000,thresh_near/100]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  AXIAL WINDOW

%  Create window to display axial slices
ax_window.f = figure('Name', 'Axial',...
                    'Visible','on',...
                    'Position',[327,750,800,850],...
                    'numbertitle','off');
                
% set(ax_window.f, 'MenuBar', 'none'); % remove the menu bar 
% set(ax_window.f, 'ToolBar', 'none'); % remove the tool bar                
    
%  Text that displays the slider/slice position
ax_window.position_slider = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'String',anat.slice_z,...
                                    'position',[0.045 0.38 0.07 0.03]);   
                                
%  Button to draw ROI and graph the timeseries 
ax_window.drawROI = uicontrol('Style','pushbutton',...
                                'Visible','on',...
                                'String','Draw ROI',...
                                'Value',0,'Position',[300,30,150,75],...
                                'Callback',{@drawROI,anat,directories,subj,mp,stim}); 

%  Text that describes regional mask dropdown
ax_window.regional_mask_text = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'String','Apply regional masks',...
                                    'position',[0.65 0.08 0.25 0.05]);                            
                            
%  Create menu for selecting pre-determined ROI to pull the timeseries 
ax_window.predetermined_ROI = uicontrol('Style','popupmenu',...
                                'Visible','on',...
                                'String',{'Remove Ventricles and Venosinuses','Only White Matter','Only Gray Matter','None'},...
                                'Position',[500,25,235,50],...
                                'callback',{@predetermined_ROI,anat,funct,directories,mp,subj,stim});

fileID = fopen([directories.subject '/' directories.textfilesdir '/create_segmentation_masks.txt'],'r');
format = '%d\n';                            
generate_maps = fgetl(fileID);
fclose(fileID);
if strcmp(generate_maps,'0') == 1
    set(ax_window.predetermined_ROI,'String',{'None',''});
    set(ax_window.predetermined_ROI,'Enable','off');
end

global onlypositive;
global onlynegative;
onlypositive = 1;
onlynegative = 1;

ax_window.positive_map = uicontrol('Style','checkbox',...
                                   'String','Positive',...
                                   'Value',1,...
                                   'Position', [500,10,100,20],...
                                   'Callback',@positive_map);

ax_window.negative_map = uicontrol('Style','checkbox',...
                                   'String','Negative',...
                                   'Value',1,...
                                   'Position',[650,10,100,20],...
                                   'Callback',@negative_map);
                            
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
                                'position', [0.03 0.7 0.1 0.05],...
                                'String', 'Axial Slice Position');
    
%  Button to generate and show montage of CVR maps (5 by 5 as jpeg)
dimension_value_ax = 1;
ax_window.montage_b = uicontrol('Style','pushbutton',...
                                'Visible','on',...
                                'String','Generate Montage',...
                                'Value',0,'Position',[100,30,150,75],...
                                'callback',{@make_montage,anat,funct,mp,type,subj,directories,montage_info,stim});       
                            
% Display the axial slice 
ax_window.image = imshow(anat.slice_ax);

guidata(ax_window.f,ax_window);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                            'callback',{@sliderpos_cor,anat,mp,funct,cor_window,directories,subj,GUI,ax_window});
    
%  Descriptive text of slider/slice position 
cor_window.text_slider = uicontrol('Style', 'text',....
                                'units', 'normalized',...
                                'position', [0.03 0.73 0.1 0.15],...
                                'String', 'Coronal Slice Position');
    
%  Display the coronal slice                             
imshow(anat.slice_cor);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
                            'callback',{@sliderpos_sag,anat,mp,funct,sag_window,directories,subj,GUI,ax_window});

%  Descriptive text of slider/slice position    
sag_window.text_slider = uicontrol('Style', 'text',...
                                'units', 'normalized',...
                                'position', [0.03 0.73 0.1 0.15],...
                                'String', 'Sagittal Slice Position');
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
%  Display the sagittal slice 
imshow(anat.slice_sag);

if strcmp(generate_maps,'1') == 1
    default_timeseries = [directories.timeseries '/no_csf_' subj.breathhold '.1D'];
    timeseries_name = 'Entire Brain - ventricles removed';
else
    default_timeseries = [directories.timeseries '/brain_average.1D'];
    timeseries_name = 'Entire Brain';
end

shift_custom_capability = 5;
boxcar_name = mp.menu(1).String(mp.menu(1).Value);
boxcar_name = boxcar_name{1};
figname = 'Entire Brain Timeseries';
pos = [1130,400,600,410];
funct_space = (['data/processed/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii']);
funct_space = load_nii([directories.subject '/' funct_space]);

plotfiles(directories,subj,default_timeseries,stim,pos,figname,shift_custom_capability,timeseries_name,boxcar_name,funct_space,mp);

set(mp.CVRb,'enable','on'); % enable the button for user to overlay CVR maps on to anatomical slices 
set(mp.t,'enable','on'); % enable t_stat slider 
