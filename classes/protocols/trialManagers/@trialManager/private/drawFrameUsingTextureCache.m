function drawFrameUsingTextureCache(tm, window, i, frameNum, stimSize, lastI, dontclear, texture, destRect, filtMode, labelFrames, ...
    xOrigTextPos, yNewTextPos)

% This function draws the given frame using the textureCache strategy.
% Part of stimOGL rewrite.
% INPUT: window, i, frameNum, stimSize, lastI, dontclear, texture, destRect, filtMode, labelFrames, ...
%    xOrigTextPos, yNewTextPos
% OUTPUT: (none)

if window>=0
    if i>0 && i <= stimSize
        if ~(i==lastI) || (dontclear==0) %only draw if texture different from last one, or if every flip is redrawn
            Screen('DrawTexture', window, texture,[],destRect,[],filtMode);
        else
            if labelFrames
                thisMsg=sprintf('This frame stim index (%d) is staying here without drawing new textures %d',i,frameNum);
                Screen('DrawText',window,thisMsg,xOrigTextPos,yNewTextPos-20,100*ones(1,3));
            end
        end
    else
        if stimSize==0
            %'stim had zeros frames, probably an penalty stim with zero duration'
        else
            i
            sprintf('stimSize: %d',stimSize)
            error('request for an unknown frame')
        end
    end
end


end % end function
