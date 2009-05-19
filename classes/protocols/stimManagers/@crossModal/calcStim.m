function [stimulus updateSM resInd preRequestStim preResponseStim discrimStim LUT targetPorts distractorPorts details interTrialLuminance text indexPulses] = ...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% 1/3/0/09 - trialRecords now includes THIS trial
indexPulses=[];
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
    if isempty(stimulus.currentModality) || strcmp(stimulus.modalitySwitchMethod,'Random') == 0  %edf: this looks like a bug -- why testing against zero?  expect 'Random' to alternate each day...
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

[stimulus.hemifieldFlicker HFupdateSM HFresInd HFout HFLUT HFscaleFactor HFtype HFtargetPorts HFdistractorPorts HFdetails HFinterTrialLuminance text] = ...
    calcStim(stimulus.hemifieldFlicker,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords);

[stimulus.stereoDiscrim SDupdateSM SDresInd SDout SDLUT SDscaleFactor SDtype SDtargetPorts SDdistractorPorts SDdetails SDinterTrialLuminance text] = ...
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords);

% Update the stim manager if either of the component stim managers needed
% updating
updateSM = HFupdateSM || SDupdateSM || updateSM;

% If stimulus is blocking, then block the appropriate stimulus
if stimulus.isBlocking 
    if stimulus.currentModality == 0
        % Visual modality, block sound
        out = HFout;
        LUT = HFLUT;
        resInd = HFresInd;
        scaleFactor = HFscaleFactor;
        type = HFtype;
        stimulus.audioStimulus = [];
    else
        % Sound modality, block vision
        out = SDout;
        LUT = SDLUT;
        resInd = SDresInd;
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
    details.correctionTrial = HFdetails.correctionTrial;
else
    % Sound modality is relevant
    targetPorts = SDtargetPorts;
    distractorPorts = SDdistractorPorts;
    interTrialLuminance = SDinterTrialLuminance;
    details.correctionTrial = SDdetails.correctionTrial;
end

details.HFdetails = HFdetails;
details.SDdetails = SDdetails;
details.HFtargetPorts = HFtargetPorts;
details.SDtargetPorts = SDtargetPorts;
details.HFdistractorPorts = HFdistractorPorts;
details.SDdistractorPorts = SDdistractorPorts;
details.HFcorrectionTrial = HFdetails.correctionTrial;
details.SDcorrectionTrial = SDdetails.correctionTrial;
details.currentModality = stimulus.currentModality;
details.blockingLength = stimulus.blockingLength;
details.isBlocking = stimulus.isBlocking;
details.currentModalityTrialNum = stimulus.trialNum; % How many trials were run on this modality so far
details.modalitySwitchMethod = stimulus.modalitySwitchMethod;
details.modalitySwitchType = stimulus.modalitySwitchType;

discrimStim=[];
discrimStim.stimulus=out;
discrimStim.stimType=type;
discrimStim.scaleFactor=scaleFactor;
discrimStim.startFrame=0;
discrimStim.autoTrigger=[];

preRequestStim=[];
preRequestStim.stimulus=interTrialLuminance;
preRequestStim.stimType='loop';
preRequestStim.scaleFactor=0;
preRequestStim.startFrame=0;
preRequestStim.autoTrigger=[];
preRequestStim.punishResponses=false;

preResponseStim=discrimStim;
preResponseStim.punishResponses=false;

% Increment trial num
stimulus.trialNum = stimulus.trialNum+1;

