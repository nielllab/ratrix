function r = setProtocolGTS(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =75;
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
stim.gain = 0.7 * ones(2,1);


% sca
% keyboard

%if ~isscalar(subjIDs)
    %error('expecting exactly one subject')
%end

switch subjIDs{1}
    
   case 'g62dd5' % Started 2/29/16 %back to GoToBlack 4/2/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 139;
       msPenalty               =3500;
       percentCorrectionTrials = .5;     
    
   case 'g62w9rt' % Started 1/19/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5; 

   case 'g62ff5lt' % Started 3/9/16  %GTS started 3/20/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 155;
       msPenalty               =3500;
       percentCorrectionTrials = .75;         
       
    
   case 'g62dd4' % Started 3/3/16 %%start gts 3/16/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 139;
       msPenalty               =3500;
       percentCorrectionTrials = .5;     
    
   case 'g62ee8rt' % Started 2/29/16 %switch to GTS 3/11/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 59;
       msPenalty               =3500;
       percentCorrectionTrials = .75;  
    
    
   case 'g62dd2ln' % Started 1/26/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5; 
       
   case 'g62tx1.9tt' % Started 1/26/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5;        
    
    
   case 'g62tx1.9ln' % Started 1/26/16 (GTS 2/3/16)
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       stim.gain = 0.55 * ones(2,1); %try this since has trouble fully stopping 4/2/16
    
   case 'g62y3lt' % Started 1/12/16 switch to GTS 1/29/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 59;
       msPenalty               =3500;
       percentCorrectionTrials = .75;    
    
    
   case 'g62tx1.5lt' % Started 1/12/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 59;
       msPenalty               =3500;
       percentCorrectionTrials = .75;  



    
         
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