function [stimulus,updateSM,resolutionIndex,preRequestStim,preResponseStim,discrimStim,LUT,targetPorts,distractorPorts,...
    details,interTrialLuminance,text,indexPulses,imagingTasks,sounds] =...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords,targetPorts,distractorPorts,details,text)

indexPulses=[];
imagingTasks=[];

LUT=makeStandardLUT(LUTbits);

[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

updateSM=0;
toggleStim=true;

scaleFactor = getScaleFactor(stimulus);
interTrialLuminance = getInterTrialLuminance(stimulus);

switch trialManagerClass
    case 'freeDrinks'
        type='cache';
    case 'nAFC'
        type='loop';%int32([10 10]); % This is 'timedFrames'
    otherwise
        error('unknown trial manager class')
end

 discrimType= 'intensityDiscrim'
switch discrimType
    case 'intensityDiscrim'
        [lefts, rights] = getBalance(responsePorts,targetPorts);
                
                
if lefts>rights %choose a left stim
            if stimulus.discrimSide %boolean, sidedness of boundary
                details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes<stimulus.discrimBoundary)));
            else
                details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes>stimulus.discrimBoundary)));
            end
        elseif rights>lefts %choose a right stim
            if stimulus.discrimSide
                details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes>stimulus.discrimBoundary)));
            else
                details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes<stimulus.discrimBoundary)));
            end
        end
        details.rightAmplitude = details.Amplitude;
        details.leftAmplitude = details.Amplitude;
    case 'stereoDiscrim'
        [lefts, rights] = getBalance(responsePorts,targetPorts);
        
        details.rightAmplitude = max(stimulus.amplitudes);
        details.leftAmplitude = max(stimulus.amplitudes);
        
        if lefts>rights
            details.rightAmplitude = min(stimulus.amplitudes);
        elseif rights>lefts
            details.leftAmplitude = min(stimulus.amplitudes);
        end
end

switch stimulus.soundType
    case {'allOctaves','tritones'}
        sSound = soundClip('stimSoundBase','allOctaves',[stimulus.freq],20000);
    case {'binaryWhiteNoise','gaussianWhiteNoise','uniformWhiteNoise','empty'}
        sSound = soundClip('stimSoundBase',stimulus.soundType);
end
stimulus.stimSound = soundClip('stimSound','dualChannel',{sSound,details.leftAmplitude},{sSound,details.rightAmplitude});

sounds={stimulus.stimSound};

out=zeros(min(height,getMaxHeight(stimulus)),min(width,getMaxWidth(stimulus)),2);
out(:,:,1)=stimulus.mean;
out(:,:,2)=stimulus.mean;

discrimStim=[];
discrimStim.stimulus=out;
discrimStim.stimType=type;
discrimStim.scaleFactor=scaleFactor;
discrimStim.startFrame=0;
%discrimStim.autoTrigger=[];

preRequestStim=[];
preRequestStim.stimulus=interTrialLuminance;
preRequestStim.stimType='loop';
preRequestStim.scaleFactor=0;
preRequestStim.startFrame=0;
%preRequestStim.autoTrigger=[];
preRequestStim.punishResponses=false;

preResponseStim=discrimStim;
preResponseStim.punishResponses=false;