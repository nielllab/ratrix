function r = setProtocolTEST(r,subjIDs)

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
requestRewardSizeULorMS=10;
percentCorrectionTrials=.5;
doAllRequests='first';

freeDrinkLikelihood=0.1; % changes for stochastic/regular freeDrinks

% ====================================================================================================================
% soundManager
sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});

% ====================================================================================================================
% reinforcementManager
constantRewards=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,doAllRequests,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

msPenalty=2000;
constantRewards2=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,...
    doAllRequests,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

msPenalty=1000;
doAllRequests='all';
constantRewardsWithAllRequests=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,doAllRequests,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

doAllRequests='nonrepeats';
constantRewardsWithNonrepeats=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,doAllRequests,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

increasingRewards=rewardNcorrectInARow([20,80,150,250,350,500,1000],requestRewardSizeULorMS,doAllRequests,msPenalty,1,1, scalar, msAirpuff); %[20 80 100 150 250] is what philip uses ..

% ====================================================================================================================
% trialManager
fd_sto = freeDrinks(sm,freeDrinkLikelihood,constantRewards);

freeDrinkLikelihood=0;
fd = freeDrinks(sm,freeDrinkLikelihood,constantRewards);

% freeDrinks (stochastic and nonstochastic) but with increasingRewards instead of constantRewards
freeDrinkLikelihood=0.003;
fd_sto_increasing_rewards = freeDrinks(sm,freeDrinkLikelihood,increasingRewards);

freeDrinkLikelihood=0;
fd_increasing_rewards = freeDrinks(sm,freeDrinkLikelihood,increasingRewards);

fd_all_requests=freeDrinks(sm,freeDrinkLikelihood,constantRewardsWithAllRequests,...
    [],[],[],[],'all');

fd_nonrepeats=freeDrinks(sm,freeDrinkLikelihood,constantRewardsWithNonrepeats,...
    [],[],[],[],'all');

vh=nAFC(sm,percentCorrectionTrials,constantRewards);

% with stimulusOnsetMode and responseWindow
% vh_responseWindow=nAFC(sm,percentCorrectionTrials,constantRewards,...
%     [],[],[],[],[],[],{'delayed','constantDelay'},2000);
% vh_responseWindow=nAFC(sm,percentCorrectionTrials,constantRewards,...
%     [],[],[],[],[],[],'immediate',2000);
responseLockoutMs=2000;
delayFcn=hazard(0,2000,20000,false);
gng=goNoGo(sm,percentCorrectionTrials,responseLockoutMs,constantRewards2,...
    [],[],[],[],[],[],delayFcn,10000);
vh_delayed=nAFC(sm,percentCorrectionTrials,constantRewards,...
    [],[],[],[],'none',[],delayFcn,10000);

ai_parameters=[];
ai_parameters.numChans=3;
ai_parameters.sampRate=50000;
ai_parameters.inputRanges=repmat([-1 6],ai_parameters.numChans,1);

vh_datanet=nAFC(sm,percentCorrectionTrials,constantRewards);
% datanet('stim','localhost','132.239.158.179','\\132.239.158.179\datanet_storage',ai_parameters)

% uses rewardNcorrectInARow reinforcementManager, but same nAFC otherwise
nAFC_increasing_rewards =nAFC(sm,percentCorrectionTrials,increasingRewards);

%%%%%%%%%% go to stim - Balaji (same as Erik's go to side)
gts = nAFC(sm,percentCorrectionTrials,constantRewards);

% autopilot trialManager (for gratings currently) - 11/12/08 fli
aP = autopilot(percentCorrectionTrials,sm,constantRewards);
aP_datanet = autopilot(percentCorrectionTrials,sm,constantRewards);

% passiveViewing trialManager
% allowRepeats=true;
% passive=passiveViewing(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
%     percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
%     maximumNumberStimPresentations,doMask,constantRewards,allowRepeats);

% ====================================================================================================================
% variables for stim managers
pixPerCycs              =[20];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =.04;
contrasts                =[1 .5];
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
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrasts,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

pixPerCycs=[20 10];
targetOrientations=[pi/2 pi/3 pi/4];
distractorOrientations=[0];
discrimStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrasts,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

% gratings
pixPerCycs=[100]; %freq
driftfrequencies=[1 6]; % in cycles per second
orientations=[pi/3]; % in radians
phases=[0]; % initial phase
contrasts=[0.99]; % contrast of the grating
durations=[2];
radii=[.08]; % radius of the gaussian mask
annuli=[0.01]; % radius of inner annuli
location=[0.25 0.75];
waveform='square';
normalizationMethod='normalizeDiagonal';
imageSelectionMode='normal';
mean=0.5;
thresh=.00005;
maxWidth                =1024;
maxHeight               =768;
scaleFactor             =0;
interTrialLuminance     =.5;
numRepeats=2;
gratingStim = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

imageSize=[1 1];
imageRotation=[0 210];
imageYoked=false;
rotationYoked=false;
imageStim = images(imageDir,ypos,background,maxWidth,maxHeight,scaleFactor,interTrialLuminance,trialDistribution,imageSelectionMode,...
    imageSize,imageYoked,imageRotation,rotationYoked,percentCorrectionTrials);

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
screen_width=100;
screen_height=100;
num_dots=100;
coherence=.85;
speed=1;
contrast=[.1 .1];
dot_size=[3 4];
movie_duration=2;
screen_zoom=[6 6];

maxWidth=1024;
maxHeight=768;


cDots=coherentDots(screen_width,screen_height,num_dots,coherence,speed,contrast,dot_size,movie_duration,screen_zoom,...
     maxWidth,maxHeight,percentCorrectionTrials);
 
movie_duration=1/60; %doesnt actually matter - calcStim will ignore this b/c the trainingStep ts102 has more than one target port
screen_width=100;
screen_height=100;
num_dots=100;
coherence=.85; % also unused in static mode
speed=1; % also unused in static mode
contrast=[1];
dot_size=[3];
screen_zoom=[6 6];
staticDots=coherentDots(screen_width,screen_height,num_dots,coherence,speed,contrast,dot_size,movie_duration,screen_zoom,...
     maxWidth,maxHeight,percentCorrectionTrials);
% ====================================================================================================================
% ifFeatureGoRightWithTwoFlank
%% default for all of pmeier stims
protocolType='goToRightDetection';
protocolVersion='2_4';
defaultSettingsDate='Oct.09,2007'; %datestr(now,22)

% whiteNoise
% gray = 127.5;
gray=0.5;
std=gray*(2/3);
distribution={'gaussian',gray,std}
searchSubspace=[1];
background=gray;
method='texOnPartOfScreen';
changeable=false;
stixelSize = [20,16];
stimLocation=[0,0,1280,1024];
numFrames=100;   %100 to test; 5*60*100=30000 for experiment
% s = whiteNoise(meanLuminance,std,background,method,requestedStimLocation,stixelSize,searchSubspace,numFrames,
%       maxWidth,maxHeight,scaleFactor,interTrialLuminance)

wn = whiteNoise(distribution,background,method,stimLocation,stixelSize,searchSubspace,...
    numFrames,changeable,1280,1024,0,.5);

% bipartiteField
receptiveFieldLocation = [0.25 0.5];
frequencies = [12 60 200];
duration = 2;
repetitions=2;
maxWidth=1280;
maxHeight=1024;
scaleFactor=0;
interTrialLuminance=0.5;
biField = bipartiteField(receptiveFieldLocation,frequencies,duration,repetitions,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

% fullField
contrast = 1.0;
frequencies = [2 30 100];
duration = 3;
repetitions=1;
maxWidth=1280;
maxHeight=1024;
scaleFactor=0;
interTrialLuminance=0.5;
fF = fullField(contrast,frequencies,duration,repetitions,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

default=getDefaultParameters(ifFeatureGoRightWithTwoFlank,protocolType,protocolVersion,defaultSettingsDate);
parameters=default;
parameters.requestRewardSizeULorMS  =30;
parameters.requestMode='first';
parameters.msPenalty=1000;
parameters.scheduler=minutesPerSession(90,3);
%parameters.scheduler = nTrialsThenWait([1000],[1],[0.01],[1]);
%%noTimeOff()

parameters.mean = 0.5;
parameters.typeOfLUT= 'linearizedDefault';
parameters.rangeOfMonitorLinearized=[0.0 0.5];

%match stim of rats, 3.3=3 cpd at 215cm
parameters.pixPerCycs =32;  %could go to 12
parameters.stdGaussMask = 1/16; %could go to 3/128

%achieves 8.9=9cpd at 215cm, like sagi
parameters.pixPerCycs =12;
parameters.stdGaussMask = 3/128;

parameters.fractionNoFlanks=.05;
parameters.flankerContrast = [0.4]; % **!! miniDatabase overwrites this (for rats on this step)  if within-step shaping rebuilding ratrix
parameters.flankerOffset = 3;
parameters.toggleStim=false;

%targetContrast= 2.^[-6,-7]; %a guess for thresh!
%[0.015625 0.5 0.75 1 ] 1/log2 idea: 2.^[-8,-7,-6,-2,-1]
targetContrast=2.^[-8,-7,-6]%-8,-7,-6,-2,-1]; %[.25 0.5 0.75 1]; % starting sweep (rational: match acuity, but if at chance on .25 don't swamp more than you need, if above chance then add in something smaller, also easier ones will keep up moral )
parameters=setLeftAndRightContrastInParameterStruct(parameters, protocolType, targetContrast);

parameters=setLeftAndRightContrastInParameterStruct(parameters, protocolType, targetContrast);  % **skip .9 ; miniDatabase overwrites this (for rats on this step)  if rebuilding ratrix
parameters.persistFlankersDuringToggle = 0; %


% parameters.shapedParameter='targetContrast';
% parameters.shapingMethod='linearChangeAtCriteria';
% parameters.shapingValues.numSteps=int8(6);
% parameters.shapingValues.startValue=.8;
% parameters.shapingValues.currentValue=.8;
% parameters.shapingValues.goalValue=0.2;
% parameters.graduation = parameterThresholdCriterion('.stimDetails.currentShapedValue','<',0.29);


%for all stimuli with displayTargetAndDistractor = 0, these will not matter
parameters.distractorYokedToTarget=1;
parameters.distractorFlankerYokedToTargetFlanker = 1;
parameters.distractorContrast = 0;


%Remove correlation for experiments
parameters.maxCorrectOnSameSide=int8(-1); %%%
parameters.percentCorrectionTrials=0;  %beware this is overpowered by the minidatabase setting!


nameOfShapingStep=repmat({'junkStep'},1,11);  % skip the first 11 of training...


nameOfShapingStep{end+1} = sprintf('Expt 1: contrast sweep', protocolType);
[sweepContrast previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});





d=2; %decrease to broaden
gran=100;
x=linspace(-d,d,gran);
[a b]=meshgrid(x);

ports=cellfun(@uint8,{1 3},'UniformOutput',false);
% % % [noiseSpec(1:length(ports)).port]=deal(ports{:});
% % % [noiseSpec.numLoops]=deal(1);
% % % 
% % % % stim properties:
% % % % in.distribution               'binary', 'uniform', or one of the following forms:
% % % %                                   {'sinusoidalFlicker',[temporalFreqs],[contrasts],gapSecs} - each freq x contrast combo will be shown for equal time in random order, total time including gaps will be in.loopDuration
% % % %                                   {'gaussian',clipPercent} - choose variance so that clipPercent of an infinite stim would be clipped (includes both low and hi)
% % % %                                   {path, origHz, clipVal, clipType} - path is to a file (either .txt or .mat, extension omitted, .txt loadable via load()) containing a single vector of stim values named 'noise', with original sampling rate origHz.
% % % %                                       clipType:
% % % %                                       'normalized' will normalize whole file to clipVal (0-1), setting darkest val in file to 0 and values over clipVal to 1.
% % % %                                       'ptile' will normalize just the contiguous part of the file you are using to 0-1, clipping top clipVal (0-1) proportion of vals (considering only the contiguous part of the file you are using)
% % % % in.startFrame                 'randomize' or integer indicating fixed frame number to start with
% % % % in.loopDuration               in seconds (will be rounded to nearest multiple of frame duration, if distribution is a file, pass 0 to loop the whole file)
% % % %                               to make uniques and repeats, pass {numRepeats numUniques numCycles chunkSeconds} - chunk refers to one repeat/unique - distribution cannot be sinusoidalFlicker
% % % 
% % % [noiseSpec.distribution]         =deal({'gaussian' .01 'new'});
% % % [noiseSpec.startFrame]           =deal(uint8(1)); %deal('randomize');
% % % [noiseSpec.loopDuration]         =deal(1);
% % % 
% % % % patch properties:
% % % % in.locationDistribution       2-d density, will be normalized to stim area
% % % % in.maskRadius                 std dev of the enveloping gaussian, normalized to diagonal of stim area (values <=0 mean no mask)
% % % % in.patchDims                  [height width]
% % % % in.patchHeight                0-1, normalized to stim area height
% % % % in.patchWidth                 0-1, normalized to stim area width
% % % % in.background                 0-1, normalized (luminance outside patch)
% % % 
% % % [noiseSpec.locationDistribution]=deal(reshape(mvnpdf([a(:) b(:)],[-d/2 d/2]),gran,gran),reshape(mvnpdf([a(:) b(:)],[d/2 d/2]),gran,gran));
% % % [noiseSpec.maskRadius]           =deal(.045);
% % % [noiseSpec.patchDims]            =deal(uint16([50 50]));
% % % [noiseSpec.patchHeight]          =deal(.4);
% % % [noiseSpec.patchWidth]           =deal(.4);
% % % [noiseSpec.background]           =deal(.5);
% % % 
% % % % filter properties:
% % % % in.orientation                filter orientation in radians, 0 is vertical, positive is clockwise
% % % % in.kernelSize                 0-1, normalized to diagonal of patch
% % % % in.kernelDuration             in seconds (will be rounded to nearest multiple of frame duration)
% % % % in.ratio                      ratio of short to long axis of gaussian kernel (1 means circular, no effective orientation)
% % % % in.filterStrength             0 means no filtering (kernel is all zeros, except 1 in center), 1 means pure mvgaussian kernel (center not special), >1 means surrounding pixels more important
% % % % in.bound                      .5-1 edge percentile for long axis of kernel when parallel to window
% % % 
% % % [noiseSpec.orientation]         =deal(-pi/4,pi/4);
% % % [noiseSpec.kernelSize]           =deal(.5);
% % % [noiseSpec.kernelDuration]       =deal(.2);
% % % [noiseSpec.ratio]                =deal(1/3);
% % % [noiseSpec.filterStrength]       =deal(1);
% % % [noiseSpec.bound]                =deal(.99);
% % % 
% % % maxWidth               = 800;
% % % maxHeight              = 600;
% % % scaleFactor            = 0;
% % % 
% % % noiseStim=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
% % % 
% % % 
% % % [noiseSpec.orientation]         =deal(0);
% % % [noiseSpec.locationDistribution]=deal([0 0;1 0], [0 0;0 1]);
% % % [noiseSpec.distribution]         =deal('binary');
% % % [noiseSpec.maskRadius]           =deal(100);
% % % [noiseSpec.kernelSize]           =deal(0);
% % % [noiseSpec.kernelDuration]       =deal(0);
% % % [noiseSpec.ratio]                =deal(1);
% % % [noiseSpec.filterStrength]       =deal(0);
% % % [noiseSpec.patchDims]            =deal(uint16([2 2]));
% % % [noiseSpec.patchHeight]          =deal(.1);
% % % [noiseSpec.patchWidth]           =deal(.1);
% % % 
% % % unfilteredNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
% % % 
% % % % led=nAFC(sm,percentCorrectionTrials,constantRewards,[],{'off'},false,'LED');
% % % 
% % % if ismac
% % %     ts001 = '/Users/eflister/Desktop/ratrix trunk/classes/protocols/stimManagers/@flicker/ts001';
% % % else
% % %     ts001 = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\hateren\ts001';
% % % end
% % % 
% % % [noiseSpec.distribution]         =deal({ts001, 1200, .01, 'ptile'}); %12800/32767 for normalized clipVal, see pam email to Alex Casti on January 25, 2005, and Reinagel Reid 2000
% % % [noiseSpec.loopDuration]         =deal({uint32(60) uint32(0) uint32(1) uint32(30)}); %{numRepeats numUniques numCycles chunkSeconds}
% % % 
% % % 
% % % [noiseSpec.locationDistribution]=deal(1);
% % % [noiseSpec.patchDims]            =deal(uint16([1 1]));
% % % [noiseSpec.patchHeight]          =deal(1);
% % % [noiseSpec.patchWidth]           =deal(1);
% % % 
% % % hateren=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
% % % 
% % % [noiseSpec.distribution]         =deal({'gaussian', .01});
% % % 
% % % fullfieldFlicker=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
% % % 
% % % [noiseSpec.distribution]         =deal({'sinusoidalFlicker',[1 5 10 25 50],[.1 .25 .5 .75 1],.1}); %temporal freqs, contrasts, gapSecs
% % % [noiseSpec.loopDuration]         =deal(5*5*1);
% % % [noiseSpec.patchHeight]          =deal(1);
% % % [noiseSpec.patchWidth]           =deal(1);
% % % crftrf=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);



% ====================================================================================================================
% training steps
svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';
% set up graduationCriterion
graduateQuickly = performanceCriterion([.9, .5], [uint8(10), uint8(20)]); %cannot use this for freeDrinks b/c no "correct" answer
repeatIndef = repeatIndefinitely();

% DEMO
ts1 = trainingStep(fd_sto, freeStim, repeatIndef, noTimeOff(), svnRev, svnCheckMode);   %stochastic free drinks
ts2 = trainingStep(fd, freeStim, repeatIndef, noTimeOff(), svnRev, svnCheckMode);  %free drinks
ts3 = trainingStep(vh, freeStim, graduateQuickly, noTimeOff(), svnRev, svnCheckMode);   %go to stim - orientedGabors w/ nAFC
ts4 = trainingStep(vh, discrimStim, repeatIndef, noTimeOff(), svnRev, svnCheckMode);%orientation discrim - orientedGabors w/ nAFC
ts5 = trainingStep(vh, imageStim,  graduateQuickly, noTimeOff(), svnRev, svnCheckMode); %morph discrim - images w/ nAFC

% Balaji
ts6 = trainingStep(gts, freeStim, graduateQuickly, noTimeOff(), svnRev, svnCheckMode);  % go to stim

% Phil
ts7 = trainingStep(fd, freeAudioStim, graduateQuickly, noTimeOff(), svnRev, svnCheckMode); % stereoDiscrim w/ fd
ts8 = trainingStep(vh, discrimAudioStim, graduateQuickly, noTimeOff(), svnRev, svnCheckMode); % stereoDiscrim w/ nAFC
ts9 = trainingStep(fd, freeVisualStim, graduateQuickly, noTimeOff(), svnRev, svnCheckMode); % hemifieldFlicker w/ fd
ts10 = trainingStep(vh, discrimVisualStim, graduateQuickly, noTimeOff(), svnRev, svnCheckMode); % hemifieldFlicker w/ nAFC
ts11 = trainingStep(vh, crossModalStim, graduateQuickly, noTimeOff(), svnRev, svnCheckMode); % crossModel w/ nAFC

% Pam
ts12 = trainingStep(vh, cDots, repeatIndef, noTimeOff(), svnRev, svnCheckMode); % coherentDots w/ nAFC
% ts13 = trainingStep(vh, cDots2, graduateQuickly, noTimeOff(), svnRev, svnCheckMode); % coherentDots w/ nAFC
% ts14 = trainingStep(vh, cDots3, graduateQuickly, noTimeOff(), svnRev, svnCheckMode); % coherentDots w/ nAFC
% ts15 = trainingStep(vh, cDots4, graduateQuickly, noTimeOff(), svnRev, svnCheckMode); % coherentDots w/ nAFC
% ts16 = trainingStep(vh, cDots5, graduateQuickly, noTimeOff(), svnRev, svnCheckMode); % coherentDots w/ nAFC
% ts17 = trainingStep(vh, cDots6, graduateQuickly, noTimeOff(), svnRev, svnCheckMode); % coherentDots w/ nAFC


% DEMO - with NcorrectInARow reinforcement manager instead of constantReinforcement
ts18 = trainingStep(fd_sto_increasing_rewards, freeStim, graduateQuickly, noTimeOff(), svnRev, svnCheckMode); %stochastic free drinks
ts19 = trainingStep(fd_increasing_rewards, freeStim, graduateQuickly, noTimeOff(), svnRev, svnCheckMode);  %free drinks
ts20 = trainingStep(nAFC_increasing_rewards, freeStim, graduateQuickly, noTimeOff(), svnRev, svnCheckMode);   %go to stim - orientedGabors w/ nAFC
ts21 = trainingStep(nAFC_increasing_rewards, discrimStim, graduateQuickly, noTimeOff(), svnRev, svnCheckMode);%orientation discrim - orientedGabors w/ nAFC
% ts22 = trainingStep(nAFC_increasing_rewards, imageStim,  graduateQuickly, noTimeOff(), svnRev, svnCheckMode); %morph discrim - images w/ nAFC

% whiteNoise
% numTrialsDoneCriterion
doFiveTimes = numTrialsDoneCriterion(5);
ts23 = trainingStep(aP, wn, repeatIndef, noTimeOff(), svnRev, svnCheckMode); % whiteNoise stim

% bipartiteField
ts24 = trainingStep(aP,biField,repeatIndef,noTimeOff(),svnRev, svnCheckMode);

% gratings
ts25 = trainingStep(aP,gratingStim,repeatIndef,noTimeOff(),svnRev, svnCheckMode);

% regular nAFC orientedGabors with no datanet
ts26 = trainingStep(vh, discrimStim, repeatIndef, noTimeOff(), svnRev, svnCheckMode);%orientation discrim - orientedGabors w/ nAFC

% fullField
ts27=trainingStep(vh,fF,repeatIndef,noTimeOff(),svnRev, svnCheckMode);

% fullField with datanet
ts28=trainingStep(vh_datanet,fF,repeatIndef,noTimeOff(),svnRev, svnCheckMode);

% whiteNoise no datanet
ts29=trainingStep(aP,wn,repeatIndef,noTimeOff(),svnRev, svnCheckMode);

% erik filteredNoise
% ts30 = trainingStep(vh, hateren,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode); %hateren
% ts31 = trainingStep(vh, fullfieldFlicker,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode); %fullfieldFlicker
% ts32 = trainingStep(vh, crftrf,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode); %crf/trf

% passiveViewing no datanet with a fullField stim, 'all' requestPorts, 'all' requests rewarded
ts40 = trainingStep(fd_all_requests, wn, repeatIndef, noTimeOff(), svnRev, svnCheckMode);

% passiveViewing no datanet with a fullField stim, 'all' requestPorts, 'nonrepeats' rewarded
ts41 = trainingStep(fd_nonrepeats, wn, repeatIndef, noTimeOff(), svnRev, svnCheckMode);

% pam's new images
%create sound manager object used by all the other trial managers
sm =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
   soundClip('wrongSound','allOctaves',[50],20000)}); % tone

%create scheduer used by all trial managers
scheduler=minutesPerSession(120,3); % sch=noTimeOff();
%path containing ALL the stimuli
imdir='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\preinagel\PRimageset' 
imlist=PR_ImageSet1; % populate struct, each training step has a field for its list  
 requestRewardSizeULorMS=0;
rewardSizeULorMS        =50;
fractionSoundOn        = 1;
fractionPenaltySoundOn = 0;
rewardScalar =1;
msPuff=0;
% params for all the NAFC trial managers
%NB LUT is set in CALCSTIM; image method uses ramp not linearized
%NB error stim set in ERRORSTIM; image method set to BLACK screen
msPenaltyNAFC          =2000;
percentCorrectionTrials=.1; % LOW for post lesion tests
%NOTE nAFC uses maxWidth, maxHeight and scaleFactor defined above
interTrialLuminance_nAFC = 0.3; %extremely brief during stim calculation
background_nAFC=0; % range 0-1; bg for images (should differ from error screen) **CHANGED 080707**
% note this is also the color of screen between toggles but does NOT
% determine pre-requst color.
ypos_nAFC=0; %location of image stimuli is near ports
% new in trunk 3/9/09
doAllRequests='first'; % only reward first request trial lick
%create reinforcement manager object for all nAFC training steps
nAFCreinfmanager = constantReinforcement(rewardSizeULorMS,...
    requestRewardSizeULorMS,doAllRequests,... % NEW parameters
    msPenaltyNAFC,... %different penalty duration
    fractionSoundOn, fractionPenaltySoundOn,rewardScalar,msPuff);
gotostim=nAFC(sm,percentCorrectionTrials,nAFCreinfmanager);
%create the associated stim manager (gets images from path defined above)
imageSelectionMode='normal'; % not deck
imageSize=[1 1]; % full size
imageSizeYoked=true; % images have same size
imageRotation=[0 0]; % upright
imageRotationYoked=false; % images have same size
drawingMode='expert';
imagelevel1 = images(imdir,ypos_nAFC, background_nAFC,...
    maxWidth,maxHeight,scaleFactor,interTrialLuminance_nAFC, imlist.level1,...
    imageSelectionMode,imageSize,imageSizeYoked,imageRotation,imageRotationYoked,percentCorrectionTrials,drawingMode);
%create graduation criterion object for nAFC trial managers
graduationCriterion=performanceCriterion([.85 0.80], int16([200 300])); %85% correct for 200 consecutive trials

objrec1 = trainingStep(gotostim, imagelevel1, graduationCriterion, scheduler,svnRev,svnCheckMode);

% ts30 = trainingStep(vh, discrimStim5A,repeatIndef,noTimeOff(),svnRev, svnCheckMode);
% ts31 = trainingStep(vh, sweepContrast,repeatIndef,noTimeOff(),svnRev);
% ts25 = trainingStep(vh, discrimStim6A,graduateQuickly,noTimeOff(),svnRev);


% phil's
%% default for all of pmeier stims
default=getDefaultParameters(ifFeatureGoRightWithTwoFlank,protocolType,protocolVersion,defaultSettingsDate);
%% parameters for each shaping step
nameOfShapingStep{1} = sprintf('Step 2a: Easy %s, friendly', protocolType);
parameters=default;
parameters.requestRewardSizeULorMS             =30;
parameters.requestMode = 'first';
parameters.msPenalty=1000;
parameters.scheduler=minutesPerSession(90,3);
%parameters.scheduler = nTrialsThenWait([1000],[1],[0.01],[1]);
%%noTimeOff()
parameters.graduation = performanceCriterion([0.85, 0.8],int16([200, 500]));
[easyStep previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});



ts101 = trainingStep(gng, discrimStim, repeatIndef, noTimeOff(), svnRev, svnCheckMode);  %goNoGo w/ orientedGabors
ts102 = trainingStep(gng, staticDots, repeatIndef, noTimeOff(), svnRev, svnCheckMode);  %goNoGo w/ static dots for pam
ts103 = trainingStep(vh_delayed, cDots, repeatIndef, noTimeOff(), svnRev, svnCheckMode);  %nAFC w/ delayed dots for pam

% ====================================================================================================================
% protocol and rest of setup stuff
% p=protocol('gabor test',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8, ts9, ts10, ts11, ts12, ts13, ts14, ts15, ts16, ts17, ...
%     ts18, ts19, ts20, ts21, ts22});
% stepNum=21;
% p=protocol('gabor test2', {ts29, ts1, ts4, ts12, ts2, ts12, ts8, ts11,ts9,ts10,sweepContrast,ts23,ts24,ts27,ts30});
stepNum=uint8(3);

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    switch subjIDs{i}
%         case 'rack2test1' % do stochastic freeDrinks, orientedGabors
%             p=protocol('stofD,orientedGabors', {ts1});
%         case 'rack2test2' % do freeDrinks, orientedGabors
%             p=protocol('fD,orientedGabors', {ts2});
%         case 'rack2test3' % nAFC, orientedGabors
%             p=protocol('nAFC,orientedGabors',{ts4});
        case 'rack2test1' % nAFC, coherentDots
            p=protocol('nAFC,coherentDots',{ts12,ts4});
        case 'rack2test2' % nAFC, images
            p=protocol('nAFC,images',{ts30});
        case 'rack2test3' % nAFC, hemifield
            p=protocol('nAFC,hemifield',{ts10});
%         case 'rack3test1' % nAFC, coherentDots
%             p=protocol('nAFC,coherentDots',{ts12});
%         case 'rack3test2' % nAFC, images
%             p=protocol('nAFC,images',{ts30});
%         case 'rack3test3' % nAFC, hemifield
%             p=protocol('nAFC,hemifield',{ts10});
%         case 'rack3test3' % nAFC, ifFeature
%             p=protocol('nAFC,ifFeature',{sweepContrast});
%         case {'rack3test4','rack3test5','rack3test6'} % nAFC, orientedGabors
%             p=protocol('nAFC,orientedGabors',{ts4});
        otherwise
            p=protocol('demo',{ts4,ts2,ts102,ts103,ts40,ts41,ts4,ts2,ts25,sweepContrast,ts12,ts5,easyStep,ts23,objrec1});
%             error('unknown subject');
    end
    
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolDEMO','edf');
end
