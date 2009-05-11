function [rawValues measuredValues currentCLUT linearizedCLUT validationValues] = calibrateMonitor(rawValues,method,writeToOracle)
% this function runs a calibration routine to get a linearized CLUT to correct for monitor's nonlinearity
% we do this by drawing the rawValues on screen, then measuring the xyz luminance output using spyder/photodiode.
% these xyz measurements can then be used to backcalculate a nonlinear transform that when applied, cancels out
% the monitor's nonlinearity. the result is the linearizedCLUT, which is finally used to validate that the output luminance
% is indeed linear.
%
% INPUTS: 
%   rawValues - the native 0-255 RGB values used to get our first set of xyz measurements; should be [1 1 3 numStims] in size
%   method - what method to use..?
%   writeToOracle - flag to write the outputs to oracle CLUTS table
% OUTPUTS:
%   rawValues - the native 0-255 RGB values (not changed)
%   measuredValues - xyz measurements corresponding to rawValues with native gamma
%   linearizedCLUT - direct inversion normalized LUT entry (interp1 w/linear) 
%   validationValues - xyz measurements corresponding to rawValues with linearizedCLUT

% error check inputs
if ~ischar(method)
    error('method must be a string');
else
    if strcmp(method,'standardCRT') || strcmp(method,'standardLCD')
        %pass
    else
        error('method must be ''standardCRT'' or ''standardLCD''');
    end
end
if islogical(writeToOracle)
    %pass
else
    error('writeToOracle must be a logical');
end


screenNum=max(Screen('Screens'));
% get current CLUT from screen
[currentCLUT, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', screenNum);
% set some default parameters based on method
switch method
    case 'standardCRT'
        screenType='CRT';
        patchRect=[.2 .2 .8 .8]; % normalized [left top right bottom]
        numFramesPerValue=uint16(300); % number of frames to hold each RGB-triple of the stim (rawValues)
        numInterValueFrames=uint16(1); % number of frames to show the interValueRGB-triple between each stim triple
        interValueRGB=uint8(ones(1,1,3));
        
        height=768;
        width=1024;
        positionFrame=getDefaultPositionFrame(width,height);
        background=uint8(1);
        parallelPortAddress=[]; % doesnt matter b/c we arent using daq
        framePulseCode=[]; % doesnt matter b/c we arent using daq
        useSpyder=true;
        doDaq=false;
        daqPath=[];
        daqPlot=false;
        skipSyncTest=false;
        
    case 'standardLCD'
        screenType='LCD';
        patchRect=[.2 .2 .8 .8]; % normalized [left top right bottom]
        numFramesPerValue=uint16(300); % number of frames to hold each RGB-triple of the stim (rawValues)
        numInterValueFrames=uint16(100); % number of frames to show the interValueRGB-triple between each stim triple
        interValueRGB=uint8(255*ones(1,1,3));
        
        height=768;
        width=1024;
        positionFrame=getDefaultPositionFrame(width,height);
        background=uint8(128); % gray background
        parallelPortAddress=[]; % doesnt matter b/c we arent using daq
        framePulseCode=[]; % doesnt matter b/c we arent using daq
        useSpyder=true;
        doDaq=false;
        daqPath=[];
        daqPlot=false;
        skipSyncTest=false;
        
    otherwise
        error('unsupported method');
end

[spyderValues]=...
    generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,...
    numInterValueFrames,currentCLUT,rawValues,positionFrame,interValueRGB,background,...
    parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath, daqPlot, skipSyncTest);
measuredValues=spyderValues(:,2,:)';
% now do something to compute linearizedCLUT
linearizedCLUT=zeros(reallutsize,3);
measuredRange=[min(measuredValues(:)) max(measuredValues(:))]; % measuredRange is min,max of the Y value

% R values
rawInds=squeeze(rawValues(:,:,1,:));
raws=currentCLUT(uint16(rawInds)+1,1)';
rawRange=[min(raws) max(raws)];
[linearizedCLUT(:,1) g.R]=fitGammaAndReturnLinearized(raws,measuredValues,[0 1],...
    measuredRange,rawRange,reallutsize,false);
% G values
rawInds=squeeze(rawValues(:,:,2,:));
raws=currentCLUT(uint16(rawInds)+1,2)';
rawRange=[min(raws) max(raws)];
[linearizedCLUT(:,2) g.G]=fitGammaAndReturnLinearized(raws,measuredValues,[0 1],...
    measuredRange,rawRange,reallutsize,false);
% B values
rawInds=squeeze(rawValues(:,:,3,:));
raws=currentCLUT(uint16(rawInds)+1,3)';
rawRange=[min(raws) max(raws)];
[linearizedCLUT(:,3) g.B]=fitGammaAndReturnLinearized(raws,measuredValues,[0 1],...
    measuredRange,rawRange,reallutsize,false);

% recall generateScreenCalibrationData w/ new linearized CLUT and get validation data
try
Screen('LoadNormalizedGammaTable', screenNum,linearizedCLUT);
catch
    sca
    keyboard
end
positionFrame=[]; % no need to redo positionFrame (spyder device should already be attached)
[validationValues]=...
    generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,...
    numInterValueFrames,linearizedCLUT,rawValues,positionFrame,interValueRGB,background,...
    parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath, daqPlot, skipSyncTest);


% restore original CLUT
Screen('LoadNormalizedGammaTable',screenNum,currentCLUT);
end % end function