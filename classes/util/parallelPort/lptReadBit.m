function out=lptReadBit(parPortAddress,pin)
error('deprecated - slow')
bit=getBitSpecForPinNum(pin);
if isBitSpec(bit)
    %bit
    if bit(2)==2
        lptWriteBit(parPortAddress,pin,1); %on control port (port 2), must put pin hi (high impedance state) to read
    end
    parPortAddress=hex2dec(parPortAddress)+double(bit(2));
    bitNum=bit(1);
else
    error('pin no good')
end

x=dec2bin(lptread(parPortAddress),8);
out=str2num(x(bitNum));

if bit(3)
    out=~out;
end