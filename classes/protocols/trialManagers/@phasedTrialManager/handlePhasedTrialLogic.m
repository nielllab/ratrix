function [tm responseDetails done newSpecInd specInd updatePhase transitionedByTimeFlag transitionedByPortFlag stepsInPhase response trialResponse...
    isRequesting] = ... 
    handlePhasedTrialLogic(tm, responseDetails, done, ...
    ports, station, specInd, updatePhase, transitionCriterion, framesUntilTransition, stepsInPhase, isFinalPhase, response, trialResponse, ...
    soundTypesInPhase, targetOptions, distractorOptions, requestOptions, isRequesting)

% This function handles trial logic for a phased trial manager.
% Part of stimOGL rewrite.
% INPUT: tm, responseDetails, done, ports, station, specInd, updatePhase, transitionCriterion, framesUntilTransition, stepsInPhase,
%   isFinalPhase, response, soundTypesInPhase, targetOptions, distractorOptions, requestOptions, correct, isRequesting
% OUTPUT: tm, responseDetails, done, newSpecInd, specInd, updatePhase, transitionedByTimeFlag, transitionedByPortFlag, 
%   stepsInPhase, response, correct, isRequesting


newSpecInd = specInd;
transitionedByTimeFlag = false;
transitionedByPortFlag = false;

% Check for sounds to play
% look at each element of soundTypesInPhase and use the shouldWePlay method
if ~isempty(soundTypesInPhase)
    for stInd=1:length(soundTypesInPhase)
        st = soundTypesInPhase{stInd};
        % decide what portSet to send to shouldWePlay
        if ports(targetOptions)
            portSet = 'target';
        elseif ports(distractorOptions)
            portSet = 'distractor';
        elseif ports(requestOptions)
            % request
            portSet = 'request';
        else
            % no response, this is a frame indexed sound stimulus
            portSet = '';
        end

        if shouldWePlay(st,portSet, stepsInPhase)
            tempSoundMgr = playSound(getSoundManager(tm),getName(st),getDuration(st)/1000.0,station);
            tm = setSoundManager(tm, tempSoundMgr);
%                         tm.soundMgr = playLoop(tm.soundMgr,getName(st),station,getReps(st));
        end
    end
end



% Check against framesUntilTransition - Transition BY TIME
% if we are at grad by time, then manually set port to the correct one
% note that we will need to flag that this was done as "auto-request"
if ~isempty(framesUntilTransition) && stepsInPhase == framesUntilTransition - 1 % changed to framesUntilTransition-1 % 8/19/08
    %port = transitionCriterion{1}(1);
    newSpecInd = transitionCriterion{2};
    updatePhase = 1;
    if isFinalPhase
        done = 1;
  %      error('we are done by time');
    end
    %error('transitioned by time in phase %d', specInd);
    transitionedByTimeFlag = true;
end

% Check for transition by port selection
for gcInd=1:2:length(transitionCriterion)-1
    if ~isempty(transitionCriterion{gcInd}) && logical(ports(transitionCriterion{gcInd}))
        % we found port in this port set
        % first check if we are done with this trial, in which case we do nothing except set done to 1
        if isFinalPhase
            done = 1;
            updatePhase = 1;
%              'we are done with this trial'
%              specInd
        else
            % move to the next phase as specified by graduationCriterion
      %      specInd = transitionCriterion{gcInd+1};
            newSpecInd = transitionCriterion{gcInd+1};
            if (specInd == newSpecInd)
                error('same indices at %d', specInd);
            end
            updatePhase = 1;
        end
        transitionedByPortFlag = true;
        
        % set response to the ports array when it is triggered during a phase transition (ie response will be whatever the last port to trigger 
        %   a transition was)
        response = ports;
        % set correct if we are on a target or distractor
        if ports(targetOptions)
            trialResponse =response;
        elseif ports(distractorOptions)
            trialResponse = response;
        end
        
    end
end


% set isRequesting when request port is hit according to these rules:
%   if isRequesting was already 1, then set it to 0
%   if isRequesting was 0, then set it to 1
%   (basically flip the bit every time request port is hit)
if any(ports(requestOptions))
    if isRequesting
        isRequesting=false;
    else
        isRequesting=true;
    end
end



stepsInPhase = stepsInPhase + 1; % increment number of steps in this phase

end % end function