function r = crossModalMakeRatrix(dataPath,permanentStorePath,standalone,rewardMethod,resetRatrix)


machines={ {'99A','0018F35DFADB',[1 1 1],7}  };

    
msFlushDuration         =1000;
rewardSizeULorMS        =50;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =1000;
msRewardSoundDuration   =rewardSizeULorMS;
sm=makeStandardSoundManager();

fractionOpenTimeSoundIsOn=1;
fractionPenaltySoundIsOn=1;
scalar=1;
% thisSessionIsCached=0; %pmm removed

constantRewards=constantReinforcement(rewardSizeULorMS,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar)

if standalone
    freeDrinkLikelihood=0;%0.003;
else
    freeDrinkLikelihood=1;
end
fd = freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,freeDrinkLikelihood,constantRewards);

requestRewardSizeULorMS=0;
percentCorrectionTrials=.5;
msResponseTimeLimit=0;
pokeToRequestStim=true;
maintainPokeToMaintainStim=true;
msMaximumStimPresentationDuration=0;
maximumNumberStimPresentations=0;
doMask=false;

vh=nAFC(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,sm,requestRewardSizeULorMS,...
    percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,maintainPokeToMaintainStim,msMaximumStimPresentationDuration,...
    maximumNumberStimPresentations,doMask,constantRewards);

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
numCalcIndices          = 10000; % Number of indices for frames to calculate
freeVisualStim = hemifieldFlicker(numCalcIndices,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
freq = 200; % Sound frequency to use in hz
amplitudes = [0 1]; % For now bias completely in one direction
freeAudioStim = stereoDiscrim(mean,freq,amplitudes,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
discrimAudioStim = stereoDiscrim(mean,freq,amplitudes,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
discrimVisualStim = hemifieldFlicker(numCalcIndices,targetContrasts,distractorContrasts,fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);

ts1 = trainingStep(fd, freeAudioStim, repeatIndefinitely(), noTimeOff());
ts2 = trainingStep(vh, discrimAudioStim, repeatIndefinitely(), noTimeOff());
ts3 = trainingStep(fd, freeVisualStim, repeatIndefinitely(), noTimeOff());
ts4 = trainingStep(vh, discrimVisualStim, repeatIndefinitely(), noTimeOff());

% Test Phil's code
% defaultSettingsDate='Oct.09,2007';
% protocolType='goToSide';
% protocolVersion='1_0';
% default=getDefaultParameters(ifFeatureGoRightWithTwoFlank,protocolType,protocolVersion,defaultSettingsDate);
% 
% % parameters for each shaping step
% 
% nameOfShapingStep{1} = sprintf('Step 2a: Easy %s, friendly', protocolType);
% parameters=default;
% parameters.requestRewardSizeULorMS             =30;
% parameters.msPenalty=1000;
% parameters.scheduler=minutesPerSession(90,3);
% %parameters.scheduler = nTrialsThenWait([1000],[1],[0.01],[1]);
% %%noTimeOff()
% parameters.graduation = rateCriterion(5,5);
% [easy previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});


if length(machines) ~= 1
    error('This should be a standalone test!')
end

p=protocol('hemifieldflicker free drinks',{ts1, ts2, ts3, ts4});

r=ratrix(fullfile(dataPath, 'ServerData'),resetRatrix,permanentStorePath);

for i=1:length(machines)
    stationNum=machines{i}{1};
    boxNum=machines{i}{4};
    id=stationNum;
    subjectID = sprintf('retest');
    trainingStepNum = 1; % 1-Audio Free,2-Audio Discrim,3-Vis Free,4-Vis Discrim
    
    if resetRatrix
        width=1280;
        height=1024;
        path=fullfile(dataPath, 'Stations',sprintf('station%s',stationNum));
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

        boxes(i)=box(int8(boxNum),fullfile(dataPath,'Boxes' , sprintf('box%d',boxNum)));
        r=addBox(r,boxes(i));
        r=addStationToBoxID(r,stations(i),getID(boxes(i)));
        subjects(i) = subject(subjectID, 'rat', 'long-evans', 'male', '05/10/2005', '01/01/2006', 'unknown', 'wild caught');
        r=addSubject(r,subjects(i),'dfp');
    else
        subjects(i) = getSubjectFromId(r,subjectID);
        boxes(i) = getBoxFromID(r,int8(boxNum));
    end
    
    % Set the protocol and step regardless of what else is going on
    [subjects(i) r]=setProtocolAndStep(subjects(i),p,1,0,1,trainingStepNum,r,'first try','dfp');
    
    % Need to put the subject in a box if we're setting up a ratrix
    if resetRatrix
        r=putSubjectInBox(r,getID(subjects(i)),getID(boxes(i)),'dfp');
    end
end