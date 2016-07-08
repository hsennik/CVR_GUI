% GUI for clinician to fully process and analyze a subject who has
% undergone a CVR study 
% 
% File Name: process_subject.m
% 
% NOTES - HS - 16/05/30 - Initial Creation
% 
% AUTHOR - Hannah Sennik
% Created - 2016-05-30

clear all; % Clear all variables
close all; % Close all windows 

addpath('/data/wayne/matlab/NIFTI'); % path to nii functions
directory = ('/data/projects/CVR/GUI_subjects/'); % base directory where all CVR subjects are stored
cd(directory); % change to this directory 
subject_names = dir(directory);

%  Create the entire interface panel
sp.f = figure('Name', 'Process and Analyze Subject',...
                        'Visible','on',...
                        'Position',[50,800,300,500],...
                        'numbertitle','off');
    
%  Descriptive text for the select subject dropdown menu                
sp.text(1) = uicontrol('Style','text',...
                        'units','normalized',...end
                        'Position',[0.35,0.73,0.3,0.2],...
                        'String','Select subject');
        
%  Create the popupmenu to select subject to process

sp.STR = {'',subject_names(3:end).name}; % pull the directory names of patients from directory where CVR subjects are stored 
sp.menu(1) = uicontrol('Style','popupmenu',...
                        'Visible','on',...
                        'String',sp.STR,...
                        'Position',[50,400,200,25]);

waitfor(sp.menu(1),'Value');   % Wait for a subject to be selected            
set(sp.menu(1),'Enable','off'); % Disable subject field once subject is selected
temp_name = sp.menu(1).String(sp.menu(1).Value); 
subj.name = temp_name{1}; 
display(subj.name);

dir_input = strcat(directory,subj.name,'/');
cd(dir_input); % Change to subject's directory 
subj.date = '160314'; % What is this - is it the same for all subjects?
mkdir('textfiles');

matlabdir = '/data/hannahsennik/MATLAB/CVR_GUI';
fileID = fopen(strcat(matlabdir,'/subject_name.txt'),'w+'); % Open the subject name text file in write mode
         format = '%s\n';
         fprintf(fileID,format,subj.name); % Write the subject name to file - this is used in the main GUI to look at the correct subject data 
         fclose(fileID);
display('Subject name file created');

%  Create push button to look at subject data after processing and analysis
%  is complete 
sp.look = uicontrol('Style','pushbutton',...
                   'Visible','on',...
                   'String','Look at Subject Data',...
                   'Value',0,'Position',[50,30,200,60],...
                   'Enable','off',...
                   'callback',@run_again); % Call function to run the display GUI ('basic_UI_function.m')
               
%  Create push button to process and analyze subject.
sp.start = uicontrol('Style','pushbutton',...
                    'Visible','on',...
                    'String','Process and Analyze Subject',...,
                    'Enable','off',...
                    'Value',0,'Position',[50,110,200,60],...
                    'callback',{@startprocessing,subj,dir_input});

%  Checkbox for BH and HV customized boxcars - user can choose to create
%  customized boxcars for all breathholds, or select specific ones
sp.custom(4) = uicontrol ('Style','checkbox',...
                          'Visible','on',...
                          'String','BH1 & BH2 same',...
                          'HandleVisibility','on',...
                          'Position',[150,248,200,25],...
                          'Enable','off',...
                          'callback',{@create_BH1BH2boxcar,subj,dir_input,sp});
sp.custom(1) = uicontrol('Style','checkbox',...
                        'Visible','on',...
                        'String','BH1',...
                        'HandleVisibility','on',...
                        'Position',[75,265,50,25],...
                        'Enable','off',...
                        'callback',{@create_BH1boxcar,subj,dir_input,sp});
                    
sp.custom(2) = uicontrol('Style','checkbox',...
                        'Visible','on',...
                        'String','BH2',...
                        'HandleVisibility','on',...
                        'Position',[75,230,50,25],...
                        'Enable','off',...
                        'callback',{@create_BH2boxcar,subj,dir_input,sp});  
                    
sp.custom(3) = uicontrol('Style','checkbox',...
                        'Visible','on',...
                        'String','HV',...
                        'HandleVisibility','on',...
                        'Position',[75,195,50,25],...
                        'Enable','off',...
                        'callback',{@create_HVboxcar,subj,dir_input,sp});  
                    
%  Create radiobuttons to select between standard and customized boxcar (can
%  only choose one or the other) 

%  Radiobutton for standard single staggered boxcar 
%  If this option is selected, the user is ready to process and analyze the
%  subject, no further steps are required 
sp.boxcar(1) = uicontrol('Style','radiobutton',...
                        'Visible','on',...
                        'Units','pixels',...
                        'String','Standard Single Staggered',...
                        'HandleVisibility','on',...
                        'Position',[50,350,200,25],...
                        'Enable','on',...
                        'Callback',{@myRadio,subj,dir_input}); 
                    
%  Radiobutton for customized boxcar 
sp.boxcar(2) = uicontrol('Style','radiobutton',...
                        'Visible','on',...
                        'Units','pixels',...
                        'String','Customized Boxcar',...
                        'HandleVisibility','on',...
                        'Position',[50,300,200,25],...
                        'Enable','on',...
                        'Callback',{@myRadio,subj,dir_input}); 
                
%  Get figure data 
guidata(sp.f,sp);                  