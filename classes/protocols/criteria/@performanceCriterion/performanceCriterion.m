function s=performanceCriterion(varargin)
% PERFORMANCECRITERION  class constructor.  
% s=performanceCriterion(pctCorrect,consecutiveTrials)

switch nargin
    case 0
        % if no input arguments, create a default object
        s.pctCorrect=0;
        s.consecutiveTrials=0;
        s = class(s,'performanceCriterion',criterion());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'performanceCriterion'))
            s = varargin{1};
        else
            error('Input argument is not a performanceCriterion object')
        end
    case 2
        if varargin{1}>=0 && varargin{1}<=1 && varargin{2}>=0
            s.pctCorrect=varargin{1};
            s.consecutiveTrials=varargin{2};
        else
            error('0<=pctCorrect<=1 and consecutiveTrials must be >= 0')
        end
        s = class(s,'performanceCriterion',criterion());
    otherwise
        error('Wrong number of input arguments')
end

        s=setSuper(s,s.criterion);