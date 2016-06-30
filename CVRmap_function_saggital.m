function CVRmap_function_sagittal(anat,funct,mp)

%  sagittal functional data

funct.sag.mapped_anat = double(repmat(imresize(squeeze(funct.mapped_anat.img(anat.slice_x,:,:)),[anat.y anat.z]), [1 1 3]));
funct.sag.mask = double(imresize(squeeze(funct.mapped_anat.img(anat.slice_x,:,:)),[anat.y anat.z],'nearest'));
funct.sag.pixel_dimension = funct.mapped_anat.hdr.dime.pixdim(2);

funct.sag.mask = imresize(funct.sag.mask,[anat.y anat.z/anat.hdr.dime.pixdim(2)]);
funct.sag.mask = rot90(funct.sag.mask(anat.yrange,anat.zrange,:));
funct.sag.mask = flip(funct.sag.mask,2);

%  sagittal

thresh_indices = find (funct.sag.mask < (max(funct.sag.mask(:))-0.001)); % find all indices that contain the values specified
thresh_vec = reshape (funct.sag.mask, [(size(funct.sag.mask,1)*size(funct.sag.mask,2)) 1]); % turn 3D array into vector 
thresh_values = thresh_vec(thresh_indices); % place the values at specified array indices in to another array

anat.slice_sag = (double(repmat(imresize(squeeze(anat.img(anat.slice_x,:,:)),[anat.y anat.z]),[1 1 3]))- anat.sigmin) / anat.sigmax;
anat.slice_sag = imresize(anat.slice_sag,[anat.y anat.z/anat.hdr.dime.pixdim(2)]);
anat.slice_sag = rot90(anat.slice_sag(anat.yrange,anat.zrange,:));
anat.slice_sag = flip(anat.slice_sag,2);

smaller_anat = anat.slice_sag(:,:,1);
redImg = smaller_anat;
greenImg = smaller_anat;
blueImg = smaller_anat;

positive = find(thresh_values > mp.t.Value);
positive_values = thresh_values(positive); 
[max_positive_value,max_positive_index] = max(positive_values);
min_positive_value = min(positive_values);

negative = find(thresh_values < -mp.t.Value);
negative = find(thresh_values < -mp.t.Value);
negative_values = thresh_values(negative);
[max_negative_value,max_negative_index] = min(negative_values);
min_negative_value = max(negative_values);

neg_diff = max_negative_value - min_negative_value;
pos_diff = max_positive_value - min_positive_value;

AUTO = 1;

% logic to determine normalization denominator (have to still add this
% functionality in - user input in text box) 
if AUTO == 1
    norm_denom = max(abs(neg_diff), abs(pos_diff));
else
    norm_denom = user_input;
end

normalized_positive = (positive_values - min_positive_value)/(norm_denom);
normalized_negative = (negative_values - min_negative_value)/(-norm_denom);

multiplier = 7; 

redImg(positive) = (1 - normalized_positive)*multiplier;
redImg(negative) = 0;
greenImg(positive) = normalized_positive;   
greenImg(negative) = normalized_negative;
blueImg(positive) = 0;
blueImg(negative) = (1 - normalized_negative)*multiplier;

rgbImage = cat(3,redImg,greenImg,blueImg);

imshow(rgbImage);

end
