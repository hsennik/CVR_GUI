function viewboxcar(source,callbackdata,subj,directories,timeseries,main_GUI,funct)
% Function to plot the timeseries against customized boxcar
% 
% INPUTS 
%     subj - subject data (name, breathhold, date)
%     directories - all directory path info 
%     timeseries - filepath for the .1D timeseries file 
%     main_GUI - data from the main interface
%     funct - functional data 
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 22, 2016
% Author - Hannah Sennik

pos = [400,300,600,500]; % position of the plot figure window 

stim = [directories.subject '/' directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_customized.1D']; % stim file location 

timeseries_name = 'Timeseries'; % name of timeseries for legend
figname = ['Timeseries: ' subj.breathhold]; % plot figure name 
shift_custom_capability = 3; % this indicates that view boxcar was pressed 
boxcar_name = 'Customized Boxcar'; % name of boxcar for legend 

plotfiles(directories,subj,timeseries,stim,pos,figname,shift_custom_capability,timeseries_name,boxcar_name,funct,main_GUI); % call the plotfiles function

end