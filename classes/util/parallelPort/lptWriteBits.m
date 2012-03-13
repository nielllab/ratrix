function lptWriteBits(decAddr,locs,vals)

if false && locs==7 && vals
    sca
    keyboard
end

b64 = true;

persistent ioObj; %declared outside of if block because warned it is inefficient otherwise
if b64 %temporary hack to get 2p station running
    if isempty(ioObj)
        ioObj = io32;
        status = io32(ioObj);
        if status~=0
            status
            error('driver installation not successful')
        end
    end
    
    codeStr=fastDec2Bin(double(io32(ioObj,decAddr)));
else
    codeStr=fastDec2Bin(lptread(decAddr));
end

codeStr(locs)=char('0'*ones(size(vals)) + vals*('1' - '0'));

if b64 %temporary hack to get 2p station running
    io32(ioObj,decAddr,fastBin2Dec(codeStr));
else
    lptwrite(decAddr, fastBin2Dec(codeStr));
end