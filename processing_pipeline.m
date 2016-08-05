function processing_pipeline(source,callbackdata,subj,directories)
% Function to run the subject through the processing pipeline
% 
% INPUTS 
%     subj - subject data (name,date,breathhold)
%     directories - all of the directories for the subject
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 13, 2016
% Author - Hannah Sennik
% 

%  Get data from 'Process and Analyze Subject' figure
main_GUI = guidata(source);

%  Make REDCap directories where a summary of processing and analysis parameters used will be
%  saved to a text file
mkdir([directories.subject '/' directories.REDCapdir],'all'); % make a folder inside REDCap directory to store all of the files 

%  Open the processing textfile to determine whether to skip steps in
%  pipeline or run all steps
fileID = fopen([directories.subject '/' directories.textfilesdir '/processing.txt'],'w+');
format = '%d\n';
fprintf(fileID,format,1); % Write 1 to file means do processing 
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
fprintf(fileID,format,0); % Write zero to file means no processing/skip steps 
fclose(fileID);

%  Run the processing pipeline and skip steps 
command = ['python ' directories.matlabdir '/python/process_fmri.py ' directories.metadata '/S_CVR_' subj.name '.txt ' directories.metadata '/P_CVR_' subj.name '.txt --clean'];
status = system(command);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CREATING THE TISSUE SEGMENTATION MASKS USING FSL FAST - THIS STEP IS
%  REALLY SLOW - give the user the option to generate these? 
% tissue_segmentation(subj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MAPPING TO STANDARD SPACE 
display('************** BRAIN REGIONAL MASKS **************');

mkdir([directories.flirtdir '/standard_to_anat']);

%  Map the standard MNI to subjects anatomical space - need the
%  transformation matrix for 3D predetermined ROI's - this may already be
%  saved in recon ..?
command = ['flirt -in ' directories.matlabdir '/standard_files/avg152T1_brain.nii.gz -ref data/recon/' subj.name '/' subj.name '_anat_brain.nii -out ' directories.flirtdir '/standard_to_anat/standard_brain_to_anat.nii -omat ' directories.flirtdir '/standard_to_anat/standard_brain_to_anat.mat -dof 12'];
status = system(command);

%  Map each of the regions to anatomical space here as well and save to
%  flirt/standard_to_anat
%  CEREBELLUM
command = ['flirt -in ' directories.matlabdir '/standard_files/Cerebellum-MNIflirt-maxprob-thr50-2mm.nii.gz -ref data/recon/' subj.name '/' subj.name '_anat_brain.nii -out ' directories.flirtdir '/standard_to_anat/cerebellum_to_anat.nii -init ' directories.flirtdir '/standard_to_anat/standard_brain_to_anat.mat -applyxfm'];
status = system(command);

display('************** ALL DONE **************');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Tell the user to wait for the subject to be processed
main_GUI.userprompt = uicontrol('Style','text',...
                    'units','normalized',...
                    'Position',[0.10,0.4,0.8,0.08],...
                    'String','Subject processed');

set(source,'Enable','off');
set(source,'String','Subject Processed');
                
end


