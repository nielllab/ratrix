function t=phasedTrialManager(varargin)
% phasedTrialManager  class constructor. ABSTRACT CLASS - DO NOT INSTANTIATE
% t=phasedTrialManager(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuratio
% n,soundManager,reinforcementManager,customDescription, phases, phaseCriteria)
%               
% phases is a 1D cell array of the phases in this phasedTrial
% phaseCriteria is a cell array of cell arrays that keeps the phase transition information in the following format:
% each element is a cell array that holds {key1, value1, key2, value2, ...} where each key is the set of ports that will advance to the corresponding value
% having more than one key-value pair means there are different phases you can transition to (eg Correct or Incorrect)


switch nargin
    case 0
        % if no input arguments, create a default object
        % use default phases and phaseDetails
        a=trialManager();
        t.phases = [];
        t.phaseCriteria = [];
        t = class(t,'phasedTrialManager',a);
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'phasedTrial'))
            t = varargin{1};
        else
            error('Input argument is not a phasedTrial object')
        end
    case 2
        % if phases and phaseCriteria are specified
        a=trialManager();
        if iscell(varargin{1}) && iscell(varargin{2})
            t.phases = varargin{1};
            t.phaseCriteria = varargin{2};
            t = class(t,'phasedTrialManager',a);
        else
            error('If two arguments are specified, they must be phases and phaseCritera as cell arrays');
        end
    case 8
        a=trialManager(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6});
        if iscell(varargin{7}) && iscell(varargin{8})
            t.phases = varargin{7};
            t.phaseCriteria = varargin{8};
        else
            error('Wrong input type for phases or phaseDetails')
        end
        t = class(t,'phasedTrialManager',a);
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end

        t=setSuper(t,t.trialManager);