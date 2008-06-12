function out=getZoneForStationMAC(r,m)
out=[];
s=getStationByMACaddress(r,m);
if ~isempty(s)
out=getPhysicalLocation(s);
out=out(2);
end