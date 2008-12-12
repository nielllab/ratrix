function r=rewardNcorrectInARow(varargin)
% ||rewardNcorrectInARow||  class constructor.
% r=rewardNcorrectInARow(rewardNthCorrect,msPenalty,fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msPuff)

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

    case 6

        if all(varargin{1})>=0
            r.rewardNthCorrect=varargin{1};
        else
            error('all the rewardSizeULorMSs must be >=0')
        end

        r = class(r,'rewardNcorrectInARow',reinforcementManager(varargin{2},varargin{6},varargin{5},varargin{3}, varargin{4}));

    otherwise
        nargin
        error('Wrong number of input arguments')
end