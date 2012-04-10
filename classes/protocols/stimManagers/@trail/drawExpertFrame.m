function [doFramePulse expertCache dynamicDetails textLabel i dontclear indexPulse sounds finish] ...
    = drawExpertFrame(s,stim,i,phaseStartTime,totalFrameNum,window,textLabel,...
    destRect,filtMode,expertCache,ifi,scheduledFrameNum,dropFrames,dontclear,...
    dynamicDetails,trialRecords,currentCLUT,phaseRecords,phaseNum)

originalLabel = textLabel;

dontclear = 0;

width  = 63; % default 1.  > 63 errors for DrawDots?  > ~10 seems to have no effect on lines?
center = []; % positions are relative to "center" (default center is [0 0]).
centerWidth = 10;

dotType = 2; % 0 (default) squares
% 1 circles (with anti-aliasing) (requires Screen('BlendFunction'))
% 2 circles (with high-quality anti-aliasing, if supported by your hardware)

if ~isfield('clutSize',expertCache)
    expertCache.clutSize = size(currentCLUT,1)-1;
end
white = expertCache.clutSize*ones(1,4);
grey = white*.5;
red = expertCache.clutSize*[1 0 0 1];
blue = expertCache.clutSize*[0 0 1 1];

didBlend = false;
smooth = 1;  % default 0, 1 requires Screen('BlendFunction')
if smooth
    [sourceFactorOld, destinationFactorOld]=Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    didBlend = true;
end

    function out=f(x) %annonymous definition below causes huge frame drops, but only when there's lots of history?!
        out=reshape(repmat(x,1,2),[1 4]);
    end

switch phaseRecords(phaseNum).phaseType
    case 'pre-request'
        
        doFramePulse = true;
        indexPulse = true;
        
        if i > 0
            p = s.gain .* (mouse(s)' - s.initialPos) + s.initialPos;
        else
            mouse(s,true);
            p = s.initialPos;
            dynamicDetails.slowTrack = []; %bad :(
            expertCache.slowStart = [];
        end
        
        i = i+1;
        
        dynamicDetails.slowTrack(:,end+1) = [GetSecs; p];
        
        finish = false;
        if all(abs(p - s.initialPos) < s.slow)
            sounds={'keepGoingSound'};
            if isempty(expertCache.slowStart)
                expertCache.slowStart = dynamicDetails.slowTrack(1,end);
            elseif dynamicDetails.slowTrack(1,end) - expertCache.slowStart >= s.slowSecs
                %dynamicDetails.result = 'request'; %sets stopEarly?
                finish = true;
            end
            textLabel = sprintf('%.1f secs to go',s.slowSecs - (dynamicDetails.slowTrack(1,end) - expertCache.slowStart));
        else
            expertCache.slowStart = [];
            sounds={'trySomethingElseSound'};
            textLabel = 'slow down';
        end
        
        %note: request rewards still not working...
        
        %f = @(x) reshape(repmat(x,1,2),[1 4]); %causes huge frame drops!
        
        slowRect = f(s.slow) .* [-1 -1 1 1] + f(2*s.initialPos - p); % seems to be [left bottom right top]?
        
        %our slow constraint is actually rectangualar, but we draw ovals...
        Screen('FillOval', window, white, slowRect, 2*max(s.slow));
        
        Screen('FrameOval', window, red, slowRect, width);
        
        Screen('DrawDots', window, s.initialPos, width, white, center, dotType);
        
        Screen('DrawDots', window, s.initialPos, centerWidth, blue, center, dotType);
        
    case 'discrim'
        
        [relPos, targetPos, wrongLoc, sounds, finish, dynamicDetails, i, indexPulse, doFramePulse, textLabel]=computeTrail(s, i, dynamicDetails, trialRecords);
        
        wallRect = destRect; %[left top right bottom]
        if dynamicDetails.target > 0
            ind = 1;
        else
            ind = 3;
        end
        wallRect(ind) = targetPos;
        if diff(wallRect([1 3])) > 0
            Screen('FillRect', window, white, wallRect);
        end
        
        if ~isempty(wrongLoc)
            midRect = destRect;
            midRect(ind) = wrongLoc;
            if dynamicDetails.target > 0
                ind = 3;
            else
                ind = 1;
            end
            midRect(ind) = targetPos;
            Screen('FillRect', window, grey, midRect);
            Screen('DrawLine', window, blue, wrongLoc, destRect(2), wrongLoc, destRect(4), width); %no smoothing?
        end
        
        Screen('DrawDots', window, relPos, width, white, center, dotType);
        
        inds = repmat(2:size(relPos,2)-1,2,1);
        Screen('DrawLines', window, relPos(:,[1 inds(:)' end]), width, white, center, smooth);
        
        Screen('DrawDots', window, relPos, centerWidth, blue, center, dotType);
        
        Screen('DrawLine', window, red, targetPos, destRect(2), targetPos, destRect(4), width); %no smoothing?
        
    otherwise
        phaseNum
        phaseRecords(phaseNum)
        error('huh')
end

if didBlend
    Screen('BlendFunction', window, sourceFactorOld, destinationFactorOld);
end

if trialRecords(end).stimDetails.correctionTrial
    textLabel = ['correction trial! ' textLabel];
end
end

% Support for 3D graphics rendering and for interfacing with external OpenGL code:
% Screen('Preference', 'Enable3DGraphics', [enableFlag]);  % Enable 3D gfx support.
% Screen('BeginOpenGL', windowPtr [, sharecontext]);  % Prepare window for external OpenGL drawing.
% Screen('EndOpenGL', windowPtr);  % Finish external OpenGL drawing.
% [targetwindow, IsOpenGLRendering] = Screen('GetOpenGLDrawMode');
% [textureHandle rect] = Screen('SetOpenGLTextureFromMemPointer', windowPtr, textureHandle, imagePtr, width, height, depth [, upsidedown][, target][, glinternalformat][, gltype][, extdataformat]);
% [textureHandle rect] = Screen('SetOpenGLTexture', windowPtr, textureHandle, glTexid, target [, glWidth] [, glHeight] [, glDepth] [, textureShader]);
% [ gltexid gltextarget texcoord_u texcoord_v ] =Screen('GetOpenGLTexture', windowPtr, textureHandle [, x][, y]);

% Low level direct access to OpenGL-API functions:
% Online info for each function available by opening a terminal window
% and typing 'man Functionname' + Enter.
% Screen('glPushMatrix', windowPtr);
% Screen('glPopMatrix', windowPtr);
% Screen('glLoadIdentity', windowPtr);
% Screen('glTranslate', windowPtr, tx, ty [, tz]);
% Screen('glScale', windowPtr, sx, sy [, sz]);
% Screen('glRotate', windowPtr, angle, [rx = 0], [ry = 0] ,[rz = 1]);