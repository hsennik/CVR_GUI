function CVRmap_function_sagittal(anat,funct,mp)

%  sagittal functional data

funct.sag.mapped_anat = double(repmat(imresize(squeeze(funct.mapped_anat.img(anat.slice_x,:,:)),[anat.y anat.z]), [1 1 3]));
funct.sag.mask = double(imresize(squeeze(funct.mapped_anat.img(anat.slice_x,:,:)),[anat.y anat.z],'nearest'));
funct.sag.pixel_dimension = funct.mapped_anat.hdr.dime.pixdim(2);

funct.sag.mask = imresize(funct.sag.mask,[anat.y anat.z/anat.hdr.dime.pixdim(2)]);
funct.sag.mask = rot90(funct.sag.mask(anat.yrange,anat.zrange,:));
funct.sag.mask = flip(funct.sag.mask,2);

%  sagittal

thresh_indices3 = find (funct.sag.mask < (max(funct.sag.mask(:))-0.001)); % find all indices that contain the values specified
thresh_vec3 = reshape (funct.sag.mask, [(size(funct.sag.mask,1)*size(funct.sag.mask,2)) 1]); % turn 3D array into vector 
thresh_values3 = thresh_vec3(thresh_indices3); % place the values at specified array indices in to another array

anat.slice_sag = (double(repmat(imresize(squeeze(anat.img(anat.slice_x,:,:)),[anat.y anat.z]),[1 1 3]))- anat.sigmin) / anat.sigmax;
anat.slice_sag = imresize(anat.slice_sag,[anat.y anat.z/anat.hdr.dime.pixdim(2)]);
anat.slice_sag = rot90(anat.slice_sag(anat.yrange,anat.zrange,:));
anat.slice_sag = flip(anat.slice_sag,2);

smaller_anat = anat.slice_sag(:,:,1);
redImg = smaller_anat;
greenImg = smaller_anat;
blueImg = smaller_anat;

positive3 = find(thresh_values3 > mp.t.Value);
% positive_values3 = thresh_values3(positive3); 
% positive_full_array3 = zeros((size(funct.sag.mask,1)*size(funct.sag.mask,2)),1);
% positive_full_array3(positive3) = 1; % equals one makes a binary mask (all positive values will have the same intensity of red)
% positive_full_array_vol3 = reshape(positive_full_array3,[size(funct.sag.mask,1) size(funct.sag.mask,2) 1]);
% positive_full_array_vol3 = imresize(positive_full_array_vol3,[anat.y anat.z/anat.hdr.dime.pixdim(2)]);
% positive_full_array_vol3 = rot90(positive_full_array_vol3(anat.yrange,anat.zrange,:));
% positive_full_array_vol3 = flip(positive_full_array_vol3,2);

negative3 = find(thresh_values3 < -mp.t.Value);
% negative_values3 = thresh_values3(negative3);
% negative_full_array3 = zeros((size(funct.sag.mask,1)*size(funct.sag.mask,2)),1);
% negative_full_array3(negative3) = 1;
% negative_full_array_vol3 = reshape(negative_full_array3,[size(funct.sag.mask,1) size(funct.sag.mask,2) 1]);
% negative_full_array_vol3 = imresize(negative_full_array_vol3,[anat.y anat.z/anat.hdr.dime.pixdim(2)]);
% negative_full_array_vol3 = rot90(negative_full_array_vol3(anat.yrange,anat.zrange,:));
% negative_full_array_vol3 = flip(negative_full_array_vol3,2);
% 
% anat.slice_sag = (double(repmat(imresize(squeeze(anat.img(anat.slice_x,:,:)),[anat.y anat.z]),[1 1 3]))- anat.sigmin) / anat.sigmax;
% anat.slice_sag = imresize(anat.slice_sag,[anat.y anat.z/anat.hdr.dime.pixdim(3)]);
% anat.slice_sag = rot90(anat.slice_sag(anat.yrange,anat.zrange,:));
% anat.slice_sag = flip(anat.slice_sag,2);

% anat.slice_sag(:,:,1) = anat.slice_sag(:,:,1) + positive_full_array_vol3; 
% anat.slice_sag(:,:,3) = anat.slice_sag(:,:,3) + negative_full_array_vol3;
% 
% imshow(anat.slice_sag);

redImg(positive3) = 255;
redImg(negative3) = 0;
greenImg(positive3) = 0;
greenImg(negative3) = 0;
blueImg(positive3) = 0;
blueImg(negative3) = 255;

rgbImage = cat(3,redImg,greenImg,blueImg);

imshow(rgbImage);

end
