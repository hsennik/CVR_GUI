function processing_pipeline(source,callbackdata,subj,directories)
% Function to run the subject through the processing pipeline, and show
% more objects on the GUI 
% 
% INPUTS 
%     subj - subject data (name,date,breathhold)
%     directories - all of the directories for the subject
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 13, 2016
% Author - Hannah Sennik

%  Get data from 'Process and Analyze Subject' figure
main_GUI = guidata(source);

mkdir([directories.subject '/' directories.textfilesdir]);

%  Make REDCap directories where a summary of processing and analysis parameters used will be
%  saved to a text file
mkdir([directories.subject '/' directories.REDCapdir]); % make the REDCap file directory in subject folder
mkdir([directories.subject '/' directories.REDCapdir '/all']); % make a folder inside REDCap directory to store all of the files 

fileID = fopen([directories.subject '/' directories.textfilesdir '/mat2py.txt'],'w+');
format = '%d\n';
fprintf(fileID,format,1,1); % Write the filtering and stimulus values in the file (they will be used in process_fmri and analyze_fmri)
fclose(fileID);

fileID = fopen([directories.subject '/' directories.textfilesdir '/processing.txt'],'w+');
format = '%d\n';
fprintf(fileID,format,1); % do processing 
fclose(fileID);

if main_GUI.stimulus_selection.Value == 2 || main_GUI.stimulus_selection.Value == 3

    number_of_first = str2num(main_GUI.specify_first_textbox.String);
    number_of_second = str2num(main_GUI.specify_second_textbox.String);
    
    if main_GUI.stimulus_selection.Value == 2
        first_string = 'BH';
        second_string = 'HV';
    elseif main_GUI.stimulus_selection.Value == 3
        first_string = 'CVR';
        second_string = 'SENS BOTH HANDS';
    end

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

    if main_GUI.stimulus_selection.Value == 2
        number_of_third = str2num(main_GUI.specify_third_textbox.String);
        if number_of_third > 0
            for k = 1:number_of_third
                current_num = k;
                if number_of_third == 1
                    m{k} = 'MOT';
                else
                    m{k} = ['MOT' num2str(k)];
                end
                C{1,1+i+j+current_num} = m{k};
            end
        end
    elseif main_GUI.stimulus_selection.Value == 3
        C{1,i+j+2} = 'SENS RIGHT';
        C{1,i+j+3} = 'SENS LEFT';
    end
end

%  Tell the user to wait for the subject to be processed
main_GUI.userprompt = uicontrol('Style','text',...
                    'units','normalized',...
                    'Position',[0.10,0.4,0.8,0.08],...
                    'String','Please wait while the subject is being processed');

pause(2);
% 
% %  Run the processing pipeline with all steps
% command = ['python ' directories.matlabdir '/python/process_fmri.py ' directories.metadata '/S_CVR_' subj.name '.txt ' directories.metadata '/P_CVR_' subj.name '.txt --clean'];
% status = system(command);
% 
% fileID = fopen([directories.subject '/' directories.textfilesdir '/processing.txt'],'w+');
% format = '%d\n';
% fprintf(fileID,format,0); % no processing 
% fclose(fileID);
% 
% %  Run the processing pipeline and skip steps 
% command = ['python ' directories.matlabdir '/python/process_fmri.py ' directories.metadata '/S_CVR_' subj.name '.txt ' directories.metadata '/P_CVR_' subj.name '.txt --clean'];
% status = system(command);

%  Tell the user that processing is done
main_GUI.userprompt = uicontrol('Style','text',...
                    'units','normalized',...
                    'Position',[0.10,0.4,0.8,0.08],...
                    'String','Subject Processed');

pause(2); % pause for two seconds

%  Current study dropdown description 
main_GUI.userprompt = uicontrol('Style','text',...
                                'units','normalized',...
                                'Position',[0.02,0.4,0.4,0.08],...
                                'String','Current Study: ');

%  Create dropdown for breathhold study selection 
main_GUI.study_selection = uicontrol('Style','popupmenu',...
                                    'Visible','on',...
                                    'Enable','on',...
                                    'String',C,...
                                    'Position',[125,425,150,10]);      
                        
waitfor(main_GUI.study_selection,'Value');
temp_selection = main_GUI.study_selection.String(main_GUI.study_selection.Value);
subj.breathhold = temp_selection{1};

%  Load in the functional data that comes out of the processing pipeline,
%  map to anatomical space and then load that nii 
functional_data = ['data/processed/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii'];
funct = load_nii([directories.subject '/' functional_data]);

%  Check if the standard stimfiles are the correct length, adjust them if
%  not, then copy them to metadata/stim
funct.time = funct.hdr.dime.dim(5);

if strcmp(subj.breathhold,'HV') == 1
    boxcar = [directories.matlabdir '/python/standard_HV.1D'];
else
    boxcar = [directories.matlabdir '/python/standard_boxcar.1D'];
end

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
                        
bg = uibuttongroup('Visible','off',...
                   'Title','Boxcar Selection',...
                  'Position',[0.15 0.28 .7 .12],...
                  'SelectionChangedFcn',@bselection);
                                    
%  Radiobutton for standard single staggered boxcar 
main_GUI.boxcar(1) = uicontrol(bg,'Style','radiobutton',...
                        'Visible','on',...
                        'Units','pixels',...
                        'String','Standard Single Staggered',...
                        'HandleVisibility','off',...
                        'Position',[10,50,200,25],...
                        'Enable','on',...
                        'callback',{@standard_selected}); 
                    
%  Radiobutton for customized boxcar 
main_GUI.boxcar(2) = uicontrol(bg,'Style','radiobutton',...
                        'Visible','on',...
                        'Units','pixels',...
                        'String','Shift the Standard Boxcar',...
                        'HandleVisibility','off',...
                        'Position',[10,25,200,25],...
                        'Enable','on',...
                        'callback',{@adjust_boxcar,subj,directories,main_GUI}); 
                        
%  Radiobutton for customized boxcar 
main_GUI.boxcar(3) = uicontrol(bg,'Style','radiobutton',...
                        'Visible','on',...
                        'Units','pixels',...
                        'String','Create Customized Boxcar',...
                        'HandleVisibility','off',...
                        'Position',[10,0,200,25],...
                        'Enable','on',...
                        'callback',{@adjust_boxcar,subj,directories,main_GUI});   
                    
bg.Visible = 'on';

guidata(main_GUI.f,main_GUI);

%  Create push button to look at subject data after processing and analysis
%  is complete 
main_GUI.look = uicontrol('Style','pushbutton',...
                   'Visible','on',...
                   'String','Look at Subject Data',...
                   'Value',0,'Position',[50,75,200,60],...
                   'Enable','off',...
                   'callback',@run_again); % Call function to run the display GUI ('basic_UI_function.m')
                
% %  Checkbox for browse alternative stim method
% main_GUI.alternative_methods = uicontrol('Style','checkbox',...
%                         'Visible','on',...
%                         'String','Browse alternative stim methods',...
%                         'HandleVisibility','on',...
%                         'Position',[50,145,250,25],...
%                         'Enable','off',...
%                         'callback',@dialoguebox); 
                   
%  Create push button to analyze subject.
main_GUI.start = uicontrol('Style','pushbutton',...
                    'Visible','on',...
                    'String','Analyze Subject',...,
                    'Enable','on',...
                    'Value',0,'Position',[50,150,200,60],...
                    'callback',{@analyze_subject,subj,directories,main_GUI});  
                
end