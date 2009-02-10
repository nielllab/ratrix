function [scrWidth scrHeight scaleFactor height width scrRect scrLeft scrTop scrRight scrBottom destRect currentCLUT frameDropCorner] ...
    = determineScreenParametersAndLUT(tm, window, station, metaPixelSize, stim, LUT, verbose, strategy, frameDropCorner)
% This function determines the scaleFactor and LUT of the Screen window.
% Part of stimOGL rewrite.
% INPUT: window, station, metaPixelSize, stim, LUT, verbose, strategy, frameDropCorner
% OUTPUT: scrWidth, scrHeight, scaleFactor, height, width, scrRect, scrLeft, scrTop, scrRight, scrBottom, destRect, currentCLUT, frameDropCorner

if window>=0
    [scrWidth scrHeight]=Screen('WindowSize', window);
else
    scrWidth=getWidth(station);
    scrHeight=getHeight(station);
end

% 10/31/08 - implement handling of expert mode (if expert, height and width should be fields of stim)
if ~isempty(strategy) && strcmp(strategy, 'expert')
    height = stim.height;
    width = stim.width;
    scaleFactor = metaPixelSize; % unused in this case (height and width are already set)
else % non dynamic mode - calculate based on size of stim
    if metaPixelSize == 0
        scaleFactor = [scrHeight scrWidth]./[size(stim,1) size(stim,2)];
    elseif length(metaPixelSize)==2 && all(metaPixelSize)>0
        scaleFactor = metaPixelSize;
    else
        error('bad metaPixelSize argument')
    end
    if any(scaleFactor.*[size(stim,1) size(stim,2)]>[scrHeight scrWidth])
        scaleFactor.*[size(stim,1) size(stim,2)]
        scaleFactor
        size(stim)
        [scrHeight scrWidth]
        error('metaPixelSize argument too big')
    end


    height = scaleFactor(1)*size(stim,1);
    width = scaleFactor(2)*size(stim,2);
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
    scrRight = scrWidth;
    scrBottom = scrHeight;
end

destRect = round([(scrWidth/2)-(width/2) (scrHeight/2)-(height/2) (scrWidth/2)+(width/2) (scrHeight/2)+(height/2)]); %[left top right bottom]

frameDropCorner.left  =scrLeft               + scrWidth *(frameDropCorner.loc(2) - frameDropCorner.size(2)/2);
frameDropCorner.right =frameDropCorner.left  + scrWidth *frameDropCorner.size(2);
frameDropCorner.top   =scrTop                + scrHeight*(frameDropCorner.loc(1) - frameDropCorner.size(1)/2);
frameDropCorner.bottom=frameDropCorner.top   + scrHeight*frameDropCorner.size(1);
frameDropCorner.rect=[frameDropCorner.left frameDropCorner.top frameDropCorner.right frameDropCorner.bottom];

% destRect
% height
% width
% scrRight
% scrLeft
% scrBottom
% scrTop
% scaleFactor
% error('stop')


[oldCLUT, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', window);

%LOAD COLOR LOOK UP TABLE (if it is the right size)
if isreal(LUT) && all(size(LUT)==[256 3])
    if any(LUT(:)>1) || any(LUT(:)<0)
        error('LUT values must be normalized values between 0 and 1')
    end
    try
        oldCLUT = Screen('LoadNormalizedGammaTable', window, LUT,0); %apparently it's ok to use a window ptr instead of a screen ptr, despite the docs
    catch 
        e=lasterror;
        %if the above fails, we lose our window :(
        %window=Screen('OpenWindow',max(Screen('Screens')));
        e.message
        %warning('failed to load clut and had to reopen the window, everything is probably screwed')
        error('couldnt set clut')
    end
    currentCLUT = Screen('ReadNormalizedGammaTable', window);
    %test clut values
    if all(all(currentCLUT-LUT<0.00001))
        if verbose
            disp('LUT is LOADED')
            disp('clut is more or less what you want it to be')
        end
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

maxV=max(currentCLUT(:));
minV=min(currentCLUT(:));

if verbose && (minV ~= 0 || maxV ~= 1)
    disp(sprintf('clut has a min of %4.6f and a max of %4.6f',minV,maxV));
end

end % end function