function [loop trigger frameIndexed timeIndexed indexedFrames timedFrames strategy toggleStim] = determineStrategy(tm, stim, type, responseOptions, framesUntilTransition)

if length(size(stim))>3
    error('stim must be 2 or 3 dims')
end

loop=0;
trigger=0;
frameIndexed=0; % Whether the stim is indexed with a list of frames
timeIndexed=0; % Whether the stim is timed with a list of frames
indexedFrames = []; % List of indices referencing the frames
timedFrames = [];
toggleStim=true; % default, overriden by {'trigger',toggleStim}

if iscell(type)
    if length(type)~=2
        error('Stim type of cell should be of length 2')
    end
    switch type{1}
        case 'indexedFrames'
            frameIndexed = 1;
            loop=1;
            trigger=0;
            indexedFrames = type{2};
            if isNearInteger(indexedFrames) && isvector(indexedFrames) && all(indexedFrames>0) && all(indexedFrames<=size(stim,3))
                strategy = 'textureCache';
            else
                class(indexedFrames)
                size(indexedFrames)
                indexedFrames
                size(stim,3)
                error('bad vector for indexedFrames type: must be a vector of integer indices into the stim frames (btw 1 and stim dim 3)')
            end
        case 'timedFrames'
            timeIndexed = 1;
            timedFrames = type{2};
            if isinteger(timedFrames) && isvector(timedFrames) && size(stim,3)==length(timedFrames) && all(timedFrames(1:end-1)>=1) && timedFrames(end)>=0
                strategy = 'textureCache';
                %dontclear = 1;  %might save time, but breaks on lame graphics cards (such as integrated gfx on asus mobos?)
            else
                error('bad vector for timedFrames type: must be a vector of length equal to stim dim 3 of integers > 0 (number or refreshes to display each frame). A zero in the final entry means hold display of last frame.')
            end
        case 'trigger'   %2 static frames -- if request, show frame 1; else show frame 2
            strategy = 'textureCache';
            loop = 0;
            trigger = 1;
            toggleStim=type{2};
            if size(stim,3)~=2
                error('trigger type must have stim with exactly 2 frames')
            end
        otherwise
            error('Unsupported stim type using a cell, either indexedFrames or timedFrames')
    end
else
    switch type
        case 'static'   %static 1-frame stimulus
            strategy = 'textureCache';
            if size(stim,3)~=1
                error('static type must have stim with exactly 1 frame')
            end
        case 'cache'    %dynamic n-frame stimulus (play once)
            strategy = 'textureCache';
        case 'loop'     %dynamic n-frame stimulus (loop)
            strategy = 'textureCache';
            loop = 1;
        case 'dynamic'
            strategy='dynamic';
        case 'expert' %callback stimManager.drawExpertFrame() to call ptb drawing methods, but leave frame labels, framedrop corner, and 'drawingfinished' to stimOGL
            strategy='expert';
        otherwise
            error('unrecognized stim type, must be ''static'', ''cache'', ''loop'', ''dynamic'', ''expert'', {''indexedFrames'' [frameIndices]}, or {''timedFrames'' [frameTimes]}')
    end
end

if isempty(responseOptions) && isempty(framesUntilTransition) && (trigger || loop || (timeIndexed && timedFrames(end)==0) || frameIndexed)
    trigger
    loop
    timeIndexed
    frameIndexed
    error('can''t loop with no response ports -- would have no way out')
end

if strcmp(strategy,'textureCache') % texture precaching causes dropped frames (~1 per 45mins @ 100Hz)
    strategy = 'noCache';
end

end