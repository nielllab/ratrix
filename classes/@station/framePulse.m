function framePulse(s)
if strcmp(s.responseMethod,'parallelPort')
    if ~isempty(s.framePulseCodes)
        %codeStr='00000000';
        codeStr=dec2bin(lptread(hex2dec(s.parallelPortAddress)),8);

        codeStr(s.framePulseCodes)='1';
        lptwrite(hex2dec(s.parallelPortAddress), bin2dec(codeStr));
        codeStr(s.framePulseCodes)='0';
        lptwrite(hex2dec(s.parallelPortAddress), bin2dec(codeStr));

    end
end;
