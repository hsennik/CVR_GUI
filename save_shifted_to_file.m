function save_shifted_to_file(source,callbackdata,subj,gui,directories,funct)

shift_value = get(gui.shift_boxcar,'Value');

display(shift_value);

close(findobj('type','figure','name',['Timeseries: ' subj.breathhold]));
close(findobj('type','figure','name',['Axial Subject Data: ' subj.breathhold]));

shift_value = ceil(shift_value);

fileID = fopen([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D'],'r'); % open the standard boxcar
format = '%d\n';
if sign(shift_value) == -1
    for i = 1:-shift_value
        fgetl(fileID);
    end
    buffer = fread(fileID,Inf);
    fclose(fileID);
    fileID = fopen([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_shifted.1D'],'w+');
    fwrite(fileID,buffer);
    for i = 1:-shift_value
        fprintf(fileID,format,0);
    end
    fclose(fileID);
elseif sign(shift_value) == 1
    fclose(fileID);
    fileID = fopen([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_shifted.1D'],'w+');
    format = '%d\n';
    for i = 1:shift_value
        fprintf(fileID,format,0);
    end
    fclose(fileID);

    fileID = fopen([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D'],'r');
    buffer = fscanf(fileID,format,funct.time-shift_value);
    fclose(fileID);
    fileID = fopen([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_shifted.1D'],'at');
    fprintf(fileID,format,buffer); 
    fclose(fileID);
elseif sign(shift_value) == 0
    copyfile([directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D'],[directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_shifted.1D']);
end
end
