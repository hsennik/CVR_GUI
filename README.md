# Cerebrovascular Reactivity (CVR) - A Graphical User Interface for processing, analyzing, and viewing a subject's CVR data, and generating a clinical diagnostic report.

## Getting Started

Run SickKids_CVR.m

### Prerequisities

* An account on SickKids server Ontasian (Tatooine)
* VNC Viewer
* Basic Linux knowledge
* Ability to run MATLAB 

### Built With

* MATLAB - the entire GUI
* Python - the process and analyze pipelines

### Authors

* **Hannah Sennik** - *Initial work* - (https://github.com/hsennik)

### Acknowledgments

* Wayne Lee, Ben Morgan - process_fmri.py, analyze_fmri.py
* Stimulate (One of the earliest fMRI software package from CMRR at University of Minnesota)
* AFNI - a set of C programs for processing, analyzing, and displaying functional MRI (FMRI) data
* FSL - comprehensive library of analysis tools for FMRI, MRI and DTI brain imaging data

## List of Functions
### Step 1: Process/Analyze Subject
### process_subject.m 
#### Processing
* processing_pipeline.m - run the subject through the processing pipeline
* tissue_segmentation.m - run fsl fast to segment white matter, gray matter, and csf
#### Boxcar
* adjust_boxcar.m - specifying that boxcar adjustments must be made
* adjust_sigvals.m - adjusting the contrast of the anatomical data 
* average_brain_timeseries.m - extracting the average brain timeseries to display to the user 
* bselection.m - radio button selection (standard, shifted, customized boxcar)
* close_customized_windows.m - when customized boxcar is confirmed, close all windows used to create the customized boxcar 
* closewindows.m - close all windows except main GUI when standard boxcar is selected
* completelycustomized.m - create a completely customized boxcar 
* create_boxcar.m - create a customized boxcar 
* create_boxcar_textfiles.m - save the customized boxcar as a .1D file
* drawROI_copy.m - draw an ROI on an anatomical slice and extract the timeseries to display to the user (plot it against the boxcar)
* plotfiles.m - plot the extracted timeseries against a stimulus file 
* refresh_customized.m - refresh the customize boxcar window where the user can input values 
* save_shifted_to_file.m - save the shifted boxcar to a .1D file
* shift_boxcar.m - shift the standard boxcar using a slider on the plot figure
* standard_selected.m - when standard boxcar is selected, call the function to close all additional windows 
* viewboxcar.m - view the customized boxcar after it has been created 
#### Analysis
* analyze_subject.m - run the subject through the analysis pipeline using the selected boxcar/stimulus file 
#### Change the interface
* first_gui_again.m - refresh the Process/Analyze Subject interface
* go_to_main.m - go back to SickKids_CVR.m to select a different step 
