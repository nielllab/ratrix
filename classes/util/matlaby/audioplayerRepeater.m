function audioplayerRepeater(a,b)
set(a,'UserData',get(a,'UserData')-get(a,'TotalSamples'));
%disp(sprintf('%g more to go',get(a,'UserData')))
if get(a,'UserData')>0
    play(a,[1 min(get(a,'TotalSamples'),get(a,'UserData'))]);
else
    set(a,'UserData',0);
end