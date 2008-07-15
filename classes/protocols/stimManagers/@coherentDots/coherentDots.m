function s=coherentDots(varargin)
% COHERENTDOTS  class constructor.
% ex: coherentDots(stimulus,junk,junk,junk,junk,maxWidth,maxHeight,junk,150, 100, 100, .85, 1, 3, 10, 85, [6 6]);


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
s.min_coherence = .8;
s.max_coherence = 1;
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
    
    if (isfloat(varargin{12}))
        s.coherence = 1;
        if (length(varargin{12}) == 1)
            if (varargin{12} >= 0 && varargin{12} <= 1)
                s.min_coherence = varargin{12}
                s.max_coherence = varargin{12}
            else
                error('Coherence must be between 0 and 1')
            end
        elseif (length(varargin{12}) == 2)
            if (varargin{12}(1) >= 0 && varargin{12}(1) <= 1 && varargin{12}(2) >= 0 && varargin{12}(2) <= 1 && (varargin{12}(2) - varargin{12}(1) > 0))
                s.min_coherence = varargin{12}(1);
                s.max_coherence = varargin{12}(2);
            else
                error('Coherence must be between 0 and 1, with max > min')
            end
        else
            error ('Coherence must be either a 1x2 or 1x1 set of floats')
        end
    else
        error('Coherence level must be a 1x1 or 1x2 array between 0 and 1')
    end
    
    if (isfloat(varargin{13}))
        s.speed = varargin{13};
    else
        error('speed (pixels/frame) must be a double')
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
    
    if (length(varargin{17}) == 2 && isnumeric(varargin{17}))
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
    s = class(s,'coherentDots',stimManager(varargin{6},varargin{7},screen_zoom,uint8(0)));   
otherwise
    nargin
    error('Wrong number of input arguments')
end

s=setSuper(s,s.stimManager);
