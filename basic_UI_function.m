%  Template interface (generalized for several subjects)

clear all;
close all;

addpath('/data/wayne/matlab/NIFTI');
fileID = fopen('/data/hannahsennik/MATLAB/CVR_GUI/subject_name.txt','r');
subj.name = fscanf(fileID,'%s\n');
dir_input = strcat('/data/projects/CVR/GUI_subjects/',subj.name);
subj.date = '160314';

cd(dir_input);

%  Clinician already enters subject to look at in run_python 
%  Step 1: Clinician specifies processing parameters and selects stimfile

%  MAIN PANEL (mp)
mp.f = figure('Name', 'CVR Menu',...
                    'Visible','on',...
                    'Position',[50,800,300,700]);

% %  Descriptive text for the temporal filtering dropdown menu                
% mp.text(1) = uicontrol('Style','text',...
%                 'units','normalized',...
%                 'Position',[0.15,0.85,0.6,0.1],...
%                 'String','Select temporal filtering');

%  Descriptive text for the processing dropdown menu                
mp.text(1) = uicontrol('Style','text',...
                'units','normalized',...
                'Position',[0.15,0.85,0.6,0.1],...
                'String','Apply pre-processing?');

%  Descriptive text for the stimfile selection dropdown menu                        
mp.text(2) = uicontrol('Style','text',...
                    'units','normalized',...
                    'Position',[0.15,0.72,0.6,0.1],...
                    'String','Select stimfile');
                
%  Descriptive text for the breathhold selection dropdown menu
mp.text(3) = uicontrol('Style','text',...
                       'units','normalized',...
                       'Position',[0.15,0.59,0.6,0.1],...
                       'String','Select breath hold');
        
%  Popupmenus to select temporal filtering and stimfile to generate map

mp.STR = {'','Boxcar','Posterior fossa'}; % String for stimfile popup
% mp.STR2 = {'','none','mpe','MD'}; % String for temporal filtering popup
mp.STR2 = {'','yes','no'}; % String for pre-processing popup
mp.STR3 = {'','BH1','BH2'}; % String for breathhold popup

mp.menu(2) = uicontrol('Style','popupmenu',...
                'Visible','on',...
                'String',mp.STR2,...
                'Position',[35,575,200,60]);
            
mp.menu(1) = uicontrol('Style','popupmenu',...
                        'Visible','on',...
                        'Enable','off',...
                        'String',mp.STR,...
                        'Position',[35,485,200,60]);

mp.menu(3) = uicontrol('Style','popupmenu',...
                       'Visible','on',...
                       'Enable','off',...
                       'String',mp.STR3,...
                       'Position',[35,395,200,60]);

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
                    'Value',0,'Position',[20,150,150,60],...
                    'callback',@run_again);
                
%  Button to terminate the program
mp.quit = uicontrol('Style','togglebutton',...
                    'Visible','on',...
                    'String','Quit',...
                    'Value',0,'Position',[20,50,80,60],...
                    'callback',@quit_program);
                
%  Descriptive text for t_stat slider 
mp.t_text = uicontrol('Style','text',...
                    'units','normalized',...
                    'String','T-stat slider value: ',...
                    'position',[0.05 0.33 0.5 0.05]);  

%  Text that shows the t_stat slider value
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
            
%  Step 2 - the anatomical image is loaded from recon and slices are
%  displayed to the user

% waitfor(mp.menu(2),'Value'); % Wait for the user to select a filtering method 
% 
% if (mp.menu(2).Value == 2)
%     s = strcat('/data/recon_none/',subj.name,'/',subj.name,'_anat_brain.nii');
%     fname_anat = s;
% elseif(mp.menu(2).Value == 3)
%     s = strcat('/data/recon_mpe/',subj.name,'/',subj.name,'_anat_brain.nii');
%     fname_anat = s;
% elseif(mp.menu(2).Value == 4)
%     s = strcat('/data/recon_MD/',subj.name,'/',subj.name,'_anat_brain.nii');
%     fname_anat = s;
% end

waitfor(mp.menu(2),'Value'); % Wait for user to select whether they want processing or not 

if(mp.menu(2).Value == 2)
    s = strcat('data/recon_none/',subj.name,'/',subj.name,'_anat_brain.nii');
    fname_anat = s;
elseif(mp.menu(2).Value == 3)
    s = strcat('data/recon/',subj.name,'/',subj.name,'_anat_brain.nii');
    fname_anat = s;
end

anat = load_nii([dir_input '/' fname_anat]);
[anat.x,anat.y,anat.z] = size(anat.img);

%  CONSTRUCTING ANATOMICAL SLICES

%  Initial slice position
anat.slice_x = 120;
anat.slice_y = 104; 
anat.slice_z = 55; 

%  Slice ranges
anat.xrange = (1:anat.x);
anat.yrange = (1:anat.y);
anat.zrange = (1:anat.z); 

%  Adjusting the contrast of the anatomical scans (shrink the window of the range of values)
anat.sigmin = 10; 
anat.sigmax = 500; 

%  AXIAL
anat.slice_ax = (double(repmat(imresize(squeeze(anat.img(:,:,anat.slice_z)),[anat.x anat.y]), [1 1 3]))- anat.sigmin) / anat.sigmax ;
anat.slice_ax = imresize(anat.slice_ax,[anat.x anat.y/anat.hdr.dime.pixdim(4)]);
anat.slice_ax = rot90(anat.slice_ax(anat.xrange,anat.yrange,:));
anat.slice_ax = flip(anat.slice_ax,2);

%  CORONAL
anat.slice_cor = (double(repmat(imresize(squeeze(anat.img(:,anat.slice_y,:)),[anat.x anat.z]), [1 1 3])) - anat.sigmin) / anat.sigmax;
anat.slice_cor = imresize(anat.slice_cor,[anat.x anat.z/anat.hdr.dime.pixdim(3)]);
anat.slice_cor = rot90(anat.slice_cor(anat.xrange,anat.zrange,:));
anat.slice_cor = flip(anat.slice_cor,2);

%  SAGGITAL
anat.slice_sag = (double(repmat(imresize(squeeze(anat.img(anat.slice_x,:,:)),[anat.y anat.z]), [1 1 3])) - anat.sigmin) / anat.sigmax;
anat.slice_sag = imresize(anat.slice_sag,[anat.y anat.z/anat.hdr.dime.pixdim(2)]);
anat.slice_sag = rot90(anat.slice_sag(anat.yrange,anat.zrange,:));
anat.slice_sag = flip(anat.slice_sag,2);
                 
%  LOAD THE FUNCTIONAL DATA

%  Allow user to select stimfile and then disable temporal filtering and
%  stimfile dropdowns
set(mp.menu(1),'Enable','on');
waitfor(mp.menu(1),'Value');
set(mp.menu(3),'Enable','on');
waitfor(mp.menu(3),'Value');
set(mp.menu(1),'enable','off');
set(mp.menu(2),'enable','off');
set(mp.menu(3),'enable','off');

if(mp.menu(3).Value==2)
    subj.breathhold = 'BH1';
elseif(mp.menu(3).Value==3)
    subj.breathhold = 'BH2';
end

% switch(mp.menu(1).Value)
%     case(2)
%         if (mp.menu(2).Value == 2)
%             type = 'none_boxcar';
%             s2 = strcat('flirt/',type,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE_anat_space.nii');
%             fname_mapped = s2;
%         elseif(mp.menu(2).Value == 3)
%             type = 'mpe_boxcar';
%             s2 = strcat('flirt/',type,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE_anat_space.nii');
%             fname_mapped = s2;
%         elseif(mp.menu(2).Value == 4)
%             type = 'MD_boxcar';
%             s2 = strcat('flirt/',type,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE_anat_space.nii');
%             fname_mapped = s2;
%         end    
%         
%     case(3)
%         if (mp.menu(2).Value == 2)
%             type = 'none_pf';
%             s2 = strcat('flirt/',type,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE_anat_space.nii');
%             fname_mapped = s2;
%         elseif(mp.menu(2).Value == 3)
%             type = 'mpe_pf';
%             s2 = strcat('flirt/',type,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE_anat_space.nii');
%             fname_mapped = s2;
%         elseif(mp.menu(2).Value == 4)
%             type = 'MD_pf';
%             s2 = strcat('flirt/',type,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE_anat_space.nii');
%             fname_mapped = s2;
%         end    
% end

switch(mp.menu(1).Value)
    case(2)
        if (mp.menu(2).Value == 2)
            type = 'none_boxcar'; % making default temporal filtering none for now 
            s2 = strcat('flirt/',type,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE_anat_space.nii');
            fname_mapped = s2;
        elseif(mp.menu(2).Value == 3)
            type = 'no_processing_boxcar';
            s2 = strcat('flirt/',type,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_masked_FIVE_anat_space.nii');
            fname_mapped = s2;
        end    
        
    case(3)
        if (mp.menu(2).Value == 2)
            type = 'none_pf';
            s2 = strcat('flirt/',type,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE_anat_space.nii');
            fname_mapped = s2;
        elseif(mp.menu(2).Value == 3)
            type = 'no_processing_pf';
            s2 = strcat('flirt/',type,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_masked_FIVE_anat_space.nii');
            fname_mapped = s2;
        end    
end

%  Load the output file from transformation
funct.mapped_anat = load_nii([dir_input '/' fname_mapped]);

%  DISPLAY THE SLICES IN WINDOWS
%  AXIAL WINDOW

%  Create window to display axial slices
ax_window.f = figure('Name', 'Axial',...
                    'Visible','on',...
                    'Position',[50,200,600,500]);
    
%  Text that displays the slider/slice position
ax_window.position_slider = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'String',anat.slice_z,...
                                    'position',[0.03 0.22 0.1 0.15]);    

%  Slider to control axial slice position                       
ax_window.slider = uicontrol('style', 'slider',...
                            'Min',1,'Max',anat.z,'Value',anat.slice_z,... 
                            'units', 'normalized',...
                            'SliderStep',[1/anat.z,10/anat.z],...
                            'position',[0.04 0.45 0.08 0.25],...
                            'callback',{@sliderpos_ax,anat,mp,funct,ax_window});

%  Descriptive text of slider/slice position    
ax_window.text_slider = uicontrol('Style', 'text',...
                                'units', 'normalized',...
                                'position', [0.03 0.73 0.1 0.15],...
                                'String', 'Axial Slice Position');
    
%  Button to show montage of CVR maps (5 by 5 as jpeg)
dimension_value_ax = 1;
ax_window.montage_b = uicontrol('Style','togglebutton',...
                                'Visible','on',...
                                'String','Generate Montage',...
                                'Value',0,'Position',[230,15,150,30],...
                                'callback',{@make_montage,anat,funct,mp,type,subj,dir_input});

imshow(anat.slice_ax);

jButton = findjobj(ax_window.slider);
jButton.MouseWheelMovedCallback = 'disp(clock)';

%  CORONAL WINDOW

%  Create window to display coronal slices
cor_window.f = figure('Name', 'Coronal',...
        'Visible','on',...
        'Position',[675,200,600,500]);

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
                            'callback',{@sliderpos_cor,anat,mp,funct,cor_window});
    
%  Descriptive text of slider/slice position 
cor_window.text_slider = uicontrol('Style', 'text',....
                                'units', 'normalized',...
                                'position', [0.03 0.73 0.1 0.15],...
                                'String', 'Coronal Slice Position');

% %  Button to show montage of CVR maps (5 by 5 as jpeg)
% cor_window.montage_b = uicontrol('Style','togglebutton',...
%                                 'Visible','on',...
%                                 'String','Generate Montage',...
%                                 'Value',0,'Position',[230,15,150,30],...
%                                 'callback',@pushstate);
 
imshow(anat.slice_cor);

%  SAGGITAL WINDOW

%  Create window to display saggital slices
sag_window.f = figure('Name', 'Sagittal',...  
                    'Visible','on',...
                    'Position',[1300,200,600,500]);

%  Text that displays the slider/slice position
sag_window.position_slider = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'String',anat.slice_x,...
                                    'position',[0.03 0.22 0.1 0.15]); 
                        
%  Slider object to control saggital slice position
sag_window.slider = uicontrol('style', 'slider',...
                            'Min',1,'Max',anat.x,'Value',anat.slice_x,... 
                            'units', 'normalized',...
                            'SliderStep',[1/anat.x,10/anat.x],...
                            'position',[0.04 0.45 0.08 0.25],...
                            'callback',{@sliderpos_sag,anat,mp,funct,sag_window});

%  Descriptive text of slider/slice position    
sag_window.text_slider = uicontrol('Style', 'text',...
                                'units', 'normalized',...
                                'position', [0.03 0.73 0.1 0.15],...
                                'String', 'Sagittal Slice Position');

% %  Button to show montage of CVR maps (5 by 5 as jpeg)
% sag_window.montage_b = uicontrol('Style','togglebutton',...
%                                 'Visible','on',...
%                                 'String','Generate Montage',...
%                                 'Value',0,'Position',[230,15,150,30],...
%                                 'callback',@pushstate);    

imshow(anat.slice_sag);

%  Allow user to press button to overlay CVR maps on to anatomical and
%  change the t_stat value. Allow user to run the program again with a
%  different combination of parameters.

set(mp.CVRb,'enable','on');
set(mp.t,'enable','on');
set(mp.program_again,'enable','on');
