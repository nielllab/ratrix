function r = setProtocolGoToBlack(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =171;
requestRewardSizeULorMS   =0;% start at 75 for 3-4 sessions, until reliably requesting 200trials/hr
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

        
    case 'pvarch515nt'  %started 9/27/17
         requestRewardSizeULorMS = 75;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;  
    
    case 'pvarch515tt'  %started 9/27/17
         requestRewardSizeULorMS = 75;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;  
    
    case 'pvarch5154t'  %started 9/27/17
         requestRewardSizeULorMS = 75;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;  
    
    case 'pvarch515lt'  %started 9/27/17
         requestRewardSizeULorMS = 75;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;  
    
    
    case 'j363lt'  %started 9/13/17
         requestRewardSizeULorMS = 0; %stop reward
         rewardSizeULorMS        = 219; %doesnt do shit, change in google docs
         msPenalty               =3500;
         percentCorrectionTrials = .5; 
         
        case 'j363rt'  %started 9/13/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;  
         
          case 'j364lt'  %started 9/13/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5; 
    
         case 'j364rt'  %started 9/13/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5; 

         case 'j364tt'  %started 9/13/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5; 
         
        case 'j364nt'  %started 9/13/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;  
         
          case 'j365lt'  %started 9/13/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5; 
    
         case 'j365rt'  %started 9/13/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;       
         
         case 'j365tt'  %started 9/13/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;  
 
          case 'j366lt'  %started 9/13/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5; 
    
         case 'j366rt'  %started 9/13/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;       
         
         case 'j366tt'  %started 9/13/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;          
         
%          case 'j351tt'  %started 7/26/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5;  
%          
%          case 'j351rt'  %started 7/26/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5;   
%          
%          case 'j351lt'  %started 7/26/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5;      
%         
%          case 'j352tt'  %started 7/26/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5;      
%         
%          case 'j352rt'  %started 7/26/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5;      
%     
%          case 'j352lt'  %started 7/26/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5;  
    
    
%            case 'pvchr4b16nt'  %started 5/26/17 xx
%            requestRewardSizeULorMS = 0;
%            rewardSizeULorMS        = 219;
%            msPenalty               =3500;
%            percentCorrectionTrials = .5; 
    %            case 'pvchr4b16rt'  %started 5/26/17
%            requestRewardSizeULorMS = 0;
%            rewardSizeULorMS        = 219;
%            msPenalty               =3500;
%            percentCorrectionTrials = .5; 

    
%            case 'pvchr4b16lt'  %started 5/26/17
%            requestRewardSizeULorMS = 0;
%            rewardSizeULorMS        = 219;
%            msPenalty               =3500;
%            percentCorrectionTrials = .5; 
    
    
%          case 'g62zz9tt'  %started 5/4/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5;       
    
%          case 'pvchr4b14tt'  %started 4/27/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5; 
         
%          case 'pvchr4b14lt'  %started 4/27/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5;     
    
%          case 'g62aaa11rt'  %started 4/25/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5;      
    
%          case 'g62aaa11lt'  %started 4/25/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5;    
    
%          case 'pvchr4b14nt'  %started 4/26/17.
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5; 
    
%          case 'pvchr4b14rt'  %started 4/26/17
%          requestRewardSizeULorMS = 0;
%          rewardSizeULorMS        = 219;
%          msPenalty               =3500;
%          percentCorrectionTrials = .5; 
    
    
%        case 'g62aaa10lt' % Started 4/07/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;    
    
%    case 'g62aaa10tt' % Started 4/07/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;    
    
%    case 'g62pp9lt' % Started 4/07/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;    
%     
%    case 'g62ddd2tt' % Started 4/07/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
    
%    case 'g62ss4lt' % Started 4/07/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;      
%     
% %    case 'g62ww3rt' % Started 4/05/17
% %        requestRewardSizeULorMS = 0;
% %        rewardSizeULorMS        = 219;
% %        msPenalty               =3500;
% %        percentCorrectionTrials = .5;        
%     
%    case 'g62ddd3ln' % Started 4/05/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;        
    
%    case 'g62ddd3tt' % Started 4/05/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;    
%     
   case '2blindg6b9lt' % Started 3/29/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
    
  
%    case 'g62ggg6tt' % Started 3/29/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;    
    
%    case 'g62aaa4tt' % Started 3/29/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;         
    

   case 'g62aaa3lt' % Started 2/1/17 %%started nieve 2/21/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;        
%     
%     
%    case 'g62uu4lt' % Started 2/1/17  %%start random 2/17/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%         percentCorrectionTrials = .0;  
%        
%    case 'g62aaa2lt' % Started 2/1/17  %%start random 2/15/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500; 
%         percentCorrectionTrials = .0;  
        
%    case 'pvchr238'  %started 3/6/17
%       requestRewardSizeULorMS = 0;
%       rewardSizeULorMS        = 219;
%       msPenalty               =3500;
%       percentCorrectionTrials = .5; 
    
    case 'testgotoblackstopime' % Started 6/25/15
       requestRewardSizeULorMS = 75;
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
stim.soundClue = true;

pixPerCycs             = [300]; %*10^9;
targetOrientations     = [-1 1]*pi/4;
distractorOrientations = []; %-targetOrientations;
mean                   = .5;
radius                 = .085;
contrast               = 1;
thresh                 = .00005;
yPosPct                = .5;
%stim.stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,zoom,interTrialLuminance);
%stim.stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,[-1 1]  ,thresh,yPosPct,maxWidth,maxHeight,zoom,interTrialLuminance,'none', 'normalizeDiagonal');

stim.stim='flip';
%stim.stim=nan;

switch subjIDs{1}  %toswitchprogramtogotowhite use   stim.stim=nan;  
   case '2blindg6b9lt' % Started 3/29/17
    stim.stim=nan;  
    
%         case 'test' % Started 6/25/15
%        stim.stim=nan; 
end      

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