function adjust_HVboxcar(source,callbackdata,subject,directory,main_GUI)
checkbox_click = get(source, 'Value');
if checkbox_click == 1
    bhselection = 'HV';
    show_axial_figure(subject,directory,main_GUI,bhselection);
else
    close(findobj('type','figure','name','Axial Subject Data: HV'));
    close(findobj('type','figure','name','Timeseries: HV'));
end
end