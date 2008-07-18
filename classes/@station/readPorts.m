function ports=readPorts(s)
if strcmp(s.responseMethod,'parallelPort')
    status=dec2bin(lptread(s.sensorPins.decAddr),8);
    ports=status(s.sensorPins.bitLocs)=='0'; %need to set parity in station 
    ports(s.sensorPins.invs)=~ports(s.sensorPins.invs);
else
    s.responseMethod
    warning('can''t read ports without parallel port')
    ports=zeros(1,s.numPorts);
end