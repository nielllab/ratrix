function [tm frameIndex i audioStimPlaying done doFramePulse didPulse] = updateFrameIndexUsingTextureCache(tm, ...
    frameIndexed, loop, trigger, timeIndexed, frameIndex, indexedFrames, stimSize, isRequesting, audioStimPlaying, audioStim, ...
    station, i, requestFrame, frameNum, timedFrames, responseOptions, done, doFramePulse, didPulse)

% This function calculates the correct frame index (which frame of the movie to play at the given loop) and also triggers sound as necessary
% Part of stimOGL rewrite.
% INPUT: tm, frameIndexed, loop, trigger, timeIndexed, frameIndex, indexedFrames, stimSize, isRequesting, audioStimPlaying, audioStim,
%   station, i, requestFrame, frameNum, timedFrames, responseOptions, done, doFramePulse, didPulse
% OUTPUT: tm frameIndex i audioStimPlaying done doFramePulse didPulse

if frameIndexed
    if loop
        frameIndex = mod(frameIndex,length(indexedFrames)-1)+1;
    else
        frameIndex = min(length(indexedFrames),frameIndex+1);
    end
    i = indexedFrames(frameIndex);
elseif loop
%     i = mod(i,stimSize-1)+1; %this is not correct if stimSize is number of frames and i is the index
    % 8/16/08 - changed to index correctly
%     i
    i = mod(i+1,stimSize);
    if i == 0
        i = stimSize;
    end
    % end changed version 8/16/08
%     stimSize
%     i

elseif trigger
    if isRequesting
        if ~audioStimPlaying && ~isempty(audioStim)
            % Play audio
            tm.soundMgr = playLoop(tm.soundMgr,audioStim,station,1);
            audioStimPlaying = true;
        end
        i=1;
    else
        if audioStimPlaying
            % Turn off audio
            tm.soundMgr = playLoop(tm.soundMgr,'',station,0);
            audioStimPlaying = false;
        end
        i=2;
    end

elseif timeIndexed %ok, this is where we do the timedFrames type

    %Function 'cumsum' is not defined for values of class 'int8'.
    if requestFrame~=0
        i=min(find((frameNum-requestFrame)<=cumsum(double(timedFrames))));  %find the stim frame number for the number of frames since the request
    end

    if isempty(i)  %if we have passed the last stim frame
        i=length(timedFrames);  %hold the last frame if the last frame duration specified was zero
        if timedFrames(end)
            i=i+1;      %otherwise move on to the finalScreenLuminance blank screen
        end
    end

else

    i=min(i+1,stimSize);

    if isempty(responseOptions) && i==stimSize
        done=1;
    end

    if i==stimSize && didPulse
        doFramePulse=0;
    end
    didPulse=1;
end


end % end function