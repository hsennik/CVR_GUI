function analyze_subject(source,callbackdata,subj,directories)
% Function to analyze the subject 
% 
% INPUTS 
%     subj - subject data (name,date,breathhold)
%     directories - all of the directories for the subject
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 13, 2016
% Author - Hannah Sennik

handles = guidata(source); % get info from the main interface

figures = findall(0,'type','figure'); % close all figures except the main interface 
close(figures(2:end));

set(handles.look,'Enable','off'); % Enable the push button for the user to look at the processed and analyzed subject data
set(handles.boxcar(1),'Enable','off'); % Disable all of the boxcar radio buttons 
set(handles.boxcar(2),'Enable','off');
set(handles.boxcar(3),'Enable','off');

pause(2);

%  Tell the user to wait for the subject to be processed
handles.analyze_prompt = uicontrol('Style','text',...
                    'units','normalized',...
                    'Position',[0.05,0.09,0.9,0.035],...
                    'String','Please wait while the subject is being analyzed');

%  Open file that indicates which boxcar was selected
fileID = fopen([directories.textfilesdir '/standard_shifted_customized.txt'],'w+');
format = '%d\n';

if handles.study_selection.Value == 2 || handles.study_selection.Value == 3
    if handles.boxcar(1).Value == 1 % standard boxcar was selected for breathhold
        fprintf(fileID,format,1);
        boxcar_destination = ['standard_boxcar'];
        fclose(fileID);
    elseif handles.boxcar(2).Value == 1 % shifted boxcar was selected for breathhold 
        fprintf(fileID,format,2);
        boxcar_destination = ['shifted_boxcar'];
        fclose(fileID);
    elseif handles.boxcar(3).Value == 1 % customized boxcar was selected for breathhold
        fprintf(fileID,format,3);
        boxcar_destination = ['customized_boxcar'];
        fclose(fileID);
    end
end

if handles.pf.Value == 1 % if pf checkbox was selected on interface then run analysis for pf 
    start = 1;
    %  Make flirt directory that will be used for mapping functional data to
    %  anatomical space, and for generating pf stimfiles
    mkdir([directories.subject '/' directories.flirtdir '/pf']);
    mkdir([directories.subject '/' directories.flirtdir '/pf_raw']);
else % if pf checkbox was not selected on interface then do not analyze using pf 
    start = 2;
end

if exist(['data/analyzed_pf/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii'],'file') == 2
    start = 2;
end

if handles.raw.Value == 1
    raw_too = 2;
else 
    raw_too = 1;
    mkdir([directories.subject '/' directories.flirtdir '/' boxcar_destination '_raw']);
end

mkdir([directories.subject '/' directories.flirtdir '/' boxcar_destination]);

fileID = fopen([directories.textfilesdir '/stimulus.txt'],'w+'); % Open the text file in write mode to write the stimulus values
format = '%d\n';
fprintf(fileID,format,start);
fclose(fileID);

fileID = fopen([directories.textfilesdir '/otherstimsel.txt'],'w+');
format = '%s';

if strcmp(handles.alternative_methods.String, 'Respiratory Bellows') == 1 
    stimulus_number = 3; %  a dropdown stimfile has been selected
    thirdseldest = 'bellows';
    fprintf(fileID,format,thirdseldest);
elseif strcmp(handles.alternative_methods.String, 'End tidal CO2') == 1
    stimulus_number = 3;
    thirdseldest = 'endtidal';
    fprintf(fileID,format,thirdseldest);
else
    stimulus_number = 2; %  stimulus_number = 2 means boxcar and pf
end
fclose(fileID);

for stimulus=start:stimulus_number %  First for loop goes through stimfile selections
    for processed = 1:raw_too % Second for loop analyzes processed and then unprocessed data
      
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
            s3 = ['/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii -out flirt/'];
            s4 = destination_name_A;
            s5 = ['/stand2funct.nii -omat ' directories.flirtdir '/'];
            s6 = '/stand2funct.mat -dof 12';

            brainmni2target = [s1 s2 s3 s4 s5 s4 s6];
            command = brainmni2target;
            status = system(command);
            
            directories.standfunct = 'standard_to_functional';
            mkdir(directories.flirtdir,['/' directories.standfunct]);
            
            standard_file = 'Cerebellum-MNIflirt-maxprob-thr50-2mm.nii.gz';
            out_file = ['/' destination_name_A '/cereb2funct.nii'];
            s13 = [destination_name_A '/pf_stim_' subj.proc_rec_sel '_' destination_name_P '.1D'];
            region = 'Cerebellum';
               
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
            s12 = ['/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '.nii > flirt/'];

            mask = [s10 s11 s2 s12 s13];
            status = system(mask);
            copy_stim = ['cp ' directories.flirtdir '/' s13 ' ' directories.metadata '/stim'];

            command = copy_stim;
            status = system(command);
            display(['Stim file created from ' region]);
        elseif stimulus == 2
            fileID = fopen([directories.textfilesdir '/stimulus.txt'],'w+'); % Open the text file in write mode to write the stimulus values
            format = '%d\n';
            fprintf(fileID,format,2); 
            fclose(fileID);
            destination_name_A = boxcar_destination;
            if processed == 2
                destination_name_A = [boxcar_destination '_raw'];
            end
        elseif stimulus == 3
            fileID = fopen([directories.textfilesdir '/stimulus.txt'],'w+');
            format = '%d\n';
            fprintf(fileID,format,3);
            fclose(fileID);
            if processed == 2
                destination_name_A = [thirdseldest '_raw'];
            else
                destination_name_A = thirdseldest;
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
        str3 = ['/CVR_' subj.date '/final/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck.nii -ref data/recon'];
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

        for i = 5:7
            if i == 5
                funct_name = 'coeff';
            elseif i == 6
                funct_name = 'tstat';
            elseif i == 7
                funct_name = 'R2';
            end
            %  Save the buckets of functional data 
            voxel_size = [temp.hdr.dime.pixdim(2) temp.hdr.dime.pixdim(3) temp.hdr.dime.pixdim(4)];
            temp.brain_bucket = double(squeeze(temp.img(:,:,:,:,i)));
            nii = make_nii(temp.brain_bucket,voxel_size);
            save_bucket = [directories.flirtdir '/' destination_name_A '/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_' funct_name '.nii'];
            save_nii(nii,save_bucket); 

            %  Map the fifth bucket to anatomical space using the
            %  transformation matrix generated above
            str8 = ['flirt -in ' directories.flirtdir '/'];
            str9 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_' funct_name '.nii -ref data/recon'];
            str10 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_' funct_name '_anat_space.nii -init ' directories.flirtdir '/'];
            str11 = ['/' subj.name '_' subj.breathhold '_CVR_' subj.date '_glm_buck_anat_space.mat -applyxfm'];

            bucket2anat = [str8 str2 str9 str5 str2 str10 str2 str11];
            command = bucket2anat;
            status = system(command);
        end

    end
end

% Map white,gray matter,csf to functional space to do 3dmaskave
for i = 0:3
    if i == 0
        mask_name = 'csf';
    elseif i == 1
        mask_name = 'gray';
    elseif i == 2
        mask_name = 'white';
    elseif i == 3
        mask_name = 'no_csf';
        command = ['flirt -in data/recon/' subj.name '/' subj.name '_nocsf.nii -ref data/processed/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii -out ' directories.flirtdir '/' mask_name '_funct_mask.nii -init data/recon/' subj.name '/' subj.name '_anat_' subj.proc_rec_sel '.xfm -applyxfm'];
        status = system(command);
    end
    if i ~= 3
        command = ['flirt -in data/recon/' subj.name '/' subj.name '_anat_brain_seg_' num2str(i) '.nii -ref data/processed/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii -out ' directories.flirtdir '/' mask_name '_funct_mask.nii -init data/recon/' subj.name '/' subj.name '_anat_' subj.proc_rec_sel '.xfm -applyxfm'];
        status = system(command);
    end
    command = ['3dmaskave -q -mask ' directories.flirtdir '/' mask_name '_funct_mask.nii data/processed/CVR_' subj.date '/final/' subj.name '_' subj.proc_rec_sel '_CVR_' subj.date '.nii > ' directories.timeseries '/' mask_name '_' subj.breathhold '.1D'];
    status = system(command);
end

set(handles.start,'Enable','off');
set(handles.start,'String','Subject Analyzed');
set(handles.look,'Enable','on'); % Enable the push button for the user to look at the processed and analyzed subject data

set(handles.analyze_prompt,'String','                  ');

pause(1);

end