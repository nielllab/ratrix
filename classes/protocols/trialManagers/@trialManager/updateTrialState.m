function [tm trialDetails result spec rewardSizeULorMS requestRewardSizeULorMS ...
    msPuff msRewardSound msPenalty msPenaltySound floatprecision textures destRect] = ...
    updateTrialState(tm, sm, result, spec, ports, lastPorts, ...
    targetPorts, requestPorts, lastRequestPorts, framesInPhase, trialRecords, window, station, ifi, ...
    floatprecision, textures, destRect, ...
    requestRewardDone)
% This function is a TM base class method to update trial state before every flip.
% Things done here include:
% - check for request rewards

rewardSizeULorMS=0;
requestRewardSizeULorMS=0;
msPuff=0;
msRewardSound=0;
msPenalty=0;
msPenaltySound=0;

if isfield(trialRecords(end),'trialDetails') && isfield(trialRecords(end).trialDetails,'correct')
    correct=trialRecords(end).trialDetails.correct;
else
    correct=[];
end

if ~isempty(result) && ischar(result) && strcmp(result,'timeout') && isempty(correct) && strcmp(getPhaseLabel(spec),'reinforcement')
	correct=0;
	result='nominal';
	trialDetails=[];
	trialDetails.correct=correct;
elseif ~isempty(result) && ischar(result) && strcmp(result,'timeout') && isempty(correct) && strcmp(getPhaseLabel(spec),'itl') 
    % timeout during 'itl' phase - neither correct nor incorrect (only happens when no stim is shown)
    result='nominal';
    trialDetails=[];
else
	trialDetails=[];
end


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


end  % end function