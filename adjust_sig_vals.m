function adjust_sig_vals(source,callbackdata,directories)
global sigmin;
global sigmax;
handles = guidata(source);
sigmin = str2num(handles.sigmin_val.String);
sigmax = str2num(handles.sigmax_val.String);

fileID = fopen([directories.textfilesdir '/sigvals.txt'],'w+'); 
format = '%d\n';
fprintf(fileID,format,sigmin);
fprintf(fileID,format,sigmax);
fclose(fileID);
end