function out=testAllSubjectBoxAndStationDirs(r)
makeAllSubjectServerDirectories(r);

out=true;
for i=1:length(r.boxes)
    b=r.boxes{i};
    sIDs=getStationIDsForBoxID(r,getID(b));
    out=out && testBoxSubjectAndStationDirs(r,b,sIDs);
    stations=getStationsForBoxID(r,getID(b));

    
    for i=1:length(stations)

        out = out && checkPath(stations(i));
    end
end

