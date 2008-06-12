function out=makeNonpersistedRatrixForStationMAC(r,m)
if isMACaddress(m)
    out=makeNonpersistedRatrixForStationID(r,getID(getStationByMACaddress(r,m)));
else
    error('need mac address')
end