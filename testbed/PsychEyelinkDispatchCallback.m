function rc = PsychEyelinkDispatchCallback(callArgs, msg)
% Retrieve live eye-image from Eyelink, show it in onscreen window.
%
% This function is normally called from within the Eyelink() file, not from
% normal usercode! To define which onscreen window the eye image should be
% drawn to, call it with a handle of an onscreen window, e.g.,
% PsychEyelinkDispatchCallback(windowPtr); with windowPtr as the window
% handle of a window created via windowPtr = Screen('OpenWindow', ...);
%
%
% This function fetches the most recent live image from the Eylink eye
% camera and displays it in the previously assigned onscreen window.
%

% History:
% 15.3.2009 Derived from MemoryBuffer2TextureDemo.m (MK).

% Cached texture handle for eyelink texture:
persistent eyelinktex;

% Cached window handle for target onscreen window:
persistent win;
persistent calxy;
persistent imgtitle;

% Cached constant definitions:
persistent GL_RGBA;
persistent GL_RGBA8;
persistent GL_UNSIGNED_BYTE;

if isempty(eyelinktex)
    % Define the two OpenGL constants we actually need. No point in
    % initializing the whole PTB OpenGL mode for just two constants:
    GL_RGBA = 6408;
    GL_RGBA8 = 32856;
    GL_UNSIGNED_BYTE = 5121;
end

% Preinit return code to zero:
rc = 0;

if nargin < 2
    msg = [];
end

if nargin < 1
    callArgs = [];
end

if isempty(callArgs)
    error('You must provide some valid "callArgs" variable as 1st argument!');
end

if ~isnumeric(callArgs) | (~isscalar(callArgs) & ~isvector(callArgs)) %#ok<AND2,OR2>
    error('"callArgs" argument must be a double scalar or double vector!');
end

if isscalar(callArgs)
    % Single double scalar. Must be a window handle:
    if Screen('WindowKind', callArgs) ~= 1
        error('"windowPtr" must be a valid handle of an open onscreen window!');
    end
    
    % Ok, valid handle. Assign it and return:
    win = callArgs;

    return;
end

% No windowhandle. Either a 4 component vector from Eyelink(), or something
% wrong:
if length(callArgs) ~= 4
    error('Invalid "callArgs" received from Eyelink() Not a 4 component double vector as expected!');
end

% Extract command code:
eyecmd = callArgs(1);

if isempty(win)
    warning('Got called as callback function from Eyelink() but usercode has not set a valid target onscreen window handle yet! Aborted.'); %#ok<WNTAG>
    return;
end

switch eyecmd
    case 1,
        % Nothing to do here. See code below for eye image display...
        
    case 2,
        % Eyelink Keyboard query:
        [isdown, secs, keyCode] = KbCheck;
        if isdown
            % This needs more thought. Which keys should we pass to
            % Eyelink? How do our KbCheck keycodes map to Eyelinks
            % expectations?
            rc = min(find(keyCode)); %#ok<MXFND>
            
            % The proper implementation probably would use:
            % For that we need the 'el' eyelinks struct. Not my business
            % integrating this properly...
            
            % [rc, el]=EyelinkGetKey(el)
        else
            rc = 0;
        end
        
    case 3,
        % Alert message:
        fprintf('Eyelink ALERT: %s.\n', msg);
        
    case 4,
        % Image title:
        fprintf('Eyelink image title is %s.\n', msg);
        imgtitle = msg;
        
    case 5,
        % Draw calibration target:
        calxy = callArgs(2:3);
        Screen('DrawDots', win, calxy, 5, [255 255 0]);
        
    case {6 , 7}
        % Setup calibration display: Do nothing except clear screen:
        Screen('Flip', win);
        
    otherwise
        % Unknown command:
        return;
end

if eyecmd ~= 1
    return;
end

% Video callback from Eyelink: We have a 'eyewidth' by 'eyeheight' pixels
% live eye image from the Eyelink system. Each pixel is encoded as a 4 byte
% RGBA pixel with alpha channel set to a constant value of 255 and the RGB
% channels encoding a 1-Byte per channel R, G or B color value. The
% given 'eyeimgptr' as a a specially encoded memory pointer to the memory
% buffer inside Eyelink() that encodes the image.
eyeimgptr = callArgs(2);
eyewidth  = callArgs(3);
eyeheight = callArgs(4);

% Create a new PTB texture of proper format and size and inject the 4
% channel RGBA color image from the Eyelink memory buffer into the texture.
% Return a standard PTB texture handle to it. If such a texture already
% exists from a previous invocation of this routiene, just recycle it for
% slightly higher efficiency:
upsidedown = 0;
eyelinktex = Screen('SetOpenGLTextureFromMemPointer', win, eyelinktex, eyeimgptr, eyewidth, eyeheight, 4, upsidedown, [], GL_RGBA8, GL_RGBA, GL_UNSIGNED_BYTE);

% Draw texture centered in window:
Screen('DrawTexture', win, eyelinktex);

% Draw calibration target:
if ~isempty(calxy)
    Screen('DrawDots', win, calxy, 5, [255 255 0]);
end

% Draw title:
if ~isempty(imgtitle)
    Screen('DrawText', win, imgtitle, eyewidth / 2, 10, [255 0 0]); 
end

% Show it:
Screen('Flip', win);

% Done.
return;
