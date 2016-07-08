function CVRmap_function_axial(anat,funct,mp)
% Function to generate axial CVR map 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     funct - 4D functional subject data 
%     mp - GUI data
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 15, 2016
% Author - Hannah Sennik

%  Axial functional data 
funct.ax.mask = double(imresize(squeeze(funct.mapped_anat.img(:,:,anat.slice_z)),[anat.x anat.y],'nearest'));
funct.ax.mask = rot90(funct.ax.mask(anat.xrange,anat.yrange,:));
funct.ax.mask = flip(funct.ax.mask,2);

thresh_indices = find (funct.ax.mask < (max(funct.ax.mask(:))-0.001)); % find all indices that contain the values specified
thresh_vec = reshape (funct.ax.mask, [(size(funct.ax.mask,1)*size(funct.ax.mask,2)) 1]); % turn 3D array into vector 
thresh_values = thresh_vec(thresh_indices); % place the values at specified array indices in to another array

%  Axial anatomical data 
anat.slice_ax = (double(repmat(imresize(squeeze(anat.img(:,:,anat.slice_z)),[anat.x anat.y]),[1 1 3]))-anat.sigmin) / anat.sigmax;
anat.slice_ax = rot90(anat.slice_ax(anat.xrange,anat.yrange,:));
anat.slice_ax = flip(anat.slice_ax,2);

smaller_anat = anat.slice_ax(:,:,1);
%  Splitting anatomical in to three colour channels 
redImg = smaller_anat;
greenImg = smaller_anat;
blueImg = smaller_anat;

%  Find positive values 
positive = find(thresh_values > mp.t.Value); %  find indices of positive values 
positive_values = thresh_values(positive); %  place positive values in an array 
[max_positive_value,max_positive_index] = max(positive_values); %  find the max positive value and its index 
min_positive_value = min(positive_values); %  find the min positive value 

negative = find(thresh_values < -mp.t.Value); %  find indices of negative values 
negative_values = thresh_values(negative); %  place negative values in an array 
[max_negative_value,max_negative_index] = min(negative_values); %  find max negative value and its index 
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
    norm_denom = user_input; %  Allow for user input of normalization denominator 
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

rgbImage = cat(3,redImg,greenImg,blueImg); %  concatenate the red, green, and blue images 

imshow(rgbImage);

end
