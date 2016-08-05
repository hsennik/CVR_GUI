function completelycustomized(source,callbackdata,subj,directories,main_GUI,timeseries,funct)
% Function to allow the user to create a completely customized boxcar
% 
% INPUTS 
%     subj - subject data (name, breathhold, date)
%     directories - all directory path info 
%     main_GUI - data from the main interface
%     timeseries - filepath for the .1D timeseries file 
%     funct - functional data 
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 22, 2016
% Author - Hannah Sennik

% close interface to create customized boxcar where all blocks are the same
% length 
close(findobj('type','figure','name',['Create customized boxcar for: ' subj.breathhold]));
% close timeseries windows 
close(findobj('type','figure','name',['Timeseries: ' subj.breathhold]));
completely = 1; % set completely to 1 to indicate that a different interface should be made 
create_boxcar(subj,directories,main_GUI,timeseries,completely,funct); % create the boxcar interface with the fields for complete customization 
end