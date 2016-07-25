function closewindows(source,callbackdata,subj)
close(findobj('type','figure','name',['Axial Subject Data: ' subj.breathhold]));
end