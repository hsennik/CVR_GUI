% GUI for clinician to fully process and analyze a subject who has
% undergone a CVR study 
% 
% File Name: process_subject.m
% 
% NOTES - HS - 16/05/30 - Initial Creation
% 
% AUTHOR - Hannah Sennik
% Created - 2016-05-30

clear all; % Clear all variablesl
close all; % Close all windows 

addpath('/data/wayne/matlab/NIFTI'); % path to nii functions
directories.main = ('/data/projects/CVR/GUI_subjects'); % base directory where all CVR subjects are stored
cd(directories.main); % change to this directory
subject_names = dir(directories.main); % get subject names from main directory 
subj = ''; % initialize subj variable (struct)
directories.subject = ''; % initialize subject directory
directories.matlabdir = '/data/hannahsennik/MATLAB/CVR_GUI'; % specify the matlab directory that contains python and standard files 
directories.REDCapdir = 'REDCap_import_files'; % directory name for REDCap files 
directories.metadata = 'metadata'; % directory name for subject specific files for pipeline
directories.textfilesdir = 'textfiles'; 
    
%  Create the entire interface panel
sp.f = figure('Name', 'Process and Analyze Subject',...
                        'Visible','on',...
                        'Position',[50,800,300,900],...
                        'numbertitle','off');
set(sp.f, 'MenuBar', 'none'); % remove the menu bar 
set(sp.f, 'ToolBar', 'none'); % remove the tool bar    
                    
%  Descriptive text for the select subject dropdown menu                
sp.text(1) = uicontrol('Style','text',...
                        'units','normalized',...
                        'Position',[0.35,0.78,0.3,0.2],...
                        'String','Select subject');

%  Create the popupmenu to select subject to process
sp.STR = {'',subject_names(3:end).name}; % pull the directory names of patients from directory where CVR subjects are stored 
sp.menu(1) = uicontrol('Style','popupmenu',...
                        'Visible','on',...
                        'String',sp.STR,...
                        'Position',[50,820,200,25]);

waitfor(sp.menu(1),'Value');   % Wait for a subject to be selected            
set(sp.menu(1),'Enable','off'); % Disable subject field once subject is selected
temp_name = sp.menu(1).String(sp.menu(1).Value); 
subj.name = temp_name{1}; % get the subject's name
display(subj.name);

directories.subject = [directories.main '/' subj.name]; % establish the subject's directory 
cd(directories.subject); % Change to subject's directory 

mkdir(directories.subject,directories.textfilesdir);

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

A = exist([directories.subject '/images'],'dir'); % if the images directory exists then the dcm files should be in the correct format 

%  Create push button to analyze subject.
sp.again = uicontrol('Style','pushbutton',...
                    'Visible','on',...
                    'String','Refresh this GUI',...,
                    'Enable','on',...
                    'Value',0,'Position',[50,175,200,60],...
                    'callback',@first_gui_again);  

%  Create push button to convert dicom files (optional button press).
sp.convert_files = uicontrol('Style','pushbutton',...
                             'Visible','on',...
                             'String','Convert Files',...
                             'Enable','on',...
                             'Value',0,'Position',[50,735,200,60],...
                             'callback',{@convert_files});  
                         
if A == 7
    set(sp.convert_files,'Enable','off') % Disable the convert files button since it is unecessary 
    set(sp.convert_files,'String','Files Converted');
else
    errormessage = errordlg('Dicom files are not in the correct format');
end
                         
%  Descriptive text for the select stimulus dropdown menu                
sp.text(1) = uicontrol('Style','text',...
                        'units','normalized',...
                        'Position',[0.3,0.68,0.4,0.1],...
                        'String','Select stimulus'); 
                         
%  Create dropdown for breathhold study selection 
sp.stimulus_selection = uicontrol('Style','popupmenu',...
                            'Visible','on',...
                            'Enable','on',...
                            'String',{'','BH/HV/Motor','GA: CVR/Sensory','Respiratory Bellows','End tidal CO2'},...
                            'Position',[50,650,200,25]);   
                        
waitfor(sp.stimulus_selection,'Value');
set(sp.stimulus_selection,'Enable','off');

if sp.stimulus_selection.Value == 2 || sp.stimulus_selection.Value == 3
    if sp.stimulus_selection.Value == 2
        string1 = 'Enter number of breathholds: ';
        string2 = 'Enter number of hyperventilations: ';
        string3 = 'Enter number of motor studies: ';
    elseif sp.stimulus_selection.Value == 3
        string1 = 'Enter number of CVR studies: ';
        string2 = 'Enter number of sensory studies: ';
    end
               
    sp.specify_first = uicontrol('Style','text',...
                                        'units','normalized',...
                                        'Position',[0.05,0.64,0.635,0.05],...
                                        'String',string1);                                    

    sp.specify_second = uicontrol('Style','text',...
                            'units','normalized',...
                            'Position',[0.05,0.60,0.75,0.05],...
                            'String',string2);  
                                    
    sp.specify_first_textbox = uicontrol('Style','edit',...
                                            'Units','pixels',... 
                                            'Enable','on',...
                                            'Position',[245,605,35,20]); 

    sp.specify_second_textbox = uicontrol('Style','edit',...
                                    'Units','pixels',...
                                    'Enable','on',...
                                    'Position',[245,570,35,20]);                                  
    
    if sp.stimulus_selection.Value == 2                                
        sp.specify_third = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'Position',[0.05,0.56,0.68,0.05],...
                                    'String',string3);
                                
        sp.specify_third_textbox = uicontrol('Style','edit',...
                                          'Units','pixels',...
                                          'Enable','on',...
                                          'Position',[245,535,35,20]);
        waitfor(sp.specify_third_textbox,'String');
    else
        waitfor(sp.specify_second_textbox,'String');
    end

end

fileID = fopen([directories.textfilesdir '/stimsel.txt'],'w+'); 
format = '%d';
if sp.stimulus_selection.Value == 2 || sp.stimulus_selection.Value == 3

    i = 0;
    j = 0;
    k = 0;
    
    number_of_first = str2num(sp.specify_first_textbox.String);
    number_of_second = str2num(sp.specify_second_textbox.String);
    
    if sp.stimulus_selection.Value == 2
        first_string = 'BH';
        second_string = 'HV';
        fprintf(fileID,format,2);
    elseif sp.stimulus_selection.Value == 3
        first_string = 'CVR';
        second_string = 'SENS';
        fprintf(fileID,format,3);
    end
    third_string = 'MOT';

    C{1,1} = '';

    if number_of_first > 0
        for i = 1:number_of_first
            current_num = i;
            bh{i} = [first_string num2str(i)];
            C{1,1+current_num} = bh{i};
        end
    end

    if number_of_second > 0
        for j = 1:number_of_second
            current_num = j;
            if number_of_second == 1
                hv{j} = second_string;
            else
            hv{j} = [second_string num2str(j)];
            end
            C{1,1+i+current_num} = hv{j};
        end
    end

    if sp.stimulus_selection.Value == 2
        number_of_third = str2num(sp.specify_third_textbox.String);
        if number_of_third > 0
            for k = 1:number_of_third
                current_num = k;
                if number_of_third == 1
                    m{k} = third_string;
                else
                    m{k} = [third_string num2str(k)];
                end
                C{1,1+i+j+current_num} = m{k};
            end
            C{1+i+j+current_num+1} = 'MOTR';
            C{1+i+j+current_num+2} = 'MOTL';
        end
    elseif sp.stimulus_selection.Value == 3
        if number_of_second > 0
            C{1,i+j+2} = 'SENSR';
            C{1,i+j+3} = 'SENSL';
        end
    end
elseif sp.stimulus_selection.Value == 4
    C = {'','BELLOWS'};
    fprintf(fileID,format,4);
elseif sp.stimulus_selection.Value == 5
    C = {'','CO2'};
    fprintf(fileID,format,5);
end

fclose(fileID);

B = exist([directories.subject '/data/processed'],'dir');

if B == 7
    process_string = 'Subject Processed';
    enable_string = 'off';
    %  Create push button to process subject.
    sp.process = uicontrol('Style','pushbutton',...
                    'Visible','on',...
                    'String','Subject Processed',...,
                    'Enable','off',...
                    'Value',0,'Position',[50,455,200,60],...
                    'callback',{@processing_pipeline,subj,directories}); 
else
    %  Create push button to process subject.
    sp.process = uicontrol('Style','pushbutton',...
                    'Visible','on',...
                    'String','Process Subject',...,
                    'Enable','on',...
                    'Value',0,'Position',[50,455,200,60],...
                    'callback',{@processing_pipeline,subj,directories});
end

pause(2);

%  Current study dropdown description 
sp.userprompt = uicontrol('Style','text',...
                                'units','normalized',...
                                'Position',[0.02,0.4,0.4,0.08],...
                                'String','Current Study: ');

%  Create dropdown for breathhold study selection 
sp.study_selection = uicontrol('Style','popupmenu',...
                                    'Visible','on',...
                                    'Enable','on',...
                                    'String',C,...
                                    'Position',[125,425,150,10]);      
                        
waitfor(sp.study_selection,'Value');
temp_selection = sp.study_selection.String(sp.study_selection.Value);
subj.breathhold = temp_selection{1};
set(sp.study_selection,'Enable','off');

fileID = fopen([directories.textfilesdir '/breathhold_selection.txt'],'w+'); % Open the subject name text file in write mode
format = '%s';
fprintf(fileID,format,subj.breathhold);
fclose(fileID);

if strcmp(subj.breathhold,'BH1') == 1 || strcmp(subj.breathhold,'BH2') == 1
    use = 'BH';
elseif strcmp(subj.breathhold,'CVR1') == 1 || strcmp(subj.breathhold,'CVR2') == 1
    use = 'CVR';
else 
    use = subj.breathhold;
end
boxcar = [directories.matlabdir '/python/standard_' use '.1D'];

%  Load in the functional data that comes out of the processing pipeline,
%  map to anatomical space and then load that nii 

if strcmp(subj.breathhold,'MOTR') == 1 || strcmp(subj.breathhold,'MOTL') == 1
    subj.proc_rec_sel = 'MOT';
elseif strcmp(subj.breathhold,'SENSR') == 1 || strcmp(subj.breathhold,'SENSL') == 1 
    subj.proc_rec_sel = 'SENS';
else
    subj.proc_rec_sel = subj.breathhold;
end

fileID = fopen([directories.textfilesdir '/gen_selection.txt'],'w+'); % Open the subject name text file in write mode
format = '%s';
fprintf(fileID,format,subj.proc_rec_sel);
fclose(fileID);

functional_data = ['data/processed/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii'];
funct = load_nii([directories.subject '/' functional_data]);

%  Check if the standard stimfiles are the correct length, adjust them if
%  not, then copy them to metadata/stim
funct.time = funct.hdr.dime.dim(5);

copy_stim = [directories.subject '/' directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D'];

fileID = fopen(boxcar, 'rt');
assert(fileID ~= -1, 'Could not read: %s', boxcar);
x = onCleanup(@() fclose(fileID));
count = 0;
while ~feof(fileID)
    count = count + sum( fread( fileID, 16384, 'char' ) == char(10) );
end

fclose(fileID);
fileID = fopen(boxcar, 'r');
if(count > funct.time)
    for i = 1:abs(count - funct.time)
        fgetl(fileID);
    end
    buffer = fread(fileID,Inf);
    fclose(fileID);
    fileID = fopen(copy_stim,'w+');
    fwrite(fileID,buffer);
    fclose(fileID);  
elseif(count < funct.time)
    copyfile(boxcar,copy_stim,'f');
    fileID = fopen(copy_stim,'a');
    for i = 1:abs(funct.time - count)
        fprintf(fileID,format,0);
    end
    fclose(fileID); 
elseif(count == funct.time)
    copyfile(boxcar,copy_stim,'f');
end               
   
if sp.stimulus_selection.Value == 2 || sp.stimulus_selection.Value == 3
    bg = uibuttongroup('Visible','off',...
                       'Title','Boxcar Selection',...
                      'Position',[0.15 0.28 .7 .12],...
                      'SelectionChangedFcn',@bselection);

    %  Radiobutton for standard single staggered boxcar 
    sp.boxcar(1) = uicontrol(bg,'Style','radiobutton',...
                            'Visible','on',...
                            'Units','pixels',...
                            'String','Standard Boxcar',...
                            'HandleVisibility','off',...
                            'Position',[10,50,200,25],...
                            'Enable','on',...
                            'callback',{@standard_selected}); 

    %  Radiobutton for customized boxcar 
    sp.boxcar(2) = uicontrol(bg,'Style','radiobutton',...
                            'Visible','on',...
                            'Units','pixels',...
                            'String','Shift the Standard Boxcar',...
                            'HandleVisibility','off',...
                            'Position',[10,25,200,25],...
                            'Enable','on',...
                            'callback',{@adjust_boxcar,subj,directories,sp,funct}); 

    %  Radiobutton for customized boxcar 
    sp.boxcar(3) = uicontrol(bg,'Style','radiobutton',...
                            'Visible','on',...
                            'Units','pixels',...
                            'String','Create Customized Boxcar',...
                            'HandleVisibility','off',...
                            'Position',[10,0,200,25],...
                            'Enable','on',...
                            'callback',{@adjust_boxcar,subj,directories,sp,funct});   

    bg.Visible = 'on';
end


%  Create push button to look at subject data after processing and analysis
%  is complete 
sp.look = uicontrol('Style','pushbutton',...
                   'Visible','on',...
                   'String','Look at Subject Data',...
                   'Value',0,'Position',[50,25,200,60],...
                   'Enable','off',...
                   'callback',@run_again); % Call function to run the display GUI ('basic_UI_function.m')
                
% %  Checkbox for browse alternative stim method
% sp.alternative_methods = uicontrol('Style','checkbox',...
%                         'Visible','on',...
%                         'String','Browse alternative stim methods',...
%                         'HandleVisibility','on',...
%                         'Position',[50,145,250,25],...
%                         'Enable','off',...
%                         'callback',@dialoguebox); 
                   
%  Create push button to analyze subject.
sp.start = uicontrol('Style','pushbutton',...
                    'Visible','on',...
                    'String','Analyze Subject',...,
                    'Enable','on',...
                    'Value',0,'Position',[50,100,200,60],...
                    'callback',{@analyze_subject,subj,directories,sp});  
                
                
%  Get figure data 
guidata(sp.f,sp);                  