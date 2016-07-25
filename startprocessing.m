function startprocessing(source,callbackdata,subj,dir_input)
% Function to process and analyze the subject using all possible parameter combinations.
% Parameters include:
% Processing: Processed, not processed
% Stimfile: boxcar, posterior fossa (pf)
% Breathholds: BH1, BH2, HV
% 
% INPUTS 
%     subj - subject data (name, breathhold, date)
%     dir_input - directory where data should we stored
% 
% *************** REVISION INFO ***************
% Original Creation Date - June 22, 2016
% Author - Hannah Sennik

%  Get data from 'Process and Analyze Subject' figure
handles = guidata(source);

flirtdir = 'flirt';
textfilesdir = 'textfiles';
REDCapdir = 'REDCap_import_files';
subjectfiles = 'metadata';
matlabhomedir = '/data/hannahsennik/MATLAB/CVR_GUI/';

fileID = fopen([dir_input textfilesdir '/standard_or_custom.txt'],'r');
format = '%d\n';
standard_or_custom = fgetl(fileID);
fclose(fileID);

if standard_or_custom == '1'
    original_value = '1';
    do_custom = 3; % There is a third stimfile option - standard boxcar, pf, customized boxcar
else
    original_value = '0';
    do_custom = 2; % There are only two stim options - standard boxcar and pf 
end

%  Make flirt directories that will be used for mapping functional data to
%  anatomical space, and for generating pf stimfiles
mkdir([dir_input flirtdir '/pf']);
mkdir([dir_input flirtdir '/pf_not_processed']);

%  Make REDCap directories where a summary of processing and analysis parameters used will be
%  saved to a text file
mkdir([dir_input REDCapdir]);
mkdir([dir_input REDCapdir '/all']);

fileID = fopen([textfilesdir '/mat2py.txt'],'w+'); % Open the text file in write mode to write the filtering and stimulus values (initially both will be 1)
format = '%d\n';
fprintf(fileID,format,1,1); % Write the filtering and stimulus values in the file (they will be used in process_fmri and analyze_fmri)
fclose(fileID);

fileID = fopen([textfilesdir '/processing.txt'],'w+'); % Write to this file to specify no processing (0) or processing (1)
format = '%d\n';
fprintf(fileID,format,1); % Process subject 

%  Run the processing pipeline with all steps
command = ['python ' matlabhomedir '/python/process_fmri.py ' subjectfiles '/S_CVR_' subj.name '.txt ' subjectfiles '/P_CVR_' subj.name '.txt --clean'];
status = system(command);

fileID = fopen([textfilesdir '/processing.txt'],'w+');
format = '%d\n';
fprintf(fileID,format,0); % Write the number 0 to skip processing 

%  Run the processing pipeline but disclude steps so data is
%  unprocessed/raw
command = ['python ' matlabhomedir '/python/process_fmri.py ' subjectfiles '/S_CVR_' subj.name '.txt ' subjectfiles '/P_CVR_' subj.name '.txt --clean'];
status = system(command);

for i=1:2 % First for loop goes through processed and unprocessed data 
    processed = i;
    
    fileID = fopen([textfilesdir '/processing.txt'],'w+'); 
    format = '%d\n';
    if processed == 2
        fprintf(fileID,format,0); % Skip processing 
    elseif processed == 1
        fprintf(fileID,format,1); % Process subject
    end
    fclose(fileID);

    for j=1:do_custom %  Second for loop goes through the two OR three stimfile selections (standard boxcar,pf, OPTIONAL customized boxcar)
        stimulus = j;
        
        if processed == 1
            destination_name_P = '';
            if stimulus == 2 %  Processed data and boxcar standard stimfile 
                destination_name_A = 'pf';
            end
        elseif processed == 2
            destination_name_P = '_not';
            if stimulus == 2 %  Raw data and boxcar stimfile 
                destination_name_A = 'pf_not_processed';
            end
        end
        
        if stimulus == 1 % standard
            fileID = fopen([dir_input textfilesdir '/standard_or_custom.txt'],'w+'); % open customized boxcar textfile in write mode to write a 0 
            format = '%d\n';
            fprintf(fileID,format,0);
            fclose(fileID);
            mkdir(dir_input,'flirt/standard_boxcar'); %  Make standard directories in the flirt folder (for transformations and pf stimfiles)
            mkdir(dir_input,'flirt/standard_boxcar_not_processed');
            BH1boxsel =  'standard_boxcar';
            BH2boxsel = 'standard_boxcar';
            HVboxsel = 'standard_boxcar';
        elseif stimulus == 3 % customized 
            fileID = fopen([dir_input textfilesdir '/standard_or_custom.txt'],'w+'); % open customized boxcar textfile in write mode to write a 1 
            format = '%d\n';
            fprintf(fileID,format,1);
            fclose(fileID);
            mkdir([dir_input flirtdir '/customized_boxcar']); %  Make customized directories in the flirt folder 
            mkdir([dir_input flirtdir '/customized_boxcar_not_processed']);
            fileID = fopen([dir_input textfilesdir '/customize_boxcar.txt'],'w+'); % open customized boxcar textfile in write mode 
            format = '%d\n';

            if handles.custom(1).Value == 1 || handles.custom(4).Value == 1 % BH1
                fprintf(fileID,format,1); % If the customized boxcar was selected, write a 1 to the customized boxcar textfile 
                BH1boxsel = 'customized_boxcar';
            else 
                fprintf(fileID,format,0); % If user specified standard boxcar, write a 0 to the file 
                BH1boxsel = 'standard_boxcar';
            end

            if handles.custom(2).Value == 1 || handles.custom(4).Value == 1 % BH2
                fprintf(fileID,format,1); 
                BH2boxsel = 'customized_boxcar';
            else
                fprintf(fileID,format,0); 
                BH2boxsel = 'standard_boxcar';
            end

            if handles.custom(3).Value == 1 % HV
                fprintf(fileID,format,1);  
                HVboxsel = 'customized_boxcar';
            else
                fprintf(fileID,format,0); 
                HVboxsel = 'standard_boxcar';
            end

            fclose(fileID);
        end
        
        if(stimulus == 2) % If stimulus selected is pf then have to transform standard data to the subject space to create mask for 1D pf stimfile
            fileID = fopen([dir_input textfilesdir '/standard_or_custom.txt'],'w+'); % open customized boxcar textfile in write mode to write a 0 
            format = '%d\n';
            fprintf(fileID,format,0);
            fclose(fileID);
            
            for bh_pf=1:3 %  bh_pf=1:3 masks the functional cerebellum data for each breathhold 
                if bh_pf == 1
                    subj.breathhold = 'BH1';
                elseif bh_pf == 2
                    subj.breathhold = 'BH2';
                elseif bh_pf == 3
                    subj.breathhold = 'HV';
                end

                %  Transform MNI standard brain to subject space
                s1 = ['flirt -in ' matlabhomedir '/standard_files/avg152T1_brain.nii.gz -ref data/processed'];
                s2 = destination_name_P;
                s3 = ['/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii -out flirt/'];
                s4 = destination_name_A;
                s5 = ['/stand2funct.nii -omat ' flirtdir '/'];
                s6 = '/stand2funct.mat -dof 12';
          
                brainmni2target = [s1 s2 s3 s4 s5 s4 s6];
                command = brainmni2target;
                status = system(command);
                
                %  Transforming standard cerebellum to subject space using the
                %  transformation matrix generated in previous transformation
                s7 = ['flirt -in ' matlabhomedir '/standard_files/Cerebellum-MNIflirt-maxprob-thr50-2mm.nii.gz -ref data/processed'];
                s8 = '/cereb2funct.nii -init flirt/';
                s9 = '/stand2funct.mat -applyxfm';

                cereb2target = [s7 s2 s3 s4 s8 s4 s9];
                command = cereb2target;
                status = system(command);

                %  Using 3dmaskave to create a 1D stimfile based on signal in
                %  the cerebellum 
                s10 = ['3dmaskave -q -mask ' flirtdir '/'];
                s11 = '/cereb2funct.nii data/processed';
                s12 = ['/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii > flirt/'];

                if(processed == 2)
                    mask = [s10 s4 s11 s2 s12 s4 '/' 'pf' '_' subj.breathhold '_stim_not_processed.1D'];
                    status = system(mask);
                    copy_stim = ['cp ' flirtdir '/' s4 '/' 'pf' '_' subj.breathhold '_stim_not_processed.1D ' subjectfiles '/stim'];
                else
                    mask = [s10 s4 s11 s2 s12 s4 '/' 'pf' '_' subj.breathhold '_stim.1D'];
                    status = system(mask);
                    copy_stim = ['cp ' flirtdir '/' s4 '/' s4 '_' subj.breathhold '_stim.1D ' subjectfiles '/stim'];
                end
                command = copy_stim;
                status = system(command);
                display('Stim file created from cerebellum');
            end
        end

        fileID = fopen([textfilesdir '/mat2py.txt'],'w+'); % Open the text file in write mode
        format = '%d\n';
        fprintf(fileID,format,processed,stimulus); % Write the filtering and stimulus values in the file (they will be used in process_fmri and analyze_fmri)
        fclose(fileID);
        
        %  Run the analyze pipeline
        command = ['python ' matlabhomedir 'python/analyze_fmri.py ' subjectfiles '/S_CVR_' subj.name '.txt ' subjectfiles '/A_CVR_' subj.name '.txt --clean'];
        status = system(command);

        for k=1:3 % Third for loop goes through the breathholds and maps the functional data to be displayed to the user 
            breathhold = k;
            if(breathhold ==1)
                subj.breathhold = 'BH1';
            elseif(breathhold ==2)
                subj.breathhold = 'BH2';
            elseif(breathhold==3)
                subj.breathhold = 'HV';
            end
            
            if stimulus == 1 || stimulus == 3 % if boxcar is selected as stimfile 
                if breathhold == 1
                    destination_name_A = BH1boxsel;
                elseif breathhold == 2
                    destination_name_A = BH2boxsel;
                elseif breathhold == 3
                    destination_name_A = HVboxsel;
                end
            end
            
            if (stimulus == 1 && processed == 2) || (stimulus == 3 && processed == 2)
                destination_name_A = [destination_name_A '_not_processed'];
            end
            
            %  Create transformation matrix for functional data to anatomical space
            str1 = [flirtdir ' -in data/analyzed_'];
            str2 = destination_name_A;
            str3 = ['/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii -ref data/recon'];
            str4 = destination_name_P;
            str5 = ['/' subj.name '/' subj.name '_anat_brain.nii -out ' flirtdir '/'];
            str6 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_anat_space.nii -omat ' flirtdir '/'];
            str7 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_anat_space.mat -dof 12'];
            
            glm2anat = [str1 str2 str3 str5 str2 str6 str2 str7];
            command = glm2anat;
            status = system(command);
            
            %  Load the unmapped functional data 
            load_glm = ['data/analyzed_' destination_name_A '/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'];
            temp = load_nii(load_glm);
            [temp.x,temp.y,temp.z] = size(temp.img);

            %  Save the fifth bucket of the functional data (coeff bucket)
            voxel_size = [temp.hdr.dime.pixdim(2) temp.hdr.dime.pixdim(3) temp.hdr.dime.pixdim(4)];
            temp.brain_bucket_5 = double(squeeze(temp.img(:,:,:,:,5)));
            nii = make_nii(temp.brain_bucket_5,voxel_size);
            save_fifthbucket = [flirtdir '/' destination_name_A '/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_FIVE.nii'];
            save_nii(nii,save_fifthbucket); 

            %  Map the fifth bucket to anatomical space using the
            %  transformation matrix generated above
            str8 = ['flirt -in ' flirtdir '/'];
            str9 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_FIVE.nii -ref data/recon'];
            str10 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_FIVE_anat_space.nii -init ' flirtdir '/'];
            str11 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_anat_space.mat -applyxfm'];

            bucketfive2anat = [str8 str2 str9 str5 str2 str10 str2 str11];
            command = bucketfive2anat;
            status = system(command);

        end
        command = ['convert_xfm -omat ' flirtdir '/' destination_name_A '/anat2funct.mat -inverse ' flirtdir '/' destination_name_A '/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_anat_space.mat'];
        status = system(command);
        
        timeseriesdir = 'timeseries';
        mkdir(timeseriesdir);
        copyfile([flirtdir '/' destination_name_A '/anat2funct.mat'],[timeseriesdir '/anat2funct.mat'],'f');
    end
end

fileID = fopen([textfilesdir '/standard_or_custom.txt'],'w+'); 
format = '%s\n';
fprintf(fileID,format,original_value); 
fclose(fileID);

%  BRAIN REGIONAL MASKS
display('************** BRAIN REGIONAL MASKS **************');

mkdir([flirtdir '/standard_to_anat']);

%  Map the standard MNI to subjects anatomical space - need the
%  transformation matrix for 3D predetermined ROI's
command = ['flirt -in ' matlabhomedir 'standard_files/avg152T1_brain.nii.gz -ref data/recon/' subj.name '/' subj.name '_anat_brain.nii -out ' flirtdir '/standard_to_anat/standard_brain_to_anat.nii -omat ' flirtdir '/standard_to_anat/standard_brain_to_anat.mat -dof 12'];
status = system(command);

%  Map each of the regions to anatomical space here as well and save to
%  flirt/standard_to_anat
%  CEREBELLUM
command = ['flirt -in ' matlabhomedir 'standard_files/Cerebellum-MNIflirt-maxprob-thr50-2mm.nii.gz -ref data/recon/' subj.name '/' subj.name '_anat_brain.nii -out ' flirtdir '/standard_to_anat/cerebellum_to_anat.nii -init ' flirtdir '/standard_to_anat/standard_brain_to_anat.mat -applyxfm'];
status = system(command);

%  Do mapping for all 3D regions to functional space ahead of time, and
%  3dmaskave for timeseries - have to do for processed and unprocessed
%  (cerebellum is already done - pf)

display('************** ALL DONE **************');

set(handles.look,'Enable','on'); % Enable the push button for the user to look at the processed and analyzed subject data

end

