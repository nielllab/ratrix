function s=images(varargin)
% IMAGES  class constructor.
% s = images(directory,yPositionPercent,background,maxWidth,maxHeight,scaleFactor,interTrialLuminance)
% yPositionPercent (0 <= value <= 1), in normalized units of the diagonal of the stim region

s.directory = '';
s.background=0;
s.yPositionPercent=0;
s.cache=[];

switch nargin
    case 0
        % if no input arguments, create a default object

        s = class(s,'images',stimManager());

    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'images'))
            s = varargin{1};
        else
            error('Input argument is not an images object')
        end
    case 7
        % create object using specified values

        if ischar(varargin{1})
            s.directory=varargin{1};
            try
                d=remoteDir(s.directory);
            catch
                error('can''t load that directory')
            end
        else
            error('directory must be fully resolved string')
        end

        if isreal(varargin{2}) && isscalar(varargin{2}) && varargin{2}>=0 && varargin{2}<=1
            s.yPositionPercent=varargin{2};
        else
            error('yPositionPercent must be real scalar 0<=yPositionPercent<=1')
        end

        if isreal(varargin{3}) && isscalar(varargin{3}) && varargin{3}>=0 && varargin{3}<=1
            s.background=varargin{3};
        else
            error('background must be real scalar 0<=background<=1')
        end

        s = class(s,'images',stimManager(varargin{4},varargin{5},varargin{6},varargin{7}));

    otherwise
        error('Wrong number of input arguments')
end

s=setSuper(s,s.stimManager);