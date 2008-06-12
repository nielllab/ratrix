%write stop request textfile to appropriate station directory.
function out=stopStation(r,b,stationID)
    if isa(b,'box')
        if ismember(stationID,getStationIDsForBoxID(r,getID(b)))
           s=getStationByID(r,stationID)
            out=1;
        else
            error('that station not in that box')
        end
    else
        error('not a box object')
    end