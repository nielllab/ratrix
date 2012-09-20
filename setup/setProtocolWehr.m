function r = setProtocolWehr(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeIntensityDiscrimSoundManager();

rewardSizeULorMS          =80;
requestRewardSizeULorMS   =80;
requestMode               ='first';
msPenalty                 =1000;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;

constantRewards=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

allowRepeats=false;
freeDrinkLikelihood=0.004; %p per frame
fd = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,constantRewards);

freeDrinkLikelihood=0;
fd2 = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,constantRewards);

percentCorrectionTrials=.5;

maxWidth               = 1920;
maxHeight              = 1080;
interTrialLuminance = .5;
scaleFactor = 0;

[w,h]=rat(maxWidth/maxHeight);

eyeController=[];

dropFrames=false;
nafcTM=nAFC(sm,percentCorrectionTrials,constantRewards,eyeController,{'off'},dropFrames,'ptb','center');
% 
% textureSize=10*[w,h];
% zoom=[maxWidth maxHeight]./textureSize;
% 
% pixPerCycs              =[100];
% targetOrientations      =[pi/4];
% distractorOrientations  =[];
% mean                    =.5;
% radius                  =.085;
% contrast                =1;
% thresh                  =.00005;
% yPosPct                 =.65;
% scaleFactor            = 0; %[1 1];
% interTrialLuminance     =.5;
% freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

%stim params for free drinks
soundParams.soundType='uniformWhiteNoise';
soundParams.freq = [];
soundParams.duration=50; %ms
maxSPL=80; %measured max level attainable by speakers; in reality, seems to be 67.5dB at head, 74.6dB 1" from earbuds
ampsdB=40:5:maxSPL; %requested amps in dB
amplitudes=10.^((ampsdB -maxSPL)/20); %amplitudes = line level, 0 to 1
soundParams.amps = amplitudes; %for intensityDisrim
discrimBoundarydB=mean(ampsdB);
discrimBoundary=10.^((discrimBoundarydB -maxSPL)/20);
soundParams.discrimBoundary=discrimBoundary; %classification boundary for use by calcStim
soundParams.discrimSide=1; %boolean. if true, stimuli < classification boundary go to left
intensityStim = intensityDiscrim(interTrialLuminance,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

%EZ intensityStim is 50 80
%intensityStim is 40:5:80
%Hard intensityStim is  50 55 57 59 60 61 63 65 70 
 

EZampsdB=[50 80];
EZamplitudes=10.^((EZampsdB -maxSPL)/20); %amplitudes = line level, 0 to 1
EZsoundParams=soundParams;
EZsoundParams.amps = EZamplitudes; %for intensityDisrim
EZintensityStim = intensityDiscrim(interTrialLuminance,EZsoundParams,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

HardampsdB=[50 55 57 59 60 61 63 65 70];
Hardamplitudes=10.^((HardampsdB -maxSPL)/20); %amplitudes = line level, 0 to 1
HardsoundParams=soundParams;
HardsoundParams.amps = Hardamplitudes; %for intensityDisrim
HardintensityStim = intensityDiscrim(interTrialLuminance,HardsoundParams,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

requestRewardSizeULorMS = 0;
msPenalty               = 1000;
noRequest=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
nrTM=nAFC(sm,percentCorrectionTrials,noRequest,eyeController,{'off'},dropFrames,'ptb','center');

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';

trialsPerMinute = 7;
minutes = .5;
numTriggers = 20;
ts1 = trainingStep(fd,  EZintensityStim, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %stochastic free drinks
ts2 = trainingStep(fd2, EZintensityStim, numTrialsDoneCriterion(numTriggers)   , noTimeOff(), svnRev,svnCheckMode);  %free drinks

%nafc
trialsPerMinute = 6;
minutes = 1;
ts3 = trainingStep(nafcTM, EZintensityStim, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %side discrim

%no request reward
ts4 = trainingStep(nrTM  , EZintensityStim,  numTrialsDoneCriterion(400)          , noTimeOff(), svnRev,svnCheckMode);

%long penalty
msPenalty = 3000;
longPenalty=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
lpTM=nAFC(sm,percentCorrectionTrials,longPenalty,eyeController,{'off'},dropFrames,'ptb','center',[],[],[]);
ts5 = trainingStep(lpTM  , EZintensityStim, performanceCriterion(.85, int8(200)), noTimeOff(), svnRev,svnCheckMode);

ts6 = trainingStep(lpTM  , intensityStim, performanceCriterion(.85, int8(200)), noTimeOff(), svnRev,svnCheckMode);

ts7 = trainingStep(lpTM  , HardintensityStim, repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode);


%p=protocol('mouse intensity discrimation',{ ts3, ts4, ts5});
p=protocol('mouse intensity discrimation',{ts1, ts2, ts3, ts4, ts5 ts6 ts7});

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    
    switch subjIDs{i}
        case 'test'
            stepNum=uint8(1);
        otherwise
            stepNum=uint8(6);
    end
    
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolWehr','edf');
end