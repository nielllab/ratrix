function spec=stimSpec(varargin)
% stimSpec  class constructor. 
% spec=stimSpec(stimulus,criterion,stimType,startFrame,rewardType,rewardDuration,rewardPorts,...
%   framesUntilGrad,stochasticDistribution,scaleFactor,isFinalPhase,hz)
%
% the stimulus is the visual movie
% criterion is the phase transitions
% stimType is the format of the movie (toggle, loop, once-through, timedFrames, indexedFrames) - default is loop
% it must be either a single char array, or a cell array (if time or frame indexed) of the form {'timedFrames', [indicies]}
% startFrame is the frame index at which to start for this phase (indexes into stimulus)
% rewardType is either reward or airpuff
% rewardDuration is the duration of the reinforcement in milliseconds
% rewardPorts is the ports at which to give a reward, if rewardType is 'reward' or 'rewardSizeULorMS'
    % rewardPorts should be [3] if you want to have runRealTimeLoop say rewardValves=[0 0 1]
% framesUntilTransition is the number of frames that this phase plays (exactly) and then graduates - this is useful if we want
% a wait phase that doesn't need a port response to move into discrim phase
% note that this only works for 'loop' stimType (because we count by frames, not by real time)
% stochasticDistribution is a two-element cell array - the first element is the distribution from which to pick an auto response
%   the second element is what port to auto trigger (given as a vector)

% criteria is the port(s) that will graduate from this phase - chosen from the set {'request', 'response', 'target', 'distractor', 'any', 'none'}
% scaleFactor is the scaleFactor for this phase
% isFinalPhase is a flag that indicates if this phase means the end of a trial

% fields in the stimSpec object
spec.stimulus = zeros(1,1,1);
spec.criterion = {[], 0};
spec.stimType = 'loop';
spec.startFrame = 1;
spec.rewardType = [];
spec.rewardDuration = 100;
spec.rewardPorts = [];
spec.framesUntilTransition = [];
spec.stochasticDistribution = []; % for now the "distribution" is a unit random criterion between 0 and 1
spec.scaleFactor=0;
spec.isFinalPhase = 0;
spec.hz=0;

switch nargin
    case 0
        % if no input arguments, create a default object
        
        spec = class(spec,'stimSpec');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'stimSpec'))
            spec = varargin{1};
            % if single argument is a stimulus, use blank sounds and
            % rewardDuration
        elseif isa(varargin{1}, 'numeric')
            spec.stimulus = varargin{1};
            spec = class(spec,'stimSpec');
        else
            error('Input argument is not a stimSpec object or cell array of stim frames')
        end
    case 2
        % if we are given a stimulus and a criteria
        goodInput = 0;
        if isa(varargin{1}, 'numeric') && iscell(varargin{2})
            temp = varargin{2}; % this is the cell array that has key value pairs
            for i=1:2:length(varargin{2})-1 % check each transition port set
                if isa(temp{1}, 'numeric')
                    goodInput = 1;
                else
                    error('Invalid port set specified');
                end
            end
        else
            error('Invalid inputs');
        end
        spec.stimulus = varargin{1};
        spec.criterion = varargin{2};
        spec = class(spec,'stimSpec');

    case 12

        % stimulus
        spec.stimulus = varargin{1};
        % criteria
        goodInput = 0;
        if iscell(varargin{2})
            temp = varargin{2}; % this is the cell array that has key value pairs
            for i=1:2:length(varargin{2})-1 % check each transition port set
                if isa(varargin{2}{i}, 'numeric')
                    
                    goodInput=1;
                else
                    error('Invalid port set specified');
                end
            end
            spec.criterion = varargin{2};
        else
            error('Invalid inputs');
        end
        
        % stimType
        %varargin{3}
        %ischar(varargin(3))
        %strcmp(varargin(3),'trigger')
        if ischar(varargin{3}) && (strcmp(varargin{3}, 'trigger') || strcmp(varargin{3}, 'loop') || ...
                strcmp(varargin{3}, 'cache') || strcmp(varargin{3},'expert')) % handle single char arrays
            % error-check that if we want toggle mode, only a 2-frame movie
            if strcmp(varargin{3}, 'trigger') && size(spec.stimulus,3) ~= 2
                size(spec.stimulus,3)
                error('trigger mode only works with a 2-frame movie');
            end
            spec.stimType = varargin{3};
        elseif iscell(varargin{3})
            typeArray = varargin{3};
            if strcmp(typeArray{1}, 'timedFrames') || strcmp(typeArray{1}, 'indexedFrames')
                spec.stimType = varargin{3};
            else
                error('invalid specification of stimType in cell array format');
            end
        else
            error('stimType must be trigger, loop, cache, timedFrames, indexedFrames, or expert');
        end
        % startFrame
        if isscalar(varargin{4}) && varargin{4}>0
            spec.startFrame=varargin{4};
        else
            error('startFrame must be >0');
        end
        % rewardType
        if ischar(varargin{5}) && (strcmp(varargin{5}, 'reward') || strcmp(varargin{5}, 'airpuff') || ...
                strcmp(varargin{5},'rewardSizeMSorUL') || strcmp(varargin{5},'msPuff')) % 1/29/09 - also allow these flags to get value from reinforcementMgr
            spec.rewardType = varargin{5};
		elseif isempty(varargin{5})
			spec.rewardType = []; % no reward/airpuff here
        else
            error('rewardType must be reward or airpuff');
        end
        % rewardDuration
        if varargin{6} > 0
            spec.rewardDuration = varargin{6};
        else
            error('rewardDuration must be longer than zero');
        end
        % rewardPorts
        if isnumeric(varargin{7})
            spec.rewardPorts=varargin{7};
        else
            error('rewardPorts must be numeric');
        end
        % framesUntilTransition
        if isscalar(varargin{8}) && varargin{8} > 0
            spec.framesUntilTransition = varargin{8};
        elseif ischar(varargin{8}) && strcmp(varargin{8},'msPenalty') % also allow this flag to get value from reinforcementMgr
            spec.framesUntilTransition = varargin{8};
        elseif isempty(varargin{8})
            spec.framesUntilTransition = [];
        else
            error('framesUntilGrad must be a real scalar or empty')
        end
        % stochasticDistribution
        if iscell(varargin{9})
                stoD = varargin{9};
                if isreal(stoD{1}) && stoD{1} >= 0 && stoD{1} < 1 && isvector(stoD{2})
                    spec.stochasticDistribution = varargin{9};
                else
                    error('distribution must be a real number in [0,1) and port must be a vector');
                end
        elseif isempty(varargin{9})
            'do nothing here b/c we do not want any auto requests';
        else
            error('stochasticDistribution must be a cell array');
        end
        % scaleFactor
        if (length(varargin{10})==2 && all(varargin{10}>0)) || (length(varargin{10})==1 && varargin{10}==0)
            spec.scaleFactor=varargin{10};
        else
            error('scale factor is either 0 (for scaling to full screen) or [width height] positive values')
        end
        
        % isFinalPhase

            if isscalar(varargin{11}) && (varargin{11} == 0 || varargin{11} == 1)
                spec.isFinalPhase = varargin{11};
            else
                error('isFinalPhase must be a scalar 0 or 1')
            end


        if isscalar(varargin{12}) && varargin{12}>0 && isreal(varargin{12})
            spec.hz=varargin{12};
        else
            error('hz must be scalar real >0')
        end
        

        spec = class(spec,'stimSpec');
        
    otherwise
        error('Wrong number of input arguments')
end

