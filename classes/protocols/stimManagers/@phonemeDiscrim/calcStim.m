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

% %decide randomly if we issue a laser pulse on this trial or not
% details.laserON = rand>0.9; %laser is on for 10% of trials
% details.laser_duration=.5; %seconds
% details.laser_start_time=Inf; 
details.toneFreq = []; 

if strcmp(stimulus.soundType, 'wmReadWav')
[wav1, fs1] = wavread(getWav1(stimulus));
[wav2, fs2] = wavread(getWav2(stimulus));
wav1 = wav1.';
wav2 = wav2.';


[lefts, rights] = getBalance(responsePorts,targetPorts);

%default case (e.g. rights==lefts )

if lefts>rights %choose a left stim (wav1)
    details.toneFreq = wav1;
elseif rights>lefts %choose a right stim (wav2)
    details.toneFreq = wav2;
end

if lefts == rights %left
    details.toneFreq = wav1;
end

end



if strcmp(stimulus.soundType, 'phonemeWav') %files specified in getClip-just need to indicate sad/dad
[lefts, rights] = getBalance(responsePorts,targetPorts);

%default case (e.g. rights==lefts )

if lefts>rights %choose a left stim (wav1)
    details.toneFreq = 1;
elseif rights>lefts %choose a right stim (wav2)
    details.toneFreq = 0;
end
if lefts == rights %left
    details.toneFreq = 1;
end
end

details.rightAmplitude = stimulus.amplitude;
details.leftAmplitude = stimulus.amplitude;

% fid=fopen('miketest.txt', 'a+t')
% fprintf(fid, '\nintensity discrim/calcstim: laserON=%d',details.laserON) 
% fclose(fid)
switch stimulus.soundType
    case {'allOctaves','tritones'}
        sSound = soundClip('stimSoundBase','allOctaves',[stimulus.freq],20000);
    case {'binaryWhiteNoise','gaussianWhiteNoise','uniformWhiteNoise','empty'}
        sSound = soundClip('stimSoundBase',stimulus.soundType);
    case {'wmReadWav'}
        sSound = soundClip('stimSoundBase','wmReadWav', [details.toneFreq]);
    case {'phonemeWav'}
        sSound = soundClip('stimSoundBase','phonemeWav', [details.toneFreq]);
end
stimulus.stimSound = soundClip('stimSound','dualChannel',{sSound,details.leftAmplitude},{sSound,details.rightAmplitude});

%do not want this line when laser enabled!
%parameterize it as "multi" and "reinforce"?
%make sure to figure out the falsed out stuff in getSoundsToPlay
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