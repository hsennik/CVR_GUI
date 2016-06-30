function create_boxcar_textfile(source,callbackdata,subj,dir_input,HV)

handles = guidata(source);
if HV == 1
    subj.breathhold = 'HV';
else
    subj.breathhold = 'BH1';
end
%  Create while loop that allows user to keep doing this until they press
%  USE BOXCAR BUTTON 
customized_stimfile = strcat(dir_input,'metadata/stim/bhonset',subj.name,'_',subj.breathhold,'_customized.1D'); % Create the textfile for the stimfile 
fileID = fopen(customized_stimfile,'w+');
format = '%d\n';
display('customized stim file created');

number_blocks= str2double(handles.number_blocks.String); % Convert all the data entry strings in to doubles
display(number_blocks);
start_delay = str2double(handles.start_delay.String);
start_delay = floor(start_delay/2.0);
display(start_delay);
break_duration = str2double(handles.break_duration.String);
break_duration = floor(break_duration/2.0);
display(break_duration);
break_after_block = str2double(handles.break_after_block.String);
display(break_after_block);
breathhold_duration = str2double(handles.breathhold_duration.String);
breathhold_duration = floor(breathhold_duration/2.0);
display(breathhold_duration);
normal_breathing_duration = str2double(handles.normal_breathing_duration.String);
normal_breathing_duration = floor(normal_breathing_duration/2.0);
display(normal_breathing_duration);
         
% Print 0 to file where the subject is breathing normally, and 185
% where the subject is holding their breath 
if start_delay ~= 0
    for h = 1:start_delay  
        fprintf(fileID,format,0);
    end
end

for i = 1:number_blocks
    if i == break_after_block
        normal_breathing_duration = normal_breathing_duration + break_duration;
    end
    if i == break_after_block + 1
        normal_breathing_duration = normal_breathing_duration - break_duration;
    end
    for j = 1:breathhold_duration
        fprintf(fileID,format,185);
    end
    for k = 1:normal_breathing_duration
        fprintf(fileID,format,0);
    end
end

fclose(fileID);
if strcmp(subj.breathhold,'BH1') == 1
    subj.breathhold = 'BH2';
    copyfile(customized_stimfile,strcat(dir_input,'metadata/stim/bhonset',subj.name,'_',subj.breathhold,'_customized.1D'),'f');
    set(handles.HVboxcar,'Enable','on');
end
set(handles.viewboxcar,'Enable','on'); % Enable viewboxcar pushbutton

end
