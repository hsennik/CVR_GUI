function overlay_sag(source,callbackdata,x,vox2,vox3,min,max,anat,range2,range3,overlay)

global button_state;
global sag_slider_value;

% button_state = get(source,'Value');
% display(button_state);

x = x + floor(sag_slider_value-x);
slice3 = (double(repmat(imresize(squeeze(anat.img(x,:,:)),[vox2 vox3]),[1 1 3]))- min) / max;
mask3 = edge(imresize(double(squeeze(overlay.img(x,:,:))),[vox2 vox3],'nearest'),'Canny');

if button_state == 1
    
    %  Code for displaying pf mask
    slice3(:,:,1) = slice3(:,:,1) + mask3;
    slice3(:,:,2) = slice3(:,:,2) - mask3;
    slice3(:,:,3) = slice3(:,:,3) - mask3;
    slice3 = rot90(slice3(range2,range3,:));
    imshow(slice3);
    
else
    
    slice3 = rot90(slice3(range2,range3,:));
    imshow(slice3);
    
end

end