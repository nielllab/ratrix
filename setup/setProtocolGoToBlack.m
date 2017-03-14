function r = setProtocolGoToBlack(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =171;
requestRewardSizeULorMS   =0;
requestMode               ='first';
msPenalty                 =3500;       %consider changing this also in future
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =0;
stim.slowSecs = 1;
percentCorrectionTrials = .5;

stim.gain = 0.7 * ones(2,1);



switch subjIDs{1}


    case 'pvchr238'  %started 3/6/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5; 
    
   %case 'pvchr4b8tt' %started 2/16/17
%       requestRewardSizeULorMS = 0;
%       rewardSizeULorMS        = 219;
%       msPenalty               =3500;
%       percentCorrectionTrials = .5; 
    
    %    case 'g62aaa3rt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
    
%    case 'g62aaa3lt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
    
%    case 'g62aaa2lt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
    
%    case 'g62uu4lt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
    
%    case 'pvchr4b1rt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
% 
%    case 'pvchr4b1lt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
%     
%    case 'pvchr4b2ln' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
%     
%    case 'pvchr4b2tt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;  
    
%    case 'g62zz2tt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
       
%    case 'pvchr3b14rt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;       
    
%    case 'g62rr1lt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
%     
%    case 'g62pp6rt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
    
%    case 'g62pp4rt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;  
    
%    case 'g62mm11lt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5; 
    
%    case 'g62uu1tt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;    
    
%    case 'g62uu1rt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5; 
       
%     case 'g62uu1lt' % Started 2/1/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;       

   %case 'pvchr4b4nt' %started 1/23/17
   %    requestRewardSizeULorMS = 0;
   %    rewardSizeULorMS        = 219;
   %    msPenalty               =3500;
   %    percentCorrectionTrials = .5; 
  
   %case 'pvchr4b4rt' %started 1/23/17
   %    requestRewardSizeULorMS = 0;
   %    rewardSizeULorMS        = 219;
   %    msPenalty               =3500;
   %    percentCorrectionTrials = .5; 
    
   %case 'pvchr4b4lt' %started 1/23/17
   %    requestRewardSizeULorMS = 0;
   %    rewardSizeULorMS        = 219;
   %    msPenalty               =3500;
   %    percentCorrectionTrials = .5; 
    
   %case 'pvchr4b3rt' %started 1/23/17
   %    requestRewardSizeULorMS = 0;
   %    rewardSizeULorMS        = 219;
   %    msPenalty               =3500;
   %    percentCorrectionTrials = .5;  
    
   %case 'pvchr4b3tt' %started 1/23/17
   %    requestRewardSizeULorMS = 0;
   %    rewardSizeULorMS        = 219;
   %    msPenalty               =3500;
   %    percentCorrectionTrials = .5; 
  
 
    
   case 'g62jj2rt' 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       
  case 'g62qq1rt' % Started 11/2/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;      
       
  case 'g62kk12rt' % Started 10/21/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 91;
       msPenalty               =3500;
       percentCorrectionTrials = .5;        
    
  case 'g62ff13lt' % Started 10/21/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 59;
       msPenalty               =3500;
       percentCorrectionTrials = .5;    
    
    
  case 'g62tx1.5lt' % Started 1/12/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 59;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
      
    
    
   case 'g62gg5rt' % Started 4/13/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 59;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       
   case 'g62bb10lt' % Started 4/13/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 59;
       msPenalty               =3500;
       percentCorrectionTrials = .6;   
    
    case 'g62tt1lt' % Started 10/6/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;     
    
%     case 'g62qq1rt' % Started 10/6/16 
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;  
    
    case 'g62qq2lt' % Started 10/3/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;     
    
    case 'g62cc16ln' % Started 9/28/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5; 
    
    case 'g62cc16lt' % Started 9/28/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5; 
       
     case 'test2' % Started 9/9/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;     

    case 'g62ss2rt' % Started 9/16/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;              
             
       
    case 'g62mm9ln' % Started 9/9/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;  
    
    case 'pvchr3b15rt' % Started 9/9/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;       
    
    case 'pvchr3b15lt' % Started 9/9/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;   
%     
    case 'pvchr3b14tt' % Started 9/9/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;  
       

       
    case 'pvchr3b14lt' % Started 9/9/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219; 
       msPenalty               =3500;
       percentCorrectionTrials = .5;  
       
       
%    case 'pvchr3b11rt' % Started 8/30/16 
%       requestRewardSizeULorMS = 0;
%       rewardSizeULorMS        = 219;
%       msPenalty               =3500;
%       percentCorrectionTrials = .5;   
    
%    case 'pvchr3b11lt' % Started 8/30/16 
%       requestRewardSizeULorMS = 0;
%       rewardSizeULorMS        = 219;
%       msPenalty               =3500;
%       percentCorrectionTrials = .5;   
    
%    case 'pvchr3b11tt' % Started 8/30/16 
%       requestRewardSizeULorMS = 0;
%       rewardSizeULorMS        = 219;
%       msPenalty               =3500;
%       percentCorrectionTrials = .5;   
    
%    case 'pvchr3b11nt' % Started 8/30/16 
%       requestRewardSizeULorMS = 0;
%       rewardSizeULorMS        = 219;
%       msPenalty               =3500;
%       percentCorrectionTrials = .5;   
%    
%     case 'g62kk9rn' % Started 8/23/16 
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;     
    
    case 'g62kk10ln' % Started 8/23/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;     
    
    case 'g62kk10tt' % Started 8/23/16 %switched to HvV_center 9/8/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;     
       
    case 'g62dd15rt' % Started 8/23/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;      
    
    case 'g62ff11rt' % Started 8/15/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;    
       
     case 'g62kk7lt' % Started 8/2/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;      
    
%    case 'pvchr2b16tt' % Started 7/11/16 
%       requestRewardSizeULorMS = 0;
%       rewardSizeULorMS        = 219;
%       msPenalty               =3500;
%       percentCorrectionTrials = .5;     
%    
%    case 'pvchr2b16lt' % Started 7/11/16 
%       requestRewardSizeULorMS = 0;
%       rewardSizeULorMS        = 219;
%       msPenalty               =3500;
%       percentCorrectionTrials = .5;  
       
%     case 'g62gg10lt' % Started 7/20/16 
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;     
    
    case 'g62cc13lt' % Started 7/8/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;    
    
    case 'g62dd11lt' % Started 7/8/16 
       requestRewardSizeULorMS = 43;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;      
       
    case 'g62ff8rt' % Started 7/1/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;       

    
%     case 'g62ll5lt' % Started 6/27/16 
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;   
%       
%     case 'g62jj3rt' % Started 6/27/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;   
    
    case 'g62dd9lt' % Started 6/14/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;   
%     
%     case 'g62ff7ln' % Started 6/14/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;        
    
%     case 'g62ll3rt' % Started 5/30/16 %sent back 7/5/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;     
%     
%     case 'g62ll4lt' % Started 5/22/16  
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5; 
    
%     case 'g62gg7lt' % Started 5/12/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;    
    
    
   case 'g62bb12lt' % Started 5/12/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;


    
%    case 'g62cc9rt' % Started 4/24/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;

       
%    case 'g62ff6lt' % Started 4/13/16 
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;

    
%     case 'g62gg5rt' % Started 4/13/16 
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;

    
%    case 'g62hh6rt' % Started 4/13/16 
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;

       
%    case 'g62hh6ln' % Started 4/13/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
 
%    case 'g62bb10lt' % Started 4/13/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;

       
%    case 'g62dd6lt' % Started 4/13/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;

         
%    case 'g62tx2.14rt' % Started 4/13/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;
 
       
%    case 'g62ff4lt' % Started 4/13/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;

       
%    case 'sanjay' % Started 4/13/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;

%        
    case 'g62bb8tt' % Started 2/9/16  %started HvV_center 2/20/16 %restarted HvV_center 4/2/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 139;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
        stim.gain = 0.55 * ones(2,1); %try this since has trouble fully stopping 4/6/16
       
%        
%     case 'g62dd5' % Started 2/29/16 %back to GoToBlack 4/2/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 139;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;     
%       
    case 'g62bb8rt' % Started 2/9/16  %started HvV_center 2/20/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 139;
       msPenalty               =3500;
       percentCorrectionTrials = .5;    
    
    case 'g62y3lt' % Started 1/12/16 switch to GTS 1/29/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 59;
       msPenalty               =3500;
       percentCorrectionTrials = .6;  
%     
%     case 'g62tx1.5lt' % Started 1/12/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 59;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;  

    case 'testgotoblackstopime' % Started 6/25/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 171;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       stim.slowSecs = 1;



            

        

            
    otherwise
        warning('unrecognized mouse, using defaults')
end;     



noRequest = constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);



maxWidth  = 1920;
maxHeight = 1080;

[w,h] = rat(maxWidth/maxHeight);
textureSize = 10*[w,h];
zoom = [maxWidth maxHeight]./textureSize;

svnRev = {}; %{'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode = 'session';

interTrialLuminance = .5;

stim.targetDistance = 455 * ones(1,2);
stim.timeoutSecs = 10;
stim.slow = [40; 80]; % 10 * ones(2,1);
%stim.slowSecs = 1;  set above for case by case
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

 ballSM = setReinfAssocSecs(trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance),1);
 %change stim to stay on for 1 sec after
 
ballTM = ball(percentCorrectionTrials,sm,noRequest);
ts1 = trainingStep(ballTM, ballSM, repeatIndefinitely(), noTimeOff(), svnRev, svnCheckMode); %ball

p=protocol('mouse',{ts1});

stepNum=uint8(1);
subj=getSubjectFromID(r,subjIDs{1});
[subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolMouse','edf');
end