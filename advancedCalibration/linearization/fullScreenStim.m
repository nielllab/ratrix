function spyderData = fullScreenStim(window,spyderLib,stim,...
    interValueRGB,numFramesPerValue,numInterValueFrames,reallutsize)
% this function uses spyder to measure the output from a full screen stim
% INPUTS:
%   window - the PTB windowPtr
%   spyderLib - for spyder calls
%   stim - [height width 3 numFrames] matrix specifying indices into the CLUT
%   background - the background RGB values, specified as indices into the CLUT
%   patchRect - where to draw the stim on the background
%   interValueRGB - the RGB values to show between frames of stim, specified as indices into the CLUT
%   numFramesPerValue - how many frames to hold each frame of the stim
%   numInterValueFrames - how many frames of interValueRGB to show between each set of frames in stim
%   reallutesize - how many lut entries
%
% NOTE: all indices in the CLUT are in the range 0-255, NOT 1-256. for some reason, PTB accepts arguments to
% 'MakeTexture' in the range 0-255 where 0 is dark and 255 is light.

KbConstants.kKey=KbName('k');
KbConstants.qKey=KbName('q');

spyderData=nan*zeros(size(stim,4),3);
if ~(size(stim,3) == 3 && length(size(stim))==4 && allClutIndices(stim(:),reallutsize))
    error('stim must be size [rows cols 3 numStims] and 0 <= int values < size(clut)')
end
if ~(isvector(interValueRGB) && length(interValueRGB)==3 && allClutIndices(interValueRGB(:),reallutsize))
    sca
    interValueRGB
    keyboard
    error('interValueRGB must be a 3-element vector and 0 <= int values < size(clut)')
end
if ~(isinteger(numInterValueFrames) && isinteger(numFramesPerValue) && ...
        isscalar(numInterValueFrames) && isscalar(numFramesPerValue))
    error('numInterValueFrames and numFramesPerValue must be scalar integers');
end

ifi=Screen('GetFlipInterval', window);
secsPerValue=ifi*double(numFramesPerValue);
secsPerInterValue=ifi*double(numInterValueFrames);

winRect=Screen('Rect',window);
width=winRect(3)-winRect(1);
height=winRect(4)-winRect(2);

% make interValue and stim textures
iv=Screen('MakeTexture',window,interValueRGB);
for i=1:size(stim,4)
    t(i)=Screen('MakeTexture',window,stim(:,:,:,i));
end
success=Screen('PreloadTextures',window);
if ~success
    error('insufficient VRAM to load all textures ahead of time, need to rewrite to be more dynamic')
end

spyderData=nan*zeros(size(stim,4),3);
% now draw and get spyder data
for i=1:size(stim,4)
    Screen('DrawTexture',window,t(i),[],winRect,[],0);
    Screen('DrawingFinished',window);
    Screen('Flip',window);
    
    % do keyboard check for k+q
    [keyIsDown,secs,keyCode]=KbCheck; % do this check outside of function to save function call overhead
    if keyIsDown
        kDown=any(keyCode(KbConstants.kKey));
        qDown=any(keyCode(KbConstants.qKey));
        if kDown && qDown
            return
        end
    end
    WaitSecs(secsPerValue);
    [success, x, y, z] = calllib(spyderLib,'CV_GetXYZ',numFramesPerValue,libpointer('int32Ptr',0),libpointer('int32Ptr',0),libpointer('int32Ptr',0));
    spyderData(i,:)=[double(x) double(y) double(z)]/1000;

    if success ~= 1
        'error calling CV_GetXYZ'
        spyderError(spyderLib);
    end
    if secsPerInterValue>0
        Screen('DrawTexture',window,iv,[],winRect,[],0);
        Screen('DrawingFinished',window);
        Screen('Flip',window);
        WaitSecs(secsPerInterValue);
    end
end

end % end main function


function out=allClutIndices(x,clutLength)
switch class(x)
    case 'uint8'
        out = isinteger(x) && all(x(:)>=0 & x(:)<=clutLength-1); %PMM + YZ code
        % can't access index 256 if stim is uint8
    otherwise
        out=false;
end
end
