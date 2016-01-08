function lptWriteBits(decAddr,locs,vals)
 
% decAddr = hex2dec('E030'); %for PCI Parrallel ports only?

if false && locs==7 && vals
    sca
end

[pp, ~, ~, ioObj] = getPP;

if pp
    if ~isnan(ioObj)
        try
            codeStr=fastDec2Bin(double(io32(ioObj,decAddr)));
        catch
            codeStr=fastDec2Bin(double(io64(ioObj,decAddr)));
        end
    else
        codeStr=fastDec2Bin(lptread(decAddr));
    end
    
    codeStr(locs)=char('0'*ones(size(vals)) + vals*('1' - '0'));
    
    if ~isnan(ioObj)
        try
            io32(ioObj,decAddr,fastBin2Dec(codeStr));
        catch
             io64(ioObj,decAddr,fastBin2Dec(codeStr));
        end
    else
        lptwrite(decAddr, fastBin2Dec(codeStr));
    end
end