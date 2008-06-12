function r=setStationIDSoundOn(r,sid,val)
    station=getStationByID(r,sid);
    bID=getBoxIDForStationID(getID(station);
    
    j=getStationInds(r,sid,bID);
    
    r.assignments{bID}{1}{j,1}=setSoundOn(station,val);
    
     saveDB(r,0);