function lptWriteBits(decAddr,locs,vals)
 codeStr=fastDec2Bin(lptread(decAddr),8); 
 codeStr(locs)=char('0'*ones(size(vals)) + vals*['1' - '0']);
 lptwrite(decAddr, fastBin2Dec(codeStr));