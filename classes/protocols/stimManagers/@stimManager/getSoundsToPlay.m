function soundsToPlay = getSoundsToPlay(stimManager, ports, lastPorts, phase, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails)
% see doc in stimManager.calcStim.txt

playLoopSounds={};
playSoundSounds={};

% nAFC setup:
if strcmp(trialManagerClass, 'nAFC')
    % play white noise (when responsePort triggered during phase 1)
    if phase == 1 && (any(ports(targetOptions)) || any(ports(distractorOptions)))
        playLoopSounds{end+1} = 'trySomethingElseSound';
    elseif phase == 2 && any(ports(requestOptions))  
        % play stim sound (when stim is requested during phase 2)
        playLoopSounds{end+1} = 'keepGoingSound';
    elseif phase == 3 && stepsInPhase <= 0 && trialDetails.correct
        % play correct sound
        playSoundSounds{end+1} = {'correctSound', msRewardSound};
    elseif phase == 3 && stepsInPhase <= 0 && ~trialDetails.correct
        % play wrong sound
        playSoundSounds{end+1} = {'wrongSound', msPenaltySound};
    end   
% freeDrinks setup
% this will have to be fixed for passiveViewing (either as a flag on freeDrinks or as a new trialManager)
elseif strcmp(trialManagerClass, 'freeDrinks')
    % play white noise (when any port that is not a target is triggered)
    if phase == 1 && ~isempty(targetOptions) && any(ports(setdiff(1:length(ports), targetOptions))) % normal freeDrinks
        playLoopSounds{end+1} = 'trySomethingElseSound';
    elseif phase == 1 && ~isempty(requestOptions) && any(ports(requestOptions)) % passiveViewing freeDrinks
        % check that the requestMode and requestRewardDone also pass 
        % same logic as in the request reward handling, but for sound
        % play keepGoing sound?
        if playRequestSoundLoop
            playLoopSounds{end+1} = 'keepGoingSound';
        end
    end
    % play correct/error sound
    if phase == 2 && stepsInPhase <= 0
        playSoundSounds{end+1} = {'correctSound', msRewardSound};
        playSoundSounds{end+1} = {'wrongSound', msPenaltySound};
    end
elseif strcmp(trialManagerClass, 'autopilot')
    % do nothing because we don't play any sounds in this case
else
    trialManagerClass
    error('default getSoundsToPlay should only be for non-phased cases');
end

soundsToPlay = {playLoopSounds, playSoundSounds};

end % end function