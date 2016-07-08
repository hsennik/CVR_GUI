function CVRmap_function_coronal(anat,funct,mp)
% Function to generate coronal CVR map 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     funct - 4D functional subject data 
%     mp - GUI data
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 15, 2016
% Author - Hannah Sennik

% Coronal functional data
funct.cor.mask = double(imresize(squeeze(funct.mapped_anat.img(:,anat.slice_y,:)),[anat.x anat.z],'nearest'));
funct.cor.mask = imresize(funct.cor.mask,[anat.x anat.z/anat.hdr.dime.pixdim(3)]);
funct.cor.mask = rot90(funct.cor.mask(anat.xrange,anat.zrange,:));
funct.cor.mask = flip(funct.cor.mask,2);

thresh_indices = find (funct.cor.mask < (max(funct.cor.mask(:))-0.001)); % find all indices that contain the values specified
thresh_vec = reshape (funct.cor.mask, [(size(funct.cor.mask,1)*size(funct.cor.mask,2)) 1]); % turn 3D array into vector 
thresh_values = thresh_vec(thresh_indices); % place the values at specified array indices in to another array

anat.slice_cor = (double(repmat(imresize(squeeze(anat.img(:,anat.slice_y,:)),[anat.x anat.z]),[1 1 3]))- anat.sigmin) / anat.sigmax;
anat.slice_cor = imresize(anat.slice_cor,[anat.x anat.z/anat.hdr.dime.pixdim(3)]);
anat.slice_cor = rot90(anat.slice_cor(anat.xrange,anat.zrange,:));
anat.slice_cor = flip(anat.slice_cor,2);

smaller_anat = anat.slice_cor(:,:,1);
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

