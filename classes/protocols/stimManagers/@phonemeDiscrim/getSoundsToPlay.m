function [soundsToPlay stimDetails] = getSoundsToPlay(stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails, stimDetails, dynamicSounds, station)

[soundsToPlay, stimDetails] = getSoundsToPlay(stimManager.stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
    targetOptions, distractorOptions, requestOptions, playRequestSoundLoop, trialManagerClass, trialDetails, stimDetails, dynamicSounds, station);

%only enable this if you aren't using keepGoingSound as the discriminandum
%ie, setting to true will give a single timed presentation of 'stimSound'
%setting to false is better for learning -- 'keepGoingSound' will play as long and as often as the center beam is broken
stimDetails.overrideSoundCues = true;

if stimDetails.overrideSoundCues && strcmp(phaseType,'discrim') && strcmp(trialManagerClass,'nAFC')
    if ~all(cellfun(@isempty,soundsToPlay))
%         soundsToPlay
%         cellfun(@(x)disp(x),soundsToPlay)
%         warning('removing conflicting sounds from discrim phase...')
        soundsToPlay={{},{}};
    end
end

if stepsInPhase <= 0 && ...
        ((strcmp(phaseType,'discrim') && strcmp(trialManagerClass,'nAFC')) || ...
        (strcmp(phaseType,'reinforced') && strcmp(trialManagerClass,'freeDrinks')))
    
    soundsToPlay{2}{end+1} = {'stimSound' stimManager.duration};
    
%     if stimDetails.laserON
%         setLaser(station,true);
%         stimDetails.laser_start_time = GetSecs;
%     end
end

% if GetSecs-stimDetails.laser_start_time > stimDetails.laser_duration
%     setLaser(station,false);
% end

end