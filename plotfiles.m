function plotfiles(directories,subj,timeseries,stim,pos,figname,shift_custom_capability,timeseries_name,boxcar_name,funct,GUIdat)
% Function to plot timeseries against the stimulus/regressor file 
% 
% INPUTS 
%     directories - all of the directories for the subject
%     subj - subject data (name,date,breathhold)
%     timeseries - file path for the timeseries file 
%     stim- file path for the stimulus file
%     pos - position of the plot figure
%     figname - name of the plot figure
%     shift_custom_capability - 1:shifted boxcar, 2:customized boxcar,
%     3:view customized boxcar, 5:nothing
%     timeseries_name - timeseries label in the legend
%     boxcar_name - boxcar label in the legend
%     funct - functional subject data  (need the time)
%     GUIdat - has all the data from the struct passed in 
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 5, 2016
% Author - Hannah Sennik

%  Load in the .1D timeseries 
timeseries_plot = load(timeseries);

stimfile = load(stim); % load the stimfile 
if strcmp(stim,[directories.metadata '/stim/bhonset' subj.name '_sawtooth.1D']) == 0 && strcmp(stim,[directories.metadata '/stim/pf_stim_' subj.breathhold '_processed.1D']) == 0
    stimfile = stimfile/10; % shrink the amplitude
elseif strcmp(stim,[directories.metadata '/stim/bhonset' subj.name '_sawtooth.1D']) == 1
    stimfile = stimfile*20;
end
stimfile = stimfile + (median(timeseries_plot) - median(stimfile)) -25; % move the plot down so that user can easily compare timeseries and stim

%  Creating the figure to display the plots 
ts.f = figure('Name',figname,...
                       'Visible','on',...
                       'Numbertitle','off',...
                       'Position', pos);

% set(ts.f, 'MenuBar', 'none'); % remove the menu bar 
% set(ts.f, 'ToolBar', 'none'); % remove the tool bar      

timeplot = plot(timeseries_plot,'Linewidth',2);  % plot the timeseries from the ROI 
title(figname) % title of the figure 
xlabel('Number of TRs') % x-axis label 
ylabel('BOLD Signal') % y-axis label 
hold; % hold the plot 

stimplot = plot(stimfile,'Color','red','Linewidth',2); % plot the stimfile 

blah = legend(timeseries_name,boxcar_name); % legend labels 

ax = gca;

%  Number of ticks for the x-axis depending on the time of functional data 
if funct.hdr.dime.dim(5) == 178
    ax.XTick = [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180];
elseif funct.hdr.dime.dim(5) == 238
    ax.XTick = [0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240];
end 

if shift_custom_capability == 1 % if shifted boxcar is selected then create a slider bar on the plot figure 
    
    starting_value = 0;
    
    %  Display shifted number (#TR)                    
    ts.shift_number = uicontrol('style', 'text',...
                                'Units','normalized',...
                                'String','Shift Value: 0',...
                                'position',[0.82 0 0.18 0.05]);       
    
    %  Slider to control boxcar shifting                     
    ts.shift_boxcar = uicontrol('style', 'slider',...
                                'Min',-20,'Max',20,'Value',starting_value,... 
                                'units', 'normalized',...
                                'SliderStep',[1/40,10/40],...
                                'position',[0.6 0 0.25 0.05],...
                                'callback',{@shift_boxcar,stimfile,starting_value,funct,ts});   

    %  Checkbox for shifted boxcar
    ts.save_shifted = uicontrol('Style','checkbox',...
                                'Visible','on',...
                                'String','Use Shifted Boxcar',...
                                'HandleVisibility','on',...
                                'Position',[35,0,225,25],...
                                'Enable','on',...
                                'callback',{@save_shifted_to_file,subj,ts,directories,funct,GUIdat});                                      
else 
    %  Calculate the correlation value 
    [R,P] = corrcoef(timeseries_plot,stimfile);
    display(R);
    display(P);
    
    R = round(R,3);
    P = round(P,3);
    
    %  Display R value                   
    ts.r_value = uicontrol('style', 'text',...
                                'Units','normalized',...
                                'String',['r: ' num2str(R(1,2))],...
                                'position',[0.22 0.04 0.18 0.02]);  

    %  Display P value                   
    ts.p_value = uicontrol('style', 'text',...
                                'Units','normalized',...
                                'String',['p: ' num2str(P(1,2))],...
                                'position',[0.22 0.01 0.18 0.025]); 
end

if shift_custom_capability == 2 % if create customized boxcar is selected 
    completely = 0;
    create_boxcar(subj,directories,GUIdat,timeseries,completely,funct);
elseif shift_custom_capability == 3 % if view boxcar is selected after creating a customized boxcar then create a checkbox to save the boxcar and move the r-value, p-value displays
    %  Checkbox to select customized boxcar
    ts.save_customized = uicontrol('Style','checkbox',...
                                'Visible','on',...
                                'String','Use Customized Boxcar',...
                                'HandleVisibility','on',...
                                'Position',[35,0,225,20],...
                                'Enable','on',...
                                'callback',{@close_customized_windows,subj,GUIdat});

    set(ts.r_value,'position',[0.68 0.02 0.18 0.03]);
    set(ts.p_value,'position',[0.82 0.02 0.18 0.03]);
    
elseif shift_custom_capability == 5
    set(ts.r_value,'position',[0.68 0.01 0.18 0.04]);
    set(ts.p_value,'position',[0.82 0.01 0.18 0.04]);
end

if strcmp(boxcar_name,'Standard Boxcar') == 1
    type = 'standard_boxcar';
elseif strcmp(boxcar_name,'Customized Boxcar') == 1
    type = 'customized_boxcar';
elseif strcmp(boxcar_name,'Shifted Boxcar') ==1 
    type = 'shifted_boxcar';
elseif strcmp(boxcar_name,'Sawtooth') == 1
    type = 'sawtooth';
elseif strcmp(boxcar_name, 'Cerebellum') == 1
    type = 'pf';
end

if strcmp(figname,'Entire Brain Timeseries') == 1
    mkdir([directories.subject '/clinician_final/' subj.breathhold], type);
    saveas(ts.f,[directories.subject '/clinician_final/' subj.breathhold '/' type '/' subj.name '_' subj.breathhold '_' boxcar_name '.jpg']);
end

end