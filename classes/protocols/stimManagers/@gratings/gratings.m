function s=gratings(varargin)
% GRATINGS  class constructor.
% s = gratings(pixPerCycs,driftfrequencies,orientations,phases,contrasts,durations,radii,annuli,location,waveform,normalizationMethod,mean,thresh,
%       maxWidth,maxHeight,scaleFactor,interTrialLuminance[,doCombos])
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
% radii - the std dev of the enveloping gaussian, (by default in normalized units of the diagonal of the stim region) - can be of length N (N masks)
% annuli - the radius of annuli that are centered inside the grating (in same units as radii)
% location - a 2x1 vector, specifying x- and y-positions where the gratings should be centered; in normalized units as fraction of screen
% waveform - 'square', 'sine', or 'none'
% normalizationMethod - 'normalizeDiagonal' (default), 'normalizeHorizontal', 'normalizeVertical', or 'none'
% mean - must be between 0 and 1
% thresh - must be greater than 0; in normalized luminance units, the value below which the stim should not appear
% doCombos - a flag that determines whether or not to take the factorialCombo of all parameters (default is true)
%   does the combinations in the following order:
%   pixPerCycs > driftfrequencies > orientations > contrasts > phases > durations
%   - if false, then takes unique selection of these parameters (they all have to be same length)
%   - in future, handle a cell array for this flag that customizes the combo selection process

s.pixPerCycs = [];
s.driftfrequencies = [];
s.orientations = [];
s.phases = [];
s.contrasts = [];
s.durations = []; 

s.radii = [];
s.annuli = [];
s.location = [];
s.waveform='square';
s.normalizationMethod='normalizeDiagonal';
s.mean = 0;
s.thresh = 0;

s.LUT =[];
s.LUTbits=0;

s.doCombos=true;

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
    case {17 18}
        % create object using specified values
        % check for doCombos argument first (it decides other error checking)
        if nargin==18 && islogical(varargin{18})
            s.doCombos=varargin{18};
        end
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
        % radii
        if isnumeric(varargin{7}) && all(varargin{7}>0)
            s.radii=varargin{7};
        else
            error('radii must be >= 0');
        end
        % annuli
        if isnumeric(varargin{8}) && all(varargin{8}>0)
            s.annuli=varargin{8};
        else
            error('all annuli must be >= 0');
        end
        % check that if doCombos is false, then all parameters must be same length
        if ~s.doCombos
            paramLength = length(s.pixPerCycs);
            if paramLength~=length(s.driftfrequencies) || paramLength~=length(s.orientations) || paramLength~=length(s.contrasts) ...
                    || paramLength~=length(s.phases) || paramLength~=length(s.durations) || paramLength~=length(s.radii) ...
                    || paramLength~=length(s.annuli)
                error('if doCombos is false, then all parameters (pixPerCycs, driftfrequencies, orientations, contrasts, phases, durations, radii, annuli) must be same length');
            end
        end           
        
        
        % location
        if isnumeric(varargin{9}) && all(varargin{9}>=0) && all(varargin{9}<=1)
            s.location=varargin{9};
        else
            error('all location must be >= 0 and <= 1');
        end        
        % waveform
        if ischar(varargin{10})
            if ismember(varargin{10},{'sine', 'square', 'none'})
                s.waveform=varargin{10};
            else
                error('waveform must be ''sine'', ''square'', or ''none''')
            end
        end
        % normalizationMethod
        if ischar(varargin{11})
            if ismember(varargin{11},{'normalizeVertical', 'normalizeHorizontal', 'normalizeDiagonal' , 'none'})
                s.normalizationMethod=varargin{11};
            else
                error('normalizationMethod must be ''normalizeVertical'', ''normalizeHorizontal'', or ''normalizeDiagonal'', or ''none''')
            end
        end
        % mean
        if varargin{12} >= 0 && varargin{12}<=1
            s.mean=varargin{12};
        else
            error('0 <= mean <= 1')
        end
        % thres
        if varargin{13} >= 0
            s.thresh=varargin{12};
        else
            error('thresh must be >= 0')
        end
        s = class(s,'gratings',stimManager(varargin{14},varargin{15},varargin{16},varargin{17}));
    otherwise
        error('Wrong number of input arguments')
end



