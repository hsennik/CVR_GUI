function create_BH1BH2boxcar(source,callbackdata,subj,dir_input,sp)

% Function to get breathhold data from user to create a customized boxcar for BH1 and BH2 - assuming that
% the same boxcar should be used for both 
% 
% INPUTS 
%     subj - subject data (name, breathhold, date)
%     dir_input - directory where data should we stored
%     sp - data from the 'Process and Analyze Subject' figure
% 
% *************** REVISION INFO ***************
% Original Creation Date - July 8, 2016
% Author - Hannah Sennik

handles = guidata(source);
breath = 1;

if handles.custom(4).Value == 1

    set(handles.custom(1),'Enable','off');
    set(handles.custom(2),'Enable','off');
    same_boxcar = 1;
    
    if handles.custom(1).Value == 1
        close('Create customized BH1 boxcar');
    end
    if handles.custom(2).Value == 1
        close('Create customized BH2 boxcar');
    end
    set(handles.custom(1),'Value',0);
    set(handles.custom(2),'Value',0);
    
    %  Create a new figure for boxcar customization
    cb.f = figure('Name', 'Create customized BH1 & BH2 boxcar',...
                    'Visible','on',...
                    'Position',[900,800,500,300],...
                    'numbertitle','off');

    %  Create data entry boxes for customized boxcar - user enters start and
    %  end times in seconds 

    %  Create edit box for number of blocks in boxcar 
    cb.number_blocks = uicontrol('Style','edit',...
                                'Units','pixels',...
                                'Enable','on',...
                                'Position',[200,260,100,20]);
    %  Create edit box for start delay                         
    cb.start_delay = uicontrol('Style','edit',...
                                'Units','pixels',...
                                'Enable','on',...
                                'Position',[200,210,100,20]);   

    %  Create edit box for duration of break (if any) during study                         
    cb.break_duration = uicontrol('Style','edit',...
                                'Units','pixels',...
                                'Enable','on',...
                                'Position',[200,160,100,20]);   

    %  Create edit box to specify which block the break comes after                         
    cb.break_after_block = uicontrol('Style','edit',...
                                    'Units','pixels',...
                                    'Enable','on',...
                                    'Position',[200,110,100,20]);         

    %  Create edit box to specify the duration of each breathhold (assuming all
    %  are the same)
    cb.breathhold_duration = uicontrol('Style','edit',...
                                    'Units','pixels',...
                                    'Enable','on',...
                                    'Position',[200,60,100,20]);

    %  Create edit box to specify the duration of normal breathing periods
    %  (assuming all are the same)
    cb.normal_breathing_duration = uicontrol('Style','edit',...
                                            'Units','pixels',...
                                            'Enable','on',...
                                            'Position',[200,10,100,20]);                                    

    %  Descriptive text for customized boxcar data entry fields

    cb.number_blocks_text = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'Position',[0.05,0.88,0.3,0.05],...
                                    'String','Number of blocks:');

    cb.start_delay_text = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'Position',[0.05,0.71,0.3,0.05],...
                                    'String','Start Delay:');            

    cb.break_duration_text = uicontrol('Style','text',...
                                    'units','normalized',...
                                    'Position',[0.05,0.54,0.3,0.05],...
                                    'String','Break duration:');

    cb.break_after_block_text = uicontrol('Style','text',...
                                        'units','normalized',...
                                        'position',[0.05,0.37,0.3,0.05],...
                                        'String','Break after block:');

    cb.breathhold_duration_text = uicontrol('Style','text',...
                                        'units','normalized',...
                                        'Position',[0.05,0.20,0.3,0.05],...
                                        'String','Breathhold duration:');

    cb.normal_breathing_duration_text = uicontrol('Style','text',...
                                                'units','normalized',...
                                                'Position',[0,0.04,0.4,0.05],...
                                                'String','Normal breathing duration:');

    %  Create push button to create customized boxcar from entered data 
    cb.createboxcar = uicontrol('Style','togglebutton',...
                              'Visible','on',...
                              'String','Create Boxcar',...
                              'Enable','off',...
                              'Value',0,'Position',[350,150,150,45],...
                              'Callback',{@create_boxcar_textfile,subj,dir_input,breath,sp,same_boxcar});

    %  Create push button to view customized boxcar (user can re-enter data in
    %  fields until this button is pressed) 
    cb.viewboxcar = uicontrol('Style','togglebutton',...
                              'Visible','on',...
                              'String','View Boxcar',...
                              'Enable','off',...
                              'Value',0,'Position',[350,90,150,45],...
                              'Callback',{@viewboxcar,subj,dir_input,breath,same_boxcar});

    %     cb.HVboxcar = uicontrol('Style','togglebutton',...
    %                               'Visible','on',...
    %                               'String','Customize HV',...
    %                               'Enable','off',...
    %                               'Value',0,'Position',[350,30,150,45],...
    %                               'Callback',{@create_HVboxcar,subj,dir_input,sp});

    %  Get figure data 
    guidata(cb.f,cb);   

    %  Wait for the user to enter data in the last edit field - need a more
    %  robust way to do this (check that all fields have been filled in)
    waitfor(cb.normal_breathing_duration,'String');
    %  Then allow the user to click on create boxcar 
    set(cb.createboxcar,'Enable','on');
else
    set(handles.custom(1),'Enable','on');
    set(handles.custom(2),'Enable','on');
    close('Create customized BH1 & BH2 boxcar');
end

end