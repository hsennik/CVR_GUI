function CVRmap(dimension,anat,funct,mp,sliceval,det_functionality,gen_file_location,mask_name)
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

ROImask = 0;

if strcmp(dimension,'axial') == 1 %  if the axial slider is moved
    sliderval = ax_slider_value;
    slice = anat.slice_z;
    dim1 = anat.x;
    dim2 = anat.y;
    range1 = anat.xrange;
    range2 = anat.yrange;
elseif strcmp(dimension,'coronal') == 1 %  if the coronal slider is moved
    sliderval = cor_slider_value;
    slice = anat.slice_y;
    dim1 = anat.x;
    dim2 = anat.z;
    range1 = anat.xrange;
    range2 = anat.zrange; 
elseif strcmp(dimension,'saggital') == 1 %  if the saggital slider is moved
    sliderval = sag_slider_value;
    slice = anat.slice_x;
    dim1 = anat.y;
    dim2 = anat.z;
    range1 = anat.yrange;
    range2 = anat.zrange;
end

if det_functionality == 1 %  if the montage button is pressed
    slice = sliceval; %  the slice is increased in increments of six to create a montage of 25 axial slices 
    display(slice);
    display('first');
elseif det_functionality == 2 %  if just need to overlay regular CVR map 
    slice = slice + floor(sliderval - slice);
    display('second');
end

if strcmp(mask_name,'') == 0 && strcmp(mask_name,'None') == 0
    ROImask = 1;
    display('masked');
    slice = floor(ax_slider_value);
end

%  Anatomical data 
if strcmp(dimension,'axial') == 1
    updated_slice = (double(repmat(imresize(squeeze(anat.img(:,:,slice)),[dim1 dim2]),[1 1 3]))-anat.sigmin) / anat.sigmax;
    updated_slice = imresize(updated_slice,[dim1 dim2/anat.hdr.dime.pixdim(1)]);
elseif strcmp(dimension,'coronal') == 1
    updated_slice = (double(repmat(imresize(squeeze(anat.img(:,slice,:)),[dim1 dim2]),[1 1 3]))-anat.sigmin) / anat.sigmax;
    updated_slice = imresize(updated_slice,[dim1 dim2/anat.hdr.dime.pixdim(2)]);
elseif strcmp(dimension,'saggital') == 1
    updated_slice = (double(repmat(imresize(squeeze(anat.img(slice,:,:)),[dim1 dim2]),[1 1 3]))-anat.sigmin) / anat.sigmax;
    updated_slice = imresize(updated_slice,[dim1 dim2/anat.hdr.dime.pixdim(3)]);
end
updated_slice = rot90(updated_slice(range1,range2,:)); % Rotate and flip the slice so that it is displayed correctly to the user 
updated_slice = flip(updated_slice,2);

%  Functional data 
if strcmp(dimension,'axial') == 1
    funct.mask = double(imresize(squeeze(funct.mapped_anat.img(:,:,slice)),[dim1 dim2],'nearest'));
    funct.mask = imresize(funct.mask,[dim1 dim2/anat.hdr.dime.pixdim(1)]);
elseif strcmp(dimension,'coronal') == 1
    funct.mask = double(imresize(squeeze(funct.mapped_anat.img(:,slice,:)),[dim1 dim2],'nearest'));
    funct.mask = imresize(funct.mask,[dim1 dim2/anat.hdr.dime.pixdim(2)]);
elseif strcmp(dimension,'saggital') == 1
    funct.mask = double(imresize(squeeze(funct.mapped_anat.img(slice,:,:)),[dim1 dim2],'nearest'));
    funct.mask = imresize(funct.mask,[dim1 dim2/anat.hdr.dime.pixdim(3)]);
end

funct.mask = rot90(funct.mask(range1,range2,:));
funct.mask = flip(funct.mask,2);

if ((ROImask == 1) && (strcmp(dimension,'axial') == 1)) || ((strcmp(mask_name,'') == 0) && (strcmp(mask_name,'None') == 0))
    masked_slice = (double(repmat(imresize(squeeze(det_functionality(:,:,floor(ax_slider_value))),[anat.x anat.y]), [1 1 3]))- anat.sigmin) / anat.sigmax ;
    masked_slice = imresize(masked_slice,[anat.x anat.y/anat.hdr.dime.pixdim(1)]);
    masked_slice = rot90(masked_slice(anat.xrange,anat.yrange,:));
    masked_slice = flip(masked_slice,2);
    
    if strcmp(mask_name,'Only Cerebellum') == 1 || strcmp(mask_name,'Cerebellum') == 1
        level = 0;
    else
        level = 0.15;
    end
    BW = im2bw(masked_slice,level);
    funct.mask = funct.mask.*BW;
end

thresh_indices = find (funct.mask < (max(funct.mask(:))-0.0000001)); % find all indices that contain the values specified
thresh_vec = reshape (funct.mask, [(size(funct.mask,1)*size(funct.mask,2)) 1]); % turn 3D array into vector 
thresh_values = thresh_vec(thresh_indices); % place the values at specified array indices in to another array

%  Splitting anatomical in to three colour channels 
redImg = updated_slice(:,:,1);
greenImg = updated_slice(:,:,2);
blueImg = updated_slice(:,:,3);

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
neg_diff = max_negative_value - min_negative_value;
pos_diff = max_positive_value - min_positive_value;

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

redImg(positive) = (1 - normalized_positive)*multiplier; %  Red is associated with positive correlation 
redImg(negative) = 0;
greenImg(positive) = normalized_positive; %  Add in green channel so that there is colour variation 
greenImg(negative) = normalized_negative;
blueImg(positive) = 0;
blueImg(negative) = (1 - normalized_negative)*multiplier; %  Blue is associated with negative correlation 

% if ((ROImask == 1) && (strcmp(dimension,'axial') == 1)) || ((strcmp(mask_name,'') == 0) && (strcmp(mask_name,'None') == 0))
%     masked_slice = (double(repmat(imresize(squeeze(det_functionality(:,:,floor(ax_slider_value))),[anat.x anat.y]), [1 1 3]))- anat.sigmin) / anat.sigmax ;
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

if det_functionality == 1
    imwrite(rgbImage,[gen_file_location 'slice' sliceval '.jpg']); %  write the image to a jpeg to be used in montage 
else
    imshow(rgbImage); %  display the anatomical overlain with CVR map 
end

end
