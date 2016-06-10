function sliderpos_cor(source,callbackdata,anat,mp,funct,cor_window)

cor_slider_value = get(source, 'Value'); %get the value of the slider position

display(cor_slider_value);

set(cor_window.position_slider,'String',floor(cor_slider_value));

anat.slice_y = anat.slice_y + floor(cor_slider_value - anat.slice_y);
updated_slice2 = (double(repmat(imresize(squeeze(anat.img(:,anat.slice_y,:)),[anat.x anat.z]),[1 1 3]))- anat.sigmin) / anat.sigmax;
updated_slice2 = imresize(updated_slice2,[anat.x anat.z/anat.hdr.dime.pixdim(3)]);
updated_slice2 = rot90(updated_slice2(anat.xrange,anat.zrange,:));
updated_slice2 = flip(updated_slice2,2);
    
if (mp.CVRb.Value == 1)
   CVRmap_function_coronal(anat,funct,mp);
else
   imshow(updated_slice2);
end
end