function shift_boxcar(source,callbackdata,boxcar,starting_value,funct,ts)
% Function to plot the shifted boxcar on the same plot that the timeseries
% and standard boxcar are plotted on 
% 
% INPUTS 
%     boxcar - the standard boxcar
%     starting value - starting value of the shift slider
%     funct - functional data
%     ts - all the data from the ts struct (plot data)
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 5, 2016
% Author - Hannah Sennik

persistent adjusted_plot; % keep adjusted plot as a variable 
delete(findobj(adjusted_plot,'Color','green')); % delete the previous shifted plot if the user shifts the plot again 
xaxis = 1:funct.time; % data driven to get number of time points 
horizontalShift = get(source,'Value'); % get the slider value 
horizontalShift = floor(horizontalShift);
horizontalShift = horizontalShift - starting_value;
adjusted_plot = plot(xaxis + horizontalShift,boxcar,'Color','green','Linewidth',2); % plot the shifted boxcar 
legend('Timeseries from ROI','Standard Boxcar','Shifted Boxcar');
set(ts.shift_number,'String',['Shift value: ' num2str(horizontalShift) ' TR']);

end
