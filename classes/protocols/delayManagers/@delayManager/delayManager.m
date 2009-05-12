function f=delayManager(varargin)
% the base delayManager class
% OBJ=delayManager(label)
% currently, i cant think of any fields that this base class needs to have
% we only use this so that every method can inherit the abstract getDelayAndTimeout function

f.label=[];



switch nargin
    case 0
        % if no input arguments, create a default object
        
        f = class(f,'delayManager');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'delayManager'))
            f = varargin{1};
        elseif ischar(varargin{1})
            f.label=varargin{1};
            f = class(f,'delayManager');
        else
            error('Input argument is not a delayManager object')
        end
    otherwise
        nargin
        error('Wrong number of input arguments')
end

end % end function