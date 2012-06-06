function r = setProtocolMouse(r,subjIDs)

if ~isa(r,'ratrix')
    error('need a ratrix')
end

if ~all(ismember(subjIDs,getSubjectIDs(r)))
    error('not all those subject IDs are in that ratrix')
end

sm=makeStandardSoundManager();

rewardSizeULorMS          =20;
requestRewardSizeULorMS   =20;
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

% maxWidth               = 1280;
% maxHeight              = 1024;

[w,h]=rat(maxWidth/maxHeight);

eyeController=[];

dropFrames=false;
nafcTM=nAFC(sm,percentCorrectionTrials,constantRewards,eyeController,{'off'},dropFrames,'ptb','center');

coherence=1;

speed=.75*2;
contrast=1;%*.25;
dotSize=4;
numDots=round(75/15);

duration=10;
textureSize=10*[w,h];
zoom=[maxWidth maxHeight]./textureSize;
textureSize(1) = floor(textureSize(1)*.7);
dots=coherentDots(textureSize(1),textureSize(2),numDots,coherence,speed,contrast,dotSize,duration,zoom,maxWidth,maxHeight);

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
background.densityFactor=10;
dots=setBackground(dots,background);

ts4 = trainingStep(nrTM  , dots,  numTrialsDoneCriterion(400)          , noTimeOff(), svnRev,svnCheckMode);  %coherent dots

msPenalty = 3000;
longPenalty=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msAirpuff);
lpTM=nAFC(sm,percentCorrectionTrials,longPenalty,eyeController,{'off'},dropFrames,'ptb','center',[],[],[300 inf]);
ts5 = trainingStep(lpTM  , dots, repeatIndefinitely()                  , noTimeOff(), svnRev,svnCheckMode);  %coherent dots

ballSM = trail(struct,maxWidth,maxHeight,zoom,0);
ballTM = ball(percentCorrectionTrials,sm,noRequest);
ts6 = trainingStep(ballTM, ballSM, repeatIndefinitely()                  , noTimeOff(), svnRev,svnCheckMode);  %ball

p=protocol('mouse',{ts1, ts2, ts3, ts4, ts5, ts6});

if true
    stepNum=uint8(3);
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