function [stimulus updateSM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance isCorrection] = calcStim(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords)

updateSM = true; % This is always true, because the audio stimulus is always set

% Determine if the modality should switch
if isempty(stimulus.currentModality)
    needToSwitch = true; % Have to choose something
else
    needToSwitch = false;
    switch stimulus.modalitySwitchType
        case 'Never'
            %
        case 'ByNumberOfTrials'
            if stimulus.trialNum > stimulus.modalitySwitchParameter
                needToSwitch = true;
            end   
        case 'ByNumberOfHoursRun'
            timeDiff = now - stimulus.modalityTimeStarted;
            timeDiffMax = datenum([ 0 0 0 stimulus.modalitySwitchParameter 0 0]);
            if timeDiff > timeDiffMax
                needToSwitch = true;
            end
        case 'ByNumberOfDaysWorked'
            timeDiff = now - stimulus.modalityTimeStarted;
            if timeDiff > stimulus.modalitySwitchParameter
                needToSwitch = true;
            end
        otherwise
            error('Unknown/unsupported modality switch type')
    end
end

% If need to switch modalities, set start time and select the new current
% modality
if needToSwitch
    stimulus.modalityTimeStarted = now;
    stimulus.trialNum = 1;
    if isempty(stimulus.currentModality) || strcmp(stimulus.modalitySwitchMethod,'Random') == 0
        stimulus.currentModality = round(rand());
    else
        stimulus.currentModality = setDiff([0 1],stimulus.currentModality);
    end
end

% Determine if blocking is still going on
if stimulus.trialNum > stimulus.blockingLength 
    stimulus.isBlocking = false;
else
    stimulus.isBlocking = true;
end


[stimulus.hemifieldFlicker HFupdateSM HFout HFLUT HFscaleFactor HFtype HFtargetPorts HFdistractorPorts HFdetails HFinterTrialLuminance HFisCorrection] = calcStim(stimulus.hemifieldFlicker,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);

[stimulus.stereoDiscrim SDupdateSM SDout SDLUT SDscaleFactor SDtype SDtargetPorts SDdistractorPorts SDdetails SDinterTrialLuminance SDisCorrection] = calcStim(stimulus.stereoDiscrim,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);

% Update the stim manager if either of the component stim managers needed
% updating
updateSM = HFupdateSM || SDupdateSM || updateSM;

% If stimulus is blocking, then block the appropriate stimulus
if stimulus.isBlocking 
    if stimulus.currentModality == 0
        % Visual modality, block sound
        out = HFout;
        LUT = HFLUT;
        scaleFactor = HFscaleFactor;
        type = HFtype;
        stimulus.audioStimulus = [];
    else
        % Sound modality, block vision
        out = SDout;
        LUT = SDLUT;
        scaleFactor = SDscaleFactor;
        type = SDtype;
        stimulus.audioStimulus = getAudioStimulus(stimulus.stereoDiscrim);
    end
else
    % When not blocking trials, the hemifield is always displayed
    %  and the audio stimulus always comes from stereoDiscrim
    out = HFout;
    LUT = HFLUT;
    scaleFactor = HFscaleFactor;
    type = HFtype;
    stimulus.audioStimulus = getAudioStimulus(stimulus.stereoDiscrim);
end

% The correct answer is dependent on which modality is selected
if stimulus.currentModality == 0
    % Visual modality is relevant
    targetPorts = HFtargetPorts;
    distractorPorts = HFdistractorPorts;
    interTrialLuminance = HFinterTrialLuminance;
    isCorrection = HFisCorrection;
else
    % Sound modality is relevant
    targetPorts = SDtargetPorts;
    distractorPorts = SDdistractorPorts;
    interTrialLuminance = SDinterTrialLuminance;
    isCorrection = SDisCorrection;
end

details.HFdetails = HFdetails;
details.SDdetails = SDdetails;
details.HFtargetPorts = HFtargetPorts;
details.SDtargetPorts = SDtargetPorts;
details.HFdistractorPorts = HFdistractorPorts;
details.SDdistractorPorts = SDdistractorPorts;
details.HFisCorrection = HFisCorrection;
details.SDisCorrection = SDisCorrection;
details.currentModality = stimulus.currentModality;
details.blockingLength = stimulus.blockingLength;
details.isBlocking = stimulus.isBlocking;
details.currentModalityTrialNum = stimulus.trialNum; % How many trials were run on this modality so far
details.modalitySwitchMethod = stimulus.modalitySwitchMethod;
details.modalitySwitchType = stimulus.modalitySwitchType;

% Increment trial num
stimulus.trialNum = stimulus.trialNum+1;

