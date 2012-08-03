function lptWriteBits(decAddr,locs,vals)

if false && locs==7 && vals
    sca
    keyboard
end

[pp, ~, ~, ioObj] = getPP;

if pp
    if ~isnan(ioObj)
        codeStr=fastDec2Bin(double(io32(ioObj,decAddr)));
    else
        codeStr=fastDec2Bin(lptread(decAddr));
    end
    
    codeStr(locs)=char('0'*ones(size(vals)) + vals*('1' - '0'));
    
    if ~isnan(ioObj)
        io32(ioObj,decAddr,fastBin2Dec(codeStr));
    else
        lptwrite(decAddr, fastBin2Dec(codeStr));
    end
end