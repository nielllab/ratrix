function t=freeDrinks(varargin)
% FREEDRINKS  class constructor.
% t=freeDrinks(soundManager,freeDrinkLikelihood, reinforcementManager, 
%   [eyeController],[frameDropCorner],[dropFrames],[displayMethod],[requestPorts])

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
    case {3 4 5 6 7 8}

        % freeDrinkLikelihood
        if varargin{2}>=0
            t.freeDrinkLikelihood=varargin{2};
        else
            error('freeDrinkLikelihood must be >= 0')
        end

        d=sprintf('free drinks\n\t\t\tfreeDrinkLikelihood: %g',t.freeDrinkLikelihood);

        
        for i=4:8
            if i <= nargin
                args{i}=varargin{i};
            else
                args{i}=[];
            end
        end
        
        % requestPorts
        if isempty(args{8})
            args{8}='none'; % default autopilot requestPorts should be 'none'
        end

        a=trialManager(varargin{1},varargin{3},args{4},d,args{5},args{6},args{7},args{8});
        
        t = class(t,'freeDrinks',a);
    otherwise
        error('Wrong number of input arguments')
end