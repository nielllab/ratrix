function s=structable(varargin)
s.super=struct([]);

switch nargin
    case 0
        % if no input arguments, create a default object

        s = class(s,'structable');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'structable'))
            s = varargin{1};
        elseif isobject(varargin{1})
            s.super=varargin{1};
        else
            error('input to constructor must be an object')
        end
    otherwise
        error('wrong num inputs')
end