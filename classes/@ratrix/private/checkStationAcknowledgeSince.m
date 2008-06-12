%look for an appropriately dated text file in the appropriate place on the station that acknowledges the last command.
function out=checkStationAcknowledgeSince(r,s,startTime)
    if isa(s,'station')
        out=0;
    else
        error('not a station object')
    end