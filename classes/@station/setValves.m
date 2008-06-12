function setValves(s, valves)
if strcmp(s.responseMethod,'parallelPort')
    %codeStr='00000000';
    codeStr=dec2bin(lptread(hex2dec(s.parallelPortAddress)),8); 

    if length(valves)==s.numPorts

        codeStr(s.valveOpenCodes)=char('0'*ones(size(valves)) + valves*['1' - '0']);
        lptwrite(hex2dec(s.parallelPortAddress), bin2dec(codeStr));
    else
        error('valves must be a vector of length numValves')
    end
else
    warning('can''t set valves without parallel port')
end