function r = setProtocolEDFtemp(r,subjIDs)

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

requestRewardSizeULorMS=10;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;

interTrialLuminance     =.5;

vh=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,constantRewards);

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


svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};

ts1 = trainingStep(vh, noiseStim,  repeatIndefinitely(), noTimeOff(), svnRev); %filteredNoise discrim


p=protocol('gabor test',{ts1});
stepNum=1;

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolEDFtemp','edf');
end