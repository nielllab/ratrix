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
    case 'goNoGo'
        type='loop';%int32([10 10]); % This is 'timedFrames'
    otherwise
        error('unknown trial manager class')
end


% target port is always the same, it's just the timing of the response that
% determines whether it will be rewarded 

% pick a random number of tones in package between 3 and 5 (for now)
details.numTones=RandSample(3:5);

% pick a random starting tone 
if rand>0.5
    details.startTone=1; %either freq 1 or freq 2
else
    details.startTone=2;
end

% if lefts>rights %choose a left stim
%     if stimulus.discrimSide %boolean, sidedness of boundary
%         details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes<stimulus.discrimBoundary)));
%     else
%         details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes>stimulus.discrimBoundary)));
%     end
% elseif rights>lefts %choose a right stim
%     if stimulus.discrimSide
%         details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes>stimulus.discrimBoundary)));
%     else
%         details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes<stimulus.discrimBoundary)));
%     end
% end
 details.rightAmplitude = stimulus.amplitude;
 details.leftAmplitude = stimulus.amplitude;

% %decide randomly if we issue a laser pulse on this trial or not
% if rand>0.5
%     details.laserON=1;
% else
%     details.laserON=0;
% end
% details.laser_duration=.5; %seconds
% details.laser_start_time=Inf; 

switch stimulus.soundType
    case {'allOctaves','tritones'}
        sSound = soundClip('stimSoundBase','allOctaves',[stimulus.freqs(details.startTone)],20000);
    case {'binaryWhiteNoise','gaussianWhiteNoise','uniformWhiteNoise','empty'}
        sSound = soundClip('stimSoundBase',stimulus.soundType);
end


stimulus.stimSound = soundClip('stimSound','dualChannel',{sSound,details.leftAmplitude},{sSound,details.rightAmplitude});

sounds={stimulus.stimSound setName(stimulus.stimSound,'correctSound') setName(stimulus.stimSound,'keepGoingSound')};

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
%preRequestStim=[];


preResponseStim=discrimStim;
preResponseStim.punishResponses=false;