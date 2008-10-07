function t=phasedTrialManager(varargin)
% phasedTrialManager  class constructor. ABSTRACT CLASS - DO NOT INSTANTIATE
% t=phasedTrialManager(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuratio
% n,soundManager,reinforcementManager,customDescription, phases, [eyeTracker, eyeController])
%    

% phasedTMSpec:
%   phasedTMSpec.phases - OWNED BY phasedTrialManager, not trialManager
%   phasedTMSpec.msFlushDuration
%   phasedTMSpec.msMinimumPokeDuration
%   phasedTMSpec.msMinimumClearDuration
%   phasedTMSpec.soundManager
%   phasedTMSpec.reinforcementManager
%   phasedTMSpec.customDescription
%   [phasedTMSpec.eyeTracker] - OPTIONAL
%   [phasedTMSpec.eyeController] - OPTIONAL
%
%

% phases is the number of phases - useless
% phaseCriteria is a cell array of cell arrays that keeps the phase transition information in the following format:
% each element is a cell array that holds {key1, value1, key2, value2, ...} where each key is the set of ports that will advance to the corresponding value
% having more than one key-value pair means there are different phases you can transition to (eg Correct or Incorrect)


switch nargin
    case 0
        % if no input arguments, create a default object
        % use default phases and phaseDetails
        a=trialManager();
        t.phases = [];
        t = class(t,'phasedTrialManager',a);
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'phasedTrial'))
            t = varargin{1};
        elseif isstruct(varargin{1}) && ismember('phases', fields(varargin{1}))
            in = varargin{1};
            t.phases = in.phases;
            a = trialManager(in);
        else
            error('Input argument is not a phasedTrial object')
        end
        
        t=class(t,'phasedTrialManager',a);
        
    case {7 9}
        if nargin == 7
            a=trialManager(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{6});
        else
            a=trialManager(varargin{1},varargin{2},varargin{3},varargin{4},varargin{5},varargin{8},varargin{9},varargin{6});
        end
        
        if isscalar(varargin{7})
            t.phases = varargin{7};
        else
            error('Wrong input type for phases or phaseDetails')
        end
        t = class(t,'phasedTrialManager',a);
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end

        t=setSuper(t,t.trialManager);