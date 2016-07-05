function make_montage(source,callbackdata,anat,funct,mp,type,subj,dir_input,montage_info)
% Function to make montage from saved axial slice images 
% 
% INPUTS 
%     anat - 3D anatomical subject data 
%     funct - 4D functional subject data
%     mp - GUI data
%     type - type of processing and stimfile 
%     subj - subject data (name,date,breathhold)
%     dir_input - main subject directory 
%     montage_info - to be used in final filename for montage 
%
% *************** REVISION INFO ***************
% Original Creation Date - June 27, 2016
% Author - Hannah Sennik

%  Create directory to hold all images in montage
mkdir(dir_input,strcat('/montage/',subj.name,'_',subj.breathhold,'_',type,'_',mp.t_number.String,'/'));
gen_file_location = strcat(dir_input,'/montage/',subj.name,'_',subj.breathhold,'_',type,'_',mp.t_number.String,'/');

%  For loop to cycle through calling the function to save CVR slices
%  as jpg
for i = 6:6:150 % save 25 slices to create 5 by 5 montage, save every six slices 
    anat.slice_z = i;
    string = int2str(i);
    CVRmap_for_montage(anat,funct,mp,string,gen_file_location);
end

%  Generate file names for each of the CVR slice images 
fileNames = {strcat(gen_file_location,'slice6.jpg'),strcat(gen_file_location,'slice12.jpg'),strcat(gen_file_location,'slice18.jpg'),strcat(gen_file_location,'slice24.jpg'),strcat(gen_file_location,'slice30.jpg'),strcat(gen_file_location,'slice36.jpg'),strcat(gen_file_location,'slice42.jpg'),strcat(gen_file_location,'slice48.jpg'),strcat(gen_file_location,'slice54.jpg'),strcat(gen_file_location,'slice60.jpg'),strcat(gen_file_location,'slice66.jpg'),strcat(gen_file_location,'slice72.jpg'),strcat(gen_file_location,'slice78.jpg'),strcat(gen_file_location,'slice84.jpg'),strcat(gen_file_location,'slice90.jpg'),strcat(gen_file_location,'slice96.jpg'),strcat(gen_file_location,'slice102.jpg'),strcat(gen_file_location,'slice108.jpg'),strcat(gen_file_location,'slice114.jpg'),strcat(gen_file_location,'slice120.jpg'),strcat(gen_file_location,'slice126.jpg'),strcat(gen_file_location,'slice132.jpg'),strcat(gen_file_location,'slice138.jpg'),strcat(gen_file_location,'slice144.jpg'),strcat(gen_file_location,'slice150.jpg')};

%  Create window to display montage
montage_window.f = figure('Name', 'Montage',...  
                        'Visible','on',...
                        'numbertitle','off');

%  Create 5 by 5 montage
mymontage = montage(fileNames, 'Size', [5 5]);

%  Create directory for clinician to view final montage
mkdir(dir_input,'/clinician_final/');

%  Write the montage to the clinician file
imwrite(mymontage.CData,strcat(dir_input,'/clinician_final/',subj.name,'_',subj.breathhold,'_',type,'_',mp.t_number.String,'_final_montage.jpg'));

%  Display the montage in the montage window
display('Montage saved');

%  If clinician generates a montage, save the parameter data used for that
%  montage to a text file that can be imported in to REDCap
mkdir('REDCap_import_files/final');
if strcmp(mp.menu(2).String(mp.menu(2).Value),'yes') == 1 % processed data 
    copyfile(strcat('REDCap_import_files/all/',subj.name,'_processed_parameters.txt'),'REDCap_import_files/final/','f');
else % raw data 
    copyfile(strcat('REDCap_import_files/all/',subj.name,'_not_processed_parameters.txt'),'REDCap_import_files/final/','f');
end
copyfile(strcat('REDCap_import_files/all/',subj.name,'_',montage_info,'_analyzed_parameters.txt'),'REDCap_import_files/final/','f');

end
