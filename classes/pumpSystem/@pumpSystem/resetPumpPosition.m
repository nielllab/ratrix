function [durs t s]=resetPumpPosition(s,zoneNum)
    [durs t s.pump]=resetPumpPosition(s.zones{zoneNum},s.pump);
end