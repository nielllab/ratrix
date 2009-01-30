function [tm responseDetails] = closeRealTimeLoop(tm, responseDetails, station, frameNum, startTime, valveErrorDetails, window, texture, ...
  destRect, filtMode, dontclear, vbl, framesPerUpdate, ifi, originalPriority)
error('no one calls this')
% This function cleans up after the realtime loop is finished running - draws the final texture and then clears cache.
% Part of stimOGL rewrite.
% INPUT: tm, responseDetails, station, frameNum, startTime, valveErrorDetails, window, texture,
%   destRect, filtMode, dontclear, vbl, framesPerUpdate, ifi, originalPriority
% OUTPUT: tm, responseDetails


currentValveState=verifyValvesClosed(station);

audioStimPlaying=false;
tm.soundMgr = playLoop(tm.soundMgr,'',station,0);

responseDetails.totalFrames=frameNum;
responseDetails.startTime=startTime;
responseDetails.valveErrorDetails=valveErrorDetails;

if window>=0
    Screen('DrawTexture', window, texture,[],destRect,[],filtMode); %change this for new stim architecture
    Screen('DrawingFinished',window,dontclear);
    when=vbl+(framesPerUpdate-0.5)*ifi;
    [vbl sos ft missed]=Screen('Flip',window,when,dontclear);
    Screen('Close'); %leaving off second argument closes all textures but leaves windows open
end

if hasAirpuff(station)
    setPuff(station,false);
end

Priority(originalPriority);
ListenChar(0);

end % end function