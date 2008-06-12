function out=motorRunning(p)
out = lptReadBit(p.motorRunningBit{1},p.motorRunningBit{2})==p.const.motorRunning;