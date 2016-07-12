function sliderpos_ax(source,callbackdata,anat,mp,funct,ax_window,dir_input,subj)
% Function to update the axial slice displayed based on the axial slider position 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     mp - GUI data
%     funct - 4D functional subject data
%     ax_window - axial window
%     dir_input - main subject directory 
%     subj - subject data (name,date,breathhold)
%
% *************** REVISION INFO ***************
% Original Creation Date - May 26, 2016
% Author - Hannah Sennik

global ax_slider_value; 
ax_slider_value = get(source, 'Value'); % get the value of the slider position
display(ax_slider_value);
set(ax_window.position_slider,'String',floor(ax_slider_value)); % Display the updated slider value in the axial slice window 
slider_position('axial',anat,mp,funct,ax_window,dir_input,subj);

end
   