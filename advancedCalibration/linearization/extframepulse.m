function extframepulse(val,parallelPortAddress,framePulseCode)
if islogical(val)
    codeStr=dec2bin(lptread(hex2dec(parallelPortAddress)),8);
    if val
        codeStr(framePulseCode)='1';
    else
        codeStr(framePulseCode)='0';
    end
    lptwrite(hex2dec(parallelPortAddress), bin2dec(codeStr));
else
    error('val must be logical')
end