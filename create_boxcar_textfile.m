function create_boxcar_textfile(source,callbackdata,subj,dir_input,breath,sp,same_boxcar)
% Function that creates the boxcar stimfile from user entered data
% 
% INPUTS 
%     subj - subject data (name, breathhold, date)
%     dir_input - directory where data should we stored
%     breath - determines which breathhold the boxcar is for 
%     sp - main GUI data 
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 22, 2016
% Author - Hannah Sennik

%  Get data from the 'Create customized BH boxcar' figure
handles = guidata(source);

%  Set subj.breathhold based on variable HV from create_boxcar.m or
%  create_HVboxcar.m

if breath == 1
    subj.breathhold = 'BH1';
elseif breath == 2
    subj.breathhold = 'BH2';
elseif breath == 3
    subj.breathhold = 'HV';
end

customized_stimfile = strcat(dir_input,'metadata/stim/bhonset',subj.name,'_',subj.breathhold,'_customized.1D'); % Create the textfile for the stimfile 
fileID = fopen(customized_stimfile,'w+');
format = '%d\n';
display('Customized stim file generated');

% Convert all the data entry strings in to doubles and divide time blocks
% by two to match with TR 
number_blocks= str2double(handles.number_blocks.String); 

start_delay = str2double(handles.start_delay.String);
halved_start_delay = start_delay/2.0;
halved_start_delay_for_end = start_delay/2.0;

break_duration = str2double(handles.break_duration.String);
halved_break_duration = floor(break_duration/2.0);

break_after_block = str2double(handles.break_after_block.String);

breathhold_duration = str2double(handles.breathhold_duration.String);
halved_breathhold_duration = breathhold_duration/2.0;

normal_breathing_duration = str2double(handles.normal_breathing_duration.String);
halved_normal_breathing_duration = normal_breathing_duration/2.0;

%  Check the value of variables          
display(number_blocks);
display(halved_start_delay);
display(halved_start_delay_for_end);
display(halved_break_duration);
display(break_after_block);
display(halved_breathhold_duration);
display(halved_normal_breathing_duration);

standard_start = 3; % half of 6 
standard_end = 10; % half of 20
% Print 0 to file where the subject is breathing normally, and 185
% where the subject is holding their breath 
for h = 1:halved_start_delay+standard_start 
    fprintf(fileID,format,0);
end

for i = 1:number_blocks %  Create the specified number of blocks 
    if i == break_after_block
        halved_normal_breathing_duration = halved_normal_breathing_duration + halved_break_duration; %  add the break duration to break_after_block
    end
    if i == break_after_block + 1
        halved_normal_breathing_duration = halved_normal_breathing_duration - halved_break_duration; %  remove the break duration for all block after break_after_block
    end
    for j = 1:halved_breathhold_duration
        fprintf(fileID,format,100);
    end
    for k = 1:halved_normal_breathing_duration
        fprintf(fileID,format,0);
    end
end

for l = 1:standard_end-halved_start_delay_for_end
    fprintf(fileID,format,0);
end

fclose(fileID);

if breath == 1 || breath == 2
    % Check that all of the times add up to 370 seconds
    % Check that blocks add up to 60 seconds 
    total_block_time = normal_breathing_duration + breathhold_duration;
    total_time = (number_blocks*(halved_breathhold_duration + halved_normal_breathing_duration) + halved_break_duration + halved_start_delay + standard_start + standard_end - halved_start_delay_for_end);
    display(total_time);
    if total_block_time ~= 60
        errormessage = errordlg('Normal breathing duration and breathhold duration should add up to 60 seconds');
        set(handles.viewboxcar,'Enable','off');
    elseif total_time ~= 178
        errormessage = errordlg('The total time is not correct, please re-enter values.');
        set(handles.viewboxcar,'Enable','off');
    else
        set(handles.viewboxcar,'Enable','on'); % Enable viewboxcar pushbutton
        set(sp.start,'Enable','on');
    end

end 

if breath == 3
    set(handles.viewboxcar,'Enable','on'); % Enable viewboxcar pushbutton
    set(sp.start,'Enable','on');
end
        

if same_boxcar == 1 %  if user selected for BH1 and BH2 boxcars to be the same 
    subj.breathhold = 'BH2';
    copyfile(customized_stimfile,strcat(dir_input,'metadata/stim/bhonset',subj.name,'_',subj.breathhold,'_customized.1D'),'f');
%     set(handles.HVboxcar,'Enable','on');
    display('boxcar copied for BH2');
end

end
