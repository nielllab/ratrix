function [durs,s] = doInfuse(s,zoneNum,vol,check)
    [durs,s.pump] = doInfuse(s.zones{zoneNum},s.pump,vol,check);
end
