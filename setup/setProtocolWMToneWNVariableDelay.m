function r = setProtocolWMToneWNVariableDelay(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end


sm=makeWMSoundManager(); 

rewardSizeULorMS          =80;
requestRewardSizeULorMS   =80;
requestMode               ='first';
msPenalty                 =1000;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =0;
responseLockoutMs = 0;        

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


pixPerCycs              =[100];
targetOrientations      =[pi/4];
distractorOrientations  =[];
mean                    =.5;
radius                  =.085;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65;
scaleFactor            = 0; %[1 1];
interTrialLuminance     =.5;
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[w,h]=rat(maxWidth/maxHeight);

eyeController=[];

dropFrames=false;

nafcTM=nAFC(sm,percentCorrectionTrials,constantRewards,eyeController,{'off'},dropFrames,'ptb','center');

%stim params for free drinks
soundParams.soundType='wmToneWN'; %soundType that creates tones and WN with an isi
soundParams.freqs = [8000]; %tone frequency
soundParams.duration=[]; %ms, total duration of stimSound-calculated in calcstim
soundParams.isi=[0 125 250 500 1000]; %ms, time between tones - can vary in this protocol
soundParams.toneDuration=250; %ms, duration of each tone 


maxSPL=80; %measured max level attainable by speakers
ampdB=60; %requested amps in dB
amplitude=10.^((ampdB -maxSPL)/20); %amplitudes = line level, 0 to 1
soundParams.amp = amplitude; %for intensityDiscrim

StimEZ = audWM(interTrialLuminance,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLuminance);



StimMedium = audWM(interTrialLuminance,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLuminance);




StimHard =audWM(interTrialLuminance,soundParams,maxWidth,maxHeight,scaleFactor,interTrialLuminance);



svnRev={'svn://132.239.158.177/projects/ratrix/AWM'};
svnCheckMode='session';

trialsPerMinute = 7;
minutes = .5;
numTriggers = 20;

ts1 = trainingStep(fd,  freeStim, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %stochastic free drinks
ts2 = trainingStep(fd2, freeStim, numTrialsDoneCriterion(numTriggers)   , noTimeOff(), svnRev,svnCheckMode);  %free drinks
ts3 = trainingStep(nafcTM, StimEZ, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);


requestRewardSizeULorMS = 0;
msPenalty               = 1000;
noRequest=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
nrTM=nAFC(sm,percentCorrectionTrials,noRequest,eyeController,{'off'},dropFrames,'ptb','center');



ts4 = trainingStep(nrTM  , StimEZ,  performanceCriterion(.85, int8(200))       , noTimeOff(), svnRev,svnCheckMode);

msPenalty = 3000;
longPenalty=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
lpTM=nAFC(sm,percentCorrectionTrials,longPenalty,eyeController,{'off'},dropFrames,'ptb','center',[],[],[]);

ts5 = trainingStep(lpTM  , StimMedium, repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode);

ts6 = trainingStep(lpTM  , StimHard, performanceCriterion(.85, int8(200)), noTimeOff(), svnRev,svnCheckMode);

%p=protocol('mouse CNM task',{ts1, ts2, ts3, ts4, ts5 ts6}); %normal setup
p=protocol('mouse WM task WN vs tone VD',{ts1, ts2, ts3, ts4, ts5 ts6}); %to test CNM/goNoGo

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    
    switch subjIDs{i}
        case 'test'
            stepNum=uint8(1);
        otherwise
            stepNum=uint8(1);
    end
    
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolWMToneWN','edf');
end