function s=orientedGabors(varargin)
% ORIENTEDGABORS  class constructor.
% s = orientedGabors([pixPerCycs],[targetOrientations],[distractorOrientations],mean,radius,contrasts,thresh,normalizedPosition,maxWidth,maxHeight,scaleFactor,interTrialLuminance,[waveform],[normalizedSizeMethod],[axis])
% orientations in radians
% mean, contrasts, normalizedPosition (0 <= value <= 1)
% radius is the std dev of the enveloping gaussian, (by default in normalized units of the diagonal of the stim region)
% thresh is in normalized luminance units, the value below which the stim should not appear

s.pixPerCycs = [];
s.targetOrientations = [];
s.distractorOrientations = [];

s.mean = 0;
s.radius = 0;
s.contrasts = 0;
s.thresh = 0;
s.pos = .5;

s.LUT =[];
s.LUTbits=0;
s.waveform='square';
s.normalizedSizeMethod='normalizeDiagonal';

s.axis = 0;

opts = 12:15;

switch nargin
    case 0
        % if no input arguments, create a default object
        
        s = class(s,'orientedGabors',stimManager());
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'orientedGabors'))
            s = varargin{1};
        else
            error('Input argument is not an orientedGabors object')
        end
    case num2cell(opts,[1 length(opts)])
        % create object using specified values
        
        if all(varargin{1})>0
            s.pixPerCycs=varargin{1};
        else
            error('pixPerCycs must all be > 0')
        end
        
        if all(cellfun(@(f) all(cellfun(@(x) f(x) || isempty(x),{varargin{2} varargin{3}})),{@isreal @isvector @isnumeric})) || ...
                (strcmp(varargin{3},'abstract') && all(cellfun(@(f)f(varargin{2}),{@iscell @isvector})) && all(cellfun(@(f) all(cellfun(@(x) f(x) || isempty(x),varargin{2})),{@isreal @isvector @isnumeric})))
            s.targetOrientations=varargin{2};
            s.distractorOrientations=varargin{3};
        else
            error('target and distractor orientations must be real numeric vectors or, if distractor orientations is ''abstract'', target orientations must be a cell vector of real numeric vectors')
        end
        
        if varargin{4} >= 0 && varargin{4}<=1
            s.mean=varargin{4};
        else
            error('0 <= mean <= 1')
        end
        
        if varargin{5} >=0
            s.radius=varargin{5};
        else
            error('radius must be >= 0')
        end
        
        if all(isnumeric(varargin{6}))
            s.contrasts=varargin{6};
        else
            error('contrasts must be numeric')
        end
        
        if varargin{7} >= 0
            s.thresh=varargin{7};
        else
            error('thresh must be >= 0')
        end
        
        s.pos = varargin{8};
        if all(cellfun(@(f)f(s.pos),{@isvector,@isreal,@isnumeric,@(x)~isempty(x),@(x)all(cellfun(@(g)all(g(x)),{@(x)x>=0 & x<=1}))}))
            %pass
        else
            error('position must be real numeric vector -- elements 0<=x<=1')
        end
        
        if nargin>=13 && ~isempty(varargin{13})
            if ismember(varargin{13},{'sine', 'square', 'none'})
                s.waveform=varargin{13};
            else
                error('waveform must be ''sine'', ''square'', or ''none''')
            end
        end
        
        if nargin>=14 && ~isempty(varargin{14})
            if ismember(varargin{14},{'normalizeVertical', 'normalizeHorizontal', 'normalizeDiagonal' , 'none'})
                s.normalizedSizeMethod=varargin{14};
            else
                error('normalizeMethod must be ''normalizeVertical'', ''normalizeHorizontal'', or ''normalizeDiagonal'', or ''none''')
            end
        end
        
        if nargin>=15 && ~isempty(varargin{15})
            s.axis = varargin{15};
            if all(cellfun(@(f)f(s.axis),{@isscalar,@isreal,@isnumeric,@isfinite}))
                %pass
            else
                error('axis must be real finite numeric scalar radian angle (default 0 = horiz)')
            end
        end
        
        s = class(s,'orientedGabors',stimManager(varargin{9},varargin{10},varargin{11},varargin{12}));
        
    otherwise
        error('Wrong number of input arguments')
end