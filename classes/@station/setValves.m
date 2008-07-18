function setValves(s, valves)
if strcmp(s.responseMethod,'parallelPort')
    
    codeStr=dec2bin(lptread(s.valvePins.decAddr),8); 

    if length(valves)==s.numPorts
        valves=logical(valves);
        valves(s.valvePins.invs)=~valves(s.valvePins.invs);

        codeStr(s.valvePins.bitLocs)=char('0'*ones(size(valves)) + valves*['1' - '0']);

        lptwrite(s.valvePins.decAddr, fastBin2Dec(codeStr));
    else
        error('valves must be a vector of length numValves')
    end
else
    warning('can''t set valves without parallel port')
end