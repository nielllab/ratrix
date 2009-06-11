function [measuredValues rawValues method calibrationDetails] = generateScreenCalibrationData(method,stim,clut,drawSpyderPositionFrame,screenNum,screenType)
% this function uses spyder to measure luminance values with the given 'method' for drawing stimuli
% INPUTS:
%   method - how to do the screen calibration:
%   ie {'stimInBoxOnBackground',background,patchRect,interValueRGB,numFramesPerValue,numInterValueFrames}
    %   background - the background RGB values, specified as indices into the CLUT
    %   patchRect - where to draw the stim on the background
    %   interValueRGB - the RGB values to show between frames of stim, specified as indices into the CLUT
    %   numFramesPerValue - how many frames to hold each frame of the stim
    %   numInterValueFrames - how many frames of interValueRGB to show between each set of frames in stim
%   stim - [height width 3 numFrames] matrix specifying indices into the CLUT
%   clut - the CLUT to use for this measurement
%   drawSpyderPositionFrame - a flag indicating whether or not to prompt user to position spyder on screen
%   screenNum - the screen number to use when calling PTB
%   screenType - 'CRT' or 'LCD'
% OUTPUTS:
%   measuredValues - the measured Y luminance values from the spyder
%   rawValues - the raw values of the stim (as indices into the CLUT): this is useful b/c calibrateMonitor might need these, but
%       doesn't know how to get them, whereas this method switches on the method
%
% NOTE: all indices in the CLUT are in the range 0-255, NOT 1-256. for some reason, PTB accepts arguments to
% 'MakeTexture' in the range 0-255 where 0 is dark and 255 is light.

measuredValues=[];
rawValues=[];
calibrationDetails=[];

if ~(ischar(screenType) && ismember(screenType,{'LCD','CRT'}))
    error('screenType must be ''LCD'' or ''CRT''');
end
if ~(iscell(method) && ischar(method{1}) && ismember(method{1},{'stimInBoxOnBackground','fullScreenStim'}))
    error('method must be a cell vector where first element specifies how to get screen calibration data');
end


try
    % set up PTB
    hidecursor;
    [window winRect]=Screen('OpenWindow',screenNum);
    [oldClut, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', screenNum);
    Screen('LoadNormalizedGammaTable', screenNum, clut);
    originalPriority=Priority(MaxPriority('GetSecs', 'KbCheck'));
    [width height]=Screen('WindowSize',window);
    % start up spyder
    whInd=repmat(WhiteIndex(screenNum),1,3); % use ptb definition of white; - pmm
    if length(whInd)~=3
        error('didn''t get 3 unique white indices')
    end
    ListenChar(2);
    wh=Screen('MakeTexture',window,whInd);
    if drawSpyderPositionFrame
        positionFrame=getDefaultPositionFrame(width, height);
        positionFrameSpyder = Screen('MakeTexture',window,positionFrame);
        Screen('DrawTexture', window, positionFrameSpyder);
        Screen('DrawText',window,'Please position the spyder NOW... and then press a key',15,15,100)
        vbl = Screen('Flip',window); % why don't we need a 'flip' here???
        % possible ans: dual header mode with ATI gfx?
        display('Please position the spyder NOW... and then press a key');
        while 1
            [ keyIsDown, seconds, keyCode ] = KbCheck;
            pause(0.01);
            if keyIsDown
                break
            end
        end
    end
    Screen('DrawTexture',window,wh,[],winRect,[],0); %white screen required to open spyder
    Screen('DrawingFinished',window);
    vbl = Screen('Flip',window);
    WaitSecs(0.1);
    [spyderLib refreshRate]=openSpyder(screenType); %wants white screen for this!

    WaitSecs(10);


    special=method{1};
    switch special
        case 'stimInBoxOnBackground'
            %     {'stimInBoxOnBackground',stim,background,patchRect,interValueRGB,numFramesPerValue,numInterValueFrames}
            % convert background from the following:
            % {value, 'fromRaw'} - where value ranges from 0 to 1 as a percentage of max luminance
            % and fromRaw means find the entry in the raw CLUT that most closely matches the requested value
            % - to an RGB triplet
            if iscell(method{2}) && length(method{2})==2 && ischar(method{2}{2}) && ...
                    ismember(method{2}{2},{'fromRaw'}) && isscalar(method{2}{1}) && ...
                    method{2}{1}>=0 && method{2}{1}<=1
                special=method{2}{2};
                calibrationDetails.requestedBackground=method{2}{1};
                [calibrationDetails.diffFromRequestedBackground method{2}]=min(abs(clut(:,1)-method{2}{1})); % find the index of the CLUT that most closely matches the requested luminance (assume grayscale)
                method{2}=uint8(method{2}); % convert to uint8
                calibrationDetails.actualBackground=clut(method{2},1);
                calibrationDetails.actualBackgroundRGB=method{2};
            else
                error('background must be {value,''fromRaw''}');
            end
            spyderData=stimInBoxOnBackground(window,spyderLib,stim,...
                method{2},method{3},method{4},method{5},method{6},reallutsize,refreshRate);
            rawValues=stim;
            method{2}={clut(method{2},1),special}; % reset the method's background to the 0.0-1.0 value
        case 'fullScreenStim'
            spyderData=fullScreenStim(window,spyderLib,stim,...
                method{2},method{3},method{4},reallutsize,refreshRate);
            rawValues=stim;
        otherwise
            error('unsupported method for screen calibration');
    end
    ListenChar(1);

    figure
    subplot(2,1,1)
    plot(spyderData)
    legend({'X','Y','Z'})
    subplot(2,1,2)
    plot(spyderData./(repmat((sum(spyderData'))',1,3)))
    legend({'x','y','z'})

    measuredValues=spyderData(:,2,:)';
    calibrationDetails.spyderData=spyderData;
    cleanup(originalPriority,screenNum,oldClut,spyderLib);

catch ex
    sca
    disp(['CAUGHT EX: ' getReport(ex)]);
    if ~isempty(strfind(getReport(ex),'go to http://www.colorvision.com/dl_software.php and download the latest spyder driver and/or the latest version of spyder2PRO (serial: 112710-692340-550088).  install, reboot, and run spyder2PRO.  make sure the spyder is attached via USB and appears in device manager attached to driver C:\WINDOWS\system32\drivers\Spyder2.sys (modified 1/17/2007)'))
        error('Check that the spyder is plugged in!!');
    end
    spyderLib=[];
    cleanup(originalPriority,screenNum,oldClut,spyderLib);
end


end % end main function


function cleanup(originalPriority,screenNum,oldClut,spyderLib)
Priority(originalPriority);
showcursor;
ListenChar(1);
Screen('CloseAll');
Screen('LoadNormalizedGammaTable', screenNum, oldClut);
Screen('Preference', 'SkipSyncTests',0);
if ~isempty(spyderLib)
    closeSpyder(spyderLib);
end
end