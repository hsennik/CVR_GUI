function analyze_subject(source,callbackdata,subj,directories,main_GUI)

directories.flirtdir = 'flirt';

%  Make flirt directory that will be used for mapping functional data to
%  anatomical space, and for generating pf stimfiles
mkdir([directories.subject '/' directories.flirtdir '/pf']);
mkdir([directories.subject '/' directories.flirtdir '/pf_raw']);

fileID = fopen([directories.textfilesdir '/standard_shifted_customized.txt'],'w+');
format = '%d\n';

if main_GUI.stimulus_selection.Value == 2 || main_GUI.stimulus_selection.Value == 3

    if main_GUI.boxcar(1).Value == 1 % standard boxcar was selected for breathhold
        fprintf(fileID,format,1);
        boxcar_destination = ['standard_boxcar'];
        fclose(fileID);
    elseif main_GUI.boxcar(2).Value == 1 % shifted boxcar was selected for breathhold 
        fprintf(fileID,format,2);
        boxcar_destination = ['shifted_boxcar'];
        fclose(fileID);
    elseif main_GUI.boxcar(3).Value == 1 % customized boxcar was selected for breathhold
        fprintf(fileID,format,3);
        boxcar_destination = ['customized_boxcar'];
        fclose(fileID);
    end
    
elseif main_GUI.stimulus_selection.Value == 4
    boxcar_destination = 'bellows';
elseif main_GUI.stimulus_selection.Value == 5
    boxcar_destination = 'CO2';
end

mkdir([directories.subject '/' directories.flirtdir '/' boxcar_destination]);
mkdir([directories.subject '/' directories.flirtdir '/' boxcar_destination '_raw']);

fileID = fopen([directories.textfilesdir '/stimulus.txt'],'w+'); % Open the text file in write mode to write the stimulus values
format = '%d\n';
fprintf(fileID,format,1); % 1 indicates pf stimulus (always do this one)
fclose(fileID);

stimulus_number = 2; % for now it is just pf and (boxcar,GA,bellows,or CO2 - only one of these at a time) (later have more)

for stimulus=1:stimulus_number %  First for loop goes through stimfile selections
    for processed = 1:2 % Second for loop analyzes processed and then unprocessed data
      
        display(stimulus);
        display(processed);
        
        fileID = fopen([directories.textfilesdir '/processing.txt'],'w+'); 
        format = '%d\n';
        
        if processed == 1
            destination_name_P = 'processed';
            fprintf(fileID,format,1); 
        elseif processed == 2
            destination_name_P = 'raw';
            fprintf(fileID,format,0);
        end
        fclose(fileID);
        
        if stimulus == 1 % If stimulus selected is pf then have to transform standard data to the subject space to create mask for 1D pf stimfile

            destination_name_A = 'pf';
            if processed == 2
                destination_name_A = 'pf_raw';
            end
        
            %  Transform MNI standard brain to functional space
            s1 = ['flirt -in ' directories.matlabdir '/standard_files/avg152T1_brain.nii.gz -ref data/'];
            s2 = destination_name_P;
            s3 = ['/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii -out flirt/'];
            s4 = destination_name_A;
            s5 = ['/stand2funct.nii -omat ' directories.flirtdir '/'];
            s6 = '/stand2funct.mat -dof 12';

            brainmni2target = [s1 s2 s3 s4 s5 s4 s6];
            command = brainmni2target;
            status = system(command);
            
            directories.standfunct = 'standard_to_functional';
            mkdir(directories.flirtdir,['/' directories.standfunct]);
            
            for mask = 1:3 % pf, white matter, gray matter
                if mask == 1
                    standard_file = 'Cerebellum-MNIflirt-maxprob-thr50-2mm.nii.gz';
                    out_file = ['/' destination_name_A '/cereb2funct.nii'];
                    s13 = [destination_name_A '/pf_stim_' subj.proc_rec_sel '_' destination_name_P '.1D'];
                    region = 'Cerebellum';
                elseif mask == 2
                    standard_file = 'avg152T1_white.img';
                    out_file = ['/' directories.standfunct '/white2funct.nii'];
                    s13 = [directories.standfunct '/whitematter_' subj.proc_rec_sel '_' destination_name_P '.1D'];
                    region = 'White Matter';
                elseif mask == 3
                    standard_file = 'avg152T1_gray.img';
                    out_file = ['/' directories.standfunct '/gray2funct.nii'];
                    s13 = [directories.standfunct '/graymatter_' subj.proc_rec_sel '_' destination_name_P '.1D'];
                    region = 'Gray Matter';
                end
            
                %  Transforming standard region to functional space using the
                %  transformation matrix generated in previous transformation
                s7 = ['flirt -in ' directories.matlabdir '/standard_files/' standard_file ' -ref data/'];
                s8 = [out_file ' -init flirt/'];
                s9 = '/stand2funct.mat -applyxfm';

                region2target = [s7 s2 s3 s8 s4 s9];
                command = region2target;
                status = system(command);

                %  Using 3dmaskave to create a 1D stimfile based on signal in
                %  the region 
                s10 = ['3dmaskave -q -mask ' directories.flirtdir '/'];
                s11 = [out_file ' data/'];
                s12 = ['/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii > flirt/'];

                mask = [s10 s11 s2 s12 s13];
                status = system(mask);
                copy_stim = ['cp ' directories.flirtdir '/' s13 ' ' directories.metadata '/stim'];
           
                command = copy_stim;
                status = system(command);
                display(['Stim file created from ' region]);
            end
        elseif stimulus == 2
            fileID = fopen([directories.textfilesdir '/stimulus.txt'],'w+'); % Open the text file in write mode to write the stimulus values
            format = '%d\n';
            fprintf(fileID,format,2); 
            fclose(fileID);
            destination_name_A = boxcar_destination;
            if processed == 2
                destination_name_A = [boxcar_destination '_raw'];
            end
        end
        
        %  Run the analyze pipeline
        command = ['python ' directories.matlabdir '/python/analyze_fmri.py ' directories.metadata '/S_CVR_' subj.name '.txt ' directories.metadata '/A_CVR_' subj.name '.txt --clean'];
        status = system(command);
    
        %  After analysis is run, map the functional data to anatomical space
        %  to be displayed to the user 

        %  Create transformation matrix for functional data to anatomical space
        str1 = [directories.flirtdir ' -in data/analyzed_'];
        str2 = destination_name_A;
        str3 = ['/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '_glm_buck.nii -ref data/recon'];
        str5 = ['/' subj.name '/' subj.name '_anat_brain.nii -out ' directories.flirtdir '/'];
        str6 = ['/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '_glm_buck_anat_space.nii -omat ' directories.flirtdir '/'];
        str7 = ['/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '_glm_buck_anat_space.mat -dof 12'];

        glm2anat = [str1 str2 str3 str5 str2 str6 str2 str7];
        command = glm2anat;
        status = system(command);

        %  Load the unmapped functional data 
        load_glm = ['data/analyzed_' destination_name_A '/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '_glm_buck.nii'];
        temp = load_nii(load_glm);
        [temp.x,temp.y,temp.z] = size(temp.img);

        %  Save the fifth bucket of the functional data (coeff bucket)
        voxel_size = [temp.hdr.dime.pixdim(2) temp.hdr.dime.pixdim(3) temp.hdr.dime.pixdim(4)];
        temp.brain_bucket_5 = double(squeeze(temp.img(:,:,:,:,5)));
        nii = make_nii(temp.brain_bucket_5,voxel_size);
        save_fifthbucket = [directories.flirtdir '/' destination_name_A '/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '_glm_buck_FIVE.nii'];
        save_nii(nii,save_fifthbucket); 

        %  Map the fifth bucket to anatomical space using the
        %  transformation matrix generated above
        str8 = ['flirt -in ' directories.flirtdir '/'];
        str9 = ['/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '_glm_buck_FIVE.nii -ref data/recon'];
        str10 = ['/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '_glm_buck_FIVE_anat_space.nii -init ' directories.flirtdir '/'];
        str11 = ['/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '_glm_buck_anat_space.mat -applyxfm'];

        bucketfive2anat = [str8 str2 str9 str5 str2 str10 str2 str11];
        command = bucketfive2anat;
        status = system(command);

    end
end


%  BRAIN REGIONAL MASKSl
display('************** BRAIN REGIONAL MASKS **************');

mkdir([directories.flirtdir '/standard_to_anat']);

%  Map the standard MNI to subjects anatomical space - need the
%  transformation matrix for 3D predetermined ROI's - this may already be
%  saved in recon ..?
command = ['flirt -in ' directories.matlabdir '/standard_files/avg152T1_brain.nii.gz -ref data/recon/' subj.name '/' subj.name '_anat_brain.nii -out ' directories.flirtdir '/standard_to_anat/standard_brain_to_anat.nii -omat ' directories.flirtdir '/standard_to_anat/standard_brain_to_anat.mat -dof 12'];
status = system(command);
% command = ['fnirt -in ' directories.matlabdir '/standard_files/avg152T1_brain.nii.gz -aff ' directories.flirtdir '/standard_to_anat/standard_brain_to_anat.mat -cout ' directories.flirtdir '/standard_to_anat/nonlinear_transform'];
% status = system(command);

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