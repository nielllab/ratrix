function [doFramePulse expertCache dynamicDetails textLabel i dontclear indexPulse sounds finish] ...
    = drawExpertFrame(s,stim,i,phaseStartTime,totalFrameNum,window,textLabel,...
    destRect,filtMode,expertCache,ifi,scheduledFrameNum,dropFrames,dontclear,...
    dynamicDetails,trialRecords,currentCLUT)

[relPos, targetPos, sounds, finish, dynamicDetails, i, indexPulse, doFramePulse]=computeTrail(s, i, dynamicDetails, trialRecords);
dontclear = 0;

didBlend = false;

width  = 63; % default 1.  > 63 errors for DrawDots?  > ~10 seems to have no effect on lines?
colors = []; % default white
center = []; % positions are relative to "center" (default center is [0 0]).
smooth = 1;  % default 0, 1 requires Screen('BlendFunction')
if smooth
    [sourceFactorOld, destinationFactorOld]=Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    didBlend = true;
end

if ~isfield('clutSize',expertCache)
    expertCache.clutSize = size(currentCLUT,1)-1;
end

color = expertCache.clutSize*ones(1,4);
wallRect = destRect; %[left top right bottom]
if dynamicDetails.target > 0
    ind = 1;
else
    ind = 3;
end
wallRect(ind) = targetPos;
if diff(wallRect([1 3])) > 0
    Screen('FillRect', window, color, wallRect);
end

type = 2; % 0 (default) squares
          % 1 circles (with anti-aliasing) (requires Screen('BlendFunction'))
          % 2 circles (with high-quality anti-aliasing, if supported by your hardware)
Screen('DrawDots', window, relPos , width, color, center, type);

inds = repmat(2:size(relPos,2)-1,2,1);
Screen('DrawLines', window, relPos(:,[1 inds(:)' end]), width, colors, center, smooth);

color = expertCache.clutSize*[0 0 1 1]; % default black
Screen('DrawDots', window, relPos , 10, color, center, type);

color = expertCache.clutSize*[1 0 0 1]; % default black
Screen('DrawLine', window, color, targetPos, destRect(2), targetPos, destRect(4), width); %no smoothing?

if didBlend
    Screen('BlendFunction', window, sourceFactorOld, destinationFactorOld);
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