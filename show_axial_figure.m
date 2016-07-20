function show_axial_figure(subj,directories,main_GUI,bhselection)
% Function to show the axial slices in a figure so that the user can select
% an ROI and pull the timeseries. This is used so that they can find the
% general peaks and troughs of the data and adjust the boxcar if needed.
% 
% INPUTS 
%     subj - subject data (name,date,breathhold)
%     directories - all of the directories for the subject
%     main_GUI - structure that has information linked to the main figure
%     bhselection - stores breathhold selection data (BH1, BH2 OR HV)
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 13, 2016
% Author - Hannah Sennik

subj.breathhold = bhselection; % breathhold selection

GUI = 1; % indicates to slider_position.m which GUI the slider belongs to - processing GUI (1) OR viewing GUI (2)

anat_filelocation = ['data/recon/' subj.name '/' subj.name '_anat_brain.nii']; % find the subject's anatomical data
fname_anat = anat_filelocation;

anat = load_nii([directories.subject '/' fname_anat]); % Load the subject's 3D skull stripped anatomical 
[anat.x,anat.y,anat.z] = size(anat.img); % get the size of anatomical

%  CONSTRUCTING ANATOMICAL SLICES

%  Initial slice position - values can be changed 
anat.slice_x = 120;
anat.slice_y = 104; 
anat.slice_z = 69; 

global ax_slider_value;
ax_slider_value = anat.slice_z; % initial value of the slider

%  Slice ranges
anat.xrange = (1:anat.x);
anat.yrange = (1:anat.y);
anat.zrange = (1:anat.z); 

%  Adjusting the contrast of the anatomical scans (shrink the window of the range of values)
anat.sigmin = 10; 
anat.sigmax = 500; 

%  Preparing slices to be displayed in each dimension 
%  AXIAL slice
anat.slice_ax = (double(repmat(imresize(squeeze(anat.img(:,:,anat.slice_z)),[anat.x anat.y]), [1 1 3]))- anat.sigmin) / anat.sigmax ;
anat.slice_ax = imresize(anat.slice_ax,[anat.x anat.y/anat.hdr.dime.pixdim(1)]);
anat.slice_ax = rot90(anat.slice_ax(anat.xrange,anat.yrange,:));
anat.slice_ax = flip(anat.slice_ax,2);      

%  Load in the functional data that comes out of the processing pipeline,
%  map to anatomical space and then load that nii 
functional_data = ['data/processed/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii'];
funct = load_nii([directories.subject '/' functional_data]);

%  Check if the standard stimfiles are the correct length, adjust them if
%  not, then copy them to metadata/stim
funct.time = funct.hdr.dime.dim(5);

standard_boxcar = [directories.matlabdir '/python/standard_boxcar.1D'];
standard_HV = [directories.matlabdir '/python/standard_HV.1D'];
stim_BH1 = [directories.subject '/' directories.metadata '/stim/bhonset' subj.name '_BH1.1D'];
stim_BH2 = [directories.subject '/' directories.metadata '/stim/bhonset' subj.name '_BH2.1D'];
stim_HV = [directories.subject '/' directories.metadata '/stim/bhonset' subj.name '_HV.1D'];

fileID = fopen(standard_boxcar, 'rt');
assert(fileID ~= -1, 'Could not read: %s', standard_boxcar);
x = onCleanup(@() fclose(fileID));
count = 0;
while ~feof(fileID)
    count = count + sum( fread( fileID, 16384, 'char' ) == char(10) );
end

fileID = fopen(standard_boxcar, 'r');
if(count > funct.time)
    for i = 1:abs(count - funct.time)
        fgetl(fileID);
    end
    buffer = fread(fileID,Inf);
    fclose(fileID);
    fileID = fopen(stim_BH1,'w+');
    fwrite(fileID,buffer);
    fclose(fileID);
    copyfile(stim_BH1,stim_BH2,'f');    
elseif(count < funct.time)
    copyfile(standard_boxcar,stim_BH1,'f');
    fileID = fopen(stim_BH1,'a');
    for i = 1:abs(funct.time - count)
        fprintf(fileID,format,0);
    end
    fclose(fileID);   
end

fileID = fopen(standard_HV, 'rt');
assert(fileID ~= -1, 'Could not read: %s', standard_HV);
x = onCleanup(@() fclose(fileID));
count = 0;
while ~feof(fileID)
    count = count + sum( fread( fileID, 16384, 'char' ) == char(10) );
end

fileID = fopen(standard_HV, 'r');
if(count > funct.time)
    for i = 1:abs(count - funct.time)
        fgetl(fileID);
    end
    buffer = fread(fileID,Inf);
    fclose(fileID);
    fileID = fopen(stim_HV,'w+');
    fwrite(fileID,buffer);
    fclose(fileID);  
elseif(count < funct.time)
    copyfile(standard_boxcar,stim_HV,'f');
    fileID = fopen(stim_HV,'a');
    for i = 1:abs(funct.time - count)
        fprintf(fileID,format,0);
    end
    fclose(fileID);   
end


%  Create the entire interface panel
axial.f = figure('Name', ['Axial Subject Data: ' subj.breathhold],...
                'Visible','on',...
                'Position',[350,800,600,500],...
                'numbertitle','off');
set(axial.f, 'MenuBar', 'none'); % remove the menu bar 
set(axial.f, 'ToolBar', 'none'); % remove the tool bar  

axial.userprompt = uicontrol('Style','text',...
                    'units','normalized',...
                    'Position',[0.05,0.9,0.9,0.1],...
                    'String',['Please specify an ROI to extract the ' subj.breathhold ' timeseries and adjust the standard boxcar or create a new one']);

%  Text that displays the slider/slice position
ax_window.position_slider = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'String',anat.slice_z,...
                                    'position',[0.03 0.22 0.1 0.15]);   

%  Button to draw ROI and graph the timeseries 
ax_window.drawROI = uicontrol('Style','pushbutton',...
                                'Visible','on',...
                                'String','Draw ROI',...
                                'Value',0,'Position',[100,5,100,40],...
                                'Callback',{@drawROI_copy,anat,directories,subj,ax_window,bhselection,funct}); 

%  Slider to control axial slice position                       
ax_window.slider = uicontrol('style', 'slider',...
                            'Min',1,'Max',anat.z,'Value',anat.slice_z,... 
                            'units', 'normalized',...
                            'SliderStep',[1/anat.z,10/anat.z],...
                            'position',[0.04 0.45 0.08 0.25],...
                            'callback',{@sliderpos_ax,anat,main_GUI,funct,ax_window,directories,subj,GUI});

%  Descriptive text of slider/slice position    
ax_window.text_slider = uicontrol('Style', 'text',...
                                'units', 'normalized',...
                                'position', [0.03 0.73 0.1 0.15],...
                                'String', 'Axial Slice Position');

%  Button to close the windows
ax_window.closewindows = uicontrol('Style','pushbutton',...
                                'Visible','on',...
                                'String',['Done adjusting boxcar for: ' subj.breathhold],...
                                'Value',0,'Position',[270,5,250,40],...
                                'Callback',{@closewindows,subj});                             

axes,      
imshow(anat.slice_ax);
end