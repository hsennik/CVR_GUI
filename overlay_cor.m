function overlay_cor(source,callbackdata,y,vox1,vox3,min,max,anat,range1,range3,overlay)

global button_state;
global cor_slider_value;

% button_state = get(source,'Value');
% display(button_state);

y = y + floor(cor_slider_value);
slice2 = (double(repmat(imresize(squeeze(anat.img(:,y,:)),[vox1 vox3]),[1 1 3]))- min) / max;
mask2 = edge(imresize(double(squeeze(overlay.img(:,y,:))),[vox1 vox3],'nearest'),'Canny');

if button_state == 1
    
    %  Code for displaying pf mask
    slice2(:,:,1) = slice2(:,:,1) + mask2;
    slice2(:,:,2) = slice2(:,:,2) - mask2;
    slice2(:,:,3) = slice2(:,:,3) - mask2;
    slice2 = rot90(slice2(range1,range3,:));
    imshow(slice2);

else
    
    slice2 = rot90(slice2(range1,range3,:));
    imshow(slice2);
    
end

end