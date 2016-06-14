function CVRmap_function_coronal(anat,funct,mp)

%  Coronal functional data

funct.cor.mapped_anat = double(repmat(imresize(squeeze(funct.mapped_anat.img(:,anat.slice_y,:)),[anat.x anat.z]), [1 1 3]));
funct.cor.mask = double(imresize(squeeze(funct.mapped_anat.img(:,anat.slice_y,:)),[anat.x anat.z],'nearest'));
funct.cor.pixel_dimension = funct.mapped_anat.hdr.dime.pixdim(3);

funct.cor.mask = imresize(funct.cor.mask,[anat.x anat.z/anat.hdr.dime.pixdim(3)]);
funct.cor.mask = rot90(funct.cor.mask(anat.xrange,anat.zrange,:));
funct.cor.mask = flip(funct.cor.mask,2);

%  CORONAL

thresh_indices2 = find (funct.cor.mask < (max(funct.cor.mask(:))-0.001)); % find all indices that contain the values specified
thresh_vec2 = reshape (funct.cor.mask, [(size(funct.cor.mask,1)*size(funct.cor.mask,2)) 1]); % turn 3D array into vector 
thresh_values2 = thresh_vec2(thresh_indices2); % place the values at specified array indices in to another array

anat.slice_cor = (double(repmat(imresize(squeeze(anat.img(:,anat.slice_y,:)),[anat.x anat.z]),[1 1 3]))- anat.sigmin) / anat.sigmax;
anat.slice_cor = imresize(anat.slice_cor,[anat.x anat.z/anat.hdr.dime.pixdim(3)]);
anat.slice_cor = rot90(anat.slice_cor(anat.xrange,anat.zrange,:));
anat.slice_cor = flip(anat.slice_cor,2);

smaller_anat = anat.slice_cor(:,:,1);
redImg = smaller_anat;
greenImg = smaller_anat;
blueImg = smaller_anat;

positive2 = find(thresh_values2 > mp.t.Value);
% positive_values2 = thresh_values2(positive2); 
% positive_full_array2 = zeros((size(funct.cor.mask,1)*size(funct.cor.mask,2)),1);
% positive_full_array2(positive2) = 1; % equals one makes a binary mask (all positive values will have the same intensity of red)
% positive_full_array_vol2 = reshape(positive_full_array2,[size(funct.cor.mask,1) size(funct.cor.mask,2) 1]);
% positive_full_array_vol2 = imresize(positive_full_array_vol2,[anat.x anat.z/anat.hdr.dime.pixdim(3)]);
% positive_full_array_vol2 = rot90(positive_full_array_vol2(anat.xrange,anat.zrange,:));
% positive_full_array_vol2 = flip(positive_full_array_vol2,2);

negative2 = find(thresh_values2 < -mp.t.Value);
% negative_values2 = thresh_values2(negative2);
% negative_full_array2 = zeros((size(funct.cor.mask,1)*size(funct.cor.mask,2)),1);
% negative_full_array2(negative2) = 1;
% negative_full_array_vol2 = reshape(negative_full_array2,[size(funct.cor.mask,1) size(funct.cor.mask,2) 1]);
% negative_full_array_vol2 = imresize(negative_full_array_vol2,[anat.x anat.z/anat.hdr.dime.pixdim(3)]);
% negative_full_array_vol2 = rot90(negative_full_array_vol2(anat.xrange,anat.zrange,:));
% negative_full_array_vol2 = flip(negative_full_array_vol2,2);

% anat.slice_cor = (double(repmat(imresize(squeeze(anat.img(:,anat.slice_y,:)),[anat.x anat.z]),[1 1 3]))- anat.sigmin) / anat.sigmax;
% anat.slice_cor = imresize(anat.slice_cor,[anat.x anat.z/anat.hdr.dime.pixdim(3)]);
% anat.slice_cor = rot90(anat.slice_cor(anat.xrange,anat.zrange,:));
% anat.slice_cor = flip(anat.slice_cor,2);

% anat.slice_cor(:,:,1) = anat.slice_cor(:,:,1) + positive_full_array_vol2; 
% anat.slice_cor(:,:,3) = anat.slice_cor(:,:,3) + negative_full_array_vol2;
% 
% imshow(anat.slice_cor);

redImg(positive2) = 255;
redImg(negative2) = 0;
greenImg(positive2) = 0;
greenImg(negative2) = 0;
blueImg(positive2) = 0;
blueImg(negative2) = 255;

rgbImage = cat(3,redImg,greenImg,blueImg);

imshow(rgbImage);

end

