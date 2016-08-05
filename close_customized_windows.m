function close_customized_windows(source,callbackdata,subj,main_GUI)
close(findobj('type','figure','name',['Axial Subject Data: ' subj.breathhold]));
close(findobj('type','figure','name',['Timeseries vs. Customized Boxcar: ' subj.breathhold]));
close(findobj('type','figure','name',['Create customized boxcar for: ' subj.breathhold]));
close(findobj('type','figure','name',['Timeseries: ' subj.breathhold]));
close(findobj('type','figure','name',['Entire Brain Average Timeseries: ' subj.breathhold]));
set(main_GUI.start,'Enable','on');
end
