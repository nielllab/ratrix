function lptwritebit(parPortAddress,bit,val)
  origBits = lptread(parPortAddress);
  if bit > 8 || bit < 1
    error('Only first 5 bits are writeable');
  end
  switch val
   case 0
    % Don't affect other bits AND 111110111111 where 0 is target bit
    modVal = hex2dec('FF')- bitshift(1,bit-1);
    outputBits = bitand(origBits,modVal);
    lptwrite(parPortAddress, outputBits);
   case 1
    % Don't affect other bits OR 000001000000 where 1 is target bit
    modVal = bitshift(1,bit-1);
    outputBits = bitor(origBits,modVal);
    lptwrite(parPortAddress, outputBits);
   otherwise
    error('Can only write 1 or 0 to bit in lptwritebit');
  end
  
end