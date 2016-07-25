function slider_position(dimension,anat,mp,funct,window,directories,subj,GUI,mask_name)

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
    updated_slice = imresize(updated_slice,[dim1 dim2/anat.hdr.dime.pixdim(2)]);
elseif strcmp(dimension,'saggital') == 1
    updated_slice = (double(repmat(imresize(squeeze(anat.img(slice,:,:)),[dim1 dim2]),[1 1 3]))-anat.sigmin) / anat.sigmax;
    updated_slice = imresize(updated_slice,[dim1 dim2/anat.hdr.dime.pixdim(3)]);
end
updated_slice = rot90(updated_slice(range1,range2,:)); % Rotate and flip the slice so that it is displayed correctly to the user 
updated_slice = flip(updated_slice,2);

montage = 2;
sliceval = 0;
gen_file_location = '';

if strcmp(mask_name,'') == 0 && strcmp(mask_name,'None') == 0
    switch mask_name
        case 'Remove Ventricles and Venosinuses'
            mask = '';
        case 'Only White Matter'
            mask = load_nii([directories.flirtdir '/standard_to_anat/white_to_anat.nii']);
        case 'Only Gray Matter'
            mask = load_nii([directories.flirtdir '/standard_to_anat/gray_to_anat.nii']);
        case 'Only Cerebellum'
            mask = load_nii([directories.flirtdir '/standard_to_anat/cerebellum_to_anat.nii']);
    end
    if mp.CVRb.Value == 1
        CVRmap(dimension,anat,funct,mp,sliceval,mask.img,gen_file_location,mask_name);
    else
        masked_slice = (double(repmat(imresize(squeeze(mask.img(:,:,floor(ax_slider_value))),[anat.x anat.y]), [1 1 3]))- anat.sigmin) / anat.sigmax ;
        masked_slice = imresize(masked_slice,[anat.x anat.y/anat.hdr.dime.pixdim(1)]);
        masked_slice = rot90(masked_slice(anat.xrange,anat.yrange,:));
        masked_slice = flip(masked_slice,2);
    
        if strcmp(mask_name,'Only Cerebellum') == 1 || strcmp(mask_name,'Cerebellum') == 1
            level = 0;
        else
            level = 0.15;
        end
        BW = im2bw(masked_slice,level);

        BW = cat(3,BW,BW,BW);
        
        updated_slice = updated_slice.*BW;
        imshow(updated_slice);
    end
elseif GUI == 2 && mp.CVRb.Value == 1 % If the CVR button is pressed, call the function to overlay CVR map 
     CVRmap(dimension,anat,funct,mp,sliceval,montage,gen_file_location,mask_name);
else % Else, just display the anatomical slice 
    window.image = updated_slice;
    imshow(window.image);
end

if strcmp(dimension,'axial') == 1  
    if(window.drawROI.Value == 1) % If the user chooses to draw an ROI, call the drawROI function 
        drawROI(updated_slice,anat,directories,subj);
    end
end
end