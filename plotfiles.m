function plotfiles(directories,subj,mp,timeseries_plot,region)

fileID = fopen([directories.textfilesdir '/standard_or_custom.txt'],'r'); % open the customize boxcar file
format = '%d';
custom_val = fscanf(fileID,format);     

% Determine which stimfile was used so that it can be displayed with the
% timeseries 
if(mp.menu(1).Value == 2)
    if custom_val == 1 && strcmp(mp.boxcarsel.String,'Boxcar selection: customized') == 1
        stim = [directories.matlabdir '/python/standard_HV.1D'];
    else
        stim = [directories.matlabdir '/python/standard_HV.1D'];
    end
elseif(mp.menu(1).Value == 3)
    stim = [directories.metadata '/stim/pf_',subj.breathhold,'_stim.1D'];
end

ts = figure('Name',['Timeseries from 3D ROI: ' region],...
       'Visible','on',...
       'Numbertitle','off',...
       'Position',[1130,400,600,410]); 
set(ts, 'MenuBar', 'none'); % remove the menu bar 
set(ts, 'ToolBar', 'none'); % remove the tool bar    
plot(timeseries_plot,'LineWidth',2);
title('Timeseries vs. Stimulus');
xlabel('Time');
ylabel('BOLD Signal');
hold; % hold the plot 
stimfile = load(stim); % load the stimfile used to generate the parametric map 
stimfile = stimfile + (median(timeseries_plot) - median(stimfile)) + 25; % move the plot up so that user can easily compare timeseries and stim
plot(stimfile,'LineWidth',2,'Color','red'); % plot the stimfile 
legend('Timeseries from ROI','Stimfile signal');
end