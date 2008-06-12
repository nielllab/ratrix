function s=initPumpSystem(s)
if ~isempty(s.zones)
    closeAllValves(s);
    [s.pump durs]=openPump(s.pump);
    s.lastZone=ceil(rand*length(s.zones));
    [durs t s.pump]=resetPumpPosition(s.zones{s.lastZone},s.pump);
    [s.pump durs]=equalizePressure(s.zones{s.lastZone},s.pump);
    s.needsAntiRock=false;
else
    error('can''t init a pumpsystem with no zones')
end