function s=coherentDots(varargin)
% ORIENTEDGABORS  class constructor.
% s = orientedGabors([pixPerCycs],[targetOrientations],[distractorOrientations],mean,radius,contrast,thresh,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance) 
% orientations in radians
% mean, contrast, yPositionPercent normalized (0 <= value <= 1)
% radius is the std dev of the enveloping gaussian, in normalized units of the diagonal of the stim region
% thresh is in normalized luminance units, the value below which the stim should not appear

eps = 0.0000001;
switch nargin
case 0 
% if no input arguments, create a default object


%         s.maxWidth=0;
%         s.maxHeight=0;
%         s.scaleFactor=[];
%         s.interTrialLuminance=0;

% TODO: Reset to be zeros

%s.dotsMoveRight = -1;           % 1 for right, -1 for left, 0 for no motion
s.screen_width = 100;         % for matrix
s.screen_height = 100;        % for matrix
s.num_dots = 100;             % Number of dots to display
s.coherence = .8;             % Percent of dots to move in a specified direction
s.speed = 1;                  % How fast do our little dots move
s.dot_size = 9;              % Width of dots in pixels
s.movie_duration = 2;         % in seconds
s.fps = 85;                   % Frames per second
screen_zoom = [6 6];

    s = class(s,'coherentDots',stimManager());

case 1
% if single argument of this class type, return it
    if (isa(varargin{1},'coherentDots'))
        s = varargin{1}; 
    else
        error('Input argument is not an coherentDots object')
    end
case 17

    if (floor(varargin{9}) - varargin{9} < eps)
        s.screen_width = varargin{9};
    else
        varargin{9}
        error('screen_width must be an integer')
    end

    if (floor(varargin{10}) - varargin{10} < eps)
        s.screen_height = varargin{10};
    else
        error('screen_height must be an integer')
    end
    
    if (floor(varargin{11}) - varargin{11} < eps)
        s.num_dots = varargin{11};
    else
        error('num_dots must be an integer')
    end
    
    if (isfloat(varargin{12}) && varargin{12} >= 0 && varargin{12} <= 1)
        s.coherence = varargin{12};
    else
        error('coherence must be a double between 0 and 1')
    end
    
    if (isfloat(varargin{13}))
        s.speed = varargin{13};
    else
        error('speed must be a double')
    end
    
    if (floor(varargin{14}) - varargin{14} < eps)
        s.dot_size = varargin{14};
    else
        error('dot_size must be an integer')
    end
    
    if (floor(varargin{15}) - varargin{15} < eps)
        s.movie_duration = varargin{15};
    else
        error('movie_duration must be an integer')
    end
    
    if (floor(varargin{16}) - varargin{16} < eps)
        s.fps = varargin{16};
    else
        error('fps must be an integer')
    end
    
    if (length(varargin{17}) == 2 && isnumeric(varargin{16}))
        screen_zoom = varargin{17};
    else
        error('screen_zoom must be a 1x2 array with integer values')
    end
% s.screen_width = 100;         % for matrix
% s.screen_height = 100;        % for matrix
% s.num_dots = 1000;             % Number of dots to display
% s.coherence = .20;             % Percent of dots to move in a specified direction
% s.speed = 1;                  % How fast do our little dots move
% s.dot_size = 1;              % Width of dots in pixels
% s.movie_duration = 10;         % in seconds
% s.fps = 85; 

    % maxWidth, maxHeight, scale factor, intertrial luminance
    s = class(s,'coherentDots',stimManager(varargin{6},varargin{7},[6 6],uint8(1)));   
otherwise
    nargin
    error('Wrong number of input arguments')
end

s=setSuper(s,s.stimManager);