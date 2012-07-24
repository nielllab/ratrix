function [soundsToPlay stimDetails] = getSoundsToPlay(stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails, stimDetails, dynamicSounds)

[soundsToPlay, stimDetails] = getSoundsToPlay(stimManager.stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
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
    setLaser(st,true); %is station in trialDetails?
    stimDetails.laser_start_time=GetSecs;    
end

if GetSecs-stimDetails.laser_start_time>stimDetails.laser_duration
    setLaser(st,false);
end

end