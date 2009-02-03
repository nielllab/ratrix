function r=setHumanExpt(r,subjects, protocolType, protocolVersion, defaultSettingsDate, persistTrainingSteps)
%master shaping template for detection, goTo, or tilt discrimination tasks

%%
if ~exist('subjects', 'var')  || isempty(subjects)
    subjects={'test','test2'}
end

if ~exist('protocolType', 'var')  || isempty(protocolType)
    protocolType='goToRightDetection'
end

if ~exist('protocolVersion', 'var') || isempty(protocolVersion)
    protocolVersion='2_4'
end

if ~exist('defaultSettingsDate', 'var') || isempty(defaultSettingsDate)
    defaultSettingsDate='Oct.09,2007'  %datestr(now,22)
end

% if ~exist('persistTrainingSteps', 'var')
%     persistTrainingSteps=1; %this is if you have to reinit... we'll give you the trainingStep from previous ratrix
% end

%% default for all of pmeier stims
default=getDefaultParameters(ifFeatureGoRightWithTwoFlank,protocolType,protocolVersion,defaultSettingsDate);
parameters=default;
parameters.requestRewardSizeULorMS  =30;
parameters.msPenalty=1000;
parameters.scheduler=minutesPerSession(90,3);
%parameters.scheduler = nTrialsThenWait([1000],[1],[0.01],[1]);
%%noTimeOff()

parameters.mean = 0.5;
parameters.typeOfLUT= 'linearizedDefault';
parameters.rangeOfMonitorLinearized=[0.0 0.5];

%match stim of rats, 3.3=3 cpd at 215cm
parameters.pixPerCycs =32;  %could go to 12
parameters.stdGaussMask = 1/16; %could go to 3/128

%achieves 8.9=9cpd at 215cm, like sagi
parameters.pixPerCycs =12; 
parameters.stdGaussMask = 3/128; 

parameters.fractionNoFlanks=.05;
parameters.flankerContrast = [0.4]; % **!! miniDatabase overwrites this (for rats on this step)  if within-step shaping rebuilding ratrix
parameters.flankerOffset = 3;
parameters.toggleStim=false;

%targetContrast= 2.^[-6,-7]; %a guess for thresh!
%[0.015625 0.5 0.75 1 ] 1/log2 idea: 2.^[-8,-7,-6,-2,-1]
targetContrast=2.^[-8,-7,-6]%-8,-7,-6,-2,-1]; %[.25 0.5 0.75 1]; % starting sweep (rational: match acuity, but if at chance on .25 don't swamp more than you need, if above chance then add in something smaller, also easier ones will keep up moral )
parameters=setLeftAndRightContrastInParameterStruct(parameters, protocolType, targetContrast);
  
parameters=setLeftAndRightContrastInParameterStruct(parameters, protocolType, targetContrast);  % **skip .9 ; miniDatabase overwrites this (for rats on this step)  if rebuilding ratrix 
 parameters.persistFlankersDuringToggle = 0; %
 
 
% parameters.shapedParameter='targetContrast';
% parameters.shapingMethod='linearChangeAtCriteria';
% parameters.shapingValues.numSteps=int8(6);
% parameters.shapingValues.startValue=.8;
% parameters.shapingValues.currentValue=.8;
% parameters.shapingValues.goalValue=0.2;
% parameters.graduation = parameterThresholdCriterion('.stimDetails.currentShapedValue','<',0.29);


%for all stimuli with displayTargetAndDistractor = 0, these will not matter
parameters.distractorYokedToTarget=1;
parameters.distractorFlankerYokedToTargetFlanker = 1;
parameters.distractorContrast = 0;


%Remove correlation for experiments
parameters.maxCorrectOnSameSide=int8(-1); %%%
parameters.percentCorrectionTrials=0;  %beware this is overpowered by the minidatabase setting!
        

nameOfShapingStep=repmat({'junkStep'},1,11);  % skip the first 11 of training...


        nameOfShapingStep{end+1} = sprintf('Expt 1: contrast sweep', protocolType);
        [sweepContrast previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});
        
        nameOfShapingStep{end+1} = sprintf('Expt 2: position sweep', protocolType);
        targetContrast=[.25]; %reasonably easy , garaunteed contrast sensitive
        parameters=setLeftAndRightContrastInParameterStruct(parameters, protocolType, targetContrast);
        parameters.flankerOffset = [2.5 3 3.5 5];
        [sweepFlankerPosition]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});
        
        nameOfShapingStep{end+1} = sprintf('Expt 3: flanker orientation sweep', protocolType);
        parameters.flankerOffset=3;
        parameters.fpaRelativeTargetOrientation=0;  % always align to fpa
        %rfo=[-pi/2 -pi/4 -pi/8 -pi/16 0 0 pi/16 pi/8 pi/4 pi/2];  % 9 best with more samples at 0
        rfo=[-pi/2 -pi/6 -pi/12 -pi/24 0 0 pi/24 pi/12 pi/6 pi/2];  % 9 best with more samples at 0
        parameters.fpaRelativeFlankerOrientation=rfo;
        required=repmat(rfo,size(parameters.flankerPosAngle,2),1)-repmat(parameters.flankerPosAngle',1,size(rfo,2));
        parameters.flankerOrientations=unique(required(:)); % find what you need
        parameters.phase=0;
        [sweepFlankerOrientation ]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});
   


%%  make new ratrix station and box, if you don't have one

if isempty(r)
    error('old code')
    if ispc
        rootPath='C:\pmeier\Ratrix\'; %**!!hard coded path
        pathSep='\';
        screenNum = 0;
        soundOn = 1;
    elseif isosx
        rootPath='/Users/pmmeier/Desktop/Ratrix/';
        pathSep='\';
        screenNum = 0;
        %rect=Screen('Rect', screenNum); screenWidth=rect(3); screenHeight=rect(4); %set in default now
        soundOn = 0;
    else  %use default
        %rootPath='C:\Ratrix\';
        'must enter rootPath'
        pathSep='\';
        screenNum =2;
        screenWidth= 800;  screenHeight=600;
        soundOn = 1;
    end

    screenWidth= 1024;  screenHeight=768;
    r=ratrix([rootPath 'ServerData' pathSep],1);
    %st=station(int8(1),int8([6,7,8]),int8([4,2,3]),1280,1024,'ptb','keyboard'    ,[rootPath 'Stations' pathSep 'station1' pathSep],[]    ,int8(screenNum),int8(1),logical(soundOn));
    %st =station(int8(1),int8([6,7,8]),int8([4,2,3]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep] ,'037F',int8(screenNum),int8(1),logical(soundOn)); %PMM COMPUTER
    st =station(int8(1),int8([6,7,8]),int8([4,2,3]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep] ,'0378',int8(screenNum),int8(1),logical(soundOn)); %STATIONS DOWNSTAIRS
    %st =station(int8(1),int8([6,7,8]),int8([4,2,3]),screenWidth,screenHeight,'ptb','keyboard',[rootPath 'Stations' pathSep 'station1' pathSep] ,[]K23,int8(screenNum),int8(1),logical(soundOn)); %STATIONS DOWNSTAIRS
    %old bomb? %st =station(int8(1),int8([7,6,8]),int8([3,4,2]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep] ,'0378',int8(screenNum),int8(1),logical(soundOn));
    b=box(int8(1),[rootPath 'Boxes' pathSep 'box1' pathSep]);
    r=addBox(r,b);
    r=addStationToBoxID(r,st,getID(b));
end



[fdTM,SM] = makeFreeDrinksTM(parameters,0,0); % none
fd = trainingStep(fdTM, SM, rateCriterion(4,1), minutesPerSession(90,3),parameters.svnRev);

%% assemble the protocol
%nameOfProtocol=[protocolType '_v' protocolVersion];
nameOfProtocol=generateProtocolName(nameOfShapingStep,protocolVersion,defaultSettingsDate)

switch protocolVersion
    case {'2_4'}
            p=protocol(nameOfProtocol,{fd,fd,fd,fd,fd,fd,fd,fd,fd,fd,fd,sweepContrast,sweepFlankerPosition,sweepFlankerOrientation})
    otherwise
        error('bad protocol type')
end

% don't add, just check that they are there
% r=addTheseRats(r,subjects,p,persistTrainingSteps);

for i=1:size(subjects,2)
    if ~any(strcmp(subjects{i}, getSubjectIDs(r)))
        allIDs = getSubjectIDs(r)
        thisID = subjects{i}
        %error('rats should already be there')
        warndlg(sprintf('adding rat %s',subjects{i}),'rats should already be there')
        s = subject(char(subjects(i)), 'human', 'none', 'male', '01/01/2005', '01/02/2005', 'unknown', 'Jackson Laboratories');
        r=addSubject(r,s,'pmm');
    else
        s = getSubjectFromID(r, subjects{i});
    end

    miniDatabasePath = fullfile(getRatrixPath, 'setup','setupPMM');
    %miniDatabaseFile = fullfile(getRatrixPath, 'setup','setupPMM','miniDatabase.mat')
    if persistTrainingSteps;
        stepNum=getMiniDatabaseFact(getSubjectFromID(r,subjects{i}),'stepNumber',miniDatabasePath); %this is if you have to reinit...
        %    stepNum = getLastTrainingStep(ratID,getPermanentStorePath(r)); %persist previous step but can't flunk or advance 
    else
        stepNum=12;
    end

     stepNum
     subjects(i)
    [s  r]=setProtocolAndStep(s ,p,1,0,1,stepNum,r,'from pmm master Shaping','pmm');
    if persistTrainingSteps
        r=setValuesFromMiniDatabase(s,r,miniDatabasePath);
    end
end


%% stim test

stimTest=1;
if stimTest
    trialManagerClass = class(getTrialManager(sweepContrast));
    frameRate = 60;
    responsePorts = [1 3];
    totalPorts = [3];
    width=1024;
    height=768;
    trialRecords = [];

    stimManager=getStimManager(sweepContrast)
    resolutions=[];
    displaySize=[];
    LUTbits=[];
    [stimManager junk2 resInd im a b c d e details interTrialLuminance text] = ...
        calcStim(stimManager,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords);
    details
    subplot(1, 2, 1); imagesc(im(:,:,1))
    subplot(1, 2, 2); imagesc(im(:,:,2))
    colormap(gray)
end
