function shift_boxcar(source,callbackdata,boxcar,starting_value,funct)
    xaxis = 1:funct.time; % data driven to get number of time points 
    horizontalShift = get(source,'Value');
    horizontalShift = horizontalShift - starting_value;
    adjusted_plot = plot(xaxis + horizontalShift,boxcar,'Color','green','Linewidth',2);
    legend('Timeseries from ROI','Standard Boxcar','Adjusted Boxcar');
end
