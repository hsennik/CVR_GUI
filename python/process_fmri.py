#!/usr/bin/python

#  fMRI processing code using pythong

#    File Name:  process_fmri.py
#
#    NOTES - WL - 12/04/03 - Initial Creation
#
#   AUTHOR - Wayne Lee 
#   Created - 2012-04-03
#   REVISIONS 
#       A - 2012-04-03 - WL - Original Creation, loose class and function definitions
#       B - 2012-09-04 - BM - add --clean option to remove intermediate files
#                        WL - add 'xxx' option to skip a run (ie if it's non-existant/an outlier/too much movement)
#		C - 2013-01-03 - BM - add option to register MNI and things to fmri space
#       D - 2013-01-08 - BM - calculate fmri_nt from data instead of specifying in P_<>.txt file


from optparse import OptionParser, Option, OptionValueError
from numpy import *
import datetime
import os, shlex, subprocess
import string
from process_fmri_functions import *
import process_fmri_parameters
import inspect
from shutil import copyfile

program_name = 'process_fmri.py'

#*************************************************************************************
# FUNCTIONS

# Load subject list from text file
def load_subject_list(fname_subj_list):
# comma delimited file with subject and data directories (csv)
#   First Line = field headers = <subj_id> <dir_dcm_raw> <anat> <fmri_A> <fmri_B> <fmri_C> ...
#       Any number of fmri directories can be provided, must be unique identifiers
#       Header values are used to create file names

    if not os.path.exists(fname_subj_list):
        raise SystemExit, 'ERROR - Parameter File - File not found: %s' % (fname_subj_list,) 

    info_subj = {}
        
    file_subj_list = open(fname_subj_list,'r')
    num_subj = -1;
    for line in file_subj_list:
        num_subj = num_subj + 1
        line = line.strip('\n')
        line_parsed = line.split(',')
        count_col = -1
        num_fmri = 0

        if num_subj == 0:     # Header Line
            headers = line_parsed
        else:
            # Skip blank lines
            if (line_parsed[0] != '') :
                for column in line_parsed:
                    count_col = count_col + 1
                    if count_col == 0:   # subject_ID
                        subj_id = column;
                        info_subj[subj_id] = {}
                    elif count_col == 1: # raw dicom directory
                        info_subj[subj_id]['dir_dcm_raw'] = column
                    elif count_col == 2: # anat directory
                        info_subj[subj_id]['anat'] = column
                        info_subj[subj_id]['fmri'] = {}
                    elif count_col > 2:  # fMRI directory
                        num_fmri = num_fmri + 1
                        fmri_id = headers[count_col]
                        info_subj[subj_id]['fmri'][fmri_id] = column

    return info_subj, num_subj, num_fmri
    

        # # # --------------------------------------------------------------------------------------------------
        # print '*** EXTRACT GM Signal'
        # debug = debug_list['create_1D_gm'] 
        # create_1D(dir_roi, rois['gm'], dir['core'], fmri_ortho, dir['1D'], debug)

        # # # --------------------------------------------------------------------------------------------------
        # print '*** Correlations'
        # debug = debug_list['corr_fmri'] 
        # correlate_fMRI(dir['core'], fmri_ortho, epi_info['fmri']['TR']/1000.0, dir['gm_corr'], \
            # dir['mc'], fmri_censor, dir['core'], fmri_mni_sm_mask, dir['1D'], rois['gm'], debug)

        # fmri_corr = create_corr_bucket(dir['gm_corr'], fmri_ortho, dir['gm_corr'], fmri + '_R2s', rois['gm'], debug)
        # create_corr_table(dir['gm_corr'], fmri_corr, dir['gm_corr'], subj + '_corr.txt', rois['gm'], debug)
        
# Method of determining filtering method and stimfile
with open('textfiles/mat2py.txt', 'r') as myfile:
    temporal_filtering=myfile.readline().rstrip()
    stimulus=myfile.readline().rstrip()
print ('in processing pipeline')
print temporal_filtering
print stimulus

myfile.close

#  Just doing no temporal filtering for all for now
if temporal_filtering == '1':
	add_suffix1 = 'mpe'
elif temporal_filtering == '2':
	add_suffix1 = 'mpe'
elif temporal_filtering == '3':
	add_suffix1 = 'mpe'

with open('textfiles/processing.txt','r') as myfile2:
	processing=myfile2.readline().rstrip()

print processing
	
if __name__ == '__main__' :

    
    usage = "Usage: "+program_name+" <options> subject_list pipeline_info\n"+\
            "   or  "+program_name+" -help";
    parser = OptionParser(usage)
    parser.add_option("-c","--clobber", action="store_true", dest="clobber",
                        default=0, help="overwrite output file")
    parser.add_option("-d","--debug", action="store_true", dest="debug",
                        default=0, help="Run in debug mode")
    parser.add_option("-s","--skip_recon", action="store_true", dest="skip_recon",
                        default=0, help="Skip data recon (ie. already reconned)")
    parser.add_option("--clean", action="store_true", dest="clean",
                        default=0, help="Clean up processed directory when done (remove intermediate .nii files)")
    parser.add_option("--somanyxfm", action="store_true", dest="somanyxfm",
                        default=0, help="Print out a whole bunch of xfm files")
    # parser.add_option("--pinfo", type="string", dest="pinfo",
                        # help="File containing processing parameters")
    # parser.add_option("--info", type="string", dest="info",
                        # help="File containing data + processing parameters (mutually exclusive from dinfo, pinfo)")
    # parser.add_option("--tempdir", type="string", dest="tempdir",
                        # default = "/tmp", help="Base location for temporary directory [default =/tmp], creates a directory a unique directory 'asl??????'")
    # parser.add_option("--keeptemp", action="store_true", dest="keeptemp",
                        # default=0, help="Keep temporary directory")
#    parser.add_option("--TR", type="float", dest="TR",
#                        default = 3.9,help="TR of Ax SPGR images [ms] (Default = 3.9)")
#    parser.add_option("--mse", type="string", dest="mse",
#                        help="Optional mean squared error output")
#    parser.add_option("--fill_off", action="store_true", dest="fill_off",
#                        default=0, help="Turn off autofill which replaces -'ve slope or -T1 values with inplane local average")

# # Parse input arguments and store them
    options, args = parser.parse_args()     

   
# # Checking for compatable info input arguments
    # # first logical check is if "info" is properly called (ie. by itself)
    # if options.info and ( options.dinfo or options.pinfo):
        # raise SystemExit, "The --info option is mutually exclusive from --dinfo and --pinfo."
    # # if info is not called, then dinfo and pinfo must be called together, otherwise, error!
    # elif not options.info and not (options.dinfo and options.pinfo):
        # raise SystemExit, "The --pinfo and --dinfo options MUST be called together"

        
# # Example of checking for proper number of arguments
    if len(args) != 2:
        parser.error("incorrect number of arguments")
    fname_subj_list, fname_pipeline = args

    # Load and Parse subject list
    if not os.path.exists(fname_subj_list):
        raise SystemExit, '* ERROR - File not found: %s' % (fname_subj_list,) 
    info_subj, num_subj, num_fmri = load_subject_list("".join(fname_subj_list))
        
    # Load and Parse Pipeline info
    if not os.path.exists(fname_pipeline):
        raise SystemExit, 'ERROR - File not found: %s' % (fname_pipeline,) 
    pinfo = process_fmri_parameters.process_fmri_parameters()
    pinfo._load('.',fname_pipeline)
    if options.debug:
        debug = 1
    elif options.clobber:
        debug = -1
    else:
        debug = 0

    # Create processed directory link
    print "****** PREPARING PIPELINE DIRECTORIES ******"
    print pinfo.dir_recon
    print pinfo.dir_processed
    #print('Selection:' + add_suffix1)
    # if data3 != '1':
		# pinfo.dir_recon = pinfo.dir_recon + '_' + add_suffix1
    dir_recon_base = check_dir ( pinfo.dir_recon,debug)
    print pinfo.dir_recon
    if processing == '0': # Then don't do processing steps
		pinfo.dir_processed = pinfo.dir_processed + '_not'
    # if data3 != '1':
		# pinfo.dir_processed = pinfo.dir_processed + '_' + add_suffix1
    dir_processed_base = check_dir(pinfo.dir_processed, debug)  # create base processed director
    dir_processed = check_dir ( '%s/%s' % (pinfo.dir_processed, pinfo.pipeline_id),debug)
    dir_final = check_dir ('%s/final' % (dir_processed,),debug)
    print pinfo.dir_processed
    
    current_date = str(datetime.datetime.now()).split(' ')[0]
    # Copy metadata into destination directory
    fname_meta_subj_dated = '%s_%s.%s' % \
        (fname_subj_list.split('.')[0], current_date, fname_subj_list.split('.')[1])
    cmd_cp_meta_subj = 'cp %s %s/%s' % (fname_subj_list, dir_processed, fname_meta_subj_dated)
    check_and_run(cmd_cp_meta_subj, dir_processed, fname_meta_subj_dated, '', debug)
    
    fname_meta_pipe_dated = '%s_%s.%s' % \
        (fname_pipeline.split('.')[0], current_date, fname_pipeline.split('.')[1])
    cmd_cp_meta_pipe = 'cp %s %s/%s' % (fname_pipeline, dir_processed, fname_meta_pipe_dated)
    check_and_run(cmd_cp_meta_pipe, dir_processed, fname_meta_pipe_dated, '', debug)
    
    # Determine processing pipeline order
    if processing == '0': # 0 means no processing
		print 'in first if statement'
		list_process = ['trim','reg']
    elif processing == '1': # 1 means do all regular processing steps 
		list_process = pinfo.pipeline_order.split(',')
    print list_process
    
    for subj in info_subj:
        print "**** PROCESSING NEW SUBJECT - %s ****" % (subj,)
        

        dir_dcm_anat = "%s/%s/*%s*" % (pinfo.dir_dcm_base, info_subj[subj]['dir_dcm_raw'], \
            info_subj[subj]['anat'])
            
            
        dir_recon = check_dir( '%s/%s' % (pinfo.dir_recon, subj) , debug)
        dir_subj = check_dir( '%s/%s' % (dir_processed, subj) , debug)

        # Recon ANATOMICAL     
        if options.skip_recon:
            anat = subj + '_anat'
        else:
            anat = recon_gen(subj, dir_dcm_anat, dir_recon, 'anat', pinfo.file_type, pinfo.dcm_type, debug)
        anat_brain, anat_mask = cmd_afni_skullstrip(dir_recon, anat, dir_recon, anat, pinfo.file_type, debug)

        for fmri_name in info_subj[subj]['fmri']:
            if info_subj[subj]['fmri'][fmri_name].find('xxx') > -1:
                print "Skipping %s - no dicom directory given" % (fmri_name,)
            else:
                print
                print  "**** PROCESSING fMRI - %s_%s ****" % (subj, fmri_name)

                dir_dcm_fmri = "%s/%s/*%s*" % \
                    (pinfo.dir_dcm_base, info_subj[subj]['dir_dcm_raw'], info_subj[subj]['fmri'][fmri_name])
                if options.skip_recon:
                    fmri = subj + '_' + fmri_name
                else:
                    fmri = recon_epi(subj, dir_dcm_fmri, dir_recon, fmri_name, pinfo.file_type, pinfo, debug)
                    

                # Recon fMRI
                fname_active = '%s' % (fmri,)            # Initialize active filename
                
                # find how many TRs are in raw data (if specified to do so)
                if pinfo.fmri_nt==-1:
                    num_TR = cmd_fslval(dir_recon, fmri, pinfo.file_type, '4', debug)
                    num_TR = int(num_TR)
                else:
                    num_TR = pinfo.fmri_nt
                
                # Go through processing steps 
                for process_step in list_process:

                    if fname_active == fmri:    # If first processing step after recon, then input dir is raw data
                        dir_active_in = dir_recon   
                    else:                       # otherwise input data is 'processed'
                        dir_active_in = dir_subj
                    
                    if process_step == 'trim':   # Trim excess volumes
                        index_last_vol = num_TR - pinfo.drop_end - 1   # subtract 1 because 0 relative
                        fname_active = cmd_afni_trim(dir_active_in, fname_active, pinfo.drop_begin, \
                            index_last_vol, dir_subj, fname_active, pinfo.file_type, debug)
                    elif process_step == 'st':  # Slice timing correction
                        print
                        print '*** SLICE TIMING CORRECTION ***'
                        fname_active = cmd_afni_3dTshift(dir_active_in, fname_active, pinfo.st_ignore, \
                            dir_subj, fname_active, pinfo.file_type, debug)
                        
                    elif process_step == 'mc':     # Motion Correction
                        print
                        print '*** MOTION CORRECTION ***'
                        fname_active = cmd_afni_3dvolreg(dir_active_in, fname_active, \
                            pinfo.mc_refvol, dir_subj, fname_active, pinfo.file_type, debug)
                        fname_MD = '%s_MD.1D' % (fname_active,)  # Max diplacement 1D file
                        fname_mpe = '%s.1D' % (fname_active,)    # Motion parameter estimates 1D file
                        # Motion Correction - Create a censor file based on MD
                        fname_censor = cmd_censor(dir_active_in, fname_MD, dir_subj, \
                            fname_active + '_censor.1D', pinfo.mc_outlier_MD, debug)
                        
                    elif process_step == 'sm':
                        print
                        print "*** SMOOTHING ***"
                        # Take average, then generate a mask for smoothing
                        fname_presm_mean = cmd_afni_create_mean(dir_active_in, fname_active, \
                            dir_subj, pinfo.file_type, debug)
                        fname_presm_mask = cmd_afni_automask(dir_active_in, fname_presm_mean, \
                            dir_subj, fname_active, pinfo.file_type, debug)
                        
                        # Smooth dataset
                        # fname_active = cmd_afni_smooth(pinfo.sm_type, pinfo.sm_fwhm, \
							# dir_subj, dir_active_in, fname_active, \
							# dir_subj, fname_presm_mask, pinfo.file_type, debug)
                        # print pinfo.sm_fwhm
                        # print fname_active
                        
                    elif process_step == 'reg':
                        print
                        print '*** REGISTRATION ***'

                        # XFMs go to recon directory
                        dir_ref = '${FSLDIR}/data/standard'
                        if pinfo.reg_ref == 'MNI_1mm':
                            file_ref = 'MNI152_T1_1mm_brain.nii.gz'
                        else:
                            file_ref = 'MNI152_T1_2mm_brain.nii.gz'

                        # Generate average fMRI brain only
                        fname_mean = cmd_afni_create_mean(dir_active_in, fname_active, \
                            dir_subj, pinfo.file_type, debug)
                        print fname_mean 
                        fname_mask = cmd_afni_automask(dir_active_in, fname_mean, \
                            dir_subj, fname_active, pinfo.file_type, debug)
                        print(dir_active_in, fname_active, dir_subj, pinfo.file_type)
                        print fname_mask
                        fname_brain = cmd_afni_basic_calc(dir_subj, fname_mean, \
                            dir_subj, fname_mask, dir_subj, fname_mean + '_brain', '*', \
                            pinfo.file_type, debug)
                        print fname_brain

                        if pinfo.reg_ref == 'MNI_2mm':    
                            # LINEAR TRANSFORMS
                            # Calculate fmri->anat
                            xfm_fmri_anat = cmd_fsl_flirt_calc(dir_active_in, fname_brain, \
                                dir_recon, anat_brain, pinfo.reg_dof_EPI_anat, \
                                dir_recon, fmri + '_anat', pinfo.file_type, debug)
                            
                            # Calculate anat->ref
                            xfm_anat_ref = cmd_fsl_flirt_calc(dir_recon, anat_brain, \
                                dir_ref, file_ref, pinfo.reg_dof_anat_ref, \
                                dir_recon, anat + '_ref', pinfo.file_type, debug)
                                                
                            # Calculate fmri->template
                            xfm_fmri_ref = cmd_fsl_convert_xfm(dir_recon, fmri + '_ref.xfm', \
                                xfm_fmri_anat, xfm_anat_ref, debug)                 
                            
                            # NON LINEAR
                            if pinfo.reg_method == 'fnirt':
                                warp_anat_ref = cmd_fsl_fnirt_calc(dir_recon, anat_brain, \
                                    dir_recon, xfm_anat_ref, dir_recon, anat + '_ref_warp' , \
                                    pinfo.reg_fnirt_config, pinfo.file_type, debug)                    

                                    # registered anatomical goes to recon directory
                                anat_ref = cmd_fsl_fnirt_apply_anat(dir_recon, anat, \
                                    dir_recon, warp_anat_ref, dir_ref, file_ref, \
                                    dir_recon, anat + '_warpRef' , pinfo.file_type, debug)
                                
                                # registered functional goes to processed 
                                fname_active = cmd_fsl_fnirt_apply_epi(dir_subj, fname_active, \
                                    'pre', dir_recon, xfm_fmri_anat, \
                                    dir_recon, warp_anat_ref, dir_ref, file_ref, \
                                    dir_subj, fname_active + '_warpRef', pinfo.file_type, debug)
                            
                            # LINEAR TRANSFORM
                            elif pinfo.reg_method == 'flirt':   
                                # apply anat->template - into recon directory
                                anat_ref = cmd_fsl_flirt_apply(dir_recon, anat, dir_ref, file_ref, \
                                    dir_recon, anat + '_ref', dir_recon, xfm_anat_ref, pinfo.file_type, 'sinc', debug)

                                # apply fmri->template - into subject directory
                                fname_active = cmd_fsl_flirt_applyxfm4D(dir_active_in, fname_active, \
                                    dir_ref, file_ref, dir_subj, fname_active + '_ref', \
                                    dir_recon, xfm_fmri_ref, pinfo.file_type, debug)
                                   
                            # LINEAR w/in subject registration
                            elif pinfo.reg_method == 'subj':  
                                # apply fmri->anat  into subject directory
                                fname_active = cmd_fsl_flirt_applyxfm4D(dir_active_in, fname_active, \
                                    dir_ref, file_ref, dir_subj, fname_active + '_anat', \
                                    dir_recon, xfm_fmri_anat, pinfo.file_type, debug)
                            else:
                                raise SystemExit, 'ERROR - Invalid registration method %s ' % \
                                    (pinfo.reg_method,)

                        elif pinfo.reg_ref == 'fmri':
                            # Calculate anat->fmri
                            xfm_anat_fmri = cmd_fsl_flirt_calc(dir_recon, anat_brain, \
                                dir_active_in, fname_brain, pinfo.reg_dof_EPI_anat, \
                                dir_recon, anat + '_' + fmri_name, pinfo.file_type, debug)
                            
                            # register anatomical into fmri space (recon directory)
                            anat_fmri = cmd_fsl_flirt_apply(dir_recon, anat_brain, dir_active_in, fname_brain, \
                                dir_recon, anat + '_' + fmri_name, dir_recon, xfm_anat_fmri, pinfo.file_type, 'sinc', debug)
                            
                            # Calculate fmri->anat
                            xfm_fmri_anat = cmd_fsl_flirt_calc(dir_active_in, fname_brain, \
                                dir_recon, anat_brain, pinfo.reg_dof_EPI_anat, \
                                dir_recon, fmri + '_anat', pinfo.file_type, debug)

                                
                            if options.somanyxfm:
                                # save xfm of fmri -> anat too
                                xfm_fmri_anat = cmd_fsl_flirt_calc(dir_active_in, fname_brain, \
                                    dir_recon, anat_brain, pinfo.reg_dof_EPI_anat, \
                                    dir_recon, subj + '_' + fmri_name + '_' + 'anat', pinfo.file_type, debug)
                                    
                                # save xfm of anat -> ref
                                xfm_anat_ref = cmd_fsl_flirt_calc(dir_recon, anat_brain, \
                                    dir_ref, file_ref, pinfo.reg_dof_anat_ref, \
                                    dir_recon, anat + '_ref', pinfo.file_type, debug)
                                    
                                # save xfm of fmri -> ref
                                # use convert_xfm to concatenate the 2 xfm files
                                xfm_fmri_ref = cmd_fsl_convert_xfm(dir_recon, subj + '_' + fmri_name + '_ref.xfm', \
                                    xfm_fmri_anat, xfm_anat_ref, debug)
                                
                            if pinfo.ref_to_fmri:
                                # register MNI first to anatomical, then to fmri space (using xfm_anat_fmri)
                                xfm_ref_anat = cmd_fsl_flirt_calc(dir_ref, file_ref, \
                                    dir_recon, anat_brain, pinfo.reg_dof_anat_ref, \
                                    dir_recon, subj + '_ref_anat', pinfo.file_type, debug)
                                    
                                # create mni_anat.nii for testing purposes
                                #mni_fmri = cmd_fsl_flirt_apply(dir_ref, file_ref, dir_recon, anat_brain, \
                                #    dir_recon, subj + '_ref_anat', dir_recon, xfm_ref_anat, pinfo.file_type, 'sinc', debug)
                                
                                # use convert_xfm to concatenate the 2 xfm files (ref_anat, anat_fmri)
                                xfm_ref_fmri = cmd_fsl_convert_xfm(dir_recon, subj + '_ref_' + fmri_name + '.xfm', \
                                    xfm_ref_anat, xfm_anat_fmri, debug)
                                
                                # register mni into fmri space (don't really need to save this)
                                #mni_fmri = cmd_fsl_flirt_apply(dir_ref, file_ref, dir_active_in, fname_brain, \
                                #    dir_recon, subj + '_mni_' + fmri_name, dir_recon, xfm_ref_fmri, pinfo.file_type, 'sinc', debug)
                                
                                    
                            if (pinfo.roi_to_fmri & pinfo.ref_to_fmri):
                                # register CSF/WM ROIs to fmri space
                                roi_fmri = cmd_fsl_flirt_apply(pinfo.roi_dir, pinfo.roi_fname, dir_active_in, fname_brain, \
                                    dir_recon, subj + '_roi_' + fmri_name, dir_recon, xfm_ref_fmri, pinfo.file_type, 'nearestneighbour', debug)
                                
                            if (pinfo.atlas_to_fmri & pinfo.ref_to_fmri):    
                                # register atlas to fmri space
								atlas_list = pinfo.atlas_list.split(',')
								atlas_alias = pinfo.atlas_alias.split(',')
								
								if len(atlas_list) != len(atlas_alias):
									raise SystemExit, 'ERROR - atlas_list and atlas_alias must have same number of entries'
																	
								count = 0
								i = iter(atlas_alias)
								for name_atlas in atlas_list:						
									
									cur_atlas = i.next()
									ref_fmri = cmd_fsl_flirt_apply(pinfo.atlas_dir, name_atlas, \
										dir_active_in, fname_brain, dir_recon, subj + '_' + cur_atlas + '_' + fmri_name, \
										dir_recon, xfm_ref_fmri, pinfo.file_type, 'nearestneighbour', debug)
									
									count = count + 1
                               
                        
                        else:
                            raise SystemExit, 'ERROR - Invalid registration reference %s ' % \
                                (pinfo.reg_method,)
                                    
                    elif process_step == 'tfilt':
                        print
                        print "*** TEMPORAL FILTERING ***"
                        # Generate ROI 1D files
                        fname_roi_1D = '%s_roi.1D' % (fname_active,)
                        if not pinfo.roi_type=='none':
                            roi_list = pinfo.roi_list.split(',')
                            if pinfo.roi_type=='group':
                                fname_roi_mask = pinfo.roi_fname
                                roi_dir = pinfo.roi_dir
                            elif ((pinfo.roi_type=='subj') & (pinfo.roi_to_fmri==1)):
                                fname_roi_mask = subj + '_roi_' + fmri_name
                                roi_dir = dir_recon
                            elif pinfo.roi_type =='subj':
                                fname_roi_mask = '%s_%s' % (subj, pinfo.roi_fname)
                                roi_dir = pinfo.roi_dir
                            print 'Generating ROI values - %s ' % (fname_roi_1D)
                            fname_roi_1D = create_1D(roi_dir, fname_roi_mask, roi_list, \
                                 dir_subj, fname_active, dir_subj, fname_roi_1D, pinfo.file_type, debug)
                        else:
                            fname_roi_1D = ''
                            roi_list = ''

                        # Orthogonalize data using 3dDeconvolve
                        if add_suffix1 == 'mpe':
                        #if pinfo.mpr_type == 'mpe':
                            num_motion = 6
                            fname_mpr = fname_mpe
                        elif add_suffix1 == 'MD':
                        #elif pinfo.mpr_type == 'MD':
                            num_motion = 1
                            fname_mpr = fname_MD
                        elif add_suffix1 == 'none':
                            num_motion = 0
                            fname_mpr = fname_MD   # dummy variable call/is this the same as none?
                     
                        # Generate average fMRI MASK only
                        fname_mean = cmd_afni_create_mean(dir_active_in, fname_active, \
                            dir_subj, pinfo.file_type, debug)
                        fname_mask = cmd_afni_automask(dir_active_in, fname_mean, \
                            dir_subj, fname_active, pinfo.file_type, debug)
                        
                        # Use the above-generated fMRI mask as a whole-brain signal regressor, if requested
                        if pinfo.roi_wholebrain==1:
                            print 'Doing whole brain regression - %s ' % (fname_roi_1D)
                            fname_roi_1D_wholebrain = 'wholebrain_roi.1D'
                            fname_roi_mask = fname_mask
                            roi_dir = dir_subj
                            roi_list2 = fname_roi_mask.split(',') # all this does it make it compatible with a for loop in create_1D (needs to be a list) :S
                            fname_roi_1D_wholebrain = create_1D(roi_dir, fname_roi_mask, roi_list2, \
                                dir_subj, fname_active, dir_subj, fname_roi_1D_wholebrain, pinfo.file_type, debug)
                            
                            # check to see if a regression 1D file already exists
                            # if it doesn't, then you don't even care, things are easy
                            # if it does, then you'll need to append the whole brain 1D as a new column to the fname_roi_1D file
                            if not pinfo.roi_type=='none':
                                array_rois = [[double(i) for i in line.split()] for line in open(dir_subj + '/' + fname_roi_1D)]
                                array_wholebrain = [[double(i) for i in line.split()] for line in open(dir_subj + '/' + fname_roi_1D_wholebrain)]
                                combined_file = column_stack((array_rois,array_wholebrain))
                                roi_list.append(fname_roi_1D_wholebrain)
                                if not debug: 
                                    savetxt(dir_subj + '/' + 'wholebrain_all_roi.1D', combined_file, fmt='%6.5f')
                                fname_roi_1D = 'wholebrain_all_roi.1D'
                                
                            else:
                                fname_roi_1D = fname_roi_1D_wholebrain
                                roi_list=[fname_roi_1D]
                           
                        fname_ortho_buck, fname_ortho_err = create_3dDecon(dir_active_in, fname_active, \
                            pinfo.fmri_TR, dir_subj, fname_active, dir_subj, fname_censor, \
                            dir_subj, fname_mask, dir_subj, fname_roi_1D, roi_list, \
                            dir_subj, fname_mpr, num_motion, pinfo.det_order, \
                            '','','', '', 0, '', '',pinfo.file_type, debug)    # pass nothing for stim at this time
                        
                        
                        if not ((pinfo.hp_cutoff == 0) and (pinfo.lp_cutoff == 0)):
                        # Band pass filter the residual
                            fname_ortho_err_bp = cmd_afni_bandpass(dir_subj, fname_ortho_err, \
                                dir_subj, fname_ortho_err, pinfo.hp_cutoff, pinfo.lp_cutoff, pinfo.file_type, debug)
                        else:
                            fname_ortho_err_bp = fname_ortho_err
                            
                        # Put polort 0 + Errts back together for a 'detrended' signal
                        fname_pol0 = cmd_afni_extract_buck(dir_subj, fname_ortho_buck, 2, \
                            dir_subj, fname_ortho_buck + '_pol0', pinfo.file_type, debug)
                        fname_active = cmd_afni_basic_calc(dir_subj, fname_pol0, \
                            dir_subj, fname_ortho_err_bp, dir_subj, fname_active + '_tfilt',  \
                            '+', pinfo.file_type, debug)
                                                    
                    elif process_step == 'bavg':
                        print
                        print "*** BASELINE AVERAGING DATASET ***"
                        # Load baseline ID file into memory
                        if pinfo.bavg_fname_1D == 'ALL':
                            data_base = ones((num_TR - pinfo.drop_begin - pinfo.drop_end,))
                        else:   
                            data_base = loadtxt(pinfo.bavg_dir_1D + '/' + pinfo.bavg_fname_1D)
                            # Error check that data_base is the same size as the data
                            if (debug < 1) and (len(data_base) != (num_TR - pinfo.drop_begin - pinfo.drop_end)):
                                raise SystemExit, 'ERROR - fMRI data [%d] and Baseline ID [%s - %d] are different lengths' % \
                                    (num_TR - pinfo.drop_begin - pinfo.drop_end, pinfo.bavg_fname_1D, len(data_base)) 

                        # Check if MD censor file exists
                        try:
                            fname_censor
                        except NameError:
                            fname_censor = None

                        # If it does not exist (or in debug mode), create an array of 1s equal to size of baseline ID
                        if (fname_censor is None) or debug>0:
                            data_cens = ones(size(data_base))
                        else: # If it does exist,  load it 
                            data_cens = loadtxt(dir_subj + '/' + fname_censor)
                            
                            # Error check that data_base is the same size as the censor file (should be!)
                            if (len(data_base) != len(data_cens)):
                                raise SystemExit, 'ERROR - MD Censor file [%s, %d] and Baseline ID [%s - %d] are different lengths' % \
                                    (fname_censor, len(data_cens), pinfo.bavg_fname_1D, len(data_base)) 
                        
                        # Create baseline and MD censored 1D file
                        fname_base_censored = '%s_base_censored.1D' % (fmri,)
                        if not debug:
                            savetxt(dir_subj + '/' + fname_base_censored, data_base * data_cens, fmt="%d")

                        # Calculate mean of baseline and MD censored fMRI data
                        fname_bavg = calc_base_avg(dir_active_in, fname_active, dir_subj, fname_base_censored, \
                            dir_subj, fname_active, pinfo.file_type, debug)
                        
                        # Remask baseline mean to precision errors
                        fname_bavg_masked = cmd_afni_basic_calc(dir_subj, fname_bavg, dir_subj, fname_mask, \
                            dir_subj, fname_bavg + '_mask' ,'*', pinfo.file_type, debug)
                        
                        # Divide active fMRI dataset by mean
                        fname_active = cmd_afni_basic_calc(dir_subj, fname_active, dir_subj, fname_bavg_masked, \
                            dir_subj, fname_active + '_bavgd', '/', pinfo.file_type, debug)
                        
                
                print
                # REMOVING INTERMEDIATE .NII FILES (option --clean)   - added 2012-09-04 by BM
                if options.clean:
                    print '*** REMOVING INTERMEDIATE .nii FILES ***' 
                    sys_cmd = 'mkdir %s/tmp' % (dir_subj)
                    run_cmd(sys_cmd,debug)
                    sys_cmd = 'cp %s/%s*.nii %s/tmp/' % (dir_subj, fname_active, dir_subj)
                    run_cmd(sys_cmd,debug)
                    sys_cmd = 'rm %s/%s*.nii' % (dir_subj, fmri)
                    run_cmd(sys_cmd,debug)
                    sys_cmd = 'mv %s/tmp/* %s/' % (dir_subj, dir_subj)
                    run_cmd(sys_cmd,debug)
                    sys_cmd = 'rm -r %s/tmp' % (dir_subj)
                    run_cmd(sys_cmd,debug)
                
                fname_short = '%s_%s' % (fmri, pinfo.pipeline_id)                
                print
                print '** Creating short form links - %s ' % (fname_short,)
                #       SHORT FORMING fMRI DATA
                # subject directory
                print fname_active 
                sys_cmd = 'ln -s %s/%s%s %s/%s%s' % (dir_subj, fname_active, pinfo.file_type, \
                    dir_subj, fname_short, pinfo.file_type)
                check_and_run(sys_cmd, dir_subj, fname_short, pinfo.file_type, debug)
                # processed directory
                sys_cmd = 'ln -s %s/%s%s %s/%s%s' % (dir_subj, fname_active, pinfo.file_type, \
                    dir_final, fname_short, pinfo.file_type)
                check_and_run(sys_cmd, dir_final, fname_short, pinfo.file_type, debug)

                #       FINAL fMRI MASK 
                print fname_active
                fname_mean = cmd_afni_create_mean(dir_subj, fname_active, \
                    dir_subj, pinfo.file_type, debug)
                print fname_mean
				#		COMMENTED THIS SECTION BECAUSE IT SHOULDN'T BE HERE, messed up masks for no processing 
                #fname_mask = cmd_afni_thresh(dir_subj, fname_mean, 0, \
				#	dir_subj, fname_mean + '_mask', 0, pinfo.file_type, debug)
                print fname_mask
                # Subject Directory - short form link
                sys_cmd = 'ln -s %s/%s%s %s/%s_mask%s' % (dir_subj, fname_mask, pinfo.file_type, \
                    dir_subj, fname_short, pinfo.file_type)
                check_and_run(sys_cmd, dir_subj, fname_short + '_mask', pinfo.file_type, debug)
                # Processed Directory - short form link
                sys_cmd = 'ln -s %s/%s%s %s/%s_mask%s' % (dir_subj, fname_mask, pinfo.file_type, \
                    dir_final, fname_short, pinfo.file_type)
                check_and_run(sys_cmd, dir_final, fname_short + '_mask', pinfo.file_type, debug)

                # If a censor file exists, create a short form link for it
                try:
                    fname_censor
                except NameError:
                    fname_censor = None
                if not (fname_censor is None):
                    # Subject directory
                    sys_cmd = 'ln -s %s/%s %s/%s_censor.1D' % (dir_subj, fname_censor, \
                        dir_subj, fname_short)
                    check_and_run(sys_cmd, dir_subj, fname_short + '_censor.1D', '', debug)
                    # Processed directory
                    sys_cmd = 'ln -s %s/%s %s/%s_censor.1D' % (dir_subj, fname_censor, \
                        dir_final, fname_short)
                    check_and_run(sys_cmd, dir_final, fname_short + '_censor.1D', '', debug)
                
                
                print '**** DONE PROCESSING - %s ****' % (fmri,)				
				
if processing == '0':
	fileName = 'REDCap_import_files/all/'+ subj + '_not_processed_parameters.txt'
else:
	fileName = 'REDCap_import_files/all/'+ subj + '_processed_parameters.txt'				
with open(fileName,'w') as thefile:
	thefile.write('dir_dcm_base,' + pinfo.dir_dcm_base + ',Base Directory\n')
	thefile.write('dir_analyzed,' + pinfo.dir_analyzed + ',Analyzed Directory\n')
	thefile.write('dir_processed,' + pinfo.dir_processed + ',Processed Directory\n')
	thefile.write('dir_recon,' + pinfo.dir_recon + ',Recon Directory\n')
	str1 = ';'.join(list_process)
	thefile.write('pipeline_order,' + str1 + ',Order of processing\n')
	thefile.write('mpr_type,' + add_suffix1 + ',Temporal Filtering Type\n')
thefile.close