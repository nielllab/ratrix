function s=closePumpSystem(s)
[durs t s.pump]=resetPumpPosition(s.zones{1},s.pump);
    s.pump=closePump(s.pump);
    durs=ensureAllRezFilled(s);
    closeAllValves(s);
    s=[];