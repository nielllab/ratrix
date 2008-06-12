function subs=getSubjectsForStationID(r,sID)
    
    bID=getBoxIDForStationID(r,sID);
    subIDs=getSubjectIDsForBoxID(r,bID);
    subs={};
    for i=1:length(subIDs)
        subs{i}=getSubjectFromID(r,subIDs{i});
    end