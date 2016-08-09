function standard_selected(source,callbackdata,subj,directories,funct)
% Function called when standard boxcar is selected
% 
% INPUTS 
%     subj - subject data (name,date,breathhold)
%     directories - all of the directories for the subject
%     funct - functional data 
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 22, 2016
% Author - Hannah Sennik

figures_to_close = findall(0,'Type','figure'); 
handles = guidata(source);
close(figures_to_close(2:end)); % close all figures except the main interface with all the controls 
set(handles.start,'Enable','on'); % enable the analyze button 
 
% if exist(['data/analyzed_standard_boxcar/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2 % if the standard boxcar analysis was done for this breathhold then dont do it again 
%     set(handles.start,'Enable','off');
%     set(handles.look,'Enable','on');
% end       

pos = [358,800,900,670]; % initialize the position of the window to show the average brain timeseries plot
stim = [directories.subject '/' directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '.1D']; % initialize the stimfile selection as the standard boxcar
boxcar_name = 'Standard Boxcar';
shift_capability = 0;

average_brain_timeseries(subj,directories,funct,pos,stim,boxcar_name,shift_capability,handles); % call the function to plot the average brain timeseries against the standard boxcar

end