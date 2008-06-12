function t=trialManager(varargin)
% TRIALMANAGER  class constructor.  ABSTRACT CLASS-- DO NOT INSTANTIATE
% t=trialManager(msFlushDuration,rewardSizeULorMS,msMinimumPokeDuration,msMinimumClearDuration,soundManager,msPenalty,msRewardSoundDuration,customDescription,eyepuffMS)

requiredSoundNames = {'correctSound','keepGoingSound','trySomethingElseSound','wrongSound'};

        t.msFlushDuration=0;
        t.rewardSizeULorMS=0;
        t.msMinimumPokeDuration=0;
        t.msMinimumClearDuration=0;
        t.soundMgr=soundManager();
        t.msPenalty=0;
        t.msRewardSoundDuration=0;
        t.description='';
        t.eyepuffMS=0;

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
    case 9
        if varargin{1}>=0
            t.msFlushDuration=varargin{1};
        else
            error('msFlushDuration must be >=0')
        end

        if varargin{2}>=0
            t.rewardSizeULorMS=varargin{2};
        else
            error('rewardSizeULorMS must be >=0')
        end
        
                
        if varargin{9}>=0 && isscalar(varargin{9})
            t.eyepuffMS=varargin{9};
        else
            error('eyepuffMS must be >=0')
        end
        
        if varargin{3}>0
            t.msMinimumPokeDuration=varargin{3};
        else
            error('msMinimumPokeDuration must be > 0')
        end

        if varargin{4}>=0
            t.msMinimumClearDuration=varargin{4};
        else
            error('msMinimumClearDuration must be >=0')
        end

        if isa(varargin{5},'soundManager') && all(ismember(requiredSoundNames, getSoundNames(varargin{5})))
            t.soundMgr=varargin{5};
        else
            error(['not a soundManager object, or doesn''t contain required sounds ' printAsList(requiredSoundNames)])
        end

        if varargin{6}>=0
            t.msPenalty=varargin{6};
        else
            error('msPenalty must be >= 0')
        end

        if varargin{7}>=0
            t.msRewardSoundDuration=varargin{7};
        else
            error('msRewardSoundDuration must be >= 0')
        end

        if ischar(varargin{8})
            t.description=sprintf(['%s\n'...
                                   '\t\t\tmsFlushDuration:\t%d\n'...
                                   '\t\t\trewardSizeULorMS:\t%d\n'...
                                   '\t\t\tmsMinimumPokeDuration:\t%d\n'...
                                   '\t\t\tmsMinimumClearDuration:\t%d\n'...
                                   '\t\t\tmsPenalty:\t%d\n'...
                                   '\t\t\tmsRewardSoundDuration:\t%d'], ...
                varargin{8},t.msFlushDuration,t.rewardSizeULorMS,t.msMinimumPokeDuration,t.msMinimumClearDuration,t.msPenalty,t.msRewardSoundDuration);
        else
            error('not a string')
        end

        t = class(t,'trialManager',structable());


    otherwise
        error('Wrong number of input arguments')
end

        t=setSuper(t,t.structable);