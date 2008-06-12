function out = testBoxSubjectDirs(r,box)
if isa(box,'box')
    subIDs=getSubjectIDsForBoxID(r,getID(box));
    success=1;
    for i=1:length(subIDs)
        sub=getSubjectFromID(r,subIDs(i));
        success = success && testBoxSubjectDir(box,sub);
    end
    out=success;
else
    error('need a box object')
end