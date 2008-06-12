function r = crossModalMakeRatrix(dataPath,standalone,rewardMethod)

machines={...
    {7,'0018F35DFADB',[1 1 1]},... %'0018F35E0281' philip took
    {8,'0018F35DEE62',[1 1 2]},...
    {9,'0018F34EAE45',[1 1 3]},...
    {10,'001A4D9326C2',[1 2 1]},... 
    {11,'001A4D523D5C',[1 2 2]},...
    {12,'001D7D9ACF80',[1 2 3]}}; %'001A4D528033' broke
    % '001A4D4F8C2F' new server

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
if standalone
    freeDrinkLikelihood=0;%0.003;
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
targetContrasts         =[0.8];
distractorContrasts     =[];
fieldWidthPct           = 0.2;
fieldHeightPct          = 0.2;
mean                    =.5;
stddev                  =.04; % Only used for Gaussian Flicker
thresh                  =.00005;
flickerType             =0; % 0 - Binary Flicker; 1 - Gaussian Flicker
yPosPct                 =.65;
maxWidth                =800;
maxHeight               =600;
scaleFactor             =[1 1];
interTrialLuminance     =.5;
%freeStim = hemifieldFlicker(pixPerCycs,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
freq = 200; % Sound frequency to use in hz
amplitudes = [0 1]; % For now bias completely in one direction
freeStim = stereoDiscrim(mean,freq,amplitudes,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
distractorContrasts  =[0.4];
discrimStim = hemifieldFlicker(pixPerCycs,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

ts1 = trainingStep(fd, freeStim, repeatIndefinitely(), noTimeOff());
ts2 = trainingStep(vh, discrimStim, repeatIndefinitely(), noTimeOff());

p=protocol('hemifieldflicker free drinks',{ts1, ts2});

r=ratrix(fullfile(dataPath, 'ServerData'),1);

for i=1:length(machines)
    stationNum=machines{i}{1};

    id=int8(stationNum);
    width=1280;
    height=1024;
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
%         if standalone
%             rewardMethod='localTimed';
%         else
%             rewardMethod='serverPump';
%         end

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