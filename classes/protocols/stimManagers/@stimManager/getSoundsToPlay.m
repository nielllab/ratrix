function soundsToPlay = getSoundsToPlay(stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails, stimDetails)
% see doc in stimManager.calcStim.txt

playLoopSounds={};
playSoundSounds={};

dOrP=strcmp(phaseType,'discrim') || strcmp(phaseType,'pre-response'); %ismember too slow

% nAFC/goNoGo setup:
switch trialManagerClass
    case {'nAFC','goNoGo','oddManOut','cuedGoNoGo'}
        % play trial start sound
        if phase==1 && stepsInPhase <=0
            playSoundSounds{end+1} = {'trialStartSound', 50};
        elseif strcmp(phaseType,'pre-request') && (any(ports(targetOptions)) || any(ports(distractorOptions)) || ...
                (any(ports) && isempty(requestOptions)))
            % play white noise (when responsePort triggered during phase 1)
            playLoopSounds{end+1} = 'trySomethingElseSound';
        elseif dOrP && any(ports(requestOptions))
            % play stim sound (when stim is requested during phase 2)
            playLoopSounds{end+1} = 'keepGoingSound';
        elseif strcmp(phaseType,'reinforced') && stepsInPhase <= 0 && trialDetails.correct
            % play correct sound
            playSoundSounds{end+1} = {'correctSound', msRewardSound};
        elseif strcmp(phaseType,'reinforced') && stepsInPhase <= 0 && ~trialDetails.correct
            % play wrong sound
            playSoundSounds{end+1} = {'wrongSound', msPenaltySound};
        elseif strcmp(phaseType,'earlyPenalty') %&& stepsInPhase <= 0 what does stepsInPhase do? I don't think we need this for this phase
            % play wrong sound
            playSoundSounds{end+1} = {'wrongSound', msPenaltySound};
        end
        
    case 'ball'
        switch phaseType
            case 'discrim'
                if false %add something in trialDetails to indicate these?
                    playLoopSounds{end+1} = 'trySomethingElseSound';
                    playLoopSounds{end+1} = 'keepGoingSound';
                end
            case 'reinforced'
                if stepsInPhase <=0
                    if trialDetails.correct
                        playSoundSounds{end+1} = {'correctSound', msRewardSound};
                    else
                        playSoundSounds{end+1} = {'wrongSound', msPenaltySound};
                    end
                end
        end
        
        % freeDrinks setup
        % this will have to be fixed for passiveViewing (either as a flag on freeDrinks or as a new trialManager)
    case 'freeDrinks'
        if phase==1 && stepsInPhase <=0
            playSoundSounds{end+1} = {'trialStartSound', 50};
        elseif dOrP && ~isempty(targetOptions) && any(ports(setdiff(1:length(ports), targetOptions))) % normal freeDrinks
            % play white noise (when any port that is not a target is triggered)
            playLoopSounds{end+1} = 'trySomethingElseSound';
        elseif dOrP && ~isempty(requestOptions) && any(ports(requestOptions)) % passiveViewing freeDrinks
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
        
    case 'autopilot'
        % do nothing because we don't play any sounds in this case
        if phase==1 && stepsInPhase <=0
            playSoundSounds{end+1} = {'trialStartSound', 50};
        end
        
    otherwise
        trialManagerClass
        error('default getSoundsToPlay should only be for non-phased cases');
end

soundsToPlay = {playLoopSounds, playSoundSounds};
end