function r = setProtocolPhys2(r,subjIDs,dataNetOn,eyeTrackerOn)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

if ~exist('dataNetOn','var') || isempty(dataNetOn)
     dataNetOn=0;
end

if ~exist('eyeTrackerOn','var') || isempty(eyeTrackerOn)
     eyeTrackerOn=0;
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
pixPerCycs=2.^([2:9]); % freq
driftfrequencies=[2];  % in cycles per second
orientations=[pi/2];   % in radians
phases=[0];            % initial phase
contrasts=[0.5];         % contrast of the grating
durations=[3];         % duration of each grating
radius=2;              % radius of the circular mask, 2= twice screen hieght
annuli=0;              % radius of inner annuli
location=[.5 .5];      % center of mask
waveform='square';     
normalizationMethod='normalizeDiagonal';
mean=0.5;
numRepeats=3;
scaleFactor             =0;
sfGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

numOrientations=8;
orientations=([2*pi]*[1:numOrientations])/numOrientations; % in radians
pixPerCycs=2^9;%temp [64];  % reset to one value
orGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

numContrasts=6;
contrasts=1./2.^[0:numContrasts-1]; % contrast of the grating
orientations=[pi/2]; % reset to one value
cntrGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

numAnulli=8;
annuli=[0.02 0.05 .1 .2 .3 .4 .5 2]; % annulus of the grating
contrasts=1; % reset to one value

if dataNetOn 
     RFdataSource='\\132.239.158.179\datanet_storage'; % good only as long as default stations don't change, %how do we get this from the dn in the station!?
     location = RFestimator({'spatialWhiteNoise','fitGaussian',{3}},{'gratings','ttestF1',{0.05,'fft'}},[],RFdataSource,[now-100 Inf]);
     %location = RFestimator({'whiteNoise','fitGaussianSigEnvelope',{3,0.05,logical(ones(3))}},{'gratings','ttestF1',{0.05,'fft'}},[],RFdataSource,[now-100 Inf]);
end
anGratings = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


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

[noiseSpec.distribution]         =deal({'gaussian',.01});
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
[noiseSpec.patchDims]            =deal(uint16([32 24]));

gaussNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal('binary');
[noiseSpec.contrast]             =deal(1);

binNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

if ismac
    ts001 = '/Users/eflister/Desktop/ratrix trunk/classes/protocols/stimManagers/@flicker/ts001';
else
    ts001 = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\hateren\ts001';
end
[noiseSpec.distribution]         =deal({ts001, 1200, .01, 'ptile'});
[noiseSpec.loopDuration]         =deal({uint32(60) uint32(0) uint32(1) uint32(30)}); %{numRepeats numUniques numCycles chunkSeconds}

hateren=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[4 8],1,.1}); %temporal freqs, contrasts, gapSecs
[noiseSpec.origHz]               =deal(0);
[noiseSpec.loopDuration]         =deal(10);

ffSearch=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[10],[.1 .25 .5 .75 1],.1}); %temporal freqs, contrasts, gapSecs
[noiseSpec.loopDuration]         =deal(10);

crf=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[1 2 4 8 32 50],1,.1}); %temporal freqs, contrasts, gapSecs

trf=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({'gaussian', .01});
[noiseSpec.loopDuration]         =deal(1*60);

ffGauss=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({ts001, 1200, .01, 'ptile'});
[noiseSpec.loopDuration]         =deal({uint32(4) uint32(1) uint32(50) uint32(8)}); %{numRepeats numUniques numCycles chunkSeconds}
[noiseSpec.contrast]             =deal(1);
[noiseSpec.startFrame]           =deal(uint8(1));

rptUnq=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);



%flankers
flankers=ifFeatureGoRightWithTwoFlank('phys');
flankersFF=ifFeatureGoRightWithTwoFlank('physFullFieldTarget');
prm=getDefaultParameters(ifFeatureGoRightWithTwoFlank, 'goToSide','1_0','Oct.09,2007');



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
stixelSize = [32,32];
stimLocation=[0,0,maxWidth,maxHeight];
numFrames=1000;   %100 to test; 5*60*100=30000 for experiment
% s = whiteNoise(meanLuminance,std,background,method,requestedStimLocation,stixelSize,searchSubspace,numFrames,
%       maxWidth,maxHeight,scaleFactor,interTrialLuminance)
wn = whiteNoise(mean,std,background,method,stimLocation,stixelSize,searchSubspace,numFrames,1280,1024,0,.5);

numFrames=3000; 
stixelSize = [maxWidth,maxHeight];
ffwn = whiteNoise(mean,std,background,method,stimLocation,stixelSize,searchSubspace,numFrames,1280,1024,0,.5);


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

sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});

rewardSizeULorMS        =150;
requestRewardSizeULorMS =50;
requestMode='first';
msPenalty               =1000;
fractionOpenTimeSoundIsOn=1;
fractionPenaltySoundIsOn=1;
scalar=1;
msAirpuff=msPenalty;
constantRewards=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

freeDrinkLikelihood=0.003;
fd = freeDrinks(sm,freeDrinkLikelihood,constantRewards);

freeDrinkLikelihood=0;
fd2 = freeDrinks(sm,freeDrinkLikelihood,constantRewards);


percentCorrectionTrials=.5;
frameDropCorner=false;
dropFrames=false;
frameDropCorner={'off'};
displayMethod='ptb';
requestPort='center'; 
afc=nAFC(sm,percentCorrectionTrials,constantRewards,eyeController,frameDropCorner,dropFrames,displayMethod,requestPort);
requestPort='none'; 
ap=autopilot(percentCorrectionTrials,sm,constantRewards,eyeController,frameDropCorner,dropFrames,displayMethod,requestPort);





%% trainingsteps

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';

%common "search and characterization"
ts{1} = trainingStep(afc, ffwn,        repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  %unfilteredNoise discrim
ts{2} = trainingStep(afc, crf,         repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  %contrast response
ts{3} = trainingStep(afc, flankersFF,  repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  %flankers with giant target
ts{4} = trainingStep(afc, wn,          repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  %unfilteredNoise discrim
ts{5} = trainingStep(afc, anGratings,  repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  %gratings: annulus size
ts{6} = trainingStep(afc, flankers,    repeatIndefinitely(),      noTimeOff(), svnRev, svnCheckMode);  %flankers
ts{7} = trainingStep(afc, biField,     numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %bipartite field for X-Y classification
ts{8} = trainingStep(afc, sfGratings,  numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %gratings: spatial frequency (should it be before annulus?)
ts{9} = trainingStep(afc, orGratings,  numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %gratings: orientation

ts{10}= trainingStep(afc, trf,         numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %temporal reponse
ts{11}= trainingStep(afc, cntrGratings,numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %gratings: contrast
ts{12}= trainingStep(afc, gaussNoise,  numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %unfilteredNoise discrim
ts{13}= trainingStep(afc, ffSearch,    numTrialsDoneCriterion(1), noTimeOff(), svnRev, svnCheckMode);  %full field search

%common "acclimate a rat"
%=setFlankerStimRewardAndTrialManager(prm, 'flanker go to side');
ts{14}   = trainingStep(afc, goToSide, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %go to side
ts{15}  = trainingStep(fd,  freeStim, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %stochastic free drinks
ts{16}  = trainingStep(fd2, freeStim, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %free drinks

%common "lots of data collection"
ts{17} = trainingStep(afc, ffGauss,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %fullfieldFlicker Gaussian
ts{18} = trainingStep(afc, hateren,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %hateren


ts{19} = trainingStep(afc, rptUnq,   repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %rpt/unq
ts{20} = trainingStep(afc, orNoise,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %filteredNoise discrim
ts{21} = trainingStep(ap,  binNoise, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);   %unfilteredNoise discrim


%% make and set it


p=protocol('practice phys',{ts{1:21}});
stepNum=uint8(6);

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolPhys','pmm');
end
