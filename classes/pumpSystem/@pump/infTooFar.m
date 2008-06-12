function out=infTooFar(p)

out = p.currentPosition>p.maxPosition || lptReadBit(p.infTooFarBit{1},p.infTooFarBit{2});