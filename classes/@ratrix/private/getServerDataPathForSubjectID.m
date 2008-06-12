function subPath=getServerDataPathForSubjectID(r,sID)
    if isa(getSubjectFromID(r,sID),'subject')
        subPath=fullfile(getSubjectDataPath(r), sID); %[r.serverDataPath 'subjectData' filesep sID filesep];
    else
        error('subject not in ratrix')
    end