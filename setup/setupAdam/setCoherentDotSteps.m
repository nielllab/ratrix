function r = setCoherentDotSteps(r,subjects)

msFlushDuration         =1000;
rewardSizeULorMS        =50;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =1000;
msRewardSoundDuration   =rewardSizeULorMS;
sm=makeStandardSoundManager();

freeDrinkLikelihood=0.006;
fd1 = freeDrinks(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,msRewardSoundDuration,freeDrinkLikelihood);


freeDrinkLikelihood=0;
fd2 = freeDrinks(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,msRewardSoundDuration,freeDrinkLikelihood);

requestRewardSizeULorMS=10;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;


scalar=1;  %maybe loaded in calcstim?
increasingReward=rewardNcorrectInARow([20,80,150],msPenalty,1,1, scalar);
tm=nAFC(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,msRewardSoundDuration,increasingReward);




stimulus = coherentDots;

trialManagerClass='nAFC';
frameRate=100;
responsePorts=[1,3];
totalPorts=3;
width=1024;
height=768;
trialRecords=[];

maxWidth = 100;
maxHeight = 100;

pixPerCycs=64;
targetOrientations=pi/2;
distractorOrientations=[];
mean=0;
radius=1/16;
contrast=0;
thresh=0.00005;
yPosPct=0.5;
scaleFactor=0;
interTrialLuminance=0;

freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
ts1 = trainingStep(fd1, freeStim, rateCriterion(5,2),minutesPerSession(90,3));

ts2 = trainingStep(fd2, freeStim, rateCriterion(6,3), minutesPerSession(90,3));

discrimStim = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,trialRecords,...
    150, 100, 100, .85, 1, 3, 10, 85, [6 6]);

ts3 = trainingStep(tm, discrimStim, performanceCriterion([0.85, 0.8],int16([200, 500])), minutesPerSession(90,3));

discrimStim2 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,trialRecords,...
    150, 100, 100, [.65 .9], 1, 3, 2, 100, [6 6]);

ts4 = trainingStep(tm, discrimStim2,performanceCriterion([0.85, 0.8],int16([200, 500])), minutesPerSession(90,3));

discrimStim3 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,trialRecords,...
    150, 100, 100, [.45 .9], 1, 3, 2, 100, [6 6]);

ts5 = trainingStep(tm, discrimStim3,performanceCriterion([0.85, 0.8],int16([200, 500])), minutesPerSession(90,3));

discrimStim4 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,trialRecords,...
    150, 100, 100, [.25 .9], 1, 3, 2, 100, [6 6]);

ts6 = trainingStep(tm, discrimStim4,performanceCriterion([0.85, 0.8],int16([200, 500])), minutesPerSession(90,3));

discrimStim5 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,trialRecords,...
    150, 100, 100, [.15 .45], 1, 3, 2, 100, [6 6]);

ts7 = trainingStep(tm, discrimStim5,performanceCriterion([0.85, 0.8],int16([200, 500])), minutesPerSession(90,3));

% impressive if they get past this step using this criterion...

discrimStim6 = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,trialRecords,...
    150, 100, 100, [.0001 1], 1, 3, 2, 100, [6 6]);

ts8 = trainingStep(tm, discrimStim6,performanceCriterion([0.85, 0.8],int16([200, 500])), minutesPerSession(90,3));

p=protocol('dots',{ts1,ts2,ts3,ts4,ts5,ts6,ts7,ts8});
%p=protocol('dots',{ts2});
%p=protocol('dots',{ts3});
% r=ratrix(ratx); % load existing DB
% r=ratx;

% machines={{1,'001D7DA810C9',[1 1 1]}};
%
%
% for i=1:length(machines)
%     stationNum=machines{i}{1};
%
%     id=int8(stationNum);
%     width=1024;
%     height=768;
%     path=fullfile(dataPath, 'Stations',sprintf('station%d',stationNum));
%     screenNum=int8(0);
%     macAddr=machines{i}{2};
%     macLoc=int8(machines{i}{3});
%
%     if ismac
%         stations(i)=station(...
%             id,...          %id
%             width,...       %width
%             height,...      %height
%             path,...        %path
%             screenNum,...   %screenNum
%             true,...       %soundOn
%             'localTimed',...%rewardMethod
%             macAddr,...     %MACaddress
%             macLoc,...      %physicalLocation([rackID shelf position] -- upperleft is 1,1)
%             int8(3));             %numPorts
%     elseif ispc
%         if standalone
%             rewardMethod='localTimed';
%         else
%             rewardMethod='serverPump';
%         end
%
%         stations(i)=station(...
%             id,...          %id
%             width,...       %width
%             height,...      %height
%             path,...        %path
%             screenNum,...   %screenNum
%             true,...        %soundOn
%             rewardMethod,...%rewardMethod
%             macAddr,...     %MACaddress
%             macLoc,...      %physicalLocation([rackID shelf position] -- upperleft is 1,1)
%             '0378',...      %parallelPortAddress
%             'parallelPort',...%responseMethod
%             int8([6,7,8]),... %valveOpenCodes
%             int8([4,2,3]),... %portCodes
%             int8(1));       %framePulseCodes
%     else
%         error('unknown OS')
%     end
%
%     boxes(i)=box(int8(stationNum),fullfile(dataPath,'Boxes' , sprintf('box%d',stationNum)));
%     r=addBox(r,boxes(i));
%     r=addStationToBoxID(r,stations(i),getID(boxes(i)));

%miniDatabasePath = 'C:\pmeier\Ratrix\analysis\miniDatabase';  %testing
% miniDatabasePath = '\\192.168.0.1\c\acalhoun\miniDatabase'  % adam may want his own spot?
miniDatabasePath = fullfile(getRatrixPath, 'setup','setupAdam')  % adam may want his own spot?
boxIDs=getBoxIDs(r);

for i=1:length(subjects)

    if ~any(strcmp(subjects{i}, getSubjectIDs(r)))
        subjObj = subject(subjects{i}, 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'wild caught');
        r=addSubject(r,subjObj,'pmm');
    else
        s = getSubjectFromID(r, subjects{i});
    end

    step = getMiniDatabaseFact(getSubjectFromID(r,char(subjects(i))),'stepNumber',miniDatabasePath)
    [subjObj r]=setProtocolAndStep(subjObj,p,1,0,1,step,r,'adam rats','pmm');
    r=putSubjectInBox(r,getID(subjObj),boxIDs(1),'pmm');
end