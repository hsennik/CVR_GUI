function make_montage(source,callbackdata,anat,funct,mp,type,subj,dir_input)

%  for loop to cycle through calling the function to save CVR slices
%  as jpg

%  Create directory to hold all images in montage
mkdir(dir_input,strcat('/montage/',subj.name,'_',subj.breathhold,'_',type,'_',mp.t_number.String,'/'));
gen_file_location = strcat(dir_input,'/montage/',subj.name,'_',subj.breathhold,'_',type,'_',mp.t_number.String,'/');

for i = 6:6:150
    anat.slice_z = i;
    string = int2str(i);
    CVRmap_for_montage(anat,funct,mp,string,gen_file_location);
end

%  Generate file names for each of the CVR slice images 
fileNames = {strcat(gen_file_location,'slice6.jpg'),strcat(gen_file_location,'slice12.jpg'),strcat(gen_file_location,'slice18.jpg'),strcat(gen_file_location,'slice24.jpg'),strcat(gen_file_location,'slice30.jpg'),strcat(gen_file_location,'slice36.jpg'),strcat(gen_file_location,'slice42.jpg'),strcat(gen_file_location,'slice48.jpg'),strcat(gen_file_location,'slice54.jpg'),strcat(gen_file_location,'slice60.jpg'),strcat(gen_file_location,'slice66.jpg'),strcat(gen_file_location,'slice72.jpg'),strcat(gen_file_location,'slice78.jpg'),strcat(gen_file_location,'slice84.jpg'),strcat(gen_file_location,'slice90.jpg'),strcat(gen_file_location,'slice96.jpg'),strcat(gen_file_location,'slice102.jpg'),strcat(gen_file_location,'slice108.jpg'),strcat(gen_file_location,'slice114.jpg'),strcat(gen_file_location,'slice120.jpg'),strcat(gen_file_location,'slice126.jpg'),strcat(gen_file_location,'slice132.jpg'),strcat(gen_file_location,'slice138.jpg'),strcat(gen_file_location,'slice144.jpg'),strcat(gen_file_location,'slice150.jpg')};

%  Create window to display montage
montage_window.f = figure('Name', 'Montage',...  
                        'Visible','on');

%  Create 5 by 5 montage
mymontage = montage(fileNames, 'Size', [5 5]);

%  Create directory for clinician to view final montage
mkdir(dir_input,'/clinician_final/');

%  Write the montage to the clinician file
imwrite(mymontage.CData,strcat(dir_input,'/clinician_final/',subj.name,'_',subj.breathhold,'_',type,'_',mp.t_number.String,'_final_montage.jpg'));

%  Display the montage in the montage window
display('Montage saved');


temp_stim = mp.menu(1).String(mp.menu(1).Value);
stimfile = temp_stim{1};

mkdir('REDCap_import_files/final');
if strcmp(mp.menu(2).String(mp.menu(2).Value),'no') == 1
    copyfile(strcat('REDCap_import_files/all/',subj.name,'_processing_parameters.txt'),'REDCap_import_files/final/','f');
    copyfile(strcat('REDCap_import_files/all/',subj.name,'_',stimfile,'_analysis_parameteres.txt'),'REDCap_import_files/final/','f');
else
    copyfile(strcat('REDCap_import_files/all/',subj.name,'_none_processing_parameters.txt'),'REDCap_import_files/final/','f');
    copyfile(strcat('REDCap_import_files/all/',subj.name,'_none_',stimfile,'_analysis_parameters.txt'),'REDCap_import_files/final/','f');
end

end
        