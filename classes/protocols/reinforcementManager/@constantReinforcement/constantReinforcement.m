function r=constantReinforcement(varargin)
% ||constantReinforcement||  class constructor.
% r=constantReinforcement(rewardSizeULorMS,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar)

switch nargin
    case 0
        % if no input arguments, create a default object
        r.rewardSizeULorMS=0;

        r = class(r,'constantReinforcement',reinforcementManager());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'constantReinforcement'))
            r = varargin{1};
        else
            error('Input argument is not a constantReinforcement object')
        end
    case 5

        if varargin{1}>=0
            r.rewardSizeULorMS=varargin{1};
        else
            error('rewardSizeULorMS must be >=0')
        end

        r = class(r,'constantReinforcement',reinforcementManager(varargin{2},varargin{5},varargin{3},varargin{4}));

    otherwise
        error('Wrong number of input arguments')
end

r=setSuper(r,r.reinforcementManager);