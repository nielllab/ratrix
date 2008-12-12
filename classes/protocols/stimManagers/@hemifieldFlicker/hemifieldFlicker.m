function s=hemifieldFlicker(varargin)
% Hemifield Flicker  class constructor.
% s =
% hemifieldFlicker([pixPerCycs],[targetContrasts],[distractorContrasts],fieldWidthPct,fieldHeightPct,mean,stddev,thresh,flickerType,yPositionPercent,maxWidth,maxHeight,scaleFactor,interTrialLuminance) 
% mean, contrasts, yPositionPercent normalized (0 <= value <= 1)
% Description of arguments:
% =========================
% targetContrasts - Number of fields for target ports and the contrast imposed on each
% distractorContrasts - Number of fields for distractor ports and the contrast imposed on each
% fieldWidthPct - Width (horizontal) in X axis as a percentage of screen (0 <= fieldWidth <= 1)
% fieldHeightPct - Height (vertical) in Y axis as a percentage of screen (0 <= fieldHeight <= 1)
% mean - Mean brightness
% stddev - Standard deviation of contrast (for Gaussian)
% thresh - in normalized luminance units, the value below which the stim should not appear 
% flickerType - 0 for binary flicker; 1 for Gaussian flicker
% yPosPct - Position in Y axis (vertical) of screen to present the fields

switch nargin
case 0 
% if no input arguments, create a default object
    s.numCalcIndices = [];
    s.targetContrasts = []; 
    s.distractorContrasts = []; 
    s.fieldWidthPct = 0;
    s.fieldHeightPct = 0;
    s.mean = 0;
    s.stddev = 0;
    s.thresh = 0;
    s.flickerType = 0; 
    s.yPosPct = 0; 
    s = class(s,'hemifieldFlicker',stimManager());    
case 1
% if single argument of this class type, return it
    if (isa(varargin{1},'hemifieldFlicker'))
        s = varargin{1}; 
    else
        error('Input argument is not a hemifieldFlicker object')
    end
case 14
% create object using specified values        
    if all(varargin{1})>0
        s.numCalcIndices=varargin{1};
    else
        error('numCalcIndices must be > 0')
    end
    
    if all(isnumeric(varargin{2})) && all(isnumeric(varargin{3}))
        s.targetContrasts=varargin{2};
        s.distractorContrasts=varargin{3};
    else
        error('target and distractor contrasts must be numbers')
    end
        
    if varargin{4} >= 0 && varargin{4}<=1
        s.fieldWidthPct=varargin{4};
    else
        error('fieldWidthPct must be >= 0')
    end
    
    if varargin{5} >= 0 && varargin{5}<=1
        s.fieldHeightPct=varargin{5};
    else
        error('fieldHeightPct must be >= 0')
    end    
    
    if varargin{6} >=0
        s.mean=varargin{6};
    else
        error('0 <= mean <= 1')
    end
        
    if varargin{7} >= 0
        s.stddev=varargin{7};
    else
        error('stddev must be >= 0')
    end
    
    if varargin{8} >= 0
        s.thresh=varargin{8};
    else
        error('thresh must be >= 0')
    end

    if isnumeric(varargin{9})
        s.flickerType=varargin{9};
    else
        error('flickerType must be 0 at this time (only binary flicker supported)')
    end
    
    if isnumeric(varargin{10})
        s.yPosPct=varargin{10};
    else
        error('yPositionPercent must be numeric')
    end
    
    s = class(s,'hemifieldFlicker',stimManager(varargin{11},varargin{12},varargin{13},varargin{14}));   
    
otherwise
    error('Wrong number of input arguments')
end