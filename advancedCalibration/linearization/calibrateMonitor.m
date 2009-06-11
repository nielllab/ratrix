function [measuredValues currentCLUT linearizedCLUT validationValues details] = ...
    calibrateMonitor(method,screenType,fitMethod,writeToOracle,cmd_line,screenNum)
% this function calls generateScreenCalibrationData to get the measured values and then does a basic
% linearization and validation before inserting into Oracle
% INPUTS: 
%   method - how to do the screen calibration (passed to generateScreenCalibrationData):
%   ie {'stimInBoxOnBackground',stim,background,patchRect,interValueRGB,numFramesPerValue,numInterValueFrames}
    %   stim - [height width 3 numFrames] matrix specifying indices into the CLUT
    %   background - the background RGB values, specified as indices into the CLUT
    %   patchRect - where to draw the stim on the background
    %   interValueRGB - the RGB values to show between frames of stim, specified as indices into the CLUT
    %   numFramesPerValue - how many frames to hold each frame of the stim
    %   numInterValueFrames - how many frames of interValueRGB to show between each set of frames in stim
%   screenType - 'LCD' or 'CRT'
%   fitMethod - 'linear' or 'power'
%   writeToOracle - a flag indicating whether or not to write to oracle
%   cmd_line (optional) - the string to store into the oracle field
%   "cmd_line"
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
if exist('cmd_line','var') && ~isempty(cmd_line)
    %pass
else
    cmd_line='unknown';
end

if exist('screenNum','var') && ~isempty(screenNum)
    %pass
else
   screenNum=max(Screen('Screens'));
end



details=[];
details.method=method;
details.fitMethod=fitMethod;
details.screenNum=screenNum;
details.screenType=screenType;
% get current CLUT from screen
[currentCLUT, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', screenNum);
drawSpyderPositionFrame = true;
[measuredValues rawValues method details.measurementDetails] = generateScreenCalibrationData(method,currentCLUT,drawSpyderPositionFrame,screenNum,screenType);

% desiredValues is a linear spacing of the first set of measured Y values (with 256 entries)
% we will compare these to our second set of measured Y values
% they should be very similar b/c the linearizedCLUT tries to force our second measurement to be equal to the desired values
desiredValues=linspace(measuredValues(1),measuredValues(end),length(measuredValues));

% 5/28/09 HACK for now
% if any measuredValues are non unique, add an epsilon to them so they are
% unique and interp doesnt complain!
u=unique(measuredValues);
for uu=1:length(u)
    a=find(measuredValues==u(uu));
    if length(a)>1
        measuredValues(a(2:end))=measuredValues(a(2:end))+eps*[1:length(a)-1];
    end
end

% now do something to compute linearizedCLUT
try
    linearizedCLUT=zeros(reallutsize,3);
    switch fitMethod
        case 'linear'
            desiredValuesForLUT=linspace(measuredValues(1),measuredValues(end),reallutsize);
            % R values
            rawInds=squeeze(rawValues(:,:,1,:));
            raws=currentCLUT(uint16(rawInds)+1,1)';
            linearizedCLUT(:,1) = interp1(measuredValues,raws,desiredValuesForLUT,'linear')'/raws(end); %consider pchip
            % G values
            rawInds=squeeze(rawValues(:,:,2,:));
            raws=currentCLUT(uint16(rawInds)+1,2)';
            linearizedCLUT(:,2) = interp1(measuredValues,raws,desiredValuesForLUT,'linear')'/raws(end); %consider pchip
            % B values
            rawInds=squeeze(rawValues(:,:,3,:));
            raws=currentCLUT(uint16(rawInds)+1,3)';
            linearizedCLUT(:,3) = interp1(measuredValues,raws,desiredValuesForLUT,'linear')'/raws(end); %consider pchip
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

% recall generateScreenCalibrationData w/ new linearized CLUT and get validation data
drawSpyderPositionFrame = false;
[validationValues junk junk details.validationDetails] = generateScreenCalibrationData(method,linearizedCLUT,drawSpyderPositionFrame,screenNum,screenType);

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
        mac='0018F35DFAC0';
        % write linearizedCLUT to tempCLUT.mat and read as binary stream
        save('tempCLUT.mat','linearizedCLUT','measuredValues','currentCLUT','validationValues','details');
        fid=fopen('tempCLUT.mat');
        CLUT=fread(fid,'*uint8');
        fclose(fid);
        timestamp=datestr(now,'mm-dd-yyyy HH:MM');
        svnRev=getSVNRevisionFromXML(getRatrixPath);
        addCalibrationData(CLUT,mac,timestamp,svnRev,cmd_line)
        closeConn(conn);
    catch ex
        disp(['CAUGHT EX: ' getReport(ex)]);
        error('failed to get open dbConn() - no oracle access');
    end
end


end % end function