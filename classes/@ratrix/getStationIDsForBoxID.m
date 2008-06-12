function out=getStationIDsForBoxID(r,bid)
    out=[];
    stns=getStationsForBoxID(r,bid);
    for i=1:length(stns)
        out=[out getID(stns(i))];
    end