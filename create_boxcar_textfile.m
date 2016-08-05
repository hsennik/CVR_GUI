function create_boxcar_textfile(source,callbackdata,subj,directories,main_GUI,completely)
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

close(findobj('type','figure','name',['Timeseries: ' subj.breathhold]));

customized_stimfile = [directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_customized.1D']; % Create the textfile for the stimfile 

waver_customize = [directories.metadata '/stim/waver_customize']; % Create the textfile for the stimfile 
fileID = fopen(waver_customize,'w+');
format = '%s\n';

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

fprintf(fileID,format,['waver -GAM -dt 2 -numout ' num2str(funct.time) ' -inline \']);
if start_delay ~= 0
    fprintf(fileID,format,[num2str(halved_start_delay) '@0 \']);
end

if completely == 0
    break_duration = str2double(handles.break_duration.String);
    halved_break_duration = floor(break_duration/2.0);

    break_after_block = str2double(handles.break_after_block.String);

    breathhold_duration = str2double(handles.breathhold_duration.String);
    halved_breathhold_duration = ceil(breathhold_duration/2.0);

    normal_breathing_duration = str2double(handles.normal_breathing_duration.String);
    halved_normal_breathing_duration = floor(normal_breathing_duration/2.0);

    %  Check the value of variables          
    display(number_blocks);
    display(halved_start_delay);
    display(halved_break_duration);
    display(break_after_block);
    display(halved_breathhold_duration);
    display(halved_normal_breathing_duration);

    for x = 1:number_blocks
        if x == break_after_block
            halved_normal_breathing_duration = halved_normal_breathing_duration + halved_break_duration;
        end
        if x == break_after_block + 1
            halved_normal_breathing_duration = halved_normal_breathing_duration - halved_break_duration;
        end
        if halved_breathhold_duration ~= 0
            fprintf(fileID,format,[num2str(halved_breathhold_duration) '@1 \']);
        end
        if halved_normal_breathing_duration ~= 0
            fprintf(fileID,format,[num2str(halved_normal_breathing_duration) '@0 \']);
        end
    end
    
    lines_filled = number_blocks*halved_breathhold_duration + number_blocks*halved_normal_breathing_duration + halved_break_duration + halved_start_delay;
    time_leftover = funct.time - lines_filled;
    
    if breathhold_duration + normal_breathing_duration ~=60
        errormessage = errordlg('Breathhold duration and normal breathing duration should add up to 60 seconds. Please re-enter values.');
        set(handles.viewboxcar,'Enable','off');
        sixty_sec_indicator = 1;
    else
        sixty_sec_indicator = 0;
    end

else
    result = 0;
    sixty_sec_indicator = 0;
    for g = 1:number_blocks   
        breath_block(g) = str2double(handles.breathhold(g).String);
        halved_breath_block(g) = ceil(breath_block(g)/2.0);
        
        normal_block(g) = str2double(handles.normal(g).String);
        halved_normal_block(g) = floor(normal_block(g)/2.0);
        
        if halved_breath_block(g) ~= 0
            fprintf(fileID,format,[num2str(halved_breath_block(g)) '@1 \']);
        end 
        if halved_normal_block(g) ~=0
            fprintf(fileID,format,[num2str(halved_normal_block(g)) '@0 \']);
        end
        
        result = result + halved_breath_block(g) + halved_normal_block(g);
    end

    lines_filled = result + halved_start_delay;
    time_leftover = funct.time - lines_filled;
    
end
 
    if sign(time_leftover) == -1
        errormessage = errordlg('The total time exceeds that of the functional data, please re-enter values.');
        set(handles.viewboxcar,'Enable','off');
    elseif sixty_sec_indicator == 0 
        display('timing is correct');
        set(handles.viewboxcar,'Enable','on');
        if time_leftover ~= 0
            fprintf(fileID,format,[num2str(time_leftover) '@0 > ' customized_stimfile]);
        end    
    end
    
    command = ['tcsh ' waver_customize];
    system(command);
    
    fclose(fileID);

    total_time = lines_filled + time_leftover;
    display(total_time);
    display(funct.time);

end
