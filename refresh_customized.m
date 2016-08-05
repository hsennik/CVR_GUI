function refresh_customized(source,callbackdata)
    handles = guidata(source);
    for i = 1:str2double(handles.number_blocks.String)
        set(handles.breathhold(i),'String','');
        set(handles.normal(i),'String','');
    end
    set(handles.number_blocks,'String','');
    set(handles.start_delay,'String','');
end

