function sm=setScaleFactor(sm,sf)
if isvector(sf) && isreal(sf) && all(isfinite(sf)) && ((length(sf)==2 && all(sf>0)) || (length(sf)==1 && sf==0))
    sm.scaleFactor=sf;
else
    error('scale factor is finite real, either 0 (for scaling to full screen) or [width height] positive values')
end
end