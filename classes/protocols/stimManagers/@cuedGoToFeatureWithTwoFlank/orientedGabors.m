function s=orientedGabors(varargin)
% ORIENTEDGABORS  class constructor.
% s = orientedGabors([pixPerCycs],[targetOrientations],[distractorOrientations],mean,radius,contrast,thresh,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance) 
% orientations in radians
% mean, contrast, yPositionPercent normalized (0 <= value <= 1)
% radius is the std dev of the enveloping gaussian, in normalized units of the diagonal of the stim region
% thresh is in normalized luminance units, the value below which the stim should not appear
switch nargin
case 0 
% if no input arguments, create a default object

    s.pixPerCycs = [];
    s.targetOrientations = [];
    s.distractorOrientations = [];
   
    s.mean = 0;
    s.radius = 0;
    s.contrast = 0;
    s.thresh = 0;
    s.yPosPct = 0; 
    
    s = class(s,'orientedGabors',stimManager());   
    
case 1
% if single argument of this class type, return it
    if (isa(varargin{1},'orientedGabors'))
        s = varargin{1}; 
    else
        error('Input argument is not an orientedGabors object')
    end
case 12
% create object using specified values    
    
    if all(varargin{1})>0
        s.pixPerCycs=varargin{1};
    else
        error('pixPerCycs must all be > 0')
    end
    
    if all(isnumeric(varargin{2})) && all(isnumeric(varargin{3}))
        s.targetOrientations=varargin{2};
        s.distractorOrientations=varargin{3};
    else
        error('target and distractor orientations must be numbers')
    end
        
    if varargin{4} >= 0 && varargin{4}<=1
        s.mean=varargin{4};
    else
        error('0 <= mean <= 1')
    end
    
    if varargin{5} >=0
        s.radius=varargin{5};
    else
        error('radius must be >= 0')
    end
    
    if isnumeric(varargin{6})
        s.contrast=varargin{6};
    else
        error('contrast must be numeric')
    end
    
    if varargin{7} >= 0
        s.thresh=varargin{7};
    else
        error('thresh must be >= 0')
    end
    
    if isnumeric(varargin{8})
        s.yPosPct=varargin{8};
    else
        error('yPositionPercent must be numeric')
    end
    
    s = class(s,'orientedGabors',stimManager(varargin{9},varargin{10},varargin{11},varargin{12}));   
    
otherwise
    error('Wrong number of input arguments')
end

s=setSuper(s,s.stimManager);