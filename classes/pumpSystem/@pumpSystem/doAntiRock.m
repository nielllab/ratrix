function s = doAntiRock(s,k)
    s.pump = doAntiRock(s.zones{k},s.pump);
end