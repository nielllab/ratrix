function leds(p,v)
pp(p.LEDs,ismember(1:length(p.LEDs),v),p.slowChecks,[],p.addr);
end