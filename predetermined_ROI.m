function predetermined_ROI(source,callbackdata,anat,funct,directories,mp,subj)
% Function to display timeseries from a predetermined 3D ROI of a specified
% brain region 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     directories - strings for all relevant directories
%     mp - GUI data
%     subj - subject data (name,date,breathhold)
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 11, 2016
% Author - Hannah Sennik

handles = guidata(source);

global ax_slider_value;
slice = floor(ax_slider_value);
mask_sel = handles.predetermined_ROI.Value;
% mask_sel = get(source,'Value'); % get the mask selection (which brain region)

%  variables to pass in masked_slice to the CVRmap.m function 
sliceval = 0; % don't need this var
gen_file_location = ''; % don't need this var
dimension = 'axial'; % variable to be fed in to the CVRmap function

if mp.menu(2).Value == 2
    add_on = '_processed';
elseif mp.menu(2).Value == 3
    add_on = '_processed_not';
end

if mask_sel ~= 1
    if mask_sel == 2 % Remove Ventricles/Venosinus
        region = 'Remove Ventricles and Venosinuses';
    elseif mask_sel == 3 % White matter
        region = 'Only White Matter';
        timeseries = [directories.flirtdir '/standard_to_functional/whitematter_' subj.breathhold add_on '.1D'];
        mask = load_nii([directories.flirtdir '/standard_to_anat/white_to_anat.nii']);
    elseif mask_sel == 4 % Gray matter
        region = 'Only Gray Matter';
        timeseries = [directories.flirtdir '/standard_to_functional/graymatter_' subj.breathhold add_on '.1D'];
        mask = load_nii([directories.flirtdir '/standard_to_anat/gray_to_anat.nii']);
    elseif mask_sel == 5 % Cerebellum  
        region = 'Only Cerebellum';
        timeseries = [directories.metadata '/stim/pf_stim_' subj.breathhold add_on '.1D'];
        mask = load_nii([directories.flirtdir '/standard_to_anat/cerebellum_to_anat.nii']);
    end

    timeseries_plot = load(timeseries);   

    if mp.CVRb.Value == 1
        CVRmap(dimension,anat,funct,mp,sliceval,mask.img,gen_file_location,region);    
        plotfiles(directories,subj,mp,timeseries_plot,region);
    end
end
end
