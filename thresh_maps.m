% thresh_indices = find (ax_mask < 0.1); % find all indices that contain the values specified
% thresh_vec = reshape (ax_mask, [65536 1]); % turn 3D array into vector 
% thresh_values = thresh_vec(thresh_indices); % place the values at specified array indices in to another array
% 
% positive = find(thresh_values > 0);
% positive_values = thresh_values(positive); 
% positive_full_array = zeros(65536,1);
% positive_full_array(positive) = positive_values + 128; 
% positive_full_array_vol = reshape(positive_full_array,[256 256 1]);
% 
% negative = find(thresh_values < 0);
% negative_values = thresh_values(negative);
% negative_full_array = zeros(65536,1);
% negative_full_array(negative) = negative_values + 128;
% negative_full_array_vol = reshape(negative_full_array,[256 256 1]);
% 
% anat_map_ax(:,:,1) = positive_full_array_vol; % add to anatomical image as overlay with slider to adjust p-value?
% anat_map_ax(:,:,3) = negative_full_array_vol;
% 
% anat_map_ax = rot90(anat_map_ax(anat_xrange,anat_yrange,:));
% anat_map_ax = flip(anat_map_ax,2);
% 
% figure,
% imshow(anat_map_ax);

% CORONAL

% anat_map_cor = double(repmat(imresize(squeeze(anat_map.img(:,anat_slice_y,:)),[anatx anatz]), [1 1 3]));
% cor_mask = double(imresize(squeeze(anat_map.img(:,anat_slice_y,:)),[anatx anatz],'nearest'));
% 
% thresh_indices2 = find (cor_mask < 0.1); % find all indices that contain the values specified
% thresh_vec2 = reshape (cor_mask, [40960 1]); % turn 3D array into vector 
% thresh_values2 = thresh_vec2(thresh_indices2); % place the values at specified array indices in to another array
% 
% positive2 = find(thresh_values2 > 0);
% positive_values2 = thresh_values2(positive2); 
% positive_full_array2 = zeros(40960,1);
% positive_full_array2(positive2) = positive_values2 + 128; 
% positive_full_array_vol2 = reshape(positive_full_array2,[256 160 1]);
% 
% negative2 = find(thresh_values2 < 0);
% negative_values2 = thresh_values2(negative2);
% negative_full_array2 = zeros(40960,1);
% negative_full_array2(negative2) = negative_values2 + 128;
% negative_full_array_vol2 = reshape(negative_full_array2,[256 160 1]);
% 
% anat_map_cor(:,:,1) = positive_full_array_vol2; % add to anatomical image as overlay with slider to adjust p-value?
% anat_map_cor(:,:,3) = negative_full_array_vol2;
% 
% anat_map_cor = imresize(anat_map_cor,[anatx anatz/anat_map.hdr.dime.pixdim(3)]);
% anat_map_cor = rot90(anat_map_cor(anat_xrange,anat_zrange,:));
% anat_map_cor = flip(anat_map_cor,2);
% 
% figure,
% imshow(anat_map_cor);
% 
% % SAGGITAL
% 
% anat_map_sag = double(repmat(imresize(squeeze(anat_map.img(anat_slice_x,:,:)),[anaty anatz]), [1 1 3]));
% %anat_map_sag = rot90(anat_map_sag(anat_yrange,anat_zrange,:));
% 
% sag_mask = double(imresize(squeeze(anat_map.img(anat_slice_x,:,:)),[anaty anatz],'nearest'));
% %sag_mask = rot90(sag_mask(anat_yrange,anat_zrange,:));
% thresh_indices3 = find (sag_mask < 0.1); % find all indices that contain the values specified
% thresh_vec3 = reshape (sag_mask, [40960 1]); % turn 3D array into vector 
% thresh_values3 = thresh_vec3(thresh_indices3); % place the values at specified array indices in to another array
% 
% positive3 = find(thresh_values3 > 0);
% positive_values3 = thresh_values3(positive3); 
% positive_full_array3 = zeros(40960,1);
% positive_full_array3(positive3) = positive_values3 + 128; 
% positive_full_array_vol3 = reshape(positive_full_array3,[256 160 1]);
% 
% negative3 = find(thresh_values3 < 0);
% negative_values3 = thresh_values3(negative3);
% negative_full_array3 = zeros(40960,1);
% negative_full_array3(negative3) = negative_values3 + 128;
% negative_full_array_vol3 = reshape(negative_full_array3,[256 160 1]);
% 
% anat_map_sag(:,:,1) = positive_full_array_vol3; % add to anatomical image as overlay with slider to adjust p-value?
% anat_map_sag(:,:,3) = negative_full_array_vol3;
% 
% anat_map_sag = imresize(anat_map_sag,[anaty anatz/anat.hdr.dime.pixdim(2)]);
% anat_map_sag = rot90(anat_map_sag(anat_yrange,anat_zrange,:));
% anat_map_sag = flip(anat_map_sag,2);
% 
% figure,
% imshow(anat_map_sag);
% 
% 
% % Save the fifth bucket of the functional file (coeff)
% voxel_size = [3.4375 3.4375 5];
% CVR_entire_brain_bucket_5_pf = double(squeeze(CVRmap.img(:,:,:,:,5)));
% nii = make_nii(CVR_entire_brain_bucket_5_pf,voxel_size);
% save_nii(nii,'/data/projects/CVR/metadata/sandbox/CVR_entire_brain_bucket_5_pf.nii'); % CVR_entire_brain_bucket_5 (boxcar)
% 
% % After doing this, would have to use flirt transformation matrix to map this
% % bucket from functional space to anatomical space, then load the output
% % file
% 
% % Load the output file from transformation
% fname_map_anat_space_pf = 'Chan_CVR_bucket_5_pf_anat_space.nii'; % Chan_CVR_bucket_5_anat_space (boxcar)
% anat_map = load_nii([dir_input '/' fname_map_anat_space_pf]);
% 
% % AXIAL
% 
% anat_map_ax_pf = double(repmat(imresize(squeeze(anat_map.img(:,:,anat_slice_z)),[anatx anaty]), [1 1 3]));
% %anat_map_ax = rot90(anat_map_ax(anat_xrange,anat_yrange,:));
% 
% ax_mask_pf = double(imresize(squeeze(anat_map.img(:,:,anat_slice_z)),[anatx anaty],'nearest'));
% %ax_mask = rot90(ax_mask(anat_xrange,anat_yrange,:));
% thresh_indices_pf = find (ax_mask_pf < 8); % find all indices that contain the values specified
% thresh_vec_pf = reshape (ax_mask_pf, [65536 1]); % turn 3D array into vector 
% thresh_values_pf = thresh_vec_pf(thresh_indices_pf); % place the values at specified array indices in to another array
% 
% positive_pf = find(thresh_values_pf > 0);
% positive_values_pf = thresh_values_pf(positive_pf); 
% positive_full_array_pf = zeros(65536,1);
% positive_full_array_pf(positive_pf) = positive_values_pf + 128; 
% positive_full_array_vol_pf = reshape(positive_full_array_pf,[256 256 1]);
% 
% negative_pf = find(thresh_values_pf < 0);
% negative_values_pf = thresh_values_pf(negative_pf);
% negative_full_array_pf = zeros(65536,1);
% negative_full_array_pf(negative_pf) = negative_values_pf + 128;
% negative_full_array_vol_pf = reshape(negative_full_array_pf,[256 256 1]);
% 
% anat_map_ax_pf(:,:,1) = positive_full_array_vol_pf; % add to anatomical image as overlay with slider to adjust p-value?
% anat_map_ax_pf(:,:,3) = negative_full_array_vol_pf;
% 
% anat_map_ax_pf = rot90(anat_map_ax_pf(anat_xrange,anat_yrange,:));
% anat_map_ax_pf = flip(anat_map_ax_pf,2);
% 
% figure,
% imshow(anat_map_ax_pf);
% 
% % CORONAL
% 
% anat_map_cor_pf = double(repmat(imresize(squeeze(anat_map.img(:,anat_slice_y,:)),[anatx anatz]), [1 1 3]));
% %anat_map_cor = rot90(anat_map_cor(anat_xrange,anat_zrange,:));
% 
% cor_mask_pf = double(imresize(squeeze(anat_map.img(:,anat_slice_y,:)),[anatx anatz],'nearest'));
% %cor_mask = rot90(cor_mask(anat_xrange,anat_zrange,:));
% thresh_indices2_pf = find (cor_mask_pf < 8); % find all indices that contain the values specified
% thresh_vec2_pf = reshape (cor_mask_pf, [40960 1]); % turn 3D array into vector 
% thresh_values2_pf = thresh_vec2_pf(thresh_indices2_pf); % place the values at specified array indices in to another array
% 
% positive2_pf = find(thresh_values2_pf > 0);
% positive_values2_pf = thresh_values2_pf(positive2_pf); 
% positive_full_array2_pf = zeros(40960,1);
% positive_full_array2_pf(positive2_pf) = positive_values2_pf + 128; 
% positive_full_array_vol2_pf = reshape(positive_full_array2_pf,[256 160 1]);
% 
% negative2_pf = find(thresh_values2_pf < 0);
% negative_values2_pf = thresh_values2_pf(negative2_pf);
% negative_full_array2_pf = zeros(40960,1);
% negative_full_array2_pf(negative2_pf) = negative_values2_pf + 128;
% negative_full_array_vol2_pf = reshape(negative_full_array2_pf,[256 160 1]);
% 
% anat_map_cor_pf(:,:,1) = positive_full_array_vol2_pf; % add to anatomical image as overlay with slider to adjust p-value?
% anat_map_cor_pf(:,:,3) = negative_full_array_vol2_pf;
% 
% anat_map_cor_pf = imresize(anat_map_cor_pf,[anatx anatz/anat_map.hdr.dime.pixdim(3)]);
% anat_map_cor_pf = rot90(anat_map_cor_pf(anat_xrange,anat_zrange,:));
% anat_map_cor_pf = flip(anat_map_cor_pf,2);
% 
% figure,
% imshow(anat_map_cor_pf);
% 
% % SAGGITAL
% 
% anat_map_sag_pf = double(repmat(imresize(squeeze(anat_map.img(anat_slice_x,:,:)),[anaty anatz]), [1 1 3]));
% %anat_map_sag = rot90(anat_map_sag(anat_yrange,anat_zrange,:));
% 
% sag_mask_pf = double(imresize(squeeze(anat_map.img(anat_slice_x,:,:)),[anaty anatz],'nearest'));
% %sag_mask = rot90(sag_mask(anat_yrange,anat_zrange,:));
% thresh_indices3_pf = find (sag_mask_pf < 8); % find all indices that contain the values specified
% thresh_vec3_pf = reshape (sag_mask_pf, [40960 1]); % turn 3D array into vector 
% thresh_values3_pf = thresh_vec3_pf(thresh_indices3_pf); % place the values at specified array indices in to another array
% 
% positive3_pf = find(thresh_values3_pf > 0);
% positive_values3_pf = thresh_values3_pf(positive3_pf); 
% positive_full_array3_pf = zeros(40960,1);
% positive_full_array3_pf(positive3_pf) = positive_values3_pf + 128; 
% positive_full_array_vol3_pf = reshape(positive_full_array3_pf,[256 160 1]);
% 
% negative3_pf = find(thresh_values3_pf < 0);
% negative_values3_pf = thresh_values3_pf(negative3_pf);
% negative_full_array3_pf = zeros(40960,1);
% negative_full_array3_pf(negative3_pf) = negative_values3_pf + 128;
% negative_full_array_vol3_pf = reshape(negative_full_array3_pf,[256 160 1]);
% 
% anat_map_sag_pf(:,:,1) = positive_full_array_vol3_pf; % add to anatomical image as overlay with slider to adjust p-value?
% anat_map_sag_pf(:,:,3) = negative_full_array_vol3_pf;
% 
% anat_map_sag_pf = imresize(anat_map_sag_pf,[anaty anatz/anat.hdr.dime.pixdim(2)]);
% anat_map_sag_pf = rot90(anat_map_sag_pf(anat_yrange,anat_zrange,:));
% anat_map_sag_pf = flip(anat_map_sag_pf,2);
% 
% figure,
% imshow(anat_map_sag_pf);
