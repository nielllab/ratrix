function r = setProtocolHvV_center_vertical(r,subjIDs)

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
msPenalty                 =3500;     %consider changing this also in future
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;
radius                 = .35;
pixPerCycs                = [200];
percentCorrectionTrials = .5;
stim.gain = 0.7 * ones(2,1);

% sca
% keyboard

if ~isscalar(subjIDs)
    error('expecting exactly one subject')
end
switch subjIDs{1}
    
    
  
    
    case 'testHvVcenter' % 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 59;
       msPenalty               =6300;
       
    case 'g62ll4lt' % Started 5/22/16 %%start hvv center 6/1/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .75;        
    
   case 'g62jj2lt' % Started 5/4/16 %started HvV_center 5/15/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .75;
    
   case 'g62jj2rt' % Started 5/4/16  %started HvV_center 5/15/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .75;
  
       
   case 'g62hh6rt' % Started 4/13/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .8;       
       
   case 'sanjay' % Started 4/13/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .8;     
          
       
%    case 'g62bb8tt' % Started 2/9/16  %started HvV_center 2/20/16 %restarted HvV_center 4/2/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 139;
%        msPenalty               =3500;
%        percentCorrectionTrials = .8;
%         stim.gain = 0.50 * ones(2,1); %try this since has trouble fully stopping 4/6/16
       
%    case 'g62bb8rt' % Started 2/9/16  %started HvV_center 2/20/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 139;
%        msPenalty               =3500;
%        percentCorrectionTrials = .8;    
       
       
    case 'g62tx2.11lt' % Started 2/9/16 %started HvV_center 2/20/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 139;
       msPenalty               =3500;
       percentCorrectionTrials = .8; 
       radius                 = .3;
       
%    case 'g62hh4ln' % Started 2/9/16  %started HvV_center 2/20/16 back to GoToBlack 2/28/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 139;
%        msPenalty               =3500;
%        percentCorrectionTrials = .75;       
       
       
%    case 'g62ee6lt' % Started 2/9/16  %started HvV_center 2/20/16 %back to GoToBlack 4/2/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 139;
%        msPenalty               =3500;
%        percentCorrectionTrials = .75;    
       
       
%     case 'g62tx2.3ln' % Started 10/24/15 %%Start hvv center 11/5/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 107;
%        msPenalty               =3500;
%        percentCorrectionTrials = .50; 
       
%     case 'g62t6lt' % Started 9/18/15 %%started hvv center 10/13/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 107;
%        msPenalty               =3500;
%        percentCorrectionTrials = .50;
%        pixPerCycs                = [200];
       
%     case 'pvchr14ln' % Started 8/25/15 %%started hvv center 9/15/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 59;
%        msPenalty               =6500;
%        percentCorrectionTrials = .50; 
%        stim.slowSecs = 2;
%        
%     case 'pvchr14rn' % Started 8/25/15 %%started hvv center 9/15/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 43;
%        msPenalty               =6500;
%        percentCorrectionTrials = .50; 
%        stim.slowSecs = 2;
% 
%        
%     case 'pvchr14rt' % Started 8/25/15 %%switched to center 9/11/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 27;
%        msPenalty               =5500;
%        percentCorrectionTrials = .50; 
%        stim.slowSecs = 1.5;
%        
%     case 'pvchr14tt' % Started 8/25/15 %%switched to center 9/11/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 43;
%        msPenalty               =4500;
%        percentCorrectionTrials = .50; 
%        stim.slowSecs = 2;
%        
%     case 'pv8lt' % Started 6/25/15  (permenant record wont show till 6/26/15) %%started center 7/14/15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 59;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
%        stim.slowSecs = 1;
%     
%     case 'pv8nt' % Started 6/25/15  (permenant record wont show till 6/26/15) %%started center 7/14/15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 59;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
%        stim.slowSecs = 1;
%        
%               
%      case 'g62a2nn' % Started 6/25/15 (permenant record wont show till 6/26/15) %%Started hvv 7/14/15 %%started gotoblack 8/11/15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 59;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
%        
%        
%       case 'g62a3tt' % Started 6/25/15 %% started hvv 7/17/15 %%started gotoblack again 8/11/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 59;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
%        
%       case 'g62a5nn' % Started 5/15/15 %% back to hvv 7/25/15 %%backtogloblack 8/11/15 %%%switch 100 sf 10/12/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 43;
%        msPenalty               =3500;
%        percentCorrectionTrials = .50;
%        pixPerCycs                = [100];
%        
%       case 'g62n7ln' % Started 7/14/15 %%switch center 8/12/15 %%%switch 100 sf 10/12/15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 43;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
%        pixPerCycs                = [100];
%        
%  
%     case 'g62n7ln' % Started 7/14/15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 16;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
    
   

       
%     case 'pv8lt' % Started 6/25/15  (permenant record wont show till 
%     6/26/15) %%started center 7/14/15 %%started gotblack 8-11-15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 32;
%        msPenalty               =3500;
%        pixPerCycs              = [350];
%        percentCorrectionTrials = .5;
%        stim.slowSecs = 1;
    
%     case 'pv8nt' % Started 6/25/15  (permenant record wont show till
%     6/26/15) %%started center 7/14/15 %%started gotblack 8-11-15
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 16;
%        msPenalty               =3500;
%        pixPerCycs              = [350];
%        percentCorrectionTrials = .5;
%        stim.slowSecs = 1;
%        
       
%     case 'g62c.2rt'           %Switched Back _center 8/15/14
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 25; 
% %        msPenalty               =4200;
%        pixPerCycs             = [100 150 200]; %*10^9;
    
%     case 'g62j.5rt' % Switched full 10/9/14
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 45;
%        msPenalty               =4300;
%        
%     case 'g62k.1rt' % Started 7/12/14
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 100;
%        msPenalty               =4100;
    
%     case 'g62f.8lt' % Started  7/12/14
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 110;
%        msPenalty               =4100;
%     
%     case 'g62g4lt'     %switched full 5/22/14 
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 30;
%         msPenalty              =4200;
%         pixPerCycs             = [100 125 150]; %*10^9;
        
%      case 'g62g.6lt' % Switched full 10/9/14
%        requestRewardSizeULorMS = 00;
%        rewardSizeULorMS        = 25;
%        msPenalty               =4100;

%         
%    case 'g62b8tt'     %switched full 5/22/14  
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 30;
%         msPenalty              =4100;
    
%        case 'g62h1tt'     %Switched Full 8/15/14
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 60;
%         msPenalty              =4000;
%         pixPerCycs             = [100 125 150]; %*10^9;
        
%        case 'g62h2lt'     %started 2/22/14  
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 95;
%         msPenalty              =4300;
        
%        case 'g62b9tt'     %started 3/8/14  
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 80;
%         msPenalty              =4100;
    
%        case 'g62h2tt'     %started 3/5/14
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 40;
%         msPenalty              =4300;
        
%       case 'g62c.2rt'           %changed 1/30/14 
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 30; 
%        msPenalty               =4100;

%     case 'g62b7lt'           %switched full 8/14/14
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 25; 
%        msPenalty               =4000;
%        pixPerCycs             = [100 125 150]; %*10^9;
%        
%        case 'g6w5rt'     %started 2/17/14  
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 30;
%         msPenalty              =4200;
        

    

 
       
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
stim.soundClue = true;

targetOrientations     = 0
distractorOrientations = []; %-targetOrientations;
mean                   = .5;
contrast               = 1;
thresh                 = .00005;
normalizedPosition      = [.5];
scaleFactor            = 0; %[1 1];
axis                   = pi/2;



%%% abstract orientation (e.g. 0 = go left, pi/2 = go right)
targetOrientations = pi/2;
distractorOrientations = 0;

%for creating psychometric curves (contrast and orientation)
% switch subjIDs{1}
%         
%      case 'g62c.2rt'           %set variable parameters
%             contrast               = [.01, .05, .1, .25, .5, 1];
% percentCorrectionTrials = .1;
%         
%      case 'g62b7lt'            %set variable parameters
%    targetOrientations = [(-pi/4)+(pi/2),(-pi/8)+(pi/2),(-3*pi/16)+(pi/2), (-pi/16)+(pi/2), 0+(pi/2)];
%    distractorOrientations = [0, (pi/16), (pi/8), (3*pi/16), (pi/4)];
%    percentCorrectionTrials = .1;
%     otherwise
%         warning('unrecognized mouse, using defaults')
% end



stim.stim = orientedGabors(pixPerCycs,{distractorOrientations [] targetOrientations},'abstract',mean,radius,contrast,thresh,normalizedPosition,maxWidth,maxHeight,scaleFactor,interTrialLuminance,[],[],axis);

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