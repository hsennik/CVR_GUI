function CVRmap_for_montage(anat,funct,mp,sliceval,gen_file_location,axial,subj)
% Function to save axial slices for a montage 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     funct - 4D functional subject data 
%     mp - GUI data
%     sliceval - slice position 
%     gen_file_location - directory where images for montage should we stored
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 15, 2016
% Author - Hannah Sennik
%   REVISIONS 
%       A - 2016-07-11 - Moved the CVRmap generation to CVRmap.m to avoid
%                        duplication of code


% temp_name = handles.predetermined_ROI.String(handles.predetermined_ROI.Value);
% mask_name = temp_name{1}; % get the mask name

mask_name = axial.predetermined_ROI.String(axial.predetermined_ROI.Value);

if strcmp(mask_name,'') == 0 && strcmp(mask_name,'None') == 0
        if strcmp(mask_name,'Remove Ventricles and Venosinuses') == 1
            mask = load_nii(['data/recon/' subj.name '/' subj.name '_anat_brain_seg_0.nii']);
        elseif strcmp(mask_name,'Only White Matter') == 1
            mask = load_nii(['data/recon/' subj.name '/' subj.name '_anat_brain_seg_2.nii']);
        elseif strcmp(mask_name,'Only Gray Matter') == 1
            mask = load_nii(['data/recon/' subj.name '/' subj.name '_anat_brain_seg_1.nii']);
        elseif strcmp(mask_name,'Only Cerebellum') == 1
            mask = load_nii([directories.flirtdir '/standard_to_anat/cerebellum_to_anat.nii']);
        end
    montage = mask.img;
else 
    montage = 1;
end

dimension = 'axial'; % if montage button is pressed, want montage of axial CVR maps
CVRmap(dimension,anat,funct,mp,sliceval,montage,gen_file_location,mask_name); % call the CVRmap function

end


