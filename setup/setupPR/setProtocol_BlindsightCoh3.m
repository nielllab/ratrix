function setProtocolPR(ratIDs)
Cohort3A={'307','308','demo1'}; % motion first
Cohort3B={'309','310'};  %  orientation first
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% note protocol changes from cohort1:
% split cohort into two groups who do steps in different order
% set scheduler to timed, 120min because notimeoff was being overridden
% more trials before graduating
% fixed timeout at 5sec (eliminate mid and late versions of reward manager)
% fixed unintended stim during free drinks
%
% note additional changes from cohort2: 12/15/08
% all rats training in box now
% explicitly construct dot stimuli (don't use makeRandomDot)
% add psychometric orientation step
% add review step before psychometrics
% remove annoying chord during psychometrics (too many invisible stimuli)
% reduce penalty sound duration (not tested)

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
sch=minutesPerSession(120,3); % sch=noTimeOff();

%create criterion used by nAFC trial managers
pc=performanceCriterion([0.85, 0.8],int16([300, 600])); % more trials before grad

% constants used by many training steps
msPenaltyEARLY          =5000; % 
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
fractionPenaltySoundOn = 0.1; % 12/15 - only 500ms chord for 5 sec timeout.
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
increasingRewardEARLY=rewardNcorrectInARow([50, 100, 200],msPenaltyEARLY,1,1, scalar); %[20 80 100 150 250] is what philip uses ..

%traial managers for NAFC trial managers
tmEARLY=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,increasingRewardEARLY);

% suppress annoying chord for psychometric tasks with many impossible
% stimuli
tmQUIET=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,smSTOCH,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,increasingRewardEARLY);

%%%%%%%%%%%%%%
% DEFINE ALL TRAINING STEPS HERE %
%%% fd_ts1 = free drinks with stochastic untriggered events %%%
%create reinforcement manager object
reinfmanager = constantReinforcement(rewardSizeULorMS,msPenaltyFD,...
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar);
%create free drinks object (trial manager) 
fd1 = freeDrinks(msFlushDuration, msMinimumPokeDuration,...
    msMinimumClearDuration,smSTOCH, stoch_freeDrinkLikelihood, reinfmanager);
%stim manager
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,FDcontrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
%training step
fd_ts1 = trainingStep(fd1, freeStim, rateCriterion(5,2),sch);

%%% fd_ts2 = earned drinks must trigger and move between ports %%%
%trial manager change one param
fd2 = freeDrinks(msFlushDuration, msMinimumPokeDuration,...
    msMinimumClearDuration,smSTOCH, earned_freeDrinkLikelihood, reinfmanager);
%stim manager same as ts1
%training step
fd_ts2 = trainingStep(fd2, freeStim, rateCriterion(6,3),sch);

%%% motion1 = coherent dots 85% coherence only
%motion1=makeDotTrainingStep(0.85); % default trial manager, criterion, scheduler, and randoom dot stim manager
coherence=[0.85];
discrimStim1= coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, coherence, 1, 3, 10, 85, [6 6]);
motion1 = trainingStep(tmEARLY, discrimStim1, pc,sch);

%%% motion2 = coherent dots, harder
%motion2 = makeDotTrainingStep([0.5 0.99]); % 70% threshold is ~0.6?
coherence=[0.5 0.99];
discrimStim2= coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, coherence, 1, 3, 10, 85, [6 6]);
motion2 = trainingStep(tmEARLY, discrimStim2, pc,sch);

%%% motion3  = coherent dots psychometric curve  
% many are below threshold!
discrimStimPsych = coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [0.2 0.9], 1, 3, 10, 85, [6 6]);
motion3 = trainingStep(tmQUIET, discrimStimPsych, pc,sch);

%%% orient1 = go to side, for orientation task 
distractorOrientations=[]; % no distractor
goToSide = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod);
orient1 = trainingStep(tmEARLY, goToSide, pc, sch);

%%% orient2  = go to HORIZ, for orientation task 
%stim manager
distractorOrientations=[0]; % always vertical
goToHor = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,...
    mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod)
orient2 = trainingStep(tmEARLY, goToHor, pc, sch);

%%% orient3 = psychometric curve for spatial frequency, reduce contrast
%stim manager
distractorOrientations=[0]; % always vertical
pixPerCycSWEEP = [4 8 16 32 64 128]; % TO DO verify that aperture is constant size
locontr=0.75; % slightly more sensitive range than 100% contrast
goToHorSF = orientedGabors(pixPerCycSWEEP,targetOrientations,distractorOrientations,...
    mean,radius,locontr,thresh,yPosPct,width,height,scaleFactor,...
    interTrialLuminance,waveform,normalizedSizeMethod)
% training step
orient3 = trainingStep(tmQUIET, goToHorSF, pc, sch);

% still to build: contrast sweep for orientation; size, speed, contrast
% sweep for dots; image recognition.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFINE ALL PROTOCOLS HERE %
% NOTE half of rats get orientation first, half get motion first!
%% possible steps = fd_ts1 fd_ts2 motion1  motion2 motion3 orient1 orient2 orient3 

pA=protocol('mixedbattery2A',{fd_ts1 fd_ts2 motion1  motion2 orient1 orient2 orient3 motion2 motion3}); 
pB=protocol('mixedbattery2B',{fd_ts1 fd_ts2 orient1 orient2 motion1  motion2 motion3 orient2 orient3}); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

logPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrix\setup\setupPR',filesep);
cd(logPath)
fid=fopen('cohort3log.txt','a');
for i=1:length(ratIDs)
    subjObj = getSubjectFromID(r,ratIDs{i});
    stepNum=1; % initialize these rats 12/15
    if ismember(ratIDs{i},Cohort3A) % define rat ID list at top of this file
        [subjObj r]=setProtocolAndStep(subjObj,pA,1,1,1,stepNum,r,'pre-lesion training','pr');
    elseif ismember(ratIDs{i},Cohort3B) % define rat ID list at top of this file
        [subjObj r]=setProtocolAndStep(subjObj,pB,1,1,1,stepNum,r,'pre-lesion training','pr');
    else
        error('unexpected ID')
    end

end
fclose(fid)

