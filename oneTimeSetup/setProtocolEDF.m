function setProtocolEDF(ratID)
% if ~any(strcmp(ratID,{'171','172','181','182','187','188','189','190','191','192','193','194'}))
%     error('not an erik rat')
% end

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file


msFlushDuration         =1000;
rewardSizeULorMS        =50;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =1000;
msRewardSoundDuration   =rewardSizeULorMS;
sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});

freeDrinkLikelihood=0.003;
fd1 = freeDrinks(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,msRewardSoundDuration,freeDrinkLikelihood);
freeDrinkLikelihood=0;
fd2 = freeDrinks(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,msRewardSoundDuration,freeDrinkLikelihood);

requestRewardSizeULorMS=0;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;


rewardSizeULorMS        =200;
msRewardSoundDuration   =rewardSizeULorMS;

vh=nAFC(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,msRewardSoundDuration);

pixPerCycs              =[20];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =.04;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65;
maxWidth                =800;
maxHeight               =600;
scaleFactor             =[1 1];
interTrialLuminance     =.5;
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

pixPerCycs=[40];
distractorOrientations=[];
radius=.12;
discrimStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance)

ts1 = trainingStep(fd1, freeStim, repeatIndefinitely(), noTimeOff());
ts2 = trainingStep(fd2, freeStim, repeatIndefinitely(), noTimeOff());
ts3 = trainingStep(vh, discrimStim, repeatIndefinitely(), noTimeOff());

p=protocol('stochastic free drinks',{ts1});

switch ratID
    case 'all'
        ids={};
        [h,garbage]=getRatrixHeatInfo(2);
        for i=1:size(h,1)
            for j=1:length(h{i,2})
                ids{end+1}=h{i,2}{j}{1};
            end
        end
        for i=1:length(ids)
            ratID=ids{i};
            s = getSubjectFromID(r,ratID);
            [s r]=setProtocolAndStep(s,p,1,0,1,1,r,'first try','edf');
        end
    case '2c'
        ids={'165','173','167','181','189'};
        for i=1:length(ids)
            ratID=ids{i};
            s = getSubjectFromID(r,ratID);
            [s r]=setProtocolAndStep(s,p,1,0,1,1,r,'first try','edf');
        end
    otherwise
        error('bad id')
end