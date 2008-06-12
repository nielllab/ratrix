function setRezValve(s,state)

if ~s.inited
    error('localPump not inited')
end

if ismember(state,[s.const.valveOff s.const.valveOn])
putvalue(s.rezValveDIO,state); %appears to not overwrite other lines!  nice.
WaitSecs(s.valveDelay);
else
    error('bad state')
end