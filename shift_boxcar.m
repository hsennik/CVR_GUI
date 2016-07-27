function shift_boxcar(source,callbackdata,boxcar,starting_value,funct,ts)
    persistent adjusted_plot;
    delete(findobj(adjusted_plot,'Color','green'));
    xaxis = 1:funct.time; % data driven to get number of time points 
    horizontalShift = get(source,'Value');
    horizontalShift = floor(horizontalShift);
    horizontalShift = horizontalShift - starting_value;
    adjusted_plot = plot(xaxis + horizontalShift,boxcar,'Color','green','Linewidth',2);
    legend('Timeseries from ROI','Standard Boxcar','Shifted Boxcar');
    set(ts.shift_number,'String',[num2str(horizontalShift) ' TR']);
end
