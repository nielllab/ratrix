function r=commandAllBoxIDStations(r,cmd,boxID,comment,auth,secsAcknowledgeWait)
    stationIDs=getStationIDsForBoxID(r,boxID);
    r=commandBoxIDStationIDs(r,cmd,boxID,stationIDs,comment,auth,secsAcknowledgeWait);