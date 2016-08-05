function average_brain_timeseries(subj,directories,funct,pos,stim,boxcar_name,shift_custom_capability,sp)
% Function to extract the average brain timeseries using 3dmaskave and plot
% the timeseries against the boxcar 
% 
% INPUTS 
%     subj - subject data (name,date,breathhold)
%     directories - all of the directories for the subject
%     funct - functional subject data  (need the time)
%     pos - position of window
%     stim - stimfile (standard,shifted,customized...?)
%     boxcar_name - standard,shifted,customized
% 
% *************** REVISION INFO ***************
% Original Creation Date - August 5, 2016
% Author - Hannah Sennik

tag = 'processed';

% Use 3dmaskave to mask the functional data with finalmask.nii and save the
% timeseries to timeseries.1D in timeseries directory - SHOULD BE DOING
% 3DMASKAVE ON THE FUNCTIONAL DATA WHERE VENTRICLES AND VENOSINUSES ARE
% MASKED
command = ['3dmaskave -q -mask data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '_mask.nii data/' tag '/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii > ' directories.timeseries '/brain_average.1D'];
status = system(command);

timeseries = [directories.timeseries '/brain_average.1D'];
timeseries_name = 'Average Entire Brain Timeseries';
figname = ['Entire Brain Average Timeseries: ' subj.breathhold];

plotfiles(directories,subj,timeseries,stim,pos,figname,shift_custom_capability,timeseries_name,boxcar_name,funct,sp)

end
