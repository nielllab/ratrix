function s=randomBursts(varargin)
% RANDOMBURSTS  class constructor.  
% s=randomBursts(minsPerBurst,burstsPerDay)

switch nargin
    case 0
        % if no input arguments, create a default object
        s.minsPerBurst=0;
        s.burstsPerDay=0;
        s = class(s,'randomBursts',scheduler());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'randomBursts'))
            s = varargin{1};
        else
            error('Input argument is not a randomBursts object')
        end
    case 2
        if varargin{1}>=0 && varargin{2}>=0
            s.minsPerBurst=varargin{1};
            s.burstsPerDay=varargin{2};
        else
            error('minsPerBurst and burstsPerDay must be >= 0')
        end
        s = class(s,'randomBursts',scheduler());
    otherwise
        error('Wrong number of input arguments')
end