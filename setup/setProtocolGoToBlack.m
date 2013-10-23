function r = setProtocolGoToBlack(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =80;
requestRewardSizeULorMS   =0;
requestMode               ='first';
msPenalty                 =3500;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;


switch subjIDs{1}
    case 'g54bb2'
       requestRewardSizeULorMS = 40;
       rewardSizeULorMS        = 80;
       
    case 'bfly6.8rt'
       requestRewardSizeULorMS = 40;
       rewardSizeULorMS        = 80; 
  
    case 'bfly1a.4lt'          
       requestRewardSizeULorMS = 40;
       rewardSizeULorMS        = 80;   
       
    case 'bfly4.7rt'          
       requestRewardSizeULorMS = 40;
       rewardSizeULorMS        = 80;   
     
   
%     case 'g54b8tt'            move to HvV
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 55;   
   
       
%     case 'g54aa7tt'
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 45;  
       
%     case 'g54aa7lt'
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 40;  

        
    otherwise
        warning('unrecognized mouse, using defaults')
end;     



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
stim.targetDistance = 455 * ones(1,2);
stim.timeoutSecs = 10;
stim.slow = [40; 80]; % 10 * ones(2,1);
stim.slowSecs = 1;
stim.positional = true;
stim.cue = true;
stim.soundClue = false;

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


stim.stim='flip';
%stim.stim=nan;
stim.dms.targetLatency = .5;
stim.dms.cueLatency = 0;
stim.dms.cueDuration = inf;
stim.dms = [];


ballSM = trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance);
ballTM = ball(percentCorrectionTrials,sm,noRequest);
ts1 = trainingStep(ballTM, ballSM, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode); %ball

p=protocol('mouse',{ts1});

stepNum=uint8(1);
subj=getSubjectFromID(r,subjIDs{1});
[subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolMouse','edf');
end