function s=noTimeOff()
% NOTIMEOFF  class constructor.  
% s=noTimeOff()

switch nargin
    case 0
        % if no input arguments, create a default object
        s=struct([]);
        s = class(s,'noTimeOff',scheduler());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'noTimeOff'))
            s = varargin{1};
        else
            error('Input argument is not a noTimeOff object')
        end
    otherwise
        error('Wrong number of input arguments')
end
        s=setSuper(s,s.scheduler);