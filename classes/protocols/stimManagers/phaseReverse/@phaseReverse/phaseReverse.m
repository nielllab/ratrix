function s=phaseReverse(varargin)
% ---------ABSTRACT CLASS DO NO INSTANTIATE--------------
% PHASEREVERSE  class constructor.
% s = phaseReverse(contrasts,durations,radii,annuli,location,waveform,normalizationMethod,mean,thresh,numRepeats,
%       maxWidth,maxHeight,scaleFactor,interTrialLuminance)
%
% contrasts - normalized (0 <= value <= 1) - Mx1 vector
% durations - up to MxN, specifying the duration (in seconds) of each
% pixPerCycs/contrast pair
% radii - the std dev of the enveloping gaussian, (by default in normalized units of the diagonal of the stim region) - can be of length N (N masks)
% annuli - the radius of annuli that are centered inside the grating (in same units as radii)
% location - a 2x1 vector, specifying x- and y-positions where the gratings should be centered; in normalized units as fraction of screen
%           OR: a RFestimator object that will get an estimated location when needed
% waveform - 'square', 'sine', or 'none'
% normalizationMethod - 'normalizeDiagonal' (default), 'normalizeHorizontal', 'normalizeVertical', or 'none'
% mean - must be between 0 and 1
% thresh - must be greater than 0; in normalized luminance units, the value below which the stim should not appear
% numRepeats - how many times to cycle through all combos
% doCombos - a flag that determines whether or not to take the factorialCombo of all parameters (default is true)
%   does the combinations in the following order:
%   pixPerCycs > driftfrequencies > orientations > contrasts > phases > durations
%   - if false, then takes unique selection of these parameters (they all have to be same length)
%   - in future, handle a cell array for this flag that customizes the
%   combo selection process.. if so, update analysis too
% doPhaseInversion - the gratings is no longer a traveling wave and is instead a standing wave.


s.contrasts = [];
s.durations = [];
s.radii = [];
s.annuli = [];
s.location = [];
s.phaseform='sine';
s.normalizationMethod='normalizeDiagonal';
s.mean = 0;
s.thresh = 0;
s.numRepeats = [];

% s.maxWidth
% s.maxHeight
% s.scaleFactor
% s.interTrialLuminance

s.changeableAnnulusCenter=false;
s.LUT =[];
s.LUTbits=0;

switch nargin
    case 0
        % if no input arguments, create a default object
        s = class(s,'phaseReverse',stimManager());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'phaseReverse'))
            s = varargin{1};
        else
            error('Input argument is not a gratings object')
        end
    case {14 15}        
        % create object using specified values
        % check for doCombos argument first (it decides other error checking)
        % contrasts
        if isvector(varargin{1}) && isnumeric(varargin{1})
            s.contrasts=varargin{1};
        else
            error('contrasts must be numbers');
        end
         % durations
        if isnumeric(varargin{2}) && all(all(varargin{2}>0))
            s.durations=varargin{2};
        else
            error('all durations must be >0');
        end
        % radii
        if isnumeric(varargin{3}) && all(varargin{3}>0)
            s.radii=varargin{3};
        else
            error('radii must be >= 0');
        end
        % annuli
        if isnumeric(varargin{4}) && all(varargin{4}>=0)
            s.annuli=varargin{4};
        else
            error('all annuli must be >= 0');
        end
        % numRepeats
        if isinteger(varargin{10}) || isinf(varargin{10}) || isNearInteger(varargin{10})
            s.numRepeats=varargin{10};
        end        
        % location
        if isnumeric(varargin{5}) && all(varargin{5}>=0) && all(varargin{5}<=1)
            s.location=varargin{5};
        elseif isa(varargin{5},'RFestimator')
            s.location=varargin{5};
        else
            error('all location must be >= 0 and <= 1, or location must be an RFestimator object');
        end
        % phaseform
        if ischar(varargin{6})
            if ismember(varargin{6},{'sine', 'square'})
                s.phaseform=varargin{6};
            else
                error('phaseform must be ''sine'' or ''square''')
            end
        end
        % normalizationMethod
        if ischar(varargin{7})
            if ismember(varargin{7},{'normalizeVertical', 'normalizeHorizontal', 'normalizeDiagonal' , 'none'})
                s.normalizationMethod=varargin{7};
            else
                error('normalizationMethod must be ''normalizeVertical'', ''normalizeHorizontal'', or ''normalizeDiagonal'', or ''none''')
            end
        end
        % mean
        if varargin{8} >= 0 && varargin{8}<=1
            s.mean=varargin{8};
        else
            error('0 <= mean <= 1')
        end
        % thres
        if varargin{9} >= 0
            s.thresh=varargin{9};
        else
            error('thresh must be >= 0')
        end
        
        if nargin>14
            
            if ismember(varargin{15},[0 1])
                s.changeableAnnulusCenter=logical(varargin{15});
            else
                error('gratingWithChangeableAnnulusCenter must be true / false')
            end
        end

        s = class(s,'phaseReverse',stimManager(varargin{11},varargin{12},varargin{13},varargin{14}));
    otherwise
        nargin
        error('Wrong number of input arguments')
end



