function CVRmap(dimension,anat,funct,mp,sliceval,det_functionality,gen_file_location,mask_name,subj)
% Function to generate CVR map 
% 
% INPUTS 
%     dimension - axial,coronal,or saggital
%     anat - 3D anatomical subject data 
%     funct - 4D functional subject data 
%     mp - GUI data
%     sliceval - used for slice position if montage button is pressed 
%     det_functionality - 1 for montage, 2 for nothing, logical for
%                         creating edge mask 
%     gen_file_location - used for montage file location if montage button
%                         is pressed
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 15, 2016
% Author - Hannah Sennik
%   REVISIONS 
%       A - 2016-07-11 - Included CVRmap generation for montage 

%  global slider variables
global ax_slider_value;  
global cor_slider_value;
global sag_slider_value;
global sigmin;
global sigmax;
global onlypositive;
global onlynegative;

ROImask = 0;

if strcmp(dimension,'axial') == 1 %  if the axial slider is moved
    slice = floor(ax_slider_value);
    dim1 = anat.x;
    dim2 = anat.y;
    range1 = anat.xrange;
    range2 = anat.yrange;
elseif strcmp(dimension,'coronal') == 1 %  if the coronal slider is moved
    slice = floor(cor_slider_value);
    dim1 = anat.x;
    dim2 = anat.z;
    range1 = anat.xrange;
    range2 = anat.zrange; 
elseif strcmp(dimension,'saggital') == 1 %  if the saggital slider is moved
    slice = floor(sag_slider_value);
    dim1 = anat.y;
    dim2 = anat.z;
    range1 = anat.yrange;
    range2 = anat.zrange;
end

if strcmp(gen_file_location,'') == 0 %  if the montage button is pressed
    slice = sliceval; %  the slice is increased in increments of six to create a montage of 25 axial slices 
    display(slice);
    display('first');
end

if strcmp(mask_name,'') == 0 && strcmp(mask_name,'None') == 0 && strcmp(dimension,'axial') == 1
    ROImask = 1;
    display('masked');
    if strcmp(gen_file_location,'') == 1
        slice = floor(ax_slider_value);
    end     
end

%  Anatomical data 
if strcmp(dimension,'axial') == 1
    updated_slice = (double(repmat(imresize(squeeze(anat.img(:,:,slice)),[dim1 dim2]),[1 1 3]))-sigmin) / sigmax;
    updated_slice = imresize(updated_slice,[dim1 dim2/anat.hdr.dime.pixdim(1)]);
elseif strcmp(dimension,'coronal') == 1
    updated_slice = (double(repmat(imresize(squeeze(anat.img(:,floor(cor_slider_value),:)),[dim1 dim2]),[1 1 3]))-sigmin) / sigmax;
    updated_slice = imresize(updated_slice,[dim1 dim2/anat.hdr.dime.pixdim(2)]);
elseif strcmp(dimension,'saggital') == 1
    updated_slice = (double(repmat(imresize(squeeze(anat.img(floor(sag_slider_value),:,:)),[dim1 dim2]),[1 1 3]))-sigmin) / sigmax;
    updated_slice = imresize(updated_slice,[dim1 dim2/anat.hdr.dime.pixdim(3)]);
end
updated_slice = rot90(updated_slice(range1,range2,:)); % Rotate and flip the slice so that it is displayed correctly to the user 
updated_slice = flip(updated_slice,2);

%  Functional data 
if strcmp(dimension,'axial') == 1
    funct.mask = double(imresize(squeeze(funct.mapped_anat.img(:,:,slice)),[dim1 dim2],'nearest'));
    funct.mask = imresize(funct.mask,[dim1 dim2/anat.hdr.dime.pixdim(1)]);
    funct.mask = rot90(funct.mask(range1,range2,:));
    funct.mask = flip(funct.mask,2);
elseif strcmp(dimension,'coronal') == 1 || strcmp(dimension,'saggital') == 1
    if strcmp(dimension,'coronal') == 1
        if strcmp(mask_name,'Remove Ventricles and Venosinuses') == 1  
            mask_CSF = load_nii(['data/recon/' subj.name '/' subj.name '_anat_brain_seg_0.nii']);
            masked_slice = double(repmat(imresize(squeeze(mask_CSF.img(:,floor(cor_slider_value),:)),[anat.x anat.z]), [1 1 3]));
            masked_slice = imresize(masked_slice,[anat.x anat.z/anat.hdr.dime.pixdim(2)]);
            masked_slice = rot90(masked_slice(anat.xrange,anat.zrange,:));
            masked_slice = flip(masked_slice,2);
        end
        funct.mask = double(imresize(squeeze(funct.mapped_anat.img(:,floor(cor_slider_value),:)),[dim1 dim2],'nearest'));
        funct.mask = imresize(funct.mask,[dim1 dim2/anat.hdr.dime.pixdim(2)]);
        funct.mask = rot90(funct.mask(range1,range2,:));
        funct.mask = flip(funct.mask,2);
    elseif strcmp(dimension,'saggital') == 1
        if strcmp(mask_name,'Remove Ventricles and Venosinuses') == 1
            mask_CSF = load_nii(['data/recon/' subj.name '/' subj.name '_anat_brain_seg_0.nii']);
            masked_slice = double(repmat(imresize(squeeze(mask_CSF.img(floor(sag_slider_value),:,:)),[anat.y anat.z]), [1 1 3]));
            masked_slice = imresize(masked_slice,[anat.y anat.z/anat.hdr.dime.pixdim(3)]);
            masked_slice = rot90(masked_slice(anat.yrange,anat.zrange,:));
            masked_slice = flip(masked_slice,2);
        end
        funct.mask = double(imresize(squeeze(funct.mapped_anat.img(floor(sag_slider_value),:,:)),[dim1 dim2],'nearest'));
        funct.mask = imresize(funct.mask,[dim1 dim2/anat.hdr.dime.pixdim(3)]);
        funct.mask = rot90(funct.mask(range1,range2,:));
        funct.mask = flip(funct.mask,2);
    end
    
    if strcmp(mask_name,'Remove Ventricles and Venosinuses') == 1
        masked_slice = imcomplement(masked_slice);
        BW = im2bw(masked_slice);
        funct.mask = funct.mask.*BW;
    end
end

if ((ROImask == 1) && (strcmp(dimension,'axial') == 1)) || ((strcmp(mask_name,'') == 0) && (strcmp(mask_name,'None') == 0) && (strcmp(dimension,'axial') == 1))
    masked_slice = double(repmat(imresize(squeeze(det_functionality(:,:,slice)),[anat.x anat.y]), [1 1 3]));
    masked_slice = imresize(masked_slice,[anat.x anat.y/anat.hdr.dime.pixdim(1)]);
    masked_slice = rot90(masked_slice(anat.xrange,anat.yrange,:));
    masked_slice = flip(masked_slice,2);
    
%     if strcmp(mask_name,'Only Cerebellum') == 1 || strcmp(mask_name,'Cerebellum') == 1
%         level = 0;
%     else
%         level = 0.15;
%     end

if strcmp(mask_name,'Remove Ventricles and Venosinuses') == 1 
    masked_slice = imcomplement(masked_slice);
end
 BW = im2bw(masked_slice);
 
%     funct.mask = funct.mask.*BW;

    funct.mask = funct.mask.*BW;
end

thresh_indices = find (funct.mask < (max(funct.mask(:))-0.0000001)); % find all indices that contain the values specified
thresh_vec = reshape (funct.mask, [(size(funct.mask,1)*size(funct.mask,2)) 1]); % turn 3D array into vector 
thresh_values = thresh_vec(thresh_indices); % place the values at specified array indices in to another array

%  Splitting anatomical in to three colour channels 
redImg = updated_slice(:,:,1);
greenImg = updated_slice(:,:,2);
blueImg = updated_slice(:,:,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% anat_img  exists
% 
% 
% overlay image
% 
% % [x y z C]
% overlay_rgb = zeros(size(anat_img));
% 
% pos_rgb_ind = 1;
% neg_rgb_ind = 3;
% 
% find pos/neg in vector format then overwrite
% [pos_ind, pos_values] = find (...);
% 
% 
% %%% MERGING
% img_display = anat_img;   % create underlay
% 
% if pos_check
%     img_display(pos_ind, pos_rgb_ind) = pos_values;
% end
% if neg_check
%     img_display(neg_ind, neg_rgb_ind) = neg_values;
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%  Find positive values 
positive = find(thresh_values > mp.t.Value); %  find indices of positive values 
positive_values = thresh_values(positive); %  place positive values in an array 
max_positive_value = max(positive_values); %  find the max positive value and its index 
min_positive_value = min(positive_values); %  find the min positive value 

negative = find(thresh_values < -mp.t.Value); %  find indices of negative values 
negative_values = thresh_values(negative); %  place negative values in an array 
max_negative_value = min(negative_values); %  find max negative value and its index 
min_negative_value = max(negative_values); %  find the min negative value 

%  Differences between max and min values (for normalization)
if isempty(negative)
    neg_diff = 0;
else
    neg_diff = max_negative_value - min_negative_value;
end
if isempty(positive)
    pos_diff = 0;
else
    pos_diff = max_positive_value - min_positive_value;
end

AUTO = 1;

% logic to determine normalization denominator (have to still add this
% functionality in - user input in text box) 
if AUTO == 1
    norm_denom = max(abs(neg_diff), abs(pos_diff)); %  Take the max difference to use as normalization denominator 
else
    norm_denom = user_input; %  Allow for user input of normalization denominator (not added in yet)
end

%  Normalize the values to be between 0 and 1 
normalized_positive = (positive_values - min_positive_value)/(norm_denom);
normalized_negative = (negative_values - min_negative_value)/(-norm_denom);

multiplier = 7; %  necessary to avoid green showing up in CVR map 

if onlypositive == 1 && onlynegative == 0
    if ~isempty(positive)
        redImg(positive) = (1 - normalized_positive)*multiplier; %  Red is associated with positive correlation 
        greenImg(positive) = normalized_positive; %  Add in green channel so that there is colour variation 
        blueImg(positive) = 0;
    end
elseif onlynegative == 1 && onlypositive == 0
    if ~isempty(negative)
        redImg(negative) = 0;
        greenImg(negative) = normalized_negative;
        blueImg(negative) = (1 - normalized_negative)*multiplier; %  Blue is associated with negative correlation 
    end
elseif onlypositive == 1 && onlynegative == 1
    if ~isempty(positive)
        redImg(positive) = (1 - normalized_positive)*multiplier; %  Red is associated with positive correlation 
        greenImg(positive) = normalized_positive; %  Add in green channel so that there is colour variation 
        blueImg(positive) = 0;
    end
    if ~isempty(negative)
        blueImg(negative) = (1 - normalized_negative)*multiplier; %  Blue is associated with negative correlation 
        redImg(negative) = 0;
        greenImg(negative) = normalized_negative;
    end

end 
% if ((ROImask == 1) && (strcmp(dimension,'axial') == 1)) || ((strcmp(mask_name,'') == 0) && (strcmp(mask_name,'None') == 0))
%     masked_slice = (double(repmat(imresize(squeeze(det_functionality(:,:,floor(ax_slider_value))),[anat.x anat.y]), [1 1 3]))- sigmin) / sigmax ;
%     masked_slice = imresize(masked_slice,[anat.x anat.y/anat.hdr.dime.pixdim(1)]);
%     masked_slice = rot90(masked_slice(anat.xrange,anat.yrange,:));
%     masked_slice = flip(masked_slice,2);
%     
%     if strcmp(mask_name,'Only Cerebellum') == 1 || strcmp(mask_name,'Cerebellum') == 1
%         level = 0;
%     else
%         level = 0.15;
%     end
%     BW = im2bw(masked_slice,level);
% %     
% %     %  Get the edge of the region 
% %     masked_slice = edge(double(det_functionality(:,:,slice)),'Canny');
% %     masked_slice = rot90(masked_slice(anat.xrange,anat.yrange,:));
% %     masked_slice = flip(masked_slice,2);   
%     redImg = redImg.*BW;
%     greenImg = greenImg.*BW;
%     blueImg = blueImg.*BW;
% end

rgbImage = cat(3,redImg,greenImg,blueImg); %  concatenate the red, green, and blue images 

sliceval = int2str(sliceval); %  converting sliceval for montage to a string

if strcmp(gen_file_location,'') == 0
    imwrite(rgbImage,[gen_file_location 'slice' sliceval '.jpg']); %  write the image to a jpeg to be used in montage 
else 
    imshow(rgbImage); %  display the anatomical overlain with CVR map 
end

end
