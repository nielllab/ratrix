function r = ctxCharPtcl(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

% moved to GUI side
% if ~exist('dataNetOn','var') || isempty(dataNetOn)
%      dataNetOn=0;
% end
% 
% if ~exist('eyeTrackerOn','var') || isempty(eyeTrackerOn)
%      eyeTrackerOn=0;
% end


%% define stim managers

pixPerCycs              =[20];
mean                    =.5;
radius                  =.04;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65;
maxWidth                =1024;
maxHeight               =768;
scaleFactor             =[1 1];
interTrialLuminance     =.5;

% gratings
pixPerCycs=2.^([7:0.5:11]); % freq
driftfrequencies=[2];  % in cycles per second
orientations=[0];       % in radians, vert
phases=[0];            % initial phase
contrasts=[0.5];       % contrast of the grating
durations=[3];         % duration of each grating
radius=5;              % radius of the circular mask, 5= five times screen hieght
annuli=0;              % radius of inner annuli
location=[.5 .5];      % center of mask
%waveform='square';     
waveform='sine';     
normalizationMethod='normalizeDiagonal';
mean=0.5;
numRepeats=4;
scaleFactor=0;
doCombos=true;
changeableAnnulusCenter=false;
sfGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);


numOrientations=8;
orientationOrder = randPerm(numOrientations);
orientations=([2*pi]*[1:numOrientations])/numOrientations; % in radians
orientations = orientations(orientationOrder);
pixPerCycs=1024; %2^9;%temp [64];  % reset to one value
orGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

numContrasts=6;
contrasts=1./2.^[0:numContrasts-1]; % contrast of the grating
orientations=[pi/4]; % reset to one value
cntrGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

radii=[0.02 0.05 .1 .2 .3 .4 .5 2]; % radii of the grating
contrasts=1; % reset to one value
radGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);


annuli=[0.02 0.05 .1 .2 .3 .4 .5 2]; % annulus of the grating
RFdataSource='\\132.239.158.179\datanet_storage'; % good only as long as default stations don't change, %how do we get this from the dn in the station!?
%location = RFestimator({'spatialWhiteNoise','fitGaussian',{3}},{'gratings','ttestF1',{0.05,'fft'}},[],RFdataSource,[now-100 Inf]);
%location =
%RFestimator({'whiteNoise','fitGaussianSigEnvelope',{3,0.05,logical(ones(3))}},{'gratings','ttestF1',{0.05,'fft'}},[],RFdataSource,[now-100 Inf]);
%location=[.5 .5];
location = RFestimator({'gratingWithChangeableAnnulusCenter','lastDynamicSettings',[]},{'gratingWithChangeableAnnulusCenter','lastDynamicSettings',[]},[],RFdataSource,[now-100 Inf]);                         
anGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

changeableAnnulusCenter=true;
location=[.5 .5];
manAnGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
changeableAnnulusCenter=false;

annuli=0;                        % reset
location=[.5 .5];                % center of mask
driftfrequencies=[2 4 8 16];     % in cycles per second
%contrasts=1./2.^[0:numContrasts-1]; % contrast of the grating
contrasts=[1];                   % contrast of the grating
durations=[2];                   % duration of each grating
pixPerCycs=2.^(16);              % freq really broad approximates fullfield homogenous

numRepeats=3;
fakeTRF= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

numRepeats=10;
fakeTRF10= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

driftfrequencies=[2 4];     % in cycles per second
fakeTRFSlow= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

waveform='square'; 
pixPerCycs=2.^([8:10]); % freq
numRepeats=1;
durations=[3];                 % duration of each grating
orientations=([5/4*pi]*[1:5])/5; % in radians

contrasts=[1];              % contrast of the grating
driftfrequencies=[1 2 4];      % in cycles per second
searchGratings  = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

numOrientations=16;
orientations=([2*pi]*[1:numOrientations])/numOrientations; % in radians
driftfrequencies=[1/2];     % in cycles per second
pixPerCycs=2048;
durations=5;
contrasts=1;
numRepeats=3;
bigSlowSquare = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);


ports=cellfun(@uint8,{1 3},'UniformOutput',false);
[noiseSpec(1:length(ports)).port]=deal(ports{:});

% stim properties:
% in.distribution               'binary', 'uniform', or one of the following forms:
%                                   {'sinusoidalFlicker',[temporalFreqs],[contrasts],gapSecs} - each freq x contrast combo will be shown for equal time in random order, total time including gaps will be in.loopDuration
%                                   {'gaussian',clipPercent} - choose variance so that clipPercent of an infinite stim would be clipped (includes both low and hi)
%                                   {path, origHz, clipVal, clipType} - path is to a file (either .txt or .mat, extension omitted, .txt loadable via load()) containing a single vector of stim values named 'noise', with original sampling rate origHz.
%                                       clipType:
%                                       'normalized' will normalize whole file to clipVal (0-1), setting darkest val in file to 0 and values over clipVal to 1.
%                                       'ptile' will normalize just the contiguous part of the file you are using to 0-1, clipping top clipVal (0-1) proportion of vals (considering only the contiguous part of the file you are using)
% in.startFrame                 'randomize' or integer indicating fixed frame number to start with
% in.loopDuration               in seconds (will be rounded to nearest multiple of frame duration, if distribution is a file, pass 0 to loop the whole file)
%                               to make uniques and repeats, pass {numRepeats numUniques numCycles chunkSeconds} - chunk refers to one repeat/unique - distribution cannot be sinusoidalFlicker

[noiseSpec.distribution]         =deal({'gaussian',.01,uint32(0)});
[noiseSpec.startFrame]           =deal(uint8(1)); %deal('randomize');
[noiseSpec.loopDuration]         =deal(1);
[noiseSpec.numLoops]             =deal(3);

% patch properties:
% in.locationDistribution       2-d density, will be normalized to stim area
% in.maskRadius                 std dev of the enveloping gaussian, normalized to diagonal of stim area (values <=0 mean no mask)
% in.patchDims                  [height width]
% in.patchHeight                0-1, normalized to stim area height
% in.patchWidth                 0-1, normalized to stim area width
% in.background                 0-1, normalized

[noiseSpec.locationDistribution] =deal(1);
%[noiseSpec.locationDistribution]=deal(reshape(mvnpdf([a(:) b(:)],[-d/2 d/2]),gran,gran),reshape(mvnpdf([a(:) b(:)],[d/2 d/2]),gran,gran));
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

[noiseSpec.orientation]          =deal(pi/4,pi/4);
[noiseSpec.kernelSize]           =deal(.5);
[noiseSpec.kernelDuration]       =deal(.1);
[noiseSpec.ratio]                =deal(1/3);
[noiseSpec.filterStrength]       =deal(1);
[noiseSpec.bound]                =deal(.99);


%maxWidth               = 800; uncommenting these effects all stims below here which would be bad
%maxHeight              = 600;
%scaleFactor            = 0;

orNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.orientation]          =deal(0);
[noiseSpec.maskRadius]           =deal(100);
[noiseSpec.kernelSize]           =deal(0);
[noiseSpec.kernelDuration]       =deal(0);
[noiseSpec.ratio]                =deal(1);
[noiseSpec.filterStrength]       =deal(0);
[noiseSpec.patchDims]            =deal(uint16([32 24]));

gaussNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal('binary');
[noiseSpec.contrast]             =deal(1);

binNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

ts001 = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\stimuli\hateren\ts001';
[noiseSpec.distribution]         =deal({ts001, 1200, .01, 'ptile'});
[noiseSpec.loopDuration]         =deal({uint32(60) uint32(0) uint32(1) uint32(30) uint32(1)}); %{numRepeats numUniques numCycles chunkSeconds centerContrast}
[noiseSpec.patchDims]            =deal(uint16([1 1]));

hateren=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[4 8],1,.1}); %temporal freqs, contrasts, gapSecs
[noiseSpec.origHz]               =deal(0);
[noiseSpec.loopDuration]         =deal(10);

ffSearch=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[10],[.1 .25 .5 .75 1],.1}); %temporal freqs, contrasts, gapSecs
[noiseSpec.loopDuration]         =deal(10);

crf=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[1 2 4 8 16],1,.1}); %temporal freqs, contrasts, gapSecs

trf=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({'gaussian', .01, uint32(0)});
[noiseSpec.loopDuration]         =deal(1*60);

ffGauss=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({ts001, 1200, .01, 'ptile'});
[noiseSpec.loopDuration]         =deal({uint32(4) uint32(1) uint32(50) uint32(8) uint32(1)}); %{numRepeats numUniques numCycles chunkSeconds centerContrast}
[noiseSpec.contrast]             =deal(1);
[noiseSpec.startFrame]           =deal(uint8(1));

rptUnq=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);



%flankers
flankers=ifFeatureGoRightWithTwoFlank('phys');
flankersFF=ifFeatureGoRightWithTwoFlank('physFullFieldTarget');
fTestFlicker=ifFeatureGoRightWithTwoFlank('testFlicker');
prm=getDefaultParameters(ifFeatureGoRightWithTwoFlank, 'goToSide','1_0','Oct.09,2007');

% bipartiteField
receptiveFieldLocation = location; %as in annuli
receptiveFieldLocation = [.5 .5];
frequencies = [ 4 8 16 32 64];
duration = 4;
repetitions=4;
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
stixelSize = [32 32];% [128 128];% [128 128]; %[32,32];
changeable=false;

%fullField 
stimLocation=[0,0,maxWidth,maxHeight];
numFrames=3000;   %100 to test; 5*60*100=30000 for experiment
stixelSize = [maxWidth maxHeight ];
ffgwn = whiteNoise({'gaussian',gray,std},background,method,stimLocation,stixelSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
ffbin = whiteNoise({'binary',0,1,.5},background,method,stimLocation,stixelSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

%big grid - gaussian and many sparse types
stixelSize = [128,128]; %[32 32] [xPix yPix]
%stixelSize = [64,64]; %[32 32] [xPix yPix]
numFrames=2000;   %1000 if limited mempry for trig 4 large stims
gwn = whiteNoise({'gaussian',gray,std},background,method,stimLocation,stixelSize,searchSubspace,5,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
bin = whiteNoise({'binary',0,1,.5},background,method,stimLocation,stixelSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

bin3x4 = whiteNoise({'binary',0,1,.5},background,method,stimLocation,[256 256],searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
bin6x8 = whiteNoise({'binary',0,1,.5},background,method,stimLocation,[128 128],searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
bin12x16 = whiteNoise({'binary',0,1,.5},background,method,stimLocation,[64 64],searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
bin24x32 = whiteNoise({'binary',0,1,.5},background,method,stimLocation,[32 32],searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
bin48x64= whiteNoise({'binary',0,1,.5},background,method,stimLocation,[16 16],searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
binOther = whiteNoise({'binary',0,1,.5},background,method,stimLocation,[200 200],searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

sparseness=0.05; %sparseness
sparseBright=whiteNoise({'binary',0.5,1,sparseness},background,method,stimLocation,stixelSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
sparseDark=whiteNoise({'binary',0,0.5,1-sparseness},background,method,stimLocation,stixelSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
sparseBrighter=whiteNoise({'binary',0,1,sparseness},background,method,stimLocation,stixelSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

% bars are black and white sparsely white like sparseBrighter
barSize=stixelSize; barSize(1)=maxWidth;
horizBars=whiteNoise({'binary',0,1,sparseness},background,method,stimLocation,barSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
barSize=stixelSize; barSize(2)=maxHeight;
vertBars=whiteNoise({'binary',0,1,sparseness},background,method,stimLocation,barSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

%changeable solid bars
changeable=true;
background=0;
barSize=stixelSize; barSize(1)=maxWidth; stimLocation= [0 maxHeight 0 maxHeight]/2+[ 0 0 barSize] ;% put bar in center
horizBar=whiteNoise({'binary',0,1,1},background,method,stimLocation,barSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
barSize=stixelSize; barSize(2)=maxHeight; stimLocation= [maxWidth 0 maxWidth 0 ]/2+[ 0 0 barSize] ;% put bar in center
vertBar=whiteNoise({'binary',0,1,1},background,method,stimLocation,barSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

%changeable small grid 
background=0.5;
frac=1/4; % fraction of the screen
stimLocation=[maxWidth*(1-frac)/2,maxHeight*(1-frac)/2,maxWidth*(1+frac)/2,maxHeight*(1+frac)/2]; % in center
boxSize=[maxWidth maxHeight]*frac;
darkBox=whiteNoise({'binary',0,1,0},background,method,stimLocation,boxSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
brightBox=whiteNoise({'binary',0,1,1},background,method,stimLocation,boxSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
brighterBox=whiteNoise({'binary',0,1,1},0,method,stimLocation,boxSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
flickeringBox=whiteNoise({'binary',0,1,.5},background,method,stimLocation,boxSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
% has small pixels in limted spatial region... using mean background and BW stixels 
localizedBin=whiteNoise({'binary',0,1,.5},background,method,stimLocation,stixelSize,searchSubspace,numFrames,changeable,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

%toDo:
% compute kinds:  temporal, spatial, vertBars, horizBars


%% trial / sound / reinforcement managers

% if dataNetOn
%       ai_parameters.numChans=3;
%             ai_parameters.sampRate=40000;
%             ai_parameters.inputRanges=repmat([-1 6],ai_parameters.numChans,1);
%             dn=datanet('stim','localhost','132.239.158.179','\\132.239.158.179\datanet_storage',ai_parameters)
% else
%     dn=[];
% end
% 
% if eyeTrackerOn
%    alpha=12; %deg above...really?
%    beta=0;   %deg to side... really?
%    settingMethod='none';  % will run with these defaults without consulting user, else 'guiPrompt'
%    eyeTracker=geometricTracker('cr-p', 2, 3, alpha, beta, int16([1280,1024]), [42,28], int16([maxWidth,maxHeight]), [400,290], 300, -55, 0, 45, 0,settingMethod,10000); % changing calibration params we be updated by user on startup
% else
%    eyeTracker=[];
% end
eyeController=[];

sm=makeStandardSoundManager();


rewardSizeULorMS        =150;
requestRewardSizeULorMS =50;
requestMode='first';
msPenalty               =1000;
fractionOpenTimeSoundIsOn=1;
fractionPenaltySoundIsOn=1;
scalar=1;
msAirpuff=msPenalty;
constantRewards=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

percentCorrectionTrials=.5;
frameDropCorner=false;
dropFrames=false;
frameDropCorner={'off'};
displayMethod='ptb';
requestPort='center'; 

saveDetailedFramedrops=false;  % default is false... do we want this info, yes if few of them
delayManager=[];
responseWindowMs=[];
showText='light';
afc=nAFC(sm,percentCorrectionTrials,constantRewards,eyeController,frameDropCorner,dropFrames,displayMethod,requestPort,saveDetailedFramedrops,delayManager,responseWindowMs,showText);
requestPort='none'; 
allowRepeats=false;
ap=autopilot(percentCorrectionTrials,sm,constantRewards,eyeController,frameDropCorner,dropFrames,displayMethod,requestPort,saveDetailedFramedrops,delayManager,responseWindowMs,showText);

freeDrinkLikelihood=0.003;
fd = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,constantRewards,eyeController,frameDropCorner,dropFrames,displayMethod,requestPort);
freeDrinkLikelihood=0;
fd2 = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,constantRewards,eyeController,frameDropCorner,dropFrames,displayMethod,requestPort);

rfIsGood=receptiveFieldCriterion(0.05,RFdataSource,1,'box',3);

numSweeps=int8(3);
cmr = manualCmrMotionEyeCal(background,numSweeps,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

%% trainingsteps

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';

%Search stim
ts{1}= trainingStep(ap,  fakeTRFSlow, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);       %temporal response function only slow temp freqs
ts{2} = trainingStep(ap, sfGratings,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);  %gratings: spatial frequency (should it be before annulus?)
ts{3} = trainingStep(ap,  fakeTRF10,  numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %temporal response function
ts{4} = trainingStep(ap, sfGratings,  numTrialsDoneCriterion(2), noTimeOff(), svnRev, svnCheckMode);  %gratings: spatial frequency (should it be before annulus?)
ts{5} = trainingStep(ap, orGratings,  numTrialsDoneCriterion(2), noTimeOff(), svnRev, svnCheckMode);  %gratings: orientation
ts{6} = trainingStep(ap, bigSlowSquare,numTrialsDoneCriterion(1),    noTimeOff(), svnRev, svnCheckMode);  %flankersTestFlicker
ts{7}= trainingStep(ap,  ffgwn,       numTrialsDoneCriterion(10), noTimeOff(), svnRev, svnCheckMode); %full field gaussian white noise
ts{8}= trainingStep(ap,  bin,         numTrialsDoneCriterion(10), noTimeOff(), svnRev, svnCheckMode); %binary noise grid
ts{9} = trainingStep(ap, bin12x16,numTrialsDoneCriterion(15),    noTimeOff(), svnRev, svnCheckMode);  %flankersTestFlicker
ts{10} = trainingStep(ap, bin24x32,numTrialsDoneCriterion(15),    noTimeOff(), svnRev, svnCheckMode);  %flankersTestFlicker

% %common "search and characterization"
% ts{1}= trainingStep(ap,  fakeTRF,     repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);       %temporal response function
% ts{2}= trainingStep(ap,  ffgwn,       repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);       %full field gaussian white noise
% ts{3}= trainingStep(ap,  bin,         repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);       %binary noise grid
% ts{4}= trainingStep(ap,  fakeTRF10,   numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %temporal response function
% ts{5}= trainingStep(ap,  ffgwn,       numTrialsDoneCriterion(10), noTimeOff(), svnRev, svnCheckMode); %full field gaussian white noise
% ts{6}= trainingStep(ap,  bin,         numTrialsDoneCriterion(10), noTimeOff(), svnRev, svnCheckMode); %binary noise grid
% ts{7} = trainingStep(ap, flankersFF,  numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %flankers with giant target
% ts{8} = trainingStep(ap, sfGratings,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);  %gratings: spatial frequency (should it be before annulus?)
% ts{9} = trainingStep(ap, orGratings,   repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);  %gratings: orientation
% 
% %check if it drives
% ts{10}= trainingStep(ap, sparseBrighter,repeatIndefinitely(),noTimeOff(),svnRev, svnCheckMode);  %
% ts{11}= trainingStep(ap, horizBars,   repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);  %
% ts{12}= trainingStep(ap, vertBars,    repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);  %
% ts{13}= trainingStep(ap, gwn,         repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);  %
% ts{14}= trainingStep(ap, sparseDark,  numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %
% ts{15}= trainingStep(ap, sparseBright,numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %
% 
% %search tools
% ts{16}= trainingStep(ap, darkBox,     numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %
% ts{17}= trainingStep(ap, brighterBox, numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %
% ts{18}= trainingStep(ap, horizBar,    numTrialsDoneCriterion(2), noTimeOff(), svnRev, svnCheckMode);  %
% ts{19}= trainingStep(ap, vertBar,     numTrialsDoneCriterion(5), noTimeOff(), svnRev, svnCheckMode);  %
% ts{20}= trainingStep(ap, flickeringBox,numTrialsDoneCriterion(2),noTimeOff(), svnRev, svnCheckMode);  %
% ts{21}= trainingStep(ap, localizedBin,repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);  %
% ts{22}= trainingStep(ap, bin,         repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  % catch and repeat here forever
% 
% %might get crude RF estimate and use:
% ts{23} = trainingStep(ap, manAnGratings,numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %gratings: annulus size
% ts{24} = trainingStep(ap, anGratings,  numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %gratings: annulus size
% ts{25} = trainingStep(ap, flankers,    repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);  %flankers
% ts{26} = trainingStep(ap, anGratings,  numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %gratings: annulus size
% ts{27} = trainingStep(ap, biField,     numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %bipartite field for X-Y classification
% 
% %xtra stuff might want:
% %ts{26} = trainingStep(ap, dynGrating,  repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  %tailored to this cell
% %ts{27} = trainingStep(ap, hateren,     repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  %hateren
% ts{28} = trainingStep(ap, fTestFlicker,repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  %flankersTestFlicker
% ts{29} = trainingStep(ap, searchGratings,repeatIndefinitely(),    noTimeOff(), svnRev, svnCheckMode);  %flankersTestFlicker
% ts{30} = trainingStep(ap, bigSlowSquare,repeatIndefinitely(),    noTimeOff(), svnRev, svnCheckMode);  %flankersTestFlicker
% 
% ts{31} = trainingStep(ap, bin3x4,repeatIndefinitely(),    noTimeOff(), svnRev, svnCheckMode);  %flankersTestFlicker
% ts{32} = trainingStep(ap, bin6x8,repeatIndefinitely(),    noTimeOff(), svnRev, svnCheckMode);  %flankersTestFlicker
% ts{33} = trainingStep(ap, bin12x16,repeatIndefinitely(),    noTimeOff(), svnRev, svnCheckMode);  %flankersTestFlicker
% ts{34} = trainingStep(ap, bin24x32,repeatIndefinitely(),    noTimeOff(), svnRev, svnCheckMode);  %flankersTestFlicker
% 
% ts{35}= trainingStep(ap, bin48x64,    repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  % catch and repeat here forever
% ts{36}= trainingStep(ap, binOther,    repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  % catch and repeat here forever
% ts{37}= trainingStep(ap, ffbin,       repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  % catch and repeat here forever
% ts{38}= trainingStep(ap, cmr,         repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  % catch and repeat here forever
% 
% %removed things b/c not used enough:
% % ts{10}= trainingStep(afc, radGratings, numTrialsDoneCriterion(2), noTimeOff(), svnRev, svnCheckMode);  %gratings: radius
% % ts{11}= trainingStep(afc, cntrGratings,numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %gratings: contrast
% % ts{2} = trainingStep(fd2, crf,       numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %contrast response
% % ts{20}= trainingStep(afc, gaussNoise,  numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %unfilteredNoise discrim
% % ts{22}= trainingStep(afc, trf,         numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %temporal reponse
% % ts{24}= trainingStep(ap, gaussNoise,  numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %unfilteredNoise discrim
% % ts{25}= trainingStep(ap, ffSearch,    numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %full field search
% 
% %common "acclimate a rat":
% % ts{26}   = trainingStep(afc, goToSide, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %go to side
% % ts{27}  = trainingStep(fd,  freeStim, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %stochastic free drinks
% % ts{28}  = trainingStep(fd2, freeStim, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %free drinks
% 
% %other ideas:
% %ts{29} = trainingStep(ap, ffGauss,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %fullfieldFlicker Gaussian
% % ts{31} = trainingStep(ap, rptUnq,   repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %rpt/unq
% % ts{32} = trainingStep(ap, orNoise,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %filteredNoise discrim
% % ts{33} = trainingStep(ap, binNoise, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %unfilteredNoise discrim
% 

%% make and set it


p=protocol('practice phys',{ts{1:10}});
stepNum=uint8(5);

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolPhys','pmm');
end
