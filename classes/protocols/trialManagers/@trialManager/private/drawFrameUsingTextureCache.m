function drawFrameUsingTextureCache(tm, window, i, frameNum, stimSize, lastI, dontclear, texture, destRect, filtMode, labelFrames, ...
    xOrigTextPos, yNewTextPos, strategy,floatprecision)

if window>=0
    if (i>0 && i <= stimSize) || strcmp(strategy,'dynamic')
        if i~=lastI || dontclear~=1 || strcmp(strategy,'dynamic') %only draw if texture different from last one, or if every flip is redrawn
            %edf worries: does that i comparisson realize these might be from two different stimSpecs/phases?
            
            loc = strcmp(strategy,'dynamic') || strcmp(strategy,'noCache');
            if loc % any(ismember(strategy,{'noCache','dynamic'})) %this ismember is slow
                texture=Screen('MakeTexture', window, texture,0,0,floatprecision); %need floatprecision=0 for remotedesktop
            end
            Screen('DrawTexture', window, texture,[],destRect,[],filtMode);
            if loc % any(ismember(strategy,{'noCache','dynamic'})) %this ismember is slow
                Screen('Close',texture);
            end
        else
            if labelFrames
                thisMsg=sprintf('This frame stim index (%d) is staying here without drawing new textures %d',i,frameNum);
                Screen('DrawText',window,thisMsg,xOrigTextPos,yNewTextPos-20,100*ones(1,3));
            end
        end
    else
        if stimSize==0
            %probably a penalty stim with zero duration
        else
            i
            sprintf('stimSize: %d',stimSize)
            error('request for an unknown frame')
        end
    end
end


end % end function