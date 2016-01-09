
function r = setProtocolDriftDemo(r,subjIDs)

% error test initial
if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end


% variables for reinforcement and trial managers
rewardSizeULorMS        =50;
msPenalty               =1000;
fractionOpenTimeSoundIsOn=1;
fractionPenaltySoundIsOn=1;
scalar=1;
msAirpuff=msPenalty;
requestRewardSizeULorMS=10;
percentCorrectionTrials=.5;
doAllRequests='first';
freeDrinkLikelihood=0; % changes for stochastic/regular freeDrinks

% reinforcementManager
constantRewards=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,doAllRequests,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
increasingRewards=rewardNcorrectInARow([20 80 100 150 250],requestRewardSizeULorMS,doAllRequests,msPenalty,1,1, scalar, msAirpuff); 

% soundManager
sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000), ...
    soundClip('trialStartSound','allOctaves',[500],20000)});

%trial manager
nAFC_constant =nAFC(sm,percentCorrectionTrials,constantRewards);
nAFC_increasing_rewards =nAFC(sm,percentCorrectionTrials,increasingRewards);
aP = autopilot(percentCorrectionTrials,sm,constantRewards);

% Stimuli
pixPerCycs=[2^8]; %spatial freq
driftfrequencies=[1 6]; % in cycles per second
orientations=[pi/2]; % in radians
phases=[0]; % initial phase
contrasts=[1]; % contrast of the grating
durations=[2];
radii=[9]; % radius of the gaussian mask, fractions of screen
annuli=[0]; % radius of inner annuli
location=[0.5 0.5];
waveform='sine';
normalizationMethod='normalizeHorizontal';
mean=0.5;
thresh=.00005;
maxWidth                =1024;
maxHeight               =768;
scaleFactor             =0;
interTrialLuminance     =.5;
numRepeats=2;
doCombos=true;
gratingStim = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos);

doCombos=false;
orientations=0; % in radians
driftfrequencies=[2]; % in cycles per second
durations=[10]; %currently it will ERROR if time runs out
driftTowards= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos);

orientations=pi; % in radians
driftAway= gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annuli,location,...
    waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance,doCombos);


% training steps
svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';
repeatIndef = repeatIndefinitely();

toward = trainingStep(nAFC_increasing_rewards,driftTowards,repeatIndef,noTimeOff(),svnRev, svnCheckMode);
away = trainingStep(nAFC_increasing_rewards,driftAway,repeatIndef,noTimeOff(),svnRev, svnCheckMode);
phys = trainingStep(aP,gratingStim,repeatIndef,noTimeOff(),svnRev, svnCheckMode);

stepNum=uint8(1);
for i=1:length(subjIDs),
subj=getSubjectFromID(r,subjIDs{i});
p=protocol('driftDemo',{toward,away,phys});
[subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolDEMO','pmm');
end