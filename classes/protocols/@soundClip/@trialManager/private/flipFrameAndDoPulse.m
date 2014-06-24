function [timestamps headroom] = flipFrameAndDoPulse(tm, window, dontclear, framesPerUpdate, ifi, paused, doFramePulse,station,timestamps)

timeStamps.enteredFlipFrameAndDoPulse=GetSecs;

if window>=0
    Screen('DrawingFinished',window,dontclear); % supposed to enhance performance
    % this usually returns fast but on asus mobos sometimes takes up to 2ms.
    % it is not strictly necessary and there have been some hints
    % that it actually hurts performance -- mario usually does not (but
    % sometimes does) include it in demos, and has mentioned to be suspect of
    % it.  it's almost certainly very sensitive to driver version.  
    % we may want to consider testing effects of removing it or giving user control over it.
end
timestamps.drawingFinished=GetSecs;

timestamps.when=timestamps.vbl+(framesPerUpdate-0.8)*ifi; %this 0.8 is critical -- get frame drops if it is 0.2.  mario uses 0.5.  in theory any number 0<x<1 should give identical results.
%                                                         %discussion at http://tech.groups.yahoo.com/group/psychtoolbox/message/9165

if doFramePulse && ~paused
        setStatePins(station,'frame',true);
end

timestamps.prePulses=GetSecs;
headroom=(timestamps.vbl+(framesPerUpdate)*ifi)-timestamps.prePulses;

if window>=0
    [timestamps.vbl sos timestamps.ft timestamps.missed]=Screen('Flip',window,timestamps.when,dontclear);
    %http://psychtoolbox.org/wikka.php?wakka=FaqFlipTimestamps
    %vbl=vertical blanking time, when bufferswap occurs (corrected by beampos logic if available/reliable)
    %sos=stimulus onset time -- vbl + a computed constant corresponding to the duration of the vertical blanking (a delay in when, after vbl, that the swap actually happens, depends on a lot of guts)
    %ft=timestamp from the end of flip's execution
else
    waitTime=GetSecs()-timestamps.when;
    if waitTime>0
        WaitSecs(waitTime);
    end
    timestamps.ft=timestamps.when;
    timestamps.vbl=ft;
    timestamps.missed=0;
end

if doFramePulse && ~paused
        setStatePins(station,'frame',false);
end

timestamps.postFlipPulse=GetSecs;

if timestamps.ft-timestamps.vbl>.15*ifi
    %this occurs when my osx laptop runs on battery power
    fprintf('long delay inside flip after the swap-- ft-vbl:%.15g%% of ifi, now-vbl:%.15g\n',(timestamps.ft-timestamps.vbl)/ifi,GetSecs-timestamps.vbl)
    fprintf('1')
end

end % end function