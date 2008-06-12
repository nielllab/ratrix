function s=resetPosition(s)

if ~s.inited
    error('localPump not inited')
end

if isa(s.station,'station')
    verifyValvesClosed(s.station);
else
    error('not inited')
end

setRezValve(s,s.const.valveOn);
[dursTemp t s.pump]=doAction(s.pump,0,'reset position');
WaitSecs(s.eqDelay);
setRezValve(s,s.const.valveOff);