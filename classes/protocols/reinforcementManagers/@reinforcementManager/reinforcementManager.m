function r=reinforcementManager(varargin)
% REINFORCEMENTMANAGER  class constructor.  ABSTRACT CLASS-- DO NOT INSTANTIATE
% r=rewardManager(msPenalty, msPuff, scalar, fractionOpenTimeSoundIsOn, fractionPenaltySoundIsOn, requestRewardSizeULorMS, requestMode)
%
% msPenalty - duration of the penalty
% fractionOpenTimeSoundIsOn - fraction of reward during which sound is played
% fractionPenaltySoundIsOn - fraction of penalty during which sound is played
% scalar - reinforcement duration/size multiplier
% msPuff - duration of the airpuff
% requestRewardSizeULorMS - duration/size of the request reward
% requestMode - one of the strings {'first', 'nonrepeats', 'all'} that specifies which requests should be rewarded within a trial
%       'first' means only the first request is rewarded; 'nonrepeats' means all requests that are not same as previous request are rewarded
%       'all' means all requests are rewarded

r.msPenalty=0;
r.fractionOpenTimeSoundIsOn=0;
r.fractionPenaltySoundIsOn=0;
r.scalar=1;
r.msPuff=0;
r.requestRewardSizeULorMS=0;
r.requestMode='first'; % 'first','nonrepeats', or 'all'

switch nargin
    case 0
        % if no input arguments, create a default object

        r = class(r,'reinforcementManager');
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'reinforcementManager'))
            r = varargin{1};
        else
            error('Input argument is not a reinforcementManager object')
        end
    case 7
        r.msPenalty=varargin{1};
        r.msPuff=varargin{2};
        r.scalar=varargin{3};
        r.fractionOpenTimeSoundIsOn=varargin{4};
        r.fractionPenaltySoundIsOn=varargin{5};
        r.requestRewardSizeULorMS=varargin{6};
        r.requestMode=varargin{7};
        
        if r.msPenalty>=0 && isreal(r.msPenalty) && isscalar(r.msPenalty)
            %pass
        else
            error('msPenalty must a single real number be >=0')
        end
        
        if isreal(r.msPuff) && isscalar(r.msPuff) && r.msPuff>=0 && r.msPuff<=r.msPenalty
            %pass
        else
            error('msPuff must be scalar real 0<= val <=msPenalty')
        end

        if isreal(r.scalar) && isscalar(r.scalar) && r.scalar>=0 && r.scalar<=100 
            %pass
        else
            error('scalar must be >=0 and <=100')
        end

        if isreal(r.fractionOpenTimeSoundIsOn) && isscalar(r.fractionOpenTimeSoundIsOn) &&  r.fractionOpenTimeSoundIsOn>=0 && r.fractionOpenTimeSoundIsOn<=1
            %pass
        else
            error('fractionOpenTimeSoundIsOn must be >=0 and <=1')
        end

        if isreal(r.fractionPenaltySoundIsOn) && isscalar(r.fractionPenaltySoundIsOn) && r.fractionPenaltySoundIsOn>=0 && r.fractionPenaltySoundIsOn<=1
            %pass
        else
            error('fractionPenaltySoundIsOn must be >=0 and <=1')
        end
        if r.requestRewardSizeULorMS>=0 && isreal(r.requestRewardSizeULorMS) && isscalar(r.requestRewardSizeULorMS)
            %pass
        else
            error('requestRewardSizeULorMS must a single real number be >=0')
        end
        if ischar(r.requestMode) && (strcmp(r.requestMode,'first') || strcmp(r.requestMode,'nonrepeats') || strcmp(r.requestMode,'all'))
            %pass
        else
            error('requestMode must be ''first'',''nonrepeats'',or ''all''');
        end

        r = class(r,'reinforcementManager');

    otherwise
        error('Wrong number of input arguments')
end