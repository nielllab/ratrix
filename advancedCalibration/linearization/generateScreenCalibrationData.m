%everything to look at is on the left small rig room computer in C:\pmeier\Calib
%calibrate.m:calibrateAndVerify() show stimuli using clut values caclucated from measurments
%fitGamma.m:

% fitClut = getFitClut(measurements from generateScreenCalibrationData (avg integral under one frame), [monotonically increasing target photodiode measurements in grey condition])

%draws a patch at location patchRect (normalized coordinates [left top right bottom]) which alternates between the entries
%in stim (for numFramesPerValue) and the interValueRGB (for
%numInterValueFrames)
%the patch is superimposed on the fixed greylevel background (rendered using the clut and scaled to full screen, may be spatially patterned)
%default stim: first sweeps through the r, g, and b clut entries independently, then all together.
%framePulses are generated on the parallel port with pin determined by framePulseCode
%stim must be size [rows cols 3 numStims] and contain clut indices (integers 1 thru clutlength)
%interValueRGB must be size [1 1 3] and contain clut indices (integers 1 thru clutlength)
%gray background is 2-d -- must contain clut indices (integers 1 thru clutlength)

%actually i probably have a bug here-- psychtoolbox docs doesn't specify
%what the color argument for screen('maketexture') is precisely -- it only
%mentions the alpha channel:
%"Alpha values range between zero (=fully transparent) and 255 (=fully opaque)"
%for openwindow, drawline, fillrect, drawdots, drawtext:
%"'color' is the clut index (scalar or [r g b] triplet or [r g b a] vector)
%altho he says "clut index" here, i think meaning 1-based in matlab, the behavior
%is that a value of zero is dark, and values over 255 are light
%in textures, however, the value 256 is *dark*, i guess this is consistent with maketexture's doc for its alpha channel
%i had been assuming that zero would not be allowed and 256 would be *bright*
%should look into this, verify w/mario, etc.  hard to try with a weird clut cuz of clut restrictions...

%see http://tech.groups.yahoo.com/group/psychtoolbox/message/6663
% OpenGL normally wants texture data in range 0-255 and color
% specs for any other drawing commands in range 0.0 - 1.0. So
% normally PTB remaps all colors to the range 0.0 - 1.0 by dividing
% through 255
% ...
%There's an optional flag 'floatprecision' to Screen('MakeTexture'). If
%set to 1 or 2, PTB will accept color values in the 0.0 - 1.0 range and
%the graphics hardware will represent the texel values with floating
%point precision at 16 bpc or 32 bpc. This format is only supported
%on recent (>= ATI Radeon X1000 and >= NVidia Geforce6800, not
%MacBook Intel GMA950) graphics hardware and it consumes 2 to 4
%times more memory and bandwidth, but you'll get image
%representations with an effective accuracy of 11 bits
%(floatprecision =1) and 23 bits for floatprecision=2.
% ... should switch to this!

%PMM: Agreed!
%PMM: Some testing of uint8 changes the error check on the function
%'allClutIndices'.

%also need to figure out how to incorporate CLUT changes...

%spyderData is returned as capital [X Y Z] as defined at http://en.wikipedia.org/wiki/CIE_1931_color_space
%be aware that on very dark stims, the hue measurement will be very noisy.  (the spyder may give up and return zero in these cases)
%consider reworking to return xyY (white = (x,y)(1/3,1/3), Y=cd/m^2)

%example call:
% generateScreenCalibrationData([],[],[0 0 .3 .3],int8(10),int8(10),repmat(linspace(0,1,2^8)',1,3),uint8(ceil((2^8)*rand(5,10,3,100))),uint8(round(2^8/2)*ones(1,1,3)),uint8(ceil(rand(1000)*2^8)),'B888',int8(1),true,false);
% generateScreenCalibrationData([],[],[],[],[],[],[],[],[],'B888',[],false,false);
% vals=generateScreenCalibrationData([],[],[],int8(10),int8(0),[],[],[],[],'B888',[],true,false);
% [spyderData daqData, ifi]=generateScreenCalibrationData(0,'CRT',[],int8(10),int8(2),repmat(linspace(0,1,2^8)',1,3),[],[], [],[],'B888',[],true,false, [], [], false)

function [spyderData daqData, ifi]=generateScreenCalibrationData(screenNum,screenType,patchRect,numFramesPerValue,numInterValueFrames,clut,stim,positionFrame, interValueRGB,background,parallelPortAddress,framePulseCode,useSpyder,doDaq, daqPath, daqPlot, skipSyncTest)
% framePulseCode
% parallelPortAddress

Screen('Preference', 'SkipSyncTests',0);

p = mfilename('fullpath');
[pathstr, name, ext, versn] = fileparts(p);
addpath(genpath(pathstr));

if ~islogical(doDaq) && ~isscalar(doDaq)
    error('doDaq should be logical scalar')
end

if ~islogical(useSpyder) && ~isscalar(useSpyder)
    error('useSpyder should be logical scalar')
end

if isempty(parallelPortAddress)
    parallelPortAddress='0378';
end
hex2dec(parallelPortAddress);

if isempty(framePulseCode)
    framePulseCode=int8(1);
elseif framePulseCode<1 || framePulseCode>8 || ~isinteger(framePulseCode)
    error('framePulseCode must be integer 1 <= framePulseCode <= 8')
end

if isempty(screenNum)
    screenNum=max(Screen('Screens'));
elseif ~ismember(screenNum,Screen('Screens'))
    error('bad screen num')
end

if isempty(skipSyncTest) 
    skipSyncTest = 0;
end

if length(Screen('Screens'))>1 || skipSyncTest
    Screen('Preference', 'SkipSyncTests',1);
    warning('detected multiple screens -- this is officially bad and you will have bad timing!')
end

if isempty(screenType)
    screenType='CRT';
    warning('defaulting to CRT')
else
    switch screenType
        case {'CRT','LCD'}
        otherwise
            error('screenType must be CRT or LCD')
    end
end

if isempty(patchRect)
    patchRect=[0.2 0.2 0.8 0.8];
elseif ~all(patchRect(:)>=0 & patchRect(:)<=1) || ~all(size(patchRect)==[1 4])
    error('patch rect should be normalized coordinates [left top right bottom]')
end

if isempty(numFramesPerValue)
    numFramesPerValue=int8(1);
end

if isempty(numInterValueFrames)
    numInterValueFrames=int8(1);
end

if ~isinteger(numFramesPerValue) || ~isinteger(numInterValueFrames)
    error('numFramesPerValue and numInterValueFrames  should be integers')
end

[oldClut, dacbits, reallutsize] = Screen('ReadNormalizedGammaTable', screenNum);

if isempty(clut)
    clut=repmat(linspace(0,1,reallutsize)',1,3);
end
if all(clut(:)>=0 & clut(:)<=1) && size(clut,1) <= reallutsize && size(clut,2) == 3
    oldClut=Screen('LoadNormalizedGammaTable', screenNum, clut);
else
    error('clut must be normalized and no longer than %d rows (3 columns)',reallutsize)
end
if isempty(daqPath)
    daqPath = fullfile(pwd, 'daqData');
end

if ~exist('daqPlot', 'var')
    daqPlot = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    originalPriority=Priority(MaxPriority('GetSecs', 'KbCheck'));

    [window winRect]=Screen('OpenWindow',screenNum);
    ifi =Screen('GetFlipInterval', window);
%     hidecursor;
    
    [width, height]=Screen('WindowSize', window);
    patchRect=patchRect.*[width height width height];

    if isempty(background)
        background=uint8(1); %used to have zero, but not a clut index!
    end
    if length(size(background))<=2 && allClutIndices(background(:),size(clut,1))
        bg=Screen('MakeTexture',window,background);
    else
        sca
        background
        keyboard
        error('background must be at most 2-dims and 1 <= int values <= size(clut)')
    end

    if isempty(interValueRGB)
        interValueRGB=uint8(ones(1,1,3)); %used to have zeros, but not a clut index!
    end
    if all(size(interValueRGB) == [1 1 3]) && allClutIndices(interValueRGB(:),size(clut,1))
        ivRGB=Screen('MakeTexture',window,interValueRGB);
    else
        error('interValueRGB must be size [1 1 3] and 1 <= int values <= size(clut)')
    end

    %     [whInd garbage]=find(clut==repmat(max(clut),size(clut,1),1)); %find max entries in each clut column - edf
    whInd=repmat(WhiteIndex(screenNum),1,3); % use ptb definition of white; - pmm
    if length(whInd)~=3
        error('didn''t get 3 unique white indices')
    end
    wh=Screen('MakeTexture',window,whInd);


    if isempty(stim)
        r=zeros(1,1,3);
        g=zeros(1,1,3);
        b=zeros(1,1,3);
        k=ones(1,1,3);
        r(:,:,1)=1;
        g(:,:,2)=1;
        b(:,:,3)=1;

        numValsPerChannel=4; %size(clut,1)
        entryNum=0;
        for i=round(linspace(1,size(clut,1),numValsPerChannel)) %1:size(clut,1)
            entryNum=entryNum+1;
            stim(:,:,:,0*numValsPerChannel+entryNum)=r*i;
            stim(:,:,:,1*numValsPerChannel+entryNum)=g*i;
            stim(:,:,:,2*numValsPerChannel+entryNum)=b*i;
            stim(:,:,:,3*numValsPerChannel+entryNum)=k*i;
        end
    elseif ~(size(stim,3) == 3 && length(size(stim))==4 && allClutIndices(stim(:),size(clut,1)))
            error('stim must be size [rows cols 3 numStims] and 1 <= int values <= size(clut)')
    end

    if isempty(positionFrame)
        drawSpyderPositionFrame = 0;

    else
        if length(size(positionFrame)) == 2
            % positionFrame = makePositionFrame(positionFrame(1), positionFrame(2));
            % treat as x, y position
        end
        drawSpyderPositionFrame = 1;
    end

    %%%%%%%%%%%%%%% ADDING THE POSITIONAL SCREEN %%%%%%%%%%%%%%%%%%%

    if drawSpyderPositionFrame
        positionFrameSpyder = Screen('MakeTexture',window,positionFrame);
        Screen('DrawTexture', window, positionFrameSpyder);
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
    vbl = Screen('Flip',window);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for i=1:size(stim,4)
        t(i)=Screen('MakeTexture',window,stim(:,:,:,i));
    end
    success=Screen('PreloadTextures',window);
    if ~success
        error('insufficient VRAM to load all textures ahead of time, need to rewrite to be more dynamic')
    end

%     flutterPulse(parallelPortAddress,framePulseCode);
%%%%%%% IF USING SPYDER %%%%%%%%%%%
    ai=[];
    spyderLib=[];
    spyderData=[];
    
    if useSpyder
        spyderData=nan*zeros(size(stim,4),3);

        Screen('DrawTexture',window,wh,[],winRect,[],0); %white screen required to open spyder
        Screen('DrawingFinished',window);
        vbl = Screen('Flip',window);
        waitsecs(0.1);

        [spyderLib refreshRate]=openSpyder(screenType); %wants white screen for this!
        refreshRate
        if numFramesPerValue < refreshRate*5
            warning('spyder wants at least 5 second samples for good readings -- numFramesPerValue should be at least %d', refreshRate*5)
        end
    end
    
%%%%%%%% IF USING DAQ %%%%%%%%%%%%% NOTE: doDaq == 0 ALWAYS!!! 
    daqData=[];
    
    if doDaq
        numChans=2;
        sampRate=100000; % was 100000
        recordingFile = fullfile(daqPath, 'calibrationData.daq');
        [ai chans recordFile]=openNidaqForAnalogRecording(numChans,sampRate,[-1 1;-1 6],recordingFile);
        start(ai);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

beep;beep
waitsecs(10);% ptb seems to be unreliable when it starts
beep;beep

    for i=1:size(stim,4)
%         if KbCheck %could use GetChar() instead, which will buffer keys
%             break
%         end
        if numFramesPerValue>0
            Screen('DrawTexture',window,bg,[],winRect,[],0);
            Screen('DrawTexture',window,t(i),[],patchRect,[],0);
            Screen('DrawingFinished',window);

            if useSpyder
                when=0;
            else
                when=vbl+(double(numFramesPerValue)-0.5)*ifi;
            end
            vbl = Screen('Flip',window,when);

            if useSpyder
                WaitSecs(.1)

                %expect warning 0x00020002 for dark screens (can't detect frame edges)
                %but really should verify success was 1 or 20002 before storing...
                [success, x, y, z] = calllib(spyderLib,'CV_GetXYZ',numFramesPerValue,libpointer('int32Ptr',0),libpointer('int32Ptr',0),libpointer('int32Ptr',0));
                spyderData(i,:)=[double(x) double(y) double(z)]/1000;

                if success ~= 1
                    'error calling CV_GetXYZ'
                    spyderError(spyderLib);
                end
            end

        end
        framepulse(true,parallelPortAddress,framePulseCode);

        if numInterValueFrames>0
            Screen('DrawTexture',window,bg,[],winRect,[],0);
            Screen('DrawTexture',window,ivRGB,[],patchRect,[],0);
            Screen('DrawingFinished',window);
            when=vbl+(double(numInterValueFrames)-0.5)*ifi;
            vbl = Screen('Flip',window,when);
        end
        framepulse(false,parallelPortAddress,framePulseCode);
    end
    
    ai=cleanup(originalPriority,screenNum,oldClut,parallelPortAddress,framePulseCode,spyderLib,ai);
    if useSpyder
        figure
        subplot(2,1,1)
        plot(spyderData)
        legend({'X','Y','Z'})
        subplot(2,1,2)
        plot(spyderData./(repmat((sum(spyderData'))',1,3)))
        legend({'x','y','z'})
    end
    
    if doDaq

        recordingFile = fullfile(daqPath, sprintf('calibrationData.daq'));
        [daqData,time,abstime,events,daqinfo] = daqread(recordingFile);
        [intensity, rawFirstFrame] = calculateIntensityPerFrame(daqData, 'integral', sampRate, ifi, numFramesPerValue);

        if daqPlot % this can overwelm matlab if too large
            figure;
            plot(daqData);
        else
% calling 'figure' creates the java.lang problem, which crashes matlab
%             figure;
%             plot(rawFirstFrame);

        end
            daqData = intensity;
    end
catch
%     showcursor; 
    sca
    x=lasterror;
    x.message
    x.stack.file
    x.stack.line
    ai=cleanup(originalPriority,screenNum,oldClut,parallelPortAddress,framePulseCode,spyderLib,ai);
end

function out=allClutIndices(x,clutLength)

switch class(x)
    case 'uint8'
        out = isinteger(x) && all(x(:)>=0 & x(:)<=clutLength-1); %PMM + YZ code
        % can't access index 256 if stim is uint8
    otherwise
        out = isinteger(x) && all(x(:)>=1 & x(:)<=clutLength); % EDF code
        warning('see function help about accessing clut indices');

end

function ai=cleanup(originalPriority,screenNum,oldClut,parallelPortAddress,framePulseCode,spyderLib,ai)
Priority(originalPriority);
showcursor;
Screen('CloseAll');
Screen('LoadNormalizedGammaTable', screenNum, oldClut);
Screen('Preference', 'SkipSyncTests',0);
framepulse(false,parallelPortAddress,framePulseCode);
if ~isempty(spyderLib)
    closeSpyder(spyderLib);
end
if ~isempty(ai)
    stop(ai);
    delete(ai);
    ai=[];
end

function framepulse(val,parallelPortAddress,framePulseCode)
if islogical(val)
    codeStr=dec2bin(lptread(hex2dec(parallelPortAddress)),8);
    if val
        codeStr(framePulseCode)='1';
    else
        codeStr(framePulseCode)='0';
    end
    lptwrite(hex2dec(parallelPortAddress), bin2dec(codeStr));
else
    error('val must be logical')
end

% function flutterPulse(parallelPortAddress,framePulseCode)
% codeStr=dec2bin(lptread(hex2dec(parallelPortAddress)),8);
% on=codeStr;
% off=codeStr;
% on(framePulseCode)='1';
% off(framePulseCode)='0';
% on=bin2dec(on);
% off=bin2dec(off);
% ppa=hex2dec(parallelPortAddress);

% WaitSecs(.1)
% lptwrite(ppa, on);lptwrite(ppa, off);
% lptwrite(ppa, on);lptwrite(ppa, off);
% lptwrite(ppa, on);lptwrite(ppa, off);
% lptwrite(ppa, on);lptwrite(ppa, off);
% lptwrite(ppa, on);lptwrite(ppa, off);
% lptwrite(ppa, on);lptwrite(ppa, off);
% lptwrite(ppa, on);lptwrite(ppa, off);
% lptwrite(ppa, on);lptwrite(ppa, off);
% lptwrite(ppa, on);lptwrite(ppa, off);
% lptwrite(ppa, on);lptwrite(ppa, off);
% 
% 
% WaitSecs(.1)
% framepulse(true,parallelPortAddress,framePulseCode);
% framepulse(false,parallelPortAddress,framePulseCode);
% framepulse(true,parallelPortAddress,framePulseCode);
% framepulse(false,parallelPortAddress,framePulseCode);
% framepulse(true,parallelPortAddress,framePulseCode);
% framepulse(false,parallelPortAddress,framePulseCode);
% framepulse(true,parallelPortAddress,framePulseCode);
% framepulse(false,parallelPortAddress,framePulseCode);
% framepulse(true,parallelPortAddress,framePulseCode);
% framepulse(false,parallelPortAddress,framePulseCode);
% framepulse(true,parallelPortAddress,framePulseCode);
% framepulse(false,parallelPortAddress,framePulseCode);
% framepulse(true,parallelPortAddress,framePulseCode);
% framepulse(false,parallelPortAddress,framePulseCode);
% framepulse(true,parallelPortAddress,framePulseCode);
% framepulse(false,parallelPortAddress,framePulseCode);
% framepulse(true,parallelPortAddress,framePulseCode);
% framepulse(false,parallelPortAddress,framePulseCode);
% framepulse(true,parallelPortAddress,framePulseCode);
% framepulse(false,parallelPortAddress,framePulseCode);

% WaitSecs(.1)
% for i=1:10
%     framepulse(true,parallelPortAddress,framePulseCode);
%     framepulse(false,parallelPortAddress,framePulseCode);
% end
% 
% WaitSecs(.1)
% for i=1:10
%     extframepulse(true,parallelPortAddress,framePulseCode);
%     extframepulse(false,parallelPortAddress,framePulseCode);
% end