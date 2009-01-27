function r = setProtocolPhys2(r,subjIDs,dataNetOn,eyeTrackerOn)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

if ~exist('dataNetOn','var') || isempty(dataNetOn)
     dataNetOn=1;
end

if ~exist('eyeTrackerOn','var') || isempty(eyeTrackerOn)
     eyeTrackerOn=1;
end


%% define stim managers

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
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

pixPerCycs=[20 10];
distractorOrientations=[0];
goToSide = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


% gratings
pixPerCycs=2.^([2:9]); %freq
driftfrequencies=[2];  % in cycles per second
orientations=[pi/2];   % in radians
phases=[0];            % initial phase
contrasts=[1];         % contrast of the grating
durations=[3];         % duration of each grating
radius=.08;            % radius of the gaussian mask
annuli=0;             % radius of inner annuli
location=[0.25 0.75];  % center of mask
waveform='square';     
normalizationMethod='normalizeDiagonal';
mean=0.5;
scaleFactor             =0;
sfGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

numOrientations=6;
orientations=([pi/2]*[1:numOrientations])/numOrientations; % in radians
pixPerCycs=[64];  % reset to one value
orGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
waveform,normalizationMethod,mean,thresh,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

numContrasts=6;
contrasts=1./2.^[0:numContrasts-1]; % contrast of the grating
orientations=[pi/2]; % reset to one value
cntrGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
waveform,normalizationMethod,mean,thresh,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


ports=cellfun(@uint8,{1 3},'UniformOutput',false);
[noiseSpec(1:length(ports)).port]=deal(ports{:});

% stim properties:
% in.distribution               'gaussian', 'binary', 'uniform', or a path to a file name (either .txt or .mat, extension omitted, .txt loadable via load(), and containing a single vector of numbers named 'noise')
% in.origHz                     only used if distribution is a file name, indicating sampling rate of file
% in.contrast                   std dev in normalized luminance units (just counting patch, before mask application), values will saturate
% in.startFrame                 'randomize' or integer indicating fixed frame number to start with
% in.loopDuration               in seconds (will be rounded to nearest multiple of frame duration, if distribution is a file, pass 0 to loop the whole file)
%                               to make uniques and repeats, pass {numRepeatsPerUnique numCycles cycleDurSeconds} - a cycle is a whole set of repeats and one unique - distribution cannot be sinusoidalFlicker 

[noiseSpec.distribution]         =deal('gaussian');
[noiseSpec.origHz]               =deal(0);
[noiseSpec.contrast]             =deal(pickContrast(.5,.01));
[noiseSpec.startFrame]           =deal('randomize');
[noiseSpec.loopDuration]         =deal(1);

% patch properties:
% in.locationDistribution       2-d density, will be normalized to stim area
% in.maskRadius                 std dev of the enveloping gaussian, normalized to diagonal of stim area (values <=0 mean no mask)
% in.patchDims                  [height width]
% in.patchHeight                0-1, normalized to stim area height
% in.patchWidth                 0-1, normalized to stim area width
% in.background                 0-1, normalized

[noiseSpec.locationDistribution] =deal(1);
[noiseSpec.maskRadius]           =deal(10);
[noiseSpec.patchDims]            =deal(uint16([50 50]));
[noiseSpec.patchHeight]          =deal(1);
[noiseSpec.patchWidth]           =deal(1);
[noiseSpec.background]           =deal(.5);

% filter properties:
% in.orientation                filter orientation in radians, 0 is vertical, positive is clockwise
% in.kernelSize                 0-1, normalized to diagonal of patch
% in.kernelDuration             in seconds (will be rounded to nearest multiple of frame duration)
% in.ratio                      ratio of short to long axis of gaussian kernel (1 means circular, no effective orientation)
% in.filterStrength             0 means no filtering (kernel is all zeros, except 1 in center), 1 means pure mvgaussian kernel (center not special), >1 means surrounding pixels more important
% in.bound                      .5-1 edge percentile for long axis of kernel when parallel to window

[noiseSpec.orientation]          =deal(-pi/4,pi/4);
[noiseSpec.kernelSize]           =deal(.5);
[noiseSpec.kernelDuration]       =deal(.1);
[noiseSpec.ratio]                =deal(1/3);
[noiseSpec.filterStrength]       =deal(1);
[noiseSpec.bound]                =deal(.99);
%maxWidth               = 800; uncommenting these effects all stims below here which would be bad
%maxHeight              = 600;
scaleFactor            = 0;

orNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.orientation]          =deal(0);
[noiseSpec.maskRadius]           =deal(100);
[noiseSpec.kernelSize]           =deal(0);
[noiseSpec.kernelDuration]       =deal(0);
[noiseSpec.ratio]                =deal(1);
[noiseSpec.filterStrength]       =deal(0);
[noiseSpec.patchDims]            =deal(uint16([100 100]));

gaussNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal('binary');
[noiseSpec.contrast]             =deal(1);

binNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


gaussNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

if ismac
    ts001 = '/Users/eflister/Desktop/ratrix trunk/classes/protocols/stimManagers/@flicker/ts001';
else
    ts001 = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\hateren\ts001';
end
[noiseSpec.distribution]         =deal(ts001);
[noiseSpec.origHz]               =deal(1200);
[noiseSpec.loopDuration]         =deal(30);

hateren=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[4 8],1,.1}); %temporal freqs, contrasts, gapSecs
[noiseSpec.origHz]               =deal(0);
[noiseSpec.loopDuration]         =deal(10);

ffSearch=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[10],[.1 .25 .5 .75 1],.1}); %temporal freqs, contrasts, gapSecs
[noiseSpec.loopDuration]         =deal(10);

crf=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[1 2 4 8 32 50 100],1,.1}); %temporal freqs, contrasts, gapSecs

trf=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal('gaussian');
[noiseSpec.contrast]             =deal(pickContrast(.5,.01));
[noiseSpec.loopDuration]         =deal(5*60);

ffGauss=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal(ts001);
[noiseSpec.origHz]               =deal(1200);
[noiseSpec.loopDuration]         =deal({uint8(4),uint8(3),40}); %{numRepeatsPerUnique numCycles cycleDurSeconds}
[noiseSpec.contrast]             =deal(1);
[noiseSpec.startFrame]           =deal(uint8(1));

rptUnq=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

flankers=ifFeatureGoRightWithTwoFlank('phys');

% bipartiteField
receptiveFieldLocation = [0.25 0.5]; 
frequencies = [12 60 200];
duration = 2;
repetitions=2;
scaleFactor=0;
interTrialLuminance=0.5;
biField = bipartiteField(receptiveFieldLocation,frequencies,duration,repetitions,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


% whiteNoise
gray=0.5;
mean=gray;
std=gray*(2/3);
searchSubspace=[1];
background=gray;
method='texOnPartOfScreen';
stixelSize = [20,16];
stimLocation=[0,0,maxWidth,maxHeight];
numFrames=1000;   %100 to test; 5*60*100=30000 for experiment
% s = whiteNoise(meanLuminance,std,background,method,requestedStimLocation,stixelSize,searchSubspace,numFrames,
%       maxWidth,maxHeight,scaleFactor,interTrialLuminance)

wn = whiteNoise(mean,std,background,method,stimLocation,stixelSize,searchSubspace,numFrames,1280,1024,0,.5);



%% trial / sound / reinforcement managers

if dataNetOn
    ai_parameters.numChans=3;
    ai_parameters.sampRate=40000;
    ai_parameters.inputRanges=repmat([-1 6],ai_parameters.numChans,1);
    dn=datanet('stim','localhost','132.239.158.179','\\132.239.158.179\datanet_storage',ai_parameters)
else
    dn=[];
end

if eyeTrackerOn
   alpha=12; %deg above...really?
   beta=0; %deg to side... really?
   eyeTracker=geometricTracker('simple', 2, 3, alpha, beta, int16([1280,1024]), [42,28], int16([maxWidth,maxHeight]), [400,290], 300, 0, 0, 0, 0,10000); % changing calibration params we be updated by user on startup
else
   eyeTracker=[];
end
eyeController=[];

sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});

rewardSizeULorMS        =150;
msPenalty               =1000;
fractionOpenTimeSoundIsOn=1;
fractionPenaltySoundIsOn=1;
scalar=1;
msAirpuff=msPenalty;

constantRewards=constantReinforcement(rewardSizeULorMS,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

msFlushDuration         =1000;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
freeDrinkLikelihood=0.003;
fd = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood,constantRewards);

freeDrinkLikelihood=0;
fd2 = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood,constantRewards);

requestRewardSizeULorMS=10;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;

afc=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,constantRewards,eyeTracker,eyeController,dn);

ap=autopilot(percentCorrectionTrials,msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,constantRewards,dn)

%% trainingsteps

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};


%common "search and characterization"
ts{1}  = trainingStep(afc, ffSearch,    repeatIndefinitely(), noTimeOff(), svnRev); %full field search
ts{2}  = trainingStep(afc, crf,         repeatIndefinitely(), noTimeOff(), svnRev); %contrast response
ts{3}  = trainingStep(afc, trf,         repeatIndefinitely(), noTimeOff(), svnRev); %temporal reponse
ts{4}  = trainingStep(afc, sfGratings,  repeatIndefinitely(), noTimeOff(), svnRev); %gratings: spatial frequency
ts{5}  = trainingStep(afc, orGratings,  repeatIndefinitely(), noTimeOff(), svnRev); %gratings: orientation
ts{6}  = trainingStep(afc, cntrGratings,repeatIndefinitely(), noTimeOff(), svnRev); %gratings: contrast
ts{7} = trainingStep(afc, gaussNoise,  repeatIndefinitely(), noTimeOff(), svnRev); %unfilteredNoise discrim
ts{8} = trainingStep(afc, biField,     repeatIndefinitely(), noTimeOff(), svnRev); %bipartite field for X-Y classification


%common "acclimate a rat"
ts{9}  = trainingStep(afc, goToSide, repeatIndefinitely(), noTimeOff(), svnRev);   %go to side
ts{10}  = trainingStep(fd,  freeStim, repeatIndefinitely(), noTimeOff(), svnRev);   %stochastic free drinks
ts{11}  = trainingStep(fd2, freeStim, repeatIndefinitely(), noTimeOff(), svnRev);   %free drinks

%common "lots of data collection"
ts{12} = trainingStep(afc, ffGauss,  repeatIndefinitely(), noTimeOff(), svnRev);   %fullfieldFlicker Gaussian
ts{13} = trainingStep(afc, hateren,  repeatIndefinitely(), noTimeOff(), svnRev);   %hateren
ts{14} = trainingStep(afc, flankers, repeatIndefinitely(), noTimeOff(), svnRev);   %flankers
ts{15} = trainingStep(afc, rptUnq,   repeatIndefinitely(), noTimeOff(), svnRev);   %rpt/unq
ts{16} = trainingStep(afc, orNoise,  repeatIndefinitely(), noTimeOff(), svnRev);   %filteredNoise discrim
ts{17} = trainingStep(ap,  binNoise, repeatIndefinitely(), noTimeOff(), svnRev);   %unfilteredNoise discrim

%testing
ts{18} = trainingStep(afc,  wn, repeatIndefinitely(), noTimeOff(), svnRev);   %unfilteredNoise discrim

%% make and set it

p=protocol('practice phys',{ts{1:18}});
stepNum=uint8(18);

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolPhys','pmm');
end