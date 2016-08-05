function make_montage(source,callbackdata,anat,funct,mp,type,subj,directories,montage_info)
% Function to make montage from saved axial slice images 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     funct - 4D functional subject data
%     mp - GUI data
%     type - type of processing and stimfile 
%     subj - subject data (name,date,breathhold)
%     directories - strings for all relevant directories
%     montage_info - to be used in final filename for montage 
%
% *************** REVISION INFO ***************
% Original Creation Date - June 27, 2016
% Author - Hannah Sennik

global onlypositive;
global onlynegative;

handles = guidata(source);
%  Create directory to hold all images that will create the montage
mkdir(directories.subject,[directories.montagedir '/' subj.name '_' subj.breathhold '_' type '_' mp.t_number.String '/']);
gen_file_location = [directories.subject '/' directories.montagedir '/' subj.name '_' subj.breathhold '_' type '_' mp.t_number.String '/'];

%  For loop to cycle through calling the function to save CVR slices
%  as jpg
for i = 15:5:140 % save 25 slices to create 5 by 5 montage, save every six slices 
    anat.slice_z = i;
    CVRmap_for_montage(anat,funct,mp,i,gen_file_location,handles,subj); % call the CVRmap_for_montage.m function 
end

%  Generate file names for each of the CVR slice images 
fileNames = {strcat(gen_file_location,'slice15.jpg'),strcat(gen_file_location,'slice20.jpg'),strcat(gen_file_location,'slice25.jpg'),strcat(gen_file_location,'slice30.jpg'),strcat(gen_file_location,'slice35.jpg'),strcat(gen_file_location,'slice40.jpg'),strcat(gen_file_location,'slice45.jpg'),strcat(gen_file_location,'slice50.jpg'),strcat(gen_file_location,'slice55.jpg'),strcat(gen_file_location,'slice60.jpg'),strcat(gen_file_location,'slice65.jpg'),strcat(gen_file_location,'slice70.jpg'),strcat(gen_file_location,'slice75.jpg'),strcat(gen_file_location,'slice80.jpg'),strcat(gen_file_location,'slice85.jpg'),strcat(gen_file_location,'slice90.jpg'),strcat(gen_file_location,'slice95.jpg'),strcat(gen_file_location,'slice100.jpg'),strcat(gen_file_location,'slice105.jpg'),strcat(gen_file_location,'slice110.jpg'),strcat(gen_file_location,'slice115.jpg'),strcat(gen_file_location,'slice120.jpg'),strcat(gen_file_location,'slice125.jpg'),strcat(gen_file_location,'slice130.jpg'),strcat(gen_file_location,'slice135.jpg')};

%  Create window to display montage
montage_window.f = figure('Name', 'Montage',...  
                        'Visible','on',...
                        'numbertitle','off');
                    
set(mp.f, 'MenuBar', 'none'); % remove the menu bar 
set(mp.f, 'ToolBar', 'none'); % remove the tool bar                     

%  Create 5 by 5 montage
mymontage = montage(fileNames, 'Size', [5 5]);

%  Create directory for clinician to view final montage
directories.cliniciandir = 'clinician_final';
mkdir(directories.subject,['/' directories.cliniciandir '/']);

mask_name = handles.predetermined_ROI.String(handles.predetermined_ROI.Value);

if strcmp(mask_name,'Remove Ventricles and Venosinuses') == 1
    mask_name = 'masked_csf';
elseif strcmp(mask_name,'Only White Matter') == 1
    mask_name = 'whitematter';
elseif strcmp(mask_name,'Only Gray Matter') == 1
    mask_name = 'graymatter';
elseif strcmp(mask_name,'Only Cerebellum') == 1
    mask_name = 'cerebellum';
elseif strcmp(mask_name,'None') == 1
    mask_name = 'whole_brain';
elseif strcmp(mask_name,'') == 1
    mask_name = 'whole_brain';
end

if onlypositive == 1 && onlynegative == 0
    separated = '_positive';
elseif onlynegative == 1 && onlypositive == 0
    separated = '_negative';
else 
    separated = '';
end

%  Write the montage to the clinician file
imwrite(mymontage.CData,[directories.subject '/' directories.cliniciandir '/' subj.name '_' subj.breathhold '_' type '_' mp.t_number.String '_' mask_name separated '_montage.jpg']); % the file name includes subject name, breathhold, processing, boxcar type, and tstat value 

%  Display the montage in the montage window
display('Montage saved');

%  If clinician generates a montage, move the parameter data used for that
%  montage to a the final REDCap folder
mkdir([directories.subject, '/' directories.REDCapdir '/final']);
if strcmp(mp.menu(2).String(mp.menu(2).Value),'yes') == 1 % user selected processed data on main GUI
    copyfile([directories.subject '/' directories.REDCapdir '/all/' subj.name '_processed_parameters.txt'],[directories.subject '/' directories.REDCapdir '/final/' subj.name '_processed_parameters.txt'],'f');
else % raw data 
    copyfile([directories.REDCapdir '/all/' subj.name '_not_processed_parameters.txt'],[directories.REDCapdir '/final/'],'f');
end
copyfile([directories.subject '/' directories.REDCapdir '/all/' subj.name '_' montage_info '_analyzed_parameters.txt'],[directories.subject '/' directories.REDCapdir '/final/' subj.name '_' montage_info '_analyzed_parameters.txt'],'f');

end
