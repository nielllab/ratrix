function s=gratings(varargin)
% GRATINGS  class constructor.
% s = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radius,location,waveform,normalizationMethod,mean,thresh,
%       maxWidth,maxHeight,scaleFactor,interTrialLuminance)
% Each of the following arguments is a 1xN vector, one element for each of N gratings
% pixPerCycs - specified as in orientedGabors
% driftfrequency - specified in cycles per second for now; the rate at which the grating moves across the screen
% orientations - in radians
% phases - starting phase of each grating frequency (in radians)
%
% contrasts - normalized (0 <= value <= 1) - Mx1 vector
%
% durations - up to MxN, specifying the duration (in seconds) of each pixPerCycs/contrast pair
%
% radius - the std dev of the enveloping gaussian, (by default in normalized units of the diagonal of the stim region)
% location - a 2x1 vector, specifying x- and y-positions where the gratings should be centered; in normalized units as fraction of screen
% waveform - 'square', 'sine', or 'none'
% normalizationMethod - 'normalizeDiagonal' (default), 'normalizeHorizontal', 'normalizeVertical', or 'none'
% mean - must be between 0 and 1
% thresh - must be greater than 0; in normalized luminance units, the value below which the stim should not appear

s.pixPerCycs = [];
s.driftfrequencies = [];
s.orientations = [];
s.phases = [];
s.contrasts = [];
s.durations = []; 

s.radius = [];
s.location = [];
s.waveform='square';
s.normalizationMethod='normalizeDiagonal';
s.mean = 0;
s.thresh = 0;

s.LUT =[];
s.LUTbits=0;


switch nargin
    case 0
        % if no input arguments, create a default object
        s = class(s,'gratings',stimManager());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'gratings'))
            s = varargin{1};
        else
            error('Input argument is not a gratings object')
        end
    case 16
        % create object using specified values
        % pixPerCycs
        if isvector(varargin{1}) && isnumeric(varargin{1})
            s.pixPerCycs=varargin{1};
        else
            error('pixPerCycs must be numbers');
        end
        % driftfrequency
        if isvector(varargin{2}) && isnumeric(varargin{2}) && all(varargin{2})>0
            s.driftfrequencies=varargin{2};
        else
            error('driftfrequencies must all be > 0')
        end
        % orientations
        if isvector(varargin{3}) && isnumeric(varargin{3})
            s.orientations=varargin{3};
        else
            error('orientations must be numbers')
        end
        % phases
        if isvector(varargin{4}) && isnumeric(varargin{4})
            s.phases=varargin{4};
        else
            error('phases must be numbers');
        end
        % contrasts
        if isvector(varargin{5}) && isnumeric(varargin{5})
            s.contrasts=varargin{5};
        else
            error('contrasts must be numbers');
        end
         % durations
        if isnumeric(varargin{6}) && all(all(varargin{6}>0))
            s.durations=varargin{6};
        else
            error('all durations must be >0');
        end
        % radius
        if isscalar(varargin{7})
            s.radius=varargin{7};
        else
            error('radius must be >= 0');
        end
        % location
        if isnumeric(varargin{8}) && all(varargin{8}>=0) && all(varargin{8}<=1)
            s.location=varargin{8};
        else
            error('all location must be >= 0 and <= 1');
        end

        % check that all these 1xN and 2xN arrays are same length
        % pixPerCycs must be numGratings long, but everything else can be a single element (same value for all gratings)
        NLength = length(s.pixPerCycs);
        if ~((length(s.driftfrequencies)==NLength || length(s.driftfrequencies)==1) && ...
                (length(s.orientations)==NLength || length(s.orientations)==1) && ...
                (length(s.phases)==NLength || length(s.phases)==1))
            error('pixPerCycs, driftfrequencies, orientations, and phases must contain the same number of gratings');
        end
        
        % check that durations is one of the following:
        %   - [1x1]: for all frequencies and contrasts
        %   - [1xN]: one per frequency
        %   - [Mx1]: one per contrast
        %   - [MxN]: one per contrast-frequency pair
        MLength = length(s.contrasts);
        if ~(length(s.durations) == 1 || all(size(s.durations) == [1 NLength]) || ...
                all(size(s.durations) == [MLength 1]) || all(size(s.durations) == [MLength NLength]))
            size(s.durations)
            MLength
            NLength
            error('durations must be [1x1], [1xN], [Mx1], or [MxN]');
        end
        
        % waveform
        if ischar(varargin{9})
            if ismember(varargin{9},{'sine', 'square', 'none'})
                s.waveform=varargin{9};
            else
                error('waveform must be ''sine'', ''square'', or ''none''')
            end
        end
        % normalizationMethod
        if ischar(varargin{10})
            if ismember(varargin{10},{'normalizeVertical', 'normalizeHorizontal', 'normalizeDiagonal' , 'none'})
                s.normalizationMethod=varargin{10};
            else
                error('normalizationMethod must be ''normalizeVertical'', ''normalizeHorizontal'', or ''normalizeDiagonal'', or ''none''')
            end
        end
        % mean
        if varargin{11} >= 0 && varargin{11}<=1
            s.mean=varargin{11};
        else
            error('0 <= mean <= 1')
        end
        % thres
        if varargin{12} >= 0
            s.thresh=varargin{12};
        else
            error('thresh must be >= 0')
        end
        s = class(s,'gratings',stimManager(varargin{13},varargin{14},varargin{15},varargin{16}));
    otherwise
        error('Wrong number of input arguments')
end



