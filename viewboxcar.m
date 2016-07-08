function viewboxcar(source,callbackdata,subj,dir_input,breath)

if breath == 1
    subj.breathhold = 'BH1';
    name = 'Customized BH1 boxcar plot';
    pos = [400,300,500,300];
elseif breath == 2
    subj.breathhold = 'BH2';
    name = 'Customized BH2 boxcar plot';
    pos = [950,300,500,300];
elseif breath == 3
    subj.breathhold = 'HV';
    name = 'Customized HV boxcar plot';
    pos = [1500,300,500,300];
end

stimlocation = strcat(dir_input,'/metadata/stim/bhonset',subj.name,'_',subj.breathhold,'_customized.1D');
newplot = load(stimlocation);
    
figure('Name',name,...
       'Visible','on',...
        'Position',pos); 
plot(newplot); 
    
end