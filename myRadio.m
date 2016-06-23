function myRadio(source,callbackdata,subj,dir_input)
    handles = guidata(source);
    otherRadio = handles.boxcar(handles.boxcar ~= source);
    set(otherRadio,'Value',0);
    
    fileID = fopen(strcat(dir_input,'customize_boxcar.txt'),'w+'); % open text file to determine whether or not to use customized boxcar 
    format = '%d\n';
    
    if handles.boxcar(1).Value == 1
        fprintf(fileID,format,2); % If the standard boxcar was selected, write a 2 to the file 
        fclose(fileID);
        display('use standard stim file');
        mkdir(dir_input,'flirt/standard_boxcar');
        mkdir(dir_input,'flirt/standard_boxcar_not_processed');
%         set(handles.start,'Enable','on');
    end
    
    if handles.boxcar(2).Value == 1
        fprintf(fileID,format,1); % If customized boxcar was selected, write a 1 to the file 
        fclose(fileID);
        display('use customized stim file');
        mkdir(dir_input,'flirt/customized_boxcar');
        mkdir(dir_input,'flirt/customized_boxcar_not_processed');
        create_boxcar(subj,dir_input);
    end
end
