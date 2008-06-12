function closeAllValves(s)
for i = 1:length(s.zones)
    closeAllValves(s.zones{i});
end