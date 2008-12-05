function r = setProtocolDEMO(r,subjIDs)

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

rewardSizeULorMS        =50;
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

ims=fullfile('Rodent-Data','PriyaV','other stimuli sets','paintbrush_flashlight'); %'\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\other stimuli sets\paintbrushMORPHflashlightEDF';
if ispc
    imageDir=fullfile('\\Reinagel-lab.ad.ucsd.edu','rlab',ims);
elseif ismac
    imageDir=fullfile('/Volumes','RLAB',ims);
else
    error('only works on windows and mac')
end

background=0;
ypos=0;
ims=dir(fullfile(imageDir,'*.png'));
if isempty(ims)
    error('couldn''t find image directory')
end

trialDistribution={};
for i=1:floor(length(ims)/2)
    [junk n1 junk junk]=fileparts(ims(i).name);
    [junk n2 junk junk]=fileparts(ims(length(ims)-(i-1)).name);
    trialDistribution{end+1}={{n1 n2} 1};
end
imageStim = images(imageDir,ypos,background,maxWidth,maxHeight,scaleFactor,interTrialLuminance,trialDistribution);


d=2; %decrease to broaden
gran=100;
x=linspace(-d,d,gran);
[a b]=meshgrid(x);

noiseSpec.orientations           = {-pi/4 [] pi/4};
noiseSpec.locationDistributions  = {reshape(mvnpdf([a(:) b(:)],[-d/2 d/2]),gran,gran) [] reshape(mvnpdf([a(:) b(:)],[d/2 d/2]),gran,gran)};
noiseSpec.distribution           = 'gaussian';
noiseSpec.origHz                 = 0;
noiseSpec.background             = .5;
noiseSpec.contrast               = pickContrast(.5,.01);
noiseSpec.maskRadius             = .045;
noiseSpec.patchDims              = uint16([50 50]);
noiseSpec.patchHeight            = .4;
noiseSpec.patchWidth             = .4;
noiseSpec.kernelSize             = .5;
noiseSpec.kernelDuration         = .2;
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
noiseSpec.locationDistributions  = {[0 0;1 0] [] [0 0;0 1]};
noiseSpec.distribution           = 'binary';
noiseSpec.contrast               = 1;
noiseSpec.maskRadius             = 100;
noiseSpec.kernelSize             = 0;
noiseSpec.kernelDuration         = 0;
noiseSpec.loopDuration           = 1;
noiseSpec.ratio                  = 1;
noiseSpec.filterStrength         = 0;
noiseSpec.patchDims              = uint16([2 2]);
noiseSpec.patchHeight            = .1;
noiseSpec.patchWidth             = .1;

unfilteredNoise=filteredNoise(noiseSpec);


noiseSpec.distribution           ='\\Reinagel-lab.AD.ucsd.edu\RLAB\Rodent-Data\hateren\ts001';% '/Users/eflister/Desktop/ratrix trunk/classes/protocols/stimManagers/@flicker/ts001';
noiseSpec.origHz                 = 1200;
noiseSpec.loopDuration           = 30;

hateren=filteredNoise(noiseSpec);


noiseSpec.locationDistributions  = {1 [] 1};
noiseSpec.distribution           = 'gaussian';
noiseSpec.contrast               = pickContrast(.5,.01);
noiseSpec.patchDims              = uint16([1 1]);
noiseSpec.patchHeight            = .5;
noiseSpec.patchWidth             = .5;

fullfieldFlicker=filteredNoise(noiseSpec);


svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};

ts1 = trainingStep(fd, freeStim, repeatIndefinitely(), noTimeOff(), svnRev);   %stochastic free drinks
ts2 = trainingStep(fd2, freeStim, repeatIndefinitely(), noTimeOff(), svnRev);  %free drinks
ts3 = trainingStep(vh, freeStim, repeatIndefinitely(), noTimeOff(), svnRev);   %go to stim
ts4 = trainingStep(vh, discrimStim, repeatIndefinitely(), noTimeOff(), svnRev);%orientation discrim
ts5 = trainingStep(vh, imageStim,  repeatIndefinitely(), noTimeOff(), svnRev); %morph discrim
ts6 = trainingStep(vh, noiseStim,  repeatIndefinitely(), noTimeOff(), svnRev); %filteredNoise discrim
ts7 = trainingStep(vh, unfilteredNoise,  repeatIndefinitely(), noTimeOff(), svnRev); %unfiltered goToSide
ts8 = trainingStep(vh, fullfieldFlicker,  repeatIndefinitely(), noTimeOff(), svnRev); %fullfieldFlicker
ts9 = trainingStep(vh, hateren,  repeatIndefinitely(), noTimeOff(), svnRev); %hateren

p=protocol('gabor test',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8, ts9});
stepNum=8;

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolDEMO','edf');
end