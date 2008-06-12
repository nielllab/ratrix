function s=getStations(r)
s=[];
bIDs=getBoxIDs(r);
for i=1:length(bIDs)
    s=[s getStationsForBoxID(r,bIDs(i))];
end