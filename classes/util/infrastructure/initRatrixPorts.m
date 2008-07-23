function st=initRatrixPorts

st=makeDefaultStation('99Z','','000000000000',int8([1 1 1]),int8(0),'localTimed');
setValves(st,0*getValves(st))
setPuff(st,false);
framePulse(st);