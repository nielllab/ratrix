function [measuredR measuredG measuredB currentCLUT linearizedCLUT validationValues details] = ...
    calibrateMonitor(stim,method,mode,screenType,fitMethod,writeToOracle,comment,screenNum)
% this function calls generateScreenCalibrationData to get the measured values and then does a basic
% linearization and validation before inserting into Oracle
% INPUTS: 
%   stim - [1 1 3 n] matrix of RGB values 
%   method - how to do the screen calibration (passed to generateScreenCalibrationData):
%   ie {'stimInBoxOnBackground',background,patchRect,interValueRGB,numFramesPerValue,numInterValueFrames}
    %   background - the background RGB values, specified as indices into the CLUT
    %   patchRect - where to draw the stim on the background
    %   interValueRGB - the RGB values to show between frames of stim, specified as indices into the CLUT
    %   numFramesPerValue - how many frames to hold each frame of the stim
    %   numInterValueFrames - how many frames of interValueRGB to show between each set of frames in stim
%   mode - whether to do RGB, RGBK, or grayscale and also whether to do 8 or 256 samples
    % acceptable values are '8RGB','8RGBK','8gray', and 'custom', in which case we use the stim input
%   screenType - 'LCD' or 'CRT'
%   fitMethod - 'linear' or 'power'
%   writeToOracle - a flag indicating whether or not to write to oracle
%   comment (optional) - the string to store into the oracle field
%   "comment"
%   screenNum (optional) - which screen to draw to
% OUTPUTS:
%   measuredValues - xyz measurements corresponding to rawValues with native gamma
%   currentCLUT - the native CLUT
%   linearizedCLUT - direct inversion normalized LUT entry (interp1 w/linear) 
%   validationValues - xyz measurements corresponding to rawValues with linearizedCLUT
%   details - stuff that might be used to do further validation (and specify how we got our calibration data); to be stored in BLOB

% error check inputs
if ischar(fitMethod) && ismember(fitMethod,{'linear','power'})
   % pass
else
    error('fitMethod must be ''linear'' or ''power''');
end
if islogical(writeToOracle)
    %pass
else
    error('writeToOracle must be a logical');
end
if exist('comment','var') && ~isempty(comment)
    %pass
else
    comment='';
end

if exist('screenNum','var') && ~isempty(screenNum)
    %pass
else
   screenNum=max(Screen('Screens'));
end

if ischar(mode) && ismember(mode,{'8RGB','8RGBK','8gray','256RGB','256RGBK','256gray'})
    % pass
else
    error('mode must be ''8RGB'',''8RGBK'',''8gray'',''256RGB'',''256RGBK'', or ''256gray''');
end

validationValues=[];

% generate calibrationString from the stim draw method, mode, screenType, and fitMethod
calibrationString=[method{1} '_' mode '_' screenType '_' fitMethod];


details=[];
details.method=method;
detailds.mode=mode;
details.fitMethod=fitMethod;
details.screenNum=screenNum;
details.screenType=screenType;
% get current CLUT from screen
% [currentCLUT, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', screenNum);
% just use a linear ramp
currentCLUT=linspace(0,1,256);
currentCLUT=repmat(currentCLUT,[3 1])';
reallutsize=256;

drawSpyderPositionFrame = true; % HACK


% construct stim and call generateScreenCalibrationData as necessary
switch mode
    case {'8gray','256gray'}
        stim=uint8([]);
        if strcmp(mode,'8gray')
            samps=floor(linspace(0,255,8));
        else
            samps=floor(linspace(0,255,256));
        end
        for i=1:length(samps)
            stim(:,:,:,i)=uint8(samps(i)*ones(1,1,3));
        end
        channels=[1 1 1]; % all RGB channels
        % now run using the gray stim
        [measuredR rawR method details.measurementDetails quit] = ...
            generateScreenCalibrationData(method,stim,channels,currentCLUT,drawSpyderPositionFrame,screenNum,screenType);
        if quit
            return; %debugging only
        end
        measuredG=measuredR;
        measuredB=measuredR;
        rawG=rawR;
        rawB=rawR; % RGB are all the same since gray
    case {'8RGB','256RGB'}
        stim=uint8([]);
        if strcmp(mode,'8RGB')
            samps=floor(linspace(0,255,8));
        else
            samps=floor(linspace(0,255,256));
        end
        % do R
        for i=1:length(samps)
            stim(:,:,1,i)=uint8(samps(i)*ones(1,1,1));
            stim(:,:,2:3,i)=uint8(0);
        end
        channels=uint8([1 0 0]); % only R channel
        [measuredR rawR junk details.measurementDetailsR quit] = ...
            generateScreenCalibrationData(method,stim,channels,currentCLUT,drawSpyderPositionFrame,screenNum,screenType);
        if quit
            return; %debugging only
        end
        drawSpyderPositionFrame=false;
        % do G
        for i=1:length(samps)
            stim(:,:,2,i)=uint8(samps(i)*ones(1,1,1));
            stim(:,:,1,i)=uint8(0);
            stim(:,:,3,i)=uint8(0);
        end
        channels=uint8([0 1 0]); % only G channel
        [measuredG rawG junk details.measurementDetailsG quit] = ...
            generateScreenCalibrationData(method,stim,channels,currentCLUT,drawSpyderPositionFrame,screenNum,screenType);
        if quit
            return; %debugging only
        end
        % do B
        for i=1:length(samps)
            stim(:,:,3,i)=uint8(samps(i)*ones(1,1,1));
            stim(:,:,1:2,i)=uint8(0);
        end
        channels=uint8([0 0 1]); % only B channel
        % 6/25/09 fli - we return a modified method here so generateScreenCalibrationData can change the background
        % for use by validation to be the background voltage used during the last raw run. this only works if we assume
        % that the native CLUT is a linear ramp in which R/G/B channels are identical
        [measuredB rawB method details.measurementDetailsB quit] = ...
            generateScreenCalibrationData(method,stim,channels,currentCLUT,drawSpyderPositionFrame,screenNum,screenType);
        if quit
            return; %debugging only
        end
    case 'custom'
        % assume grayscale
        % now run using the gray stim
        channels=uint8([1 1 1]);
        [measuredR rawR method details.measurementDetails quit] = ...
            generateScreenCalibrationData(method,stim,channels,currentCLUT,drawSpyderPositionFrame,screenNum,screenType);
        if quit
            return; %debugging only
        end
        measuredG=measuredR;
        measuredB=measuredR;
        rawG=rawR;
        rawB=rawR; % RGB are all the same since gray
    otherwise
        error('unsupported mode');
end
% now we have rawR,rawG,rawB, measuredR,measuredG,measuredB

% 5/25/09 - we only return a modified 'method' after the last raw measurement, so that validation can use the same voltage value
% - this assumes that the R/G/B voltage values are the same, which is true because our first CLUT is a linear ramp!

% desiredValues is a linear spacing of the first set of measured Y values (with 256 entries)
% we will compare these to our second set of measured Y values
% they should be very similar b/c the linearizedCLUT tries to force our second measurement to be equal to the desired values
measuredR=makeUnique(measuredR);
measuredG=makeUnique(measuredG);
measuredB=makeUnique(measuredB);

desiredR=linspace(measuredR(1),measuredR(end),length(measuredR));
desiredG=linspace(measuredG(1),measuredG(end),length(measuredG));
desiredB=linspace(measuredB(1),measuredB(end),length(measuredB));

% now do something to compute linearizedCLUT
try
    linearizedCLUT=zeros(reallutsize,3);
    switch fitMethod
        case 'linear'
            % R values
            desiredValuesForLUT=linspace(measuredR(1),measuredR(end),reallutsize);
            rawInds=squeeze(rawR(:,:,1,:));
            raws=currentCLUT(uint16(rawInds)+1,1)';
            linearizedCLUT(:,1) = interp1(measuredR,raws,desiredValuesForLUT,'linear')'/raws(end); %consider pchip
            % G values
            desiredValuesForLUT=linspace(measuredG(1),measuredG(end),reallutsize);
            rawInds=squeeze(rawG(:,:,2,:));
            raws=currentCLUT(uint16(rawInds)+1,2)';
            linearizedCLUT(:,2) = interp1(measuredG,raws,desiredValuesForLUT,'linear')'/raws(end); %consider pchip
            % B values
            desiredValuesForLUT=linspace(measuredB(1),measuredB(end),reallutsize);
            rawInds=squeeze(rawB(:,:,3,:));
            raws=currentCLUT(uint16(rawInds)+1,3)';
            linearizedCLUT(:,3) = interp1(measuredB,raws,desiredValuesForLUT,'linear')'/raws(end); %consider pchip
        case 'power'
            error('not yet implemented');
        otherwise
            error('unsupported fitMethod');
    end
catch
    % this is happening when measuredValues contains non-unique entries
    % how does spyder get non-unique measurements for Y, even though stim
    % is always unique?
    % - what should we do with the repeated measurements? throw them away?
    ple
    keyboard
end



% ==============================================================================================
% validate on GRAY only
% recall generateScreenCalibrationData w/ new linearized CLUT and get validation data
% if ismember(mode,{'8gray','256gray'})
stim=uint8([]);
for i=1:length(samps)
    stim(:,:,:,i)=uint8(samps(i)*ones(1,1,3));
end
channels=uint8([1 1 1]);
drawSpyderPositionFrame = false;
[validationValues junk junk details.validationDetails quit] = ...
    generateScreenCalibrationData(method,stim,channels,linearizedCLUT,drawSpyderPositionFrame,screenNum,screenType);
% end

% restore original CLUT
Screen('LoadNormalizedGammaTable',screenNum,currentCLUT);

% compare validationValues with desiredValues
% if max(abs(validationValues-desiredValues))>1.5
%     warning('validationValues differed dramatically from desiredValues - please recalibrate!');
%     keyboard
% end

% put new linearizedCLUT into oracle
if writeToOracle
    try
        conn=dbConn();
        [junk mac]=getMACaddress();
        % HACK
%         mac='0018F35DFAC0';
        % write linearizedCLUT to tempCLUT.mat and read as binary stream
        save('tempCLUT.mat','linearizedCLUT','measuredR','measuredG','measuredB','currentCLUT','validationValues','details');
        fid=fopen('tempCLUT.mat');
        CLUT=fread(fid,'*uint8');
        fclose(fid);
        timestamp=datestr(now,'mm-dd-yyyy HH:MM');
        svnRev=getSVNRevisionFromXML(getRatrixPath);
        addCalibrationData(CLUT,mac,timestamp,svnRev,comment,calibrationString)
        closeConn(conn);
    catch ex
        disp(['CAUGHT EX: ' getReport(ex)]);
        error('failed to get open dbConn() - no oracle access');
    end
end


end % end function


function measuredValues=makeUnique(measuredValues)
% 5/28/09 HACK for now
% if any measuredValues are non unique, add an epsilon to them so they are
% unique and interp doesnt complain!
u=unique(measuredValues);
for uu=1:length(u)
    a=find(measuredValues==u(uu));
    if length(a)>1
        measuredValues(a(2:end))=measuredValues(a(2:end))+eps(measuredValues(a(2:end))).*[1:length(a)-1];
    end
end
end % end function
