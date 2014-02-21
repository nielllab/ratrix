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
    case 'nAFC'
        type='loop';%int32([10 10]); % This is 'timedFrames'
    otherwise
        error('unknown trial manager class')
end


details.toneFreq = stimulus.freqs;
details.numTones=1;

details.isi=RandSample(stimulus.isi); %randomly chooses an isi from the possibilities (1 or more)


%override total stimulus duration
stimulus.duration=(details.numTones+1)*(stimulus.toneDuration+details.isi)-details.isi;



% pick a random starting tone and then update stimulus.startfreq to the next value

if details.correctionTrial==0 %randomly decide stimuli if not a correction trial
    %if it is a correction trial, assignports determines the stimuli

    
    
    
stim=RandSample(1:5); %this chooses stimuli randomly, with Tone/Tone given 40% weight (other 3 are each 20%)

if stim==1 || stim==2
    details.startTone=0;
    details.endTone=0;
    targetPorts=3;
    distractorPorts=1;
end
if stim==3
    details.startTone=0;
    details.endTone=1;   
    targetPorts=1;
    distractorPorts=3;
end

if stim==4
    details.startTone=1;
    details.endTone=0;
    targetPorts=1;
    distractorPorts=3;
end
        
if stim==5
    details.startTone=1;
    details.endTone=1; 
    targetPorts=3;
    distractorPorts=1;
end

    
end


% details.startTone = RandSample(0:1); %below is original determination of stimuli 
% 
% x = [1 0];
% 
%     
% [lefts, rights] = getBalance(responsePorts,targetPorts);
% 
% 
% if lefts>rights %choose a left stim (change)
%     details.endTone = x(details.startTone+1);
% elseif rights>lefts %choose a right stim (no change)
%     details.endTone = details.startTone;
% end
% 
% if lefts == rights
%     details.endTone = x(details.startTone+1);
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
    case {'wmToneWN'}
        sSound = soundClip('stimSoundBase','wmToneWN',[details.startTone details.endTone details.toneFreq details.isi stimulus.toneDuration]) ;
    case {'warblestackWav'} %reads files-currently specified in getClip
        details.toneFreq = 1;
        sSound = soundClip('stimSoundBase','warblestackWav',[details.startTone details.endTone details.toneFreq stimulus.isi stimulus.toneDuration]) ;
end

mycorrectSound=soundClip('stimSoundBase','empty');
mykeepGoingSound=soundClip('stimSoundBase','empty');

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