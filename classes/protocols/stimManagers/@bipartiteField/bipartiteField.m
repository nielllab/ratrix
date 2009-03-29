function s=bipartiteField(varargin)
% BIPARTITEFIELD  class constructor.

% s = bipartiteField(receptiveFieldLocation,frequencies,duration,repetitions,maxWidth,maxHeight,scaleFactor,interTrialLuminance)
% receptiveFieldLocation - fractional location of receptive field; used to decide where to make the partition
% frequencies - an array of frequencies for switching from low to high luminance (black to white); in hz requested
% duration - seconds to spend in each frequency
% repetitions - number of times to cycle through all frequencies


s.receptiveFieldLocation=[];
s.frequencies=[]; % really this is not freq, but rather 1/freq (lower value = more cycles)
s.duration=[];
s.repetitions=[];
s.LUT=[];
s.LUTbits=0;
s.frames=[]; % internal variable for dynamic mode - never should be user-set

switch nargin
    case 0
        % if no input arguments, create a default object
        s = class(s,'bipartiteField',stimManager());
    case 1
        % if input is of this class type
        if (isa(varargin{1},'bipartiteField'))
            s = varargin{1};
        else
            error('Input argument is not a bipartiteField object')
        end
    case 8
        % create object using specified values
        % receptiveFieldLocation
        if (isvector(varargin{1}) && length(varargin{1}) == 2) || isa(varargin{1},'RFestimator')
            s.receptiveFieldLocation = varargin{1};
        else
            error('receptiveFieldLocation must be a two-element array [xPos yPos] as fractional locations, or an RFestimator');
        end
        % frequencies
        if isvector(varargin{2}) && isnumeric(varargin{2})
            if all(varargin{2}>=2)
                s.frequencies = varargin{2};
            else
                error('frequencies must be >2');
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
        s = class(s,'bipartiteField',stimManager(varargin{5},varargin{6},varargin{7},varargin{8}));
        
    otherwise
        error('invalid number of input arguments');
end

        
        
        