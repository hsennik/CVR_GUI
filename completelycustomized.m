function completelycustomized(source,callbackdata,subj,directories,main_GUI,timeseries)
close(findobj('type','figure','name',['Create customized boxcar for: ' subj.breathhold]));
completely = 1;
create_boxcar(subj,directories,main_GUI,timeseries,completely);
end