function s=manualCmrMotionEyeCal(varargin)
% MANUALCMRMOTIONEYECAL  class constructor.

% s = manualCmrMotionEyeCal(background,numSweeps,
%       maxWidth,maxHeight,scaleFactor,interTrialLuminance)

s.background=[];
s.numSweeps=[];

s.LUT=[];
s.LUTbits=0;

% constant values for this stim manager - drawExpertFrame will reference these values
s.stateValues={'initialize','move camera to A','recording at A','move camera to B','recording at B','done'};
s.stateTransitionValues=[2 3 4 5 2 1];
s.stateDurationValues=[10 10 5 10 5 10]; % in seconds

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
    case 6
        % create object using specified values
        
        % background
        if isscalar(varargin{1})
            s.background = varargin{1};
        else
            error('background must be a scalar');
        end
        % numSweeps
        if isscalar(varargin{2}) && isinteger(varargin{2}) && varargin{2}>0
            s.numSweeps=varargin{2};
        else
            error('numSweeps must be a positive integer');
        end
        
        s = class(s,'manualCmrMotionEyeCal',stimManager(varargin{3},varargin{4},varargin{5},varargin{6}));
    otherwise
        error('invalid number of input arguments');
end

end % end function


