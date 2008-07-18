function lptWriteBit(parPortAddress,pin,val)
error('deprecated - slow')
bit=getBitSpecForPinNum(pin);
if isBitSpec(bit) && ismember(val,[1 0]) && getDirForPinNum(pin,'write')
    parPortAddress=hex2dec(parPortAddress)+double(bit(2));
    bitNum=bit(1);
    if bit(3)
        val=~val;
    end
else
    parPortAddress
    pin
    val
    error('pin no good (can only write to ports 0 and 2, which is pins 1-9,14,16-17) or val not in [0 1]')
end

%erik's way:
x=dec2bin(lptread(parPortAddress),8);
x(bitNum)=num2str(val);
lptwrite(parPortAddress,bin2dec(x));

%dan's way:
% origBits=lptread(parPortAddress);
% bitNum=double(bitNum);
% switch val
%     case 0
%         % Don't affect other bits AND 111110111111 where 0 is target bit
%         modVal = hex2dec('FF')- bitshift(1,bitNum-1);
%         outputBits = bitand(origBits,modVal);
%         lptwrite(parPortAddress, outputBits);
%     case 1
%         % Don't affect other bits OR 000001000000 where 1 is target bit
%         modVal = bitshift(1,bit-1);
%         outputBits = bitor(origBits,modVal);
%         lptwrite(parPortAddress, outputBits);
%     otherwise
%         error('Can only write 1 or 0 to bit in lptwritebit');
% end