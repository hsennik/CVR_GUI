function myRadio(source,callbackdata,subj,dir_input,main_GUI)
% Function to determine radio button selection (standard boxcar OR customized).
%
% INPUTS 
%     subj - subject data (name, breathhold, date)
%     dir_input - directory where data should we stored
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 22, 2016
% Author - Hannah Sennik

% %  Get data from 'Process and Analyze Subject' figure
% handles = guidata(source);

%  Make sure only one radio button can be selected at a given time 
otherRadio = main_GUI.boxcar(main_GUI.boxcar ~= source);
set(otherRadio,'Value',0);

fileID = fopen([directories.subject '/' directories.textfilesdir '/standard_shifted_customized.txt'],'w+'); % open customized boxcar textfile in write mode 
format = '%d\n';

if handles.boxcar(1).Value == 1
    display('Use standard boxcar');
    fprintf(fileID,format,0); % If the standard boxcar was selected, write a 0 to the file
    figures_to_close = findall(0,'Type','figure'); %  Close all figures except for the main one ('Process and Analyze Subject')
    close(figures_to_close(2:end));
%     set(handles.start,'Enable','on'); %  Allow user to start processing and analyzing subject
% else
%     set(handles.start,'Enable','off');

elseif handles.boxcar(2).Value == 1
    display('Shift standard boxcar');
    fprintf(fileID,format,1); % If the shifted boxcar was selected, write a 1 to the file 
%     set(handles.start,'Enable','off'); %  Do not allow the user to press the start button yet 
elseif handles.boxcar(3).Value == 1
    display('Create customized boxcar');
    fprintf(fileID,format,2);
end
fclose(fileID);
end
