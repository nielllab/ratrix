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

rewardSizeULorMS          =50;
requestRewardSizeULorMS   =10;
requestMode               ='first'; 
msPenalty                 =1000;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;

constantRewards=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

freeDrinkLikelihood=0.003;
fd = freeDrinks(sm,freeDrinkLikelihood,constantRewards);

freeDrinkLikelihood=0;
fd2 = freeDrinks(sm,freeDrinkLikelihood,constantRewards);

percentCorrectionTrials=.5;

maxWidth               = 800;
maxHeight              = 600;

eyetrack=false;
if eyetrack
    alpha=12; %deg above...really?
    beta=0;   %deg to side... really?
    settingMethod='none';  % will run with these defaults without consulting user, else 'guiPrompt'
    eyeTracker=geometricTracker('cr-p', 2, 3, alpha, beta, int16([1280,1024]), [42,28], int16([maxWidth,maxHeight]), [400,290], 300, -55, 0, 45, 0,settingMethod,10000);
else
    eyeTracker=[];
end
eyeController=[];

dataNetOn=false;
if dataNetOn
    ai_parameters.numChans=3;
    ai_parameters.sampRate=40000;
    ai_parameters.inputRanges=repmat([-1 6],ai_parameters.numChans,1);
    dn=datanet('stim','localhost','132.239.158.179','\\132.239.158.179\datanet_storage',ai_parameters)
else
    dn=[];
end

% {'flickerRamp',[0 .5]}
vh=nAFC(sm,percentCorrectionTrials,constantRewards,eyeController,{'off'},true,'ptb','center');

pixPerCycs              =[20];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =.04;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65;
%screen('resolutions') returns values too high for our NEC MultiSync FE992's -- it must just consult graphics card
scaleFactor            = 0; %[1 1];
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
imageStim = images(imageDir,ypos,background,maxWidth,maxHeight,scaleFactor,interTrialLuminance,trialDistribution,'normal',[1 1],false,[0 0],false);

d=2; %decrease to broaden
gran=100;
x=linspace(-d,d,gran);
[a b]=meshgrid(x);

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
% in.numLoops                   must be >0 or inf, fractional values ok (will be rounded to nearest frame)

[noiseSpec.distribution]         =deal({'gaussian' .01});
[noiseSpec.startFrame]           =deal(uint8(1)); %deal('randomize');
[noiseSpec.loopDuration]         =deal(1);
[noiseSpec.numLoops]             =deal(inf);

% patch properties:
% in.locationDistribution       2-d density, will be normalized to stim area
% in.maskRadius                 std dev of the enveloping gaussian, normalized to diagonal of stim area (values <=0 mean no mask)
% in.patchDims                  [height width]
% in.patchHeight                0-1, normalized to stim area height
% in.patchWidth                 0-1, normalized to stim area width
% in.background                 0-1, normalized (luminance outside patch)

[noiseSpec.locationDistribution]=deal(reshape(mvnpdf([a(:) b(:)],[-d/2 d/2]),gran,gran),reshape(mvnpdf([a(:) b(:)],[d/2 d/2]),gran,gran));
[noiseSpec.maskRadius]           =deal(0.06);%.045);
[noiseSpec.patchDims]            =deal(uint16([50 50]));
[noiseSpec.patchHeight]          =deal(.4);
[noiseSpec.patchWidth]           =deal(.4);
[noiseSpec.background]           =deal(.5);

% filter properties:
% in.orientation                filter orientation in radians, 0 is vertical, positive is clockwise
% in.kernelSize                 0-1, normalized to diagonal of patch
% in.kernelDuration             in seconds (will be rounded to nearest multiple of frame duration)
% in.ratio                      ratio of short to long axis of gaussian kernel (1 means circular, no effective orientation)
% in.filterStrength             0 means no filtering (kernel is all zeros, except 1 in center), 1 means pure mvgaussian kernel (center not special), >1 means surrounding pixels more important
% in.bound                      .5-1 edge percentile for long axis of kernel when parallel to window

[noiseSpec.orientation]         =deal(-pi/4,pi/4);
[noiseSpec.kernelSize]           =deal(.5);
[noiseSpec.kernelDuration]       =deal(.2);
[noiseSpec.ratio]                =deal(1/3);
[noiseSpec.filterStrength]       =deal(1);
[noiseSpec.bound]                =deal(.99);

noiseStim=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.orientation]         =deal(0);
[noiseSpec.locationDistribution]=deal([0 0;1 0], [0 0;0 1]);
[noiseSpec.distribution]         =deal('binary');
[noiseSpec.maskRadius]           =deal(100);
[noiseSpec.kernelSize]           =deal(0);
[noiseSpec.kernelDuration]       =deal(0);
[noiseSpec.ratio]                =deal(1);
[noiseSpec.filterStrength]       =deal(0);
[noiseSpec.patchDims]            =deal(uint16([2 2]));
[noiseSpec.patchHeight]          =deal(.1);
[noiseSpec.patchWidth]           =deal(.1);

unfilteredNoise=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

led=nAFC(sm,percentCorrectionTrials,constantRewards,eyeController,{'off'},false,'LED','center');

if ismac
    ts001 = '/Users/eflister/Desktop/ratrix trunk/classes/protocols/stimManagers/@flicker/ts001';
else
    ts001 = '\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\hateren\ts001';
end

[noiseSpec.distribution]         =deal({ts001, 1200, .01, 'ptile'}); %12800/32767 for normalized clipVal, see pam email to Alex Casti on January 25, 2005, and Reinagel Reid 2000
[noiseSpec.loopDuration]         =deal({uint32(60) uint32(0) uint32(1) uint32(30)}); %{numRepeats numUniques numCycles chunkSeconds}


[noiseSpec.locationDistribution]=deal(1);
[noiseSpec.patchDims]            =deal(uint16([1 1]));
[noiseSpec.patchHeight]          =deal(1);
[noiseSpec.patchWidth]           =deal(1);

hateren=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({'gaussian', .01});

fullfieldFlicker=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

[noiseSpec.distribution]         =deal({'sinusoidalFlicker',[1 5 10 25 50],[.1 .25 .5 .75 1],.1}); %temporal freqs, contrasts, gapSecs
[noiseSpec.loopDuration]         =deal(5*5*1);
[noiseSpec.patchHeight]          =deal(1);
[noiseSpec.patchWidth]           =deal(1);
crftrf=filteredNoise(noiseSpec,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';

ts1 = trainingStep(fd, freeStim, repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode);   %stochastic free drinks
ts2 = trainingStep(fd2, freeStim, repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode);  %free drinks
ts3 = trainingStep(vh, freeStim, repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode);   %go to stim
ts4 = trainingStep(vh, discrimStim, repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode);%orientation discrim
ts5 = trainingStep(vh, imageStim,  repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode); %morph discrim
ts6 = trainingStep(vh, noiseStim,  repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode); %filteredNoise discrim
ts7 = trainingStep(vh, unfilteredNoise,  repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode); %unfiltered goToSide
ts8 = trainingStep(vh, hateren,  repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode); %hateren
ts9 = trainingStep(vh, fullfieldFlicker,  repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode); %fullfieldFlicker
ts10 = trainingStep(vh, crftrf,  repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode); %crf/trf CRT
ts11 = trainingStep(led, crftrf,  repeatIndefinitely(), noTimeOff(), svnRev,svnCheckMode); %crf/trf LED

p=protocol('gabor test',{ts1, ts2, ts3, ts4, ts4, ts6, ts7, ts8, ts9, ts10, ts11});
stepNum=uint8(2);

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolDEMO','edf');
end
