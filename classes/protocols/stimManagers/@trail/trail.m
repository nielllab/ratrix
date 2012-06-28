function s=trail(varargin)
% TRAIL  class constructor.
% s = trail(in, maxWidth, maxHeight, scaleFactor, interTrialLuminance)

s.gain = 1 * ones(2,1);
s.targetDistance = 100;
s.timeoutSecs = 1;
s.slow = 10 * ones(2,1);
s.slowSecs = 1;
s.cue = false;
s.soundClue = false;

s.positional = nan;
s.stim = [];
s.dms = [];

s.initialPos=nan;
s.mouseIndices=nan;

switch nargin
    case 0  % if no input arguments, create a default object
        s = class(s,'trail',stimManager());
    case 1
        if (isa(varargin{1},'trail'))	% if single argument of this class type, return it
            s = varargin{1};
        else
            error('Input argument is not a trail object')
        end
    case 5
        d = varargin{1};
        
        cellfun(@validateField,{'gain','targetDistance','timeoutSecs','slow','slowSecs','positional','stim','cue','soundClue','dms'});
        
        s = class(s,'trail',stimManager(varargin{2},varargin{3},varargin{4},varargin{5}));
    otherwise
        error('Wrong number of input arguments')
end

    function validateField(f)
        if ~isfield(d,f) % || isempty(d.(f)) || isnan(d.(f))
            %error('trail requires %s', f)
        else
            s.(f) = d.(f);
        end
        x = s.(f);
        
        if (any(isobject(x)) || any(isstruct(x)) || ~all(isnan(x))) %for now, nans coming from loadobj ok...  can't isnan objects/structs!?!?
            switch f
                case 'gain'
                    if ~(isvector(x) && isnumeric(x) && isreal(x) && all(size(x)==[2 1]))
                        error('gain must be real numeric 2-element column vector') %negative entries ok :)
                    end
                case 'targetDistance'
                    if ~(isvector(x) && isnumeric(x) && isreal(x) && all(x>=0) && numel(x)<=2)
                        error('targetDistance must be real 1- or 2-element vector >= 0')
                    end
                case 'timeoutSecs'
                    if ~(isscalar(x) && isnumeric(x) && isreal(x) && x>=0)
                        error('timeoutSecs must be real numeric scalar >= 0')
                    end
                case 'slow'
                    if ~(isvector(x) && isnumeric(x) && isreal(x) && all(size(x)==[2 1]) && all(x>=0))
                        error('gain must be real numeric 2-element column vector with elements >= 0')
                    end
                case 'slowSecs'
                    if ~(isscalar(x) && isnumeric(x) && isreal(x) && x>=0)
                        error('slowSecs must be real numeric scalar >= 0')
                    end
                case 'positional'
                    if ~((isscalar(x) && islogical(x)) || (isvector(x) && ischar(x) && strcmp(x,'HUD')))
                        error('positional must be scalar logical or string ''HUD''')
                    end
                case 'stim'
                    if ~((isa(x,'stimManager') && isscalar(x)) || isempty(x) || ismember(x,{'flip','rand'}))
                        error('stim must be empty or a scalar stimManager or the string ''flip'' or ''rand''')
                    end
                case {'cue' 'soundClue'}
                    if ~all(cellfun(@(f)f(x),{@islogical @isscalar}))
                        error('cue and soundClue must be logical scalaer')
                    end  
                case 'dms'
                    if ~(isempty(x) || (isstruct(x) && all(cellfun(@(xf) all(cellfun(@(xff) xff(x.(xf)),{@isscalar @isreal @(x) x>=0 })),{'targetLatency','cueLatency','cueDuration'}))))
                        error('dms must be empty or struct with fields targetLatency, cueLatency, and cueDuration, all scalar reals >=0')
                    end
                otherwise
                    error('huh')
            end
        end
    end

end