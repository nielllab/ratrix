function inds=getStationInds(r,stationIDs,boxID)
inds=[];
b=getBoxFromID(r,boxID);

if ~all(ismember(stationIDs,getStationIDsForBoxID(r,boxID)))
    error('not all those stationIDs are in that box')
else
    for i=1:length(stationIDs)
        found(i)=0;
        for j=1:size(r.assignments{boxID}{1},1)
            if strcmp(stationIDs{i},getID(r.assignments{boxID}{1}{j,1}))%changed from sid's being ints and checking w/==
                if found(i)
                    error('found multiple references to station')
                else
                    found(i)=1;
                    inds(i)=j;
                end
            end
        end
    end
    if any(~found)
        error('couldn''t find some of those stations')
    end
end