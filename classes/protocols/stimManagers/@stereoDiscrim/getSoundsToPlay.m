function soundsToPlay = getSoundsToPlay(stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails, stimDetails, dynamicSounds)

soundsToPlay = getSoundsToPlay(stimManager.stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails, stimDetails, dynamicSounds);


if strcmp(phaseType,'discrim') && strcmp(trialManagerClass,'nAFC') && stepsInPhase <= 0
    soundsToPlay{2}{end+1} = {'stimSound' 100};
end

end