function [stimulus,updateSM,resolutionIndex,preRequestStim,preResponseStim,discrimStim,LUT,targetPorts,distractorPorts,...
    details,interTrialLuminance,text,indexPulses,imagingTasks,sounds] =...
    calcStim(stimulus,trialManagerClass,allowRepeats,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords,targetPorts,distractorPorts,details,text)

indexPulses=[];
imagingTasks=[];

LUT=makeStandardLUT(LUTbits);

[resolutionIndex height width hz]=chooseLargestResForHzsDepthRatio(resolutions,[100 60],32,getMaxWidth(stimulus),getMaxHeight(stimulus));

updateSM=1;
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

%override total stimulus duration
stimulus.duration=(details.numTones+1)*(stimulus.toneDuration+stimulus.isi)-stimulus.isi;
a = trialRecords(end-1);
c = [];
r = [];
try
c = a.trialDetails.correct;
end

try
r = a.result;
end


% pick a starting tone and then update stimulus.startfreq to the next value
details.startTone = stimulus.startfreq; 
x = [2 1];
if ~c
    if strcmp(r,'nominal')   
    details.startTone = x(stimulus.startfreq);
    end
end
stimulus.startfreq = x(details.startTone);
details.endTone = x(details.startTone);
    

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
    case {'tone'}
        sSound = soundClip('stimSoundBase','tone',[stimulus.freqs(details.startTone)]) ;
    case {'CNMToneTrain'}
        sSound = soundClip('stimSoundBase','CNMToneTrain',[stimulus.freqs(details.startTone) stimulus.freqs(details.endTone) details.numTones stimulus.isi stimulus.toneDuration]) ;
end

mycorrectSound=soundClip('stimSoundBase','allOctaves',100,20000);
mykeepGoingSound=soundClip('stimSoundBase','allOctaves',800,20000);

stimulus.stimSound = soundClip('stimSound','dualChannel',{sSound,details.leftAmplitude},{sSound,details.rightAmplitude});

%sounds={stimulus.stimSound setName(stimulus.stimSound,'correctSound') setName(stimulus.stimSound,'keepGoingSound')};
sounds={stimulus.stimSound setName(mycorrectSound,'correctSound') setName(mykeepGoingSound,'keepGoingSound')};

out=zeros(min(height,getMaxHeight(stimulus)),min(width,getMaxWidth(stimulus)),2);
out(:,:,1)=stimulus.mean;
out(:,:,2)=stimulus.mean;

discrimStim=[];
discrimStim.stimulus=out;
discrimStim.stimType=type;
discrimStim.scaleFactor=scaleFactor;
discrimStim.startFrame=0;
discrimStim.punishResponses=false;
%discrimStim.autoTrigger=[];

preRequestStim=[];
preRequestStim.stimulus=interTrialLuminance;
preRequestStim.stimType='loop';
preRequestStim.scaleFactor=0;
preRequestStim.startFrame=0;
%preRequestStim.autoTrigger=[];
preRequestStim.punishResponses=false;
%preRequestStim=[];

earlyPenaltyStim=preRequestStim;
earlyPenaltyStim.stimType='cache';


preResponseStim=preRequestStim;
preResponseStim.st='loop';
%preResponseStim.autoTrigger=[];
preResponseStim.startFrame=[];