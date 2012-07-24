function securePins(st)
setValves(st,0*getValves(st))
setPuff(st,false);
setStatePins(st,'all',false);
verifyValvesClosed(st);
setLaser(st,false);