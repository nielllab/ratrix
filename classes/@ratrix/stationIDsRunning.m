function out=stationIDsRunning(r,stationIDs)
    out=zeros(1,length(stationIDs));
    for i=1:length(stationIDs)
        b=getBoxIDForStationID(r,stationIDs{i});
        ind=getStationInds(r,{stationIDs{i}},b);
        out(i)=r.assignments{b}{1}{ind,2};
    end