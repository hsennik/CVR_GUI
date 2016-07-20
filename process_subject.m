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
directories.main = ('/data/projects/CVR/GUI_subjects'); % base directory where all CVR subjects are stored
cd(directories.main); % change to this directory l
subject_names = dir(directories.main); % get subject names from main directory 
subj = '';
directories.subject = '';
directories.matlabdir = '/data/hannahsennik/MATLAB/CVR_GUI'; % specify the matlab directory that contains python and standard files 

%  Create the entire interface panel
sp.f = figure('Name', 'Process and Analyze Subject',...
                        'Visible','on',...
                        'Position',[50,800,300,500],...
                        'numbertitle','off');
set(sp.f, 'MenuBar', 'none'); % remove the menu bar 
set(sp.f, 'ToolBar', 'none'); % remove the tool bar    
                    
%  Descriptive text for the select subject dropdown menu                
sp.text(1) = uicontrol('Style','text',...
                        'units','normalized',...
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
subj.name = temp_name{1}; % get the subject's name
display(subj.name);

directories.subject = [directories.main '/' subj.name]; % establish the subject's directory 
cd(directories.subject); % Change to subject's directory 

fileID = fopen([directories.matlabdir '/python/filepath.txt'],'w+'); % print the file path to a text file to be accessed by pipeline
format = '%s\n';
fprintf(fileID,format,directories.subject);
fclose(fileID);     

subj.date = '160314'; % What is this - is it the same for all subjects?

fileID = fopen([directories.matlabdir '/subject_name.txt'],'w+'); % Open the subject name text file in write mode
format = '%s\n';
fprintf(fileID,format,subj.name); % Write the subject name to file - this is used in the main GUI to look at the correct subject data 
fclose(fileID);
display('Subject name file created');
         
%  Create push button to process subject.
sp.process = uicontrol('Style','pushbutton',...
                    'Visible','on',...
                    'String','Process Subject',...,
                    'Enable','on',...
                    'Value',0,'Position',[50,325,200,60],...
                    'callback',{@processing_pipeline,subj,directories});                    
%  Get figure data 
guidata(sp.f,sp);                  