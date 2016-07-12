#!/usr/bin/env python
#
#  process_fmri_parameters.py
#
#  Contains the classes needed to interact with the parameter files used by process_fmri.py
#  for the processing of RSN data
#
#   NOTES
#      INITIAL CREATION
#
#   AUTHOR - Wayne Lee
#   Created - April 3, 2012
#   REVISIONS 
#       2012-04-03 - WL - First Created and checked into respository


import string
import os
from numpy import *
from time import gmtime, strftime

# asl analysis parameter class
class process_fmri_parameters():
# allowable parameter variable types, anything else is considered a comment
    variable_types = ('int', 'float', 'string')

# Template for input/output of parameter files 
#    (parameter_name, parameter_type, paramter comment)
#   type = 'comment' means it's a comment line in the parameter file
#   type = 'header' means it's a special comment which will embed the supplied parameter within a comment
#                  Used to provide a quick summary at the top of the output file
    template = [ \
        ('' , 'comment', '########################################################'),
        ('' , 'comment', '#### Process Pipeline information ######################'),
        ('' , 'comment', '########################################################'),            
        ('' , 'comment', '# NOTE : Individual directories will be created for each subject #'),            
        ('fname_pipeline' ,'string','Name of the pipeline information file'),
        ('pipeline_id' ,'string','Process Pipeline ID'),
        ('pipeline_descrip' ,'string','One line description of the pipeline'),
        ('dir_dcm_base' ,'string', 'Base directory for raw dicom files '),
        ('dir_analyzed' ,'string','Output directory for analyzed data, final directory = output_dir/<subject_id>_<pipeline_id>'),
        ('dir_processed' ,'string','Output directory for processed data, final directory = output_dir/<subject_id>_<pipeline_id>'),
        ('dir_recon','string','Output directory base for recon'),
        ('pipeline_order', 'string', 'Processing pipeline steps to run, comma separated and in order'),
        ('use_short_names', 'int', 'Use <pipeline_id> as suffix for final processed file names (ie. c41_pipe_01.nii) [0 = No, 1 = Yes]'),
        ('create_link_dir', 'int', 'Create soft links in output_dir/processed to all final processed filenames[0 = No, 1 = Yes]'),
        ('dcm_type','string','Dicom organization [single - one dcm file for all slices; dir - directory of dcm files for all slices]'),
        ('dcm_filename','string','file extension for dicom files'),
        ('file_type', 'string', 'What file type to use [.nii, +orig]'),
        ('' , 'comment', '#### fMRI DATA INFO ####################################'),
        ('fmri_order','string','dcm slice order [tz, zt]'),
        ('fmri_nz' ,'int', 'Number of slices'),
        ('fmri_1stfile', 'string','Name of first file in raw dicom directory'),
        ('fmri_nt' ,'int', 'Number of TR'),
        ('fmri_TR' ,'float', 'TR (s)'),
        ('fmri_sliceorder' , 'string', 'Slice order (AFNI terminology, ie. seqplus) '),
        ('' , 'comment', '#### DROP SCANS (automatic) ############################'),
        ('drop_begin' ,'int','How many scans to drop from the beginning of fMRI'),
        ('drop_end', 'int', '# How many scans to drop from the end of fMRI'),
        ('','comment','#### PHYSIOLOGICAL NOISE CORRECTION (phys) #############'),
        ('phys_type','string','Type of physiological noise correction [retroicor, phycaa]'),
        ('phys_cardiac_suffix','string','Cardiac flag ie. CTL01_CMT1_card.txt'),
        ('phys_resp_suffix','string','Cardiac flag ie. CTL01_CMT1_resp.txt'),
        ('' , 'comment', '#### SLICE TIMING CORRECTION (st) ######################'),
        ('st_ignore','int', 'How many initial scans to ignore [0 = none]'),
        ('' , 'comment', '#### MOTION CORRECTION (mc) ############################'),
        ('mc_refvol' ,'int','Which reference volume to use, after scans have been dropped [0+ = volume # (0 relative)]'),
        ('mc_outlier_MD', 'float', 'Maximum displacement threshold (mm) [set to 0 to turn off]'),
        ('','comment','#### REGISTRATION (reg) ################################'),
        ('reg_ref','string','What reference space to align into [MNI_2mm, fMRI]'),
        ('ref_to_fmri','int','if reg_ref = fmri, 1 = also register MNI, HarvardOxford, CSF/WM ROIs to the fMRI space'),
        ('roi_to_fmri','int','1 = register roi (from tfilt) to fmri space (requires reg_ref=fmri), 0 = off'), 
        ('atlas_to_fmri','int','1 = register atlas to fmri space (requires reg_ref=fmri), 0 = off'),
        ('atlas_dir','string','directory of above atlas'),
        ('atlas_list','string','fname of above atlas'),
		('atlas_alias','string','short-form names for atlas_fnames used in naming output files'),
        ('reg_method','string','Which registration method [flirt or fnirt]'),
        ('reg_dof_EPI_anat','int','DOF for EPI->ANAT registration [7]'),
        ('reg_dof_anat_ref','int','DOF for ANAT->REF registration [12]'),
        ('reg_fnirt_config','string','for fnirt based registrations, config file [T1_2_MNI152_2mm.cnf]'),
        ('','comment','#### SMOOTHING (sm) ####################################'),
        ('sm_type','string','type of smoothing [2D, 3D]'),
        ('sm_fwhm','float','Smoothing kernal size (mm)'),
        ('','comment','#### TEMPORAL FILTERING (tfilt) #############'),
        ('det_order','string','detrending order [AFNI like ie. -1 = off, A = auto]'),
        ('hp_cutoff','float','high pass filter frequency [0 = off]'),
        ('lp_cutoff','float','low pass filter frequency [0 = off]'),
        ('mpr_type','string','What type of mpr [none, mpe, MD]'),
        ('roi_type','string','What type of ROI regression [none, subj, group]'),
        ('roi_dir','string','Base directory of 4D ROI mask (for subj specific ROIs, assumes common directory ie. <roi_dir>)'),
        ('roi_fname','string','Filename for 4D ROI masks (for subj specific ROIs,  this is a prefix ie. <subj>_<roi_fname><file_type>'),
        ('roi_list','string','List of ROI names'),
        ('roi_wholebrain','int','use subjects function mask as a whole-brain regressor'),
        ('','comment','#### BASELINE AVERAGING (bavg) #########################'),
        ('bavg_dir_1D','string','Directory for file (1D) which identifies baseline scans (with a 1)'),
        ('bavg_fname_1D','string','File (1D) which identifies baseline scans (with a 1) [Leave blank if all scans are to be used]'),
        ('','comment','#### GLM Analysis (glm) #########################'),
        ('glm_enable','int','Run GLM Analysis?'),
        ('glm_dir_stim','string','Directory of stimuli'),
        ('glm_stim_model','string',"What stimulus model to use ('1D' - stim file is a full 1D file; 'ROI' - create 1D files from ROIs;or AFNI type ie. BLOCK(20,1))"),
        ('glm_stim_per_subj','string','Separate Stimulus per subject? [yes/no]'),
        ('glm_stim_per_run','string','Separate Stimulus per run? [yes/no]'),
        ('glm_stim_suffix','string','List of stimulus names (where approporiate <subj>_<run>_<suffix>)'),
		('glm_stim_censor_enable','int','turn off/on stim censoring, for example in event-related motion-coupled tasks'),
		('glm_stim_censor','string','file to censor certain TRs (for example to censor event-related motion in foot-flexion task) - will be multiplied with motion-censor file'),
        ('glm_stim_grouping','string','How to group stimuli (single - separate analysis for each stim; combo - combined analysis for all stim)'),
        ('glm_roi_type','string','What type of ROI regression [none, subj, group]'),
        ('glm_roi_dir','string','Base directory of 4D  ROI mask (for subj specific ROIs, assumes common directory ie. <roi_dir>)'),
        ('glm_roi_fname','string','Filename for 4D ROI masks (for subj specific ROIs,  this is a prefix ie. <subj>_<roi_fname><file_type>'),
        ('glm_roi_list','string','List of ROI names'),
        ('glt_enable','int','Run GLTs? (0 to turn off)'),
        ('glt_dir','string','directory containing GLTs'),
        ('glt_labels','string','Suffix of GLTs "GLT_<suffix>.txt"'),
        ('concat_enable','int','concatenate runs (when suubjects perform multiple runs and you want to average them)'),
        ( '', 'comment', '#### End of File #######################################') ]
        
    def __init__(self):
        # loading in template list and creating members in book_keeping class
        for pname, ptype, comment in self.template:
            if ptype in self.variable_types:             # ignore comment lines
                if hasattr(self, pname):                  # check for duplicate variables
                    raise ValueError, 'ERROR - Duplicate names in book keeper template definitions: %s' % (pname,)
                setattr(self, pname, None)                # assuming everything's okay, create member

    def _load(self, dir, filename):                      # Read parameter info
        full_path = dir + '/' + filename                # check that parameter file exists
        if not os.path.exists(full_path):
            raise SystemExit, 'ERROR - Parameter File - File not found: %s' % (full_path,) 

        # Creating quick hash file for looking up parameter types
        template_hash = {}
        for name, dtype, comment in self.template:
            if dtype in self.variable_types:
                template_hash[name] = dtype

        # Open parameter file for reading
        f = open(full_path,'r')
        line_count = 0;
        for line in f:
            line_count = line_count + 1
            if not line.startswith('#'):                               # ignore header lines
                # Line format = "parameter name := parameter value        # comment"
                line_parsed = line.partition(':=')                     # Split line into "name" and "value + comment"
                parameter_name = line_parsed[0].strip()                # isolate parameter name
                if not hasattr(self,parameter_name):                   # Check if parameter name exists
                    raise SystemExit, 'ERROR - Parameter File - Unknown parameter name: Line %s - %s' % (str(line_count), parameter_name)
                parameter_type = template_hash[parameter_name]
 
                parameter_value = line_parsed[2].partition('#')        # Split "value + comment"
                parameter_value = parameter_value[0].strip()           # isolate parameter value

                if parameter_value.startswith('['):                    # check if parameter is an array
                    parameter_value = parameter_value.strip('[')       # remove parantheses
                    parameter_value = parameter_value.strip(']')
                    if parameter_value.find(',') == -1:                # allowable delimiters are ' ' or ','
                        parameter_value = parameter_value.split()
                    else:
                        parameter_value = parameter_value.split(',')
                if parameter_type == 'int':                       # Check variable type - Int
                    parameter_value = int(parameter_value)     
                elif parameter_type == 'float':                   # Check variable type - Float
                    parameter_value = float(parameter_value)     
                else:                                                 # else string
                    parameter_value = str(parameter_value)
                setattr(self,parameter_name,parameter_value)            # Update parameter value with whatever we loaded
        f.close()
        self.user_name = os.getenv('LOGNAME')

    def _save(self):
        full_path = self.output_dir + '/' + self.info_name
#   Preparing output log information
        self.timestamp = strftime('%X %x %Z')
		
#   Save will overwrite any existing parameter file of the same name (for now)
#        if os.path.exists(full_path):         
#            raise SystemExit, 'ERROR - Parameter File - File not found (' + full_path + ')'
        f = open(full_path,'w')
        for pname, ptype, pcomment in self.template:
            if ptype in self.variable_types:             # ignore comment lines
                f.write('%s := %s \t\t\t\t\t\t\t # %s \n' % (pname, str( getattr(self,pname)), pcomment) )
            elif ptype == 'header':
                f.write(pcomment % str(getattr(self,pname)) + '\n' )
            else:
                f.write(pcomment + '\n')
        f.close()
