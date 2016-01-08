function ports=readPorts(s)
[pp, ~, ~, ioObj] = getPP;

if pp && strcmp(s.responseMethod,'parallelPort')
    if isnan(ioObj)
        status=fastDec2Bin(lptread(s.sensorPins.decAddr));
    else
       try
           status=fastDec2Bin(double(io32(ioObj,s.sensorPins.decAddr)));
       catch
           status=fastDec2Bin(double(io64(ioObj,s.sensorPins.decAddr)));
       end
    end
    
    ports=status(s.sensorPins.bitLocs)=='0'; %need to set parity in station, assumes sensors emit +5V for unbroken beams
    ports(s.sensorPins.invs)=~ports(s.sensorPins.invs);
else
    if false && ~ismac
        %s.responseMethod
        warning('can''t read ports without parallel port')
    end
    ports=false(1,s.numPorts);
end