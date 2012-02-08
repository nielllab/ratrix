function [tm frameIndex i done doFramePulse didPulse] ...
    = updateFrameIndexUsingTextureCache(tm, frameIndexed, loop, trigger, timeIndexed, frameIndex, indexedFrames,...
    stimSize, isRequesting, ...
    i, frameNum, timedFrames, responseOptions, done, doFramePulse, didPulse, scheduledFrameNum)

% This method calculates the correct frame index (which frame of the movie to play at the given loop)

if frameIndexed
    if loop
        if tm.dropFrames
            frameIndex = mod(scheduledFrameNum,length(indexedFrames));
            if frameIndex==0
                frameIndex=length(indexedFrames);
            end
        else
            % frameIndex = mod(frameIndex,length(indexedFrames)-1)+1; %02.03.09 edf notices this has same problem as loop condition (next). changing to:
            frameIndex = mod(frameIndex,length(indexedFrames))+1;
        end
    else
        if tm.dropFrames
            frameIndex = min(length(indexedFrames),scheduledFrameNum);
        else
            frameIndex = min(length(indexedFrames),frameIndex+1);
        end
    end
    i = indexedFrames(frameIndex);
elseif loop
    if tm.dropFrames
        i = mod(scheduledFrameNum,stimSize);
        if i==0
            i=stimSize;
        end
    else
        % i = mod(i,stimSize-1)+1; %original was incorrect!  never gets to last frame
        
        % 8/16/08 - changed to:
        %     i = mod(i+1,stimSize);
        %     if i == 0
        %         i = stimSize;
        %     end
        
        % 02.03.09 edf changing to:
        i = mod(i,stimSize)+1;
    end
    
elseif trigger
    if isRequesting
        i=1;
    else
        i=2;
    end
    
elseif timeIndexed
    
    %should precache cumsum(double(timedFrames))
    if tm.dropFrames
        i=min(find(scheduledFrameNum<=cumsum(double(timedFrames))));
    else
        i=min(find(frameNum<=cumsum(double(timedFrames))));
    end
    
    if isempty(i)  %if we have passed the last stim frame
        i=length(timedFrames);  %hold the last frame if the last frame duration specified was zero
        if timedFrames(end)
            error('currently broken')
            
            i=i+1;      %otherwise move on to the finalScreenLuminance blank screen -- this will probably error on the phased architecture, need to advance phase, but it's too late by this point?
            % from fan:
            % > i think this would have to be handled by the framesUntilTransition timeout.
            % > it would be up to the user to correctly pass in a framesUntilTransition
            % > argument of 600 frames if they vector of timedFrames sums up to 600 and does
            % > not end in zero. phaseify could automatically handle this, but new calcStims
            % > would have to be aware of this.
            
        end
    end
    
else
    
    if tm.dropFrames
        i=min(scheduledFrameNum,stimSize);
    else
        i=min(i+1,stimSize);
    end
    
    if isempty(responseOptions) && i==stimSize && ~isa(tm,'ball')
        warning('this was killing ball rewards -- what is it for?  doesn''t autoplay work some other way, like using the stim spec transitions?')
        done=1;
    end
    
    if i==stimSize && didPulse
        doFramePulse=0;
    end
    didPulse=1;
end

end % end function