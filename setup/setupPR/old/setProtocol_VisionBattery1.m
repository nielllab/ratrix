function setProtocolPR(ratIDs)
%debugged on rack1 directly
%
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
%scheduler=noTimeOff(); %runs trials until rat logged off WORKED for ts1&2
% 9/11/08 ts3 crashing unknown reasons; minutesPerSession didn't fix
%sch=minutesPerSession(120,3); % see if this fixes bug involving correctiontrial field invalid reference?
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

%%% TS1 = free drinks with stochastic untriggered events %%%
%create reinforcement manager object
reinfmanager = constantReinforcement(rewardSizeULorMS,msPenaltyFD,...
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar);
%create free drinks object (trial manager) 
fd1 = freeDrinks(msFlushDuration, msMinimumPokeDuration,...
    msMinimumClearDuration,smSTOCH, stoch_freeDrinkLikelihood, reinfmanager);
%stim manager
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
% this is from old training protocol, DOES NOT WORK
% fd1 = freeDrinks(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,...
%     msMinimumClearDuration,sm,msPenaltyEARLY,msRewardSoundDuration,stoch_freeDrinkLikelihood);

%training step
ts1 = trainingStep(fd1, freeStim, rateCriterion(5,2),sch);

%%% TS2 = earned drinks must trigger and move between ports %%%
%trial manager change one param
fd2 = freeDrinks(msFlushDuration, msMinimumPokeDuration,...
    msMinimumClearDuration,smSTOCH, earned_freeDrinkLikelihood, reinfmanager);
%stim manager same as ts1
%training step
ts2 = trainingStep(fd2, freeStim, rateCriterion(6,3),sch);

%%% TS3 = coherent dots 85% coherence only
% CRASHES!!
% ts3 = trainingStep(tmEARLY, discrimStim, pc,minutesPerSession(90,3)); %sch); %  sch > minutesPerSession
% 9/17/08 try this
ts3=makeDotTrainingStep(0.85); % default trial manager, criterion, scheduler, and randoom dot stim manager)

%%% TS4 = coherent dots, harder
%trainingStep(tmMID, discrimStim, pc,sch); % 
ts4 = makeDotTrainingStep([0.75 0.89]); 

%%% TS5 = go to side, for orientation task, EASY stringency
%stim manager
goToSide = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod);
ts5 = trainingStep(tmEARLY, goToSide, pc, sch);

%%% TS6 = go to HORIZ, for orientation task, EASY stringency
%stim manager
distractorOrientations=[0];
goToHor = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod)
% training step
ts6 = trainingStep(tmEARLY, goToHor, pc, sch);

%%% TS7 = go to HORIZ, for orientation task, MED stringency
ts7 = trainingStep(tmMID, goToHor, pc, sch);

%%% TS8 = go to HORIZ, for orientation task, VARY orientations
%NOT PROG YET!!
% distractorOrientations=[0];
% goToHorPsych = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
%     mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
%     interTrialLuminance,waveform,normalizedSizeMethod)
% 
% ts8 = trainingStep(tmLATE, goToHor, pc, sch);

%%% TS9 = repeat ts4 to review
ts9 = ts4;

%%% TS10 = coherent dots psychometric curve  
% use EASY stringency because many are below threshold!
discrimStimPsych = coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [0.2 0.9], 1, 3, 10, 85, [6 6]);
ts10 = trainingStep(tmEARLY, discrimStimPsych, pc,sch);

%%%%%%%%%%%%%%%%%%%
% after this: psychometrics on orientation - by which parameter?
% object recognition - runs on male ratrix?
% go to sound - runs on male ratrix?

%9/17/08 move ts3 and ts4 to after orientation task 
%(need to debug coherent dots)
%p=protocol('mixedbattery',{ts1, ts2, ts5,ts6,ts7,ts8, ts3,ts4, ts9, ts10});
p=protocol('mixedbattery',{ts1, ts2, ts3,ts4, ts5,ts6,ts7, ts9, ts10}); % hold out ts8 not prog yet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE all rats are on same protocol  
for i=1:length(ratIDs) 
    subjObj = getSubjectFromID(r,ratIDs{i});
    if ismember(ratIDs{i},{'286', 'demo1'}), %{'284','285','286','287','288','289','290', '291','demo1'}) % list the new rats here
        % persist previous training step, 
        % defaults to step=1 if no previous training records found
        %stepNum = getLastTrainingStep(ratIDs{i},getPermanentStorePath(r));
        stepNum=5; %10/24/09 for rat286 only
        [subjObj r]=setProtocolAndStep(subjObj,p,1,0,1,stepNum,r,'pre-lesion vision battery','pr');
    elseif ismember(ratIDs{i},{'23','24','25','19','20','21', 'l',    'r',    's' ,   't' ,   'u'  , 'v'}) % TEST rats
        stepNum=2; % keep on a step that is easy for testing rigs
        [subjObj r]=setProtocolAndStep(subjObj,p,1,0,1,stepNum,r,'pre-lesion vision battery','pr');
    else
        error('unexpected ID')
    end
end
