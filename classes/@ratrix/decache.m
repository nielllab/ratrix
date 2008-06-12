function r=decache(r)
    for i=1:length(r.subjects)
        r.subjects{i}=decache(r.subjects{i});
    end