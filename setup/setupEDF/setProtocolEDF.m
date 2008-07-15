function r= setProtocolEDF(r,subIDs)

rewardSizeULorMS        =50;
msPenalty               =500;
fractionOpenTimeSoundIsOn = 1.0;
fractionPenaltySoundIsOn = 1.0;
scalar = 1.0;
rm=constantReinforcement(rewardSizeULorMS,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar);

msFlushDuration         =1000;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;

sm=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});

freeDrinkLikelihood=0.1;
fd1 = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood, rm);
freeDrinkLikelihood=0;
fd2 = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood, rm);

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

vh=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,rm);

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

imageDir='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\other stimuli sets\paintbrushMORPHflashlightEDF';
background=0;
ypos=0;
ims=dir(fullfile(imageDir,'*.png'));
trialDistribution={};
for i=1:floor(length(ims)/2)
    [junk n1 junk junk]=fileparts(ims(i).name);
    [junk n2 junk junk]=fileparts(ims(length(ims)-(i+1)).name);
    trialDistribution{end+1}={{n1 n2} 1};
end
imageStim = images(imageDir,ypos,background,maxWidth,maxHeight,scaleFactor,interTrialLuminance,trialDistribution);

ts1 = trainingStep(fd1, freeStim, repeatIndefinitely(), noTimeOff());
ts2 = trainingStep(fd2, freeStim, repeatIndefinitely(), noTimeOff());
ts3 = trainingStep(vh, discrimStim, repeatIndefinitely(), noTimeOff());
ts4 = trainingStep(vh, imageStim, repeatIndefinitely(), noTimeOff());
ts5 = trainingStep(fd1, imageStim, repeatIndefinitely(), noTimeOff());

p=protocol('free drinks',{ts5});

if isvector(subIDs) && ischar(subIDs) && strcmp(subIDs, 'all')
    rackID=getRackIDFromIP;

    ids={};
    conn=dbConn;
    heats=getHeats(conn);
    for i=1:length(heats)
        if strcmp(heats{i}.name,'Test')
            assignments=getAssignments(conn,rackID,heats{i}.name);
            for j=1:length(assignments)
                ids{end+1}=assignments{j}.subject_id;
                ids{end}
            end
        end
    end
    closeConn(conn);
    subIDs=ids;
end

if isvector(subIDs) && iscell(subIDs)
    for i=1:length(subIDs)
        ratID=subIDs{i};
        s = getSubjectFromID(r,ratID);
        [s r]=setProtocolAndStep(s,p,1,0,1,1,r,'first try','edf');
    end
else
    error('bad id format')
end