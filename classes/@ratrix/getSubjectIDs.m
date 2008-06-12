function out=getSubjectIDs(r)
    out={};
    for i=1:length(r.subjects)
        out{i}=getID(r.subjects{i});
    end