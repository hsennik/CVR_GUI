function viewboxcar(source,callbackdata,subj,directories,timeseries)

pos = [400,300,600,500];

stimlocation = [directories.subject '/' directories.metadata '/stim/bhonset' subj.name '_' subj.breathhold '_customized.1D'];
customizedbox = load(stimlocation);
    
view.f = figure('Name',['Timeseries vs. Customized Boxcar: ' subj.breathhold],...
       'numbertitle','off',...
       'Visible','on',...
        'Position',pos); 
set(view.f, 'MenuBar', 'none'); % remove the menu bar 
set(view.f, 'ToolBar', 'none'); % remove the tool bar        
    
timeplot = plot(timeseries,'Linewidth',2);  % plot the timeseries from the ROI 
title(['Timeseries vs. Customized Boxcar ' subj.breathhold])
xlabel('Scan Time')
ylabel('BOLD Signal')
hold; % hold the plot 

customizedbox = customizedbox + (median(timeseries) - median(customizedbox)) + 50;
stimplot = plot(customizedbox,'Color','red','Linewidth',2); 

legend('Timeseries from ROI','Customized Boxcar');    
ax = gca;
ax.XTick = [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180];
end