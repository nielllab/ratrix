% Usage: 
% setProtocolDFP('female room',{'173','174','175','176'})
% setProtocolDFP('male room',{'225','226','239','240','241','242'})
function setProtocolDFP(room,ids)

% Check that the subjects are valid
for i=1:length(ids)
    ratID=ids{i};
    if strcmp(room,'male room')
        if ~any(strcmp(ratID,{'223','224','225','226','239','240','241','242'}))
            error('not a female rat owned by dan')
        end
    elseif strcmp(room,'female room')
        if ~any(strcmp(ratID,{'173','174','175','176'}))
            error('not a male rat owned by dan')
        end
    end
end

% Load the existing ratrix
dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file


% Create a reinforcement manager
rewardSizeULorMS        =50;
msPenalty               =1000;
fractionOpenTimeSoundIsOn = 1.0;
fractionPenaltySoundIsOn = 1.0;
scalar = 1.0;
% thisSessionIsCached = 0; %pmm removed
fdReinforcementManager=constantReinforcement(rewardSizeULorMS,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar);

rewardSizeULorMS        =200;
afcReinforcementManager=constantReinforcement(rewardSizeULorMS,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar);

% Create a sound manager
sm=makeStandardSoundManager();

msFlushDuration         =1000;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;

% Create a stochastic free drinks trial manager
freeDrinkLikelihood=0.003;
fdStochastic = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood, fdReinforcementManager);

% Create a standard free drinks trial manager
freeDrinkLikelihood=0;
fd = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood, fdReinforcementManager);


requestRewardSizeULorMS=0;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;

% Create a standard nAFC trial manager
vh=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,afcReinforcementManager);

pixPerCycs              =[20];
targetContrasts         =[0.8];
distractorContrasts     =[];
fieldWidthPct           = 0.2;
fieldHeightPct          = 0.2;
mean                    =.5;
stddev                  =.04; % Only used for Gaussian Flicker
thresh                  =.00005;
flickerType             =0; % 0 - Binary Flicker; 1 - Gaussian Flicker
yPosPct                 =.65;
maxWidth                =1024;
maxHeight               =768;
scaleFactor             =[1 1];
interTrialLuminance     =.5;

soundFreq = 200; % Sound frequency to use in hz

freeDrinksStim = hemifieldFlicker(pixPerCycs,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

hemiFieldStim = hemifieldFlicker(pixPerCycs,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

soundAmp = [0 0.4]; % For now bias completely in one direction
stereoStim = stereoDiscrim(mean,soundFreq,soundAmp,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

% distractorContrasts  =[0.4]; % Add a distractor target
% hemiFieldDistractorStim = hemifieldFlicker(pixPerCycs,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
% 
% soundAmp = [0.1 0.4]; % Add a distractor sound
% stereoDistractorStim = stereoDiscrim(mean,soundFreq,soundAmp,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

switchType              = 'ByNumberOfHoursRun';
switchParameter         = 15;
switchMethod            = 'Random';
blockingLength          = 50;
currentModality         = []; % Default
crossModalStim = crossModal(switchType,switchParameter,switchMethod,blockingLength,currentModality,pixPerCycs,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,soundFreq,soundAmp,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


% Rate Criterion () = (trialsPerMin,consecutiveMins)
rateCrit = rateCriterion(10,5);
% 85% Performance on 250 trials or 95% on 125 trials
perfCrit = performanceCriterion([.95, .85], [int32(125),int32(250)]);
% 85% Performance on 200 trials
perfAlternateCrit = performanceCriterion([.85], [int32(200)]);

% Protocol

% % Visual Free Drinks (Stochastic First)
% ts1 = trainingStep(fdStochastic, freeDrinksStim, perfCrit, noTimeOff());
% ts2 = trainingStep(fd, freeDrinksStim, rateCrit, noTimeOff());
% % Hemifield Flicker
% ts3 = trainingStep(vh, hemiFieldStim, perfCrit, noTimeOff()); 
% % Hemifield Flicker with small distractor
% ts4 = trainingStep(vh, hemiFieldDistractorStim, perfCrit, noTimeOff());
% % Auditory Discrimination
% ts5 = trainingStep(vh, stereoStim, perfCrit, noTimeOff());
% % Auditory Discrimination with small distractor
% ts6 = trainingStep(vh, stereoDistractorStim, perfCrit, noTimeOff());
% % Go back and forth between Auditory with distractor and Hemifield with distractor
% ts7 = trainingStep(vh, hemiFieldDistractorStim, perfAlternateCrit, noTimeOff());
% ts8 = trainingStep(vh, stereoDistractorStim, perfAlternateCrit, noTimeOff());
% ts9 = trainingStep(vh, hemiFieldDistractorStim, perfAlternateCrit, noTimeOff());
% ts10 = trainingStep(vh, stereoDistractorStim, perfAlternateCrit, noTimeOff());
% ts11 = trainingStep(vh, hemiFieldDistractorStim, perfAlternateCrit, noTimeOff());
% ts12 = trainingStep(vh, stereoDistractorStim, perfAlternateCrit, noTimeOff());
% % Cross modal stimulus
% ts13 = trainingStep(vh, crossModalStim, repeatIndefinitely(), noTimeOff());

% Visual Free Drinks (Stochastic First)
ts1 = trainingStep(fdStochastic, freeDrinksStim, perfCrit, noTimeOff());
ts2 = trainingStep(fd, freeDrinksStim, rateCrit, noTimeOff());
% Hemifield Flicker
ts3 = trainingStep(vh, hemiFieldStim, perfCrit, noTimeOff()); 
% Hemifield Flicker with small distractor
% Auditory Discrimination
ts4 = trainingStep(vh, stereoStim, perfCrit, noTimeOff());
% Auditory Discrimination with small distractor
% Go back and forth between Auditory with distractor and Hemifield with distractor
ts5 = trainingStep(vh, hemiFieldStim, perfAlternateCrit, noTimeOff());
ts6 = trainingStep(vh, stereoStim, perfAlternateCrit, noTimeOff());
ts7 = trainingStep(vh, hemiFieldStim, perfAlternateCrit, noTimeOff());
ts8 = trainingStep(vh, stereoStim, perfAlternateCrit, noTimeOff());
ts9 = trainingStep(vh, hemiFieldStim, perfAlternateCrit, noTimeOff());
ts10 = trainingStep(vh, stereoStim, perfAlternateCrit, noTimeOff());
% Cross modal stimulus
ts11 = trainingStep(vh, crossModalStim, repeatIndefinitely(), noTimeOff());


p=protocol('stereo/visual crossmodal 6/20/2008',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8, ts9, ts10, ts11});


for i=1:length(ids)
    ratID=ids{i};
    s = getSubjectFromID(r,ratID);
    stepNum = getLastTrainingStep(ratID,getPermanentStorePath(r));
    [s r]=setProtocolAndStep(s,p,1,0,1,stepNum,r,'Putting rat on stereo discrim','dfp');
end
