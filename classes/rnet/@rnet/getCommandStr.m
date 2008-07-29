function out=getCommandStr(r,c)
server2station=fields(r.constants.serverToStationCommands);
for i=1:length(server2station)
    if c==r.constants.serverToStationCommands.(server2station{i})
        out=['SERVER->STATION:' server2station{i}];
        return
    end
end

station2server=fields(r.constants.stationToServerCommands);
for i=1:length(station2server)
    if c==r.constants.stationToServerCommands.(station2server{i})
        out=['STATION->SERVER:' station2server{i}];
        return
    end
end

c
error('unrecognized command')