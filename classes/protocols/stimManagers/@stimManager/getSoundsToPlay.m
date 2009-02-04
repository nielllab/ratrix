function soundsToPlay = getSoundsToPlay(stimManager, soundNames, ports, phase, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, trialManagerClass)
% this function decides what sounds to play given the current ports, phase, and stepsInPhase
% returns a cell array of sound names in this form:
% { {playLoop sounds}, {{playSound sound, playSound duration}, {playSound sound, playSound duration}} }

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
    elseif phase == 3 && stepsInPhase <= 0
        % play correct sound
        playSoundSounds{end+1} = {'correctSound', msRewardSound};
    elseif phase == 4 && stepsInPhase <= 0
        % play wrong sound
        playSoundSounds{end+1} = {'wrongSound', msPenaltySound};
    end   
% freeDrinks setup
elseif strcmp(trialManagerClass, 'freeDrinks')
    % play white noise (when any port that is not a target is triggered)
    if phase == 1 && any(ports(setdiff(1:length(ports), targetOptions)))
        playLoopSounds{end+1} = 'trySomethingElseSound';
    end
    % play correct sound
    if phase == 2 && stepsInPhase <= 0
        playSoundSounds{end+1} = {'correctSound', msRewardSound};
    end
elseif strcmp(trialManagerClass, 'autopilot')
    % do nothing because we don't play any sounds in this case
else
    error('default getSoundsToPlay should only be for non-phased cases');
end

soundsToPlay = {playLoopSounds, playSoundSounds};

end % end function