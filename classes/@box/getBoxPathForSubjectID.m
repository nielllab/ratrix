function subPath=getBoxPathForSubjectID(b,sID,r)
    if isa(r,'ratrix')
        if getBoxIDForSubjectID(r,sID)==getID(b)
            subPath=fullfile(getSujbectDataDir(b),sID);  %[b.path 'subjectData' filesep sID filesep];
        else
            error('subject not in this box')
        end
    else
        error('ratrix does not contain subject')
    end