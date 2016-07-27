function process_pushed(source,callbackdata,subj,directories)
main_GUI = guidata(source);
processing_pipeline(subj,directories,main_GUI);
end