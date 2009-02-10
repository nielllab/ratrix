function t=trialManager(varargin)
% TRIALMANAGER  class constructor.  ABSTRACT CLASS-- DO NOT INSTANTIATE
% t=trialManager(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,reinforcementManager,eyeTracker,eyeController,customDescription,datanet,frameDropCorner, dropFrames, displayMethod)

% 10/8/08 - this is the new integrated trialManager that handles all stims in a phased way - uses phased doTrial and stimOGL

requiredSoundNames = {'correctSound','keepGoingSound','trySomethingElseSound','wrongSound'};

t.msFlushDuration=0;
t.msMinimumPokeDuration=0;
t.msMinimumClearDuration=0;
t.soundMgr=soundManager();
t.reinforcementManager=reinforcementManager();
t.description='';
t.eyeTracker=[];
t.eyeController=[];
t.datanet=[];
t.frameDropCorner={};
t.dropFrames=false;
t.displayMethod='';

switch nargin
    case 0
        % if no input arguments, create a default object
        
        t = class(t,'trialManager');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'trialManager'))
            t = varargin{1};
        else
            error('Input argument is not a trialManager object')
        end
    case 12
        if varargin{1}>=0
            t.msFlushDuration=varargin{1};
        else
            error('msFlushDuration must be >=0')
        end
        
        if varargin{2}>0
            t.msMinimumPokeDuration=varargin{2};
        else
            error('msMinimumPokeDuration must be > 0')
        end
        
        if varargin{3}>=0
            t.msMinimumClearDuration=varargin{3};
        else
            error('msMinimumClearDuration must be >=0')
        end
        
        if isa(varargin{4},'soundManager') && all(ismember(requiredSoundNames, getSoundNames(varargin{4})))
            t.soundMgr=varargin{4};
        else
            error(['not a soundManager object, or doesn''t contain required sounds ' printAsList(requiredSoundNames)])
        end
        
        if isa(varargin{5},'reinforcementManager')
            t.reinforcementManager=varargin{5};
        else
            error('must be a reinforcementManager')
        end
        
        
        t.eyeTracker=varargin{6};
        t.eyeController=varargin{7};
        customDescription=varargin{8};
        t.datanet=varargin{9};
        
        
        if isa(t.eyeTracker,'eyeTracker') || isempty(t.eyeTracker)
            %pass
        else
            error('must be an eyeTracker or empty')
        end
        
        if isempty(t.eyeController)
            %pass
        else
            ec=t.eyeController
            error('must be a empty -- until we actually have controllers...then maybe its an controller object or a parameter pair list;  example:  {''driftCorrect'',{param1, param2}}')
        end
        
        if ischar(customDescription)
            t.description=sprintf(['%s\n'...
                '\t\t\tmsFlushDuration:\t%d\n'...
                '\t\t\tmsMinimumPokeDuration:\t%d\n'...
                '\t\t\tmsMinimumClearDuration:\t%d'], ...
                customDescription,t.msFlushDuration,t.msMinimumPokeDuration,t.msMinimumClearDuration);
        else
            error('not a string')
        end
        
        
        t.frameDropCorner=varargin{10};
        t.dropFrames=varargin{11};
        t.displayMethod=varargin{12};
        
        if isempty(t.dropFrames)
            t.dropFrames=false;
        elseif islogical(t.dropFrames) && isscalar(t.dropFrames)
            %pass
        else
            error('dropFrames must be scalar logical')
        end
        
        if isempty(t.displayMethod)
            t.displayMethod='ptb';
        elseif ismember(t.displayMethod,{'LED','ptb'})
            %pass
        else
            error('displayMethod must be one of {''LED'',''ptb''}')
        end
        
        if isempty(t.frameDropCorner)
            t.frameDropCorner={'off'};
        elseif iscell(t.frameDropCorner) && (strcmp(t.frameDropCorner{1},'off') || ...
                (isvector(t.frameDropCorner{2}) && all(t.frameDropCorner{2}>=0) && all(t.frameDropCorner{2}<=1) && ...
                (strcmp(t.frameDropCorner{1},'sequence') || (strcmp(t.frameDropCorner{1},'flickerRamp') && all(size(t.frameDropCorner{2})==[1 2])))))
            %pass
        else
            error('frameDropCorner must be {''off''}, {''sequence'',[vector of normalized luminance values]}, or {''flickerRamp'',[rampBottomNormalizedLuminanceValue flickerNormalizedLuminanceValue]}')
        end
        
        if strcmp(t.displayMethod,'LED')
            if strcmp(t.frameDropCorner{1},'off') && ~t.dropFrames
                %pass
            else
                error('must have dropFrames=false and frameDropCorner={''off''} for LED')
            end
        end
        
        t = class(t,'trialManager');
        
        
    otherwise
        nargin
        error('Wrong number of input arguments')
end