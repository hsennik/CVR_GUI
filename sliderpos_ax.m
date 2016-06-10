function sliderpos_ax(source,callbackdata,anat,mp,funct,ax_window)

ax_slider_value = get(source, 'Value'); %get the value of the slider position

display(ax_slider_value);

set(ax_window.position_slider,'String',floor(ax_slider_value));

anat.slice_z = anat.slice_z + floor(ax_slider_value - anat.slice_z);
updated_slice = (double(repmat(imresize(squeeze(anat.img(:,:,anat.slice_z)),[anat.x anat.y]),[1 1 3]))-anat.sigmin) / anat.sigmax;
updated_slice = rot90(updated_slice(anat.xrange,anat.yrange,:));
updated_slice = flip(updated_slice,2);

if (mp.CVRb.Value == 1)
   CVRmap_function_axial(anat,funct,mp);
else
   imshow(updated_slice);
end

end
   