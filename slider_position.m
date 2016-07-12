function slider_position(dimension,anat,mp,funct,window,directory,subj)

global ax_slider_value;
global cor_slider_value;
global sag_slider_value;

if strcmp(dimension,'axial') == 1
    sliderval = ax_slider_value;
    slice = anat.slice_z;
    dim1 = anat.x;
    dim2 = anat.y;
    range1 = anat.xrange;
    range2 = anat.yrange;
elseif strcmp(dimension,'coronal') == 1
    sliderval = cor_slider_value;
    slice = anat.slice_y;
    dim1 = anat.x;
    dim2 = anat.z;
    range1 = anat.xrange;
    range2 = anat.zrange;
elseif strcmp(dimension,'saggital') == 1
    sliderval = sag_slider_value;
    slice = anat.slice_x;
    dim1 = anat.y;
    dim2 = anat.z;
    range1 = anat.yrange;
    range2 = anat.zrange;
end
  
slice = slice + floor(sliderval - slice); % Increase the slice position based on the slider value
if strcmp(dimension,'axial') == 1
    updated_slice = (double(repmat(imresize(squeeze(anat.img(:,:,slice)),[dim1 dim2]),[1 1 3]))-anat.sigmin) / anat.sigmax;
elseif strcmp(dimension,'coronal') == 1
    updated_slice = (double(repmat(imresize(squeeze(anat.img(:,slice,:)),[dim1 dim2]),[1 1 3]))-anat.sigmin) / anat.sigmax;
    updated_slice = imresize(updated_slice,[dim1 dim2/anat.hdr.dime.pixdim(3)]);
elseif strcmp(dimension,'saggital') == 1
    updated_slice = (double(repmat(imresize(squeeze(anat.img(slice,:,:)),[dim1 dim2]),[1 1 3]))-anat.sigmin) / anat.sigmax;
    updated_slice = imresize(updated_slice,[dim1 dim2/anat.hdr.dime.pixdim(3)]);
end
updated_slice = rot90(updated_slice(range1,range2,:)); % Rotate and flip the slice so that it is displayed correctly to the user 
updated_slice = flip(updated_slice,2);

montage = 2;
sliceval = 0;
gen_file_location = '';

if (mp.CVRb.Value == 1) % If the CVR button is pressed, call the function to overlay CVR map 
    CVRmap(dimension,anat,funct,mp,sliceval,montage,gen_file_location);
else % Else, just display the anatomical slice 
    window.image = updated_slice;
    imshow(window.image);
end

if strcmp(dimension,'axial') == 1  
    if(window.drawROI.Value == 1) % If the user chooses to draw an ROI, call the drawROI function 
        drawROI(updated_slice,anat,directory,subj);
    end
end
end