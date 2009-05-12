function [rawValues measuredValues currentCLUT linearizedCLUT validationValues] = ...
    calibrateMonitor(rawValues,monitorType,fitMethod,writeToOracle)
% this function runs a calibration routine to get a linearized CLUT to correct for monitor's nonlinearity
% we do this by drawing the rawValues on screen, then measuring the xyz luminance output using spyder/photodiode.
% these xyz measurements can then be used to backcalculate a nonlinear transform that when applied, cancels out
% the monitor's nonlinearity. the result is the linearizedCLUT, which is finally used to validate that the output luminance
% is indeed linear.
%
% INPUTS: 
%   rawValues - the native 0-255 RGB values used to get our first set of xyz measurements; should be [1 1 3 numStims] in size
%   monitorType - what monitorType to use..?
%   fitMethod - what method to use to generate our linearized CLUT ('linear', 'power')
%   writeToOracle - flag to write the outputs to oracle CLUTS table
% OUTPUTS:
%   rawValues - the native 0-255 RGB values (not changed)
%   measuredValues - xyz measurements corresponding to rawValues with native gamma
%   linearizedCLUT - direct inversion normalized LUT entry (interp1 w/linear) 
%   validationValues - xyz measurements corresponding to rawValues with linearizedCLUT

% error check inputs
if ~ischar(monitorType)
    error('monitorType must be a string');
else
    if strcmp(monitorType,'standardCRT') || strcmp(monitorType,'standardLCD')
        %pass
    else
        error('monitorType must be ''standardCRT'' or ''standardLCD''');
    end
end
if ischar(fitType) && ismember(fitType,{'linear','power'})
   % pass
else
    error('fitType must be ''linear'' or ''power''');
end
if islogical(writeToOracle)
    %pass
else
    error('writeToOracle must be a logical');
end
% raw RGB values need to be monotonically increasing
if all(squeeze(diff(rawValues(:,:,1,:)))>=0) && all(squeeze(diff(rawValues(:,:,2,:)))>=0) && all(squeeze(diff(rawValues(:,:,3,:)))>=0)
    %pass
else
    error('RGB values must be monotonically increasing');
end


screenNum=max(Screen('Screens'));
% get current CLUT from screen
[currentCLUT, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', screenNum);
% set some default parameters based on monitorType
switch monitorType
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
        error('unsupported monitorType');
end

[spyderValues]=...
    generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,...
    numInterValueFrames,currentCLUT,rawValues,positionFrame,interValueRGB,background,...
    parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath, daqPlot, skipSyncTest);
measuredValues=spyderValues(:,2,:)';
% now do something to compute linearizedCLUT
linearizedCLUT=zeros(reallutsize,3);

switch fitMethod
    case 'linear'
        % R values
        rawInds=squeeze(rawValues(:,:,1,:));
        raws=currentCLUT(uint16(rawInds)+1,1)';
        desiredVals=linspace(measuredValues(1),measuredValues(end),reallutsize);
        linearizedCLUT(:,1) = interp1(measuredValues,raws,desiredVals,'linear')'/raws(end); %consider pchip
        % G values
        rawInds=squeeze(rawValues(:,:,2,:));
        raws=currentCLUT(uint16(rawInds)+1,2)';
        desiredVals=linspace(measuredValues(1),measuredValues(end),reallutsize);
        linearizedCLUT(:,2) = interp1(measuredValues,raws,desiredVals,'linear')'/raws(end); %consider pchip
        % B values
        rawInds=squeeze(rawValues(:,:,3,:));
        raws=currentCLUT(uint16(rawInds)+1,3)';
        desiredVals=linspace(measuredValues(1),measuredValues(end),reallutsize);
        linearizedCLUT(:,3) = interp1(measuredValues,raws,desiredVals,'linear')'/raws(end); %consider pchip
    case 'power'
        error('not yet implemented');
    otherwise
        error('unsupported fitMethod');
end

% recall generateScreenCalibrationData w/ new linearized CLUT and get validation data
try
Screen('LoadNormalizedGammaTable', screenNum,linearizedCLUT);
catch ex
    sca
    disp(['CAUGHT EX: ' getReport(ex)]);
    keyboard
end
positionFrame=[]; % no need to redo positionFrame (spyder device should already be attached)
[spyderValues]=...
    generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,...
    numInterValueFrames,linearizedCLUT,rawValues,positionFrame,interValueRGB,background,...
    parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath, daqPlot, skipSyncTest);
validationValues=spyderValues(:,2,:)';

% restore original CLUT
Screen('LoadNormalizedGammaTable',screenNum,currentCLUT);

% put new linearizedCLUT into oracle
if writeToOracle
    try
        conn=dbConn();
        [junk mac]=getMACaddress();
        % HACK
%         mac='0018F35DFAC0';
        % write linearizedCLUT to tempCLUT.mat and read as binary stream
        save('tempCLUT.mat','linearizedCLUT','rawValues','measuredValues','currentCLUT','validationValues');
        fid=fopen('tempCLUT.mat');
        CLUT=fread(fid,'*uint8');
        fclose(fid);
        timestamp=datestr(now,'mm-dd-yyyy HH:MM');
        svnRev=getSVNRevisionFromXML(getRatrixPath);
        cmd='test';
        addCLUTToOracle(CLUT,mac,timestamp,svnRev,cmd)
        closeConn(conn);
    catch ex
        disp(['CAUGHT EX: ' getReport(ex)]);
        error('failed to get open dbConn() - no oracle access');
    end
end


end % end function