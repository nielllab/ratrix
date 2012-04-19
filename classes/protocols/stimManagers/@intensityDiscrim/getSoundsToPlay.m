function soundsToPlay = getSoundsToPlay(stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails, stimDetails, dynamicSounds)

soundsToPlay = getSoundsToPlay(stimManager.stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails, stimDetails, dynamicSounds);

%only enable this if you aren't using keepGoingSound as the discriminandum
if false && strcmp(phaseType,'discrim') && strcmp(trialManagerClass,'nAFC')
    if ~all(cellfun(@isempty,soundsToPlay))
        soundsToPlay
        cellfun(@(x)disp(x),soundsToPlay)
        warning('removing conflicting sounds from discrim phase...')
        soundsToPlay={{},{}};
    end
end

if stepsInPhase <= 0 && ...
        ((strcmp(phaseType,'discrim') && strcmp(trialManagerClass,'nAFC')) || ...
        (strcmp(phaseType,'reinforced') && strcmp(trialManagerClass,'freeDrinks')))
    soundsToPlay{2}{end+1} = {'stimSound' stimManager.duration};
end
end