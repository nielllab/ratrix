function r = setProtocolCMN(r,subjIDs)

if ~exist('r','var') || isempty(r)
    %dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'mouseData0512',filesep);
    dataPath='\\mtrix2\Users\nlab\Desktop\mouseData0512\';
    r=ratrix(fullfile(dataPath, 'ServerData'),0);
end

if ~isa(r,'ratrix')
    error('need a ratrix')
end


if ~exist('subjIDs','var') || isempty(subjIDs)
    %    subIDs=intersect(getEDFids,getSubjectIDs(r));
    subjIDs=getSubjectIDs(r);
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';

sm=makeStandardSoundManager();

rewardSizeULorMS          =80;
requestRewardSizeULorMS   =80;
requestMode               ='first';
msPenalty                 =1000;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;

maxWidth               = 1920;
maxHeight              = 1080;

[w,h]=rat(maxWidth/maxHeight);

%%% trial managers
constantRewards=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

% free drinks with drip
allowRepeats=false;
%freeDrinkLikelihood=0.004;
freeDrinkLikelihood=1/(60*15); %%% on average, once every 30 secs. == .001, ~4x less than before
fd = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,constantRewards);

% free drinks no drip
freeDrinkLikelihood=0;
fd2 = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,constantRewards);

% 2AFC with request reward
percentCorrectionTrials=.5;
eyeController=[];

dropFrames=false;
nafcTM=nAFC(sm,percentCorrectionTrials,constantRewards,eyeController,{'off'},dropFrames,'ptb','center');

% 2AFC with no request reward
requestRewardSizeULorMS = 0;
msPenalty               = 1000;
noRequest=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
nrTM=nAFC(sm,percentCorrectionTrials,noRequest,eyeController,{'off'},dropFrames,'ptb','center');

% 2AFC with long penalty
msPenalty = 6000;
longPenalty=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
lpTM=nAFC(sm,percentCorrectionTrials,longPenalty,eyeController,{'off'},dropFrames,'ptb','center',[],[],[300 inf]);

% 2AFC with long penalty &smaller reward (once performance >50%)
rewardSizeULorMS=60;
longPenalty=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
lpsrTM=nAFC(sm,percentCorrectionTrials,longPenalty,eyeController,{'off'},dropFrames,'ptb','center',[],[],[300 inf]);



%%% calculate pixPerCycs based on parameters for current monitors
widthpix = 1920;
widthcm = 50;
pixpercm = widthpix/widthcm;
dist = 15;

targetOrientations      =[0];
distractorOrientations  =[];
mean                    =.5;
radius                  =.4;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.5;
scaleFactor            = 0; %[1 1];
interTrialLuminance     =.5;


cpd=0.08 ;

% pixel calibration - lateral stim
degpercm = atand((0.25*widthcm+1)/dist) - atand(0.25*widthcm/dist);
pixperdeg = pixpercm/degpercm;
pixPerCycs = pixperdeg/cpd;

%%% stim - go to target
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
%%% small stim for first steps, when they can overlap
freeStim_sm = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius/2,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

freeStim = setReinfAssocSecs(freeStim,1);

%%% stim  - go to target with distractor
targetOrientations = 0;
distractorOrientations = pi/2;
orientation = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
orientation=setReinfAssocSecs(orientation,1);


%%% stim  - go to target with distractor
targetOrientations = pi/4;
distractorOrientations = -pi/4;
orientationOblique = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
orientationOblique=setReinfAssocSecs(orientationOblique,1);

% pixel calibration midline stim
degpercm = atand(1/dist);
pixperdeg = pixpercm/degpercm;
pixPerCycs = pixperdeg/cpd;

%%% abstract orientation (e.g. vert = go left, horiz = go right)
abstract = orientedGabors(pixPerCycs,{distractorOrientations [] targetOrientations},'abstract',mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
abstract = setReinfAssocSecs(abstract,1);

%%% abstract orientation - psychometric curve for orientiation difference
targetOrientations  = pi/4 - linspace(0,pi/4,7);
distractorOrientations = -targetOrientations;
abstractOrient = orientedGabors(pixperdeg./cpd,{distractorOrientations [] targetOrientations},'abstract',mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

%%% abstract orientation - psychometric curve for SF
cpd = [0.02 0.04 0.08 0.16 0.32 0.64 1.28];
abstractSF = orientedGabors(pixperdeg./cpd,{distractorOrientations [] targetOrientations},'abstract',mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


% trialsPerMinute = 7;
% minutes = .5;
% numTriggers = 20;
% ts1 = trainingStep(fd,  freeStim_sm, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %stochastic free drinks
% ts2 = trainingStep(fd2, freeStim_sm, numTrialsDoneCriterion(numTriggers)   , noTimeOff(), svnRev,svnCheckMode);  %free drinks

%%% try this time
%%% free drips
numTriggers = 20;
ts1 = trainingStep(fd,  freeStim_sm, numTrialsDoneCriterion(numTriggers) , noTimeOff(), svnRev,svnCheckMode);  %stochastic free drinks

%%% turn off stochastic drips
trialsPerMinute = 7;
minutes = 0.5;  %%% now go for speed
ts2 = trainingStep(fd2,  freeStim_sm, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %stochastic free drinks

%nafc
trialsPerMinute = 6;
minutes = 1;
ts3 = trainingStep(nafcTM, freeStim, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %side discrim

%no request reward
ts4 = trainingStep(nrTM  , freeStim,  numTrialsDoneCriterion(400)          , noTimeOff(), svnRev,svnCheckMode);

%long penalty
ts5 = trainingStep(lpTM  , freeStim, performanceCriterion(.85,int32(300))  , noTimeOff(), svnRev,svnCheckMode);

%orientation discrim (with distractor)
ts6 = trainingStep(lpsrTM  , orientation, performanceCriterion(.85,int32(300))                , noTimeOff(), svnRev,svnCheckMode);

%orientation discrim (oblique)
ts7 = trainingStep(lpsrTM  , orientationOblique, repeatIndefinitely()                   , noTimeOff(), svnRev,svnCheckMode);


%abstract - orientation discrim
ts8 = trainingStep(lpsrTM  , abstract,    repeatIndefinitely()                  , noTimeOff(), svnRev,svnCheckMode);


% abstract - SF psychometric curve
ts9 = trainingStep(lpsrTM  , abstractSF,    repeatIndefinitely()                  , noTimeOff(), svnRev,svnCheckMode);

% abstract - orientation pyschometric curve
ts10 = trainingStep(lpsrTM  , abstractOrient,    repeatIndefinitely()                  , noTimeOff(), svnRev,svnCheckMode);

p=protocol('mouse orientation',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8,ts9,ts10});

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});

%     % set to defined step    
%     switch subjIDs{i}
%         case 'test'
%             stepNum=uint8(1);
%         otherwise
%             stepNum=uint8(1);
%     end
  
   
   % keep on current step
   [currentp stepNum]=getProtocolAndStep(subj);
    
    stepNum
   
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolMouse','edf');
end