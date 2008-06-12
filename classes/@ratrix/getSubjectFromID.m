function s=getSubjectFromID(r,id)
    [member index]=ismember(id,getSubjectIDs(r));
    if index>0
        s=r.subjects{index};
    else
        error('request for subject id not contained in ratrix')
    end