function s=performanceCriterion(varargin)
% PERFORMANCECRITERION  class constructor.  
% s=performanceCriterion(pctCorrect,consecutiveTrials)
%percent correct is a vector of possible graduation points, the first one
%that is reached will cause a graduation. For example: 
%performanceCriterion([.95, .85], [20,200]);
%will graduate a subject if he is 95% correct after 20 consecutive trials
%or if he is at least 85% correct after 200 consecutive trials

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
        if size(varargin{1})~=size(varargin{2})
            error('size of percent correct must be the same as the size of consecutive trials')
        end    
        if all(varargin{1}>=0 & varargin{1}<=1) && isinteger(varargin{2}) && all(varargin{2}>=1)
            s.pctCorrect=varargin{1};
            s.consecutiveTrials=varargin{2};
        else
            error('0<=pctCorrect<=1 and consecutiveTrials must be an integer >= 1')
        end
        s = class(s,'performanceCriterion',criterion());
    otherwise
        error('Wrong number of input arguments')
end

        s=setSuper(s,s.criterion);