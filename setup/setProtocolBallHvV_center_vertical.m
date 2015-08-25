function r = setProtocolHvV_center_vertical(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =80;
requestRewardSizeULorMS   =5;
requestMode               ='first';
msPenalty                 =3500;     %consider changing this also in future
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;
pixPerCycs                = [200];
percentCorrectionTrials = .5;

% sca
% keyboard

if ~isscalar(subjIDs)
    error('expecting exactly one subject')
end
switch subjIDs{1}
    
    
    case 'testHvVcenter' % Switched full 10/9/14
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 45;
       msPenalty               =4300;
       
       
  
       
      case 'g62n7ln' % Started 7/14/15 %%switch center 8/12/15
       requestRewardSizeULorMS = 00;
       rewardSizeULorMS        = 91;
       msPenalty               =3500;
       percentCorrectionTrials = .5;
       
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

stim.gain = 0.7 * ones(2,1);
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
radius                 = .25;
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