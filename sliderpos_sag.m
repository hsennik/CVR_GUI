function sliderpos_sag(source,callbackdata,anat,mp,funct,sag_window)
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

sag_slider_value = get(source, 'Value'); % get the value of the slider position

display(sag_slider_value);

set(sag_window.position_slider,'String',floor(sag_slider_value)); % Display the updated slider value in the sagittal slice window 

anat.slice_x = anat.slice_x + floor(sag_slider_value - anat.slice_x); % Increase the slice position based on the slider value 
updated_slice = (double(repmat(imresize(squeeze(anat.img(anat.slice_x,:,:)),[anat.y anat.z]),[1 1 3]))- anat.sigmin) / anat.sigmax;
updated_slice = imresize(updated_slice,[anat.y anat.z/anat.hdr.dime.pixdim(3)]);
updated_slice = rot90(updated_slice(anat.yrange,anat.zrange,:)); % Rotate and flip the slice so that it is displayed correctly to the user 
updated_slice = flip(updated_slice,2);

if (mp.CVRb.Value == 1) % If the CVR button is pressed, call the function to overlay CVR map 
   CVRmap_function_saggital(anat,funct,mp); 
else % Else, just display the anatomical slice
   imshow(updated_slice);
end
end
