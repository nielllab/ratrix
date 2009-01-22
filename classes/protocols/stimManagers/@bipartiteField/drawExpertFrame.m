function [doFramePulse expertCache dynamicDetails textLabel] = ...
    drawExpertFrame(stimulus,stim,i,phaseStartTime,window,textLabel,floatprecision,destRect,filtMode,expertCache)
% 11/7/08 - implementing expert mode for bipartiteField 
% this function calculates an expert frame, and then makes and draws the texture; nothing needs to be done in runRealTimeLoop
% this should be a stimManager-specific implementation (if expert mode is supported for the given stimulus)

% stimulus = stimManager
doFramePulse=true;
dynamicDetails=[];
% ================================================================================
% start calculating frames now

% get parameters from stim
% only need stim.numLeftPixels and stim.numRightPixels

% expertFrame = zeros(height,width,1);

% 11/7/08 - this causes an enormous number of frame drops (>1 per actual frame) - find a better way
% % left side
% expertFrame(:,1:floor(partition(1)*width),1) = stim.frames(1,i);
% % right side
% expertFrame(:,ceil(partition(1)*width):end,1) = stim.frames(2,i);

% expertFrame = ones(height,floor(partition(1)*width))*stim.frames(1,i); % left side
% expertFrame = [expertFrame ones(height,width-ceil(partition(1)*width))*stim.frames(2,i)]; % right side

% % method 2
% % try drawing only 1xWidth pixels (since same vertically)
% expertFrame = ones(1,width);
% expertFrame(1,1:floor(partition(1)*width)) = stim.frames(1,i);
% expertFrame(1,ceil(partition(1)*width):end,1) = stim.frames(2,i);

% method 3
% same as method 2, but also reduce size horizontally by trying to find gcd of the two sides
expertFrame = ones(1,stim.numLeftPixels+stim.numRightPixels);
expertFrame(1,1:stim.numLeftPixels) = stim.frames(1,i);
expertFrame(1,stim.numLeftPixels+1:end) = stim.frames(2,i);


% 11/14/08 - moved the make and draw to stimManager specific getexpertFrame b/c they might draw differently
dynTex = Screen('MakeTexture', window, expertFrame,0,0,floatprecision);
Screen('DrawTexture', window, dynTex,[],destRect,[],filtMode);

end % end function