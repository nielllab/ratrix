function [patchX patchY]=getPatchSize(s)

maxHeight=getMaxHeight(s);

patchX=ceil(maxHeight*s.stdGaussMask*s.stdsPerPatch);  %stdGaussMask control patch size which control the radius
patchY=patchX;

if isnan(patchY) % this is what you get when inf*0
    patchY=maxHeight;
    patchX=getMaxWidth(s);
end
    