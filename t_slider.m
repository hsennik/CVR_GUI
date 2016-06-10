function t_slider(source,callbackdata,mp)

tnum = get(source,'Value');
display (tnum);

tnum = round(tnum,4);

set(mp.t_number,'String',tnum);

end