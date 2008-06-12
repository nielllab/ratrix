function [s durs]=equalizePressure(s,lastZone)
    [s.pump durs]=equalizePressure(s.zones{lastZone},s.pump);
end