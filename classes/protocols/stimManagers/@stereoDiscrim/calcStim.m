function [stimulus,updateSM,resolutionIndex,out,LUT,scaleFactor,type,targetPorts,distractorPorts,details,interTrialLuminance,text] =... 
    calcStim(stimulus,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% 1/3/0/09 - trialRecords now includes THIS trial
%LUT = Screen('LoadCLUT', 0);
%LUT=LUT/max(LUT(:));

LUTBitDepth=8;
numColors=2^LUTBitDepth; maxColorID=numColors-1; fraction=1/(maxColorID);
ramp=[0:fraction:1];
LUT= [ramp;ramp;ramp]';

[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

updateSM=0;
details.correctionTrial=0;
text='stereoDiscrim';

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

switch trialManagerClass
    case 'freeDrinks'
        type='static';
        % Determine what the last response was
        if ~isempty(trialRecords) && length(trialRecords)>=2
            lastResponse=find(trialRecords(end-1).response);
            if length(lastResponse)>1
                lastResponse=lastResponse(1);
            end
        else
            lastResponse=[];
        end
        % Go to port with sound, ignore wrong answers
        '##################CALC STIM RESPONSE PORTS#################'
        responsePorts
        % Go to port with sound, ignore wrong answers
        tp=round(rand);
        if(tp == 0)
            targetPorts = responsePorts(1); % Left
        else
            targetPorts = responsePorts(end); % Right
        end
        distractorPorts=[];
    case 'nAFC'
        type='loop';%int32([10 10]); % This is 'timedFrames'

        %edf: 11.25.06: copied correction trial logic from hack addition to cuedGoToFeatureWithTwoFlank
        %edf: 11.15.06 realized we didn't have correction trials!
        %changing below...

        details.pctCorrectionTrials=.5; % need to change this to be passed in from trial manager
        
        if ~isempty(trialRecords) && length(trialRecords)>=2
            lastResponse=find(trialRecords(end-1).response);
            lastCorrect=trialRecords(end-1).correct;
            if any(strcmp(fields(trialRecords(end-1).stimDetails),'correctionTrial'))
                lastWasCorrection=trialRecords(end-1).stimDetails.correctionTrial;
            else
                lastWasCorrection=0;
            end
            if length(lastResponse)>1
                lastResponse=lastResponse(1);
            end
        else
            lastResponse=[];
            lastCorrect=[];
            lastWasCorrection=0;
        end

        %note that this implementation will not show the exact same
        %stimulus for a correction trial, but just have the same side
        %correct.  may want to change...
        if ~isempty(lastCorrect) && ~isempty(lastResponse) && ~lastCorrect && (lastWasCorrection || rand<details.pctCorrectionTrials)
            details.correctionTrial=1;
            'correction trial!'
            targetPorts=trialRecords(end-1).targetPorts;
            details.correctionTrial=1;
        else
            details.correctionTrial=0;
            targetPorts=responsePorts(ceil(rand*length(responsePorts)));
        end


        distractorPorts=setdiff(responsePorts,targetPorts);
        targetPorts

    otherwise
        error('unknown trial manager class')
end

% Use the amplitudes and the target port to determine how to set the spread
if targetPorts == 1 % Left Bias -- this is hacky, how to tell if port is left or not?
    details.leftAmplitude = max(stimulus.amplitudes);
    details.rightAmplitude = min(stimulus.amplitudes);
else % Right Bias
    details.leftAmplitude = min(stimulus.amplitudes);
    details.rightAmplitude = max(stimulus.amplitudes);
end
sSound = soundClip('stimSoundBase','allOctaves',[stimulus.freq],20000);
stimulus.stimSound = soundClip('stimSound','dualChannel',{sSound,details.leftAmplitude},{sSound,details.rightAmplitude});

out=zeros(min(height,getMaxHeight(stimulus)),min(width,getMaxWidth(stimulus)),2);
out(:,:,1)=stimulus.mean;
out(:,:,2)=stimulus.mean;