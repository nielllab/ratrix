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



noiseSpec.orientations           = {-pi/4 [] pi/4};
noiseSpec.locationDistributions  = {1 [] 1};
noiseSpec.distribution           = 'gaussian';
noiseSpec.origHz                 = 0;
noiseSpec.background             = .5;
noiseSpec.contrast               = pickContrast(.5,.01);
noiseSpec.maskRadius             = 10;
noiseSpec.patchDims              = uint16([50 50]);
noiseSpec.patchHeight            = 1;
noiseSpec.patchWidth             = 1;
noiseSpec.kernelSize             = .5;
noiseSpec.kernelDuration         = .1;
noiseSpec.loopDuration           = 1;
noiseSpec.ratio                  = 1/3;
noiseSpec.filterStrength         = 1;
noiseSpec.bound                  = .99;
noiseSpec.maxWidth               = 800;
noiseSpec.maxHeight              = 600;
noiseSpec.scaleFactor            = 0;
noiseSpec.interTrialLuminance    = interTrialLuminance;

noiseStim=filteredNoise(noiseSpec);


noiseSpec.orientations           = {0 [] 0};
noiseSpec.locationDistributions  = {1 [] 1};
noiseSpec.distribution           = 'binary';
noiseSpec.contrast               = 1;
noiseSpec.maskRadius             = 100;
noiseSpec.kernelSize             = 0;
noiseSpec.kernelDuration         = 0;
noiseSpec.loopDuration           = 1;
noiseSpec.ratio                  = 1;
noiseSpec.filterStrength         = 0;
noiseSpec.patchDims              = uint16([100 100]);
noiseSpec.patchHeight            = 1;
noiseSpec.patchWidth             = 1;

unfilteredNoise=filteredNoise(noiseSpec);


noiseSpec.distribution           = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\hateren\ts001';
noiseSpec.origHz                 = 1200;
noiseSpec.loopDuration           = 30;

hateren=filteredNoise(noiseSpec);


noiseSpec.distribution           = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\pmeier\stimSequence\TRF_CRF_v3';
noiseSpec.origHz                 = 100;
noiseSpec.loopDuration           = 10;

crf_trf=filteredNoise(noiseSpec);


noiseSpec.locationDistributions  = {1 [] 1};
noiseSpec.distribution           = 'gaussian';
noiseSpec.contrast               = pickContrast(.5,.01);
noiseSpec.patchDims              = uint16([1 1]);
noiseSpec.patchHeight            = 1;
noiseSpec.patchWidth             = 1;
noiseSpec.loopDuration           = 5*60;

fullfieldFlicker=filteredNoise(noiseSpec);

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};


ts1 = trainingStep(fd, freeStim, repeatIndefinitely(), noTimeOff(), svnRev);   %stochastic free drinks
ts2 = trainingStep(fd2, freeStim, repeatIndefinitely(), noTimeOff(), svnRev);  %free drinks
ts3 = trainingStep(vh, discrimStim, repeatIndefinitely(), noTimeOff(), svnRev);%orientation discrim
ts4 = trainingStep(vh, noiseStim,  repeatIndefinitely(), noTimeOff(), svnRev); %filteredNoise discrim
ts5 = trainingStep(vh, unfilteredNoise,  repeatIndefinitely(), noTimeOff(), svnRev); %unfilteredNoise discrim
ts6 = trainingStep(vh, fullfieldFlicker,  repeatIndefinitely(), noTimeOff(), svnRev); %fullfieldFlicker
ts7 = trainingStep(vh, hateren,  repeatIndefinitely(), noTimeOff(), svnRev); %hateren
ts8 = trainingStep(vh, hateren,  repeatIndefinitely(), noTimeOff(), svnRev); %hateren

p=protocol('practice phys',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8});
stepNum=6;

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolPhys','edf');
end