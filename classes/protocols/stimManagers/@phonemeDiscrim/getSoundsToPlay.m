function [soundsToPlay, stimDetails] = getSoundsToPlay(stimManager, ports, lastPorts, phase, phaseType, stepsInPhase,msRewardSound, msPenaltySound, ...
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
        ((strcmp(phaseType,'discrim') && strcmp(trialManagerClass,'nAFC')))
    
    soundsToPlay{2}{end+1} = {'stimSound' stimManager.duration};
    
     if stimDetails.laserON
         
         
         if stimManager.freq(1)==1 %full duration of stimulus
        setLaser(station,true);

         stimDetails.laser_start_time = GetSecs;
         
         
         
         else %multiple possible timepoints 
             
             
             if stimDetails.laser_start_window==0 %if the laser starts right away, start it!
                  setLaser(station,true);
             stimDetails.laser_start_time = GetSecs;
             
             
             else %wait if startwindow is nonzero

                 stimDetails.laser_wait_start_time=GetSecs; 
             end
             
         end
         
         
         
         
         
     end
end


if stimDetails.laserON 
    if stimManager.freq(1)~=1 %only for delayed laser starts
    if stimDetails.laser_start_window~=0 %make sure we should be waiting
    if stimDetails.laser_start_time == Inf; %make sure the laser isn't on added 4-25   
    if GetSecs-stimDetails.laser_wait_start_time > stimDetails.laser_start_window %oops this is always true CO 4-25
        setLaser(station, true) %turn on laser
        stimDetails.laser_start_time = GetSecs; %store starting time
    end
    end
    end
    end
end
    


if stimDetails.laserON
   
 if GetSecs-stimDetails.laser_start_time > stimDetails.laser_duration
     setLaser(station,false);
     if stimDetails.laser_off_time==Inf
         stimDetails.laser_off_time=GetSecs;
     end
 end
end



end

