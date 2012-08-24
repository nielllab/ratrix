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

sm=makeStandardSoundManager();

rewardSizeULorMS          =80;
requestRewardSizeULorMS   =80;
requestMode               ='first';
msPenalty                 =1000;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =msPenalty;

constantRewards=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);

allowRepeats=false;
freeDrinkLikelihood=0.004;
fd = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,constantRewards);

freeDrinkLikelihood=0;
fd2 = freeDrinks(sm,freeDrinkLikelihood,allowRepeats,constantRewards);

percentCorrectionTrials=.5;

maxWidth               = 1920;
maxHeight              = 1080;

[w,h]=rat(maxWidth/maxHeight);

eyeController=[];

dropFrames=false;
nafcTM=nAFC(sm,percentCorrectionTrials,constantRewards,eyeController,{'off'},dropFrames,'ptb','center');

textureSize=10*[w,h];
zoom=[maxWidth maxHeight]./textureSize;

%%% hard coded pixPerCycs
%%% pixPerCycs              =[100];

%%% calculate pixPerCycs based on parameters for current monitors
widthpix = 1920;
widthcm = 50;
pixpercm = widthpix/widthcm;
dist = 15;
% lateral stim
%degpercm = atand((0.25*widthcm+1)/dist) - atand(0.25*widthcm/dist);

% midline stim
degpercm = atand(1/dist)
pixperdeg = pixpercm/degpercm

cpd=0.16  %c1ln=hi  c1lt=lo  c2lt=hi  c3ln=lo

pixPerCycs = pixperdeg/cpd

targetOrientations      =[0];
distractorOrientations  =[];
mean                    =.5;
radius                  =.4;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.5;
scaleFactor            = 0; %[1 1];
interTrialLuminance     =.5;
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
freeStim_sm = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius/2,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

%distractorOrientations=-targetOrientations;
targetOrientations = 0;
distractorOrientations = pi/2;
orientation = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
abstract = orientedGabors(pixPerCycs,{distractorOrientations [] targetOrientations},'abstract',mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

cpd = 0.08;

targetOrientations  = pi/4 - linspace(0,pi/4,7);
distractorOrientations = pi/4 + linspace(0,pi/4,7);
abstractOrient = orientedGabors(pixperdeg./cpd,{distractorOrientations [] targetOrientations},'abstract',mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);



cpd = [0.02 0.04 0.08 0.16 0.32 0.64 1.28];
abstractSF = orientedGabors(pixperdeg./cpd,{distractorOrientations [] targetOrientations},'abstract',mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


requestRewardSizeULorMS = 0;
msPenalty               = 1000;
noRequest=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
nrTM=nAFC(sm,percentCorrectionTrials,noRequest,eyeController,{'off'},dropFrames,'ptb','center');

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';

trialsPerMinute = 7;
minutes = .5;
numTriggers = 20;
ts1 = trainingStep(fd,  freeStim_sm, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %stochastic free drinks
ts2 = trainingStep(fd2, freeStim_sm, numTrialsDoneCriterion(numTriggers)   , noTimeOff(), svnRev,svnCheckMode);  %free drinks

%nafc
trialsPerMinute = 6;
minutes = 1;
ts3 = trainingStep(nafcTM, freeStim, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %side discrim

%no request reward
ts4 = trainingStep(nrTM  , freeStim,  numTrialsDoneCriterion(400)          , noTimeOff(), svnRev,svnCheckMode);

%long penalty
msPenalty = 6000;
rewardSizeULorMS=60;
longPenalty=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
lpTM=nAFC(sm,percentCorrectionTrials,longPenalty,eyeController,{'off'},dropFrames,'ptb','center',[],[],[300 inf]);
ts5 = trainingStep(lpTM  , freeStim, performanceCriterion(.85,int32(300))  , noTimeOff(), svnRev,svnCheckMode);

%orientation discirm
ts6 = trainingStep(lpTM  , orientation, performanceCriterion(.85,int32(300))                  , noTimeOff(), svnRev,svnCheckMode);

%abstract
ts7 = trainingStep(lpTM  , abstract,    repeatIndefinitely()                  , noTimeOff(), svnRev,svnCheckMode);


ts8 = trainingStep(lpTM  , abstractSF,    repeatIndefinitely()                  , noTimeOff(), svnRev,svnCheckMode);

ts9 = trainingStep(lpTM  , abstractOrient,    repeatIndefinitely()                  , noTimeOff(), svnRev,svnCheckMode);

p=protocol('mouse orientation',{ts1, ts2, ts3, ts4, ts5, ts6, ts7, ts8,ts9});

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});

    % set to defined step    
    switch subjIDs{i}
        case 'test'
            stepNum=uint8(1);
        otherwise
            stepNum=uint8(9);
    end
  
   
   % keep on current step
   %[currentp stepNum]=getProtocolAndStep(subj);
    
    stepNum
   
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolMouse','edf');
end