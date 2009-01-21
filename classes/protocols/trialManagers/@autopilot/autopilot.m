function t=autopilot(varargin)
% AUTOPILOT  class constructor.
% t=autopilot(percentCorrectionTrials,msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,...
%                rewardManager,[datanet],[eyeTracker,eyeController])
%
% Used for the whiteNoise, bipartiteField, fullField, and gratings stims, which don't require any response to go through the trial
% basically just play through the stims, with no sounds, no correction trials

switch nargin
    case 0
        % if no input arguments, create a default object

        a=trialManager();
        t.percentCorrectionTrials=0;

        t = class(t,'autopilot',a);
        
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'autopilot'))
            t = varargin{1};
        else
            error('Input argument is not a autopilot object')
        end
    case {6 7 8 9}
        % percentCorrectionTrials
        if varargin{1}>=0 && varargin{1}<=1
            t.percentCorrectionTrials=varargin{1};
        else
            error('1 >= percentCorrectionTrials >= 0')
        end
        
        d=sprintf('autopilot');

        if nargin==6 % no optional arguments
            a=trialManager(varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},d);
        elseif nargin==7 % datanet
            a=trialManager(varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},d,varargin{7});
        elseif nargin==8 % eyeTracker and eyeController, no datanet
            a=trialManager(varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{7},varargin{8},d);
        elseif nargin==9 % all optional arguments
            a=trialManager(varargin{2},varargin{3},varargin{4},varargin{5},varargin{6},varargin{8},varargin{9},d,varargin{7});
        else
            error('should never happen')
        end
        
        t = class(t,'autopilot',a);
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end

