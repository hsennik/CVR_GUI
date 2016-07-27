# CVR_GUI
Matlab files for CVR GUI 

Wayne please look at these files 

**look_at_CVR_data.m**

This is the main user interface where clinician can LOOK at data 

**CVRmap.m**

This file creates the CVR map to overlay on to axial anatomical image (please refer to this for the **colour map** issue) 

**drawROI.m**

This function takes the drawn region, converts it in to a mask, and ideally pulls the **timeseries** from the functional data. Having issues right now because I can't convert logical (the mask) to nii.

**process_subject.m**

This is the first GUI that the user will see where they can select the subject to completely process and analyze 

