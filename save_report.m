function save_report(source,callbackdata,subj,directories)

handles = guidata(source);

fileID = fopen([directories.main '/' subj.name '/clinician_final/' subj.name '_clinical_report.txt'],'w+'); 
format = '%s\n';
fprintf(fileID, format, ['Subject: ' subj.name]);
fprintf(fileID, format, '');
fprintf(fileID, format, '#### RESULTS ####');
temp = handles.success_dropdown.String(handles.success_dropdown.Value);
success = temp{1};
fprintf(fileID, format, ['Adequacy of the study: ' success]);
temp = handles.impression_dropdown.String(handles.impression_dropdown.Value);
impression = temp{1};
fprintf(fileID, format, ['Impression: ' impression]);
fprintf(fileID, format, '');
fprintf(fileID, format, '#### IMPAIRED REACTIVITY ####');
temp = handles.decreased_reactivity_dropdown.String(handles.decreased_reactivity_dropdown.Value);
decreased_reactivity = temp{1};
    fprintf(fileID, format, ['Decreased Reactivity: ' decreased_reactivity]);
if strcmp(decreased_reactivity,'yes') == 1
    if handles.impaired_laterality_left.Value == 1 && handles.impaired_laterality_right.Value == 1 && handles.impaired_laterality_midline == 1
        C = 'left,right,midline';
    elseif handles.impaired_laterality_left.Value == 1 && handles.impaired_laterality_right.Value == 1
        C = 'left,right';
    elseif handles.impaired_laterality_left.Value == 1 && handles.impaired_laterality_midline.Value == 1
        C = 'left,midline';
    elseif handles.impaired_laterality_right.Value == 1 && handles.impaired_laterality_midline.Value == 1
        C = 'right,midline';
    elseif handles.impaired_laterality_left.Value == 1
        C = 'left';
    elseif handles.impaired_laterality_right.Value == 1
        C = 'right';
    elseif handles.impaired_laterality_midline.Value == 1
        C = 'midline';
    end
    fprintf(fileID, format, ['Laterality: ' C]);
    fprintf(fileID,format,'## Left Side ##');
    fprintf(fileID,format,['Regions: ' handles.impaired_left_enter_regions_box.String]);
    temp = handles.impaired_left_steal_dropdown.String(handles.impaired_left_steal_dropdown.Value);
    impaired_left_steal = temp{1};
    fprintf(fileID,format,['Steal: ' impaired_left_steal]);
    if strcmp(impaired_left_steal,'yes') == 1
        fprintf(fileID,format,['Steal location: ' handles.impaired_left_steal_regions_box.String]);
    end
    fprintf(fileID,format,'## Right Side ##');
    fprintf(fileID,format,['Regions: ' handles.impaired_right_enter_regions_box.String]);
    temp = handles.impaired_right_steal_dropdown.String(handles.impaired_right_steal_dropdown.Value);
    impaired_right_steal = temp{1};
    fprintf(fileID,format,['Steal: ' impaired_right_steal]);
    if strcmp(impaired_right_steal,'yes') == 1
        fprintf(fileID,format,['Steal location: ' handles.impaired_right_steal_regions_box.String]);
    end
end

fprintf(fileID, format, '');
fprintf(fileID, format, '#### POSITIVE REACTIVITY ####');
temp = handles.decreased_reactivity_dropdown.String(handles.increased_reactivity_dropdown.Value);
increased_reactivity = temp{1};
    fprintf(fileID, format, ['Increased Reactivity: ' increased_reactivity]);
if strcmp(increased_reactivity,'yes') == 1
    if handles.positive_laterality_left.Value == 1 && handles.positive_laterality_right.Value == 1 && handles.positive_laterality_midline == 1
        C = 'left,right,midline';
    elseif handles.positive_laterality_left.Value == 1 && handles.positive_laterality_right.Value == 1
        C = 'left,right';
    elseif handles.positive_laterality_left.Value == 1 && handles.positive_laterality_midline.Value == 1
        C = 'left,midline';
    elseif handles.positive_laterality_right.Value == 1 && handles.positive_laterality_midline.Value == 1
        C = 'right,midline';
    elseif handles.positive_laterality_left.Value == 1
        C = 'left';
    elseif handles.positive_laterality_right.Value == 1
        C = 'right';
    elseif handles.positive_laterality_midline.Value == 1
        C = 'midline';
    end
    fprintf(fileID, format, ['Laterality: ' C]);
    fprintf(fileID,format,'## Left Side ##');
    fprintf(fileID,format,['Regions: ' handles.positive_left_enter_regions_box.String]);
    fprintf(fileID,format,'## Right Side ##');
    fprintf(fileID,format,['Regions: ' handles.positive_right_enter_regions_box.String]);
end
    fprintf(fileID,format,'');
    fprintf(fileID,format,'#### INTERPRETATION/COMMENTS ####');
    fprintf(fileID,format,handles.interpretation_entry_box.String);

fclose(fileID);      

close(['Clinical Report: ' subj.name]);

h = msgbox('Report saved');
pause(2);

run('/data/hannahsennik/MATLAB/CVR_GUI/SickKids_CVR.m');
end