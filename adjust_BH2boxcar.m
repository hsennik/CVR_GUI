function adjust_BH2boxcar(source,callbackdata,subject,directory,main_GUI)
checkbox_click = get(source, 'Value');
if checkbox_click == 1
    bhselection = 'BH2';
    show_axial_figure(subject,directory,main_GUI,bhselection);
else
    close(findobj('type','figure','name','Axial Subject Data: BH2'));
    close(findobj('type','figure','name','Timeseries: BH2'));
end
end