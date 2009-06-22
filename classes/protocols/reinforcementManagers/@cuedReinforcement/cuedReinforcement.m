function r=cuedReinforcement(varargin)
% ||constantReinforcement||  class constructor.
% r=constantReinforcement(rewardSizeULorMS,requestRewardSizeULorMS,requestMode,...
%   msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msPuff)

        r.rewardSizeULorMS=0;

switch nargin
    case 0
        % if no input arguments, create a default object


        r = class(r,'cuedReinforcement',reinforcementManager());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'cuedReinforcement'))
            r = varargin{1};
        else
            error('Input argument is not a cuedReinforcement object')
        end
    case 8
        r = class(r,'cuedReinforcement',...
            reinforcementManager(varargin{4},varargin{8},varargin{7},varargin{5},varargin{6},varargin{2},varargin{3}));
%         r = setRewardSizeULorMS(r,varargin{1}); % not needed b/c we never look at this value! - stim manager cuedCoherentDots
    otherwise
        error('Wrong number of input arguments')
end