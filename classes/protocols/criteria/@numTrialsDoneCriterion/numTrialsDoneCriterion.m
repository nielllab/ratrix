function s=numTrialsDoneCriterion(varargin)
% NUMTRIALSDONECRITERION  class constructor.  
% s=numTrialsDoneCriterion([numTrialsNeeded])

switch nargin
    case 0
        % if no input arguments, create a default object
        s.numTrialsNeeded = 1;
        s = class(s,'numTrialsDoneCriterion',criterion());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'numTrialsDoneCriterion'))
            s = varargin{1};
        elseif isscalar(varargin{1})
            s.numTrialsNeeded = varargin{1};
            s = class(s,'numTrialsDoneCriterion',criterion());
        else
            error('Input argument is not a numTrialsDoneCriterion object')
        end
    otherwise
        error('Wrong number of input arguments')
end
