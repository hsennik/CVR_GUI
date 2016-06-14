%  PROCESS SUBJECT ENTIRELY 

%  Step 1: Clinician specifies location of raw subject data via a select
%  folder popup. Should be able to get subject name, date associated with data, and breath hold method. 

%  Simple UI that displays subject selection and GO button to PROCESS
%  SUBJECT. Generates files that are used for display later. User can then
%  LOOK AT SUBJECT by choosing to run the display GUI. Need to figure out
%  if have to do/how to do all of the processing for BH1,BH2,HV.

addpath('/data/wayne/matlab/NIFTI');
directory = ('/data/projects/CVR/GUI_subjects/');
cd(directory);
subject_names = dir(directory);

%  SELECTION PANEL (sp)
sp.f = figure('Name', 'Process Subject',...
                    'Visible','on',...
                    'Position',[50,800,300,450]);
    
%  Descriptive text for the select subject dropdown menu                
sp.text(1) = uicontrol('Style','text',...
                'units','normalized',...
                'Position',[0.35,0.75,0.3,0.2],...
                'String','Select subject');
        
%  Popupmenu to select subject to process

sp.STR = {subject_names.name}; % pull the directory names of patients from GUI_subjects
sp.menu(1) = uicontrol('Style','popupmenu',...
                'Visible','on',...
                'String',sp.STR,...
                'Position',[50,325,200,60]);
             
%  Push button to begin processing subjectcd .
sp.CVRb = uicontrol('Style','togglebutton',...
                'Visible','on',...
                'String','Process Subject',...,
                'Enable','off',...
                'Value',0,'Position',[50,240,200,60],...
                'callback',@pushstate);
            
sp.look = uicontrol('Style','togglebutton',...
                   'Visible','on',...
                   'String','Look at Subject Data',...
                   'Value',0,'Position',[50,160,200,60],...
                   'Enable','off',...
                   'callback',@run_again);
               
%  Button to terminate the program
mp.quit = uicontrol('Style','togglebutton',...
                    'Visible','on',...
                    'String','Quit',...
                    'Value',0,'Position',[110,80,80,60],...
                    'callback',@quit_program);              

%  MAKE DATA DRIVEN 
waitfor(sp.menu(1),'Value');               
if(sp.menu(1).Value == 3)
    subj.name = 'Bisch15';
elseif(sp.menu(1).Value == 4)
    subj.name = 'ChanR16';
elseif(sp.menu(1).Value == 5)
    subj.name = 'Dunstan15';
end

dir_input = strcat(directory,subj.name,'/');
cd(dir_input);
subj.date = '160314';  

set(sp.CVRb,'Enable','on');
waitfor(sp.CVRb,'Value',1);

%  Make flirt directories that will be used for mapping functional data to
%  anatomical space, and for generating pf stimfiles
mkdir(dir_input,'flirt/none_boxcar');
mkdir(dir_input,'flirt/none_pf');
mkdir(dir_input,'flirt/mpe_boxcar');
mkdir(dir_input,'flirt/mpe_pf');
mkdir(dir_input,'flirt/MD_boxcar');
mkdir(dir_input,'flirt/MD_pf');

%  Process and analyze subject data for all combinations of temporal
%  filtering and stimfile selection

for i=1:3 % First for loop goes through the three temporal filtering methods 
    filtering = i;
    display(filtering);
    for j=1:2 % Second for loop goes through the two stimfile selections
        stimulus = j;
        display(stimulus);
        if((filtering == 1)&&(stimulus == 1))
            destination_name_R_P = 'none';
            destination_name_A = 'none_boxcar';
        elseif((filtering == 1)&&(stimulus == 2))
            destination_name_R_P = 'none';
            destination_name_A = 'none_pf';
        elseif((filtering == 2)&&(stimulus == 1))
            destination_name_R_P = 'mpe';
            destination_name_A = 'mpe_boxcar';
        elseif((filtering == 2)&&(stimulus == 2))
            destination_name_R_P = 'mpe';
            destination_name_A = 'mpe_pf';
        elseif((filtering == 3)&&(stimulus == 1))
            destination_name_R_P = 'MD';
            destination_name_A = 'MD_boxcar';
        elseif((filtering == 3)&&(stimulus == 2))
            destination_name_R_P = 'MD';
            destination_name_A = 'MD_pf';    
        end
        
        if(stimulus == 2) % If stimulus selected is pf then have to transform standard data to the subject space to create 1D pf stimfile
            for bh_pf=1:2
                if bh_pf == 1
                    subj.breathhold = 'BH1';
                elseif bh_pf == 2
                    subj.breathhold = 'BH2';
                end
                s1 = 'flirt -in standard_files/avg152T1_brain.nii.gz -ref data/processed_';
                s2 = destination_name_R_P;
                s3 = strcat('/CVR_',subj.date,'/final/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'.nii -out flirt/');
                s4 = destination_name_A;
                s5 = '/stand2funct.nii -omat flirt/';
                s6 = '/stand2funct.mat -dof 12';

                %  Transforming standard brain to subject space
                brainmni2target = strcat(s1,s2,s3,s4,s5,s4,s6);
                command = brainmni2target;
                status = system(command);

                s7 = 'flirt -in standard_files/Cerebellum-MNIflirt-maxprob-thr50-2mm.nii.gz -ref data/processed_';
                s8 = '/cereb2funct.nii -init flirt/';
                s9 = '/stand2funct.mat -applyxfm';

                %  Transforming standard cerebellum to subject space using the
                %  transformation matrix generated in previous transformation
                cereb2target = strcat(s7,s2,s3,s4,s8,s4,s9);
                command = cereb2target;
                status = system(command);

                s10 = '3dmaskave -q -mask flirt/';
                s11 = '/cereb2funct.nii data/processed_';
                s12 = strcat('/CVR_',subj.date,'/final/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'.nii > flirt/');

                %  Using 3dmaskave to create a 1D stimfile based on signal in
                %  the cerebellum 
                mask = strcat(s10,s4,s11,s2,s12,s4,'/',s4,'_',subj.breathhold,'_stim.txt');
                command = mask;
                status = system(command);

                %  Copying the stimfile to stim in metadata where the S,P,A
                %  files are so that A can use the file
                copy_stim = strcat('cp flirt/',s4,'/',s4,'_',subj.breathhold,'_stim.txt',' metadata/stim');
                command = copy_stim;
                status = system(command);
                display('Stim file created from cerebellum');
            end
        end

        fileID = fopen('metadata/mat2py.txt','w+'); % Open the text file in write mode
        format = '%d\n';
        fprintf(fileID,format,filtering,stimulus); % Write the filtering and stimulus values in the file (they will be used in process_fmri and analyze_fmri)
        fclose(fileID);
        
        %  Run the processing pipeline
        command = strcat('python metadata/process_fmri.py metadata/S_CVR_',subj.name,'.txt  metadata/P_CVR_',subj.name,'.txt --clean');
        status = system(command);
        
        %  Run the analyze pipeline
        command = strcat('python metadata/analyze_fmri.py metadata/S_CVR_',subj.name,'.txt metadata/A_CVR_',subj.name,'.txt --clean');
        status = system(command);

        for k=1:2
            breathhold = k;
            if(breathhold ==1)
                subj.breathhold = 'BH1';
            elseif(breathhold ==2)
                subj.breathhold = 'BH2';
            end
            
            str1 = 'flirt -in data/analyzed_';
            str2 = destination_name_A;
            str3 = strcat('/CVR_',subj.date,'/final/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck.nii -ref data/recon_');
            str4 = destination_name_R_P;
            str5 = strcat('/',subj.name,'/',subj.name,'_anat_brain.nii -out flirt/');
            str6 = strcat('/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_anat_space.nii -omat flirt/');
            str7 = strcat('/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_anat_space.mat -dof 12');

            %  Transform the functional data to anatomical space
            glm2anat = strcat(str1,str2,str3,str4,str5,str2,str6,str2,str7);
            command = glm2anat;
            status = system(command);

            %  Load the unmapped functional data 
            load_glm = strcat('data/analyzed_',destination_name_A,'/CVR_',subj.date,'/final/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck.nii');
            temp = load_nii(load_glm);
            [temp.x,temp.y,temp.z] = size(temp.img);

            %  Save the fifth bucket of the functional data (coeff bucket)
            %  Changing to try and see if can save the sixth bucket of the
            %  functional data (t_stat bucket)
            voxel_size = [temp.hdr.dime.pixdim(2) temp.hdr.dime.pixdim(3) temp.hdr.dime.pixdim(4)];
            temp.brain_bucket_5 = double(squeeze(temp.img(:,:,:,:,5)));
            nii = make_nii(temp.brain_bucket_5,voxel_size);
            save_fifthbucket = strcat('flirt/',destination_name_A,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE.nii');
            save_nii(nii,save_fifthbucket); 

            str8 = 'flirt -in flirt/';
            str9 = strcat('/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE.nii -ref data/recon_');
            str10 = strcat('/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE_anat_space.nii -init flirt/');
            str11 = strcat('/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_anat_space.mat -applyxfm');

            %  Map the fifth bucket to anatomical space using the
            %  transformation matrix generated when mapping the functional data
            %  to anatomical
            bucketfive2anat = strcat(str8,str2,str9,str4,str5,str2,str10,str2,str11);
            command = bucketfive2anat;
            status = system(command);
        end
    end
end

display('ALL DONE');
%  Allow the user to press the Look at Subject button to start running the
%  display UI program 
set(sp.look,'Enable','on');

