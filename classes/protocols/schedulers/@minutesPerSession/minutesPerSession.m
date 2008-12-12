function s=minutesPerSession(varargin)
% HOURRANGE  class constructor.
% s=minutesPerSession(minutes)

switch nargin
    case 0
        % if no input arguments, create a default object
        s.minutes=0;
        s.hoursBetweenSessions=0;
        s = class(s,'minutesPerSession',scheduler());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'minutesPerSession'))
            s = varargin{1};
        else
            error('Input argument is not a minutesPerSession object');

        end
    case 2
        if varargin{1}>0
            s.minutes=varargin{1};
        else
            error('must be more than 1 minute');
        end

        if varargin{2}>0
            s.hoursBetweenSessions=varargin{2};
        else
            error('must be positive');
        end

        s = class(s,'minutesPerSession',scheduler());
    otherwise
        error('Wrong number of input arguments');
end