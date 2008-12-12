function s=hourRange(varargin)
% HOURRANGE  class constructor.  
% s=randomBursts(startHour,endHour)

switch nargin
    case 0
        % if no input arguments, create a default object
        s.startHour=0;
        s.endHour=0;
        s = class(s,'hourRange',scheduler());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'hourRange'))
            s = varargin{1};
        else
            error('Input argument is not a hourRange object')
        end
    case 2
        if varargin{1}>=0 && varargin{2}<=24
            s.startHour=varargin{1};
            s.endHour=varargin{2};
        else
            error('startHour must be >=0 and endHour must be <=24')
        end
        s = class(s,'hourRange',scheduler());
    otherwise
        error('Wrong number of input arguments')
end