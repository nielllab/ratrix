function p = leds(p,v)
pp(p.LEDs,ismember(1:length(p.LEDs),v),p.slowChecks,[],p.addr);
if isscalar(v) && isnan(p.record(6,p.ind))
    p.record(6,p.ind) = v;
end
end