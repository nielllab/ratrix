function f=constantDelay(varargin)
% the subclass constantDelay class
% OBJ=constantDelay(value)
% value - in ms


f.value=[];

switch nargin
    case 0
        % if no input arguments, create a default object
        a=delayManager('constantDelay function');
        f = class(f,'constantDelay',a);
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'constantDelay'))
            f = varargin{1};
        elseif isnumeric(varargin{1}) && length(varargin{1})==1
            f.value=varargin{1};
            a=delayManager('constantDelay function');
            f=class(f,'constantDelay',a);
        else
            error('Input argument is not a constantDelay object or numeric value')
        end
    otherwise
        nargin
        error('wrong number of input arguments');
end

end % end function