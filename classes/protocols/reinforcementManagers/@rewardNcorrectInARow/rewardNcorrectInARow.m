function r=rewardNcorrectInARow(varargin)
% ||rewardNcorrectInARow||  class constructor.
% r=rewardNcorrectInARow(rewardNthCorrect,requestRewardSizeULorMS,requestMode,msPenalty,...
%   fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msPuff)

switch nargin
    case 0
        % if no input arguments, create a default object
        r.rewardNthCorrect=[0]; %this is a vector of the rewardSizeULorMSs for the Nth trial correct in a row

        r = class(r,'rewardNcorrectInARow',reinforcementManager());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'rewardNcorrectInARow'))
            r = varargin{1};
        else
            error('Input argument is not a rewardNcorrectInARow object')
        end

    case 8

        if all(varargin{1})>=0
            r.rewardNthCorrect=varargin{1};
        else
            error('all the rewardSizeULorMSs must be >=0')
        end

        r = class(r,'rewardNcorrectInARow',...
            reinforcementManager(varargin{4},varargin{8},varargin{7},varargin{5}, varargin{6}, varargin{2}, varargin{3}));

    otherwise
        nargin
        error('Wrong number of input arguments')
end