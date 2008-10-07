function s=examplePhased(varargin)
% examplePhased  class constructor.
% stim = examplePhased(maxWidth, maxHeight, scaleFactor, interTrialLuminance)
% just build a default examplePhased (stimManager) object with sample parameters

% phases is the number of phases - useless
% phaseCriteria is a cell array of cell arrays that keeps the phase transition information in the following format:
% each element is a cell array that holds {key1, value1, key2, value2, ...} where each key is the set of ports that will advance to the corresponding value
% having more than one key-value pair means there are different phases you can transition to (eg Correct or Incorrect)
% ports can be from the set {'any', 'request', 'response', 'target', 'distractor', 'none'} - not known here which ports are the actual response/distractors


% phases and phaseCriteria should also be hard-coded here b/c a lot of parameters depend on calcStim
% each different set of parameters and phases needs to be a different stimManager
s.LUT =[];
s.LUTbits = 0;
s.phases = {'start', 'discrim', 'correct', 'incorrect', 'end'};
s.phaseCriteria = {{'request',2}, {'target',3,'distractor',4}, {'none',5}, {'none',5}, {'none',5}};

switch nargin
    case 0
        % if no input arguments, create a default object
        % use default phases and phaseDetails
        a=stimManager();
        s = class(s,'examplePhased',a);
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'examplePhased'))
            s = varargin{1};
        else
            error('Input argument is not a examplePhased object')
        end
    case 4
        a=stimManager(varargin{1},varargin{2},varargin{3},varargin{4});
        s = class(s,'examplePhased',a);
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end

        s=setSuper(s,s.stimManager);