function t=freeDrinks(varargin)
% FREEDRINKS  class constructor.
% t=freeDrinks(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,freeDrinkLikelihood, reinforcementManager, [eyeTracker,eyeController])

switch nargin
    case 0
        % if no input arguments, create a default object

        t.freeDrinkLikelihood=0;
        a=trialManager();
        t = class(t,'freeDrinks',a);
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'freeDrinks'))
            t = varargin{1};
        else
            error('Input argument is not a freeDrinks object')
        end
    case {6 8}

        if varargin{5}>=0
            t.freeDrinkLikelihood=varargin{5};
        else
            error('freeDrinkLikelihood must be >= 0')
        end

        d=sprintf('free drinks\n\t\t\tfreeDrinkLikelihood: %g',t.freeDrinkLikelihood);

        if nargin==6
            a=trialManager(varargin{1},varargin{2},varargin{3},varargin{4},varargin{6},d);        
        elseif nargin==8
            a=trialManager(varargin{1},varargin{2},varargin{3},varargin{4},varargin{6},varargin{7},varargin{8},d);
        else
            error('should never happen')
        end
        
        t = class(t,'freeDrinks',a);
    otherwise
        error('Wrong number of input arguments')
end

        t=setSuper(t,t.trialManager);
