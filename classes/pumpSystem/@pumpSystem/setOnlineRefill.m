%need to rapidly call this over and over to avoid flooding!
function setOnlineRefill(s)
for i=1:length(s.zones)
    setOnlineRefill(s.zones{i});
end