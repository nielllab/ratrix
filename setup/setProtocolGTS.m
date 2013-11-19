function r = setProtocolGTS(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =80;
requestRewardSizeULorMS   =20;
requestMode               ='first';
msPenalty                 =3500;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;

% sca
% keyboard

if ~isscalar(subjIDs)
    error('expecting exactly one subject')
end
switch subjIDs{1}

      
%    case 'g625ln'
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 100; 
       
   case 'g54aa7tt'
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 35;
    
    case 'gcam32tt'
        requestRewardSizeULorMS = 0;
        rewardSizeULorMS        = 22.5;
   case 'gcam32ln'
        requestRewardSizeULorMS = 0;
        rewardSizeULorMS        = 27.5;

   case 'gcam50tt'
        requestRewardSizeULorMS = 0;
        rewardSizeULorMS        = 27.5;
   case 'gcam46tt'
        requestRewardSizeULorMS = 0;
        rewardSizeULorMS        = 22.5;
   case 'gcam51ln'
        requestRewardSizeULorMS = 0;
        rewardSizeULorMS        = 22.5;
   case 'gcam39rt'
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 25;

      
   case 'g62.8lt' 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 60;
       
   case 'g54b12rt' 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 70;
       
   case 'g625ln'
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 100;  
       
       
   case 'g54bb2'
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 50;
       
    
         
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
stim.slowSecs = 1;
stim.positional = false;
stim.cue = true;
stim.soundClue = false;

pixPerCycs             = [100]; %*10^9;
targetOrientations     = [0 1]*pi/2;
distractorOrientations = []; %-targetOrientations;
mean                   = .5;
radius                 = .35;
contrast               = 1;
thresh                 = .00005;
yPosPct                = .5;
stim.stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,zoom,interTrialLuminance);


%stim to stay on 1 sec after answer
ballSM = setReinfAssocSecs(trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance),1);


ballSM = trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance);
ballTM = ball(percentCorrectionTrials,sm,noRequest);
ts1 = trainingStep(ballTM, ballSM, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode); %ball

p=protocol('mouse',{ts1});

stepNum=uint8(1);
subj=getSubjectFromID(r,subjIDs{1});
[subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'LY01 (40,80), R=36','edf');
end