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

anat.slice_z = anat.slice_z + floor(ax_slider_value - anat.slice_z); % Increase the slice position based on the slider value
updated_slice = (double(repmat(imresize(squeeze(anat.img(:,:,anat.slice_z)),[anat.x anat.y]),[1 1 3]))-anat.sigmin) / anat.sigmax;
updated_slice = rot90(updated_slice(anat.xrange,anat.yrange,:)); % Rotate and flip the slice so that it is displayed correctly to the user 
updated_slice = flip(updated_slice,2);

if (mp.CVRb.Value == 1) % If the CVR button is pressed, call the function to overlay CVR map 
   CVRmap_function_axial(anat,funct,mp);
else % Else, just display the anatomical slice 
   ax_window.image = updated_slice;
   imshow(updated_slice);
end

if(ax_window.drawROI.Value == 1) % If the user chooses to draw an ROI, call the drawROI function 
    drawROI(updated_slice,anat,dir_input,subj);
end

end
   