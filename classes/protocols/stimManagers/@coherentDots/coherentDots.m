function s=coherentDots(varargin)
% COHERENTDOTS  class constructor.
% s=coherentDots(screen_width,screen_height,num_dots,coherence,speed,contrast,
%   dot_size,movie_duration,screen_zoom,maxWidth,maxHeight,[replayMode,interTrialLuminance])
%   screen_width - width of sourceRect (determines size of texture to make)
%   screen_height - height of sourceRect (determines size of texture to make)
%   num_dots - number of dots to draw
%   coherence - either a single coherence value, or a 2-element array specifying a range of coherence values from which to draw randomly every trial
%   speed - either a single speed value, or a 2-element array specifying a range to randomly draw from every trial
%   contrast - either a single contrast value, or a 2-element array specifying a range to randomly draw from every trial
%   dot_size - size in pixels of each dot (square)
%   movie_duration - length of the movie in seconds
%   screen_zoom - scaleFactor argument passed to stimManager constructor
%   interTrialLuminance - (optional) defaults to 0
%

eps = 0.0000001;
s.screen_width = 100;         % for matrix
s.screen_height = 100;        % for matrix
s.num_dots = 100;             % Number of dots to display
s.coherence = .8;             % Percent of dots to move in a specified direction
s.speed = 1;                  % How fast do our little dots move
s.contrast = 1;               % contrast of the dots
s.dot_size = 9;              % Width of dots in pixels
s.movie_duration = 2;         % in seconds
s.replayMode='loop';

s.sideDisplay=1; %pct screen width to use
s.position=.5; %.5 is center, 0 is in movement direction
s.shapeMethod='';
s.background=[];

s.LUT=[];
s.LUTbits=0;

screen_zoom = [6 6];

switch nargin
    case 0
        % if no input arguments, create a default object
        
        s = class(s,'coherentDots',stimManager());
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'coherentDots'))
            s = varargin{1};
        else
            error('Input argument is not an coherentDots object')
        end
    case {11 12 13}
        % screen_width
        if (floor(varargin{1}) - varargin{1} < eps)
            s.screen_width = varargin{1};
        else
            varargin{1}
            error('screen_width must be an integer')
        end
        % screen_height
        if (floor(varargin{2}) - varargin{2} < eps)
            s.screen_height = varargin{2};
        else
            error('screen_height must be an integer')
        end
        % num_dots
        if (floor(varargin{3}) - varargin{3} < eps)
            s.num_dots = varargin{3};
        else
            error('num_dots must be an integer')
        end
        % coherence
        if (isfloat(varargin{4}))
            s.coherence = 1;
            if (length(varargin{4}) == 1)
                if (varargin{4} >= 0 && varargin{4} <= 1)
                    s.coherence = varargin{4};
                else
                    error('Coherence must be between 0 and 1')
                end
            elseif (length(varargin{4}) == 2)
                if (varargin{4}(1) >= 0 && varargin{4}(1) <= 1 && varargin{4}(2) >= 0 && varargin{4}(2) <= 1 && (varargin{4}(2) - varargin{4}(1) > 0))
                    s.coherence=varargin{4};
                else
                    error('Coherence must be between 0 and 1, with max > min')
                end
            else
                error ('Coherence must be either a 1x2 or 1x1 set of floats')
            end
        else
            error('Coherence level must be a 1x1 or 1x2 array between 0 and 1')
        end
        % speed
        if (isfloat(varargin{5})) && (isscalar(varargin{5}) || length(varargin{5})==2)
            if (length(varargin{5})==2) && ~(varargin{5}(1)<=varargin{5}(2))
                error('range of speed must be [min max]');
            end
            s.speed = varargin{5};
        else
            error('speed (pixels/frame) must be a double or a 2-element array specifying a range')
        end
        % contrast
        if (length(varargin{6})==1 || length(varargin{6})==2) && all(isnumeric(varargin{6})) && ...
                all(varargin{6} >=0) && all(varargin{6} <=1)
            if length(varargin{6})==2 && ~(varargin{6}(1)<=varargin{6}(2))
                error('range of contrast must be [min max]');
            end
            s.contrast = varargin{6};
        else
            error('contrast must be >=0 and <=1 and be a single number or a 2-element array specifying a range');
        end
        
        % screen_zoom
        if (length(varargin{9}) == 2 && isnumeric(varargin{9}))
            screen_zoom = varargin{9};
        else
            error('screen_zoom must be a 1x2 array with integer values')
        end
        
        for i=12:13
            if i <= nargin
                args{i}=varargin{i};
            else
                args{i}=[];
            end
        end
        
        isValidRange = @(x) isvector(x) && length(x)<=2 && all(diff(x)>=0);
        
        % dot_size
        if all(varargin{7}>=0) && isreal(varargin{7}) && isValidRange(varargin{7}) && ...
                (strcmp(args{12},'expert') || all(mod(varargin{7},1)==1))
            s.dot_size = varargin{7};
        else
            error('dot_size must be a 1- or 2-element real increasing vector >=0, and integers if not expert')
        end
        
        % movie_duration
        if all(varargin{8}>=0) && isreal(varargin{8}) && ...
                ((strcmp(args{12},'expert') && isscalar(varargin{8}) && isinf(varargin{8})) || ...
                (isValidRange(varargin{8}) && all(mod(varargin{8},1)==1)))
            s.movie_duration = varargin{8};
        else
            error('movie_duration must be a 1- or 2-element real increasing vector of integers >=0 or scalar inf for expert')
        end
        
        % replayMode
        if ~isempty(args{12})
            if ismember(args{12},{'loop','once','expert'})
                s.replayMode=args{12};
            else
                error('replay mode must be ''loop'' or ''once'' or ''expert''');
            end
        else
            s.replayMode='loop';
        end
        
        % maxWidth, maxHeight, scale factor, intertrial luminance
        if isempty(args{13})
            s = class(s,'coherentDots',stimManager(varargin{10},varargin{11},screen_zoom,uint8(0)));
        else
            % check intertrial luminance
            if args{13} >=0 && args{13} <= 1
                s = class(s,'coherentDots',stimManager(varargin{10},varargin{11},screen_zoom,args{13}));
            else
                error('interTrialLuminance must be <=1 and >=0 - will be converted to a uint8 0-255');
            end
        end
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end