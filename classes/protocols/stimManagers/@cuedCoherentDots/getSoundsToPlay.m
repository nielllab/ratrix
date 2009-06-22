function soundsToPlay = getSoundsToPlay(stimManager, ports, lastPorts, phase, phaseType,stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails,stimDetails)
% see doc in stimManager.calcStim.txt

playLoopSounds={};
playSoundSounds={};

% nAFC setup:
if strcmp(trialManagerClass, 'nAFC')
    % play white noise (when responsePort triggered during phase 1)
    if strcmp(phaseType,'pre-request') && (any(ports(targetOptions)) || any(ports(distractorOptions)))
        playLoopSounds{end+1} = 'trySomethingElseSound';
    elseif ismember(phaseType,{'pre-response'}) && stepsInPhase == 0
        playSoundSounds{end+1} = {stimDetails.cue_sound_name,stimDetails.cue_sound_duration};
% %     elseif phase == 2 && any(ports(requestOptions))  
% %         % play stim sound (when stim is requested during phase 2)
% %         playLoopSounds{end+1} = 'keepGoingSound';
    elseif strcmp(phaseType,'reinforced') && stepsInPhase <= 0 && ~isempty(trialDetails.correct) && trialDetails.correct
        % play correct sound
        playSoundSounds{end+1} = {'correctSound', msRewardSound};
    elseif strcmp(phaseType,'reinforced') && stepsInPhase <= 0 && (~isempty(trialDetails.correct) && ~trialDetails.correct)
        % play wrong sound
        playSoundSounds{end+1} = {'wrongSound', msPenaltySound};
    end   
% freeDrinks setup
% this will have to be fixed for passiveViewing (either as a flag on freeDrinks or as a new trialManager)
elseif strcmp(trialManagerClass, 'freeDrinks')
    % play white noise (when any port that is not a target is triggered)
    if ismember(phaseType,{'discrim','pre-response'}) && ~isempty(targetOptions) && any(ports(setdiff(1:length(ports), targetOptions))) % normal freeDrinks
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
else
    trialManagerClass
    error('default getSoundsToPlay should only be for non-phased cases');
end

soundsToPlay = {playLoopSounds, playSoundSounds};

end % end function