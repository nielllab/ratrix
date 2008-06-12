function b=box(varargin)
% BOX  class constructor.
% b = box(id, path)

switch nargin
    case 0
        % if no input arguments, create a default object
        b.id=0;
        b.path='';

        b = class(b,'box');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'box'))
            b = varargin{1};
        else
            error('Input argument is not a box object')
        end
    case 2

        if varargin{1}>0 && isscalar(varargin{1}) && isinteger(varargin{1})
            b.id=varargin{1};
        else
            %varargin{1}
            %varargin{1}>0
            %isscalar(varargin{1})
            %isinteger(varargin{1})
            error('id must be positive scalar integer')
        end

        if checkPath(varargin{2})
            b.path=varargin{2};
        else
            error('path check failed. must provide fully resolved path to box for temporary storage of subjects'' trial data')
        end

        b = class(b,'box');
    otherwise
        error('Wrong number of input arguments')
end