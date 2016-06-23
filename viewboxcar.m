function viewboxcar(source,callbackdata,subj,dir_input)

    stimlocation = strcat(dir_input,'/metadata/stim/bhonset',subj.name,'_customized.txt');
    newplot = load(stimlocation);
    figure('Name','Customized boxcar plot'),
    plot(newplot); 
    
end