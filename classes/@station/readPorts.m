function ports=readPorts(s)
if strcmp(s.responseMethod,'parallelPort')
    status=fastDec2Bin(lptread(s.sensorPins.decAddr));
    ports=status(s.sensorPins.bitLocs)=='0'; %need to set parity in station, assumes sensors emit +5V for unbroken beams
    ports(s.sensorPins.invs)=~ports(s.sensorPins.invs);
else
    s.responseMethod
    warning('can''t read ports without parallel port')
    ports=zeros(1,s.numPorts);
end