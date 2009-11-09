function soundsToPlay = getSoundsToPlay(stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails, stimDetails)
% see doc in stimManager.calcStim.txt

playLoopSounds={};
playSoundSounds={};

% nAFC/goNoGo setup:
if strcmp(trialManagerClass, 'nAFC') || strcmp(trialManagerClass,'goNoGo') || strcmp(trialManagerClass,'oddManOut') || strcmp(trialManagerClass,'cuedGoNoGo')
    % play trial start sound
    if phase==1 && stepsInPhase <=0
        playSoundSounds{end+1} = {'trialStartSound', 50};
    elseif strcmp(phaseType,'pre-request') && (any(ports(targetOptions)) || any(ports(distractorOptions)) || ...
        (any(ports) && isempty(requestOptions))) 
        % play white noise (when responsePort triggered during phase 1)
        playLoopSounds{end+1} = 'trySomethingElseSound';
    elseif ismember(phaseType,{'discrim','pre-response'}) && any(ports(requestOptions))  
        % play stim sound (when stim is requested during phase 2)
        playLoopSounds{end+1} = 'keepGoingSound';
    elseif strcmp(phaseType,'reinforced') && stepsInPhase <= 0 && trialDetails.correct
        % play correct sound
        playSoundSounds{end+1} = {'correctSound', msRewardSound};
    elseif strcmp(phaseType,'reinforced') && stepsInPhase <= 0 && ~trialDetails.correct
        % play wrong sound
        playSoundSounds{end+1} = {'wrongSound', msPenaltySound};
    end
    
% freeDrinks setup
% this will have to be fixed for passiveViewing (either as a flag on freeDrinks or as a new trialManager)
elseif strcmp(trialManagerClass, 'freeDrinks')
    if phase==1 && stepsInPhase <=0
        playSoundSounds{end+1} = {'trialStartSound', 50};
    elseif ismember(phaseType,{'discrim','pre-response'}) && ~isempty(targetOptions) && any(ports(setdiff(1:length(ports), targetOptions))) % normal freeDrinks
        % play white noise (when any port that is not a target is triggered)
        playLoopSounds{end+1} = 'trySomethingElseSound';
    elseif ismember(phaseType,{'discrim','pre-response'}) && ~isempty(requestOptions) && any(ports(requestOptions)) % passiveViewing freeDrinks
        % check that the requestMode and requestRewardDone also pass 
        % same logic as in the request reward handling, but for sound
        % play keepGoing sound?
        if playRequestSoundLoop
            playLoopSounds{end+1} = 'keepGoingSound';
        end
    end
    % play correct/error sound
    if strcmp(phaseType,'reinforced') && stepsInPhase <= 0
        if ~isempty(msRewardSound) && msRewardSound>0
            playSoundSounds{end+1} = {'correctSound', msRewardSound};
        elseif ~isempty(msPenaltySound) && msPenaltySound>0
            playSoundSounds{end+1} = {'wrongSound', msPenaltySound};
        end
    end
elseif strcmp(trialManagerClass, 'autopilot')
    % do nothing because we don't play any sounds in this case
     if phase==1 && stepsInPhase <=0
        playSoundSounds{end+1} = {'trialStartSound', 50};
     end
else
    trialManagerClass
    error('default getSoundsToPlay should only be for non-phased cases');
end

soundsToPlay = {playLoopSounds, playSoundSounds};

end % end function