function overlay_ax(source,callbackdata,z,vox1,vox2,min,max,anat,range1,range2,overlay)

global button_state;
global ax_slider_value;

% button_state = get(source,'Value');
% display(button_state);
% display(z);
display(ax_slider_value);

z = z + floor(ax_slider_value);
slice1 = (double(repmat(imresize(squeeze(anat.img(:,:,z)),[vox1 vox2]),[1 1 3]))- min) / max;
mask1 = edge(imresize(double(squeeze(overlay.img(:,:,z))),[vox1 vox2],'nearest'),'Canny');

if button_state == 1
    
    %  Code for displaying pf mask
    slice1(:,:,1) = slice1(:,:,1) + mask1;
    slice1(:,:,2) = slice1(:,:,2) - mask1;
    slice1(:,:,3) = slice1(:,:,3) - mask1;
    slice1 = rot90(slice1(range1,range2,:));
    imshow(slice1);
 
else
    
    slice1 = rot90(slice1(range1,range2,:));
    imshow(slice1);

end

end