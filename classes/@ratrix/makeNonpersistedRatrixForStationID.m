function out=makeNonpersistedRatrixForStationID(r,id)
if isempty(id)
    out=[];
    return
else
out=ratrix();
end
bid=getBoxIDForStationID(r,id);
'this box'
bid
out.boxes={getBoxFromID(r,bid)};
out.creationDate = getCreationDate(r);
out.subjects=getSubjectsForStationID(r,id);
subIDs=getSubjectIDsForStationID(r,id);
if isempty(subIDs)
    out=[];
else
out.assignments{bid}={{getStationByID(r,id),stationIDsRunning(r,{id})}, subIDs};
out.permanentStorePath =r.permanentStorePath;
end
% 
% display(out.boxes)
% display(out.subjects)
% out.assignments
% size(out.assignments)
% out.assignments{bid}
% out.assignments{bid}{1}
% out.assignments{bid}{2}