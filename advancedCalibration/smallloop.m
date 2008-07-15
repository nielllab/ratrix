
%% init

if 1
    screen clear all; clear classes; close all
    clc; format short g
end
rootPath='C:\pmeier\Ratrix\';
pathSep='\';
screenNum = 0;
soundOn = 1;

%% addPaths
warning('off','MATLAB:dispatcher:nameConflict')
addpath(genpath([rootPath 'Server' pathSep]))% Everything in the ratrix
addpath(genpath(['c:\pmeier\newStimTest\']))% A few extra things in this project
warning('on','MATLAB:dispatcher:nameConflict')

%% create a trial manager with default parameters
sndManager            =soundManager({soundClip('correctSound','allOctaves',[400],20000), ...
    soundClip('keepGoingSound','allOctaves',[300],20000), ...
    soundClip('trySomethingElseSound','gaussianWhiteNoise'), ...
    soundClip('wrongSound','tritones',[300 400],20000)});

%shared stim parameters  -- detection
maxWidth                =1280;
maxHeight               =1024;
scaleFactor             =[1 1];
interTrialLuminance     =0.5;

pixPerCycs =32;
goRightOrientations = [0,pi/2];
goLeftOrientations =  [0,pi/2];
flankerOrientations = [0,pi/2]; %choose a random orientation from this list

topYokedToBottomFlankerOrientation =1;
topYokedToBottomFlankerContrast =1;

goRightContrast = [1];    %choose a random contrast from this list each trial
goLeftContrast =  [0];
flankerContrast = [0];
%
meanLum = 0.5;              %normalized luminance - if not 0.5 then grating can be detected as mean lum changes
cueLum=0.5;              %luminance of cue square
cueSize=4;               %roughly in pixel radii

xPositionPercent = 0.5;  %target position in percent ScreenWidth
cuePercentTargetEcc=0.6; %fraction of distance from center to target  % NOT USED IN cuedGoToFeatureWithTwoFlank
stdGaussMask = 1/16;     %in fraction of vertical extent of stimulus
flankerOffset = 5;       %distance in stdGaussMask  (0-->5.9 when std is 1/16)
%
framesJustFlanker=int8(2);
framesTargetOn=int8(50);
thresh = 0.001;
yPositionPercent = 0.5;
toggleStim = 1;
typeOfLUT= 'useThisMonitorsUncorrectedGamma';
rangeOfMonitorLinearized=[0 1];

%freeDrinks = trainingStep(fd, stim, rateCriterion(6,5), noTimeOff());

msFlushDuration         =1000;
rewardSizeULorMS        =150;
msMinimumPokeDuration   =10;
msMinimumClearDuration  =10;
msPenalty               =4000;
msRewardSoundDuration   =rewardSizeULorMS;

requestRewardSizeULorMS             =0;
percentCorrectionTrials             =.5;
msResponseTimeLimit                 =0;
pokeToRequestStim                   =1;
maintainPokeToMaintainStim          =1;
msMaximumStimPresentationDuration   =0;
maximumNumberStimPresentations      =0;
doMask                              =1;

% parameters for reinforcement manager
fractionOpenTimeSoundIsOn=0.6;
fractionPenaltySoundIsOn=1;
rewardNthCorrect=2*[20,80,100,150,250];
maxCorrectOnSameSide=int8(4);

%no flank but sweep detection - make the psy curve!
pixPerCycs =32;
goRightContrast = [1 0.75 0.5 0.25 0.125];
meanLum = 0.5;
stdGaussMask = 1/16; %1/5;  %this is big and spends time in mvnpdf in compute gabors
flankerOffset = 0;  %only 0 while big target or no flanker; distance in stdGaussMask  (0-->5.9 when std is 1/16); consider making this a set of possible distances
flankerContrast = [1];
typeOfLUT= 'linearizedDefault';
rangeOfMonitorLinearized=[0.0 0.5];

msPenalty               =15000;
rewardNthCorrect=1*[20,80,100,150,250];

%trialManager =  ifFeatureGoRightWithTwoFlankTrialManager(pixPerCycs,goRightOrientations,goLeftOrientations,flankerOrientations,topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,goRightContrast,goLeftContrast,flankerContrast,meanLum,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,toggleStim,typeOfLUT,rangeOfMonitorLinearized,maxCorrectOnSameSide,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
trialManager =  ifFeatureGoRightWithTwoFlankTrialManager();
trialManager = setCalibrationFrame(trialManager,1);
trialManager = setCalibrationMethod(trialManager, 'sweepAllPhasesPerTargetOrientation');
trialManager = setCalibrationModeOn(trialManager, 1);

doCalibration(trialManager)




%% Linearize Screen with homogenous patch
newHomogenousCalibration = 0;
if newHomogenousCalibration
    trialManager = setTypeOfLUT(trialManager, 'calibrateNow');  %linearizedDefault
    plotOn = 1;
    trialManager = fillLUT(trialManager,'calibrateNow',linearizedRange,plotOn);  
else
    trialManager = setTypeOfLUT(trialManager, 'linearizedDefault');  
    plotOn = 0;
    trialManager = fillLUT(trialManager,'linearizedDefault',[0 1],plotOn); 
end
%% Make all the stim frames % Updated and added selectStimulatorParameters,


% set some perameters so that we can use calcStim
trialManager=trialManager;
trialManagerClass=class(trialManager);
frameRate=[]%-99;
responsePorts=[1 3];
totalPorts=[]%3;
width=maxWidth ;
height=maxHeight;
trialRecords= [];

%this should update, add:
%trialPhase='discriminandum'
%doingCalibration=1
%[trialManager updateTM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance] = calcStim(trialManager,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);
%im=out(:,:,2); %make sure calibrate mode passes out one image, not a video


calibrationMethod ='sweepAllPhasesPerTargetOrientation';
trialManager = setCalibrationMethod(trialManager, calibrationMethod);
setCalibrationModeOn(trialManager, 1);
totalFrames = findTotalCalibrationFrames(trialManager);
calibrationMovie = zeros(height, width, 3 , totalFrames, 'uint8');

%%%%%%% FOR CREATING 'calibrationMovie' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:1:totalFrames
    trialManager = setCalibrationFrame(trialManager,i);
    [trialManager updateTM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance] = calcStim(trialManager,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);
    calibrationMovie(:, :, :,i)=repmat( out(:, :, 2), [1, 1, 3]);
end
blackWhite =1;
if blackWhite
    totalFrames = totalFrames + 2;
    blackFrame = zeros(height, width, 3);
    whiteFrame = 255.*ones(height, width, 3);
    calibrationMovie(:, :, :, end + 1) = blackFrame;
    calibrationMovie(:, :, :, end + 1) = whiteFrame;
end
%%%%%%% FOR CREATING 'calibrationMovie' END %%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% CURRENT METHOD FOR CALCULATING positionFrame %%%%%%%%%
%old code centered
positionFrame = zeros(height, width, 'uint8');
if 0
    [leftRight, topDown] = meshgrid( -width/2:1:width/2-1, -height/2:1:height/2-1);
    [locationBOTTOM] = ((topDown == round(leftRight*tan(pi/6)) | topDown == round(-leftRight*tan(pi/6))) & (topDown > 0));
    [locationTOP] = ((leftRight == 0)& (topDown < 0));
    positionFrame(locationBOTTOM | locationTOP) = 255;
end

%new code general
xPos=0.5;
yPos=0.5;
pixFromLeft=round(xPos*width);  % round or floor or ceil?  test fraction with 1/3 of a pixel and 2/3 and 0.5...
pixFromRight=round((1-xPos)*width);
pixFromTop=round(yPos*height);
pixFromBottom=round((1-yPos)*height);
[leftRight, topDown] = meshgrid( -pixFromLeft:pixFromRight-1, -pixFromTop:pixFromBottom-1);
[locationBOTTOM] = ((topDown == round(leftRight*tan(pi/6)) | topDown == round(-leftRight*tan(pi/6))) & (topDown > 0));
[locationTOP] = ((-0.5 <= leftRight & leftRight <= 0.5)& (topDown < 0));
positionFrame(locationBOTTOM | locationTOP) = 255;

%oneline:
%positionFrame(((topDown == round(leftRight*tan(pi/6)) | topDown == round(-leftRight*tan(pi/6))) & (topDown > 0)) | ((-0.5 <= leftRight & leftRight <= 0.5)& (topDown < 0)))=255;

% %%%%%%% FOR MEASURING SCREEN-TO-SOFTWARE SIZE %%%%%%%
%
% positionFrame = zeros(height, width, 'uint8');
% distance = 100;
% positionFrame(round(height/2)- distance: round(height/2) + distance, round(width/2)-distance: round(width/2) + distance) = 255;
% %imshow(positionFrame)
% Screen('Preference', 'SkipSyncTests',1);
% [window winRect]=Screen('OpenWindow',2);
% texture = Screen('MakeTexture',window,positionFrame);
% Screen('DrawTexture', window, texture);
%
% %Screen('Flip',window);
% display('measure screen pixels, press a key when done');
%         while 1
%             [ keyIsDown, seconds, keyCode ] = KbCheck;
%             pause(0.01);
%             if keyIsDown
%                 break
%             end
%         end
% Screen('Close', window);

%%%%%%% FOR MEASURING SCREEN-TO-SOFTWARE SIZE END %%%%%%%

%% Show it to the Spyder

% generateScreenCalibrationData([],[0 0 .3 .3],int8(10),int8(10),repmat(linspace(0,1,2^8)',1,3),uint8(8),uint8(round(2^8/2)*ones(1,1,3)),uint8(rand(1000)*(2^8-1)),'B888',int8(1),false,false);
% generateScreenCalibrationData([],[],[],[],[],[],[],[],'B888',[],false,false);
% vals=generateScreenCalibrationData([],[],int8(10),int8(0),[],[],[],[],'B888',[],true,true);

sensorMode = 'daq'; % 'spyder' is the other option
calibrationPhase='homogenousIntensity'; % 'patterenedIntensity'
screenNum=[];
screenType = 'CRT';
patchRect=[0 0 1 1];
numFramesPerValue=int8(30);
numInterValueFrames=int8(30);
clut=repmat(linspace(0,1,2^8)',1,3);
%clutBits=uint8(1);% will sample low, middle, and high
%clutBits=[];% will sample low, middle, and high
stim = calibrationMovie;
interValueRGB= uint8(zeros(1,1,3));%uint8(round(2^8/2)*ones(1,1,3));
background=[];
parallelPortAddress='B888';
framePulseCode=int8(1);
[luminanceData, details] = getScreenCalibrationData(trialManager, sensorMode, calibrationPhase, screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,stim,positionFrame, interValueRGB,background,parallelPortAddress,framePulseCode);
%%

% switch sensorMode
%     case 'spyder'
%         spyderData = zeros(totalFrames, 3, numRepeats);
%         for i = 1:numRepeats
%             if i > 1
%                 positionFrame = [];
%             end
%             spyderData(:, :, i) =generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,calibrationMovie,positionFrame,interValueRGB,background,parallelPortAddress,framePulseCode,useSpyder,doDaq);
%         end
%
%         % luminance is the Y value, which is the second entry in spyderData; %[xyY] = XYZToxyY(spyderData')'
%         luminanceData = reshape(spyderData( :, 2, : ), totalFrames, numRepeats);
%
%     case 'daq'

daqData = zeros(totalFrames, numRepeats);

daqPath = '\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\daqXfer\Calibration'; % need to pass the daqPath
    %%[junk, daqData] =generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,calibrationMovie,positionFrame,interValueRGB,background,parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath);
    %[junk, daqData] =generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,calibrationMovie,positionFrame,interValueRGB,background,parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath);
     %%
%%% Tells Daq to start %%%%%%%
go=1; 
calibrationDone = 0;
thisStimRunning = 0;
doingQualityCheck = 0;
save(fullfile(daqPath, 'command.mat'), 'doingQualityCheck','thisStimRunning', 'calibrationDone', 'go');                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
commandReturn = load(fullfile(daqPath,'commandReturn.mat'));

for i = 1:numRepeats
%%%%%%%% sets command.thisStimRunning ==1 %%%%%
    thisStimRunning = 1;
    save(fullfile(daqPath, 'command.mat'), 'doingQualityCheck','thisStimRunning', 'calibrationDone', 'go');
    pause(1);
%%%%%%% waits for commandReturn.isRecording ==1  
    waitingForRecording=1;
    while waitingForRecording  
        commandReturn = load(fullfile(daqPath,'commandReturn.mat'))  
        display('waiting for commandReturn.isRecording == 1');
        if commandReturn.isRecording==1
            waitingForRecording=0;
        else
            pause(1);
        end   
    end
    
%%%%%%% now generate calibration data %%%%%%%%%%
    
    if i > 1
            positionFrame = [];
    end

    [junk, daqDataJunk, ifi] =generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,calibrationMovie,positionFrame,interValueRGB,background,parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath);
      %%  [junk, daqData] =generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,[],[],interValueRGB,[],parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath);
%%%%%%% resets command.thisStimRunning == 0 %%%%%%
        thisStimRunning = 0;
        save(fullfile(daqPath, 'command.mat'), 'doingQualityCheck','thisStimRunning', 'calibrationDone', 'go'); 
        pause(1);
              
%%%%%%% waits for commandReturn.isRecording == 0 %%%%%
    waitingForRecordingToEnd=1;
    while waitingForRecordingToEnd == 1  
        commandReturn = load(fullfile(daqPath,'commandReturn.mat'))  
        display('waiting for isRecording == 0');
        if commandReturn.isRecording==0
            waitingForRecordingToEnd=0;
        else
            pause(1);
        end   
    end
    
    
    
        %say if calibration is done

        recordingFile = fullfile(daqPath, sprintf('calibrationData-%d.daq', i));
        [fullDaqData,time,abstime,events,daqinfo] = daqread(recordingFile);
        
        [daqData(:,i), rawFirstFrame] = calculateIntensityPerFrame(fullDaqData, 'integral', daqinfo.ObjInfo.SampleRate, ifi, numFramesPerValue);       
        fullDaqData = [];
        goodEnough = qualityCheck(trialManager, daqData);
        
        
 %%%%%% sets command.calibrationDone == 1 if last stim round %%%%%%%%%%
    if i == numRepeats 
        calibrationDone = 1;
        doingQualityCheck = 0;
        save(fullfile(daqPath, 'command.mat'), 'doingQualityCheck','thisStimRunning', 'calibrationDone', 'go'); 
        pause(1);
    else
        calibrationDone = 0;
        doingQualityCheck = 1;
        save(fullfile(daqPath, 'command.mat'), 'doingQualityCheck','thisStimRunning', 'calibrationDone', 'go'); 
        pause(1);
    end
%         thisStimRunning = 1;
%         save(fullfile(daqPath, 'command.mat'), 'thisStimRunning', 'calibrationDone', 'go');
end

luminanceData = daqData;


%% Get contrast

[amplitudes, SNR] = getAmplitudeOfLuminanceData(trialManager, luminanceData, 1);

dimmestInd= find(amplitudes == min(amplitudes));  % should be the dimmest thing
contrast = amplitudes(dimmestInd)./amplitudes; % multiplying by this will creat a reduction of contrast per orientation that should achieve iso-contrast for your sensor

%% Validate
spyderData = zeros(totalFrames, 3, numRepeats);
for i = 1:numRepeats
    if i > 1
        positionFrame = [];
    end
    spyderData(:, :, i) =generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,calibrationMovie,positionFrame,interValueRGB,background,parallelPortAddress,framePulseCode,useSpyder,doDaq);
end

validationData = reshape(spyderData( :, 2, : ), totalFrames, numRepeats);

[amplitudes, SNR] = getAmplitudeOfLuminanceData(trialManager, luminanceData, 1);

dimmestInd= find(amplitudes == min(amplitudes));  % should be the dimmest thing
contrast = amplitudes(dimmestInd)./amplitudes; % multiplying by this will creat a reduction of contrast per orientation that should achieve iso-contrast for your sensor

% %% Get all the data
%
% setCalibrationMethod='sweepAllPhasesPerFlankTargetContext';
%
% totalFrames=findTotalCalibrationFrames(trialManager);
% for i=1:totalFrames
%     setCalibrationFrame(trialManager,i);
%     [trialManager updateTM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance] = calcStim(trialManager,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);
%     im=out(:,:,2);
%
% %     [spyderData(i)]=generateScreenCalibrationData(screenNum,patchRect,numFramesPerValue,numInterValueFrames,clut,clutBits,interValueRGB,background,parallelPortAddress,framePulseCode,useSpyder,doDaq)
% end


%%
if 0
    stim =  cuedIfFeatureGoRightWithTwoFlank(pixPerCycs,goRightOrientations,goLeftOrientations,flankerOrientations,topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,goRightContrast,goLeftContrast,flankerContrast,distractorContrast,meanLum,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,toggleStim,typeOfLUT,rangeOfMonitorLinearized,maxCorrectOnSameSide,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
    increasingReward=rewardNcorrectInARow(rewardNthCorrect,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar);
    nafc=nAFC(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sndManager,...
        msPenalty,requestRewardSizeULorMS,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
        maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration,increasingReward)
end