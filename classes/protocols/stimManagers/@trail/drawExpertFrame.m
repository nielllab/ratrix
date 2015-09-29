function [doFramePulse expertCache dynamicDetails textLabel i dontclear indexPulse sounds finish] ...
    = drawExpertFrame(s,stim,i,phaseStartTime,totalFrameNum,window,textLabel,...
    destRect,filtMode,expertCache,ifi,scheduledFrameNum,dropFrames,dontclear,...
    dynamicDetails,trialRecords,currentCLUT,phaseRecords,phaseNum,trialManager)

originalLabel = textLabel;

%width  = 63; % default 1.  > 63 errors for DrawDots?  > ~10 seems to have no effect on lines?
width = 10  % new video cards support only (0.500000 to 10.000000)
center = []; % positions are relative to "center" (default center is [0 0]).
centerWidth = 10;

dotType = 2; % 0 (default) squares
% 1 circles (with anti-aliasing) (requires Screen('BlendFunction'))
% 2 circles (with high-quality anti-aliasing, if supported by your hardware)

if ~isfield(expertCache,'clutSize')
    expertCache.clutSize = size(currentCLUT,1)-1;
end
white = expertCache.clutSize*ones(1,4);
black =       white.*[zeros(1,3)   1];
grey  = round(white.*[.5*ones(1,3) 1]);
red   =       white.*[1 0 0        1];
blue  =       white.*[0 0 1        1];

if strcmp(phaseRecords(phaseNum).phaseType,'reinforced')
    dontclear = 1;
elseif true %shouldn't be necessary, but ptb bug: a fillrect grey below screws up dontclear = 0
    dontclear = 1;
    if isa(s.stim,'stimManager')
        [fp, itl] = determineColorPrecision(trialManager, getInterTrialLuminance(s.stim), []); %is this slow?  cache it.
        if fp ~= 0
            error('haven''t fully solved this')
        end
        fill = [repmat(itl,1,3) expertCache.clutSize];
    else
        fill = black;
    end
    % should add a check that fill is black if we're doing dms -- we depend on that
    Screen('FillRect', window, fill, destRect);
else
    dontclear = 0;
end

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
        
        doWalls = true;
        try
            doWalls = length(size(stim.stim.stimulus))~=2;
        end
        
        positionStim = false;
        if islogical(s.positional)
            positionStim = s.positional;
        end
        
        colorWalls = positionStim && ~s.cue;
        drawTrail = positionStim && isempty(s.dms);
        
        if ~positionStim
            origTargetPos = targetPos;
            targetPos = s.initialPos(1) + dynamicDetails.target;
            if ~isempty(wrongLoc)
                origWrongLoc = wrongLoc;
                wrongLoc =  targetPos-sign(dynamicDetails.target)*diff(s.targetDistance.*[-1 1]);
            end
        end
        
        trailColor = white;
        
        if doWalls
            wallRect = destRect; %[left top right bottom]
            
            if ~isfield(dynamicDetails,'parity')
                dynamicDetails.parity = strcmp(s.stim,'flip') || (strcmp(s.stim,'rand') && rand>.5);
            end
            
            if dynamicDetails.target > 0 == dynamicDetails.parity
                ind = 3;
            else
                ind = 1;
            end
            
            if dynamicDetails.parity
                if isempty(wrongLoc)
                    error('can''t flip without a wrongLoc')
                end
                wallRect(ind) = wrongLoc;
                cueColor = black;
            else
                wallRect(ind) = targetPos;
                cueColor = white;
                trailColor = black;
            end
            
            if ~isempty(s.dms)
                if ~s.cue
                    error('can''t have dms without cue')
                end
                t = GetSecs - phaseStartTime; %have to GetSecs instead of dynamicDetails.times(i) cuz i only updates if there was movement
                if t < s.dms.targetLatency
                    Screen('FillRect', window, grey, destRect); %ptb bug: fillrecting whole screen redefines clear color
                    dontclear = 1;
                    if finish
                        dynamicDetails.result = 'tooEarly';
                    end
                end
            end
            
            if diff(wallRect([1 3])) > 0 && (isempty(s.dms) || t >= s.dms.targetLatency) %for now assume targetLatency = distractorLatency
                Screen('FillRect', window, white, wallRect);
            end
            
            if ~isempty(wrongLoc)
                midRect = destRect;
                ind = [1 3];
                if dynamicDetails.target > 0
                    ind = fliplr(ind);
                end
                midRect(ind) = [targetPos wrongLoc];
                Screen('FillRect', window, grey, midRect);
                if colorWalls
                    Screen('DrawLine', window, blue, wrongLoc, destRect(2), wrongLoc, destRect(4), width); %no smoothing?
                end
            end
            
            if colorWalls
                Screen('DrawLine', window, red, targetPos, destRect(2), targetPos, destRect(4), width); %no smoothing?
            end
            
            if s.cue
                if isempty(s.dms) || (t >= s.dms.cueLatency && t <= s.dms.cueLatency + s.dms.cueDuration)
                    if exist('midRect','var')
                        cueRect = midRect;
                        cueRect([1 3]) = cueRect([1 3])+[1 -1].*width;
                    else
                        error('can''t have cue without wrongLoc')
                    end
                    Screen('FillRect', window, cueColor, cueRect);
                end
            elseif strcmp(s.stim,'rand')
                error('cues should be enabled for randomized stim')
            end
        else
            try
                tex = dynamicDetails.tex;
                bg = dynamicDetails.bg;
            catch
                if length(size(stim.stim.stimulus))==2
                    [floatprecision tex] = determineColorPrecision(trialManager, stim.stim.stimulus, []);
                    tex = Screen('MakeTexture', window, tex, [], [], floatprecision);
                    dynamicDetails.tex = tex;
                    
                    [floatprecision bg] = determineColorPrecision(trialManager, getInterTrialLuminance(s.stim), []);
                    bg = Screen('MakeTexture', window, bg, [], [], floatprecision);
                    dynamicDetails.bg = bg;
                else
                    error('only supports single frames atm')
                end
            end
            
            if positionStim
                Screen('DrawTexture', window, bg, [], destRect, [], filtMode);
                
                destinationRect = destRect;
                destinationRect([1 3]) = destinationRect([1 3]) + targetPos - s.initialPos(1) - dynamicDetails.target;
            else
                destinationRect = [];
            end
            
            Screen('DrawTexture', window, tex, [], destinationRect, [], filtMode);
        end
        
        if drawTrail
            Screen('DrawDots', window, relPos, width, trailColor, center, dotType);
            
            inds = repmat(2:size(relPos,2)-1,2,1);
            Screen('DrawLines', window, relPos(:,[1 inds(:)' end]), width, trailColor, center, smooth);
            
            Screen('DrawDots', window, relPos, centerWidth, blue, center, dotType);
        end
        
        if ~positionStim && strcmp(s.positional,'HUD')
            pos = destRect(4)*.1;
            height = 20;
            coords = [origTargetPos, pos, origWrongLoc, pos];
            coords = [coords; cell2mat(arrayfun(@(x)[x,pos,x,pos]+[0,height,0,height].*[1,1,1,-1],[origTargetPos origWrongLoc s.initialPos(1)]','UniformOutput',false))];
            
            for rowNum=1:size(coords,1)
                Screen('DrawLine', window, red, coords(rowNum,1),coords(rowNum,2),coords(rowNum,3),coords(rowNum,4), 10);
            end
        end
        
    case 'reinforced'
        % leave up last discrim frame
        
        sounds = {};
        finish = false;
        indexPulse = false;
        doFramePulse = false;
        textLabel
        
    otherwise
        phaseNum
        phaseRecords(phaseNum)
        error('huh')
end

if didBlend
    Screen('BlendFunction', window, sourceFactorOld, destinationFactorOld);
end

ctStr = 'correction trial!';
if trialRecords(end).stimDetails.correctionTrial && isempty(strfind(textLabel,ctStr))
    textLabel = [ctStr ' ' textLabel];% ' ' originalLabel]; %adding original label grows forever
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