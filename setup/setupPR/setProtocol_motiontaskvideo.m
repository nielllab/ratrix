function r=setProtocolPR(r,ratIDs)
% just the tasks needed to make nice movies

% sound manager used by many training steps
sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});

%create scheduer used by all trial managers
sch=noTimeOff(); % return to previous scheduler

%create criterion used by nAFC trial managers
pc=performanceCriterion([0.85, 0.8],int16([200, 500]));

% constants used by many training steps
msPenaltyEARLY          =500; %SHORT for movie
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
rewardSizeULorMS        =10; % 
msRewardSoundDuration   =200; % 
requestRewardSizeULorMS=1; % 
percentCorrectionTrials=0; % OFF for movie
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;
msFlushDuration=10;
scalar=1; % note there will be ramping per correct in row.

%params of reinforcement manager
rewardSizeULorMS        =50;
fractionSoundOn        = 1;
fractionPenaltySoundOn = 1;
rewardScalar =1;

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

%% EASY
discrimStimPsych = coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [0.85], 1, 3, 10, 85, [6 6]);
ts_standard = trainingStep(tmEARLY, discrimStimPsych, pc,sch);

%% vary coherence is same one used in visionBattery ts10
discrimStimPsych = coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [0.2 0.9], 1, 3, 10, 85, [6 6]);
ts_vary_coherence = trainingStep(tmEARLY, discrimStimPsych, pc,sch);

%% vary_size  
coh=0.85; speed=1; size=[.1 3];
discrimStimPsych = coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, coh, speed, size, 10, 85, [6 6]);
ts_vary_size = trainingStep(tmEARLY, discrimStimPsych, pc,sch);

%%% vary_speed  
coh=0.85; speed=[.5 5]; size=3;
discrimStimPsych = coherentDots(stimulus,trialManagerClass,frameRate,...
    responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, coh, speed, size, 10, 85, [6 6]);
ts_vary_speed = trainingStep(tmEARLY, discrimStimPsych, pc,sch);

% 
p=protocol('motiondemo',{ts_standard, ts_vary_coherence, ts_vary_size, ts_vary_speed}); 

for i=1:length(ratIDs) 
    subjObj = getSubjectFromID(r,ratIDs{i});
    if ismember(ratIDs{i},{'195','196','demo1'}) % list rats here   
        stepNum=1; % 
        [subjObj r]=setProtocolAndStep(subjObj,p,1,0,1,stepNum,r,'motion psychometrics','pr');
    else
        error('unexpected ID')
    end
end
