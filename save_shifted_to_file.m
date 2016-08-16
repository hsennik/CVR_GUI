function save_shifted_to_file(source,callbackdata,subj,gui,directories,funct,main_GUI)
% Function to save the shifted boxcar to a .1D texfile 
% 
% INPUTS 
%     subj - subject data 
%     gui - guidata 
%     directories - all of the necessary directory info
%     funct - functional data
%     main_GUI - 
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 5, 2016
% Author - Hannah Sennik

shift_value = get(gui.shift_boxcar,'Value'); % get the slider value 

display(shift_value);
global number_shift_files;
number_shift_files = '';

% Close all windows except for the main interface
close(findobj('type','figure','name',['Timeseries: ' subj.breathhold]));
close(findobj('type','figure','name',['Axial Subject Data: ' subj.breathhold]));
close(findobj('type','figure','name',['Entire Brain Average Timeseries: ' subj.breathhold]));

set(main_GUI.start,'Enable','on'); % Enable the analyze subject button 

shift_value = ceil(shift_value);

fileID = fopen([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D'],'r'); % open the standard boxcar
format = '%d\n';
if sign(shift_value) == -1 % if the boxcar was shifted to the left 
    for i = 1:-shift_value % remove lines from the beginning of the boxcar equal to the shift value
        fgetl(fileID);
    end
    buffer = fread(fileID,Inf); % copy the remaining boxcar into buffer 
    fclose(fileID);
    
%     % SOMETHING TO ADD IN FOR LATER - having several shifted files
%     if exist([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_shifted' number '.1D'],'file') == 2
%         number_shift_files = 2;
%     else
%         number_shift_files = '';
%     end
        
    fileID = fopen([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_shifted' number_shift_files '.1D'],'w+'); % create a shifted file 
    fwrite(fileID,buffer); % write buffer to shifted boxcar file in the stim directory 
    for i = 1:-shift_value
        fprintf(fileID,format,0); % print zeroes at the end of the file for number of lines equal to the shift value 
    end
    fclose(fileID);
elseif sign(shift_value) == 1 % if the boxcar was shifted to the right 
    fclose(fileID);
    fileID = fopen([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_shifted.1D'],'w+');
    format = '%f\n';
    for i = 1:shift_value
        fprintf(fileID,format,0); % print zeroes at the beginning of the file for number of lines equal to the shift value 
    end
    fclose(fileID);

    fileID = fopen([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D'],'r');
    buffer = fscanf(fileID,format,funct.time - shift_value); % read the lines from the standard boxcar except the number of lines at the end equal to the shift value, save to buffer
    fclose(fileID);
    fileID = fopen([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_shifted.1D'],'at');
    fprintf(fileID,format,buffer); % print buffer to the shifted boxcar
    fclose(fileID);
elseif sign(shift_value) == 0 % if the boxcar wasn't shifted, copy the standard boxcar directly to the shifted file 
    copyfile([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D'],[directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_shifted.1D']);
end

h = msgbox('Shifted boxcar saved');

end
