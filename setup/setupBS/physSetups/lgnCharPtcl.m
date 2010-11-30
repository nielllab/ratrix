function r = lgnCharPtcl(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

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
waveform='sine';     
normalizationMethod='normalizeDiagonal';
mean=0.5;
numRepeats=4;
scaleFactor=0;
doCombos={true,'twister','clock'};
changeableAnnulusCenter=false;

%% spatial frequency
sfGratingsSine = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
waveform = 'square';
sfGratingsSquare = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

waveform = 'sine';
frequencies = driftfrequencies;
phaseform = 'sine';
sfPhaseRevGratingsSine = phaseReverseGratings(pixPerCycs,frequencies,orientations,phases,waveform,contrasts,durations,radius,annuli,location,...
    phaseform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,changeableAnnulusCenter,doCombos);

waveform = 'square';
sfPhaseRevGratingsSquare = phaseReverseGratings(pixPerCycs,frequencies,orientations,phases,waveform,contrasts,durations,radius,annuli,location,...
    phaseform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,changeableAnnulusCenter,doCombos);

%% orientation
numOrientations=8;
orientations=([2*pi]*[1:numOrientations])/numOrientations; % in radians
pixPerCycs=1024; %2^9;%temp [64];  % reset to one value
orGratings1024 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

pixPerCycs = 512;
orGratings512 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

pixPerCycs = 256;
orGratings256 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

phaseform = 'sine';
waveform = 'sine';
pixPerCycs = 1024;
orientations=([pi]*[1:numOrientations])/numOrientations;
phases = linspace(0,2*pi,8);
orPhaseRevGratingsSine1024 = phaseReverseGratings(pixPerCycs,frequencies,orientations,phases,waveform,contrasts,durations,radius,annuli,location,...
    phaseform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,changeableAnnulusCenter,doCombos);

pixPerCycs = 512;
orientations=([pi]*[1:numOrientations])/numOrientations;
orPhaseRevGratingsSine512 = phaseReverseGratings(pixPerCycs,frequencies,orientations,phases,waveform,contrasts,durations,radius,annuli,location,...
    phaseform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,changeableAnnulusCenter,doCombos);

pixPerCycs = 256;
orientations=([pi]*[1:numOrientations])/numOrientations;
orPhaseRevGratingsSine256 = phaseReverseGratings(pixPerCycs,frequencies,orientations,phases,waveform,contrasts,durations,radius,annuli,location,...
    phaseform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,changeableAnnulusCenter,doCombos);

%% contrast
numContrasts=6;
contrasts=1./2.^[0:numContrasts-1]; % contrast of the grating
orientations=[pi/4]; % reset to one value
pixPerCycs = 1024;
cntrGratings1024 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

pixPerCycs = 512;
cntrGratings512 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

pixPerCycs = 256;
cntrGratings256 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

%% locating the RF
radii=[0.02 0.05 .1 .2 .3 .4 .5 2]; % radii of the grating
contrasts=1; % reset to one value
pixPerCycs = 1024;
changeableAnnulusCenter = true;
radGratingsChangeable = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);


annuli=[0.02 0.05 .1 .2 .3 .4 .5 2]; % annulus of the grating
anGratingsChangeable = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

% % location of RF
% RFdataSource='\\132.239.158.179\datanet_storage'; % good only as long as default stations don't change, %how do we get this from the dn in the station!?
% location = RFestimator({'gratingWithChangeableAnnulusCenter','lastDynamicSettings',[]},{'gratingWithChangeableAnnulusCenter','lastDynamicSettings',[]},[],RFdataSource,[now-100 Inf]);
% 
% %% pixPerCycs = 1024
% annulus = 0;
% contrasts = 1; pixPerCycs = 1024;
% radGratingsPPC1024Ctr100 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC1024Ctr100= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.95; pixPerCycs = 1024;
% radGratingsPPC1024Ctr095 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC1024Ctr095= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.9; pixPerCycs = 1024;
% radGratingsPPC1024Ctr090 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC1024Ctr090= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.75; pixPerCycs = 1024;
% radGratingsPPC1024Ctr075 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC1024Ctr075= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.5; pixPerCycs = 1024;
% radGratingsPPC1024Ctr050 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC1024Ctr050= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% 
% %% pixPerCycs = 512
% contrasts = 1; pixPerCycs = 512;
% radGratingsPPC512Ctr100 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC512Ctr100= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.95; pixPerCycs = 512;
% radGratingsPPC512Ctr095 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC512Ctr095= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.9; pixPerCycs = 512;
% radGratingsPPC512Ctr090 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC512Ctr090= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.75; pixPerCycs = 512;
% radGratingsPPC512Ctr075 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC512Ctr075= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.5; pixPerCycs = 512;
% radGratingsPPC512Ctr050 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC512Ctr050= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% %% pixPerCycs = 256
% contrasts = 1; pixPerCycs = 256;
% radGratingsPPC256Ctr100 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC256Ctr100= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.95; pixPerCycs = 256;
% radGratingsPPC256Ctr095 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC256Ctr095= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.9; pixPerCycs = 256;
% radGratingsPPC256Ctr090 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC256Ctr090= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.75; pixPerCycs = 256;
% radGratingsPPC256Ctr075 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC256Ctr075= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.5; pixPerCycs = 256;
% radGratingsPPC256Ctr050 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC256Ctr050= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% %% pixPerCycs = 128
% contrasts = 1; pixPerCycs = 128;
% radGratingsPPC128Ctr100 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC128Ctr100= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.95; pixPerCycs = 128;
% radGratingsPPC128Ctr095 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC128Ctr095= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.9; pixPerCycs = 128;
% radGratingsPPC128Ctr090 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC128Ctr090= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.75; pixPerCycs = 128;
% radGratingsPPC128Ctr075 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC128Ctr075= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% 
% contrasts = 0.5; pixPerCycs = 128;
% radGratingsPPC128Ctr050 = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annulus,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
% anGratingsPPC128Ctr050= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
%     waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);


%% temporal stimuli
% full-field
annuli=0;                        % reset
location=[.5 .5];                % center of mask
driftfrequencies=2.^(-2:0.5:3);  % in cycles per second
%contrasts=1./2.^[0:numContrasts-1]; % contrast of the grating
contrasts=[1];                   % contrast of the grating
durations=[3];                   % duration of each grating
pixPerCycs=2.^(16);              % freq really broad approximates fullfield homogenous

numRepeats=2;
fakeTRF10= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);

driftfrequencies=[1 2 4];     % in cycles per second
fakeTRFSlow= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos,changeableAnnulusCenter);
%% @diff sfs
driftfrequencies=[1 2 4 8 16];



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

% rfIsGood=receptiveFieldCriterion(0.05,RFdataSource,1,'box',3);

numSweeps=int8(3);
cmr = manualCmrMotionEyeCal(background,numSweeps,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

%% trainingsteps

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';

%Search stim
ts{1}= trainingStep(ap,  fakeTRFSlow, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'searchTRF');       %temporal response function only slow temp freqs
ts{2}= trainingStep(ap, sfGratingsSine,   repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'searchSF');  %gratings: spatial frequency (should it be before annulus?)
ts{3}= trainingStep(ap,  ffgwn,       repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'searchFFGWN'); %full field gaussian white noise
ts{4}= trainingStep(ap,  bin6x8,       repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'searchBIN6X8'); %full field gaussian white noise

% lots of gratings basic characterization
ts{5} = trainingStep(ap,  sfGratingsSine,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'sfGrSin');  %temporal response function
ts{6} = trainingStep(ap,  sfGratingsSquare,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'sfGrSqr');  %temporal response function
ts{7} = trainingStep(ap,  sfPhaseRevGratingsSine,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'sfPrSin');  %temporal response function
ts{8} = trainingStep(ap,  sfPhaseRevGratingsSquare,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'sfPrSqr');  %temporal response function
ts{9} = trainingStep(ap,  orGratings1024,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'orGr1024');  %temporal response function
ts{10} = trainingStep(ap,  orGratings512,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'orGr512');  %temporal response function
ts{11} = trainingStep(ap,  orGratings256,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'orGr256');  %temporal response function
ts{12} = trainingStep(ap,  orPhaseRevGratingsSine1024,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'orPr1024');  %temporal response function
ts{13} = trainingStep(ap,  orPhaseRevGratingsSine512,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'orPr512');  %temporal response function
ts{14} = trainingStep(ap,  orPhaseRevGratingsSine256,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'orPr256');  %temporal response function
ts{15} = trainingStep(ap,  cntrGratings1024,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'ctrGr1024');  %temporal response function
ts{16} = trainingStep(ap,  cntrGratings512,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'ctrGr512');  %temporal response function
ts{17} = trainingStep(ap,  cntrGratings256,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'ctrGr256');  %temporal response function

% lets get some bin
ts{18} = trainingStep(ap,  ffgwn,  numTrialsDoneCriterion(20), noTimeOff(), svnRev, svnCheckMode,'ffgwn');  %temporal response function
ts{19} = trainingStep(ap,  bin6x8,  numTrialsDoneCriterion(30), noTimeOff(), svnRev, svnCheckMode,'bin6X8');  %temporal response function
ts{20} = trainingStep(ap,  bin12x16,  numTrialsDoneCriterion(30), noTimeOff(), svnRev, svnCheckMode,'bin12X16');  %temporal response function

% changeable annulus
ts{21} = trainingStep(ap,  radGratingsChangeable,  numTrialsDoneCriterion(5), noTimeOff(), svnRev, svnCheckMode,'radMan');  %temporal response function
ts{22} = trainingStep(ap,  anGratingsChangeable,  numTrialsDoneCriterion(5), noTimeOff(), svnRev, svnCheckMode,'annMan');  %temporal response function

% % pixPerCycs = 1024
% ts{23} = trainingStep(ap,  radGratingsPPC1024Ctr100,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC1024Ctr100');  %temporal response function
% ts{24} = trainingStep(ap,  radGratingsPPC1024Ctr095,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC1024Ctr095');  %temporal response function
% ts{25} = trainingStep(ap,  radGratingsPPC1024Ctr090,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC1024Ctr090');  %temporal response function
% ts{26} = trainingStep(ap,  radGratingsPPC1024Ctr075,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC1024Ctr075');  %temporal response function
% ts{27} = trainingStep(ap,  radGratingsPPC1024Ctr050,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC1024Ctr050');  %temporal response function
% ts{28} = trainingStep(ap,  anGratingsPPC1024Ctr100,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC1024Ctr100');  %temporal response function
% ts{29} = trainingStep(ap,  anGratingsPPC1024Ctr095,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC1024Ctr095');  %temporal response function
% ts{30} = trainingStep(ap,  anGratingsPPC1024Ctr090,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC1024Ctr090');  %temporal response function
% ts{31} = trainingStep(ap,  anGratingsPPC1024Ctr075,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC1024Ctr075');  %temporal response function
% ts{32} = trainingStep(ap,  anGratingsPPC1024Ctr050,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC1024Ctr050');  %temporal response function
% 
% % pixPerCycs = 512
% ts{33} = trainingStep(ap,  radGratingsPPC512Ctr100,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC512Ctr100');  %temporal response function
% ts{34} = trainingStep(ap,  radGratingsPPC512Ctr095,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC512Ctr095');  %temporal response function
% ts{35} = trainingStep(ap,  radGratingsPPC512Ctr090,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC512Ctr090');  %temporal response function
% ts{36} = trainingStep(ap,  radGratingsPPC512Ctr075,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC512Ctr075');  %temporal response function
% ts{37} = trainingStep(ap,  radGratingsPPC512Ctr050,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC512Ctr050');  %temporal response function
% ts{38} = trainingStep(ap,  anGratingsPPC512Ctr100,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC512Ctr100');  %temporal response function
% ts{39} = trainingStep(ap,  anGratingsPPC512Ctr095,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC512Ctr095');  %temporal response function
% ts{40} = trainingStep(ap,  anGratingsPPC512Ctr090,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC512Ctr090');  %temporal response function
% ts{41} = trainingStep(ap,  anGratingsPPC512Ctr075,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC512Ctr075');  %temporal response function
% ts{42} = trainingStep(ap,  anGratingsPPC512Ctr050,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC512Ctr050');  %temporal response function
% 
% % pixPerCycs = 256
% ts{43} = trainingStep(ap,  radGratingsPPC256Ctr100,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC256Ctr100');  %temporal response function
% ts{44} = trainingStep(ap,  radGratingsPPC256Ctr095,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC256Ctr095');  %temporal response function
% ts{45} = trainingStep(ap,  radGratingsPPC256Ctr090,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC256Ctr090');  %temporal response function
% ts{46} = trainingStep(ap,  radGratingsPPC256Ctr075,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC256Ctr075');  %temporal response function
% ts{47} = trainingStep(ap,  radGratingsPPC256Ctr050,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC256Ctr050');  %temporal response function
% ts{48} = trainingStep(ap,  anGratingsPPC256Ctr100,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC256Ctr100');  %temporal response function
% ts{49} = trainingStep(ap,  anGratingsPPC256Ctr095,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC256Ctr095');  %temporal response function
% ts{50} = trainingStep(ap,  anGratingsPPC256Ctr090,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC256Ctr090');  %temporal response function
% ts{51} = trainingStep(ap,  anGratingsPPC256Ctr075,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC256Ctr075');  %temporal response function
% ts{52} = trainingStep(ap,  anGratingsPPC256Ctr050,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC256Ctr050');  %temporal response function
% 
% % pixPerCycs = 128
% ts{53} = trainingStep(ap,  radGratingsPPC128Ctr100,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC128Ctr100');  %temporal response function
% ts{54} = trainingStep(ap,  radGratingsPPC128Ctr095,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC128Ctr095');  %temporal response function
% ts{55} = trainingStep(ap,  radGratingsPPC128Ctr090,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC128Ctr090');  %temporal response function
% ts{56} = trainingStep(ap,  radGratingsPPC128Ctr075,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC128Ctr075');  %temporal response function
% ts{57} = trainingStep(ap,  radGratingsPPC128Ctr050,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'radGratingsPPC128Ctr050');  %temporal response function
% ts{58} = trainingStep(ap,  anGratingsPPC128Ctr100,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC128Ctr100');  %temporal response function
% ts{59} = trainingStep(ap,  anGratingsPPC128Ctr095,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC128Ctr095');  %temporal response function
% ts{60} = trainingStep(ap,  anGratingsPPC128Ctr090,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC128Ctr090');  %temporal response function
% ts{61} = trainingStep(ap,  anGratingsPPC128Ctr075,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC128Ctr075');  %temporal response function
% ts{62} = trainingStep(ap,  anGratingsPPC128Ctr050,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'anGratingsPPC128Ctr050');  %temporal response function
% 
% ts{63} = trainingStep(ap,  bin3x4,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'bin3x4');  %temporal response function
% ts{64} = trainingStep(ap,  bin24x32,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'bin24x32');  %temporal response function
% ts{65} = trainingStep(ap,  bin48x64,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'bin48x64');  %temporal response function
% 
% % other stuff
% ts{66} = trainingStep(ap,  flankers,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'flankers');  %temporal response function
% ts{67} = trainingStep(ap,  flankersFF,  numTrialsDoneCriterion(3), noTimeOff(), svnRev, svnCheckMode,'lankersFF');  %temporal response function
% 
% % burnthro
% ts{68} = trainingStep(ap,  gwn,  repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode,'binFast');  %temporal response function
% 

% sfGratingsSine
% sfGratingsSquare
% sfPhaseRevGratingsSine
% sfPhaseRevGratingsSquare
% orGratings1024
% orGratings512
% orGratings256
% sfPhaseRevGratingsSine1024
% sfPhaseRevGratingsSine512
% sfPhaseRevGratingsSine256
% sfPhaseRevGratingsSquare256Phased
% cntrGratings1024
% cntrGratings512
% cntrGratings256
% radGratingsChangeable
% anGratingsChangeable
% fakeTRF10
% ffgwn
% ffbin
% bin3x4 
% bin6x8 
% bin12x16
% bin24x32 
% bin48x64
% binOther


%% make and set it


p=protocol('practice phys',{ts{1:22}});
stepNum=uint8(1);

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolPhys','pmm');
end
