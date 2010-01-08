function r = flankerCalibProtocol(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
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
pixPerCycs=2.^([5:11]); % freq
pixPerCycs=2.^([7:0.5:11]); % freq
%pixPerCycs=2.^([9]);   % freq
%driftfrequencies=[4];  % in cycles per second
driftfrequencies=[2];  % in cycles per second
orientations=[pi/2];   % in radians, horiz
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

durations=[3]
numRepeats=5;
pixPerCycs=512;
dynGrating=gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

numOrientations=8;
orientations=([2*pi]*[1:numOrientations])/numOrientations; % in radians
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

%flankers
flankers=ifFeatureGoRightWithTwoFlank('phys');
flankersFF=ifFeatureGoRightWithTwoFlank('physFullFieldTarget');
fTestFlicker=ifFeatureGoRightWithTwoFlank('testFlicker');
hvCalib=ifFeatureGoRightWithTwoFlank('horizontalVerticalCalib');
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
stixelSize = [32 32]% [128 128];% [128 128]; %[32,32];
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


%% trial / sound / reinforcement managers

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



%% trainingsteps

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';

%calib stim
ts{1}= trainingStep(ap, hvCalib,    repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode);  % catch and repeat here forever

%% make and set it

p=protocol('practice phys',ts);
stepNum=uint8(1);

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolPhys','pmm');
end
