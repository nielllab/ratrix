function r = makeRatrix(dataPath,standalone,rewardMethod)

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
eyepuffMS=250;

fd = freeDrinks(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,msRewardSoundDuration,freeDrinkLikelihood,eyepuffMS);

requestRewardSizeULorMS=10;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;

vh=nAFC(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sm,msPenalty,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,msRewardSoundDuration,eyepuffMS);

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

pixPerCycs=[20 10];
distractorOrientations=[0];
discrimStim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance) 

% bandaid='\\132.239.158.169\resources\morestimulifwd full\';
% paintbrush='\\132.239.158.169\resources\morph';
paintbrush='\\132.239.158.169\resources\paintbrush_flashlight\paintbrush_flashlight';
discrimStim = images(paintbrush,0,0,maxWidth,maxHeight,scaleFactor,0);



ts1 = trainingStep(fd, freeStim, repeatIndefinitely(), noTimeOff());
ts2 = trainingStep(vh, discrimStim, repeatIndefinitely(), noTimeOff());

p=protocol('gabor test',{ts2, ts1});

r=ratrix(fullfile(dataPath, 'ServerData'),1);

for i=1:length(machines)
    stationNum=machines{i}{1};

    id=int8(stationNum);
    width=1280;
    height=1024;
    path=fullfile(dataPath, 'Stations',sprintf('station%d',stationNum));
    screenNum=int8(max(Screen('Screens')));
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

        valveOpenCodes=int8([6,7,8]);
        pportAddr='0378';
        if strcmp(rewardMethod,'localPump')
            infTooFarPin=int8(1);
            wdrTooFarPin=int8(14);
            motorRunningPin= int8(11);
            %dirPin = int8(7); %not used
            rezValvePin = int8(5);  %valve 4
            eqDelay=0.3; %seems to be lowest that will work
            valveDelay=0.02;

            pmp = pump('COM1',...             %serPortAddr
                9.65,...                    %mmDiam
                500,...                     %mlPerHr
                false,...                   %doVolChks
                {pportAddr,motorRunningPin},... %motorRunningBit
                {pportAddr,infTooFarPin},... %infTooFarBit
                {pportAddr,wdrTooFarPin},... %wdrTooFarBit
                1.0,...                     %mlMaxSinglePump
                1.0,...                     %mlMaxPos
                0.1,...                     %mlOpportunisticRefill
                0.05);                      %mlAntiRock
            lp=localPump(pmp,rezValvePin,eqDelay,valveDelay);
            arg={valveOpenCodes,lp};
        else
            arg=valveOpenCodes;
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
            pportAddr,...      %parallelPortAddress
            'parallelPort',...%responseMethod
            arg,... %valveOpenCodes
            int8([4,2,3]),... %portCodes
            int8(1),...       %framePulseCodes
            int8(6));        %eyepuffPin
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