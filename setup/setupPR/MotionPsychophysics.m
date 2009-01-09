function setProtocolPR(ratIDs)
% for rats already trained in the random dot motion task,
% sweep over different stim params to get thresholds.

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file

% sound manager used by many training steps
sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});

%create sound manager object used by stochastic free drinks only
% no hissing sound when water clogs ports
smSTOCH=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','allOctaves',[],2000), ...
    soundClip('wrongSound','allOctaves',[],20000)}); %SILENCE

%create scheduer used by all trial managers
sch=noTimeOff(); % return to previous scheduler

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
percentCorrectionTrials=.25; %% NOTE set lower than usual
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
width=1024;
height=768;

% params used by coherent dots
stimulus = coherentDots;
trialManagerClass='nAFC';
frameRate=100;
responsePorts=[1,3];
totalPorts=3;
maxWidth = 100;
maxHeight = 100;

%%reward managers for NAFC trial managers
% make penalties longer and reward volumes smaller as training proceeds
increasingRewardEARLY=rewardNcorrectInARow([50, 100, 200],msPenaltyEARLY,1,1, scalar); %[20 80 100 150 250] is what philip uses ..
increasingRewardMID=rewardNcorrectInARow([25, 50, 100, 200],msPenaltyMID,1,1, scalar); %[20 80 100 150 250] is what philip uses ..
increasingRewardLATE=rewardNcorrectInARow([20, 80, 100, 150, 250],msPenaltyLATE,1,1, scalar); %[20 80 100 150 250] is what philip uses ..

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


%%% ts1 = earned drinks must trigger and move between ports %%%
reinfmanager = constantReinforcement(rewardSizeULorMS,msPenaltyFD,...
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar);
% stim manager
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,FDcontrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
%trial manager
fd = freeDrinks(msFlushDuration, msMinimumPokeDuration,...
    msMinimumClearDuration,smSTOCH, earned_freeDrinkLikelihood, reinfmanager);
%training step
ts1 = trainingStep(fd, freeStim, rateCriterion(6,3),sch);

%%% TS2 = coherent dots 85% coherence only
ts2=makeDotTrainingStep(0.85); % default trial manager, criterion, scheduler, and randoom dot stim manager)

%%% TS3 = coherent dots, harder by smaller dot SIZE
ts3 = makeDotTrainingStepSMALL(0.85);

%%% TS4 = coherent dots, harder by faster SPEED
ts4 = makeDotTrainingStepFAST(0.85)

%%% NOTE what I want is to get psychometric curves by randomizing over size
%%% or speed or contrast instead of randomizing coherence, but this needs
%%% to be added to the coherent dots stimulus manager 
%ADDED 12/4/08 AFTER UPGRADES BY FLI TO STIMMGR%
%%% vary_size  
coh=0.85; speed=1; size=[1 3];
vary_size = makeDotTrainingStepParametric(coh,speed,size);

%%% vary_speed  
coh=0.85; speed=[.5 5]; size=3;
vary_speed = makeDotTrainingStepParametric(coh,speed,size);

%%% vary_everything NOTE contrast not variable on rack1TEMP version of code
coh=[0.2 0.9]; speed=[.5 5]; size=[1 3]; % not sure what fraction are doable
vary_everything = makeDotTrainingStepParametric(coh,speed,size);

%vary_everything_hard choose harder parameters
coh=[0.2 0.9]; speed=[.1 10]; size=[.1 1];  
vary_everything_hard = makeDotTrainingStepParametric(coh,speed,size);

% note I ADDED more steps but the original 1-4 are unchanged
p=protocol('motionpsychometrics',{ts1, ts2, ts3,ts4, vary_size, vary_speed, vary_everything}); 
ptest=protocol('testing',{vary_everything_hard});


for i=1:length(ratIDs) 
    subjObj = getSubjectFromID(r,ratIDs{i});
    if ismember(ratIDs{i},{'195','196'}) % list rats here
        % persist previous training step, 
        % defaults to step=1 if no previous training records found
        % stepNum = getLastTrainingStep(ratIDs{i},getPermanentStorePath(r));
        
        stepNum=5; % graduate this rat to the new step 5
        [subjObj r]=setProtocolAndStep(subjObj,p,1,0,1,stepNum,r,'motion psychometrics','pr');
    elseif if ismember(ratIDs{i},{'demo1'}),
            stepNum=1; 
             [subjObj r]=setProtocolAndStep(subjObj,ptest,1,0,1,stepNum,r,'motion psychometrics','pr');
    else
        error('unexpected ID')
    end
end
