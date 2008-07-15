% This code should be intergrated into the trialManager.calibrate

function trialManager = doCalibration(trialManager,newHomogenousCalibration, screenType, skipSyncTest)

if ~exist('screenType', 'var')
    screenType = 'CRT';
elseif isempty(screenType)
    screenType = 'CRT';
end

if ~exist('skipSyncTest', 'var')
    skipSyncTest = 0;
elseif isempty(skipSyncTest)
    skipSyncTest = 0;
end

if ~exist('newHomogenousCalibration', 'var')
    newHomogenousCalibration = 0;
elseif isempty(newHomogenousCalibration)
    newHomogenousCalibration = 0;
end
%% Linearize Screen with homogenous patch

if newHomogenousCalibration
    trialManager = setTypeOfLUT(trialManager, 'calibrateNow');  %linearizedDefault
    plotOn = 0;
    linearizedRange = [0 1];
    trialManager = fillLUT(trialManager,'calibrateNow',linearizedRange,plotOn);


else
    trialManager = setTypeOfLUT(trialManager, 'linearizedDefault');
    plotOn = 0;
    trialManager = fillLUT(trialManager,'linearizedDefault',[0 1],plotOn);
end

%% Pattern Calibration

% set some parameters so that we can use calcStim
trialManager=trialManager;
trialManagerClass=class(trialManager);
% frameRate=[];%-99;
ifi = [];
responsePorts=[1 3];
targetPorts = 3;
totalPorts=[];%3;
width=trialManager.maxWidth ;
% width
height=trialManager.maxHeight;
% height
trialRecords=[];
%this should update, add:
%trialPhase='discriminandum'
%doingCalibration=1
%[trialManager updateTM out LUT scaleFactor type targetPorts distractorPorts details interTrialLuminance] = calcStim(trialManager,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);
%im=out(:,:,2); %make sure calibrate mode passes out one image, not a video

%create calibrationMovie
setCalibrationModeOn(trialManager, 1);

totalFrames = findTotalCalibrationFrames(trialManager);
totalFrames
numOrientations = size(trialManager.calib.orientations,2);
trialManager.calib.contrastScale=ones(1,numOrientations);  %set to one to measure
trialManager=inflate(trialManager);

numBatches = getNumCalibrationBatches(trialManager);

for batch = 1:numBatches
    disp(sprintf('****** Calibrating Batch %d ******', batch));
    [frameIndices] = getNumFramesNextCalibrationBatch(trialManager, batch);
    framesThisBatch = size(frameIndices,2);

    calibrationMovie = zeros(height, width, 3 , framesThisBatch, 'uint8');

    for i=1:framesThisBatch
        trialManager = setCalibrationFrame(trialManager,frameIndices(i)); % setting the frame index for calibration [1:totalFrames]
        %[trialManager updateTM out LUT scaleFactor type targetPorts distractorPorts frameDetails{frameIndices(i)} interTrialLuminance] = calcStim(trialManager,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);
%        calibrationMovie(:, :, :,i)=repmat( out(:, :, 2), [1, 1, 3]);
        [trialManager updateTM frameDetails{frameIndices(i)} stimSpec targetPorts  details] = calcStimBeta(trialManager,ifi,targetPorts,responsePorts,width,height,trialRecords);
        stimDetails = frameDetails{frameIndices(i)};
        calibrationMovie(:, :, :,i)=repmat( stimDetails.discriminandumStim.stim{1}, [1, 1, 3]);
    end
    %     blackWhite =0;
    %     if blackWhite
    %         totalFrames = totalFrames + 2;
    %         blackFrame = zeros(height, width, 3);
    %         whiteFrame = 255.*ones(height, width, 3);
    %         calibrationMovie(:, :, :, end + 1) = blackFrame;
    %         calibrationMovie(:, :, :, end + 1) = whiteFrame;
    %     end

    %create positionFrame
    positionFrame=getCalibrationPositionFrame( trialManager );
    if batch > 1
        positionFrame = [];
    end
    % get sensor data
    sensorMode = 'daq'; % 'spyder' is the other option ... passed in
    calibrationPhase= 'patterenedIntensity';
    %calibrationPhase = 'homogenousIntensity';
    screenNum=0;
    screenType = screenType;
    patchRect=[0 0 1 1];
    numFramesPerValue=int8(100);
    numInterValueFrames=int8(15);
    clut=repmat(linspace(0,1,2^8)',1,3);
    stim = calibrationMovie;
    interValueRGB= uint8(zeros(1,1,3));%uint8(round(2^8/2)*ones(1,1,3));
    background=[];
    parallelPortAddress='B888';
    framePulseCode=int8(1);

    %%%%% making sure the recordScreenCalibrationData function is running %%%%%%
    daqPath = '\\reinagel-lab.ad.ucsd.edu\rlab\Rodent-Data\daqXfer\Calibration'; % need to pass the daqPath
    if batch == 1
        daqInitialization(daqPath);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [thisLuminanceData, details] = getScreenCalibrationData(trialManager, sensorMode, calibrationPhase, screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,stim,positionFrame, interValueRGB,background,parallelPortAddress,framePulseCode, skipSyncTest, batch);

    % insert this data into the larger matrix
    lumWidth = size(thisLuminanceData, 2);
    luminanceData(frameIndices, 1:size(thisLuminanceData, 2)) = thisLuminanceData;

    % this puts NaN's into all newly generated matrix positions (rather than
    % matlab's default of zero)
    if size(luminanceData > lumWidth)
        whichNew = zeros(size(luminanceData));
        whichNew(:, lumWidth+1:end) = 1;
        whichNew(frameIndices, 1:size(thisLuminanceData, 2)) = 0;
        luminanceData(whichNew ==1) = NaN;
    end
    %%%%%%%%%%%%%%% Adding the call to addToLumStruct - yuan %%%%%%%%%%%%%%%%%%%%%%%%%
    if ~exist('fLum', 'var')
        fLum = [];
    end

    fLum = addToLumStruct(trialManager, fLum, frameDetails, frameIndices, thisLuminanceData)

    batch
    numBatches
end

fContrast = makeContrastStruct(trialManager, fLum)


luminanceData
batch = [];
% interpret data
size(luminanceData)
contrastMethod='std'; %'peakToPeak'
plotOn=0;
[amplitudes, SNR] = getAmplitudeOfLuminanceData(trialManager, luminanceData, contrastMethod, batch, plotOn)
dimmestInd= find(amplitudes == min(amplitudes));  % should be the dimmest thing
contrast = amplitudes(dimmestInd)./amplitudes % multiplying by this will creat a reduction of contrast per orientation that should achieve iso-contrast for your sensor


% store relevant data in trialManager
trialManager.calib.rawData=luminanceData;
trialManager.calib.interpretedData.contrastMethod=contrastMethod;
trialManager.calib.interpretedData.amplitudes=amplitudes;
trialManager.calib.interpretedData.SNR=SNR;

%useable data - where does it go?
trialManager.calib.contrastScale=contrast;
trialManager=deflate(trialManager);
trialManager=inflate(trialManager,1); % with new contrastScale!

prevMovie=calibrationMovie;
%create a new calibrationMovie
setCalibrationModeOn(trialManager, 1);
totalFrames = findTotalCalibrationFrames(trialManager);
calibrationMovie = zeros(height, width, 3 , totalFrames, 'uint8');

if 0 % to be fixed later with a function doValidation
for i=1:1:totalFrames
        trialManager = setCalibrationFrame(trialManager,frameIndices(i)); % setting the frame index for calibration [1:totalFrames]
        %[trialManager updateTM out LUT scaleFactor type targetPorts distractorPorts frameDetails{frameIndices(i)} interTrialLuminance] = calcStim(trialManager,trialManagerClass,frameRate,responsePorts,totalPorts,width,height,trialRecords);
%        calibrationMovie(:, :, :,i)=repmat( out(:, :, 2), [1, 1, 3]);
        [trialManager updateTM frameDetails{frameIndices(i)} stimSpec targetPorts  details] = calcStimBeta(trialManager,ifi,targetPorts,responsePorts,width,height,trialRecords)
        calibrationMovie(:, :, :,i)=repmat( stimDetails.discriminandumStim.stim{1}, [1, 1, 3]);
end
end
%do it again
stim = calibrationMovie;
positionFrame=[];
[luminanceDataValidation, details] = getScreenCalibrationData(trialManager, sensorMode, calibrationPhase, screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,stim,positionFrame, interValueRGB,background,parallelPortAddress,framePulseCode, skipSyncTest, batch);
%%%%%%%%%%%%%%%%%%%%%%%%%
daqFinish(daqPath); %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
plotOn = 0;
[validationAmplitudes, validationSNR] = getAmplitudeOfLuminanceData(trialManager, luminanceDataValidation, contrastMethod, batch, plotOn);
dimmestInd= find(validationAmplitudes == min(validationAmplitudes));
contrast = validationAmplitudes(dimmestInd)./validationAmplitudes;
validationFractionalError=1-contrast;

% store relevant data in trialManager
trialManager.calib.rawValidationData=luminanceDataValidation;
trialManager.calib.interpretedData.validationAmplitudes=validationAmplitudes;
trialManager.calib.interpretedData.validationSNR=validationSNR;
trialManager.calib.interpretedData.validationFractionalError=validationFractionalError;

function daqInitialization(daqPath)
complete = 0;
save(fullfile(daqPath, 'processComplete.mat'), 'complete');
inputdlg('please start recordScreenCalibrationData.m', 'ok');


function daqFinish(daqPath)
complete = 1;
save(fullfile(daqPath, 'processComplete.mat'), 'complete');

