function r = setProtocolGTS(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =130;
requestRewardSizeULorMS   =0;
requestMode               ='first';
msPenalty                 =3500;          %consider changing this also in future
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =0;
pixPerCycs                = [200]; %*10^9;
%stim.stopHUD = false; %stop period heads up display... false = off
percentCorrectionTrials = .5;


% sca
% keyboard

%if ~isscalar(subjIDs)
    %error('expecting exactly one subject')
%end

switch subjIDs{1}
    
     
     case 'pvchr9tt' % Started 7/14/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 16;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
    
    case 'pvchr9rt' % Started 7/14/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 16;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
    
    case 'pvchr9lt' % Started 7/14/15
       requestRewardSizeULorMS = 00;
       rewardSizeULorMS        = 16;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
    
    case 'g62q1lt' % Started 7/14/15
       requestRewardSizeULorMS = 00;
       rewardSizeULorMS        = 16;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       
    case 'g62w2lt' % Started 7/14/15
       requestRewardSizeULorMS = 00;
       rewardSizeULorMS        = 16;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
    
    case 'g62r4lt' % Started 5/18/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 16;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
    
%     case 'g62r3rt' % Switched to HvV 6/8/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 70;
%        msPenalty               =3500;
%        percentCorrectionTrials = .25;

     case 'g62l10rt' % Started 3/14/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 16;
       msPenalty               =2500;
       percentCorrectionTrials = .5;
%   
%      case 'g62l1lt' % Started GTS 7/27/14
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 20;
%        msPenalty               =2500;
%        percentCorrectionTrials = .5;
% 
%        
%      case 'g62m9tt' % Started GTS 3/4/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 25;
%        msPenalty               =2500;
%        pixPerCycs             = [200]; %*10^9;       
%        percentCorrectionTrials = .5;

     case 'g62n1ln' % Started GTS 3/8/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 16;
       msPenalty               =2500;
       pixPerCycs             = [200]; %*10^9;       
       percentCorrectionTrials = .5;

    


    
         
    otherwise
        warning('unrecognized mouse, using defaults')
end

noRequest = constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);



maxWidth  = 1920;
maxHeight = 1080;

[w,h] = rat(maxWidth/maxHeight);
textureSize = 10*[w,h];
zoom = [maxWidth maxHeight]./textureSize;

svnRev = {}; %{'svn://132.239.158.177/projects/ratrix/trunk'};
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

targetOrientations     = [0 1]*pi/2;
distractorOrientations = []; %-targetOrientations;
mean                   = .5;
radius                 = .25;
contrast               = 1;
thresh                 = .00005;
yPosPct                = .5;
stim.stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,zoom,interTrialLuminance);


%stim to stay on 1 sec after answer
ballSM = setReinfAssocSecs(trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance),1);



ballTM = ball(percentCorrectionTrials,sm,noRequest);
ts1 = trainingStep(ballTM, ballSM, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode); %ball

p=protocol('mouse',{ts1});

stepNum=uint8(1);
subj=getSubjectFromID(r,subjIDs{1});
[subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'LY01 (40,80), R=36','edf');
end