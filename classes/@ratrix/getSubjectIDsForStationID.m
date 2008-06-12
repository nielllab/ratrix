function out=getSubjectIDsForStationID(r,id)
out={};
subs=getSubjectsForStationID(r,id);
for i=1:length(subs)
    out{i}=getID(subs{i});
end

if isempty(out)
    id
    warning('didn''t find any subjects for that station id')
end