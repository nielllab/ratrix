function s=whiteNoise(varargin)
% WHITENOISE  class constructor.

% s = whiteNoise(distribution,std,background,method,requestedStimLocation,stixelSize,searchSubspace,numFrames,
%       maxWidth,maxHeight,scaleFactor,interTrialLuminance)

s.distribution = [];
s.background = [];
s.method = [];
s.requestedStimLocation = [];
s.stixelSize = [];
s.searchSubspace = [];
s.numFrames = [];
s.changeable = [];
s.LUT=[];
s.LUTbits=0;

switch nargin
    case 0
        % if no input arguments, create a default object
        
        s = class(s,'whiteNoise',stimManager());
    case 1
        % if input is of this class type
        if (isa(varargin{1},'whiteNoise'))
            s = varargin{1};
        else
            error('Input argument is not a whiteNoise object')
        end
    case 12
        % create object using specified values
        
        if ischar(varargin{1}{1}) && ismember(varargin{1}{1},{'gaussian','binary'})
            s.distribution.type=varargin{1}{1};
        else
            varargin{1}{1}
            error('distribution must be ''gaussian'' or ''binary''')
        end
        
        switch s.distribution.type
            case 'gaussian'
                if length(varargin{1})==3
                    % meanLuminance
                    if isscalar(varargin{1}{2})
                        s.distribution.meanLuminance = varargin{1}{2};
                    else
                        error('meanLuminance must be a scalar');
                    end
                    % std
                    if isscalar(varargin{1}{3})
                        s.distribution.std = varargin{1}{3};
                    else
                        error('std must be a scalar');
                    end
                else
                    error('gaussian must have 3 arguments: ditribution name, mean and std')
                end
            case 'binary'
                if length(varargin{1})==4
                    lowVal=varargin{1}{2};
                    if isscalar(lowVal)
                        s.distribution.lowVal= lowVal;
                    else
                        error('lowVal must be a scalar');
                    end
                    
                    hiVal=varargin{1}{3};
                    if isscalar(hiVal)
                        s.distribution.hiVal=hiVal;
                    else
                        error('hiVal must be a scalar');
                    end
                    
                    if lowVal>=hiVal
                        lowVal
                        hiVal
                        error('lowVal must be less than hiVal')
                    end
                    
                    probability=varargin{1}{4};
                    if isscalar(probability) && probability>=0 probability<=0
                        s.distribution.probability = probability;
                    else
                        probability
                        error('probability must be in the range 0 and 1 inclusive');
                    end
                else
                    error('binary must have 4 arguments: ditribution name, loVal, hiVal,probability of highVal')
                end
        end
        
        % background
        if isscalar(varargin{2})
            s.background = varargin{2};
        else
            error('background must be a scalar');
        end
        
        % method
        if ischar(varargin{3})
            s.method = varargin{3};
        else
            error('method must be a string');
        end
        
        %requestedStimLocation
        if isvector(varargin{4}) && length(varargin{4}) == 4
            s.requestedStimLocation = varargin{4};
        else
            error('requestedStimLocation must be a vector of length 4');
        end
        
        % stixelSize
        if isvector(varargin{5}) && length(varargin{5}) == 2
            s.stixelSize = varargin{5};
        else
            error('stixelSize must be a 2-element vector');
        end
        % searchSubspace
        if isnumeric(varargin{6})
            s.searchSubspace = varargin{6};
        else
            error('searchSubspace must be numeric');
        end
        % numFrames
        if isscalar(varargin{7})
            s.numFrames = varargin{7};
        else
            error('numFrames must be a scalar');
        end
        
        % changeable
        if islogical(varargin{8})
            s.changeable = varargin{8};
        else
            error('changeable must be a logicial');
        end
        
        s = class(s,'whiteNoise',stimManager(varargin{9},varargin{10},varargin{11},varargin{12}));
        
    otherwise
        error('invalid number of input arguments');
end


