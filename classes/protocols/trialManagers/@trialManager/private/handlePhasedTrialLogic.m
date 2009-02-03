function [tm done newSpecInd specInd updatePhase transitionedByTimeFlag transitionedByPortFlag response trialResponse...
    isRequesting lastSoundsPlayed] = ...
    handlePhasedTrialLogic(tm, done, ...
    ports, station, specInd, transitionCriterion, framesUntilTransition, stepsInPhase, isFinalPhase, response, trialResponse, ...
    stimManager, msRewardSound, mePenaltySound, targetOptions, distractorOptions, requestOptions, isRequesting, lastSoundsPlayed)

% This function handles trial logic for a phased trial manager.
% Part of stimOGL rewrite.
% INPUT: tm, responseDetails, done, ports, station, specInd, transitionCriterion, framesUntilTransition, stepsInPhase,
%   isFinalPhase, response, stimManager, msRewardSound, mePenaltySound, targetOptions, distractorOptions, requestOptions, correct,
%   isRequesting, lastSoundsPlayed
% OUTPUT: tm, responseDetails, done, newSpecInd, specInd, updatePhase, transitionedByTimeFlag, transitionedByPortFlag,
%   stepsInPhase, response, correct, isRequesting, lastSoundsPlayed

updatePhase=0;
newSpecInd = specInd;
transitionedByTimeFlag = false;
transitionedByPortFlag = false;

% Check for sounds to play
% 10/13/08 - call the function getSoundsToPlay(stimManager, soundNames, ports, phase, stepsInPhase)
% this function should know about its phases and will determine what sounds to play based on ports, phase and stepsInPhase
soundsToPlay = getSoundsToPlay(stimManager, getSoundNames(getSoundManager(tm)), ports, specInd, stepsInPhase,msRewardSound, mePenaltySound, ...
    targetOptions, distractorOptions, requestOptions, class(tm));
% first end any sounds that were playing last frame but should no longer be played
for i=1:length(lastSoundsPlayed)
    if ~any(ismember(lastSoundsPlayed{i}, soundsToPlay{1}))
        % if this sound should be stopped
        tm.soundMgr = playLoop(tm.soundMgr,lastSoundsPlayed{i},station,0);
    end
end

% soundsToPlay is a cell array of sound names {{playLoop sounds}, {playSound sounds}} to be played at current frame
for i=1:length(soundsToPlay{1})
    %     if ~any(ismember(soundsToPlay{1}{i}, lastSoundsPlayed))
    % if this sound isnt already playing
    tm.soundMgr = playLoop(tm.soundMgr,soundsToPlay{1}{i},station,1);
    %     end
end
% lastSoundsPlayed should be updated to the currently playing sounds
lastSoundsPlayed = soundsToPlay{1};

% now play one-time sounds
for i=1:length(soundsToPlay{2})
    %     soundsToPlay{2}{i}{1}
    %     soundsToPlay{2}{i}{2}
    tm.soundMgr = playSound(tm.soundMgr,soundsToPlay{2}{i}{1},soundsToPlay{2}{i}{2}/1000.0,station);
end

% look at each element of soundTypesInPhase and use the shouldWePlay method
% if ~isempty(soundTypesInPhase)
%     for stInd=1:length(soundTypesInPhase)
%         st = soundTypesInPhase{stInd};
%         % decide what portSet to send to shouldWePlay
%         if ports(targetOptions)
%             portSet = 'target';
%         elseif ports(distractorOptions)
%             portSet = 'distractor';
%         elseif ports(requestOptions)
%             % request
%             portSet = 'request';
%         else
%             % no response, this is a frame indexed sound stimulus
%             portSet = '';
%         end
%
%         if shouldWePlay(st,portSet, stepsInPhase)
%             tempSoundMgr = playSound(getSoundManager(tm),getName(st),getDuration(st)/1000.0,station);
%             tm = setSoundManager(tm, tempSoundMgr);
% %                         tm.soundMgr = playLoop(tm.soundMgr,getName(st),station,getReps(st));
%         end
%     end
% end

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
    if ~isempty(transitionCriterion{gcInd}) && any(logical(ports(transitionCriterion{gcInd})))
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
            %             if (specInd == newSpecInd)
            %                 error('same indices at %d', specInd);
            %             end
            updatePhase = 1;
        end
        transitionedByPortFlag = true;
        
        % set response to the ports array when it is triggered during a phase transition (ie response will be whatever the last port to trigger
        %   a transition was)
        response = ports;
        % set correct if we are on a target or distractor
        if any(ports(targetOptions))
            % 2/2/09 - if multiple ports blocked, then automatically respond as incorrect and change newSpecInd appropriately
            if length(find(ports))>1
                errorPhaseInd = newSpecInd+1; % how do we know errorPhaseInd, except by policy of error phase being immediately after correct phase?
                % maybe we can loop through transitionCriterion again and look? but that sucks
                newSpecInd = errorPhaseInd;
            end
            trialResponse =response;
        elseif any(ports(distractorOptions))
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


% moved to runRealTimeLoop to save on copy-on-write 10/16/08
% stepsInPhase = stepsInPhase + 1; % increment number of steps in this phase

end % end function