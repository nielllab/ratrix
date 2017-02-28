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
msAirpuff                 =0;
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
    
    case 'hvvtest' 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .75; 
       
   case 'g62zz2tt' % Started 2/1/17  %%start hvv_center 2/18/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .75;             
       
%     case 'g62aaa3rt' % Started 2/1/17  %%switch 2/9/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 219;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5;        
       
%    case 'g62mm11lt' % Started 2/1/17 %%switch 2/8/17
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .5; 
       
   case 'g62uu1tt' % Started 2/1/17 %%switch 2/8/17
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .75;         
    
        case 'g62kk9rn' % Started 8/23/16 %moved to HvV_center 9/23/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .75;  
    
    
    case 'g62kk10tt' % Started 8/23/16 %%start hvv 9/19/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .75;         
       
   case 'pvchr3b11nt' % Started 9/20/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .75;  
    
    case 'pvchr3b11tt' % Started 9/16/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .75; 
       
    case 'pvchr3b11lt' % Started 9/8/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .75; 
    
    case 'pvchr3b11rt' % Started 9/8/16 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 219;
       msPenalty               =3500;
       percentCorrectionTrials = .75;   
    
    case 'hvvtest' 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 75;
       msPenalty               =5000;
       percentCorrectionTrials = .75;  
    
   case 'pvchr2b16tt' % Started 7/11/16 %%HvH 7/22/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 187;
       msPenalty               =3500;
       percentCorrectionTrials = .75;     
    
   case 'pvchr2b16lt' % Started 7/11/16 %%HvH 7/22/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 187;
       msPenalty               =3500;
       percentCorrectionTrials = .75;  
    
   case 'testHvVcenter' % 
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 59;
       msPenalty               =6300;
              
    
%    case 'g62jj2lt' % Started 5/4/16 %started HvV_center 5/15/16
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 123;
%        msPenalty               =3500;
%        percentCorrectionTrials = .75;
    
   case 'g62jj2rt' % Started 5/4/16  %started HvV_center 5/15/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
       msPenalty               =3500;
       percentCorrectionTrials = .75;
    
    case 'g62kk10tt' % Started 8/23/16 %switched to HvV_center 9/8/16
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 123;
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