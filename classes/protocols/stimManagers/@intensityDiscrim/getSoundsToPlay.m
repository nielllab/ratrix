function soundsToPlay = getSoundsToPlay(stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails, stimDetails, dynamicSounds)

soundsToPlay = getSoundsToPlay(stimManager.stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails, stimDetails, dynamicSounds);

if stepsInPhase <= 0 && ...
        ((strcmp(phaseType,'discrim') && strcmp(trialManagerClass,'nAFC')) || ...
        (strcmp(phaseType,'reinforced') && strcmp(trialManagerClass,'freeDrinks')))
    if ~all(cellfun(@isempty,soundsToPlay))
        soundsToPlay
        cellfun(@(x)disp(x),soundsToPlay)
        warning('conflicting sounds...')
    end
    soundsToPlay={{},{}};
    soundsToPlay{2}{end+1} = {'stimSound' stimManager.duration};
end
end