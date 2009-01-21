function s=fullField(varargin)
% FULLFIELD  class constructor.

% s = fullField(contrast,frequencies,duration,repetitions,maxWidth,maxHeight,scaleFactor,interTrialLuminance)
% 
% contrast - contrast of the single pixel (difference between high and low luminance endpoints) - in the 0.0-1.0 scale
% frequencies - an array of frequencies for switching from low to high luminance (black to white); in hz requested
% duration - seconds to spend in each frequency
% repetitions - number of times to cycle through all frequencies

s.contrast=[];
s.frequencies=[]; % really this is not freq, but rather 1/freq (lower value = more cycles)
s.duration=[];
s.repetitions=[];
s.LUT=[];
s.LUTbits=0;
s.frames=[]; % internal variable for dynamic mode - never should be user-set

switch nargin
    case 0
        % if no input arguments, create a default object
        s = class(s,'fullField',stimManager());
    case 1
        % if input is of this class type
        if (isa(varargin{1},'fullField'))
            s = varargin{1};
        else
            error('Input argument is not a fullField object')
        end
    case 8
        % create object using specified values
        % contrast
        if isscalar(varargin{1})
            s.contrast = varargin{1};
        else
            error('contrast must be a scalar');
        end
        % frequencies
        if isvector(varargin{2}) && isnumeric(varargin{2})
            if all(varargin{2}>=2)
                s.frequencies = varargin{2};
            else
                error('frequencies must be >=2');
            end
        else
            error('frequencies must be numeric');
        end
        % duration
        if isscalar(varargin{3})
            s.duration = varargin{3};
        else
            error('duration must be a scalar');
        end
        % repetitions
        if isscalar(varargin{4}) && isnumeric(varargin{4})
            s.repetitions = varargin{4};
        else
            error('repetitions must be a scalar');
        end
        s = class(s,'fullField',stimManager(varargin{5},varargin{6},varargin{7},varargin{8}));
        
    otherwise
        error('invalid number of input arguments');
end

        
        