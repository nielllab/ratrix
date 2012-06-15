function r = setProtocolCMN(r,subjIDs)

if ~exist('r','var') || isempty(r)
    dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'mouseData',filesep);
    %dataPath='\\mtrix2\Users\nlab\Desktop\mouseData\';
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
widthpix = 1980;
widthcm = 50;
pixpercm = widthpix/widthcm;
dist = 15;
degpercm = atand((0.25*widthcm+1)/dist) - atand(0.25*widthcm/dist);
pixperdeg = pixpercm/degpercm

cpd=0.1
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

%distractorOrientations=-targetOrientations;
targetOrientations = 0;
distractorOrientations = pi/2;
orientation = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

requestRewardSizeULorMS = 0;
msPenalty               = 1000;
noRequest=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
nrTM=nAFC(sm,percentCorrectionTrials,noRequest,eyeController,{'off'},dropFrames,'ptb','center');

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';

trialsPerMinute = 7;
minutes = .5;
numTriggers = 20;
ts1 = trainingStep(fd,  freeStim, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %stochastic free drinks
ts2 = trainingStep(fd2, freeStim, numTrialsDoneCriterion(numTriggers)   , noTimeOff(), svnRev,svnCheckMode);  %free drinks

% %%% try next time
% %%% free drips
% trialsPerMinute = 10;
% minutes = 60;  %%% basically 10 triggered trials period
% ts1 = trainingStep(fd,  freeStim, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %stochastic free drinks
% 
% %%% turn off stochastic drips
% trialsPerMinute = 7;
% minutes = 0.5;  %%% now go for speed
% ts2 = trainingStep(fd2,  freeStim, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %stochastic free drinks

%nafc
trialsPerMinute = 6;
minutes = 1;
ts3 = trainingStep(nafcTM, freeStim, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %side discrim

%no request reward
ts4 = trainingStep(nrTM  , freeStim,  numTrialsDoneCriterion(400)          , noTimeOff(), svnRev,svnCheckMode);

%long penalty
msPenalty = 3000;
rewardSizeULorMS=30;
longPenalty=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
lpTM=nAFC(sm,percentCorrectionTrials,longPenalty,eyeController,{'off'},dropFrames,'ptb','center',[],[],[300 inf]);
ts5 = trainingStep(lpTM  , freeStim, performanceCriterion(.85,int32(300))  , noTimeOff(), svnRev,svnCheckMode);

%orientation discirm
ts6 = trainingStep(lpTM  , orientation, repeatIndefinitely()                  , noTimeOff(), svnRev,svnCheckMode);

p=protocol('mouse orientation',{ts1, ts2, ts3, ts4, ts5, ts6});

for i=1:length(subjIDs),
    subj=getSubjectFromID(r,subjIDs{i});

    % set to defined step    
%     switch subjIDs{i}
%         case 'test'
%             stepNum=uint8(5);
%         otherwise
%             stepNum=uint8(5);
%     end
    
    % keep on current step
    [currentp stepNum]=getProtocolAndStep(subj);
    
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolMouse','edf');
end