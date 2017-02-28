function r = setProtocolNieve(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =100;
requestRewardSizeULorMS   =0;
requestMode               ='first';
msPenalty                 =3500;          %consider changing this also in future
pixPerCycs             = [200]; %*10^9;
stim.gain = 0.7 * ones(2,1);
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =0;
 percentCorrectionTrials = .5;  
%stim.stopHUD = false; %stop period heads up display... false = off

% sca
% keyboard

if ~isscalar(subjIDs)
    error('expecting exactly one subject')
end
switch subjIDs{1}

   case 'g62aaa3lt' % Started 2/1/17 %%started nieve 2/21/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .0;        
    
    case 'g62uu1lt' % Started 2/1/17  %%start nieve 2/20/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .0;       
    
    
   case 'g62rr1lt' % Started 2/1/17  %%start random 2/17/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500; 
        percentCorrectionTrials = .0;  
    
   case 'g62pp6rt' % Started 2/1/17  %%start random 2/17/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
        percentCorrectionTrials = .0;  
    
   case 'g62uu4lt' % Started 2/1/17  %%start random 2/17/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
        percentCorrectionTrials = .0;  
       
   case 'g62aaa2lt' % Started 2/1/17  %%start random 2/15/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500; 
        percentCorrectionTrials = .0;  
    
   case 'g62pp4rt' % Started 2/1/17  %%start random 2/15/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
        percentCorrectionTrials = .0;  
    
   case 'g62uu1rt' % Started 2/1/17  %%start random 2/15/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
        percentCorrectionTrials = .0;  
     
       
   case 'g62kk12rt' % Started 10/21/16 %%started random 11/7/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 91;
       msPenalty               =3500;
        percentCorrectionTrials = .5;  
  
    
    
     case 'g62qq1rt' % Started 11/2/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
        percentCorrectionTrials = .5;  
  
    
     case 'g62qq2lt' % start nieve 10/27/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 60;
       msPenalty               =3500;
        percentCorrectionTrials = .5;  
       
     case 'g62tt1lt' % start nieve 10/27/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 60;
       msPenalty               =3500;
       
 
    
         
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
distractorOrientations = [0 1]*pi/2; 
mean                   = .5;
radius                 = .25;
contrast               = 1;
thresh                 = .00005;
normalizedPosition      = [0.33 0.66];
scaleFactor            = 0; %[1 1];
axis                   = pi/2;
stim.stim = orientedGabors(pixPerCycs,{distractorOrientations [] targetOrientations},'abstract',mean,radius,contrast,thresh,normalizedPosition,maxWidth,maxHeight,scaleFactor,interTrialLuminance,[],[],axis);


%stim to stay on 1 sec after answer
ballSM = setReinfAssocSecs(trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance),1);



ballTM = ball(percentCorrectionTrials,sm,noRequest);
ts1 = trainingStep(ballTM, ballSM, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode); %ball

p=protocol('mouse',{ts1});

stepNum=uint8(1);
subj=getSubjectFromID(r,subjIDs{1});
[subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'LY01 (40,80), R=36','edf');
end