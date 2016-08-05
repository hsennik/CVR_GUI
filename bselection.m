function bselection(source,callbackdata,directories)
% Print the boxcar selection to a textfile to be read by the pipeline and
% view data interface
% 
% INPUTS 
%     directories - all of the directories for the subject
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 22, 2016
% Author - Hannah Sennik

display(['Previous: ' callbackdata.OldValue.String]);
display(['Current: ' callbackdata.NewValue.String]);
display('------------------');

fileID = fopen([directories.textfilesdir '/standard_shifted_customized.txt'],'w+');
format = '%d\n';

if strcmp(source.SelectedObject.String,'Standard Boxcar') == 1 % standard boxcar was selected for breathhold
    fprintf(fileID,format,1);
elseif strcmp(source.SelectedObject.String,'Shift the Standard Boxcar') == 1 % shifted boxcar was selected for breathhold 
    fprintf(fileID,format,2);
elseif strcmp(source.SelectedObject.String,'Create Customized Boxcar') == 1% customized boxcar was selected for breathhold
    fprintf(fileID,format,3);
end

fclose(fileID);

end
