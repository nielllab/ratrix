function r=reinforcementManager(varargin)
% REINFORCEMENTMANAGER  class constructor.  ABSTRACT CLASS-- DO NOT INSTANTIATE
% r=rewardManager(msPenalty, msPuff, scalar, fractionOpenTimeSoundIsOn, fractionPenaltySoundIsOn)

r.msPenalty=0;
r.fractionOpenTimeSoundIsOn=0;
r.fractionPenaltySoundIsOn=0;
r.scalar=1;
r.msPuff=0;

r.rewardStrategy='msOpenTime';
r.unloggedRewardConvention='reset to 250mmHg';

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
    case 5
        r.msPenalty=varargin{1};
        r.msPuff=varargin{2};
        r.scalar=varargin{3};
        r.fractionOpenTimeSoundIsOn=varargin{4};
        r.fractionPenaltySoundIsOn=varargin{5};
        
        if r.msPenalty>=0
            %pass
        else
            error('msPenalty must be >=0')
        end
        
        if isreal(r.msPuff) && isscalar(r.msPuff) && r.msPuff>=0 && r.msPuff<=r.msPenalty
            %pass
        else
            error('msPuff must be scalar real 0<= val <=msPenalty')
        end

        if r.scalar>=0 && r.scalar<=100
            %pass
        else
            error('scalar must be >=0 and <=100')
        end

        if r.fractionOpenTimeSoundIsOn>=0 && r.fractionOpenTimeSoundIsOn<=1
            %pass
        else
            error('fractionOpenTimeSoundIsOn must be >=0 and <=1')
        end

        if r.fractionPenaltySoundIsOn>=0 && r.fractionPenaltySoundIsOn<=1
            %pass
        else
            error('fractionPenaltySoundIsOn must be >=0 and <=1')
        end

        r = class(r,'reinforcementManager');

    otherwise
        error('Wrong number of input arguments')
end