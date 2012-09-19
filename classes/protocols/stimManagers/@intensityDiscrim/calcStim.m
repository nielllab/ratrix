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

%decide randomly if we issue a laser pulse on this trial or not
details.laserON = rand>0.9; %laser is on for 10% of trials
details.laser_duration=.5; %seconds
details.laser_start_time=Inf; 

[lefts, rights] = getBalance(responsePorts,targetPorts);

%default case (e.g. rights==lefts )
details.Amplitude=stimulus.discrimBoundary;

if details.laserON %randomly reward laserON trials, i.e. pick a random stimulus
    details.Amplitude=RandSample(stimulus.amplitudes);
else %laser is off, choose a stimulus that corresponds to the rewarded side
    if lefts>rights %choose a left stim
        if stimulus.discrimSide %boolean, sidedness of boundary (i.e. left==quiet)
            %mw9-19-12 added >= to include boundary
            details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes<=stimulus.discrimBoundary)));
        else
            details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes>stimulus.discrimBoundary)));
        end
    elseif rights>lefts %choose a right stim
        if stimulus.discrimSide
            details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes>=stimulus.discrimBoundary)));
        else
            details.Amplitude=RandSample(stimulus.amplitudes(find(stimulus.amplitudes<stimulus.discrimBoundary)));
        end
    end
end

details.rightAmplitude = details.Amplitude;
details.leftAmplitude = details.Amplitude;

% fid=fopen('miketest.txt', 'a+t')
% fprintf(fid, '\nintensity discrim/calcstim: laserON=%d',details.laserON) 
% fclose(fid)
switch stimulus.soundType
    case {'allOctaves','tritones'}
        sSound = soundClip('stimSoundBase','allOctaves',[stimulus.freq],20000);
    case {'binaryWhiteNoise','gaussianWhiteNoise','uniformWhiteNoise','empty'}
        sSound = soundClip('stimSoundBase',stimulus.soundType);
end
stimulus.stimSound = soundClip('stimSound','dualChannel',{sSound,details.leftAmplitude},{sSound,details.rightAmplitude});

%do not want this line when laser enabled!
%parameterize it as "multi" and "reinforce"?
%make sure to figure out the falsed out stuff in getSoundsToPlay
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

preResponseStim=discrimStim;
preResponseStim.punishResponses=false;