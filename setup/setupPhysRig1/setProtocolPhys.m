function r = setProtocolPhys(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

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

vh=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,constantRewards);

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
discrimStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);





ports=cellfun(@uint8,{1 3},'UniformOutput',false);
[noiseSpec(1:length(ports)).port]=deal(ports{:});

% stim properties:
% in.distribution               'gaussian', 'binary', 'uniform', or a path to a file name (either .txt or .mat, extension omitted, .txt loadable via load(), and containing a single vector of numbers named 'noise')
% in.origHz                     only used if distribution is a file name, indicating sampling rate of file
% in.contrast                   std dev in normalized luminance units (just counting patch, before mask application), values will saturate
% in.loopDuration               in seconds (will be rounded to nearest multiple of frame duration, if distribution is a file, pass 0 to loop the whole file instead of a random subset)

[noiseSpec.distribution]         =deal('gaussian');
[noiseSpec.origHz]               =deal(0);
[noiseSpec.contrast]             =deal(pickContrast(.5,.01));
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

maxWidth               = 800;
maxHeight              = 600;
scaleFactor            = 0;

noiseStim=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);





[noiseSpec.orientation]          =deal(0);
[noiseSpec.distribution]         =deal('binary');
[noiseSpec.contrast]             =deal(1);
[noiseSpec.maskRadius]           =deal(100);
[noiseSpec.kernelSize]           =deal(0);
[noiseSpec.kernelDuration]       =deal(0);
[noiseSpec.ratio]                =deal(1);
[noiseSpec.filterStrength]       =deal(0);
[noiseSpec.patchDims]            =deal(uint16([100 100]));

unfilteredNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);




if ismac
    ts001 = '/Users/eflister/Desktop/ratrix trunk/classes/protocols/stimManagers/@flicker/ts001';
else
    ts001 = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\hateren\ts001';
end

[noiseSpec.distribution]         =deal(ts001);
[noiseSpec.origHz]               =deal(1200);
[noiseSpec.loopDuration]         =deal(30);

hateren=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);



if ismac
    TRF_CRF = '/Volumes/RLAB/Rodent-Data/pmeier/stimSequence/TRF_CRF_v3';
else
    TRF_CRF = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\pmeier\stimSequence\TRF_CRF_v3';
end

[noiseSpec.distribution]         =deal(TRF_CRF);
[noiseSpec.origHz]               =deal(100);
[noiseSpec.loopDuration]         =deal(10);
[noiseSpec.patchDims]            =deal(uint16([1 1]));

crf_trf=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[1 5 10 20 30 50 100],[.1 .25 .5 .75 1],.1}); %temporal freqs, contrasts, gapSecs
[noiseSpec.origHz]               =deal(0);
[noiseSpec.loopDuration]         =deal(60);

crf_trf_better=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


[noiseSpec.distribution]         =deal('gaussian');
[noiseSpec.contrast]             =deal(pickContrast(.5,.01));
[noiseSpec.loopDuration]         =deal(5*60);

fullfieldFlicker=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);




svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};


ts1 = trainingStep(fd, freeStim, repeatIndefinitely(), noTimeOff(), svnRev);   %stochastic free drinks
ts2 = trainingStep(fd2, freeStim, repeatIndefinitely(), noTimeOff(), svnRev);  %free drinks
ts3 = trainingStep(vh, discrimStim, repeatIndefinitely(), noTimeOff(), svnRev);%orientation discrim
ts4 = trainingStep(vh, noiseStim,  repeatIndefinitely(), noTimeOff(), svnRev); %filteredNoise discrim
ts5 = trainingStep(vh, unfilteredNoise,  repeatIndefinitely(), noTimeOff(), svnRev); %unfilteredNoise discrim
ts6 = trainingStep(vh, fullfieldFlicker,  repeatIndefinitely(), noTimeOff(), svnRev); %fullfieldFlicker
ts7 = trainingStep(vh, hateren,  repeatIndefinitely(), noTimeOff(), svnRev); %hateren
ts8 = trainingStep(vh, crf_trf,  repeatIndefinitely(), noTimeOff(), svnRev); %crf_trf (from file)
ts9 = trainingStep(vh, crf_trf_better,  repeatIndefinitely(), noTimeOff(), svnRev); %crf_trf (dynamic)

p=protocol('practice phys',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8, ts9});
stepNum=6;

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolPhys','edf');
end