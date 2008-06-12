%copy latest code and write ratrix containing just this box, station, subject, and protocol to the station directory.
%consider updating ptb (need flag?)
function out=writeObjectsToStationAndStart(r,b,stationID)

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