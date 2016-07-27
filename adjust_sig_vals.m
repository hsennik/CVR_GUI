function adjust_sig_vals(source,callbackdata)
global sigmin;
global sigmax;
handles = guidata(source);
sigmin = str2num(handles.sigmin_val.String);
sigmax = str2num(handles.sigmax_val.String);
end