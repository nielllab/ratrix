function s=stimManager(varargin)
% STIMMANAGER  class constructor. ABSTRACT CLASS -- DO NOT INSTANTIATE
% s = stimManager(maxWidth,maxHeight,scaleFactor,interTrialLuminance)

s.correctStim = [];
s.reinfAssocSecs = 0;

switch nargin
    case 0
        % if no input arguments, create a default object
        s.maxWidth=0;
        s.maxHeight=0;
        s.scaleFactor=[];
        s.interTrialLuminance=0;
        s = class(s,'stimManager');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'stimManager'))
            s = varargin{1};
        else
            error('Input argument is not a stimManager object')
        end
    case 4
        if varargin{1}>0 && varargin{2}>0
            s.maxWidth=varargin{1};
            s.maxHeight=varargin{2};
            
        else
            error('maxWidth and maxHeight must be positive')
        end
        
        s=setScaleFactor(varargin{3});
        
        if varargin{4}>=0 && varargin{4}<=1
            s.interTrialLuminance=varargin{4};
        else
            error('interTrailLuminance must be >=0 and <=1')
        end
        
        s = class(s,'stimManager');
    otherwise
        error('Wrong number of input arguments')
end