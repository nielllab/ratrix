function r=setStationMACaddress(r,sid,mac)
station=getStationByID(r,sid);
bID=getBoxIDForStationID(r,getID(station));

j=getStationInds(r,{sid},bID);

r.assignments{bID}{1}{j,1}=setMACaddress(station,mac);

saveDB(r,0);