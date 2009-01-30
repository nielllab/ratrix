function [lastI vbl ft missed timestamps] = ...
    flipFrameAndDoPulse(tm, window, dontclear, i, vbl, framesPerUpdate, ifi, paused, doFramePulse,station,timestamps)

timeStamps.enteredFlipFrameAndDoPulse=GetSecs;

%indicate finished (enhances performance)
if window>=0
    Screen('DrawingFinished',window,dontclear);
    lastI=i;
end
timestamps.drawingFinished=GetSecs;

timestamps.when=vbl+(framesPerUpdate-0.8)*ifi; %this 0.8 is critical -- get frame drops if it is 0.2.  mario uses 0.5.  in theory any number 0<x<1 should give identical results.

if ~paused && doFramePulse
    framePulse(station);
    framePulse(station);
end
timestamps.prePulses=GetSecs;

%logwrite('frame calculated, waiting for flip');

%wait for next frame, flip buffer
if window>=0
    [vbl sos ft missed]=Screen('Flip',window,timestamps.when,dontclear); %vbl=vertical blanking time, when flip starts executing
     %http://psychtoolbox.org/wikka.php?wakka=FaqFlipTimestamps
     %vbl=vertical blanking time, when bufferswap occurs (corrected by beampos logic if available/reliable)
     %sos=stimulus onset time -- vbl + a computed constant corresponding to the duration of the vertical blanking (a delay in when, after vbl, that the swap actually happens, depends on a lot of guts)
     %ft=timestamp from the end of flip's execution --  using this for 'apparent misses' is probably wrong since i think this might be significantly later than the swap and more jitter prone than vbl!
else
    waitTime=GetSecs()-timestamps.when;
    if waitTime>0
        WaitSecs(waitTime);
    end
    ft=timestamps.when;
    vbl=ft;
    missed=0;
end

if ~paused
    if doFramePulse
        framePulse(station);
    end
end

timestamps.postFlipPulse=GetSecs;

%logwrite('just flipped');

if ft-vbl>.15*ifi
    %this occurs when my osx laptop runs on battery power
    fprintf('long delay inside flip after the swap-- ft-vbl:%.15g%% of ifi, now-vbl:%.15g\n',(ft-vbl)/ifi,GetSecs-vbl)
end
    
end % end function