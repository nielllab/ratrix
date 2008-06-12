function out=wdrTooFar(p)

out = p.currentPosition<p.minPosition || lptReadBit(p.wdrTooFarBit{1},p.wdrTooFarBit{2});