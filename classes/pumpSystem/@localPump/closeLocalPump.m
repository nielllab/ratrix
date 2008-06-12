function s=closeLocalPump(s)
if ~s.inited
    error('localPump not inited')
end

s=resetPosition(s);

s.pump=closePump(s.pump);
setRezValve(s,s.const.valveOff);

