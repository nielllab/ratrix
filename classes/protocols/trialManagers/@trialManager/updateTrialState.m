function [tm trialDetails result spec rewardSizeULorMS requestRewardSizeULorMS ...
    msPuff msRewardSound msPenalty msPenaltySound floatprecision textures destRect] = ...
    updateTrialState(tm, sm, result, spec, ports, lastPorts, ...
    targetPorts, requestPorts, lastRequestPorts, framesInPhase, trialRecords, window, station, ifi, ...
    floatprecision, textures, destRect, ...
    requestRewardDone, punishResponses, request)
if ~exist('request','var') || isempty(request)
    request = false;
end
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

trialDetails=[];
if ~isempty(result) && ischar(result) && strcmp(result,'timeout') && isempty(correct)
    if ismember(getPhaseLabel(spec),{'reinforcement','itl'})
        % timeout during 'itl' phase - neither correct nor incorrect (only happens when no stim is shown)
        result='timedout';
        
        if strcmp(getPhaseLabel(spec),'reinforcement')
            trialDetails.correct=0;
        end
    end
end

if (request || (any(ports(requestPorts)) && ~any(lastPorts(requestPorts)))) && ... % request port triggered
        ((strcmp(getRequestMode(getReinforcementManager(tm)),'nonrepeats') && ~any(ports&lastRequestPorts)) || ... % non-repeat
        strcmp(getRequestMode(getReinforcementManager(tm)),'all') || ...  % all requests
        ~requestRewardDone) % first request
    
    [rm, ~, requestRewardSizeULorMS, ~, ~, ~, ~, updateRM] =...
        calcReinforcement(getReinforcementManager(tm),trialRecords, trialRecords(end).subjectsInBox); %subject hack
    if updateRM
        tm=setReinforcementManager(tm,rm);
    end
end

end