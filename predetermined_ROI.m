function predetermined_ROI(source,callbackdata,anat,funct,directories,mp,subj,stim)
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
    add_on = '_raw';
end

if strcmp(handles.predetermined_ROI.String(handles.predetermined_ROI.Value),'None') == 0
    if strcmp(handles.predetermined_ROI.String(handles.predetermined_ROI.Value),'Remove Ventricles and Venosinuses') == 1
        region = 'Remove Ventricles and Venosinuses';
        timeseries = [directories.timeseries '/no_csf_' subj.breathhold '.1D'];
        mask = load_nii(['data/recon/' subj.name '/' subj.name '_anat_brain_seg_0.nii']);
    elseif strcmp(handles.predetermined_ROI.String(handles.predetermined_ROI.Value),'Only White Matter') == 1
        region = 'Only White Matter';
        timeseries = [directories.timeseries '/white_' subj.breathhold '.1D'];
        mask = load_nii(['data/recon/' subj.name '/' subj.name '_anat_brain_seg_2.nii']);
    elseif strcmp(handles.predetermined_ROI.String(handles.predetermined_ROI.Value),'Only Gray Matter') == 1
        region = 'Only Gray Matter';
        timeseries = [directories.timeseries '/gray_' subj.breathhold '.1D'];
        mask = load_nii(['data/recon/' subj.name '/' subj.name '_anat_brain_seg_1.nii']);
    elseif strcmp(handles.predetermined_ROI.String(handles.predetermined_ROI.Value),'Only Cerebellum') == 1 
        region = 'Only Cerebellum';
        timeseries = [directories.metadata '/stim/pf_stim_' subj.proc_rec_sel add_on '.1D'];
        mask = load_nii([directories.flirtdir '/standard_to_anat/cerebellum_to_anat.nii']);
    end 

    if mp.CVRb.Value == 1
        CVRmap(dimension,anat,funct,mp,sliceval,mask.img,gen_file_location,region,subj);    
        
        shift_custom_capability = 5;
        boxcar_name = mp.menu(1).String(mp.menu(1).Value);
        boxcar_name = boxcar_name{1};
        figname = ['Regional Timeseries: ' region];
        pos = [1130,400,600,410];
        funct_space = (['data/processed/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii']);
        funct_space = load_nii([directories.subject '/' funct_space]);
        
        plotfiles(directories,subj,timeseries,stim,pos,figname,shift_custom_capability,region,boxcar_name,funct_space,mp);
    end
end
end

