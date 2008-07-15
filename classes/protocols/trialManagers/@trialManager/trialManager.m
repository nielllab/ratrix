function t=trialManager(varargin)
% TRIALMANAGER  class constructor.  ABSTRACT CLASS-- DO NOT INSTANTIATE
% t=trialManager(msFlushDuration,msMinimumPokeDuration,msMinimumClearDuration,soundManager,reinforcementManager,eyeTracker,eyeController,customDescription)

requiredSoundNames = {'correctSound','keepGoingSound','trySomethingElseSound','wrongSound'};

        t.msFlushDuration=0;
        t.msMinimumPokeDuration=0;
        t.msMinimumClearDuration=0;
        t.soundMgr=soundManager();
        t.reinforcementManager=reinforcementManager();
        t.description='';
        t.eyeTracker=[];
        t.eyeController=[];
switch nargin
    case 0
        % if no input arguments, create a default object

        t = class(t,'trialManager',structable());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'trialManager'))
            t = varargin{1};
        else
            error('Input argument is not a trialManager object')
        end
    case 8
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

        if isa(varargin{6},'eyeTracker')
            t.eyeTracker=varargin{6};
        else
            error('must be an eyeTracker')
        end
        
        if isempty(varargin{7})
            t.eyeController=varargin{7};
        else
            error('must be a empty -- until we actually have controllers...then maybe its an controller object or a parameter pair list;  example:  {''driftCorrect'',{param1, param2}}')
        end

        
        if ischar(varargin{8})
            t.description=sprintf(['%s\n'...
                                   '\t\t\tmsFlushDuration:\t%d\n'...
                                   '\t\t\tmsMinimumPokeDuration:\t%d\n'...
                                   '\t\t\tmsMinimumClearDuration:\t%d'], ...
                varargin{8},t.msFlushDuration,t.msMinimumPokeDuration,t.msMinimumClearDuration);
        else
            error('not a string')
        end

        t = class(t,'trialManager',structable());


    otherwise
        nargin
        error('Wrong number of input arguments')
end

        t=setSuper(t,t.structable);
