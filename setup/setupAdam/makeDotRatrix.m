function r = makeDotRatrix(dataPath,standalone)


msFlushDuration         =1000;
rewardSizeULorMS        =50;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =1000;
msRewardSoundDuration   =rewardSizeULorMS;
sm=makeStandardSoundManager();

    freeDrinkLikelihood=0;


requestRewardSizeULorMS=0;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;

tm=nAFC(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,msRewardSoundDuration);




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

discrimStim = coherentDots(stimulus,trialManagerClass,frameRate,responsePorts,totalPorts,maxWidth,maxHeight,trialRecords,...
    150, 100, 100, .85, 1, 1, 10, 85, [6 6]);

ts1 = trainingStep(tm, discrimStim, repeatIndefinitely(), noTimeOff());

p=protocol('dots',{ts1});

r=ratrix(fullfile(dataPath, 'ServerData'),1);

machines={{1,'001D7DA810C9',[1 1 1]}};


for i=1:length(machines)
    stationNum=machines{i}{1};

    id=int8(stationNum);
    width=1024;
    height=768;
    path=fullfile(dataPath, 'Stations',sprintf('station%d',stationNum));
    screenNum=int8(0);
    macAddr=machines{i}{2};
    macLoc=int8(machines{i}{3});

    if ismac
        stations(i)=station(...
            id,...          %id
            width,...       %width
            height,...      %height
            path,...        %path
            screenNum,...   %screenNum
            true,...       %soundOn
            'localTimed',...%rewardMethod
            macAddr,...     %MACaddress
            macLoc,...      %physicalLocation([rackID shelf position] -- upperleft is 1,1)
            int8(3));             %numPorts
    elseif ispc
        if standalone
            rewardMethod='localTimed';
        else
            rewardMethod='serverPump';
        end

        stations(i)=station(...
            id,...          %id
            width,...       %width
            height,...      %height
            path,...        %path
            screenNum,...   %screenNum
            true,...        %soundOn
            rewardMethod,...%rewardMethod
            macAddr,...     %MACaddress
            macLoc,...      %physicalLocation([rackID shelf position] -- upperleft is 1,1)
            '0378',...      %parallelPortAddress
            'parallelPort',...%responseMethod
            int8([6,7,8]),... %valveOpenCodes
            int8([4,2,3]),... %portCodes
            int8(1));       %framePulseCodes
    else
        error('unknown OS')
    end

    boxes(i)=box(int8(stationNum),fullfile(dataPath,'Boxes' , sprintf('box%d',stationNum)));
    r=addBox(r,boxes(i));
    r=addStationToBoxID(r,stations(i),getID(boxes(i)));
    subjects(i) = subject(sprintf('retest%d',i), 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'wild caught');
    r=addSubject(r,subjects(i),'edf');
    [subjects(i) r]=setProtocolAndStep(subjects(i),p,1,0,1,1,r,'first try','edf');
    r=putSubjectInBox(r,getID(subjects(i)),getID(boxes(i)),'edf');
end