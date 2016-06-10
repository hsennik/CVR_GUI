function sliderpos_sag(source,callbackdata,anat,mp,funct,sag_window)

sag_slider_value = get(source, 'Value'); %get the value of the slider position

display(sag_slider_value);

set(sag_window.position_slider,'String',floor(sag_slider_value));

anat.slice_x = anat.slice_x + floor(sag_slider_value - anat.slice_x);
updated_slice3 = (double(repmat(imresize(squeeze(anat.img(anat.slice_x,:,:)),[anat.y anat.z]),[1 1 3]))- anat.sigmin) / anat.sigmax;
updated_slice3 = imresize(updated_slice3,[anat.y anat.z/anat.hdr.dime.pixdim(3)]);
updated_slice3 = rot90(updated_slice3(anat.yrange,anat.zrange,:));
updated_slice3 = flip(updated_slice3,2);

if (mp.CVRb.Value == 1)
   CVRmap_function_saggital(anat,funct,mp); 
else
   imshow(updated_slice3);
end
end

