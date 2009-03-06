function [tm trialDetails result spec rewardSizeULorMS requestRewardSizeULorMS ...
    msPuff msRewardSound msPenalty msPenaltySound floatprecision textures destRect checkCorrect] = ...
    updateTrialState(tm, sm, result, spec, ports, lastPorts, ...
    targetPorts, requestPorts, lastRequestPorts, framesInPhase, trialRecords, window, station, ifi, ...
    floatprecision, textures, destRect, ...
    requestRewardDone, checkCorrect)
% This function is a tm-specific method to update trial state before every flip.
% Things done here include:
%   - set trialRecords.correct and trialRecords.result as necessary
%   - call RM's calcReinforcement as necessary
%   - update the stimSpec as necessary (with correctStim() and errorStim())
%   - update the TM's RM if neceesary

rewardSizeULorMS=0;
requestRewardSizeULorMS=0;
msPuff=0;
msRewardSound=0;
msPenalty=0;
msPenaltySound=0;
checkCorrect=false;

if (any(ports(requestPorts)) && ~any(lastPorts(requestPorts))) && ... % if a request port is triggered
        ((strcmp(getRequestMode(getReinforcementManager(tm)),'nonrepeats') && ~any(ports&lastRequestPorts)) || ... % if non-repeat
        strcmp(getRequestMode(getReinforcementManager(tm)),'all') || ...  % all requests
        ~requestRewardDone) % first request

    [rm garbage requestRewardSizeULorMS garbage garbage garbage garbage updateRM] =...
        calcReinforcement(getReinforcementManager(tm),trialRecords, []);
    if updateRM
        tm=setReinforcementManager(tm,rm);
    end
end

trialDetails=[];
end  % end function