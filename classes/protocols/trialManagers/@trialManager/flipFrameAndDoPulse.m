function [lastI when vbl sos ft missed time6 time7 whenTime] = ...
    flipFrameAndDoPulse(tm, window, dontclear, i, vbl, framesPerUpdate, ifi, paused, doFramePulse,station) 

% This function calls the Screen Flip command and does Frame Pulses as necessary. This is done after the texture is ready to display (cached).
% Part of stimOGL rewrite.
% INPUT: window, dontclear, i , vbl, framesPerUpdate, ifi, paused, doFramePulse, station
% OUTPUT: lastI, when, vbl, sos, ft, missed

%indicate finished (enhances performance)
if window>=0
    Screen('DrawingFinished',window,dontclear);
    lastI=i;
end

time6=GetSecs;
when=vbl+(framesPerUpdate-0.8)*ifi;
whenTime=GetSecs;

if ~paused && doFramePulse
    framePulse(station);
    framePulse(station);
end
time7=GetSecs;

%logwrite('frame calculated, waiting for flip');

%wait for next frame, flip buffer
if window>=0
    [vbl sos ft missed]=Screen('Flip',window,when,dontclear); %vbl=vertical blanking time, when flip starts executing
     %http://psychtoolbox.org/wikka.php?wakka=FaqFlipTimestamps
     %vbl=vertical blanking time, when bufferswap occurs (corrected by beampos logic if available/reliable)
     %sos=stimulus onset time -- vbl + a computed constant corresponding to the duration of the vertical blanking (a delay in when, after vbl, that the swap actually happens, depends on a lot of guts)
     %ft=timestamp from the end of flip's execution --  using this for 'apparent misses' is probably wrong since i think this might be significantly later than the swap and more jitter prone than vbl!
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

if ft-vbl>.3*ifi
    %this occurs when my osx laptop runs on battery power
    fprintf('long delay inside flip after the swap-- ft-vbl:%.15g%% of ifi, now-vbl:%.15g\n',(ft-vbl)/ifi,GetSecs-vbl)
end

if ~paused
    if doFramePulse
        framePulse(station);
    end
end
    
    
end % end function