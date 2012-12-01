function p = trig(p,v)
if v
    p = leds(p,p.LEDf(p.ind));
end

pp(p.trig,v,p.slowChecks,[],p.addr);
end