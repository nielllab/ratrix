function t=trialManager(varargin)
% TRIALMANAGER  class constructor.  ABSTRACT CLASS-- DO NOT INSTANTIATE
% t=trialManager(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,reinforcementManager,
%   [eyeTracker,eyeController],customDescription,[datanet])

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
    case {6 7 8 9}
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
        
        if nargin==6
            t.eyeTracker=[];
            t.eyeController=[];
            customDescription=varargin{6};
        elseif nargin==7
            customDescription=varargin{6};
            t.datanet=varargin{7};
        elseif nargin==8
            t.eyeTracker=varargin{6};
            t.eyeController=varargin{7};
            customDescription=varargin{8};
        elseif nargin==9
            t.eyeTracker=varargin{6};
            t.eyeController=varargin{7};
            customDescription=varargin{8};
            t.datanet=varargin{9};
        else
            error('should never happen')
        end
        
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

        t = class(t,'trialManager');


    otherwise
        nargin
        error('Wrong number of input arguments')
end