function sliderpos_cor(source,callbackdata,anat,mp,funct,cor_window,dir_input,subj)
% Function to update the coronal slice displayed based on the coronal slider position 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     mp - GUI data
%     funct - 4D functional subject data
%     cor_window - coronal window
%
% *************** REVISION INFO ***************
% Original Creation Date - May 26, 2016
% Author - Hannah Sennik

global cor_slider_value;
cor_slider_value = get(source, 'Value'); % get the value of the slider position
display(cor_slider_value);
set(cor_window.position_slider,'String',floor(cor_slider_value)); % Display the updated slider value in the coronal slice window 
slider_position('coronal',anat,mp,funct,cor_window,dir_input,subj);

end

