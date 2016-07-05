function myRadio(source,callbackdata,subj,dir_input)
% Function to determine radio button selection (standard boxcar OR customized).
%
% INPUTS 
%     subj - subject data (name, breathhold, date)
%     dir_input - directory where data should we stored
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 22, 2016
% Author - Hannah Sennik

%  Get data from 'Process and Analyze Subject' figure
handles = guidata(source);
%  Make sure only one radio button can be selected at a given time 
otherRadio = handles.boxcar(handles.boxcar ~= source);
set(otherRadio,'Value',0);

fileID = fopen(strcat(dir_input,'customize_boxcar.txt'),'w+'); % open customized boxcar textfile in write mode 
format = '%d\n';

if handles.boxcar(1).Value == 1
    fprintf(fileID,format,0); % If the standard boxcar was selected, write a 0 to the customized boxcar textfile 
    fclose(fileID);
    display('Use standard stim file');
    mkdir(dir_input,'flirt/standard_boxcar'); %  Make standard directories in the flirt folder (for transformations and pf stimfiles)
    mkdir(dir_input,'flirt/standard_boxcar_not_processed');
    figures_to_close = findall(0,'Type','figure'); %  Close all figures except for the main one ('Process and Analyze Subject')
    close(figures_to_close(2:end));
    set(handles.start,'Enable','on'); %  Allow user to start processing and analyzing subject
    set(handles.custom(1),'Value',0); %  Set the customized checkboxes to unchecked
    set(handles.custom(2),'Value',0);
    set(handles.custom(1),'Enable','off'); %  Disable the customized checkboxes 
    set(handles.custom(2),'Enable','off');
end

if handles.boxcar(2).Value == 1
    fprintf(fileID,format,1); % If customized boxcar was selected, write a 1 to the customized boxcar file 
    fclose(fileID);
    display('Use customized stim file');
    mkdir(dir_input,'flirt/customized_boxcar'); %  Make customized directories in the flirt folder 
    mkdir(dir_input,'flirt/customized_boxcar_not_processed');
    set(handles.custom(1),'Enable','on'); %  Enable the customized checkboxes to specify customization for BH1, BH2, and/or HV
    set(handles.custom(2),'Enable','on');
    set(handles.start,'Enable','off'); %  Do not allow the user to press the start button yet 
end
end
