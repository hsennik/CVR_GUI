function analyze_subject(source,callbackdata,subj,directories,main_GUI)

% IN THIS FUNCTION, CUSTOMIZED INDICATES A STANDARD BOXCAR THAT HAS BEEN
% SHIFTED

directories.flirtdir = 'flirt';

%  Make flirt directory that will be used for mapping functional data to
%  anatomical space, and for generating pf stimfiles
mkdir([directories.subject '/' directories.flirtdir '/pf']);

if main_GUI.custom(1).Value == 1 || main_GUI.custom(2).Value == 1 || main_GUI.custom(3).Value == 1
    standard_or_custom = '1';
else
    standard_or_custom = '0';
end

if standard_or_custom == '1'
    original_value = '1';
    do_custom = 3; % There is a third stimfile option - standard boxcar, pf, customized boxcar
else
    original_value = '0';
    do_custom = 2; % There are only two stim options - standard boxcar and pf 
end

fileID = fopen([directories.textfilesdir '/mat2py.txt'],'w+'); % Open the text file in write mode to write the filtering and stimulus values (initially both will be 1)
format = '%d\n';
fprintf(fileID,format,1,1); % Write the filtering and stimulus values in the file (they will be used in process_fmri and analyze_fmri)
fclose(fileID);

for j=1:do_custom %  Second for loop goes through the two OR three stimfile selections (standard boxcar,pf, OPTIONAL customized boxcar)
    stimulus = j;
    destination_name_P = '';
    if stimulus == 2 %  posterior fossa stimfile
        destination_name_A = 'pf';
    end

    if stimulus == 1 % standard
        fileID = fopen([directories.subject '/' directories.textfilesdir '/standard_or_custom.txt'],'w+'); % open customized boxcar textfile in write mode to write a 0 
        format = '%d\n';
        fprintf(fileID,format,0);
        fclose(fileID);
        mkdir(directories.subject,['/' directories.flirtdir '/standard_boxcar']); %  Make standard directories in the flirt folder (for transformations and pf stimfiles)
        BH1boxsel =  'standard_boxcar';
        BH2boxsel = 'standard_boxcar';
        HVboxsel = 'standard_boxcar';
    elseif stimulus == 3 % customized 
        fileID = fopen([directories.subject '/' directories.textfilesdir '/standard_or_custom.txt'],'w+'); % open customized boxcar textfile in write mode to write a 1 
        format = '%d\n';
        fprintf(fileID,format,1);
        fclose(fileID);
        mkdir([directories.subject '/' directories.flirtdir '/customized_boxcar']); %  Make customized directories in the flirt folder 
        fileID = fopen([directories.subject '/' directories.textfilesdir '/customize_boxcar.txt'],'w+'); % open customized boxcar textfile in write mode 
        format = '%d\n';

        if main_GUI.custom(1).Value == 1 
            fprintf(fileID,format,1); % If the customized boxcar was selected, write a 1 to the customized boxcar textfile 
            BH1boxsel = 'customized_boxcar';
        else 
            fprintf(fileID,format,0); % If user specified standard boxcar, write a 0 to the file 
            BH1boxsel = 'standard_boxcar';
        end

        if main_GUI.custom(2).Value == 1 
            fprintf(fileID,format,1); 
            BH2boxsel = 'customized_boxcar';
        else
            fprintf(fileID,format,0); 
            BH2boxsel = 'standard_boxcar';
        end

        if main_GUI.custom(3).Value == 1 % HV
            fprintf(fileID,format,1);  
            HVboxsel = 'customized_boxcar';
        else
            fprintf(fileID,format,0); 
            HVboxsel = 'standard_boxcar';
        end

        fclose(fileID);
    end

    if(stimulus == 2) % If stimulus selected is pf then have to transform standard data to the subject space to create mask for 1D pf stimfile
        fileID = fopen([directories.subject '/' directories.textfilesdir '/standard_or_custom.txt'],'w+'); % open customized boxcar textfile in write mode to write a 0 
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

            %  Transform MNI standard brain to functional space
            s1 = ['flirt -in ' directories.matlabdir '/standard_files/avg152T1_brain.nii.gz -ref data/processed'];
            s2 = destination_name_P;
            s3 = ['/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii -out flirt/'];
            s4 = destination_name_A;
            s5 = ['/stand2funct.nii -omat ' directories.flirtdir '/'];
            s6 = '/stand2funct.mat -dof 12';

            brainmni2target = [s1 s2 s3 s4 s5 s4 s6];
            command = brainmni2target;
            status = system(command);

            %  Transforming standard cerebellum to functional space using the
            %  transformation matrix generated in previous transformation
            s7 = ['flirt -in ' directories.matlabdir '/standard_files/Cerebellum-MNIflirt-maxprob-thr50-2mm.nii.gz -ref data/processed'];
            s8 = '/cereb2funct.nii -init flirt/';
            s9 = '/stand2funct.mat -applyxfm';

            cereb2target = [s7 s2 s3 s4 s8 s4 s9];
            command = cereb2target;
            status = system(command);
            
            mkdir([directories.flirtdir '/standard_to_functional']);
            
            %  Transforming white matter to functional space using the
            %  transformation matrix
            s7 = ['flirt -in ' directories.matlabdir '/standard_files/avg152T1_white.img -ref data/processed'];
            s8 = '/standard_to_functional/white2funct.nii -init flirt/';
            s9 = '/stand2funct.mat -applyxfm';

            whitematter = [s7 s2 s3 s8 s4 s9];
            command = whitematter;
            status = system(command);
            
            %  Transforming gray matter to functional space using the
            %  transformation matrix
            s7 = ['flirt -in ' directories.matlabdir '/standard_files/avg152T1_gray.img -ref data/processed'];
            s8 = '/standard_to_functional/gray2funct.nii -init flirt/';
            s9 = '/stand2funct.mat -applyxfm';

            graymatter = [s7 s2 s3 s8 s4 s9];
            command = graymatter;
            status = system(command);

            %  Using 3dmaskave to create a 1D stimfile based on signal in
            %  the cerebellum 
            s10 = ['3dmaskave -q -mask ' directories.flirtdir '/'];
            s11 = '/cereb2funct.nii data/processed';
            s12 = ['/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii > flirt/'];

            if(processed == 0)
                mask = [s10 s4 s11 s2 s12 s4 '/' 'pf' '_' subj.breathhold '_stim_not_processed.1D'];
                status = system(mask);
                copy_stim = ['cp ' directories.flirtdir '/' s4 '/' 'pf' '_' subj.breathhold '_stim_not_processed.1D ' directories.metadata '/stim'];
            else
                mask = [s10 s4 s11 s2 s12 s4 '/' 'pf' '_' subj.breathhold '_stim.1D'];
                status = system(mask);
                copy_stim = ['cp ' directories.flirtdir '/' s4 '/' s4 '_' subj.breathhold '_stim.1D ' directories.metadata '/stim'];
            end
            command = copy_stim;
            status = system(command);
            display('Stim file created from cerebellum');
            
            command = ['3dmaskave -q -mask ' directories.flirtdir '/standard_to_functional/white2funct.nii data/processed/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii > flirt/standard_to_functional/whitematter_' subj.breathhold '.1D'];
            status = system(command);
            command = ['3dmaskave -q -mask ' directories.flirtdir '/standard_to_functional/gray2funct.nii data/processed/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii > flirt/standard_to_functional/graymatter_' subj.breathhold '.1D'];
            status = system(command);
        end
    end

    processed = 1;
    fileID = fopen([directories.textfilesdir '/mat2py.txt'],'w+'); % Open the text file in write mode
    format = '%d\n';
    fprintf(fileID,format,processed,stimulus); % Write the filtering and stimulus values in the file (they will be used in process_fmri and analyze_fmri)
    fclose(fileID);

    %  Run the analyze pipeline
    command = ['python ' directories.matlabdir '/python/analyze_fmri.py ' directories.metadata '/S_CVR_' subj.name '.txt ' directories.metadata '/A_CVR_' subj.name '.txt --clean'];
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

        %  Create transformation matrix for functional data to anatomical space
        str1 = [directories.flirtdir ' -in data/analyzed_'];
        str2 = destination_name_A;
        str3 = ['/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii -ref data/recon'];
        str4 = destination_name_P;
        str5 = ['/' subj.name '/' subj.name '_anat_brain.nii -out ' directories.flirtdir '/'];
        str6 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_anat_space.nii -omat ' directories.flirtdir '/'];
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
        save_fifthbucket = [directories.flirtdir '/' destination_name_A '/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_FIVE.nii'];
        save_nii(nii,save_fifthbucket); 

        %  Map the fifth bucket to anatomical space using the
        %  transformation matrix generated above
        str8 = ['flirt -in ' directories.flirtdir '/'];
        str9 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_FIVE.nii -ref data/recon'];
        str10 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_FIVE_anat_space.nii -init ' directories.flirtdir '/'];
        str11 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_anat_space.mat -applyxfm'];

        bucketfive2anat = [str8 str2 str9 str5 str2 str10 str2 str11];
        command = bucketfive2anat;
        status = system(command);

    end
end


fileID = fopen([directories.textfilesdir '/standard_or_custom.txt'],'w+'); 
format = '%s\n';
fprintf(fileID,format,original_value); 
fclose(fileID);

%  BRAIN REGIONAL MASKSl
display('************** BRAIN REGIONAL MASKS **************');

mkdir([directories.flirtdir '/standard_to_anat']);

%  Map the standard MNI to subjects anatomical space - need the
%  transformation matrix for 3D predetermined ROI's - this may already be
%  saved in recon ..?
command = ['flirt -in ' directories.matlabdir '/standard_files/avg152T1_brain.nii.gz -ref data/recon/' subj.name '/' subj.name '_anat_brain.nii -out ' directories.flirtdir '/standard_to_anat/standard_brain_to_anat.nii -omat ' directories.flirtdir '/standard_to_anat/standard_brain_to_anat.mat -dof 12'];
status = system(command);

%  Map each of the regions to anatomical space here as well and save to
%  flirt/standard_to_anat
%  CEREBELLUM
command = ['flirt -in ' directories.matlabdir '/standard_files/Cerebellum-MNIflirt-maxprob-thr50-2mm.nii.gz -ref data/recon/' subj.name '/' subj.name '_anat_brain.nii -out ' directories.flirtdir '/standard_to_anat/cerebellum_to_anat.nii -init ' directories.flirtdir '/standard_to_anat/standard_brain_to_anat.mat -applyxfm'];
status = system(command);

%  WHITE MATTER
command = ['flirt -in ' directories.matlabdir '/standard_files/avg152T1_white.img -ref data/recon/' subj.name '/' subj.name '_anat_brain.nii -out ' directories.flirtdir '/standard_to_anat/white_to_anat.nii -init ' directories.flirtdir '/standard_to_anat/standard_brain_to_anat.mat -applyxfm'];
status = system(command);

%  GRAY MATTER
command = ['flirt -in ' directories.matlabdir '/standard_files/avg152T1_gray.img -ref data/recon/' subj.name '/' subj.name '_anat_brain.nii -out ' directories.flirtdir '/standard_to_anat/gray_to_anat.nii -init ' directories.flirtdir '/standard_to_anat/standard_brain_to_anat.mat -applyxfm'];
status = system(command);

%  Do mapping for all 3D regions to functional space ahead of time, and
%  3dmaskave for timeseries
%  (cerebellum is already done - pf)

display('************** ALL DONE **************');

set(main_GUI.look,'Enable','on'); % Enable the push button for the user to look at the processed and analyzed subject data

end