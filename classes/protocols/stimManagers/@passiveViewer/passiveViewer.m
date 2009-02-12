function s=passiveViewer(varargin)
% PASSIVEVIEWER  class constructor.

% s = passiveViewer(meanLuminance,std,background,method,requestedStimLocation,stixelSize,searchSubspace,numFrames,
%       maxWidth,maxHeight,scaleFactor,interTrialLuminance)


s.meanLuminance = [];
s.std = [];
s.background = [];
s.method = [];
s.requestedStimLocation = [];
s.stixelSize = [];
s.searchSubspace = [];
s.numFrames = [];
s.LUT=[];
s.LUTbits=0;

switch nargin
    case 0
        % if no input arguments, create a default object

        s = class(s,'passiveViewer',stimManager());
    case 1
        % if input is of this class type
        if (isa(varargin{1},'passiveViewer'))
            s = varargin{1};
        else
            error('Input argument is not a passiveViewer object')
        end
    case 12
        % create object using specified values
        % meanLuminance
        if isscalar(varargin{1})
            s.meanLuminance = varargin{1};
        else
            error('meanLuminance must be a scalar');
        end
        % std
        if isscalar(varargin{2})
            s.std = varargin{2};
        else
            error('std must be a scalar');
        end
        % background
        if isscalar(varargin{3})
            s.background = varargin{3};
        else
            error('background must be a scalar');
        end
        % method
        if ischar(varargin{4})
            s.method = varargin{4};
        else
            error('method must be a string');
        end
        %requestedStimLocation
        if isvector(varargin{5}) && length(varargin{5}) == 4
            s.requestedStimLocation = varargin{5};
        else
            error('requestedStimLocation must be a vector of length 4');
        end
        % stixelSize
        if isvector(varargin{6}) && length(varargin{6}) == 2
            s.stixelSize = varargin{6};
        else
            error('stixelSize must be a 2-element vector');
        end
        % searchSubspace
        if isnumeric(varargin{7})
            s.searchSubspace = varargin{7};
        else
            error('searchSubspace must be numeric');
        end
        % numFrames
        if isscalar(varargin{8})
            s.numFrames = varargin{8};
        else
            error('numFrames must be a scalar');
        end
        
        s = class(s,'passiveViewer',stimManager(varargin{9},varargin{10},varargin{11},varargin{12}));
        
    otherwise
        error('invalid number of input arguments');
end

        
        