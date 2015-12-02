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
    
   case 'g62cc2lt' % Started 11/16/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5;  
    
   case 'g62tx2.8lt' % Started 11/16/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5; 

   case 'g62z1lt' % Started 11/16/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5; 
       
   case 'g62cc1ln' % Started 11/16/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5; 
    
    
    case 'g62bb1rt' % Started 11/16/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5; 
       
    case 'g62y2lt' % Started 11/16/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5; 
       
    case 'g62y1tt' % Started 11/16/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5; 
       
    case 'g62w7ln' % Started 11/2/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 107;
       msPenalty               =3500;
       percentCorrectionTrials = .50; 
    
%     case 'g62w7tt' % Started 11/2/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 107;
%        msPenalty               =3500;
%        percentCorrectionTrials = .50; 
    
    
    case 'g62bb2rt' % Started 11/8/15 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 107;
       msPenalty               =3500;
       percentCorrectionTrials = .50; 
         
    case 'g62tx2.6lt' % Started 11/8/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 107;
       msPenalty               =3500;
       percentCorrectionTrials = .50; 
   
    case 'g62tx1.2lt' % Started 10/24/15 %%Start GTS 11/3/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 107;
       msPenalty               =3500;
       percentCorrectionTrials = .50; 
    
    case 'g62tx1.1tt' % Started 10/15/15 %%Started GTS 11/2/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 107;
       msPenalty               =3500;
       percentCorrectionTrials = .50; 
    
    case 'g62x1rt' % Started 10/8/15 %%started gts 10/24/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 107;
       msPenalty               =3500;
       percentCorrectionTrials = .50; 
    
    case 'g62r9tt' % Started 10/12/15 %%started gts 10/24/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 107;
       msPenalty               =3500;
       percentCorrectionTrials = .1; 
    
    case 'g62tx1.1ln' % Started 10/15/15 %%start gts 10/24/15
       requestRewardSizeULorMS = 0; 
       rewardSizeULorMS        = 107;
       msPenalty               =3500;
       percentCorrectionTrials = .50; 
     
    case 'g6w4tt' % Started 9/15/15 %switch to GTS on 10/4/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 59;
       msPenalty               =3500;
       percentCorrectionTrials = .5;   

%     case 'g62w2lt' % Started 7/14/15 %%switch gts 8/12/15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 59;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
%     
%     case 'g62q1lt' % Started 7/14/15 %%switched gts 8/12/15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 43;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
%     
%     case 'pvchr9tt' % Started 7/14/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 27;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
%     
%     case 'pvchr9rt' % Started 7/14/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 27;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
%     
%     case 'pvchr9lt' % Started 7/14/15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 27;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
    
%     case 'g62q1lt' % Started 7/14/15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 16;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
%        
%     case 'g62w2lt' % Started 7/14/15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 16;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
%     
    case 'g62r4lt' % Started 5/18/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 43;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
    
%     case 'g62r3rt' % Switched to HvV 6/8/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 70;
%        msPenalty               =3500;
%        percentCorrectionTrials = .25;
% 
%      case 'g62l10rt' % Started 3/14/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 27;
%        msPenalty               =2500;
%        percentCorrectionTrials = .5;
%   
%      case 'g62l1lt' % Started GTS 7/27/14
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 20;
%        msPenalty               =2500;
%        percentCorrectionTrials = .5;
% 
%        


%     case 'g62w2rt' % Started 7/2/15  RESTARTED 8/7/15 %%tresty esjptjooeptses
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 76;
%        msPenalty               =4200;
%        percentCorrectionTrials = .5;
       
%      case 'g62m9tt' % Started GTS 3/4/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 25;
%        msPenalty               =2500;
%        pixPerCycs             = [200]; %*10^9;       
%        percentCorrectionTrials = .5;

     case 'g62n1ln' % Started GTS 3/8/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 43;
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