function sliderpos_sag(source,callbackdata,anat,mp,funct,sag_window,dir_input,subj)
% Function to update the sagittal slice displayed based on the sagittal slider position 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     mp - GUI data
%     funct - 4D functional subject data
%     sag_window - sagittal window
%
% *************** REVISION INFO ***************
% Original Creation Date - May 26, 2016
% Author - Hannah Sennik

global sag_slider_value;
sag_slider_value = get(source, 'Value'); % get the value of the slider position
display(sag_slider_value);
set(sag_window.position_slider,'String',floor(sag_slider_value)); % Display the updated slider value in the sagittal slice window 
slider_position('saggital',anat,mp,funct,sag_window,dir_input,subj);

end
