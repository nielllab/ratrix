function [patchX patchY]=getPatchSize(s)

maxHeight=getMaxHeight(s);
patchX=ceil(maxHeight*s.stdGaussMask*s.stdsPerPatch);  %stdGaussMask control patch size which control the radius
patchY=patchX;