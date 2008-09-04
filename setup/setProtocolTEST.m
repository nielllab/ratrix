function r = setProtocolDEMO(r,subjIDs)

% ====================================================================================================================
% Complete list of reinforcement, stim, and trial managers tested:
%   REINFORCEMENT MANAGERS
%   constantReinforcement - works on merge
%   rewardNcorrectInARow - works on merge

%   STIM MANAGERS
%   orientedGabors - works on merge
%   images - works on merge
%   coherentDots - **DOES NOT work on merge
%   stereoDiscrim - **DOES NOT work on merge
%   hemifieldFlicker - **DOES NOT work on merge
%   crossModal - **DOES NOT work on merge

%   TRIAL MANAGERS
%   freeDrinks (stochastic) - works on merge
%   freeDrinks (nonstochastic) - works on merge
%   nAFC - works on merge

% ====================================================================================================================
% List of reinforcement, stim, and trial managers NOT tested:
%   REINFORCEMENT MANAGERS


%   STIM MANAGERS
%   cuedGoToFeatureWithTwoFlank
%   cuedIfFeatureGoRightWithTwoFlank
%   goToFeatureWithTwoFlank
%   ifFeatureGoRightWithTwoFlank
%   RomoBarMotionStimulus

%   TRIAL MANAGERS
%   ifFeatureGoRightWithTwoFlankTrialManager
%   promptedNAFC

% ====================================================================================================================
% error test initial
if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end
% ====================================================================================================================
% variables for reinforcement and trial managers
rewardSizeULorMS        =50;
msPenalty               =1000;
fractionOpenTimeSoundIsOn=1;
fractionPenaltySoundIsOn=1;
scalar=1;
msAirpuff=msPenalty;
msFlushDuration         =1000;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
requestRewardSizeULorMS=10;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;

freeDrinkLikelihood=0.003; % changes for stochastic/regular freeDrinks

% ====================================================================================================================
% soundManager
sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});

% ====================================================================================================================
% reinforcementManager
constantRewards=constantReinforcement(rewardSizeULorMS,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

increasingRewards=rewardNcorrectInARow([20,80,150,250,350,500,1000],msPenalty,1,1, scalar, msAirpuff); %[20 80 100 150 250] is what philip uses ..

% ====================================================================================================================
% trialManager
fd_sto = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood,constantRewards);

freeDrinkLikelihood=0;
fd = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood,constantRewards);

% freeDrinks (stochastic and nonstochastic) but with increasingRewards instead of constantRewards
freeDrinkLikelihood=0.003;
fd_sto_increasing_rewards = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood,increasingRewards);

freeDrinkLikelihood=0;
fd_increasing_rewards = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood,increasingRewards);

vh=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,constantRewards);

% uses rewardNcorrectInARow reinforcementManager, but same nAFC otherwise
nAFC_increasing_rewards =nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,increasingRewards);

%%%%%%%%%% go to stim - Balaji (same as Erik's go to side)
gts = nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,percentCorrectionTrials,...
    msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,constantRewards);



% ====================================================================================================================
% variables for stim managers
pixPerCycs              =[20];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =.04;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65;
%screen('resolutions') returns values too high for our NEC MultiSync FE992's -- it must just consult graphics card
maxWidth                =1024;
maxHeight               =768;
scaleFactor             =[1 1];
interTrialLuminance     =.5;



imageDir='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\other stimuli sets\paintbrush_flashlight';%'\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\other stimuli sets\paintbrushMORPHflashlightEDF';
background=0;
ypos=0;
ims=dir(fullfile(imageDir,'*.png'));
trialDistribution={};
for i=1:floor(length(ims)/2)
    [junk n1 junk junk]=fileparts(ims(i).name);
    [junk n2 junk junk]=fileparts(ims(length(ims)-(i-1)).name);
    trialDistribution{end+1}={{n1 n2} 1};
end

% ====================================================================================================================
% stimManager
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

pixPerCycs=[20 10];
distractorOrientations=[0];
discrimStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

imageStim = images(imageDir,ypos,background,maxWidth,maxHeight,scaleFactor,interTrialLuminance,trialDistribution);

% for Phil's stim managers
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
maxWidth                =800;
maxHeight               =600;
scaleFactor             =[1 1];
interTrialLuminance     =.5;
numCalcIndices          = 10000; % Number of indices for frames to calculate

% Phil - stereoDiscrim, hemifieldFlicker, and crossModal
freeVisualStim = hemifieldFlicker(numCalcIndices,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
freq = 200; % Sound frequency to use in hz
amplitudes = [0 1]; % For now bias completely in one direction
freeAudioStim = stereoDiscrim(mean,freq,amplitudes,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
discrimAudioStim = stereoDiscrim(mean,freq,amplitudes,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

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

discrimVisualStim = hemifieldFlicker(numCalcIndices,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

switchType              = 'ByNumberOfHoursRun';
switchParameter         = 15;
switchMethod            = 'Random';
blockingLength          = 50;
currentModality         = []; % Default

soundFreq = 200; % Sound frequency to use in hz
soundAmp = [0 0.4]; % For now bias completely in one direction
crossModalStim = crossModal(switchType,switchParameter,switchMethod,blockingLength,currentModality,pixPerCycs,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,soundFreq,soundAmp,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

% Pam - coherentDots
stimulus = coherentDots;

trialManagerClass='nAFC';
frameRate=100;
responsePorts=[1,3];
totalPorts=3;
width=1024;
height=768;

maxWidth = 100;
maxHeight = 100;

cDots = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, .85, 1, 3, 10, 85, [6 6]);
cDots2 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [.65 .9], 1, 3, 2, 100, [6 6]);
cDots3 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [.45 .9], 1, 3, 2, 100, [6 6]);
cDots4 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [.25 .9], 1, 3, 2, 100, [6 6]);
cDots5 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [.15 .45], 1, 3, 2, 100, [6 6]);
cDots6 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [.0001 1], 1, 3, 2, 100, [6 6]);

% ====================================================================================================================
% training steps
svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
% set up graduationCriterion
graduateQuickly = performanceCriterion([.9, .5], [uint8(10), uint8(20)]); %cannot use this for freeDrinks b/c no "correct" answer


% DEMO
ts1 = trainingStep(fd_sto, freeStim, graduateQuickly, noTimeOff(), svnRev);   %stochastic free drinks
ts2 = trainingStep(fd, freeStim, graduateQuickly, noTimeOff(), svnRev);  %free drinks
ts3 = trainingStep(vh, freeStim, graduateQuickly, noTimeOff(), svnRev);   %go to stim - orientedGabors w/ nAFC
ts4 = trainingStep(vh, discrimStim, graduateQuickly, noTimeOff(), svnRev);%orientation discrim - orientedGabors w/ nAFC
ts5 = trainingStep(vh, imageStim,  graduateQuickly, noTimeOff(), svnRev); %morph discrim - images w/ nAFC

% Balaji
ts6 = trainingStep(gts, freeStim, graduateQuickly, noTimeOff(), svnRev);  % go to stim

% Phil
ts7 = trainingStep(fd, freeAudioStim, graduateQuickly, noTimeOff(), svnRev); % stereoDiscrim w/ fd
ts8 = trainingStep(vh, discrimAudioStim, graduateQuickly, noTimeOff(), svnRev); % stereoDiscrim w/ nAFC
ts9 = trainingStep(fd, freeVisualStim, graduateQuickly, noTimeOff(), svnRev); % hemifieldFlicker w/ fd
ts10 = trainingStep(vh, discrimVisualStim, graduateQuickly, noTimeOff(), svnRev); % hemifieldFlicker w/ nAFC
ts11 = trainingStep(vh, crossModalStim, graduateQuickly, noTimeOff(), svnRev); % crossModel w/ nAFC

% Pam
ts12 = trainingStep(vh, cDots, graduateQuickly, noTimeOff(), svnRev); % coherentDots w/ nAFC
ts13 = trainingStep(vh, cDots2, graduateQuickly, noTimeOff(), svnRev); % coherentDots w/ nAFC
ts14 = trainingStep(vh, cDots3, graduateQuickly, noTimeOff(), svnRev); % coherentDots w/ nAFC
ts15 = trainingStep(vh, cDots4, graduateQuickly, noTimeOff(), svnRev); % coherentDots w/ nAFC
ts16 = trainingStep(vh, cDots5, graduateQuickly, noTimeOff(), svnRev); % coherentDots w/ nAFC
ts17 = trainingStep(vh, cDots6, graduateQuickly, noTimeOff(), svnRev); % coherentDots w/ nAFC

% DEMO - with NcorrectInARow reinforcement manager instead of constantReinforcement
ts18 = trainingStep(fd_sto_increasing_rewards, freeStim, graduateQuickly, noTimeOff(), svnRev); %stochastic free drinks
ts19 = trainingStep(fd_increasing_rewards, freeStim, graduateQuickly, noTimeOff(), svnRev);  %free drinks
ts20 = trainingStep(nAFC_increasing_rewards, freeStim, graduateQuickly, noTimeOff(), svnRev);   %go to stim - orientedGabors w/ nAFC
ts21 = trainingStep(nAFC_increasing_rewards, discrimStim, graduateQuickly, noTimeOff(), svnRev);%orientation discrim - orientedGabors w/ nAFC
ts22 = trainingStep(nAFC_increasing_rewards, imageStim,  graduateQuickly, noTimeOff(), svnRev); %morph discrim - images w/ nAFC

% ====================================================================================================================
% protocol and rest of setup stuff
% p=protocol('gabor test',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8, ts9, ts10, ts11, ts12, ts13, ts14, ts15, ts16, ts17, ...
%     ts18, ts19, ts20, ts21, ts22});
% stepNum=21;
p=protocol('gabor test', {ts4, ts3});
stepNum=1;

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolDEMO','edf');
end