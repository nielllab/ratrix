function [tm trialDetails result spec rewardSizeULorMS requestRewardSizeULorMS ...
    msPuff msRewardSound msPenalty msPenaltySound floatprecision textures destRect] = ...
    updateTrialState(tm, sm, result, spec, ports, lastPorts, ...
    targetPorts, requestPorts, lastRequestPorts, framesInPhase, trialRecords, window, station, ifi, ...
    floatprecision, textures, destRect, ...
    requestRewardDone, punishResponses)
% autopilot updateTrialState does nothing!

rewardSizeULorMS=0;
requestRewardSizeULorMS=0;
msPuff=0;
msRewardSound=0;
msPenalty=0;
msPenaltySound=0;

trialDetails=[];
if strcmp(getPhaseLabel(spec),'intertrial luminance') && ischar(result) && strcmp(result,'timeout')
    % this should be the only allowable result in autopilot
    result='timedout'; % so we continue to next trial
end
end  % end function