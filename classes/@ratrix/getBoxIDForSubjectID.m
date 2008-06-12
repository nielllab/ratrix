function out=getBoxIDForSubjectID(r,s)

[member index]=ismember(s,getSubjectIDs(r));

if index>0
    out=0;
    foundSubj=0;
    boxIDs=getBoxIDs(r);
    for i=1:length(boxIDs)
        for j=1:length(r.assignments{boxIDs(i)}{2})
            if strcmp(r.assignments{boxIDs(i)}{2}{j},s)
                if foundSubj
                    error('found subject in more than one box')
                else
                    foundSubj=1;
                    out=boxIDs(i);
                end
            end
        end
    end
else
    error('no such subject id')
end