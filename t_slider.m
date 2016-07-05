function t_slider(source,callbackdata,mp)
% Function to update the t statistic value displayed on the main figure 
% 
% INPUTS 
%     mp - GUI data
%
% *************** REVISION INFO ***************
% Original Creation Date - June 8, 2016
% Author - Hannah Sennik

tnum = get(source,'Value'); % Get value of the tstat slider 
display (tnum);

tnum = round(tnum,4); % Round the tstat value for display 

set(mp.t_number,'String',tnum); % Set the displayed string to the rounded value 

end