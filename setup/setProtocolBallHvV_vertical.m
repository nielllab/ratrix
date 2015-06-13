function r = setProtocolHvV_vertical(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =20;
requestRewardSizeULorMS   =0;
requestMode               ='first';
msPenalty                 =4000;         
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =0;
pixPerCycs                = [200]; %*10^9;
percentCorrectionTrials = .5;
normalizedPosition      = [0.33 0.66];

% sca
% keyboard

if ~isscalar(subjIDs)
    error('expecting exactly one subject')
end
 switch subjIDs{1}

    
     case 'g62r3rt' % Started 2/17/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 50;
       msPenalty               =3000;
       percentCorrectionTrials = .5;
     
     case 'g62a5nn' % Started 5/15/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 40;
       msPenalty               =3000;
       percentCorrectionTrials = .50;
     
     case 'g62a4tt' % Started 5/14/15
       requestRewardSizeULorMS = 0;
       rewardSizeULorMS        = 40;
       msPenalty               =3000;
       percentCorrectionTrials = .50;
     
%      case 'g62l8rn'     %Started from Go To Black 3/8/15
%        requestRewardSizeULorMS = 0;
%        rewardSizeULorMS        = 25;
%        msPenalty               = 3500;
%        percentCorrectionTrials = .50;
  
        

           
       
    otherwise
        warning('unrecognized mouse, using defaults')
end

noRequest = constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);


percentCorrectionTrials = .5;

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
radius                 = .25;
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