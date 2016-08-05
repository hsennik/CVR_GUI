#!/usr/bin/python

#  fMRI Analysis code wrapped using python
#  For the analysis of fMRI data processed using process_fmri.py

#    File Name:  analyze_fmri.py
#
#    NOTES - WL - 12/04/03 - Initial Creation
#
#   AUTHOR - Wayne Lee 
#   Created - 2012-04-03
#   REVISIONS 
#       A - 2012-04-03 - WL - Original Creation, loose class and function definitions
#       B - 2013-01-03 - WL - added glt option and xxx option for skipping runs
#       C - 2013-01-08 - BM - added zipping of errts file (to save space)
#		D - 2013-01-08 - BM - added option to concatenate preprocessed files for analysis (for multiple runs per subject)


from optparse import OptionParser, Option, OptionValueError
from numpy import *
import datetime
import os, shlex, subprocess
import string
from process_fmri_functions import *
import process_fmri_parameters
import inspect
import sys

program_name = 'analyze_fmri.py'

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
        num_subj = num_subj + 1;
        line = line.strip('\n')
        line_parsed = line.split(',')
        count_col = -1;
        num_fmri = 0;

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
                        #info_subj[subj_id]['anat'] = int(column)
                        info_subj[subj_id]['anat'] = column
                        info_subj[subj_id]['fmri'] = {}
                    elif count_col > 2:  # fMRI directory
                        num_fmri = num_fmri + 1
                        fmri_id = headers[count_col]
                        #info_subj[subj_id]['fmri'][fmri_id] = int(column)
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

# Method of determining stimfile
with open('textfiles/stimulus.txt', 'r') as myfile:
    stimulus=myfile.readline().rstrip()
if stimulus == '1':
	stimulus_suffix = 'pf'

myfile.close

# Method of determining processed or raw data 
with open('textfiles/processing.txt','r') as myfile2:
	processing=myfile2.readline().rstrip()
myfile2.close

# Method of determining if using standard boxcar, shifted boxcar, or customized boxcar
with open('textfiles/standard_shifted_customized.txt','r') as myfile3:
	boxcar_sel = myfile3.readline().rstrip()
myfile3.close

if boxcar_sel == '1':
	tackon = ''
	if stimulus == '2':
		stimulus_suffix = 'standard_boxcar'
elif boxcar_sel == '2':
	tackon = '_shifted'
	if stimulus == '2':
		stimulus_suffix = 'shifted_boxcar'
elif boxcar_sel == '3':
	tackon = '_customized'
	if stimulus == '2':
		stimulus_suffix = 'customized_boxcar'
print tackon
print stimulus_suffix

# Method of determining which breathhold if selected, since analysis only runs one study at a time (fmri_name)
with open('textfiles/breathhold_selection.txt') as myfile4:
	breathhold_selection = myfile4.readline()
myfile4.close

# This text file is needed for MOT and SENS to specify them generally instead of MOTL MOTR SENSL SENSR (only process data for MOT and SENS, then analyze using MOTR MOTL boxcars, etc)
with open('textfiles/gen_selection.txt') as myfile5:
	gen_selection = myfile5.readline()
myfile5.close

with open('textfiles/otherstimsel.txt') as myfile6:
	otherstimsel = myfile6.readline()
myfile6.close

if stimulus == '3':
	stimulus_suffix = otherstimsel
	
if __name__ == '__main__' :

    
    usage = "Usage: "+program_name+" <options> subject_list pipeline_info\n"+\
            "   or  "+program_name+" -help";
    parser = OptionParser(usage)
    parser.add_option("-c","--clobber", action="store_true", dest="clobber",
                        default=0, help="overwrite output file")
    parser.add_option("-d","--debug", action="store_true", dest="debug",
                        default=0, help="Run in debug mode")
    parser.add_option("--clean", action="store_true", dest="clean",
                        default=0, help="Delete concatenated files to save space")                    
   
	
# Parse input arguments and store them
    options, args = parser.parse_args()     
       
# Checking for proper number of arguments
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
    else:
        debug = 0
    
    # Create processed directory link
    print "****** PREPARING PIPELINE DIRECTORIES ******"
    # print('Selection:' + add_suffix1 + '_' + stimulus)
    # if data3 != '1':
		# pinfo.dir_recon = pinfo.dir_recon + '_' + add_suffix1
    dir_recon_base = check_dir ( pinfo.dir_recon,debug)
    # if data3 != '1':
		# pinfo.dir_analyzed = pinfo.dir_analyzed + '_' + add_suffix1 + '_' + stimulus
    if processing == '0':
		pinfo.dir_analyzed = pinfo.dir_analyzed + '_' + stimulus_suffix + '_raw'
    else:
		pinfo.dir_analyzed = pinfo.dir_analyzed + '_' + stimulus_suffix
    dir_analyzed_base = check_dir(pinfo.dir_analyzed, debug)  # create base processed director
    dir_analyzed = check_dir ( '%s/%s' % (pinfo.dir_analyzed, pinfo.pipeline_id),debug)
    dir_final = check_dir ('%s/final' % (dir_analyzed,),debug)
    # if data3 != '1':
		# pinfo.dir_processed = pinfo.dir_processed + '_' + add_suffix1
    if processing == '0':
		pinfo.dir_processed = pinfo.dir_dcm_base + '/data/raw'
    dir_processed = check_dir ( '%s/%s' % (pinfo.dir_processed, pinfo.pipeline_id),debug)
	
    current_date = str(datetime.datetime.now()).split(' ')[0]
    # Copy metadata into destination directory
    fname_meta_subj_dated = '%s_%s.%s' % \
        (fname_subj_list.split('.')[0], current_date, fname_subj_list.split('.')[1])
    cmd_cp_meta_subj = 'cp %s %s/%s' % (fname_subj_list, dir_analyzed, fname_meta_subj_dated)
    check_and_run(cmd_cp_meta_subj, dir_analyzed, fname_meta_subj_dated, '', debug)
    
    fname_meta_pipe_dated = '%s_%s.%s' % \
        (fname_pipeline.split('.')[0], current_date, fname_pipeline.split('.')[1])
    cmd_cp_meta_pipe = 'cp %s %s/%s' % (fname_pipeline, dir_analyzed, fname_meta_pipe_dated)
    check_and_run(cmd_cp_meta_pipe, dir_analyzed, fname_meta_pipe_dated, '', debug)
    
    # Determine processing pipeline order
    if processing == '0': # 0 means no processing
		print 'in first if statement'
		list_process = ['trim','reg']
    elif processing == '1': # 1 means do all regular processing steps 
		list_process = pinfo.pipeline_order.split(',')
    print list_process
	
    for subj in info_subj:
        print 
        print "**** ANALYZING NEW SUBJECT - %s ****" % (subj,)
        dir_analyzed_subj = check_dir('%s/%s' % (dir_analyzed,subj), debug)
        dir_recon = pinfo.dir_recon + '/' + subj
        
        if not pinfo.concat_enable:

				
			fmri_name = breathhold_selection
			
			# check to see if 'xxx' was entered for a run - if so, skip the run
			# if info_subj[subj]['fmri'][fmri_name].find('xxx') > -1:
				# print 
				# print "*** Skipping run because no dicom directory given for: ***" 
				# print '%s' % (fmri_name)
			
			# else:        
			print
			print  "**** ANALYZING fMRI - %s_%s ****" % (subj, fmri_name)
			print fmri_name
			dir_subj = '%s/final' % (dir_processed, )
			print dir_subj
			fname_fmri = '%s_%s_%s' % (subj, fmri_name, pinfo.pipeline_id)
			fname_mask = '%s_%s_%s_mask' % (subj, fmri_name, pinfo.pipeline_id)
			print fname_mask
			fname_censor = '%s_%s_%s_censor.1D' % (subj, fmri_name, pinfo.pipeline_id)
			
			# If censor file doesn't exist, wipe it's name, these may or may no tbe created at the end of process_fmri
			if not os.path.exists(dir_subj + '/' + fname_censor):
				fname_censor = ''
			elif (hasattr(pinfo, "glm_stim_censor_enable") and pinfo.glm_stim_censor_enable):
				fname_stim_censor = pinfo.glm_dir_stim + '/' + pinfo.glm_stim_censor
				fname_combined_censor = dir_subj + '/' + subj + '_' + fmri_name + '_' + pinfo.pipeline_id + '_censor_stim.1D'
				sys_cmd = ['1deval -expr "a*b" -a ' + dir_subj + '/' + fname_censor + ' -b ' + fname_stim_censor + ' > ' + fname_combined_censor]
				process = subprocess.Popen(sys_cmd, shell=True)
				process.communicate()
				fname_censor = subj + '_' + fmri_name + '_' + pinfo.pipeline_id + '_censor_stim.1D'
			
				
			# If mask  file doesn't exist, wipe it's name, these may or may no tbe created at the end of process_fmri
			if not os.path.exists(dir_subj + '/' + fname_mask + '.nii'):
				fname_mask = ''
				print 'Mask file does not exist'
			else:
				print 'MASK FILE PATH EXISTS'
			
			if pinfo.glm_enable:
				# Initialize stim file construction
				stim_prefix = ''
				
				if pinfo.glm_stim_model == 'ROI':    # if ROI based
					roi_list = pinfo.glm_roi_list.split(',')
					if pinfo.roi_type=='group':                 # Figure out ROI masks
						fname_roi_mask = pinfo.glm_roi_fname
					elif pinfo.roi_type =='subj':
						fname_roi_mask = '%s_%s' % (subj, pinfo.glm_roi_fname)
					print 'Generating ROI values - %s ' % (fname_roi_1D)
					# Create 1D files based on masks
					fname_roi_1D = create_1D(pinfo.glm_roi_dir, fname_roi_mask, roi_list, \
						dir_subj, fname_active, dir_subj, fname_roi_1D, pinfo.file_type, debug)
					pinfo.glm_dir_stim = dir_subj
					pinfo.glm_stim_suffix = fname_roi_1D
					
				else:    # normal stimulus type    
					# Check stimulus naming convention
					if pinfo.glm_stim_per_subj == 'yes':
						stim_prefix = '%s/%s_' % (subj, subj)
					if pinfo.glm_stim_per_run == 'yes':
						stim_prefix = '%s%s_' % (stim_prefix, fmri_name)
				
				if pinfo.glm_stim_grouping == 'single' or pinfo.glm_stim_model == 'ROI':
					for stim_name in pinfo.glm_stim_suffix.split(','):
						fname_buck_out = '%s_%s' % (fname_fmri , stim_name.split('.')[0])
						fname_glm_buck, fname_glm_err = create_3dDecon(dir_subj, fname_fmri, \
							pinfo.fmri_TR, dir_analyzed_subj, fname_buck_out, dir_subj, fname_censor, \
							dir_subj, fname_mask, '', '', '', \
							'', '', 0, '0', \
							pinfo.glm_dir_stim, stim_prefix, (stim_name,), pinfo.glm_stim_model, \
							pinfo.glt_enable, pinfo.glt_dir, pinfo.glt_labels, pinfo.file_type, debug)
				elif pinfo.glm_stim_grouping == 'all':
					if stimulus == '2':
						pinfo.glm_stim_suffix = 'bhonset' + subj + '_' + breathhold_selection + tackon + '.1D'
					elif stimulus == '1':
						if processing is '0':
							pinfo.glm_stim_suffix = 'pf_stim_' + gen_selection + '_raw.1D'	
						else:
							pinfo.glm_stim_suffix = 'pf_stim_' + gen_selection + '_processed.1D'
					elif stimulus == '3':
						pinfo.glm_stim_suffix = 'bhonset' + subj + '_' + otherstimsel + '.1D'
					print('The selected stimfile is: ' + pinfo.glm_stim_suffix)
					fname_glm_buck, fname_glm_err = create_3dDecon(dir_subj, fname_fmri, \
					pinfo.fmri_TR, dir_analyzed_subj, fname_fmri, dir_subj, fname_censor, \
					dir_subj, fname_mask, '', '', '', \
					'', '', 0, '0', \
					pinfo.glm_dir_stim, stim_prefix, pinfo.glm_stim_suffix.split(','), pinfo.glm_stim_model, \
					pinfo.glt_enable, pinfo.glt_dir, pinfo.glt_labels, pinfo.file_type, debug)
				else:
					raise SystemExit, 'ERROR - Improper Stimulus Group [single, group] - %s' % (pinfo.glm_stim_group)   
		

			#       Soft linking bucket into a single directory
			# subject directory
			sys_cmd = 'ln -s %s/%s%s %s/%s%s' % (dir_analyzed_subj, fname_glm_buck, pinfo.file_type, \
				dir_final, fname_glm_buck, pinfo.file_type)
			check_and_run(sys_cmd, dir_final, fname_glm_buck, pinfo.file_type, debug)
			
			# zipping errts file
			sys_cmd = 'gzip %s/%s%s' % (dir_analyzed_subj, fname_glm_err, pinfo.file_type)
			check_and_run(sys_cmd, dir_analyzed_subj, fname_glm_err, pinfo.file_type + '.gz', debug)
        
        else:
            # concatenate all runs into one file, then run same processes
            print
            print '*** CONCATENATING RUNS ***'
            # initialize list
            fmri_list = []
            
            
            # extract the list to make things a bit cleaner
            for fmri_name in info_subj[subj]['fmri']:
                if fmri_name != 'xxx':
                    fmri_list.append(fmri_name)
            
            # sort the list so that the runs are (hopefully) in order
            fmri_list_sorted = sorted(fmri_list)
            
            
            # conactenate the files into one
            all_names = []
            all_names_censor = []
            for cur_name in fmri_list_sorted:
                all_names.append(dir_processed + '/final/' + subj + '_' + cur_name + '_' + pinfo.pipeline_id + pinfo.file_type)
                all_names_censor.append(dir_processed + '/final/' + subj + '_' + cur_name + '_' + pinfo.pipeline_id + '_censor.1D')
            
            cmd_afni_3dTcat(all_names, dir_analyzed_subj, subj + '_concat', pinfo.file_type, debug)
            
            # also concat the censor files
            for name in all_names_censor:
                    run_cmd('cat ' + name + ' >> ' + dir_analyzed_subj + '/' + subj + '_concat_censor.1D', debug)
            
            # CONCAT THE STIM FILES! ugh ###############################################################################
            if pinfo.glm_stim_per_subj == 'yes' and pinfo.glm_stim_per_run == 'yes':
                if pinfo.glm_stim_model == '1D': 
                    
                    # simple concat of 1D files :)
                    for stim_name in pinfo.glm_stim_suffix.split(','):
                        for name in fmri_list_sorted:
                            run_cmd('cat ' + pinfo.glm_dir_stim + '/' + subj + '/' + subj + '_' + name + '_' + stim_name + ' >> ' \
                                + dir_analyzed_subj + '/' + subj + '_concat_stim_' + stim_name + '.1D', debug)
                                
                else:
                    
                    # not-so-simple concat of stimulus times :(
                    for stim_name in pinfo.glm_stim_suffix.split(','):
                        count = 0
                        all_times = []
                        for name in fmri_list_sorted:
                            
                            # find how many TRs are in raw data (if specified to do so)
                            if pinfo.fmri_nt==-1:
                                num_TR = cmd_fslval(dir_recon, subj + '_' + name, pinfo.file_type, '4', debug)
                                num_TR = int(num_TR)
                            else:
                                num_TR = pinfo.fmri_nt
                            
                            
                            temp_times = [[int(i) for i in line.split()] for line in open(pinfo.glm_dir_stim + '/' + subj + '/' + subj + '_' + name + '_' + stim_name)]
                            
                            temp_times = double(temp_times)
                            temp_times = temp_times + count*pinfo.fmri_TR*num_TR
                            all_times.append(str(temp_times))
                            all_times.append('\n')
                            count = count + 1 
                            
                        # write the new concatenated stim times to a txt file
                        f=open(dir_analyzed_subj + '/' + subj + '_concat_stim_' + stim_name, 'w')
                        for line in all_times:
                            words = line
                            words = words.replace('[','')
                            words = words.replace(']','')
                            words = words.replace('.','')
                            words = words.replace(' ','')
                            f.write(words)
                        f.close()
                    
            
            elif pinfo.glm_stim_per_subj == 'no' and pinfo.glm_stim_per_run == 'yes':
                
                if pinfo.glm_stim_model == '1D': 
                    
                    # simple concat of 1D files :)
                    for stim_name in pinfo.glm_stim_suffix.split(','):
                        for name in fmri_list_sorted:
                            run_cmd('cat ' + pinfo.glm_dir_stim + '/' + name + '_' + stim_name + ' >> ' \
                                + dir_analyzed_subj + '/' + 'concat_stim_' + stim_name + '.1D', debug)
                                
                else:
                    
                    # not-so-simple concat of stimulus times :(
                    for stim_name in pinfo.glm_stim_suffix.split(','):
                        count = 0
                        all_times = []
                        for name in fmri_list_sorted:
                            num_TR = pinfo.fmri_nt
                            temp_times = [[int(i) for i in line.split()] for line in open(pinfo.glm_dir_stim + '/' + name + '_' + stim_name)]
                            
                            temp_times = double(temp_times)
                            temp_times = temp_times + count*pinfo.fmri_TR*num_TR
                            all_times.append(str(temp_times))
                            all_times.append('\n')
                            count = count + 1 
                            
                        # write the new concatenated stim times to a txt file
                        f=open(dir_analyzed_subj + '/' + 'concat_stim_' + stim_name, 'w')
                        for line in all_times:
                            words = line
                            words = words.replace('[','')
                            words = words.replace(']','')
                            words = words.replace('.','')
                            words = words.replace(' ','')
                            f.write(words)
                        f.close()
            
            
            elif pinfo.glm_stim_per_subj == 'no' and pinfo.glm_stim_per_run == 'no':
                
                if pinfo.glm_stim_model == '1D': 
                    
                    # simple concat of 1D files :)
                    for stim_name in pinfo.glm_stim_suffix.split(','):
                        for name in fmri_list_sorted:
                            run_cmd('cat ' + pinfo.glm_dir_stim + '/' + stim_name + ' >> ' \
                                + dir_analyzed_subj + '/' + 'concat_stim_' + stim_name + '.1D', debug)
                                
                else:
                    
                    # not-so-simple concat of stimulus times :(
                    for stim_name in pinfo.glm_stim_suffix.split(','):
                        count = 0
                        all_times = []
                        for name in fmri_list_sorted:
                            
                            num_TR = pinfo.fmri_nt
                            temp_times = [[int(i) for i in line.split()] for line in open(pinfo.glm_dir_stim + '/' + stim_name)]
                            
                            temp_times = double(temp_times)
                            temp_times = temp_times + count*pinfo.fmri_TR*num_TR
                            all_times.append(str(temp_times))
                            all_times.append('\n')
                            count = count + 1 
                            
                        # write the new concatenated stim times to a txt file
                        f=open(dir_analyzed_subj + '/' + 'concat_stim_' + stim_name, 'w')
                        for line in all_times:
                            words = line
                            words = words.replace('[','')
                            words = words.replace(']','')
                            words = words.replace('.','')
                            words = words.replace(' ','')
                            f.write(words)
                        f.close()
                
            ##########################################################################################################
            
            print
            print  "**** ANALYZING fMRI - %s - CONCATENATED ****" % (subj)

            dir_subj = '%s/final' % (dir_processed, )
            fname_fmri = subj + '_concat'
            fname_mask = '%s_%s_%s_mask' % (subj, fmri_list_sorted[0], pinfo.pipeline_id)
            fname_censor = '%s_%s_%s_censor.1D' % (subj, fmri_name, pinfo.pipeline_id)

            # If censor file doesn't exist, wipe it's name, these may or may no tbe created at the end of process_fmri
            if not os.path.exists(dir_final + '/' + fname_censor):
                fname_censor = ''
                
            # If mask  file doesn't exist, wipe it's name, these may or may no tbe created at the end of process_fmri
            if not os.path.exists(dir_final + '/' + fname_mask):
                fname_mask = ''
            
            if pinfo.glm_enable:
                # Initialize stim file construction
                stim_prefix = ''
                                
                if pinfo.glm_stim_model == 'ROI':    # if ROI based
                    roi_list = pinfo.glm_roi_list.split(',')
                    if pinfo.roi_type=='group':                 # Figure out ROI masks
                        fname_roi_mask = pinfo.glm_roi_fname
                    elif pinfo.roi_type =='subj':
                        fname_roi_mask = '%s_%s' % (subj, pinfo.glm_roi_fname)
                    print 'Generating ROI values - %s ' % (fname_roi_1D)
                    # Create 1D files based on masks
                    fname_roi_1D = create_1D(pinfo.glm_roi_dir, fname_roi_mask, roi_list, \
                         dir_subj, fname_active, dir_subj, fname_roi_1D, pinfo.file_type, debug)
                    pinfo.glm_dir_stim = dir_subj
                    pinfo.glm_stim_suffix = fname_roi_1D
                  
                elif pinfo.glm_stim_per_subj == 'yes':
                    stim_prefix = subj + '_concat_stim_'
                
                elif pinfo.glm_stim_per_subj == 'no':
                    stim_prefix = 'concat_stim_' 
                
                if pinfo.glm_stim_grouping == 'single' or pinfo.glm_stim_model == 'ROI':
                    for stim_name in pinfo.glm_stim_suffix.split(','):
                        fname_buck_out = '%s_%s' % (fname_fmri , stim_name.split('.')[0])
                        fname_glm_buck, fname_glm_err = create_3dDecon(dir_analyzed_subj, fname_fmri, \
                            pinfo.fmri_TR, dir_analyzed_subj, fname_buck_out, dir_analyzed_subj, fname_censor, \
                            dir_subj, fname_mask, '', '', '', \
                            '', '', 0, '0', \
                            dir_analyzed_subj, stim_prefix, (stim_name,), pinfo.glm_stim_model, \
                            pinfo.glt_enable, pinfo.glt_dir, pinfo.glt_labels, pinfo.file_type, debug)
                
                
                elif pinfo.glm_stim_grouping == 'all':
                    fname_glm_buck, fname_glm_err = create_3dDecon(dir_analyzed_subj, fname_fmri, \
                        pinfo.fmri_TR, dir_analyzed_subj, fname_fmri, dir_analyzed_subj, fname_censor, \
                        dir_subj, fname_mask, '', '', '', \
                        '', '', 0, '0', \
                        dir_analyzed_subj, stim_prefix, pinfo.glm_stim_suffix.split(','), pinfo.glm_stim_model, \
                        pinfo.glt_enable, pinfo.glt_dir, pinfo.glt_labels, pinfo.file_type, debug)
                else:
                    raise SystemExit, 'ERROR - Improper Stimulus Group [single, group] - %s' % (pinfo.glm_stim_group)   

            #       Soft linking bucket into a single directory
            # subject directory
            sys_cmd = 'ln -s %s/%s%s %s/%s%s' % (dir_analyzed_subj, fname_glm_buck, pinfo.file_type, \
                dir_final, fname_glm_buck, pinfo.file_type)
            check_and_run(sys_cmd, dir_final, fname_glm_buck, pinfo.file_type, debug)
            
            if options.clean:
                print '*** REMOVING CONCATENATED .nii FILES ***' 
                if os.path.exists(dir_analyzed_subj + '/' + subj + '_concat' + pinfo.file_type):
                    run_cmd('rm ' + dir_analyzed_subj + '/' + subj + '_concat' + pinfo.file_type, debug)
                    
                # zipping errts file
                sys_cmd = 'gzip %s/%s%s' % (dir_analyzed_subj, fname_glm_err, pinfo.file_type)
                check_and_run(sys_cmd, dir_analyzed_subj, fname_glm_err, pinfo.file_type + '.gz', debug)
			
fileName = 'REDCap_import_files/all/'+ subj + '_' + stimulus_suffix + '_analyzed_parameters.txt'				
with open(fileName,'w') as thefile:
	thefile.write('dir_dcm_base,' + pinfo.dir_dcm_base + ',Base Directory\n')
	thefile.write('dir_analyzed,' + pinfo.dir_analyzed + ',Analyzed Directory\n')
	thefile.write('dir_processed,' + pinfo.dir_processed + ',Processed Directory\n')
	thefile.write('dir_recon,' + pinfo.dir_recon + ',Recon Directory\n')
	process_order = ';'.join(list_process)
	thefile.write('pipeline_order,' + process_order + ',Order of processing\n')
	thefile.write('glm_dir_stim,' + pinfo.glm_dir_stim + ',Stimulus File Directory\n')
	thefile.write('glm_stim_model,' + pinfo.glm_stim_model + ',Stimulus Model Type\n')
	thefile.write('glm_stim_suffix,' + pinfo.glm_stim_suffix + ',' + fmri_name + ' Stim File Selection\n')
thefile.close
            
            
