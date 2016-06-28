# CVR_GUI
Matlab files for CVR GUI 

Wayne please look at these files 

**basic_UI_function**

This is the main user interface where clinician can LOOK at data 

**CVRmap_function_axial**

This file creates the CVR map to overlay on to axial anatomical image (please refer to this for the **colour map** issue) 

**drawROI**

This function takes the drawn region, converts it in to a mask, and ideally pulls the **timeseries** from the functional data. Having issues right now because I can't convert logical (the mask) to nii.

**run_python**

This is the first GUI that the user will see where they can select the subject to completely process and analyze 

**startprocessing**

This is the function called by run_python where all of the processing and analysis occurs 
