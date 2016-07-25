function adjust_boxcar(source,callbackdata,subj,directories,main_GUI)
handles = guidata(source);
temp_selection = main_GUI.study_selection.String(main_GUI.study_selection.Value);
subj.breathhold = temp_selection{1};
show_axial_figure(subj,directories,handles);
end