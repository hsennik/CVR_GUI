function CVRmap_function_axial(anat,funct,figurename)

%  Axial functional data 
funct.ax.mapped_anat = double(repmat(imresize(squeeze(funct.mapped_anat.img(:,:,anat.slice_z)),[anat.x anat.y]), [1 1 3]));
funct.ax.mask = double(imresize(squeeze(funct.mapped_anat.img(:,:,anat.slice_z)),[anat.x anat.y],'nearest'));
funct.ax.pixel_dimension = funct.mapped_anat.hdr.dime.pixdim(4);

%  AXIAL

thresh_indices = find (funct.ax.mask < (max(funct.ax.mask(:))-0.001)); % find all indices that contain the values specified
thresh_vec = reshape (funct.ax.mask, [(size(funct.ax.mask,1)*size(funct.ax.mask,2)) 1]); % turn 3D array into vector 
thresh_values = thresh_vec(thresh_indices); % place the values at specified array indices in to another array

positive = find(thresh_values > funct.p_value);
positive_values = thresh_values(positive); 
positive_full_array = zeros((size(funct.ax.mask,1)*size(funct.ax.mask,2)),1);
positive_full_array(positive) = 1; % equals one makes a binary mask (all positive values will have the same intensity of red)
positive_full_array_vol = reshape(positive_full_array,[size(funct.ax.mask,1) size(funct.ax.mask,2) 1]);
positive_full_array_vol = imresize(positive_full_array_vol,[anat.x anat.y/anat.hdr.dime.pixdim(4)]);
positive_full_array_vol = rot90(positive_full_array_vol(anat.xrange,anat.yrange,:));
positive_full_array_vol = flip(positive_full_array_vol,2);

negative = find(thresh_values < -funct.p_value);
negative_values = thresh_values(negative);
negative_full_array = zeros((size(funct.ax.mask,1)*size(funct.ax.mask,2)),1);
negative_full_array(negative) = 1;
negative_full_array_vol = reshape(negative_full_array,[size(funct.ax.mask,1) size(funct.ax.mask,2) 1]);
negative_full_array_vol = imresize(negative_full_array_vol,[anat.x anat.y/anat.hdr.dime.pixdim(4)]);
negative_full_array_vol = rot90(negative_full_array_vol(anat.xrange,anat.yrange,:));
negative_full_array_vol = flip(negative_full_array_vol,2);

anat.slice_ax = (double(repmat(imresize(squeeze(anat.img(:,:,anat.slice_z)),[anat.x anat.y]),[1 1 3]))-anat.sigmin) / anat.sigmax;
anat.slice_ax = rot90(anat.slice_ax(anat.xrange,anat.yrange,:));
anat.slice_ax = flip(anat.slice_ax,2);

anat.slice_ax(:,:,1) = anat.slice_ax(:,:,1) + positive_full_array_vol; 
anat.slice_ax(:,:,3) = anat.slice_ax(:,:,3) + negative_full_array_vol;

% axmap = figure('Name', figurename.ax_map);
imshow(anat.slice_ax);

end
