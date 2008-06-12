function s=scheduler(varargin)
% SCHEDULER  class constructor.  ABSTRACT CLASS -- DO NOT INSTANTIATE
% s=scheduler()

switch nargin
    case 0
        % if no input arguments, create a default object
        s=struct([]);
        s = class(s,'scheduler',structable());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'scheduler'))
            s = varargin{1};
        else
            error('Input argument is not a scheduler object')
        end

    otherwise
        error('Wrong number of input arguments')
end

        s=setSuper(s,s.structable);