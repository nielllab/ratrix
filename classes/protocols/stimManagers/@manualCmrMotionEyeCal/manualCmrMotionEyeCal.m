function s=manualCmrMotionEyeCal(varargin)
% MANUALCMRMOTIONEYECAL  class constructor.

% s = manualCmrMotionEyeCal(background,
%       maxWidth,maxHeight,scaleFactor,interTrialLuminance)

s.background = [];

s.LUT=[];
s.LUTbits=0;

switch nargin
    case 0
        % if no input arguments, create a default object
        
        s = class(s,'manualCmrMotionEyeCal',stimManager());
    case 1
        % if input is of this class type
        if (isa(varargin{1},'manualCmrMotionEyeCal'))
            s = varargin{1};
        else
            error('Input argument is not a manualCmrMotionEyeCal object')
        end
    case 5
        % create object using specified values
        
        % background
        if isscalar(varargin{1})
            s.background = varargin{1};
        else
            error('background must be a scalar');
        end
        
        s = class(s,'manualCmrMotionEyeCal',stimManager(varargin{2},varargin{3},varargin{4},varargin{5}));
    otherwise
        error('invalid number of input arguments');
end

end % end function


