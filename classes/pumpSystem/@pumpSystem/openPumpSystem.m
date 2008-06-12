function [s durs] = openPumpSystem(s)
    [s.pump durs]=openPump(s.pump);
end