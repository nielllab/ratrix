function s=criterion(varargin)
% CRITERION  class constructor.  ABSTRACT CLASS -- DO NOT INSTANTIATE
% s=criterion()

switch nargin
    case 0
        % if no input arguments, create a default object
        s=struct();
        s = class(s,'criterion');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'criterion'))
            s = varargin{1};
        else
            error('Input argument is not a criterion object')
        end

    otherwise
        error('Wrong number of input arguments')
end