function setValves(s, valves)
if strcmp(s.responseMethod,'parallelPort')
    if length(valves)==s.numPorts
        valves=logical(valves);
        valves(s.valvePins.invs)=~valves(s.valvePins.invs);
        lptWriteBits(s.valvePins.decAddr,s.valvePins.bitLocs,valves);
    else
        error('valves must be a vector of length numValves')
    end
else
    warning('can''t set valves without parallel port')
end