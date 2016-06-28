function startprocessing(source,callbackdata,subj,dir_input)

handles = guidata(source);
%  Make flirt directories that will be used for mapping functional data to
%  anatomical space, and for generating pf stimfiles

mkdir(dir_input,'flirt/pf');
mkdir(dir_input,'flirt/pf_not_processed');

%  Process and analyze subject data for all combinations of temporal
%  filtering and stimfile selection

fileID = fopen('metadata/mat2py.txt','w+'); % Open the text file in write mode to write the processed and stimulus values (initially both will be 1)
format = '%d\n';
fprintf(fileID,format,1,1); % Write the filtering and stimulus values in the file (they will be used in process_fmri and analyze_fmri)
fclose(fileID);

fileID = fopen('metadata/noprocessing.txt','w+');
format = '%d\n';
fprintf(fileID,format,2);

%  Run the processing pipeline with all steps
command = strcat('python metadata/process_fmri.py metadata/S_CVR_',subj.name,'.txt  metadata/P_CVR_',subj.name,'.txt --clean');
status = system(command);

fileID = fopen('metadata/noprocessing.txt','w+'); % Open the text file in write mode that determine whether or not to do processing 
format = '%d\n';
fprintf(fileID,format,1); % Write the number 1 to not do processing 

%  Run the processing pipeline but disclude steps so it is NO processing 
command = strcat('python metadata/process_fmri.py metadata/S_CVR_',subj.name,'.txt  metadata/P_CVR_',subj.name,'.txt --clean');
status = system(command);

% for a = 1:2
%     if a == 1
%         breathhold = 'BH1';
%         display('BH1');
%     else
%         breathhold = 'BH2';
%         display('BH2');
%     end
%     %  Map the processed data to anatomical space 
%     command = strcat('flirt -in data/processed/CVR_',subj.date,'/',subj.name,'/',subj.name,'_',breathhold,'_trim_mc_ts_tfilt_2Dsm7.nii -ref data/recon/',subj.name,'/',subj.name,'_anat_brain.nii -out flirt/',subj.name,'_',breathhold,'_processed_to_anat.nii -omat flirt/',subj.name,'_',breathhold,'_processed_to_anat.mat -dof 12');
%     status = system(command);
% 
%     %  Map the unprocessed data to anatomical space 
%     command = strcat('flirt -in data/processed_not/CVR_',subj.date,'/',subj.name,'/',subj.name,'_',breathhold,'_CVR_',subj.date,'.nii -ref data/recon/',subj.name,'/',subj.name,'_anat_brain.nii -out flirt/',subj.name,'_',breathhold,'_processed_not_to_anat.nii -omat flirt/',subj.name,'_',breathhold,'_processed_not_to_anat.mat -dof 12');
%     status = system(command);
% end

%  PROCESSED using no temporal filtering and NOTPROCESSED, ANALYZED using boxcar and pf, BH1 BH2
for i=1:2 % First for loop goes through processed and not processed
    processed = i;
    display(processed); % Filtering method for process
    
    if processed == 2
        fileID = fopen('metadata/noprocessing.txt','w+'); % Open the text file in write mode that determine whether or not to do processing 
        format = '%d\n';
        fprintf(fileID,format,1); % Write the number 1 to not do processing 
        %  ALSO HAVE TO DO MASKING.. maybe if reg does not work 
    elseif processed == 1
        fileID = fopen('metadata/noprocessing.txt','w+');
        format = '%d\n';
        fprintf(fileID,format,2);
    end
    
    for j=1:2 % Second for loop goes through the two stimfile selections
        stimulus = j;
        display(stimulus); % Stimulus method for analyze 
        if((processed == 1)&&(stimulus == 1))
            if(handles.boxcar(2).Value == 1)
                destination_name_P = '';
                destination_name_A = 'customized_boxcar';
            else
                destination_name_P = '';
                destination_name_A = 'standard_boxcar';
            end
        elseif((processed == 1)&&(stimulus == 2))
            destination_name_P = '';
            destination_name_A = 'pf';  
        elseif((processed == 2)&&(stimulus == 1))
            if(handles.boxcar(2).Value == 1)
                destination_name_P = '_not';
                destination_name_A = 'customized_boxcar_not_processed';
            else
                destination_name_P = '_not';
                destination_name_A = 'standard_boxcar_not_processed';
            end
        elseif((processed == 2)&&(stimulus == 2))
            destination_name_P = '_not';
            destination_name_A = 'pf_not_processed';
        end
        
        display(destination_name_A);
        display(destination_name_P);
        
        if(stimulus == 2) % If stimulus selected is pf then have to transform standard data to the subject space to create 1D pf stimfile
            for bh_pf=1:3
                if bh_pf == 1
                    subj.breathhold = 'BH1';
                elseif bh_pf == 2
                    subj.breathhold = 'BH2';
                elseif bh_pf == 3
                    subj.breathhold = 'HV';
                end
                
                s1 = 'flirt -in standard_files/avg152T1_brain.nii.gz -ref data/processed';
                s2 = destination_name_P;
                s3 = strcat('/CVR_',subj.date,'/final/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'.nii -out flirt/');
                s4 = destination_name_A;
                s5 = '/stand2funct.nii -omat flirt/';
                s6 = '/stand2funct.mat -dof 12';

                %  Transform MNI standard brain to subject space
                brainmni2target = strcat(s1,s2,s3,s4,s5,s4,s6);
                command = brainmni2target;
                status = system(command);

                s7 = 'flirt -in standard_files/Cerebellum-MNIflirt-maxprob-thr50-2mm.nii.gz -ref data/processed';
                s8 = '/cereb2funct.nii -init flirt/';
                s9 = '/stand2funct.mat -applyxfm';

                %  Transforming standard cerebellum to subject space using the
                %  transformation matrix generated in previous transformation
                cereb2target = strcat(s7,s2,s3,s4,s8,s4,s9);
                command = cereb2target;
                status = system(command);

                s10 = '3dmaskave -q -mask flirt/';
                s11 = '/cereb2funct.nii data/processed';
                s12 = strcat('/CVR_',subj.date,'/final/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'.nii > flirt/');

                %  Using 3dmaskave to create a 1D stimfile based on signal in
                %  the cerebellum 
                if(processed == 2)
                    mask = strcat(s10,s4,s11,s2,s12,s4,'/','pf','_',subj.breathhold,'_stim_not_processed.txt');
                else
                    mask = strcat(s10,s4,s11,s2,s12,s4,'/','pf','_',subj.breathhold,'_stim.txt');
                end
                command = mask;
                status = system(command);

                %  Copying the pf stimfile to stim in metadata
                if(processed == 2)
                    copy_stim = strcat('cp flirt/',s4,'/','pf','_',subj.breathhold,'_stim_not_processed.txt',' metadata/stim');
                else
                    copy_stim = strcat('cp flirt/',s4,'/',s4,'_',subj.breathhold,'_stim.txt',' metadata/stim');
                end
                command = copy_stim;
                status = system(command);
                display('Stim file created from cerebellum');
            end
        end
       
        fileID = fopen('metadata/mat2py.txt','w+'); % Open the text file in write mode
        format = '%d\n';
        fprintf(fileID,format,processed,stimulus); % Write the filtering and stimulus values in the file (they will be used in process_fmri and analyze_fmri)
        fclose(fileID);
        
        %  Run the analyze pipeline
        command = strcat('python metadata/analyze_fmri.py metadata/S_CVR_',subj.name,'.txt metadata/A_CVR_',subj.name,'.txt --clean');
        status = system(command);

        display(destination_name_A);
        
        for k=1:3 % Third for loop goes through the breathholds and maps the functional data to be displayed to the user 
            breathhold = k;
            if(breathhold ==1)
                subj.breathhold = 'BH1';
            elseif(breathhold ==2)
                subj.breathhold = 'BH2';
            elseif(breathhold==3)
                subj.breathhold = 'HV';
            end
            
            str1 = 'flirt -in data/analyzed_';
            str2 = destination_name_A;
            str3 = strcat('/CVR_',subj.date,'/final/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck.nii -ref data/recon');
            str4 = destination_name_P;
            str5 = strcat('/',subj.name,'/',subj.name,'_anat_brain.nii -out flirt/');
            str6 = strcat('/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_anat_space.nii -omat flirt/');
            str7 = strcat('/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_anat_space.mat -dof 12');

            %  Transform the functional data to anatomical space
            glm2anat = strcat(str1,str2,str3,str5,str2,str6,str2,str7);
            command = glm2anat;
            status = system(command);

            %  Load the unmapped functional data 
            load_glm = strcat('data/analyzed_',destination_name_A,'/CVR_',subj.date,'/final/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck.nii');
            temp = load_nii(load_glm);
            [temp.x,temp.y,temp.z] = size(temp.img);

            %  Save the fifth bucket of the functional data (coeff bucket)
            voxel_size = [temp.hdr.dime.pixdim(2) temp.hdr.dime.pixdim(3) temp.hdr.dime.pixdim(4)];
            temp.brain_bucket_5 = double(squeeze(temp.img(:,:,:,:,5)));
            nii = make_nii(temp.brain_bucket_5,voxel_size);
            save_fifthbucket = strcat('flirt/',destination_name_A,'/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE.nii');
            save_nii(nii,save_fifthbucket); 

            str8 = 'flirt -in flirt/';
            str9 = strcat('/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE.nii -ref data/recon');
            str10 = strcat('/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_FIVE_anat_space.nii -init flirt/');
            str11 = strcat('/',subj.name,'_',subj.breathhold,'_CVR_',subj.date,'_glm_buck_anat_space.mat -applyxfm');

            %  Map the fifth bucket to anatomical space using the
            %  transformation matrix generated when mapping the functional data
            %  to anatomical
            bucketfive2anat = strcat(str8,str2,str9,str5,str2,str10,str2,str11);
            command = bucketfive2anat;
            status = system(command);
            
        end
    end
end

fileID = fopen('metadata/noprocessing.txt','w+'); % Open the text file in write mode
         format = '%d\n';
         fprintf(fileID,format,2); % Write the number 2 to noprocessing.txt (this reverts back to doing regular processing)
         fclose(fileID);
         
fileID = fopen(strcat(dir_input,'customize_boxcar.txt'),'w+');
format = '%d\n';
fprintf(fileID,format,2); % Write the number 2 to customize_boxcar.txt (this reverts back to using the standard boxcar)
fclose(fileID);        

display('ALL DONE');

%  set(handles.look,'Enable','on'); % Enable the push button for the user to look at the processed and analyzed subject data

end

