function adjust_boxcar(source,callbackdata,subj,directories,funct)
% Function to call function to show axial slices in figure to draw ROI and
% extract timeseries 
% 
% INPUTS 
%     subj - subject data (name,date,breathhold)
%     directories - all of the directories for the subject
%     funct - functional subject data  (need the time)
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 22, 2016
% Author - Hannah Sennik

figures_to_close = findall(0,'Type','figure'); 
close(figures_to_close(2:end)); % close all figures except the main interface with all the controls 

handles = guidata(source);
set(handles.look,'Enable','off');
show_axial_figure(subj,directories,handles,funct);

end