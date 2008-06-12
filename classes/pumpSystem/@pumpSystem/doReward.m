function s=doReward(s,mlRewardSize,zone)
fprintf('rewarding zone %d\n',zone)
if s.needsAntiRock
    s.pump=doAntiRock(s.zones{zone},s.pump);
    s.lastZone=zone;
    s.needsAntiRock=false;
end
[durs s.pump] =doInfuse(s.zones{zone},s.pump,mlRewardSize,s.lastZone~=zone);
s.lastZone=zone;