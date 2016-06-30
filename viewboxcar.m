function viewboxcar(source,callbackdata,subj,dir_input,HV)

if HV ==1
    subj.breathhold = 'HV';
else
    subj.breathhold = 'BH1';
end
    stimlocation = strcat(dir_input,'/metadata/stim/bhonset',subj.name,'_',subj.breathhold,'_customized.1D');
    newplot = load(stimlocation);
    if HV ==1
        name = 'Customized HV boxcar plot';
        pos = [950,300,500,300];
    else
        name = 'Customized BH boxcar plot';
        pos = [400,300,500,300];
    end
    
    figure('Name',name,...
           'Visible','on',...
            'Position',pos); 
    plot(newplot); 
    
end