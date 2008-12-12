function r=constantReinforcement(varargin)
% ||constantReinforcement||  class constructor.
% r=constantReinforcement(rewardSizeULorMS,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msPuff)

        r.rewardSizeULorMS=0;

switch nargin
    case 0
        % if no input arguments, create a default object


        r = class(r,'constantReinforcement',reinforcementManager());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'constantReinforcement'))
            r = varargin{1};
        else
            error('Input argument is not a constantReinforcement object')
        end
    case 6
        r = class(r,'constantReinforcement',reinforcementManager(varargin{2},varargin{6},varargin{5},varargin{3},varargin{4}));
        r = setRewardSizeULorMS(r,varargin{1});
    otherwise
        error('Wrong number of input arguments')
end