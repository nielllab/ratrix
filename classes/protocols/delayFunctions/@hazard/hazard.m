function f=hazard(varargin)
% the subclass hazard class
% OBJ=hazard(rate, earliestStimTime, latestStimTime, forceshowAtLastChance)

f.rate=[];
f.earliestStimTime=[];
f.latestStimTime=[];
f.forceShowAtLastChance=[];


switch nargin
    case 0
        % if no input arguments, create a default object
        a=delayFunction('hazard function');
        f.rate=0;
        f.earliestStimTime=0;
        f.latestStimTime=Inf;
        f.forceShowAtLastChance=false;
        f = class(f,'hazard',a);
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'hazard'))
            f = varargin{1};
        else
            error('Input argument is not a hazard object')
        end
    case 4
        % rate
        if isscalar(varargin{1}) && varargin{1}>=0 && varargin{1}<=1
            f.rate=varargin{1};
        else
            error('rate must be >=0 and <=1');
        end
        % earliestStimTime
        if isscalar(varargin{2})
            f.earliestStimTime=varargin{2};
        else
            error('earliestStimTime must be scalar');
        end
        % latestStimTime
        if isscalar(varargin{3})
            f.latestStimTime=varargin{3};
        else
            error('latestStimTime must be scalar');
        end
        if f.earliestStimTime>f.latestStimTime
            error('earliestStimTime must be earlier than latestStimTime');
        end
        % forceShowAtLastChance
        if islogical(varargin{4})
            f.forceShowAtLastChance=varargin{4};
        else
            error('forceShowAtLastChance must be logical');
        end
        a=delayFunction('hazard function');
        f = class(f,'hazard',a);
    otherwise
        nargin
        error('wrong number of input arguments');
end

end % end function