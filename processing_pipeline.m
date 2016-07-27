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
% 
% %  Get data from 'Process and Analyze Subject' figure

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

%  Tell the user to wait for the subject to be processed
main_GUI.userprompt = uicontrol('Style','text',...
                    'units','normalized',...
                    'Position',[0.10,0.4,0.8,0.08],...
                    'String','Please wait while the subject is being processed');

pause(2);

%  Run the processing pipeline with all steps
command = ['python ' directories.matlabdir '/python/process_fmri.py ' directories.metadata '/S_CVR_' subj.name '.txt ' directories.metadata '/P_CVR_' subj.name '.txt --clean'];
status = system(command);

fileID = fopen([directories.subject '/' directories.textfilesdir '/processing.txt'],'w+');
format = '%d\n';
fprintf(fileID,format,0); % no processing 
fclose(fileID);

%  Run the processing pipeline and skip steps 
command = ['python ' directories.matlabdir '/python/process_fmri.py ' directories.metadata '/S_CVR_' subj.name '.txt ' directories.metadata '/P_CVR_' subj.name '.txt --clean'];
status = system(command);

%  Tell the user that processing is done
main_GUI.userprompt = uicontrol('Style','text',...
                    'units','normalized',...    
                    'Position',[0.10,0.4,0.8,0.08],...
                    'String','Subject Processed');

end


