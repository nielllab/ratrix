function out=isValidClientCommand(r,c)
cs=fieldnames(r.constants.serverToStationCommands);
out=false;
for i=1:length(cs)
    if r.constants.serverToStationCommands.(cs{i})==c
        out= true;
    end
end