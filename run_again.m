function run_again(source,callbackdata)
    handles = guidata(source);
    clear all;
    close all;
    run ('/data/hannahsennik/MATLAB/CVR_GUI/look_at_CVR_data.m')
end
