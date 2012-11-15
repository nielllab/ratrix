function trig(p,v)
if v
    leds(p,p.LEDf(p.ind));
end

pp(p.trig,v,p.slowChecks,[],p.addr);
end