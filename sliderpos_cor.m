function sliderpos_cor(source,callbackdata,anat,mp,funct,cor_window)
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

cor_slider_value = get(source, 'Value'); % get the value of the slider position

display(cor_slider_value);

set(cor_window.position_slider,'String',floor(cor_slider_value)); % Display the updated slider value in the coronal slice window 

anat.slice_y = anat.slice_y + floor(cor_slider_value - anat.slice_y); % Increase the slice position based on the slider value 
updated_slice = (double(repmat(imresize(squeeze(anat.img(:,anat.slice_y,:)),[anat.x anat.z]),[1 1 3]))- anat.sigmin) / anat.sigmax;
updated_slice = imresize(updated_slice,[anat.x anat.z/anat.hdr.dime.pixdim(3)]);
updated_slice = rot90(updated_slice(anat.xrange,anat.zrange,:)); % Rotate and flip the slice so that it is displayed correctly to the user 
updated_slice = flip(updated_slice,2);
    
if (mp.CVRb.Value == 1) % If the CVR button is pressed, call the function to overlay CVR map 
   CVRmap_function_coronal(anat,funct,mp);
else % Else, just display the anatomical slice 
   imshow(updated_slice);
end
end

