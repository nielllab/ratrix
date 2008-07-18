function valves =getValves(s)
if strcmp(s.responseMethod,'parallelPort')

    status=dec2bin(lptread(s.valvePins.decAddr),8);

    valves=status(s.valvePins.bitLocs)=='1'; %need to set parity in station, assumes normally closed valves
    valves(s.valvePins.invs)=~valves(s.valvePins.invs);
else
    warning('can''t read ports without parallel port')
    valves=zeros*s.valvePins.bitLocs;
end