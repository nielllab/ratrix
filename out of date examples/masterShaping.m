function masterShaping() 


%% addPaths
 rootPath='C:\pmeier\Ratrix\';
%warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([fullfile(rootPath,'Server')]))
%warning('on','MATLAB:dispatcher:nameConflict')


%% set each rat on a protocol
r=setShaping([],{'rat_102','rat_106'}, 'goToRightDetection', '1_0')
r=setShaping(r,{'rat_116','rat_117'}, 'goToSide', '1_0')

%% set shaping
function r=setShaping(r,subjects, protocolType, protocolVersion, defaultSettingsDate, persistTrainingSteps)
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
    persistTrainingSteps=0; %this is if you have to reinit... we'll give you the trainingStep from previous ratrix
end





%% define shared and constant parameters for all rats

%% default for all of pmeier stims
default=getDefaultParametersForPmeierStim(protocolType,protocolVersion,defaultSettingsDate);

%% parameters for each shaping step
nameOfShapingStep{1} = sprintf('Step 2b: Easy %s, stringent', protocolType);
parameters=default;

parameters.msRequestRewardDuration             =0;
parameters.msPenalty=1000;

parameters.scheduler = nTrialsThenWait([1000],[1],[0.01],[1]); %noTimeOff()
parameters.graduation = performanceCriterion(.95,300);
%graduation = rateCriterion(5,2)+
%Criteria: 5 trials per minute for 5-10 minutes
[easy previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Step 2b: Easy %s, stringent', protocolType);
parameters=previousParameters;
parameters.msRequestRewardDuration=0;
parameters.msPenalty=10000;
[centerOff previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

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
parameters.flankerContrast = [0 0.1 0.2 0.3]; % **!! confirm this!
parameters.flankerOffset = 3;
[dimFlankers previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

parameters.msPenalty = 10;  %just test
[testStim junk]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Step 3b: Full contrast flankers %s, stringent', protocolType);
parameters=previousParameters;
parameters.flankerContrast = [0 1 1 1]; % **!! confirm this!
[fullFlankers previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

nameOfShapingStep{end+1} = sprintf('Step 3c: Flankers change positions %s, stringent', protocolType);
parameters=previousParameters;
parameters.flankerContrast = [0 1 1 1]; % **!! confirm this!
[varyPosition previousParameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep{end});

pixPerCycs =32;
flankerContrast = [1 1 1 0]; % **!! confirm this!
flankerOrientations = [pi/6,0,-pi/6]; %choose a random orientation from this list
distractorContrast = [0];mean = 0.5;
stdGaussMask = 1/16;
flankerOffset = [1 2 3 4 5];
typeOfLUT= 'linearizedDefault';
%rangeOfMonitorLinearized=[0.0 0.5];

msRequestRewardDuration             =0;
msPenalty=10000;
msRewardNthCorrect=1*[20,80,100,150,250];


%% shared parameters for free drinks

msFlushDuration         =1000;
msRewardDuration        =100;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =1;
msRewardSoundDuration   =msRewardDuration;
sndManager            =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});
pctStochasticReward=0.0;  %0.01 or 0.001;

pixPerCycs              =[20];
targetOrientations      =0;%rand*pi;%[pi/2];
distractorOrientations  =[];
mean                    =.5;
radius                  =.1;
contrast                =1;
thresh                  =.00005;
yPosPct                 =.65;
maxWidth                =800;
maxHeight               =600;
scaleFactor             =[1 1];
interTrialLuminance     =0.5;


%% universal free drink parans

msRewardDuration        =100;
msPenalty               =1;
msRewardSoundDuration   =msRewardDuration;
pctStochasticReward=0.01;  %0.01 or 0.001;

% contrast                =1;   % if wrong for shaping, show nothing!
% maxWidth                =800;
% maxHeight               =600;
% scaleFactor             =[1 1];

contrast                =0;   % if wrong for shaping, show nothing!
maxWidth                =120;
maxHeight               =100;
scaleFactor             =[0];

pctStochasticReward=0.01;  %juicey
fd1 = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,msPenalty,msRewardSoundDuration,pctStochasticReward);

pctStochasticReward=0.001;  %some
fd2 = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,msPenalty,msRewardSoundDuration,pctStochasticReward);

pctStochasticReward=0;  %none
fd3 = freeDrinks(msFlushDuration,msRewardDuration,msMinimumPokeDuration,msMinimumClearDuration,sndManager,msPenalty,msRewardSoundDuration,pctStochasticReward);

stim = orientedGabors(pixPerCycs,targetOrientations,distractorOrientations,mean,radius,contrast,thresh,yPosPct,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
fd1 = trainingStep(fd1, stim, repeatIndefinitely(), nTrialsThenWait([1000],[1],[0.001],[1]));
fd2 = trainingStep(fd2, stim, repeatIndefinitely(), nTrialsThenWait([1000],[1],[0.001],[1]));
fd3 = trainingStep(fd3, stim, repeatIndefinitely(), nTrialsThenWait([1000],[1],[0.001],[1]));
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
        rootPath='C:\pmeier\Ratrix\';
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

    screenWidth= 800;  screenHeight=600;
    r=ratrix([rootPath 'ServerData' pathSep],1);
    %st=station(int8(1),int8([6,7,8]),int8([4,2,3]),1280,1024,'ptb','keyboard'    ,[rootPath 'Stations' pathSep 'station1' pathSep],[]    ,int8(screenNum),int8(1),logical(soundOn));
    st =station(int8(1),int8([6,7,8]),int8([4,2,3]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep] ,'0378',int8(screenNum),int8(1),logical(soundOn));
    %old bomb? %st =station(int8(1),int8([7,6,8]),int8([3,4,2]),screenWidth,screenHeight,'ptb','parallelPort',[rootPath 'Stations' pathSep 'station1' pathSep] ,'0378',int8(screenNum),int8(1),logical(soundOn));
    b=box(int8(1),[rootPath 'Boxes' pathSep 'box1' pathSep]);
    r=addBox(r,b);
    r=addStationToBoxID(r,st,getID(b));
end


%% assemble the protocol
switch protocolVersion
    case '1_0'
        nameOfProtocol=[protocolType '_v' protocolVersion];
        nameOfProtocol=generateProtocolName(nameOfShapingStep,protocolVersion,defaultSettingsDate)
                         % 1  2  3    4      5         6         7        8         9          10            11         12?              
        p=protocol(nameOfProtocol,{fd1,fd2,fd3,easy,centerOff,linearized,thinner,smaller,dimFlankers,fullFlankers,varyPosition})
    case '!!!'
    otherwise
        error('bad protocol type')
end



%% add the rats
for i=1:size(subjects,2)
    s = subject(char(subjects(i)), 'rat', 'long-evans', 'male', '01/01/2005', '01/02/2005', 'unknown', 'Jackson Laboratories');
    r=addSubject(r,s,'pmm');
    if persistTrainingSteps
        stepNum=getStepFromPreviousRatrix(char(subjects(i)));  %this is if you have to reinit...
    else
        stepNum=9;
    end
    [s  r]=setProtocolAndStep(s ,p,1,0,1,stepNum,r,'from pmm master Shaping','pmm');
end

%% tester


[member index]=ismember('test',getSubjectIDs(r));
if index>0
    %test subject already there
else
    s = subject('test', 'rat', 'long-evans', 'male', '01/01/2005', '01/02/2005', 'unknown', 'Jackson Laboratories');
    r=addSubject(r,s,'pmm');
    test_p=protocol('testProto',{testStim});
    [s  r]=setProtocolAndStep(s ,test_p,1,0,1,1,r,'from pmm master Shaping','pmm');
end


%% Functions
function [step parameters]=setFlankerStimRewardAndTrialManager(parameters, nameOfShapingStep)
p=parameters;
stim = ifFeatureGoRightWithTwoFlank([p.pixPerCycs],[p.goRightOrientations],[p.goLeftOrientations],[p.flankerOrientations],...
    p.topYokedToBottomFlankerOrientation,p.topYokedToBottomFlankerContrast,[p.goRightContrast],[p.goLeftContrast],...
    [p.flankerContrast],p.mean,p.cueLum,p.cueSize,p.xPositionPercent,p.cuePercentTargetEcc,p.stdGaussMask,p.flankerOffset,...
    p.framesJustFlanker,p.framesTargetOn,p.thresh,p.yPositionPercent,p.toggleStim,p.typeOfLUT,p.rangeOfMonitorLinearized,...
    p.maxCorrectOnSameSide,p.positionalHint,p.xPosNoise,p.yPosNoise,p.displayTargetAndDistractor,p.phase,p.persistFlankersDuringToggle,p.maxWidth,...
    p.maxHeight,p.scaleFactor,p.interTrialLuminance)
increasingReward=rewardNcorrectInARow(p.msRewardNthCorrect,p.msPenalty,p.fractionOpenTimeSoundIsOn,p.fractionPenaltySoundIsOn,p.scalar);
nafc=nAFC(p.msFlushDuration,p.msRewardDuration,p.msMinimumPokeDuration,p.msMinimumClearDuration,p.sndManager,...
    p.msPenalty,p.msRequestRewardDuration,p.percentCorrectionTrials,p.msResponseTimeLimit,p.pokeToRequestStim,...
    p.maintainPokeToMaintainStim,p.msMaximumStimPresentationDuration,p.maximumNumberStimPresentations,p.doMask,p.msRewardSoundDuration,increasingReward)
step= trainingStep(nafc, stim, p.graduation, p.scheduler); %it would be nice to add the nameOfShapingStep

function nameOfProtocol=generateProtocolName(nameOfShapingStep,protocolVersion,defaultSettingsDate)
numSteps=size(nameOfShapingStep,2);
string=sprintf('version %s\ndefaultSettingsDate %s',protocolVersion, defaultSettingsDate);
for i=1:numSteps
    string=[string '\n' nameOfShapingStep{i}];
end
nameOfProtocol=string;

function default=getDefaultParametersForPmeierStim(protocolType,protocolVersion,defaultSettingsDate);

switch defaultSettingsDate
    case 'Oct.09,2007'

        default.sndManager=soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
            soundClip('keepGoingSound','allOctaves',[300],20000), ...
            soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
            soundClip('wrongSound','tritones',[300 400],20000)});

        default.maxWidth                =1024;
        default.maxHeight               =768;
        default.scaleFactor             =[1 1];
        default.interTrialLuminance     =0.5;

        default.pixPerCycs =64;
        numPhase = 4; default.phase= 2*pi * [0: numPhase-1]/numPhase;
        default.mean = 0.2;
        default.msRewardNthCorrect=1*[20,80,100,150,250];
        default.maxCorrectOnSameSide=int8(4);

        default.typeOfLUT= 'useThisMonitorsUncorrectedGamma';
        default.rangeOfMonitorLinearized=[0.0 0.5];

        default.flankerOffset = 0;
        default.flankerContrast = [0];

        default.topYokedToBottomFlankerOrientation =1;
        default.topYokedToBottomFlankerContrast =1;

        default.cueLum=1;                %luminance of cue square
        default.cueSize=0;               %roughly in pixel radii

        default.xPositionPercent = 0.5;  %target position in percent ScreenWidth
        default.cuePercentTargetEcc=0.6; %fraction of distance from center to target  % NOT USED IN cuedGoToFeatureWithTwoFlank

        default.framesJustFlanker=int8(2);
        default.framesTargetOn=int8(50);
        default.thresh = 0.001;
        default.yPositionPercent = 0.5;
        default.toggleStim = 1;

        default.displayTargetAndDistractor =0;
        default.xPosNoise=0.0;%standard deviation of noise in fractional screen width
        default.yPosNoise=0;%standard deviation of noise in fractional screen height
        default.persistFlankersDuringToggle=1;
        
        default.msFlushDuration         =1000;
        default.msRewardDuration        =0;     %not used! but still defined in nAFC.  Eventually remove. pmm
        default.msMinimumPokeDuration   =10;
        default.msMinimumClearDuration  =10;
        default.msPenalty               =4000;
        default.msRewardSoundDuration   =0; %not used! but still defined in nAFC.  Eventually remove. pmm

        default.msRequestRewardDuration             =0;
        default.percentCorrectionTrials             =.5;
        default.msResponseTimeLimit                 =0;
        default.pokeToRequestStim                   =1;
        default.maintainPokeToMaintainStim          =1;
        default.msMaximumStimPresentationDuration   =0;
        default.maximumNumberStimPresentations      =0;
        default.doMask                              =1;

        % constant parameters for reinforcement manager
        default.fractionOpenTimeSoundIsOn=0.6;
        default.fractionPenaltySoundIsOn=1;

end

%% set protocol type
switch protocolVersion
    case '1_0'
        switch protocolType

            case 'goToSide'
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                default.goRightOrientations = [0,pi/2];
                default.goLeftOrientations =  [0,pi/2];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list

                default.stdGaussMask = 1/8;
                default.positionalHint=0.2;

            case 'goToRightDetection'
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [0];
                default.flankerContrast = [0];

                default.goRightOrientations = [0,pi/2];
                default.goLeftOrientations =  [0,pi/2];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0;

            case 'goToLeftDetection'

                default.goRightContrast = [0];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];

                default.goRightOrientations = [0,pi/2];
                default.goLeftOrientations =  [0,pi/2];
                default.flankerOrientations = [0,pi/2]; %choose a random orientation from this list

                default.stdGaussMask = 1/5;
                default.positionalHint=0;

            case 'tiltDiscrim'
                error('double check all arguments')
                default.goRightContrast = [1];    %choose a random contrast from this list each trial
                default.goLeftContrast =  [1];
                default.flankerContrast = [0];
                %default.distractorContrast = [0]; %do we need this?
                %note: displayTargetAndDistractor =0; in default

                default.goRightOrientations = [pi/6];
                default.goLeftOrientations =  [-pi/6];
                default.flankerOrientations = 0; %[pi/6,0,-pi/6]; %choose a random orientation from this list
                %default.topYokedToBottomFlankerOrientation =1;  %note this is redundant with default params

                default.stdGaussMask = 1/5;
                default.positionalHint=0;


            otherwise
                error('unknown type of protocol requested')
        end
    otherwise
        error ('unknown version')
end

function unusedReferenceFunction

%% master parameter list
%Master shaping steps for Go To Side  WRONG FOR DETECTION OR GO TO
%SIDE!!!!

%Step 1a: Free drinks, high stochastic value
%Purpose: To get them to associate water from the ports
%Criteria: Reliably drinks many times in row, about 2-5 minutes of drinking

stochastic = 0.01; 	rewardDuration=1*300; msPenalty =1;

%Step 1b: Free drinks, low stochastic value
%Purpose: To see if they can trigger with their tongue

stochastic = 0.001;	rewardDuration=1*300;

%Step 1c: Free drinks
%Purpose: To make sure that they can switch between ports
%Warning: Rats might use two ports instead of all three
%Criteria: 20-30 rapidly triggered trials in less than 1-2 minutes
%or 100-200 trials with a rate of at least 5 trial per minute

stochastic = 0;


%Step 2a (pmeier version): Easy detection, friendly
%Purpose: To expose animals to stimuli, get used to sounds, ween them off centerReward
%Criteria: 5 trials per minute for 5-10 minutes

nameOfShapingStep = 'Step 2a: Easy goTo, friendly'
pixPerCycs =64;
flankerContrast = [0];
flankerOrientations = [0];  %just vertical, but we never see them
distractorContrast = [0];
mean = 0.2;
stdGaussMask = 1/8;
flankerOffset = 0;
typeOfLUT= 'useThisMonitorsUncorrectedGamma';
%rangeOfMonitorLinearized=[0.0 0.5];

msRequestRewardDuration             =0;
msPenalty               =2000;
msRewardNthCorrect=1*[300 600 900];

%Step 2b: Easy detection, stringent
%Purpose: To get animal to learn an easy task
%Criteria: First achieves 85% correct over 100 trials
%or sustains an average of 70% correct for 2-5 days

nameOfShapingStep = 'Step 2b: Easy detection, stringent'

pixPerCycs =64;
flankerContrast = [0];
flankerOrientations = [0];  %just vertical, but we never see them
distractorContrast = [0];
mean = 0.2;
stdGaussMask = 1/8;
flankerOffset = 0;
typeOfLUT= 'useThisMonitorsUncorrectedGamma';
%rangeOfMonitorLinearized=[0.0 0.5];

msRequestRewardDuration             =0;
msPenalty=10000;
msRewardNthCorrect=1*[20,80,100,150,250];


%Step 2c: linearized detection
%Purpose: To get animal to perform on the linearized monitor
%Criteria: First achieves 85% correct over 100 trials
%or sustains an average of 70% correct for 2-5 days

nameOfShapingStep = 'Step 2c: linearized detection'

pixPerCycs =64;
flankerContrast = [0];
flankerOrientations = [0];  %just vertical, but we never see them
distractorContrast = [0];
mean = 0.5;
stdGaussMask = 1/8;
flankerOffset = 0;
typeOfLUT= 'linearizedDefault';
%rangeOfMonitorLinearized=[0.0 0.5];

msRequestRewardDuration             =0;
msPenalty=10000;
msRewardNthCorrect=1*[20,80,100,150,250];


%Step 2d: detect thinner stripes
%Purpose: To get animal to perform on thinner stripes
%Criteria: First achieves 85% correct over 100 trials
%or sustains an average of 70% correct for 2-5 days

nameOfShapingStep = 'Step 2d: detect thinner stripes'

pixPerCycs =32;
flankerContrast = [0];
flankerOrientations = [0];  %just vertical, but we never see them
distractorContrast = [0];
mean = 0.5;
stdGaussMask = 1/8;
flankerOffset = 0;
typeOfLUT= 'linearizedDefault';
%rangeOfMonitorLinearized=[0.0 0.5];

msRequestRewardDuration             =0;
msPenalty=10000;
msRewardNthCorrect=1*[20,80,100,150,250];


%Step 2e: detect smaller region
%Purpose: To get animal to perform on thinner stripes
%Criteria: First achieves 85% correct over 100 trials
%or sustains an average of 70% correct for 2-5 days

nameOfShapingStep = 'Step 2e: detect smaller region'

pixPerCycs =32;
flankerContrast = [0];
flankerOrientations = [0];  %just vertical, but we never see them
distractorContrast = [0];
mean = 0.5;
stdGaussMask = 1/16;
flankerOffset = 0;
typeOfLUT= 'linearizedDefault';
%rangeOfMonitorLinearized=[0.0 0.5];

msRequestRewardDuration             =0;
msPenalty=10000;
msRewardNthCorrect=1*[20,80,100,150,250];


%Step 2f: detect with noise distribution
%Warning!!: skip this step if Philip has not made it yet.
%Purpose: To get animal to perform with noise distribution
%Criteria: First achieves 85% correct over 100 trials
%or sustains an average of 70% correct for 2-5 days

nameOfShapingStep = 'Step 2f: detect with noise distribution'

pixPerCycs =32;
flankerContrast = [0];
flankerOrientations = [0];  %just vertical, but we never see them
distractorContrast = [0];
mean = 0.5;
stdGaussMask = 1/16;
flankerOffset = 0;
typeOfLUT= 'linearizedDefault';
%rangeOfMonitorLinearized=[0.0 0.5];

msRequestRewardDuration             =0;
msPenalty=10000;
msRewardNthCorrect=1*[20,80,100,150,250];


%Step 3a: add flankers
%Purpose: To get animal to perform with flankers
%Criteria: First achieves 85% correct over 100 trials
%or sustains an average of 70% correct for 2-5 days

nameOfShapingStep = 'Step 3a: add flankers'

pixPerCycs =32;
flankerContrast = [1 1 1 0]; % **!! confirm this!
flankerOrientations = [pi/6,0,-pi/6]; %choose a random orientation from this list
distractorContrast = [0];
mean = 0.5;
stdGaussMask = 1/16;
flankerOffset = 3;
typeOfLUT= 'linearizedDefault';
%rangeOfMonitorLinearized=[0.0 0.5];

msRequestRewardDuration             =0;
msPenalty=10000;
msRewardNthCorrect=1*[20,80,100,150,250];

%Step 3b: change flanker position
%Purpose: To get animal to perform with changed flanker position
%Criteria: First achieves 85% correct over 100 trials
%or sustains an average of 70% correct for 2-5 days

nameOfShapingStep = 'Step 3b: change flanker position'

pixPerCycs =32;
flankerContrast = [1 1 1 0]; % **!! confirm this!
flankerOrientations = [pi/6,0,-pi/6]; %choose a random orientation from this list
distractorContrast = [0];mean = 0.5;
stdGaussMask = 1/16;
flankerOffset = [1 2 3 4 5];
typeOfLUT= 'linearizedDefault';
%rangeOfMonitorLinearized=[0.0 0.5];

msRequestRewardDuration             =0;
msPenalty=10000;
msRewardNthCorrect=1*[20,80,100,150,250];

%Step 3c: add distract?




