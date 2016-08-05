function tissue_segmentation(subj)
% Function to segment the tissue based on contrast and create masks - uses
% fslfast - which is actually REALLY SLOW
% 
% *************** REVISION INFO ***************
% Original Creation Date - August 5, 2016
% Author - Hannah Sennik

%  Create the white matter, gray matter, and csf masks using fsl fast
command = ['fast -g data/recon/' subj.name '/' subj.name '_anat_brain.nii'];
status = system(command);

% Reverse the csf mask 
csf = load_nii(['data/recon/' subj.name '/' subj.name '_anat_brain_seg_0.nii']);
nocsf = int32(ones(size(csf.img))) - csf.img;

mask_new_out = load_nii(['data/recon/' subj.name '/' subj.name '_anat_mask.nii']);

new_out = csf;
new_out.img = int32(mask_new_out.img).* nocsf;

% Save the mask to be used in look_at_CVR_data.m
save_nii(new_out,['data/recon/' subj.name '/' subj.name '_nocsf.nii']);

end