function out=getNumPortsForStationID(rx,st)
s=getStationByID(rx,st);
out=getNumPorts(s);