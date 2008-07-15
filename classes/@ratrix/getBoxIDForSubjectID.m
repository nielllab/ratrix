function out=getBoxIDForSubjectID(r,s)
out = 0;
[member index]=ismember(s,getSubjectIDs(r));

if index>0
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
    if ~foundSubj || isempty(out)
        disp(s)     
        warning('no box for given subject')
    end
else
    error('no such subject id')
end