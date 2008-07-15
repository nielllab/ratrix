function s=rateCriterion(varargin)
% RATECRITERION  class constructor.  
% s=rateCriterion(trialsPerMin,consecutiveMins)

switch nargin
    case 0
        % if no input arguments, create a default object
        s.trialsPerMin=0;
        s.consecutiveMins=0;
        s = class(s,'rateCriterion',criterion());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'rateCriterion'))
            s = varargin{1};
        else
            error('Input argument is not a rateCriterion object')
        end
    case 2
        if varargin{1}>=0 && varargin{2}>=0
            s.trialsPerMin=varargin{1};
            s.consecutiveMins=varargin{2};
        else
            error('trialsPerMin and consecutiveMins must be >= 0')
        end
        s = class(s,'rateCriterion',criterion());
    otherwise
        error('Wrong number of input arguments')
end


        s=setSuper(s,s.criterion);