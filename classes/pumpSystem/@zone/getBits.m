function out=getBits(z)
out=getValveBits(z);
out{end+1}=getSensorBit(z);