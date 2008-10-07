function r = setProtocolPhased(r,subjIDs)


% ====================================================================================================================
% error test initial
if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end
% ====================================================================================================================
% variables for reinforcement and trial managers
rewardSizeULorMS        =50;
msPenalty               =1000;
fractionOpenTimeSoundIsOn=1;
fractionPenaltySoundIsOn=1;
scalar=1;
msAirpuff=msPenalty;

parameters = [];

% ====================================================================================================================
% soundManager
sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});
parameters.soundManager = sm;

% ====================================================================================================================
% reinforcementManager
constantRewards=constantReinforcement(rewardSizeULorMS,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
reinforcementManager = constantRewards;
% ====================================================================================================================
% trialManager
msFlushDuration=50;
msMinimumPokeDuration=150;
msMinimumClearDuration=150;
customDescription = 'phased trial manager';
phases = 5;

phased = phasedTrialManager(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration, ...
    sm,reinforcementManager,customDescription, phases);

% ====================================================================================================================
% stimManager
maxWidth                =1024;
maxHeight               =768;
scaleFactor             =[1 1];
interTrialLuminance     =0;
discrimStim = examplePhased(maxWidth,maxHeight,scaleFactor,interTrialLuminance);

% ====================================================================================================================
% training steps
svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};

ts1 = trainingStep(phased, discrimStim, repeatIndefinitely(), noTimeOff(), svnRev);   %stochastic free drinks


% ====================================================================================================================
% protocol and rest of setup stuff
p=protocol('gabor test',{ts1});
stepNum=1;

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolDEMO','edf');
end