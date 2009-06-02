function setProtocolPR(ratIDs)

dataPath=fullfile(fileparts(fileparts(getRatrixPath)),'ratrixData',filesep);
r=ratrix(fullfile(dataPath, 'ServerData'),0); %load from file


sm=makeStandardSoundManager();


msPenalty               =0; %this is kinda short, but it worked for Adam
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;

% freeDrinkLikelihood=0.006;
% fd1 = freeDrinks(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,msRewardSoundDuration,freeDrinkLikelihood);
%
% freeDrinkLikelihood=0;
% fd2 = freeDrinks(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,msRewardSoundDuration,freeDrinkLikelihood);

requestRewardSizeULorMS=10;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;
msFlushDuration=10;

scalar=1;
increasingReward=rewardNcorrectInARow([20,80,150],msPenalty,1,1, scalar); %[20 80 100 150 250] is what philip uses ..

tm=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,increasingReward);




stimulus = coherentDots;

trialManagerClass='nAFC';
frameRate=100;
responsePorts=[1,3];
totalPorts=3;
width=1024;
height=768;

maxWidth = 100;
maxHeight = 100;


%freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
%ts1 = trainingStep(fd1, freeStim, rateCriterion(5,2),minutesPerSession(90,3));

%ts2 = trainingStep(fd2, freeStim, rateCriterion(6,3), minutesPerSession(90,3));

pc=performanceCriterion([0.85, 0.8],int16([200, 500]));
sch=minutesPerSession(90,3);

discrimStim = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, .85, 1, 3, 10, 85, [6 6]);

ts3 = trainingStep(tm, discrimStim, pc,sch);

discrimStim2 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [.65 .9], 1, 3, 2, 100, [6 6]);

ts4 = trainingStep(tm, discrimStim2,pc,sch);

discrimStim3 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [.45 .9], 1, 3, 2, 100, [6 6]);

ts5 = trainingStep(tm, discrimStim3,pc,sch);

discrimStim4 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [.25 .9], 1, 3, 2, 100, [6 6]);

ts6 = trainingStep(tm, discrimStim4,pc,sch);

discrimStim5 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [.15 .45], 1, 3, 2, 100, [6 6]);

ts7 = trainingStep(tm, discrimStim5,pc,sch);

% impressive if they get past this step using this criterion...

discrimStim6 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,[],...
    150, 100, 100, [.0001 1], 1, 3, 2, 100, [6 6]);

ts8 = trainingStep(tm, discrimStim6,pc,sch);

pDots=protocol('dots',{ts3,ts4,ts5,ts6,ts7,ts8});

pixPerCycs              =[64];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =1/8;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65;
scaleFactor             =[1 1];
interTrialLuminance     =.5;
waveform='square';
normalizedSizeMethod='normalizeVertical';

goToSide = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,interTrialLuminance,waveform,normalizedSizeMethod);

distractorOrientations=[0];
goToHor = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,width,height,scaleFactor,interTrialLuminance,waveform,normalizedSizeMethod)

gt1 = trainingStep(tm, goToSide, pc, sch);
gt2 = trainingStep(tm, goToHor, pc, sch);

pGoToStim=protocol('shape goToHor',{gt1, gt2});

for i=1:length(ratIDs) %243-245 are dots, 246-248 are goToSide/goToHoriz (244, 247 cockpits) A243, B245, C244, D247, E246, F248
    subjObj = getSubjectFromID(r,ratIDs{i});

    %stepNum=1;
    stepNum = getLastTrainingStep(ratIDs{i},getPermanentStorePath(r)); %persist previous step
    
    if ismember(ratIDs{i},{'243','244','245','l'})
        p=pDots;
    elseif ismember(ratIDs{i},{'246','247','248','r'})
        p=pGoToStim;
    else
        error('unexpected ID')
    end
    
    [subjObj r]=setProtocolAndStep(subjObj,p,1,0,1,stepNum,r,'initial protocol setup for blind sight rats','pr');

end