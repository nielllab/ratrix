function RatSubjectInit()

%%
clc
clear classes;

%% addPaths
rootPath='C:\pmeier\Ratrix';
%warning('off','MATLAB:dispatcher:nameConflict')
%addpath(genpath([fullfile(rootPath,'Server')]))  %old
addpath(genpath(fullfile(rootPath,'classes')));
%warning('on','MATLAB:dispatcher:nameConflict')

%% set each rat on a protocol
r=setShaping([],{'test'}, 'goToLeftDetection', '1_1');
% r=setShaping(r,{'rat_213','rat_215'}, 'goToLeftDetection', '1_1'); r=setShaping(r,{'rat_216'}, 'goToRightDetection', '1_1');  r=setCoherentDotSteps(r,{'rat_195'}); r=setShaping(r,{'rat_144'}, 'tiltDiscrim', '1_1');
% r=setShaping(r,{'rat_214','rat_219','rat_217'}, 'goToLeftDetection', '1_1'); r=setShaping(r,{'rat_218','rat_220'}, 'goToRightDetection', '1_1');  %r=setShaping(r,{'rat_145','rat_146','rat_147','rat_148','rat_129'}, 'tiltDiscrim', '1_2')
% r=setShaping(r,{'rat_221'}, 'goToLeftDetection', '1_1'); r=setShaping(r,{'rat_222'}, 'goToRightDetection', '1_1'); r=setShaping(r,{'rat_106','rat_102'}, 'goToRightDetection', '1_3'); r=setCoherentDotSteps(r,{'rat_196'}); %r=setShaping(r,{'rat_112','rat_126','rat_102','rat_106'}, 'goToRightDetection', '1_3');
%r=setShaping(r,{'127'}, 'goToRightDetection', '1_3');  r=setShaping(r,{'rat_116','rat_130','rat_115'}, 'tiltDiscrim', '1_0'); r=setAcuity(r,{'rat_117','test2'},'tiltDiscrim','1_0');   %removed: 114
%r=setAcuity(r,{'rat_138','rat_139'}, 'goToRightDetection', '1_1'); r=setShaping(r,{'rat_132','rat_133','rat_128'}, 'goToRightDetection', '1_3');
%r=setShaping(r,{'rat_134','rat_135'}, 'goToSide', '1_3');%r=setShaping(r,{'rat_136','rat_137','rat_131'}, 'goToSide', '1_4');

% r=setHeadFixShaping();

%% start test session

startTestSession=1;
if startTestSession
    ratSubjectSession('test'); % test for downstairs, test2 for upstairs
end

%%
function r=setHeadFixShaping()


%  make new ratrix station and box
% Note: we use a different screen and parallelport upstairs
rootPath='C:\pmeier\Ratrix\'; %**!!hard coded path
pathSep = filesep;
soundOn = 1;
screenNum = 2;
parportaddress='FFF8';
screenWidth= 1024;  screenHeight=768;
r=ratrix([rootPath 'ServerData' pathSep],1); %r=ratrix([rootPath 'ServerData' pathSep],1);
%st=station(int8(1),int8([6,7,8]),int8([4,2,3]),1280,1024,'ptb','keyboard'    ,[rootPath 'Stations' pathSep 'station1' pathSep],[]    ,int8(screenNum),int8(1),logical(soundOn));
rigStation  =station(int8(1),int8([6,7,8]),int8([4,2,3]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep],parportaddress,int8(screenNum),int8(1),logical(soundOn));
%workStation =station(int8(1),int8([6,7,8]),int8([4,2,3]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep],'0378',int8(0),int8(1),logical(soundOn));
%oldBombStation =station(int8(1),int8([7,6,8]),int8([3,4,2]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep] ,'0378',int8(2),int8(1),logical(soundOn));
%macOsStation =
st=rigStation;
b=box(int8(1),[rootPath 'Boxes' pathSep 'box1' pathSep]);
r=addBox(r,b);
r=addStationToBoxID(r,st,getID(b));

% fd1TM = makeFreeDrinksTM(0.01); % juicy
% fd2TM = makeFreeDrinksTM(0.001); % some
% fd3TM = makeFreeDrinksTM(0); % none
miniDatabasePath = 'C:\pmeier\Ratrix\analysis\miniDatabase\rig1';  % upstairs
[TM, SM] = makeFreeDrinksTM(0, 1);
grad = rateCriterion(999,1);

pctStochasticReward = 0.001;
fd = trainingStep(makeFreeDrinksTM(pctStochasticReward, 1), SM, grad, nTrialsThenWait([1000],[1],[0.001],[1]));
fdSteps = protocol('no stim free drinks ', {fd});
s = subject('test2', 'rat', 'long-evans', 'male', '01/01/2005', '01/02/2005', 'unknown', 'Jackson Laboratories', miniDatabasePath, ''); r=addSubject(r,s,'pmm');
[s r]=setProtocolAndStep(s,fdSteps,1,0,1,1,r,'first try','pmm');

pctStochasticReward = 0.001;
fd = trainingStep(makeFreeDrinksTM(pctStochasticReward, 1), SM, grad, nTrialsThenWait([1000],[1],[0.001],[1]));
fdSteps = protocol('no stim free drinks ', {fd});
s = subject('rat_124', 'rat', 'long-evans', 'male', '01/01/2005', '01/02/2005', 'unknown', 'Jackson Laboratories', miniDatabasePath, ''); r=addSubject(r,s,'pmm');
[s r]=setProtocolAndStep(s,fdSteps,1,0,1,1,r,'first try','pmm');

pctStochasticReward = 0.001;
fd = trainingStep(makeFreeDrinksTM(pctStochasticReward, 1), SM, grad, nTrialsThenWait([1000],[1],[0.001],[1]));
fdSteps = protocol('no stim free drinks ', {fd});
s = subject('rat_127', 'rat', 'long-evans', 'male', '01/01/2005', '01/02/2005', 'unknown', 'Jackson Laboratories', miniDatabasePath, ''); r=addSubject(r,s,'pmm');
[s r]=setProtocolAndStep(s,fdSteps,1,0,1,1,r,'first try','pmm');


%% set shaping
function r=setShapingPMM(r,subjects, protocolType, protocolVersion, defaultSettingsDate, persistTrainingSteps)
%master shaping template for detection, goTo, or tilt discrimination tasks

if ~exist('subjects', 'var')
    subjects={'test','test2'}
end

if ~exist('protocolType', 'var')
    protocolType='goToSide'
end

if ~exist('protocolVersion', 'var')
    protocolVersion='1_0'
end

if ~exist('defaultSettingsDate', 'var')
    defaultSettingsDate='Oct.09,2007'  %datestr(now,22)
end

if ~exist('persistTrainingSteps', 'var')
    persistTrainingSteps=1; %this is if you have to reinit... we'll give you the trainingStep from previous ratrix
end





%% define shared and constant parameters for all rats

%% default for all of pmeier stims
default=getDefaultParameters(ifFeatureGoRightWithTwoFlank,protocolType,protocolVersion,defaultSettingsDate);

%% parameters for each shaping step

nameOfShapingStep{1} = sprintf('Step 2a: Easy %s, friendly', protocolType);
parameters=default;
parameters.msRequestRewardDuration             =30;
parameters.msPenalty=1000;
parameters.scheduler=minutesPerSession(90,3);
%parameters.scheduler = nTrialsThenWait([1000],[1],[0.01],[1]);
%%noTimeOff()
parameters.graduation = rateCriterion(5,5);
[easy previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

if strcmp (protocolVersion,'1_2');
    %optional step overrides easy but lacks weening off of ms request reward duration
    nameOfShapingStep{1} = sprintf('Step 2x: Easy %s, with Hint', protocolType);
    parameters=default;
    parameters.msRequestRewardDuration=30; % make this go down?
    parameters.msPenalty=4000;
    parameters.positionalHint=0.2;
    parameters.scheduler=minutesPerSession(90,3);
    parameters.graduation = performanceCriterion([0.85, 0.8],int16([200, 500])); %this could become a criteria that weens rats off of hint
    %parameters.graduation = performanceCriterion([0.95,0.9,0.85, 0.8],int16([50,100,200, 500]));
    [easyHint previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});
    parameters=previousParameters;
    parameters.positionalHint=0;
else
    parameters=previousParameters;
end

nameOfShapingStep{end+1} = sprintf('Step 2b: Easy %s, stringent', protocolType);

parameters.msRequestRewardDuration=0;
switch protocolType
    case 'goToRightDetection'
        parameters.msPenalty=4000; % keep at 4 secs
    case 'goToLeftDetection'
        parameters.msPenalty=4000; % keep at 4 secs
    otherwise
        parameters.msPenalty=10000;
end
parameters.graduation = performanceCriterion([0.85, 0.8],int16([200, 500]));
%parameters.graduation = performanceCriterion([0.85, 0.8],int16([10, 500])); % just for testing
[stringent previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Step 2c: Linearized %s, stringent', protocolType);
parameters=previousParameters;
parameters.mean = 0.5;
parameters.typeOfLUT= 'linearizedDefault';
parameters.rangeOfMonitorLinearized=[0.0 0.5];
[linearized previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Step 2d: Thinner %s, stringent', protocolType);
parameters=previousParameters;
parameters.pixPerCycs =32;
[thinner previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Step 2e: Smaller %s, stringent', protocolType);
parameters=previousParameters;
parameters.stdGaussMask = 1/16;
[smaller previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Step 3a: Dim flankers %s, stringent', protocolType);
parameters=previousParameters;
parameters.fractionNoFlanks=.05;
parameters.flankerContrast = [ 0.1]; % **!! confirm this!
parameters.flankerOffset = 3;
%for all stimuli with displayTargetAndDistractor = 0, these will not matter
parameters.distractorYokedToTarget=1;
parameters.distractorFlankerYokedToTargetFlanker = 1;
parameters.distractorContrast = 0;

parameters.shapedParameter='flankerContrast';
parameters.shapingMethod='linearChangeAtCriteria';
parameters.shapingValues.numSteps=int8(9);
parameters.shapingValues.performanceLevel= [0.9,0.85,0.82,0.8];   %using conf at ~.78;   for confidence at .85: [0.95,0.9,0.85,0.8];
parameters.shapingValues.numTrials=int16([50,100,200,500]);
parameters.shapingValues.startValue=parameters.flankerContrast;
parameters.shapingValues.currentValue=parameters.flankerContrast;
parameters.shapingValues.goalValue=1;
parameters.graduation = parameterThresholdCriterion('.stimDetails.flankerContrast','>=',0.99);

[dimFlankers previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Step 3b: Full contrast flankers %s, stringent', protocolType);
parameters=previousParameters;
parameters.shapedParameter=[];
parameters.shapingMethod=[];
parameters.shapingValues=[];
parameters.flankerContrast = [1];
parameters.graduation = performanceCriterion([0.85, 0.8],int16([200,500]));
[fullFlankers previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Step 3c: Flankers change positions %s, stringent', protocolType);
parameters=previousParameters;
parameters.persistFlankersDuringToggle = 0; %
[flanksToggleToo previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Step 3d: Flankers change positions %s, stringent', protocolType);
parameters=previousParameters;
parameters.flankerOffset = [2.5 3 3.5 5]; % **!! confirm this!
[varyPosition previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});


%% experiment mode

% expt 1:
% 2* contrasts, 4 relative phases, 2 flanker contexts (VV and VH), 1
% spatial offset (==3)
% goal: compare VV to VH, don't bias a particular phase for expt 2
% -->32 days

nameOfShapingStep{end+1} = sprintf('Expt 1: VV-VH', protocolType);
targetContrast= 1; % [0.6 0.8] %a guess for thresh!
parameters=setLeftAndRightContrast(parameters, protocolType, targetContrast);

numPhase = 4; parameters.phase= 2*pi * [0: numPhase-1]/numPhase;
parameters.flankerOffset = [3];

%Remove correlation for experiments
parameters.maxCorrectOnSameSide=int8(-1);
parameters.percentCorrectionTrials=0;  %doTo: not used yet!

%And then the 'default' parameters (which would not need to be set if testing steps are added to the end of the protocol)
%     parameters.goRightOrientations = [0];
%     parameters.goLeftOrientations =  [0];
%     parameters.flankerOrientations = [0,pi/2]; %choose a random orientation from this list\
%
%     parameters.stdGaussMask = 1/16;
%     parameters.positionalHint=0;
%     parameters.displayTargetAndDistractor=1;
%end default parameters

%parameters.graduation = timeCriterion(32);
%parameters.graduation = experimenterControlled([16,28,32],[0,0,0]);
parameters.graduation = performanceCriterion([0.99],int16([9999]));
[vvVH previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

% expt 2:
% 2* contrasts, 4 relative phases, 1 flanker contexts (VV), 1 spatial offset (==3)
% goal:  compare effect of relative phase
% -->16 days
nameOfShapingStep{end+1} = sprintf('Expt 2: VV phases', protocolType);
parameters.flankerOrientations = [0];
parameters.pixPerCycs = 64;  %WARNING YOU WOULD EXPECT THIS TO BE 32!!!!! but changed because of 125 failing!
%parameters.graduation = timeCriterion(16);
%parameters.graduation = experimenterControlled([8,12,16],[0,0,0]);
parameters.graduation = performanceCriterion([0.99],int16([9999]));
[vvPhases previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});


% expt 3:
% 2* contrasts, 1 "aligned" phase, 1 flanker contexts (VV), 5 spatial
% offset (i.e. 2 2.5 3 3.5 4)
% goal:  compare effect at a range of distances
nameOfShapingStep{end+1} = sprintf('Expt 3: VV offsets', protocolType);
parameters.flankerYokedToTargetPhase =0;
parameters.flankerOffset = [2 2.5 3 3.5 4];
%parameters.flankerOffset = [2.5 3 3.5 5]; % **!! confirm this!
%parameters.graduation = timeCriterion(40);
%parameters.graduation = experimenterControlled([20,35,40],[0,0,0]);
parameters.graduation = performanceCriterion([0.99],int16([9999]));
[vvOffsets previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});


% expt 4-5  combine spatial offset with phase or orientation... only if
% you have an effect
% goal:  view the differential effects on performance at different
% distances...as in literature
nameOfShapingStep{end+1} = sprintf('Expt 4: VV phasesOffset', protocolType);
parameters.flankerYokedToTargetPhase =1;
%parameters.graduation = timeCriterion(50);
%parameters.graduation = experimenterControlled([10,30,50],[0,0,0]);
parameters.graduation = performanceCriterion([0.99],int16([9999]));
[vvPhasesOffset previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Expt 5: VV-VH offsets', protocolType);
parameters.flankerYokedToTargetPhase =1;
%parameters.graduation = timeCriterion(50);
%parameters.graduation = experimenterControlled([10,30,50],[0,0,0]);
parameters.graduation = performanceCriterion([0.99],int16([9999]));
[vvVHOffsets previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});


parameters.flankerYokedToTargetPhase =1;
%parameters.graduation = timeCriterion(50);
%parameters.graduation = experimenterControlled([10,30,50],[0,0,0]);
parameters.graduation = performanceCriterion([0.99],int16([9999]));
[vvVHOffsets previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});





fd1TM = makeFreeDrinksTM(0.01); %juicy
fd2TM = makeFreeDrinksTM(0.001); % some
[fd3TM, SM] = makeFreeDrinksTM(0); % none


grad1 = rateCriterion(4,1); %(3,2)? (3,3)?
grad2 = rateCriterion(5,2); % how likely is it that false positives trigger a graduation without rat licks? -pmm
grad3 = rateCriterion(6,3); % rateCriterion(10,3) % (20,1)? (5,20)?


fd1 = trainingStep(fd1TM, SM, grad1, nTrialsThenWait([1000],[1],[0.001],[1]));
fd2 = trainingStep(fd2TM, SM, grad2, nTrialsThenWait([1000],[1],[0.001],[1]));
fd3 = trainingStep(fd3TM, SM, grad3, nTrialsThenWait([1000],[1],[0.001],[1]));
%fdSteps=protocol('contrasty gabor free drinks weening',{fd1, fd2, fd3});


%% fd test
%s = subject('fdtest', 'rat', 'long-evans', 'male', '08/20/2006', '09/20/2006', 'unknown', 'Jackson Laboratories'); r=addSubject(r,s,'pmm');
%[s r]=setProtocolAndStep(s,fdSteps,1,0,1,1,r,'first try','pmm');  %juicey  (0.01)
%[s r]=setProtocolAndStep(s,fdSteps,1,0,1,2,r,'first try','pmm'); %some (0.001)
%[s r]=setProtocolAndStep(s,fdSteps,1,0,1,3,r,'first try','pmm'); %no
%stochastic

%%  make new ratrix station and box, if you don't have one

if isempty(r)
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


%% assemble the protocol
%nameOfProtocol=[protocolType '_v' protocolVersion];
nameOfProtocol=generateProtocolName(nameOfShapingStep,protocolVersion,defaultSettingsDate)

switch protocolVersion
    case '1_0'
        p=protocol(nameOfProtocol,{fd1,fd2,fd3,easy,stringent,linearized,thinner,smaller,dimFlankers,fullFlankers,flanksToggleToo,varyPosition})
    case '1_1'
        p=protocol(nameOfProtocol,{fd1,fd2,fd3,easy,stringent,linearized,thinner,smaller,dimFlankers,fullFlankers,flanksToggleToo,varyPosition})
    case '1_2'
        p=protocol(nameOfProtocol,{fd1,fd2,fd3,easyHint,stringent,linearized,thinner,smaller,dimFlankers,fullFlankers,flanksToggleToo,varyPosition})
    case '1_3'
        p=protocol(nameOfProtocol,{fd1,fd2,fd3,easy,stringent,linearized,thinner,smaller,dimFlankers,fullFlankers,flanksToggleToo,varyPosition,vvVH,vvPhases,vvOffsets,vvPhasesOffset,vvVHOffsets})
    case '1_4'
        p=protocol(nameOfProtocol,{fd1,fd2,fd3,easy,stringent,linearized,thinner,smaller,dimFlankers,fullFlankers,flanksToggleToo,varyPosition,vvVH,vvPhases,vvOffsets,vvPhasesOffset,vvVHOffsets})

    otherwise
        error('bad protocol type')
end

r=addTheseRats(r,subjects,p,persistTrainingSteps);

%% test graduation

testGraduation=0;
if testGraduation
    load 'C:\Documents and Settings\rlab\Desktop\localAnalysis\out\trialRecords.mat'
    c=rateCriterion(10,3);
    % c=performanceCriterion([.8,.5,.95],[20,200,2000]);
    ts=getTrainingStep(p,4); %why bother passing this in if we already know criteria?
    %trialRecords.correct=rand(1,300)>0.5;
    graduate = checkCriterion(c,s,ts,trialRecords)
end

%% stim test

stimTest=0;
if stimTest
    clc
    trialManagerClass = class(getTrialManager(thinner));
    frameRate = 60;
    responsePorts = [1 3];
    totalPorts = [3];
    width=1024;
    height=768;
    trialRecords = [];

    stimManager=getStimManager(thinner)
    [stimManager junk2 im a b c d e details] = calcStim(stimManager,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);
    details
    subplot(1, 2, 1); imagesc(im(:,:,1))
    subplot(1, 2, 2); imagesc(im(:,:,2))
    colormap(gray)
end


%% Functions


function r=setAcuity(r,subjects,protocolType,protocolVersion)
%r=setAcuity(r,{'rat_112','testAcuity'},'tiltDiscrim','1_0')

defaultSettingsDate='Oct.09,2007';
parameters=getDefaultParameters(ifFeatureGoRightWithTwoFlank,protocolType,protocolVersion,defaultSettingsDate);

nameOfShapingStep{1} = sprintf('Expt1: spatial frequency sweep', protocolType);
parameters.graduation = performanceCriterion([0.99],int16([9999]));
parameters.scheduler=minutesPerSession(90,3);
parameters.msRequestRewardDuration=0;
parameters.msPenalty=10000;
parameters.mean = 0.5;
parameters.typeOfLUT= 'linearizedDefault';
parameters.rangeOfMonitorLinearized=[0.0 0.5];
parameters.stdGaussMask = 1/5;
parameters.gratingType='sine';
parameters.pixPerCycs =[4 8 16 32 64 128];
[experiment1 previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Expt2: spatial frequency plus contrast sweep', protocolType);
parameters=setLeftAndRightContrast(previousParameters, protocolType, [0 0.125 0.25 0.5 0.75 1]);
[experiment2 previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfProtocol=generateProtocolName(nameOfShapingStep,protocolVersion,defaultSettingsDate);
p=protocol(nameOfProtocol,{experiment1,experiment2});
persistTrainingSteps=1;
r=addTheseRats(r,subjects,p,persistTrainingSteps);

function r=addTheseRats(r,subjects,p,persistTrainingSteps)
% add these rats and set per rat values

if ~exist('persistTrainingSteps', 'var')
    persistTrainingSteps=1; %this is if you have to reset protocol... we'll give you the trainingStep from previous ratrix
end

for i=1:size(subjects,2)
    miniDatabasePath = 'C:\pmeier\Ratrix\analysis\miniDatabase';  %testing
    %miniDatabasePath = '\\192.168.0.1\c\pmeier\RSTools\miniDatabase';
    
% only make and add a rat if its not there
    if ~any(strcmp(subjects{i}, definedRats)) 
    s = subject(char(subjects(i)), 'rat', 'long-evans', 'male', '01/01/2005', '01/02/2005', 'unknown', 'Jackson Laboratories', miniDatabasePath, '');
    r=addSubject(r,s,'pmm');
    end
    
    if persistTrainingSteps
        stepNum=getDatabaseFact(getSubjectFromID(r,char(subjects(i))),'stepNumber') %this is if you have to reinit...
    else
        stepNum=1;
    end
    
    stepNum
    subjects(i)
    [s  r]=setProtocolAndStep(s ,p,1,0,1,stepNum,r,'from pmm master Shaping','pmm');
    if persistTrainingSteps
        r=setCurrentShapedValueFromMiniDatabase(s,r);
    end
end


function [TM, SM] = makeFreeDrinksTM(pctStochasticReward, contrast)

% shared parameters for free drinks
if ~exist('contrast', 'var')
    contrast = 0; % if wrong for shaping, show nothing!
end

msFlushDuration         =1000;
msRewardDuration        =100;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =1;
msRewardSoundDuration   =msRewardDuration;
sndManager            =makeStandardSoundManager();

pctStochasticReward=0.0;  %0.01 or 0.001;

pixPerCycs              =[20];
targetOrientations      =0;%rand*pi;%[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =.1;
% contrast                =1; passed in
thresh                  =.00005;
yPosPct                 =.65;
maxWidth                =800;
maxHeight               =600;
scaleFactor             =[1 1];
interTrialLuminance     =0.5;


%universal free drink parans

msRewardDuration        =100;
msPenalty               =1;
msRewardSoundDuration   =msRewardDuration;
pctStochasticReward=0.01;  %0.01 or 0.001;

% contrast                =1;   % if wrong for shaping, show nothing!
% maxWidth                =800;
% maxHeight               =600;
% scaleFactor             =[1 1];

maxWidth                =120;
maxHeight               =100;
scaleFactor             =[0];

%pctStochasticReward = passed in ;
TM = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,msPenalty,msRewardSoundDuration,pctStochasticReward);
SM = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);


function [step parameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep)
p=parameters;
stim = ifFeatureGoRightWithTwoFlank([p.pixPerCycs],[p.goRightOrientations],[p.goLeftOrientations],[p.flankerOrientations],...
    p.topYokedToBottomFlankerOrientation,p.topYokedToBottomFlankerContrast,[p.goRightContrast],[p.goLeftContrast],...
    [p.flankerContrast],p.mean,p.cueLum,p.cueSize,p.xPositionPercent,p.cuePercentTargetEcc,p.stdGaussMask,p.flankerOffset,...
    p.framesJustFlanker,p.framesTargetOn,p.thresh,p.yPositionPercent,p.toggleStim,p.typeOfLUT,p.rangeOfMonitorLinearized,...
    p.maxCorrectOnSameSide,p.positionalHint,p.xPosNoise,p.yPosNoise,p.displayTargetAndDistractor,p.phase,p.persistFlankersDuringToggle,...
    p.distractorFlankerYokedToTargetFlanker,p.distractorOrientation,p.distractorFlankerOrientation,p.distractorContrast,...
    p.distractorFlankerContrast, p.distractorYokedToTarget, p.flankerYokedToTargetPhase, p.fractionNoFlanks,...
    p.shapedParameter, p.shapingMethod, p.shapingValues,...
    p.gratingType, p.framesMotionDelay, p.numMotionStimFrames, p.framesPerMotionStim,...
    p.protocolType,p.protocolVersion,p.protocolSettings, ...
    p.maxWidth,p.maxHeight,p.scaleFactor,p.interTrialLuminance);

increasingReward=rewardNcorrectInARow(p.msRewardNthCorrect,p.msPenalty,p.fractionOpenTimeSoundIsOn,p.fractionPenaltySoundIsOn, p.scalar);
nafc=nAFC(p.msFlushDuration,p.msRewardDuration,p.msMinimumPokeDuration,p.msMinimumClearDuration,p.sndManager,...
    p.msPenalty,p.msRequestRewardDuration,p.percentCorrectionTrials,p.msResponseTimeLimit,p.pokeToRequestStim,...
    p.maintainPokeToMaintainStim,p.msMaximumStimPresentationDuration,p.maximumNumberStimPresentations,p.doMask,p.msRewardSoundDuration,increasingReward);
step= trainingStep(nafc, stim, p.graduation, p.scheduler); %it would be nice to add the nameOfShapingStep

function nameOfProtocol=generateProtocolName(nameOfShapingStep,protocolVersion,defaultSettingsDate)
numSteps=size(nameOfShapingStep,2);
string=sprintf('version %s\ndefaultSettingsDate %s',protocolVersion, defaultSettingsDate);
for i=1:numSteps
    string=[string '\n' nameOfShapingStep{i}];
end
nameOfProtocol=string;


function parameters=setLeftAndRightContrast(parameters, protocolType, targetContrast)
switch protocolType
    case 'goToSide'
        parameters.goRightContrast = [targetContrast];    %choose a random contrast from this list each trial
        parameters.goLeftContrast =  [targetContrast];
    case 'goToRightDetection'
        parameters.goRightContrast = [targetContrast];    %choose a random contrast from this list each trial
        parameters.goLeftContrast =  [0];
    case 'goToLeftDetection'
        parameters.goRightContrast = [0];    %choose a random contrast from this list each trial
        parameters.goLeftContrast =  [targetContrast];
    case 'tiltDiscrim'
        parameters.goRightContrast = [targetContrast];    %choose a random contrast from this list each trial
        parameters.goLeftContrast =  [targetContrast];
    otherwise
        protocolType=protocolType
        error('unknown type of protocol requested')
end


function r=setCurrentShapedValueFromMiniDatabase(s, r)

[p stepNum]=getProtocolAndStep(s);
ts = getTrainingStep(p,stepNum);
stim = getStimManager(ts);
currentValue = getCurrentShapedValue(stim);
% there are two plausible reasons for the currentValue to be empty:
% 1. the stimulus is not shaping anything 
% 2. the stimulus is shaping something but currentValue is [], this should
% never happen! We passed back a string of the word 'empty'
% 3. somehow, an empty value got loaded in from the miniDatabase, possibly
% because the field was never defined, this should never happen and if it
% did, see 2. above
if ~isempty(currentValue) % some steps have no shaping, so don't get database fact, and replace value
    valueInDatabase = getDatabaseFact(s,'currentShapedValue'); %this is if you have to reinit...
    if ~isempty(valueInDatabase)
        stim = setCurrentShapedValue(stim, valueInDatabase);
        ts = setStimManager(ts, stim);
        %     subject = setTrainingStep(subject, ts);
        [s r]=changeProtocolStep(s,ts,r,'updating shaping value','pmm'); % only change the current step!
        
        % confirm it worked
        s2=getSubjectFromID(r,getID(s));
        [p stepNum]=getProtocolAndStep(s2);
        ts = getTrainingStep(p,stepNum);
        stim = getStimManager(ts);
        currentValue = getCurrentShapedValue(stim)
        if currentValue ~= valueInDatabase
            error('what up wi'' dat?')
        end

    else
        getID(s)
        stepNum = stepNum
        valueInDatabase = valueInDatabase
        currentValue = currentValue
        error('must have currentShapedValue defined in database, if rat is on a shaping step ')
    end
end


function unusedReferenceFunction
%% DOUBLE CHECK BEFORE DEPLOYING
%miniDataBase location away from test location find  'miniDatabasePath ='
%defining rat per station
%force quit (or confirm overwrite doesn't send ratSubjectInit)
%force initialization
%state of default reloadStepsFromRatrix in makeMiniDatabase
% Confirm minidatabase/rig1/minidatabase.mat does not interfere! 08/02/07


%% Upon adding new rats

%getCurrentSubjects -- active list of heats
%findStationsForSubject -- subject station pairing
%RatSubjectInit -- protocol defined
%makeMiniDatabase -- define starting values


%% OLD removed 071129
% r=setShaping(r,{'rat_131','rat_134','rat_135'}, 'goToSide', '1_0')
% r=setShaping(r,{'rat_128','rat_132','rat_133'}, 'goToRightDetection', '1_0')
% r=setShaping(r,{'rat_112','rat_113','rat_126'}, 'goToRightDetection', '1_0')
% r=setShaping(r,{'rat_102','rat_106','rat_127'}, 'goToRightDetection', '1_0')
% r=setShaping(r,{'rat_114','rat_115','rat_129'}, 'tiltDiscrim', '1_0')
%r=setShaping(r,{'rat_116','rat_117','rat_130'}, 'tiltDiscrim', '1_0')

