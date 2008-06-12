function [stimulus updateSM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance isCorrection] = calcStim(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords)

%LUT = Screen('LoadCLUT', 0);
%LUT=LUT/max(LUT(:));

LUTBitDepth=8;
numColors=2^LUTBitDepth; maxColorID=numColors-1; fraction=1/(maxColorID);
ramp=[0:fraction:1];
LUT= [ramp;ramp;ramp]';


updateSM=0;
isCorrection=0;

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

switch trialManagerClass
    case 'freeDrinks'
        type='static';
        % Determine what the last response was
        if ~isempty(trialRecords)
            lastResponse=find(trialRecords(end).response);
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

        % dfp: 12.07.07: correction trial code removed from here.  Thought
        % to be handled outside of calcStim eventually per Erik

        lastResponse=[];
        lastCorrect=[];
        lastWasCorrection=0;
        details.correctionTrial=0;
        targetPorts=responsePorts(ceil(rand*length(responsePorts)));

        distractorPorts=setdiff(responsePorts,targetPorts);
        targetPorts

        %edf: 11.25.06: original:
        %targetPorts=responsePorts(ceil(rand*length(responsePorts)));
        %distractorPorts=setdiff(responsePorts,targetPorts);

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