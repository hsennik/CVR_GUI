function sliderpos_ax(source,callbackdata,anat,mp,funct,ax_window,directories,subj,GUI)
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

handles = guidata(source);
if GUI == 2
    temp_name = handles.predetermined_ROI.String(handles.predetermined_ROI.Value);
    mask_name = temp_name{1}; % get the mask name
else
    mask_name = '';
end
global ax_slider_value; 
ax_slider_value = get(source, 'Value'); % get the value of the slider position
display(ax_slider_value);
set(ax_window.position_slider,'String',floor(ax_slider_value)); % Display the updated slider value in the axial slice window 
slider_position('axial',anat,mp,funct,ax_window,directories,subj,GUI,mask_name);

end
   