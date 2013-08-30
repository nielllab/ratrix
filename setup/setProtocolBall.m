function r = setProtocolMouse(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end


sm=makeStandardSoundManager();

rewardSizeULorMS          =80;
requestRewardSizeULorMS   =30;
requestMode               ='first';
msPenalty                 =1000;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;

switch subjIDs{1}
   case 'gcam33lt'
        requestRewardSizeULorMS = 0;
        rewardSizeULorMS        = 70;
   case 'sg4lt'
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 100;
   case 'gcam17rn'
        requestRewardSizeULorMS = 0;
        rewardSizeULorMS        = 40;


noRequest = constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

percentCorrectionTrials = .5;

maxWidth  = 1920;
maxHeight = 1080;

[w,h] = rat(maxWidth/maxHeight);
textureSize = 10*[w,h];
zoom = [maxWidth maxHeight]./textureSize;

svnRev = {'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode = 'session';

interTrialLuminance = .5;

stim.gain = .7 * ones(2,1);
stim.targetDistance = 300 * ones(1,2);
stim.timeoutSecs = .5;
stim.slow = [50; 100]; % 10 * ones(2,1);
stim.slowSecs = .5;
stim.positional = false;
stim.cue = true;
stim.soundClue = true;

pixPerCycs             = [300]; %*10^9;
targetOrientations     = [-1 1]*pi/4;
distractorOrientations = []; %-targetOrientations;
mean                   = .5;
radius                 = .085;
contrast               = 1;
thresh                 = .00005;
yPosPct                = .5;
stim.stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,zoom,interTrialLuminance);
%stim.stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,[-1 1]  ,thresh,yPosPct,maxWidth,maxHeight,zoom,interTrialLuminance,'none', 'normalizeDiagonal');

stim.stim = 'flip';
%stim.stim='rand';
%stim.stim=nan;
stim.dms.targetLatency = 1;
stim.dms.cueLatency = 0;
stim.dms.cueDuration = .5;
stim.dms = [];

%stim to stay on 1 sec after answer
ballSM = setReinfAssocSecs(trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance),1);

ballSM = trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance);
ballTM = ball(percentCorrectionTrials,sm,noRequest);
ts1 = trainingStep(ballTM, ballSM, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode); %ball

p=protocol('mouse',{ts1});

stepNum=uint8(1);
subj=getSubjectFromID(r,subjIDs{1});
[subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolMouse','edf');
end