function closeAllValves(z)
bits=getValveBits(z);
for i = 1:length(bits)
    setValve(z,bits{i},z.const.valveOff);
end