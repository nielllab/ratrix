function [lastI when vbl sos ft missed] = flipFrameAndDoPulse(tm, window, dontclear, i, vbl, framesPerUpdate, ifi, paused, doFramePulse,station) 

% This function calls the Screen Flip command and does Frame Pulses as necessary. This is done after the texture is ready to display (cached).
% Part of stimOGL rewrite.
% INPUT: window, dontclear, i , vbl, framesPerUpdate, ifi, paused, doFramePulse, station
% OUTPUT: lastI, when, vbl, sos, ft, missed

%indicate finished (enhances performance)
if window>=0
    Screen('DrawingFinished',window,dontclear);
    lastI=i;
end

when=vbl+(framesPerUpdate-0.5)*ifi;

if ~paused && doFramePulse
    framePulse(station);
    framePulse(station);
end

%logwrite('frame calculated, waiting for flip');

%wait for next frame, flip buffer
if window>=0
    [vbl sos ft missed]=Screen('Flip',window,when,dontclear); %vbl=vertical blanking time, when flip starts executing
    %sos=stimulus onset time -- doc doesn't clarify what this is
    %ft=timestamp from the end of flip's execution
else
    waitTime=GetSecs()-when;
    if waitTime>0
        WaitSecs(waitTime);
    end
    ft=when;
    vbl=ft;
    missed=0;
end

%logwrite('just flipped');

if ~paused
    if doFramePulse
        framePulse(station);
    end
end
    
    
end % end function