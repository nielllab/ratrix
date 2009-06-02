function [stimulus,updateSM,resolutionIndex,preRequestStim,preResponseStim,discrimStim,LUT,targetPorts,distractorPorts,...
    details,interTrialLuminance,text,indexPulses,imagingTasks] =... 
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords)
% 1/3/0/09 - trialRecords now includes THIS trial
%LUT = Screen('LoadCLUT', 0);
%LUT=LUT/max(LUT(:));

indexPulses=[];
imagingTasks=[];

LUTBitDepth=8;
numColors=2^LUTBitDepth; maxColorID=numColors-1; fraction=1/(maxColorID);
ramp=[0:fraction:1];
LUT= [ramp;ramp;ramp]';

[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

updateSM=0;
details.correctionTrial=0;
toggleStim=true;
text='stereoDiscrim';

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

switch trialManagerClass
    case 'freeDrinks'
        type='cache';
        % fli: this never gets used anyways, so why is it still here?
        % Determine what the last response was
%         if ~isempty(trialRecords) && length(trialRecords)>=2
%             lastResponse=find(trialRecords(end-1).response);
%             if length(lastResponse)>1
%                 lastResponse=lastResponse(1);
%             end
%         else
%             lastResponse=[];
%         end
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
            lastRec=trialRecords(end-1);
        else
            lastRec=[];
        end
        [targetPorts distractorPorts details]=assignPorts(details,lastRec,responsePorts,trialManagerClass);


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