
%% init

if 1
    screen clear all; clear classes; close all
    clc; format short g
end

cd ('C:\Documents and Settings\rlab\Desktop\merge20080324\bootstrap')
setupEnvironment
ListenChar(1)
rootPath=getRatrixPath;
addpath(genpath([fullfile(rootPath,'advancedCalibration')]))

soundOn = 1;

%% addPaths
%warning('off','MATLAB:dispatcher:nameConflict')
%addpath(genpath([fullfile(rootPath,'classes')]))
%pathSep='\'; %old
%addpath(genpath([rootPath 'Server' pathSep]))% Everything in the ratrix 
%addpath(genpath(['C:\pmeier\newStimTest\']))% A few extra things in this project
%warning('on','MATLAB:dispatcher:nameConflict')

[parameterStructure, super] = getDefaultParameters(ifFeatureGoRightWithTwoFlankTrialManager);

trialManager =  ifFeatureGoRightWithTwoFlankTrialManager(parameterStructure,super);

%trialManager =  ifFeatureGoRightWithTwoFlankTrialManager(pixPerCycs,goRightOrientations,goLeftOrientations,flankerOrientations,topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,goRightContrast,goLeftContrast,flankerContrast,meanLum,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,toggleStim,typeOfLUT,rangeOfMonitorLinearized,maxCorrectOnSameSide,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
%trialManager =  ifFeatureGoRightWithTwoFlankTrialManager();
stimManager = ifFeatureGoRightWithTwoFlank(); %just to test it's not broken
trialManager = setCalibrationFrame(trialManager,1);
trialManager = setCalibrationMethod(trialManager, 'sweepAllPhasesPerTargetOrientation');

errorCheck(trialManager);
ifi=1/85;
targetPorts=[3];
responsePorts=[1:3];
width=1024;
height=768;
trialRecords=[];
[t updateTM stimDetails stimSpec targetPorts details] = calcStimBeta(trialManager,ifi,targetPorts,responsePorts,width,height,trialRecords);

stimDetails.targetOrientation
stimDetails.targetPhase

figure(1); colormap(gray);
subplot(2, 3, 1); imagesc(stimDetails.interSessionStim.stim,[0 255]); title('interSessionStim')
subplot(2, 3, 2); imagesc(stimDetails.interTrialStim.stim,[0 255]); title('interTrialStim')
subplot(2, 3, 3); imagesc(stimDetails.discriminandumStim.stim{1},[0 255]); title('discriminandumStim')
subplot(2, 3, 4); imagesc(stimDetails.penaltyStim.stim(:,:,2),[0 255]); title('penaltyStim')
subplot(2, 3, 5); imagesc(stimDetails.rewardStim.stim(:,:,2),[0 255]); title('rewardStim')
subplot(2, 3, 6); imagesc(stimDetails.finalStim.stim,[0 255]); title('finalStim')

%% ptb loop

testLoop = 1;
if testLoop

    try
        screens=Screen('Screens');
        screenNumber=max(screens);
        [w screenRect]=Screen('OpenWindow',screenNumber, 0,[],32,2)
   
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);

        phase = 'discriminandum';
        eyeRecords = [];
        RFestimate = [];
        numTrials = 10;
        numFrames = 25;
        parameterStructure.renderMode='directPTB';
        t = ifFeatureGoRightWithTwoFlankTrialManager(parameterStructure,super);
        t = inflate(t);
        
        
        vbl = zeros(1, numFrames);

        for trial = 1:numTrials
            targetPorts = 1+ 2*(rand>0.5);
            beep;
            [t updateTM stimDetails stimSpec targetPorts details] = calcStimBeta(t,ifi,targetPorts,responsePorts,width,height,trialRecords);
            beep;
            
            startTrialTime = now;
            for frame = 1:numFrames
                timeSinceTrial = now - startTrialTime;
                %[stimDetails frameRecords]=doDynamicPTBFrame(t,phase,stimDetails,frame,timeSinceTrial,eyeRecords, RFestimate, w);
                 [stimDetails frameRecords]=doUniqueRepeatDriftFrame(t,phase,stimDetails,frame,timeSinceTrial,eyeRecords, RFestimate, w);
                
                vbl(frame,trial) = Screen('Flip', w);
            end
        end
        
        hz=Screen('FrameRate', w);
        ifi= Screen('GetFlipInterval',w);
 
        
        % done
        sca
        Priority(0);
        ShowCursor;
    catch ex
        sca
        Priority(0);
        ShowCursor;
        err=ex
        err.stack.line
        err.stack.name
        err.stack.file
        rethrow(ex);
    end

    relativeTime = vbl(:) - vbl(1);
    figure;
    hist(diff(relativeTime)/ifi);
    

end
%%
if 0 % the main calibration
skipSyncTest = 1; % problem in single header mode FE992, 1024x768, 85 Hz, ATI gfx
n = 2;
trialManager = setTargetOrientation(trialManager, [(0: n-1)*(pi/n)], 0); % t=setTargetOrientation(t, orientations, updateNow)
trialManager = setPixPerCycle(trialManager, 32);
trialManager = doCalibration(trialManager, 0, [],skipSyncTest);
seeCalibrationResults(trialManager);
c = getCalibration(trialManager)
c.interpretedData
end

if 0
    i = 1;
    c{i} = getCalibration(trialManager)
    % made Spatial Frequency Smaller
    trialManager = setPixPerCycle(trialManager, 32);
    im = getStimPatch(trialManager, 'target');
    imagesc(im(:, :, 1,1))
    trialManager = doCalibration(trialManager)
    i = i+1; 
    c{i} = getCalibration(trialManager)

    % added on Felt
    trialManager = doCalibration(trialManager)
    i = i+1;
    c{i} = getCalibration(trialManager)

    % rotated photo diode
    trialManager = doCalibration(trialManager)
    i = i+1;
    c{i} = getCalibration(trialManager)
    % bumpted photo diode
    trialManager = doCalibration(trialManager)
    i = i+1;
    c{i} = getCalibration(trialManager)
end

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

if 0

    % set some perameters so that we can use calcStim
    trialManager=trialManager;
    trialManagerClass=class(trialManager);
    frameRate=[]%-99;
    responsePorts=[1 3];
    totalPorts=[]%3;
    width=maxWidth ;
    height=maxHeight;
    displaySize=[]; % to fix 1/8/09
    LUTbits=[]; % to fix 1/8/09
    resolutions=[]; % to fix 1/8/09
    trialRecords= [];

    %this should update, add:
    %trialPhase='discriminandum'
    %doingCalibration=1
    %[trialManager updateTM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance] = calcStim(trialManager,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);
    %im=out(:,:,2); %make sure calibrate mode passes out one image, not a video

    setCalibrationModeOn(trialManager, 1);
    totalFrames = findTotalCalibrationFrames(trialManager);
    calibrationMovie = zeros(height, width, 3 , totalFrames, 'uint8');

    %%%%%%% FOR CREATING 'calibrationMovie' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for i=1:1:totalFrames
        trialManager = setCalibrationFrame(trialManager,i);
        [trialManager updateTM resInd out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance text] =...
            calcStim(trialManager,trialManagerClass,resolutions,displaySize,LUTbits,responsePorts,totalPorts,trialRecords);
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

end
%%%%%%% FOR CREATING 'calibrationMovie' END %%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% CURRENT METHOD FOR CALCULATING positionFrame %%%%%%%%%

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





%%
if 0
    stim =  cuedIfFeatureGoRightWithTwoFlank(pixPerCycs,goRightOrientations,goLeftOrientations,flankerOrientations,topYokedToBottomFlankerOrientation,topYokedToBottomFlankerContrast,goRightContrast,goLeftContrast,flankerContrast,distractorContrast,meanLum,cueLum,cueSize,xPositionPercent,cuePercentTargetEcc,stdGaussMask,flankerOffset,framesJustFlanker,framesTargetOn,thresh,yPositionPercent,toggleStim,typeOfLUT,rangeOfMonitorLinearized,maxCorrectOnSameSide,maxWidth,maxHeight,scaleFactor,interTrialLuminance);
    increasingReward=rewardNcorrectInARow(rewardNthCorrect,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar);
    nafc=nAFC(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,sndManager,...
        msPenalty,requestRewardSizeULorMS,percentCorrectionTrials,msResponseTimeLimit,pokeToRequestStim,...
        maintainPokeToMaintainStim,msMaximumStimPresentationDuration,maximumNumberStimPresentations,doMask,msRewardSoundDuration,increasingReward)
end