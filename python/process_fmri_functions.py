#!/usr/bin/env python
#
#  process_fmri_functions.py
#
# Contains python wrappers for various commonly used preprocessing steps
#    Packages
#       AFNI
#       FSL
#    Filetypes
#       .nii
#
# NOTES
#      Initial Creation
#
#   AUTHOR - Wayne Lee
#   Created - Apr 3, 2012
#   REVISIONS 
#       2012-04-03 - WL - First Created and checked into respository
#       2013-01-08 - BM - Added fslval function to check # of TRs in a .nii
#                       - also had to update recon_epi to do above task
#                       - added cmd_nz_dcm, cmd_nt_dcm to find # of slices and TRs from dicoms


from numpy import *
import os
import string
import shlex, subprocess

program_name = 'process_fmri_functions.py'

#*************************************************************************************
# FUNCTIONS - GENERAL

# Subprocess call
def run_cmd(sys_cmd, debug):
# one line call to output system command and control debug state
# Debug = -1 - CLOBBER STATE (overwrites files)
# Debug = 0 - basic run state, no overwriting
# Debug = 1 - basic debug state, print function calls
# Debug = 2 - short debug state, don't print function calls
    if debug < 2:
        print "> " + sys_cmd
    if debug < 1:
        p = subprocess.Popen(sys_cmd, stdout = subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        output, errors = p.communicate()
        return output, errors
        # os.system(sys_cmd)
    else:
        return '',''        

# Check if file exists before running
def check_and_run(sys_cmd, dir_out, prefix_out, file_type, debug):
# Debug = -1 - CLOBBER STATE (overwrites files)
# Debug = 0 - basic run state
# Debug = 1 - basic debug state, print function calls
# Debug = 2 - short debug state, don't print function calls

    # if file exists
    if os.path.exists( '%s/%s%s' % (dir_out, prefix_out, file_type)):
        # Check if it's clobbering time
        if debug == -1 :    
            print "Overwriting file - %s/%s%s" % (dir_out, prefix_out, file_type)
            clobber_cmd = 'rm %s/%s%s' % (dir_out, prefix_out, file_type)
            output, errors = run_cmd(clobber_cmd, debug)
            
            output, errors = run_cmd(sys_cmd, debug)
            return output, errors
        else:
            print '> %s > Output file already exists ' % (sys_cmd,)
            return '',''
    else:     # file doesn't exist
        output, errors = run_cmd(sys_cmd, debug)
        # Check after program run for output file's existance if not in debug mode
        if (debug < 1) and (not os.path.exists( '%s/%s%s' % (dir_out, prefix_out, file_type))):
            print 'ERROR - Function call failed - %s' % (sys_cmd,) 
            print 'Function call output:'
            print output, errors
            # raise SystemExit, 'ERROR - Function call failed - %s' % (sys_cmd,) 
        return output, errors

def check_dir(dir, debug):
    if not os.path.exists(dir):
        run_cmd('mkdir -p ' + dir, debug)
    else:
        if debug <2:
            print '> mkdir ' + dir + ' > Directory already exists'
    return dir
    
#*************************************************************************************
#   FUNCTIONS - AFNI

# AFNI - recon  EPI (4D) data 
def cmd_afni_to3d_epi(dir_out, prefix_out, order, nz, nt, tr, seqdir, dir_in, file_type, dcm_type, debug):
# to3d -session ./ -prefix IS_r1.nii -time:zt 11 24 5s seqplus /data2/wayne/asl/mpld/oct26_invivo/8167_10262010/005/*
    if dcm_type == 'single':    # only a single dcm
        dir_dcm = '/*'
        #dir_dcm = '/*IMA'
    elif dcm_type == 'dir':                        # dicom directory
        dir_dcm = '/*/*'
    elif dcm_type == '4Ddcm':
        dir_dcm = '' 
    else: 
        raise SystemExit, 'need to specify dcm_type fo recon'
    print '** Reconstructing data - %s' % (prefix_out,)
    if order =='tz':
        t_1st = nt
        t_2nd = nz
    else:
        t_1st = nz
        t_2nd = nt
    
    sys_cmd = 'to3d -session %s -prefix %s%s -time:%s %s %s %ss %s %s%s' % \
        (dir_out, prefix_out, file_type, order, t_1st, t_2nd, tr, seqdir, dir_in, dir_dcm)
    check_and_run(sys_cmd, dir_out, prefix_out, file_type, debug)
    return prefix_out
        
# AFNI - recon anatomical (3D) data     
def cmd_afni_to3d_anat(dir_out, prefix_out, dir_in, file_type, dcm_type, debug):
# to3d -session ./ -prefix IS_r1.nii  /data2/wayne/asl/mpld/oct26_invivo/8167_10262010/005/*
    print '** Reconstructing data - %s' % (prefix_out,)
    if dcm_type == 'single':    # only a single dcm
        dir_dcm = '/*'
        #dir_dcm = '/*IMA'
    elif dcm_type == 'dir':                        # dicom directory
        dir_dcm = '/*/*'
    elif dcm_type == '4Ddcm':
        dir_dcm = ''
    else: 
        raise SystemExit, 'need to specify dcm_type fo recon'
    print '** Reconstructing data - %s' % (prefix_out,)
    sys_cmd = 'to3d -session %s -prefix %s%s %s%s' % \
        (dir_out, prefix_out, file_type, dir_in, dir_dcm)
    check_and_run(sys_cmd, dir_out, prefix_out, file_type, debug)
    return prefix_out

# AFNI - skull strip anatomical image
def cmd_afni_skullstrip(dir_in, file_in, dir_out, prefix_out, file_type, debug):
# 3dSkullStrip -orig_vol -input anat.nii -prefix anat_brain.nii
    prefix_brain = '%s_brain' % (prefix_out,)
    sys_cmd = '3dSkullStrip -orig_vol -input %s/%s%s -prefix %s/%s%s' % \
        (dir_in, file_in, file_type, dir_out, prefix_brain, file_type)
    check_and_run(sys_cmd, dir_out, prefix_brain, file_type, debug)

    prefix_mask = '%s_mask' % (prefix_out,)
    sys_cmd = "3dcalc -float -a %s/%s%s -prefix %s/%s%s -expr 'ispositive(a)'" % \
        (dir_out, prefix_brain, file_type, dir_out, prefix_mask, file_type)
    check_and_run(sys_cmd, dir_out, prefix_mask, file_type, debug)

    return prefix_brain, prefix_mask

# AFNI - brain mask EPI image
def cmd_afni_automask(dir_in, file_in, dir_out, prefix_out, file_type,debug):
# Create brain mask for EPI images
# 3dAutomask -apply_prefix IS_brain.nii -prefix IS_mask.nii IS_r1.nii'[2]'
# Split into two calls (3dAutomask and 3dCalc) to simplify file checking
    prefix_mask = '%s_mask' % (prefix_out,)
    print '** Masking dataset - %s' % (prefix_mask,)
    sys_cmd = '3dAutomask -q -prefix %s/%s%s %s/%s%s' % \
        (dir_out, prefix_mask, file_type, dir_in, file_in, file_type)
    check_and_run(sys_cmd, dir_out, prefix_mask, file_type, debug)

    return prefix_mask

# AFNI - Trim dataset (drop scans at beginning and end)
def cmd_afni_trim(dir_in, prefix_in, first_vol, last_vol, dir_out, prefix_out, file_type, debug):
# 3dcalc -a data.nii[4..10] -prefix dir/data_trim.nii-expr 'a'
    prefix_trim = '%s_trim' % (prefix_out,)
    print '** Trimming dataset - %s' % (prefix_trim,)
    sys_cmd = "3dcalc -float -a %s/%s%s'[%d..%d]' -prefix %s/%s%s -expr 'a'" % \
        (dir_in, prefix_in, file_type, first_vol, last_vol, dir_out, prefix_trim, file_type)
    check_and_run(sys_cmd, dir_out, prefix_trim, file_type, debug)
    return prefix_trim

# AFNI - Slice timing correction
def cmd_afni_3dTshift(dir_in, prefix_in, ignore, dir_out, prefix_out, file_type, debug):
# 3dTshift -prefix dir/data_ts -ignore 3  data_in
    prefix_ts = '%s_ts' % (prefix_out,)
    print '** Slice Timing Correction - %s' % (prefix_ts,)
    sys_cmd = '3dTshift -prefix %s/%s%s -ignore %d %s/%s%s' % \
        (dir_in, prefix_ts, file_type, ignore, dir_out, prefix_in, file_type)
    check_and_run(sys_cmd, dir_out, prefix_ts, file_type, debug)
    return prefix_ts

# AFNI - Motion Correction 3D
def cmd_afni_3dvolreg(dir_in, file_in, mc_base, dir_out, prefix_out, file_type, debug):
# 3dvolreg -prefix SI_r1_mc -base 2 -1Dfile SI_r1_mc.1D -maxdisp -maxdisp1D SI_r1_mc_MD.1D SI_r1.nii
    prefix_mc = '%s_mc' % (prefix_out,)
    print '** Motion Correction - %s' % (prefix_mc,)
    sys_cmd = '3dvolreg -prefix %s/%s%s -base %d \
        -1Dfile %s/%s.1D -maxdisp -maxdisp1D %s/%s_MD.1D %s/%s%s' % \
        (dir_out, prefix_mc, file_type, mc_base, \
            dir_out, prefix_mc, dir_out, prefix_mc, dir_in, file_in, file_type)
    check_and_run(sys_cmd, dir_out, prefix_mc, file_type, debug)
    return prefix_mc

# AFNI - Motion Correction 2D
def cmd_afni_2dImReg(dir_in, file_in, file_base, dir_out, prefix_out, file_type, debug):
# 2dImReg -prefix SS_50_mc -basefile SS_50.nii -dprefix SS_50_mc.1D -dmm -input SS_50.nii
    prefix_mc = '%s_mc' % (prefix_out,)
    sys_cmd = '2dImReg -prefix %s/%s%s -basefile %s/%s%s -base 2 \
        -dprefix %s/%s.1D -dmm -input %s/%s%s' % \
        (dir_out, prefix_mc, file_type, dir_in, file_base, file_type, \
            dir_out, prefix_mc, dir_in, file_in, file_type)
    check_and_run(sys_cmd, dir_out, prefix_mc, file_type, debug)
    return prefix_mc
    
# AFNI - Basic mathematical operation on two images (+, -, *, /)
def cmd_afni_basic_calc(dir_A, file_A, dir_B, file_B, dir_out, prefix_out, operation, file_type, debug):
    sys_cmd = "3dcalc -float -a %s/%s%s -b %s/%s%s -prefix %s/%s%s -expr 'a%sb'" % \
        (dir_A, file_A, file_type, dir_B, file_B, file_type, dir_out, prefix_out, file_type, operation)
    check_and_run(sys_cmd, dir_out, prefix_out, file_type, debug)
    return prefix_out

# AFNI - Extract a single bucket from a 4D dataset
def cmd_afni_extract_buck(dir_in, file_in, buck_num, dir_out, prefix_out, file_type, debug):
    sys_cmd = "3dcalc -float -a '%s/%s%s'[%d] -prefix %s/%s%s -expr 'a'" % \
        (dir_in, file_in, file_type, buck_num, dir_out, prefix_out, file_type)
    check_and_run(sys_cmd, dir_out, prefix_out, file_type, debug)
    return prefix_out

    
# AFNI - Threshold a single bucket from a 4D dataset
def cmd_afni_thresh(dir_in, file_in, buck_num, dir_out, prefix_out, threshold, file_type, debug):
    sys_cmd = "3dcalc -float -a '%s/%s%s'[%d] -prefix %s/%s%s -expr 'ispositive(a-%s)'" % \
        (dir_in, file_in, file_type, buck_num, dir_out, prefix_out, file_type, threshold)
    check_and_run(sys_cmd, dir_out, prefix_out, file_type, debug)
    return prefix_out

# AFNI - Create mean image across the 4th dimension
def cmd_afni_create_mean(dir_in, prefix_in, dir_out, file_type, debug):
    prefix_out = '%s_mean' % (prefix_in)
    print '** Calcualting mean dataset - %s' % (prefix_out,)
    sys_cmd = '3dTstat -prefix %s/%s%s %s/%s%s' % \
        (dir_out, prefix_out, file_type, dir_in, prefix_in, file_type)
    check_and_run(sys_cmd, dir_out, prefix_out, file_type, debug)
    return prefix_out

# AFNI - Calculate average signal over the 4th dimension based on some mask
def cmd_afni_bandpass(dir_in, prefix_in, dir_out, prefix_out, low, high, file_type, debug):
# 3dBandpass -quiet -nodetrend -input <>  -band <> <> -prefix <>
    prefix_bp = '%s_bp' % (prefix_out,)
    print '** Bandpass filtering dataset - %s' % (prefix_bp,)
    sys_cmd = '3dBandpass -nodetrend -input %s/%s%s -prefix %s/%s%s %4.2f %4.2f ' % \
        (dir_in, prefix_in, file_type, dir_out, prefix_bp, file_type, low, high)
    check_and_run(sys_cmd, dir_out, prefix_bp, file_type, debug)
    return prefix_bp

# AFNI - Calculate average signal over the 4th dimension based on some mask
def cmd_afni_maskave(dir_fmri, prefix_fmri, dir_mask, file_mask, dir_out, prefix_out, file_type, debug):
# 3dmaskave -q -mask ROI_csf_Locchorn+orig Resting.reg.bl4.pc+orig > ROI_csf_Locchorn.1D
    sys_cmd = '3dmaskave -q -mask %s/%s%s %s/%s%s > %s/%s' % \
        (dir_mask, file_mask, file_type, dir_fmri, prefix_fmri, file_type, dir_out, prefix_out)
    check_and_run(sys_cmd, dir_out, prefix_out, '', debug)
    return prefix_out

# AFNI - Smooth dataset using AFNI's 3dmerge (3D or 2D)
def cmd_afni_smooth(dim, fwhm, dir_out, dir_in, prefix_in, dir_mask, prefix_mask, file_type, debug):
# Select 2D or 3D smoothing with 'dim' variable
# If no mask, then leave dir_mask and prefix_mask blank ie. ''
# For now, isotropic smoothing 
# Smoothing radius is set to 1.3*FWHM

# BASIC Command - 3D smoothing
#   3dmerge -1fmask Resting.mask+orig -1filter_expr fwhm*1.3 'exp(-r*r/(0.36067*fwhm*fwhm))*iszero(k)'
#           -prefix Resting.reg.bl4 -doall Resting.reg+orig
# 2D smoothing option adds *iszero(k) to the filter expression
#   -1filter_expr fwhm*1.3 'exp(-r*r/(0.36067*fwhm*fwhm))*iszero(k)'
    smooth_window = 1.3*fwhm
    smooth_denom = 0.36067*fwhm*fwhm
    if dim=='3D':
        smooth_expr = ''
    elif dim=='2D':
        smooth_expr = '*iszero(k)'
    else:
        raise SystemExit, 'ERROR - cmd_afni_smooth - Invalid smoothing dimension: %s [Valid = 2D, 3D]' \
            % (dim,) 

    if dir_mask == '' and prefix_mask == '':
        mask_option = ''
    else:
        mask_option = '-1fmask %s/%s%s'  % (dir_mask, prefix_mask, file_type)
            
    prefix_out = '%s_%ssm%d' % (prefix_in, dim, fwhm)
    print '** Smoothing dataset - %s' % (prefix_out,)
    sys_cmd = "3dmerge %s -1filter_expr %f 'exp(-r*r/(%f))%s' \
        -prefix %s/%s%s -doall %s/%s%s" % \
        (mask_option, smooth_window, smooth_denom, smooth_expr, \
        dir_out, prefix_out, file_type, dir_in, prefix_in, file_type)
    check_and_run(sys_cmd, dir_out, prefix_out, file_type, debug)
    return prefix_out
    
    
# AFNI - 3dtcat - datasets
def cmd_afni_3dTcat(name_list, dir_out, name_out, file_type, debug):
    # name_list must be a list including the full file path of each file to be concatenated
    
    all_names = ''
    for name in name_list:
        all_names = all_names + name + ' '
    
    sys_cmd = '3dTcat -session %s -prefix %s%s %s'  %\
        (dir_out, name_out, file_type, all_names)
    
    check_and_run(sys_cmd, dir_out, name_out, file_type, debug)
    
    
#*************************************************************************************
#   FUNCTIONS - FSL

# FSL - Calculate XFM (flirt)
def cmd_fsl_flirt_calc(dir_in, file_in, dir_ref, file_ref, num_dof, dir_out, file_omat, file_type, debug):
# flirt -in anat_brain.nii -ref SI_brain.nii -interp sinc -dof 7 -omat anat_to_SI.xfm
    file_out = '%s.xfm' % (file_omat,)
    sys_cmd = 'flirt -in %s/%s%s -ref %s/%s%s -interp sinc -dof %s \
        -searchrx -30 30 -searchry -30 30 -searchrz -30 30 -omat %s/%s' % \
        (dir_in, file_in, file_type, dir_ref, file_ref, file_type, num_dof, dir_out, file_out)
    check_and_run(sys_cmd, dir_out, file_out, '', debug)
    return file_out

# FSL - Apply XFM to 3D data (flirt)
def cmd_fsl_flirt_apply(dir_in, file_in, dir_ref, file_ref, dir_out, file_out, dir_omat, file_omat, file_type, interp, debug):
# flirt -in anat.nii -ref IS_brain.nii -interp sinc -applyxfm -init anat_to_IS.xfm -out anat_IS.nii
    sys_cmd = 'flirt -in %s/%s%s -ref %s/%s%s -interp %s -applyxfm -init %s/%s -out %s/%s%s' % \
        (dir_in, file_in, file_type, dir_ref, file_ref, file_type, interp, \
            dir_omat, file_omat, dir_out, file_out, file_type)
    check_and_run(sys_cmd, dir_out, file_out, file_type, debug)
    return file_out

# FSL - Apply XFM to 4D data (flirt)
def cmd_fsl_flirt_applyxfm4D(dir_in, file_in, dir_ref, file_ref, dir_out, file_out, dir_omat, file_omat, file_type, debug):
# applyxfm4D <input volume> <ref volume> <output volume> <transformation matrix file/[dir]> -singlematrix
    sys_cmd = 'applyxfm4D %s/%s%s %s/%s%s %s/%s%s %s/%s -singlematrix' % \
        (dir_in, file_in, file_type, dir_ref, file_ref, file_type, \
            dir_out, file_out, file_type, dir_omat, file_omat)
    check_and_run(sys_cmd, dir_out, file_out, file_type, debug)
    return file_out
        
# FSL - Calculate Deformation field (fnirt)
def cmd_fsl_fnirt_calc(dir_in, file_in, dir_affine, file_affine, dir_out, file_warp, config, file_type, debug):
# /usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz
# fnirt --in=%s/%s_anat_brain.nii --aff=%s/%s_anat_to_mni.xfm --cout=%s/%s_anat_to_mni_fnirt --config=T1_2_MNI152_2mm --ref= --refmask
# CHECK FILE OUTPUT TYPE
    sys_cmd = 'fnirt --in=%s/%s%s --aff=%s/%s --cout=%s/%s --config=%s' % \
        (dir_in, file_in, file_type, dir_affine, file_affine, dir_out, file_warp, config)
    check_and_run(sys_cmd, dir_out, file_warp, file_type, debug)
    return file_warp
    
# FSL - Apply deformation field (fnirt) - EPI
def cmd_fsl_fnirt_apply_epi(dir_in, file_in, pre_post, dir_affine, file_affine, dir_warp, file_warp, dir_ref, file_ref, dir_out, file_out, file_type, debug):
# applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=my_functional --warp=my_nonlinear_transf --premat=func2struct.mat --out=my_warped_functional
    sys_cmd = 'applywarp --ref=%s/%s --in=%s/%s%s --warp=%s/%s --%smat=%s/%s --out=%s/%s%s' % \
        (dir_ref, file_ref, dir_in, file_in, file_type, dir_warp, file_warp, pre_post, \
            dir_affine, file_affine, dir_out, file_out, file_type)
    check_and_run(sys_cmd, dir_out, file_out, file_type, debug)
    return file_out

# FSL - Apply deformation field (fnirt) - ANAT
def cmd_fsl_fnirt_apply_anat(dir_in, file_in, dir_warp, file_warp, dir_ref, file_ref, dir_out, file_out, file_type, debug):
# applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=my_structural --warp=my_nonlinear_transf --out=my_warped_structural
    sys_cmd = 'applywarp --ref=%s/%s --in=%s/%s%s --warp=%s/%s%s --out=%s/%s' % \
        (dir_ref, file_ref, dir_in, file_in, file_type, dir_warp, file_warp, file_type,  \
            dir_out, file_out)
    check_and_run(sys_cmd, dir_out, file_out, file_type, debug)
    return file_out

    # FSL - Combining transformation matrices
def cmd_fsl_convert_xfm(dir, omat_out_A_C, omat_A_B, omat_B_C, debug):
# convert_xfm -omat mni_to_IS.xfm -concat anat_to_IS.xfm mni_to_anat.xfm
    sys_cmd = 'convert_xfm -omat %s/%s -concat %s/%s %s/%s' % \
        (dir, omat_out_A_C, dir, omat_B_C, dir, omat_A_B)
    check_and_run(sys_cmd, dir, omat_out_A_C, '', debug)
    return omat_out_A_C
    
# FSL - Reorient image matrix into MNI space (not registration)
def cmd_fsl_reorient2std(dir, file_in, file_type, debug):
# fslreorient2std input_image output_image
    sys_cmd = 'fslreorient2std %s/%s%s %s/%s_temp%s' % \
        (dir, file_in, file_type, dir, file_in, file_type)
    run_cmd(sys_cmd, debug)
    sys_cmd = 'mv %s/%s_temp%s %s/%s%s ' % \
        (dir, file_in, file_type, dir, file_in, file_type)
    run_cmd(sys_cmd, debug)
    
# FSL - find # of TRs from a .nii file
def cmd_fslval(dir, file_in, file_type, dim, debug):
    
    print '** Finding the number of slices **'
    sys_cmd = 'fslval %s/%s%s dim%s > %s/temp.txt' % \
        (dir, file_in, file_type, dim, dir)
    run_cmd(sys_cmd, debug)
    
    with open(dir + '/temp.txt') as f:
        num_TR = f.readline()
    
    # remove the last char in the string bc it's a return character
    num_TR = num_TR[:-1]
    num_TR = num_TR[:-1]
    print '** The # of TRs is: ' + num_TR
        
    sys_cmd = 'rm %s/temp.txt' % (dir)
    run_cmd(sys_cmd, debug)
    
    return num_TR

# find number of slices from a dicom header    
def cmd_nz_dcm(dir_in, dir_out, epi_info, debug):
    
    # this is not a very robust way to do this, but it works for now
    print '** Finding the number of slices **'
    sys_cmd = 'dcmdump %s/%s | grep "(0019,100a)" > %s/temp.txt' % \
        (dir_in, epi_info.fmri_1stfile, dir_out)
    run_cmd(sys_cmd, debug)
    
    with open(dir_out + '/temp.txt') as f:
        num_z_output = f.readline()
    
    num_z_output = num_z_output.split(' ')
    num_z = num_z_output[2]
    print '** The # of slices is: ' + num_z
        
    sys_cmd = 'rm %s/temp.txt' % (dir_out)
    run_cmd(sys_cmd, debug)
    
    return num_z
    
# find number of TRs from a dicom directory 
def cmd_nt_dcm(dir_in, dir_out, epi_info, debug):
    
    print '** Finding the number of TRs **'
    sys_cmd = 'ls -1 %s/*.%s | wc -l > %s/temp.txt' % \
        (dir_in, epi_info.dcm_filename, dir_out)
    run_cmd(sys_cmd, debug)
    
    with open(dir_out + '/temp.txt') as f:
        num_TR = f.readline()
    
    # remove the last char in the string bc it's a return character
    num_TR = num_TR[:-1]
    print '** The # of TRs is: ' + num_TR
    
    sys_cmd = 'rm %s/temp.txt' % (dir_out)
    run_cmd(sys_cmd, debug)
    
    return num_TR
        
  
#*************************************************************************************
#   FUNCTIONS - CONVERSION TOOLS    

# Conversion - nii<->afni
def cmd_niiORafni(dir_in, file_in, file_type_in, dir_out, file_type_out, debug):
# 3dcalc -a anat_IS.nii -prefix matlab/anat_IS -expr 'a'
    sys_cmd = "3dcalc -float -a %s/%s%s -prefix %s/%s%s -expr 'a'" % \
        (dir_in, file_in, file_type_in, ir_out, file_in, file_type_out)
    check_and_run(sys_cmd, dir_out, file_in, file_type_out, debug)

# Conversion - dcm -> nii
def cmd_dcm2nii(dir_out, prefix_out, num_series, dir_in, dir_temp, debug):
# dcm2nii -d n -f n -g n -o ./ -p n  /data2/wayne/asl/rr_manuscript/data/m3/8671_03132011/041
    sys_cmd = 'dcm2nii -d n -f n -g n -o %s -p n %s' % \
        (dir_temp, dir_in)
    run_cmd(sys_cmd, debug)

    sys_cmd = 'mv %s/*%0.3d*.nii %s/%s.nii' % \
        (dir_temp, num_series, dir_out, prefix_out)
    check_and_run(sys_cmd, dir_out, prefix_out, '.nii', debug)

#*************************************************************************************
#   FUNCTIONS - Wrappers to facilitate function calls

# General Thresholds a 1D time series based on some value (> thresh = 0, < thresh = 1)
def cmd_censor(dir_in, MD_in, dir_out, file_out, thresh, debug):
    print '** Create censor file - %s' % (file_out,)
    sys_cmd = 'outToCensor.pl %s/%s %s/%s %4.2f' % \
        (dir_in, MD_in, dir_out, file_out, thresh)
    if os.path.exists( '%s/%s' % (dir_in, MD_in)):
        check_and_run(sys_cmd, dir_out, file_out, '', debug)
        return file_out
    else:
        print 'ERROR - Function call failed - %s' % (sys_cmd,) 
        print 'Input file does not exist - %s/%s' %(dir_in, MD_in)
        return file_out
   
# General - Reconstruction of structural images
def recon_gen(subj, dir_in, dir_out, type, file_type, dcm_type, debug):
    prefix_out = '%s_%s' % (subj, type)
    cmd_afni_to3d_anat(dir_out, prefix_out , dir_in, file_type, dcm_type, debug )
    if file_type == '.nii':
        cmd_fsl_reorient2std(dir_out, prefix_out, file_type, debug)
    return prefix_out

# General - Reconstruction of EPI images
def recon_epi(subj, dir_in, dir_out, epi_type, file_type, epi_info, debug):
    prefix_out = '%s_%s' % (subj, epi_type)
    if epi_info.fmri_nt==-1:
        num_TR = cmd_nt_dcm(dir_in, dir_out, epi_info, debug)
    else:
        num_TR = epi_info.fmri_nt
        
    if epi_info.fmri_nz==-1:
        num_z = cmd_nz_dcm(dir_in, dir_out, epi_info, debug)
    else:
        num_z = epi_info.fmri_nz
    
    cmd_afni_to3d_epi(dir_out, prefix_out, epi_info.fmri_order, num_z, num_TR, epi_info.fmri_TR \
        , epi_info.fmri_sliceorder, dir_in, file_type, epi_info.dcm_type, debug)
    if file_type == '.nii':
        cmd_fsl_reorient2std(dir_out, prefix_out, file_type, debug)
    return prefix_out

# General - Calculate baseline average
def calc_base_avg(dir_in, prefix_in, dir_censor, censor_in, dir_out, prefix_out, file_type, debug):
# Need to load in censor file and determine % of baseline vs total number of volumes
    
    prefix_censored = '%s_basecens' % (prefix_out,)
    print '** Censoring active dataset - %s' % (prefix_censored,)

    if not debug:
        data_censor = loadtxt(dir_censor + '/' + censor_in)
        count_censored = sum(data_censor)
        count_total = len(data_censor)
    else:
        count_censored = 1
        count_total = 1
    
    sys_cmd = "3dcalc -float -a %s/%s%s -b %s/%s -prefix %s/%s%s -expr 'a*b/%d*%d'" % \
        (dir_in, prefix_in, file_type, dir_censor, censor_in, \
            dir_out, prefix_censored, file_type, count_censored, count_total)
    check_and_run(sys_cmd, dir_out, prefix_censored , file_type, debug)

    prefix_censored_mean = cmd_afni_create_mean(dir_out, prefix_censored, dir_out, file_type, debug)

    return prefix_censored_mean

    
# General - Orthogonalize data with respect to some signals
def create_3dDecon(dir_in, fmri_in, TR, dir_out, fmri_out, dir_censor, file_censor, dir_mask, \
    prefix_mask, dir_roi, file_roi, list_roi, dir_motion, file_motion, num_motion, polort, \
    dir_stim, stim_prefix, list_stim, stim_model,  
    glt_enable, glt_dir, glt_labels, file_type, debug):
    
    
    
    # Check if censor is provided
    if file_censor != '' and dir_censor !='':
        cmd_censor = '-censor %s/%s' % (dir_censor, file_censor)
    else:
        cmd_censor = ''
    # Check if mask is provided
    if prefix_mask != '' and dir_mask !='':
        cmd_mask = '-mask %s/%s%s' % (dir_mask, prefix_mask , file_type)
    else:
        cmd_mask = ''

    prefix_bucket = fmri_out + '_glm_buck'
    prefix_errts = fmri_out + '_glm_errts'
    print '** 3dDeconvolve - %s, %s' % (prefix_bucket, prefix_errts)
    num_stimts = num_motion + len(list_roi) + len(list_stim)
    
    sys_cmd = "3dDeconvolve -goforit 1 -float -input %s/%s%s -bucket %s/%s%s -force_TR %4.2f\
        -errts %s/%s%s %s %s \
        -polort %s -tout -rout -fout -bout -x1D %s/%s.1D -num_stimts %d" \
        % (dir_in, fmri_in, file_type, dir_out, prefix_bucket, file_type, TR, \
            dir_out, prefix_errts, file_type, cmd_censor, cmd_mask, \
            polort, dir_out, prefix_bucket, num_stimts)
    count = 0
    # Adding motion parameters to be regressed
    for count_mot in range(num_motion):
        count = count + 1
        if num_motion == 1:
            name_roi = 'MD'
        else:
            if count == 0:
                name_roi = 'roll'
            if count == 1:
                name_roi = 'pitch'
            if count == 2:
                name_roi = 'yaw'
            if count == 3:
                name_roi = 'dS'
            if count == 4:
                name_roi = 'dL'
            if count == 5:
                name_roi = 'dP'                
        sys_cmd = "%s -stim_file %s %s/%s'[%s]' -stim_base %d -stim_label %d %s" \
            % (sys_cmd, count, dir_motion, file_motion, count_mot, count, count, name_roi)
    
    # Adding roi 1D parameters to be regressed
    count_roi = -1;
    for name_roi in list_roi:
        count = count + 1
        count_roi = count_roi + 1;
        sys_cmd = "%s -stim_file %s %s/%s'[%s]' -stim_base %d -stim_label %d %s" \
            % (sys_cmd, count, dir_roi, file_roi, count_roi, count, count, name_roi)

    # Adding Stimuli
    count_stim = -1;
    for name_stim in list_stim:
        count = count + 1
        count_stim = count_stim + 1;
        ID_stim = stim_prefix.split('/')[-1] + name_stim
        
        if stim_model == '1D':
            sys_cmd = "%s -stim_file %s %s/%s%s -stim_label %d %s" \
                % (sys_cmd, count, dir_stim, stim_prefix, name_stim, count, ID_stim)
        else:        
            sys_cmd = "%s -stim_times %s %s/%s%s '%s' -stim_label %d %s" \
                % (sys_cmd, count, dir_stim, stim_prefix, name_stim, stim_model, count, ID_stim)

            
    # Adding GLTs
    count_glts = -1;
    if glt_enable>0:
        glt_cmd = ''      # separate command string because we need to check how many GLTs are present
        label_count = 0
        glt_list = glt_labels.split(',')
        for label in glt_list:
            label_count = label_count + 1
            label_path = "%s/GLT_%s.txt" % (glt_dir, label)
            if not os.path.exists(label_path):
                raise SystemExit, 'ERROR - GLT File - File not found: %s' % (label_path,) 
            glt_cmd = "%s -glt 1 %s -glt_label %d %s " \
                % (glt_cmd, label_path, label_count, label)
        sys_cmd = "%s -num_glt %s %s " % (sys_cmd, label_count, glt_cmd)
                
                
    
    # Fit everything!
    check_and_run(sys_cmd, dir_out, prefix_errts, file_type, debug)
    
    return prefix_bucket, prefix_errts

# General - Generate 1D files for ROIs
def create_1D(dir_roi, prefix_roi, list_roi, dir_data, prefix_data, dir_out, prefix_1D_table, file_type, debug):
    print '** Calculating 1D files for ROIs [%s%s] - %s' % \
        (prefix_roi, file_type, prefix_1D_table)
    count_roi = -1
    for name_roi in list_roi:
        print 'TESTER ' + name_roi
        count_roi = count_roi + 1
        sys_cmd =  "3dmaskave -mask %s/%s%s -mindex %d -quiet %s/%s%s " % \
            (dir_roi, prefix_roi, file_type, count_roi, dir_data, prefix_data, file_type)
        output, errors = check_and_run(sys_cmd, dir_out, prefix_1D_table,'blargh', debug)    
        nums = array(output.split(), dtype = float)
        if count_roi == 0:
            array_1D = nums
        else:
            array_1D = column_stack((array_1D,nums))
    
    if not debug: 
        savetxt(dir_out + '/' + prefix_1D_table, array_1D,fmt='%6.5f')
        
    return prefix_1D_table
        
# General - Calculating voxel wise correlation values 
def correlate_fMRI(dir_in, fmri_in, TR, dir_out, dir_censor, file_censor, dir_mask, prefix_mask, dir_1D, gm_rois, file_type, debug):
    print '** ROI Correlations'
    for name_roi in gm_rois:
        prefix_bucket = fmri_in + '_' + name_roi
        file_1D = "roi_%s.1D" % (name_roi,)
        sys_cmd = "3dDeconvolve -float -input %s/%s%s -bucket %s/%s%s -force_TR %4.2f\
            -censor %s/%s -mask %s/%s%s -polort -1 \
            -tout -rout -bout -num_stimts 1 \
            -stim_file 1 %s/%s -stim_label 1 %s" \
            % (dir_in, fmri_in, file_type, dir_out, prefix_bucket, file_type, \
                TR, dir_censor, file_censor, \
                dir_mask, prefix_mask, file_type, dir_1D, file_1D, name_roi)
        check_and_run(sys_cmd, dir_out, prefix_bucket, file_type, debug)
        
# General - Merging all r2 buckets into a single volume
def create_corr_bucket(dir_in, fmri_in, dir_out, file_out, gm_rois, bucket_num, file_type, debug):
    print '** Merging all r2 buckets into a single volume!'
    # Manual file check because this funtion call appends
    
    if not os.path.exists( '%s/%s%s' % (dir_out, file_out, file_type)):
        for name_roi in gm_rois:
            prefix_bucket = fmri_in + '_' + name_roi
            sys_cmd = "3dbucket -aglueto %s/%s%s '%s/%s%s[%d]'" % \
                (dir_out, file_out, file_type, dir_in, prefix_bucket, file_type, buck_num)
            run_cmd(sys_cmd, debug)         
    else: 
        sys_cmd = "3dbucket -aglueto %s/%s%s '%s/%s%s[%d]'" % \
            (dir_out, file_out, file_type, dir_in, prefix_bucket, file_type, buck_num)
        print 'Output file already exists, function call skipped - %s' % (sys_cmd,)
    return file_out

# General - Creating a table of correlation values 
def create_corr_table(dir_in, corr_in, dir_out, file_out, gm_rois, debug):
    print '** Creating table of correlations'
    FILE_corr = open(dir_out + '/' + file_out,'w')
    for name_roi in gm_rois:
        file_roi = 'roi_' + name_roi 
        sys_cmd = '3dmaskave -q -mask %s/%s.nii %s/%s+tlrc' % \
            (dir_roi, file_roi, dir_in, corr_in)
        # sys_cmd = '3dmaskave -q -mask %s/%s.nii %s/%s+tlrc >> %s/%s' % \
            # (dir_roi, file_roi, dir_in, corr_in, dir_out, file_out)
        output, errors = run_cmd(sys_cmd, debug)            
        corrs = str(output.split()).replace("'","")
        corrs = corrs.strip('[] ')
        FILE_corr.write('%s\n' % corrs)
    FILE_corr.close()
    print gm_rois
    
    
#**********************************************************************



