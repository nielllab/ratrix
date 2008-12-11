function s=getSubjectsFromIDs(r,ids)
s=[];
if ischar(ids)
     s=getSubjectFromID(r,ids);
elseif iscell(ids)
    ids={ids{:}};
    for i=1:length(ids)
        s{end+1}=getSubjectFromID(r,ids{i});
    end
end