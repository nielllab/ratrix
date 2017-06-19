function r = setProtocolHvV_vertical(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =59;
requestRewardSizeULorMS   =0;
requestMode               ='first';
msPenalty                 =3500;         
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =0;
%pixPerCycs                = [100 150 200]; %*10^9;
pixPerCycs              = [200];
percentCorrectionTrials = .5;
normalizedPosition      = [0.33 0.66];
radius                 = .25;

% sca
% keyboard

if ~isscalar(subjIDs)
    error('expecting exactly one subject')
end
 switch subjIDs{1}
     
    case 'test' 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5;     
       pixPerCycs              = [200];
       normalizedPosition      = [0.50 0.66];
       radius                 = .27; 
       
    case 'g62zz9tt'  %started 5/4/17 %%start hvv 5/16/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;
         pixPerCycs              = [200];
         normalizedPosition      = [0.46 0.54];
         radius                 = .35; 
       
   case 'g62aaa11lt'  %started 4/25/17 %%start center 5/4/17 %%%full 5/24/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;         
         normalizedPosition      = [0.33 0.66];
         radius                 = .27;        
       
   case 'g62aaa10tt' % Started 4/07/17 %%start hvv center 4/15/17 %%%full 5/23/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       normalizedPosition      = [0.33 0.66];
       radius                 = .34;
       
    case 'g62aaa10lt' % Started 4/07/17 %%start hvv 4/15/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;          
       pixPerCycs              = [200];
       normalizedPosition      = [0.38 0.62];
       radius                 = .35;        

    case 'g62ddd3tt' % Started 4/05/17 %%hvv start 4/14/17 %%%full 5/17/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       normalizedPosition      = [0.33 0.66];
       radius                 = .33;        
       
   case 'g62aaa11rt'  %started 4/25/17 %%hvv center 5/10/17 %%%full 5/17/17
         requestRewardSizeULorMS = 0;
         rewardSizeULorMS        = 219;
         msPenalty               =3500;
         percentCorrectionTrials = .5;
         normalizedPosition      = [0.44 0.56];
         radius                 = .34; 
       
   case 'g62ddd3ln' % Started 4/05/17  %%hvv center 4/15/17 %%%full 4/26/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;       
       pixPerCycs              = [200];
       normalizedPosition      = [0.33 0.66];
       radius                 = .25;  
       
   case 'g62ww3rt' % Started 4/05/17 %%hvv start 4/13/17 %%full 4/24/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       pixPerCycs              = [200];
       normalizedPosition      = [0.33 0.66];
       radius                 = .25;         

   case 'g62aaa4tt' % Started 3/29/17 %%hvv start 4/8/17 %%full 4/24/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       pixPerCycs              = [200];
       normalizedPosition      = [0.33 0.66];
       radius                 = .25;  

   case 'g62ggg6tt' % Started 3/29/17 %%hvv start 4/8/17 %%full 4/24/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       pixPerCycs              = [200];
       normalizedPosition      = [0.33 0.66];
       radius                 = .26;         
       
   case 'g62ss4lt' % Started 4/07/17  %%hvv center 4/15/17 %%full 4/24/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       pixPerCycs              = [200];
       normalizedPosition      = [0.33 0.66];
       radius                 = .25;  
     
   case 'g62uu1tt' % Started 2/1/17 %%switch 2/8/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .6;
       pixPerCycs              = [200];
       normalizedPosition      = [0.35 0.64];
       radius                 = .35;  
       
    case 'g62mm11lt' % Started 2/1/17 %%switch 2/8/17 %%%switch full 2/27/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5;     
       pixPerCycs              = [200];
       normalizedPosition      = [0.33 0.66];
       radius                 = .29;
       
    case 'g62aaa3rt' % Started 2/1/17  %%switch 2/9/17 %%%switch full 2/27/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       pixPerCycs              = [200];
       normalizedPosition      = [0.33 0.66];
       radius                 = .26;
     
   
  case 'test' % Started 5/4/16 %started HvV 9/6/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .5;     
       pixPerCycs              = [200];
       normalizedPosition      = [0.48 0.52];
       radius                 = .34;
       
  

  
     case 'testpixhvv' % Started 5/18/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 60;
       msPenalty               =3000;
       pixPerCycs              = [400];
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

targetOrientations     = 0
distractorOrientations = []; %-targetOrientations;
mean                   = .5;

contrast               = 1;
thresh                 = .00005;
scaleFactor            = 0; %[1 1];
axis                   = pi/2;




%%% abstract orientation (e.g. 0 = go left, pi/2 = go right)
targetOrientations = pi/2;
distractorOrientations = 0;


% %for creating psychometric curves (contrast and orientation
% switch subjIDs{1}
%         
%       case 'g62b1lt'     %set variable parameters 
%             contrast               = [.01, .05, .1, .25, .5, 1];
% percentCorrectionTrials = .1;
%         
%        case 'g62b3rt'           %set variable parameters 
%    %targetOrientations = [(-pi/4)+pi/2,(-pi/8)+pi/2, (-pi/16)+pi/2, 0+pi/2, (pi/16)+pi/2, (pi/8)+pi/2, (pi/4)+pi/2];
%       targetOrientations = [(-pi/4)+(pi/2),(-pi/8)+(pi/2),(-3*pi/16)+(pi/2), (-pi/16)+(pi/2), 0+(pi/2)];
%    distractorOrientations = [0, (pi/16), (pi/8), (3*pi/16), (pi/4)];
%    %distractorOrientations = [(-pi/4),(-pi/8), (-pi/16), 0, (pi/16), (pi/8), (pi/4)];
%    percentCorrectionTrials = .1;
%     otherwise
%         warning('unrecognized mouse, using defaults')
% end



stim.stim = orientedGabors(pixPerCycs,{distractorOrientations [] targetOrientations},'abstract',mean,radius,contrast,thresh,normalizedPosition,maxWidth,maxHeight,scaleFactor,interTrialLuminance,[],[],axis);
%  ballSM = trail(stim,maxWidth,maxHeight,zoom,interTrialLuminance);
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