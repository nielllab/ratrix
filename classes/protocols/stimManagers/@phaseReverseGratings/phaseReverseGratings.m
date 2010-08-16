function s=phaseReverseGratings(varargin)

% PHASEREVERSEGRATINGS  class constructor.
% s = phaseReverseGratings(pixPerCycs,frequencies,orientations,startPhases,doCombos
%       contrasts,durations,radii,annuli,location,waveform,normalizationMethod,mean,thresh,numRepeats,maxWidth,maxHeight,scaleFactor,interTrialLuminance)
%
% Each of the following arguments is a 1xN vector, one element for each of N gratings
% pixPerCycs - specified as in orientedGabors
% frequencies - specified in cycles per second for now; the rate at which the grating moves across the screen
% orientations - in radians
% startPhases - starting phase of each grating frequency (in radians)%
% contrasts - normalized (0 <= value <= 1) - Mx1 vector%
% durations - up to MxN, specifying the duration (in seconds) of each pixPerCycs/contrast pair
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

% special only to phaseReverseGratings
s.pixPerCycs = [];
s.frequencies = [];
s.orientations = [];
s.startPhases = [];
s.waveform='square';


s.contrasts = [];
s.durations = [];
s.radii = [];
s.annuli = [];
s.location = [];
s.phaseform = 'sine';
s.normalizationMethod='normalizeDiagonal';
s.mean = 0;
s.thresh = 0;
s.numRepeats = [];

% s.maxWidth
% s.maxHeight
% s.scaleFactor
% s.interTrialLuminance

s.changeableAnnulusCenter=false;
s.doCombos=true;
s.ordering.method = 'ordered';
s.ordering.seed = [];

s.LUT =[];
s.LUTbits=0;

switch nargin
    case 0
        % if no input arguments, create a default object
        s = class(s,'phaseReverseGratings',phaseReverse());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'phaseReverseGratings'))
            s = varargin{1};
        else
            error('Input argument is not a phaseReverseGratings object')
        end
    case {19 20 21}
        % create object using specified values
        % special to phaseReverseGratings
        % pixPerCycs
        
        if isvector(varargin{1}) && isnumeric(varargin{1})
            s.pixPerCycs=varargin{1};
        else
            error('pixPerCycs must be numbers');
        end
        % frequencies
        if isvector(varargin{2}) && isnumeric(varargin{2}) && all(varargin{2})>0
            s.frequencies=varargin{2};
        else
            error('frequencies must all be > 0')
        end
        % orientations
        if isvector(varargin{3}) && isnumeric(varargin{3})
            s.orientations=varargin{3};
        else
            error('orientations must be numbers')
        end
        % phases
        if isvector(varargin{4}) && isnumeric(varargin{4})
            s.startPhases=varargin{4};
        else
            error('startPhases must be numbers');
        end
        % waveform
        if ischar(varargin{5})
            if ismember(varargin{5},{'sine', 'square', 'none','catcam530a','haterenImage1000'})
                s.waveform=varargin{5};
            else
                error('waveform must be ''sine'', ''square'', ''catcam530a'', or ''none''')
            end
        end
        
        % general to phaseReverse
        % contrasts
        if isvector(varargin{6}) && isnumeric(varargin{6})
            s.contrasts=varargin{6};
        else
            error('contrasts must be numbers');
        end
        % durations
        if isnumeric(varargin{7}) && all(all(varargin{7}>0))
            s.durations=varargin{7};
        else
            error('all durations must be >0');
        end
        % radii
        if isnumeric(varargin{8}) && all(varargin{8}>0)
            s.radii=varargin{8};
        else
            error('radii must be >= 0');
        end
        % annuli
        if isnumeric(varargin{9}) && all(varargin{9}>=0)
            s.annuli=varargin{9};
        else
            error('all annuli must be >= 0');
        end
        % numRepeats
        if isinteger(varargin{15}) || isinf(varargin{15}) || isNearInteger(varargin{15})
            s.numRepeats=varargin{15};
        end
        
        % location
        if isnumeric(varargin{10}) && all(varargin{10}>=0) && all(varargin{10}<=1)
            s.location=varargin{10};
        elseif isa(varargin{10},'RFestimator')
            s.location=varargin{10};
        else
            error('all location must be >= 0 and <= 1, or location must be an RFestimator object');
        end
      
        % phaseform
        if ischar(varargin{11})
            if ismember(varargin{11},{'sine', 'square'})
                s.phaseform=varargin{11};
            else
                error('phaseform must be ''sine'' or ''square''')
            end
        end
        % normalizationMethod
        if ischar(varargin{12})
            if ismember(varargin{12},{'normalizeVertical', 'normalizeHorizontal', 'normalizeDiagonal' , 'none'})
                s.normalizationMethod=varargin{12};
            else
                error('normalizationMethod must be ''normalizeVertical'', ''normalizeHorizontal'', or ''normalizeDiagonal'', or ''none''')
            end
        end
        % mean
        if varargin{13} >= 0 && varargin{13}<=1
            s.mean=varargin{13};
        else
            error('0 <= mean <= 1')
        end
        % thres
        if varargin{14} >= 0
            s.thresh=varargin{14};
        else
            error('thresh must be >= 0')
        end
        

        if nargin==19
            s = class(s,'phaseReverseGratings',phaseReverse(varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},...
            varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19}));
        elseif nargin==20
            s = class(s,'phaseReverseGratings',phaseReverse(varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},...
            varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19},varargin{20}));
        elseif nargin==21
            % check for doCombos argument first (it decides other error checking)
            if islogical(varargin{21})
                s.doCombos=varargin{21};
                s.ordering.method = 'ordered';
                s.ordering.seed = [];
            elseif iscell(varargin{21})&&(length(varargin{21})==3)
                s.doCombos = varargin{21}{1}; if ~islogical(s.doCombos), error('doCombos has to be a logical'),end;
                s.ordering.method = varargin{21}{2}; if ~ismember(s.ordering.method,{'twister','state','seed'}), error('unknown ordering method'), end;
                s.ordering.seed = varargin{21}{3};
            else
                error('unknown way to specify doCombos. its either just a logical or a cell length 3.');                    
            end
            s = class(s,'phaseReverseGratings',phaseReverse(varargin{6},varargin{7},varargin{8},varargin{9},varargin{10},varargin{11},varargin{12},...
                varargin{13},varargin{14},varargin{15},varargin{16},varargin{17},varargin{18},varargin{19},varargin{20}));
        end
        if ~s.doCombos
            paramLength = length(s.pixPerCycs);
            if paramLength~=length(s.frequencies) || paramLength~=length(s.orientations) || paramLength~=length(s.contrasts) ...
                    || paramLength~=length(s.phases) || paramLength~=length(s.durations) || paramLength~=length(s.radii) ...
                    || paramLength~=length(s.annuli)
                error('if doCombos is false, then all parameters (pixPerCycs, frequencies, orientations, contrasts, phases, durations, radii, annuli) must be same length');
            end
        end
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end


        
        % check that if doCombos is false, then all parameters must be same length

%         

%         if nargin>18
%             if ismember(varargin{19},[0 1])
%                 s.changeableAnnulusCenter=logical(varargin{19});
%             else
%                 error('gratingWithChangeableAnnulusCenter must be true / false')
%             end
%         end

