function r = setProtocolPR(r, ratIDs)
% this protocol is for training cohort 1 for LGN lesions 080813
% goal is to pretrain in motion discrim and orientation discrim between msRewardSoundDurationp30
% and p90 prior to lesion. Desirable to also train object recognition and
% sound discrimination but not certain if these run on male ratrix right
% now.

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

% sound manager used by many training steps
sm=makeStandardSoundManager();

%create sound manager object used by stochastic free drinks only
% no hissing sound when water clogs ports
smSTOCH=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','allOctaves',[],2000), ...
    soundClip('wrongSound','allOctaves',[],20000)}); %SILENCE

%create scheduer used by all trial managers
scheduler=noTimeOff(); %runs trials until rat logged off

%create criterion used by nAFC trial managers
pc=performanceCriterion([0.85, 0.8],int16([200, 500]));

% constants used by many training steps
msPenaltyEARLY          =2000; % penalty was 0 in previous cohort!
msPenaltyMID            =4000;
msPenaltyLATE           =8000;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
rewardSizeULorMS        =10; % for free drinks only
msRewardSoundDuration   =200; % for free drinks only
requestRewardSizeULorMS=1; % was 10 in previous cohort
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;
msFlushDuration=10;
scalar=1; % note there will be ramping per correct in row.

%params of freedrinks trial manager only
msPenaltyFD              =0; %no penalty during free drinks
stoch_freeDrinkLikelihood=0.006; %ts1 stochastic water emitted without licks
earned_freeDrinkLikelihood=0; % ts2 lick required

%params of reinforcement manager
rewardSizeULorMS        =50;
fractionSoundOn        = 1;
fractionPenaltySoundOn = 1;
rewardScalar =1;


% params used by orientation discrimtask AND free drinks
pixPerCycs              =[64];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =1/8;
contrast                =1;
FDcontrast                =0;%%% all stimuli invisible for free drinks
thresh                  =.00005;
yPosPct                 =.65;
scaleFactor             =[1 1];
interTrialLuminance     =.5;
waveform='square';
normalizedSizeMethod='normalizeVertical';

% params used by coherent dots
stimulus = coherentDots;
trialManagerClass='nAFC';
frameRate=100;
responsePorts=[1,3];
totalPorts=3;
width=1024;
height=768;
maxWidth = 100;
maxHeight = 100;

%%reward managers for NAFC trial managers
% make penalties longer and reward volumes smaller as training proceeds
increasingRewardEARLY=rewardNcorrectInARow([50 100 200],msPenaltyEARLY,1,1, scalar); %[20 80 100 150 250] is what philip uses ..
increasingRewardMID=rewardNcorrectInARow([25 50 100 200],msPenaltyMID,1,1, scalar); %[20 80 100 150 250] is what philip uses ..
increasingRewardLATE=rewardNcorrectInARow([20 80 100 150 250],msPenaltyLATE,1,1, scalar); %[20 80 100 150 250] is what philip uses ..

%traial managers for NAFC trial managers
tmEARLY=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,increasingRewardEARLY);
tmMID=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,increasingRewardMID);
tmLATE=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,increasingRewardLATE);
%%%%%%%%%%%%%%



%%% TS1 = free drinks with stochastic untriggered events %%%
% TRY THIS FROM OTHER CODE BASE
%create reinforcement manager object
reinfmanager = constantReinforcement(rewardSizeULorMS,msPenaltyFD,...
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar);
%create free drinks object (trial manager) 
fd1 = freeDrinks(msFlushDuration, msMinimumPokeDuration,...
    msMinimumClearDuration,smSTOCH, stoch_freeDrinkLikelihood, reinfmanager);
% fd1 = freeDrinks(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,...
%     msMinimumClearDuration,sm,msPenaltyEARLY,msRewardSoundDuration,freeDrinkLikelihood);

%stim manager
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
%training step
ts1 = trainingStep(fd1, freeStim, rateCriterion(5,2),scheduler);

%%% TS2 = earned drinks must trigger and move between ports %%%
%trial manager change one param
freeDrinkLikelihood=0;
fd2 = freeDrinks(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,...
    msMinimumClearDuration,sm,msPenalty,msRewardSoundDuration,freeDrinkLikelihood);
%stim manager same as ts1
%training step
ts2 = trainingStep(fd2, freeStim, rateCriterion(6,3),scheduler);

%%% TS3 = coherent dots 85% coherence only
discrimStim = coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, .85, 1, 3, 10, 85, [6 6]);
ts3 = trainingStep(tmEARLY, discrimStim, pc,scheduler);

%%% TS4 = coherent dots 85% coherence only, MED stringency
ts4 = trainingStep(tmMID, discrimStim, pc,scheduler);

%%% TS5 = go to side, for orientation task, EASY stringency
%stim manager
goToSide = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod);
ts5 = trainingStep(tmEARLY, goToSide, pc, scheduler);

%%% TS6 = go to HORIZ, for orientation task, EASY stringency
%stim manager
distractorOrientations=[0];
goToHor = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod)
% training step
ts6 = trainingStep(tmEARLY, goToHor, pc, scheduler);

%%% TS7 = go to HORIZ, for orientation task, MED stringency
ts7 = trainingStep(tmMID, goToHor, pc, scheduler);

%%% TS8 = go to HORIZ, for orientation task, HARD stringency  
ts8 = trainingStep(tmLATE, goToHor, pc, scheduler);

%%% TS9 = coherent dots 85% coherence only, MED stringency
ts8 = trainingStep(tmMID, discrimStim, pc,scheduler);

%%% TS10 = coherent dots psychometric curve  
% use EASY stringency because many are below threshold!
discrimStimPsych = coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [0.2 0.9], 1, 3, 10, 85, [6 6]);
ts10 = trainingStep(tmEARLY, discrimStimPsych, pc,scheduler);

%%%%%%%%%%%%%%%%%%%
% after this: psychometrics on orientation - by which parameter?
% object recognition - runs on male ratrix?
% go to sound - runs on male ratrix?

p=protocol('mixedbattery',{ts1, ts2, ts3,ts4,ts5,ts6,ts7,ts8, ts9, ts10});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE all rats are on same protocol at this point
for i=1:length(ratIDs) 
    subjObj = getSubjectFromID(r,ratIDs{i});
    stepNum=1;
    %stepNum = getLastTrainingStep(ratIDs{i},getPermanentStorePath(r));
    %%persist previous step
    if ismember(ratIDs{i},{'284','285','286','287','288','289','290', '291','demo1'}) % list the new rats here
        [subjObj r]=setProtocolAndStep(subjObj,p,1,0,1,stepNum,r,'pre-lesion vision battery','pr');
    else
        error('unexpected ID')
    end
end