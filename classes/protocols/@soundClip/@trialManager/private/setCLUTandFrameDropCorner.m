function [frameDropCorner currentCLUT] = setCLUTandFrameDropCorner(tm, window, station, LUT, frameDropCorner)

if window>=0
    [scrWidth scrHeight]=Screen('WindowSize', window);
else
    scrWidth=getWidth(station);
    scrHeight=getHeight(station);
end

if window>=0
    scrRect = Screen('Rect', window);
    scrLeft = scrRect(1); %am i retarted?  why isn't [scrLeft scrTop scrRight scrBottom]=Screen('Rect', window); working?  deal doesn't work
    scrTop = scrRect(2);
    scrRight = scrRect(3);
    scrBottom = scrRect(4);
    scrWidth= scrRight-scrLeft;
    scrHeight=scrBottom-scrTop;
else
    scrLeft = 0;
    scrTop = 0;
end

frameDropCorner.left  =scrLeft               + scrWidth *(frameDropCorner.loc(2) - frameDropCorner.size(2)/2);
frameDropCorner.right =frameDropCorner.left  + scrWidth *frameDropCorner.size(2);
frameDropCorner.top   =scrTop                + scrHeight*(frameDropCorner.loc(1) - frameDropCorner.size(1)/2);
frameDropCorner.bottom=frameDropCorner.top   + scrHeight*frameDropCorner.size(1);
frameDropCorner.rect=[frameDropCorner.left frameDropCorner.top frameDropCorner.right frameDropCorner.bottom];

[oldCLUT, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', window);

if isreal(LUT) && all(size(LUT)==[256 3])
    if any(LUT(:)>1) || any(LUT(:)<0)
        error('LUT values must be normalized values between 0 and 1')
    end
    try
        oldCLUT = Screen('LoadNormalizedGammaTable', window, LUT,0); %apparently it's ok to use a window ptr instead of a screen ptr, despite the docs
    catch ex
        %if the above fails, we lose our window
        
        ex.message
        error('couldnt set clut')
    end
    currentCLUT = Screen('ReadNormalizedGammaTable', window);

    if all(all(abs(currentCLUT-LUT)<0.00001))
        %pass
    else
        oldCLUT
        currentCLUT
        LUT             %requested
        currentCLUT-LUT %error
        error('the LUT is not what you think it is')
    end
    
    switch tm.frameDropCorner{1}
        case 'off'
        case 'flickerRamp'
            inds=findClosestInds(tm.frameDropCorner{2},mean(currentCLUT'));
            frameDropCorner.seq=size(currentCLUT,1):-1:inds(1);
            frameDropCorner.seq(2,:)=inds(2);
            frameDropCorner.seq=frameDropCorner.seq(:); %interleave them
        case 'sequence'
            frameDropCorner.seq=findClosestInds(tm.frameDropCorner{2},mean(currentCLUT'));
        otherwise
            error('shouldn''t happen')
    end
else
    reallutsize
    error('LUT must be real 256 X 3 matrix')
end

end % end function