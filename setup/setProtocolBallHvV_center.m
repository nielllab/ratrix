function r = setProtocolHvV_center(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =80;
requestRewardSizeULorMS   =80;
requestMode               ='first';
msPenalty                 =3500;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;
stim.slowSecs = 1;
pixPerCycs             = [350]; %*10^9;
targetOrientations     = 0
distractorOrientations = []; %-targetOrientations;

% sca
% keyboard

if ~isscalar(subjIDs)
    error('expecting exactly one subject')
end
switch subjIDs{1}
      case 'gcam33lt'
        requestRewardSizeULorMS = 0;
        rewardSizeULorMS        =80;
   case 'sg4lt'
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 100;
   case 'gcam17rn'
        requestRewardSizeULorMS = 0;
   case 'gcam21rt'
        requestRewardSizeULorMS = 0;
   case 'wg4rt'
        requestRewardSizeULorMS = 0; 
   case 'gcam30lt'
        requestRewardSizeULorMS = 0;
   case 'gcam30rn'
        requestRewardSizeULorMS = 0;
        rewardSizeULorMS        = 100;
  % case 'g54a11rt'
   %     requestRewardSizeULorMS = 0;
    %    rewardSizeULorMS        = 100;
  % case 'g54a11tt'
   %     requestRewardSizeULorMS = 0;
    %    rewardSizeULorMS        = 100;
 

       
    otherwise
        warning('unrecognized mouse, using defaults')
end

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

stim.gain = 0.7 * ones(2,1);
stim.targetDistance = 500 * ones(1,2);
stim.timeoutSecs = 10;
stim.slow = [40; 80]; % 10 * ones(2,1);
%stim.slowSecs = 1;  set above for individual changes
stim.positional = false;
stim.cue = true;
stim.soundClue = false;


mean                   = .5;
radius                 = .35;
contrast               = 1;
thresh                 = .00005;
normalizedPosition      = [.5];
scaleFactor            = 0; %[1 1];
axis                   = pi/2;






%%% abstract orientation (e.g. 0 = go left, pi/2 = go right)
targetOrientations = 0;
distractorOrientations = pi/2;

stim.stim = orientedGabors(pixPerCycs,{distractorOrientations [] targetOrientations},'abstract',mean,radius,contrast,thresh,normalizedPosition,maxWidth,maxHeight,scaleFactor,interTrialLuminance,[],[],axis);
 ballSM = trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance);
 ballTM = ball(percentCorrectionTrials,sm,noRequest);
 
 ballSM = setReinfAssocSecs(trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance),1);
 %change stim to stay on for 1 sec after
 
 ts1 = trainingStep(ballTM, ballSM, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode); %ball
 
 p=protocol('mouse',{ts1});
%p=protocol('mouse',{ts1,ts2});

stepNum=uint8(1);
subj=getSubjectFromID(r,subjIDs{1});
[subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'LY01 (40,80), R=36','edf');
end