function s=considerOpportunisticRefill(s)
[s.pump didOpportunisiticRefill]=considerOpportunisticRefill(s.zones{s.lastZone},s.pump);
if didOpportunisiticRefill
    s.needsAntiRock=true;
elseif s.needsAntiRock   %don't do this every time cuz might want to do more refills first
    s.pump=doAntiRock(s.zones{s.lastZone},s.pump);
    s.needsAntiRock = false;
end