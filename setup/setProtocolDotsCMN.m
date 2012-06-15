function r = setProtocolDotsCMN(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =60;
requestRewardSizeULorMS   =60;
requestMode               ='first';
msPenalty                 =6000;
fractionOpenTimeSoundIsOn =1;
fractionPenaltySoundIsOn  =1;
scalar                    =1;
msAirpuff                 =0;

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
textureSize=10*[h,h];
zoom=[maxHeight maxHeight]./textureSize;

%%% calculate pixPerCycs based on parameters for current monitors
widthpix = 1980;
widthcm = 50;
pixpercm = maxWidth/widthcm;
dist = 20;
%degpercm = atand((0.25*widthcm+1)/dist) - atand(0.25*widthcm/dist);
%
degpercm = atand(1/dist);
pixperdeg = pixpercm/degpercm;
hz=60;

eyeController=[];

coherence=1;
contrast=1;

speed_degpersec = 30;
size_deg = 10;
density = 0.04;

speed = speed_degpersec*pixperdeg*(1/hz)/zoom(1);
dotSize = round(size_deg*pixperdeg/zoom(1))
numDots = round(density*(norm(textureSize).^2)/(dotSize^2))
% speed=.75*2;
% contrast=1*.25;
% dotSize=5*4;
% numDots=round(75/15);

duration=10;

dots=coherentDots(textureSize(1),textureSize(2),numDots,coherence,speed,contrast,dotSize,duration,zoom,maxWidth,maxHeight,[],0.5);

dropFrames=false;
nafcTM=nAFC(sm,percentCorrectionTrials,constantRewards,eyeController,{'off'},dropFrames,'ptb','center');


%dots=setShapeMethod(setPosition(setSideDisplay(dots,.5),.25),'position');

requestRewardSizeULorMS = 0;
msPenalty               = 1000;
noRequest=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
nrTM=nAFC(sm,percentCorrectionTrials,noRequest,eyeController,{'off'},dropFrames,'ptb','center');

svnRev={'svn://132.239.158.177/projects/ratrix/trunk'};
svnCheckMode='session';

trialsPerMinute = 7;
minutes = .5;
numTriggers = 20;
ts1 = trainingStep(fd,  dots, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %stochastic free drinks
ts2 = trainingStep(fd2, dots, numTrialsDoneCriterion(numTriggers)   , noTimeOff(), svnRev,svnCheckMode);  %free drinks

trialsPerMinute = 6;
minutes = 1;
ts3 = trainingStep(nafcTM, dots, rateCriterion(trialsPerMinute,minutes), noTimeOff(), svnRev,svnCheckMode);  %coherent dots

background.contrastFactor=2;
background.sizeFactor=2;
background.densityFactor=0;
dots=setBackground(dots,background);

ts4 = trainingStep(nrTM  , dots,  numTrialsDoneCriterion(400)          , noTimeOff(), svnRev,svnCheckMode);  %coherent dots

msPenalty = 6000;
longPenalty=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
lpTM=nAFC(sm,percentCorrectionTrials,longPenalty,eyeController,{'off'},dropFrames,'ptb','center',[],[],[300 inf]);
ts5 = trainingStep(lpTM  , dots, repeatIndefinitely()                  , noTimeOff(), svnRev,svnCheckMode);  %coherent dots


p=protocol('mouse',{ts1, ts2, ts3, ts4, ts5});

if true
    stepNum=uint8(4);
    subj=getSubjectFromID(r,subjIDs{1});
    [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolMouse','edf');
else
    %not the right way to do this
    if strcmp(subjIDs,'all')
        subjIDs=getSubjectIDs(r);
    end
    
    for i=1:length(subjIDs),
        subj=getSubjectFromID(r,subjIDs{i});
        switch subjIDs{i}
            case {'e1rt','e2rt','e1lt','e2lt'}
                stepNum=uint8(5);
            case {'n5rt','n5rn','n5lt','n8lt'}
                stepNum=uint8(1);
            otherwise
                break %this won't work cuz standAloneRun will try to run the subject after this
        end
        [subj r]=setProtocolAndStep(subj,p,true,false,true,stepNum,r,'call to setProtocolMouse','edf');
    end
end