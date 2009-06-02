function r = makeRatrix(dataPath,standalone,rewardMethod)

machines={...
    {88,'001111467B80',[1 1 1]}}; %'0018F35E0281' philip took
    % '001A4D4F8C2F' new server

msFlushDuration         =1000;
rewardSizeULorMS        =50;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =0;
msRewardSoundDuration   =rewardSizeULorMS;
sm=makeStandardSoundManager();

if standalone
    freeDrinkLikelihood=0.006;%0.003;
else
    freeDrinkLikelihood=1;
end
fd = freeDrinks(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,msRewardSoundDuration,freeDrinkLikelihood);

requestRewardSizeULorMS=0;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;

vh=nAFC(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,msRewardSoundDuration);

pixPerCycs              =[20];
targetOrientations      =[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =.10;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65;
maxWidth                =1280;
maxHeight               =1024;
scaleFactor             =[1 1];
interTrialLuminance     =.5;
freeStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

%pixPerCycs=[20 10];
%distractorOrientations=[0];
%discrimStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance) 

% bandaid='\\132.239.158.169\resources\morestimulifwd full\';
% paintbrush='\\132.239.158.169\resources\morph';
paintbrush='\\Reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\PriyaV\paintbrush_flashlight\';
discrimStim = images(paintbrush,0,0,maxWidth,maxHeight,scaleFactor,0);


ts1 = trainingStep(fd, freeStim, repeatIndefinitely(), noTimeOff());
ts2 = trainingStep(vh, discrimStim, repeatIndefinitely(), noTimeOff());

p=protocol('gabor test',{ts2});

r=ratrix(fullfile(dataPath, 'ServerData'),1);

for i=1:length(machines)
    stationNum=machines{i}{1};

    id=int8(stationNum);
    width=1280;
    height=1024;
    path=fullfile(dataPath, 'Stations',sprintf('station%d',stationNum));
    screenNum=int8(2);
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
    subjects(i) = subject(sprintf('ppriya_197%d',i), 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'wild caught');
    r=addSubject(r,subjects(i),'edf');
    [subjects(i) r]=setProtocolAndStep(subjects(i),p,1,0,1,1,r,'first try','edf');
    r=putSubjectInBox(r,getID(subjects(i)),getID(boxes(i)),'edf');
end