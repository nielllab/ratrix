function lptWriteBits(decAddr,locs,vals)
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
    
    % valves=[6 7 8 1 2];
    % sensors=[4 2 3];
    % closed=char('0'*ones(1,8));
    % t=closed;
    % t(valves(codes(cellfun(@KbName,{'1!' '2@' '3#' '4$' '5%'})) | [out(sensors) 0 0]))='1';
    % io32(ioObj,hex2dec(addr),bin2dec(t));
        
    io32(ioObj,decAddr,fastBin2Dec(codeStr));

    if locs==7 && vals==true && false
        sca
        keyboard
    end
else
    lptwrite(decAddr, fastBin2Dec(codeStr));
end