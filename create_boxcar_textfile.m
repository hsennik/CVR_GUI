function create_boxcar_textfile(source,callbackdata,subj,directories,main_GUI)
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

customized_stimfile = [directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_customized.1D']; % Create the textfile for the stimfile 
fileID = fopen(customized_stimfile,'w+');
format = '%d\n';
display('Customized stim file generated');

%  Load in the functional data that comes out of the processing pipeline,
%  map to anatomical space and then load that nii 
functional_data = ['data/processed/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii'];
funct = load_nii([directories.subject '/' functional_data]);

%  Check if the standard stimfiles are the correct length, adjust them if
%  not, then copy them to metadata/stim
funct.time = funct.hdr.dime.dim(5);
real_time = funct.time * 2;

% Convert all the data entry strings in to doubles and divide time blocks
% by two to match with TR 
number_blocks= str2double(handles.number_blocks.String); 

start_delay = str2double(handles.start_delay.String);
halved_start_delay = ceil(start_delay/2.0);

break_duration = str2double(handles.break_duration.String);
halved_break_duration = floor(break_duration/2.0);

break_after_block = str2double(handles.break_after_block.String);

breathhold_duration = str2double(handles.breathhold_duration.String);
halved_breathhold_duration = floor(breathhold_duration/2.0);

normal_breathing_duration = str2double(handles.normal_breathing_duration.String);
halved_normal_breathing_duration = ceil(normal_breathing_duration/2.0);

%  Check the value of variables          
display(number_blocks);
display(halved_start_delay);
display(halved_break_duration);
display(break_after_block);
display(halved_breathhold_duration);
display(halved_normal_breathing_duration);

% Print 0 to file where the subject is breathing normally, and 185
% where the subject is holding their breath 
for h = 1:halved_start_delay
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
        fprintf(fileID,format,200);
    end
    for k = 1:halved_normal_breathing_duration
        fprintf(fileID,format,0);
    end
end

lines_filled = (i*j) + (i*k) + h + halved_break_duration;

for l = 1:funct.time - lines_filled
    fprintf(fileID,format,0);
end

fclose(fileID);

total_time = lines_filled + l;
display(total_time);
display(funct.time);


% Check that the total time is not greater than the functional time 
if total_time > funct.time
    errormessage = errordlg('The total time exceeds that of the functional data, please re-enter values.');
    set(handles.viewboxcar,'Enable','off');
elseif total_time == funct.time
    display('timing is correct');
    set(handles.viewboxcar,'Enable','on'); % Enable viewboxcar pushbutton
end     

end
