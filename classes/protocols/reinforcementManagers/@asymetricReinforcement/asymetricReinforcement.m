function r=asymetricReinforcement(varargin)
% ||asymetricReinforcement||  class constructor.
% r=asymetricReinforcement(hitRewardSizeULorMS,correctRejectRewardSizeULorMS,missMsPenalty,falseAlarmMsPenalty,requestRewardSizeULorMS,requestMode,msPenalty,...
%   fractionOpenTimeSoundIsOn,fractionPenaltySoundIsOn,scalar,msPuff)

switch nargin
    case 0
        % if no input arguments, create a default object
        r.hitRewardSizeULorMS=0;
        r.correctRejectRewardSizeULorMS=0;
        r.missMsPenalty=0;
        r.falseAlarmMsPenalty=0;
        
        r = class(r,'asymetricReinforcement',reinforcementManager());
    case 1
        % if single argument of this class type, return it
        if (isa(varargin{1},'asymetricReinforcement'))
            r = varargin{1};
        else
            error('Input argument is not a asymetricReinforcement object')
        end

    case 11

        if varargin{1}>=0 && isreal(varargin{1}) && isscalar(varargin{1})
            r.hitRewardSizeULorMS=varargin{1};
        else
            error('the hitRewardSizeULorMS must a single scalar be >=0')
        end
           
        if varargin{2}>=0 && isreal(varargin{2}) && isscalar(varargin{2})
            r.correctRejectRewardSizeULorMS=varargin{2};
        else
            error('the correctRejectRewardSizeULorMS must a single scalar be >=0')
        end
        
             
        if varargin{3}>=0 && isreal(varargin{3}) && isscalar(varargin{3})
            r.missMsPenalty=varargin{3};
        else
            error('the missMsPenalty must a single scalar be >=0')
        end
         
        if varargin{4}>=0 && isreal(varargin{4}) && isscalar(varargin{4})
            r.falseAlarmMsPenalty=varargin{4};
        else
            error('the falseAlarmMsPenalty must a single scalar be >=0')
        end
        
        
        msPenalty=NaN;  % these should not be set in the super class, because they will vary in this sub-class
        %msPuff=NaN; % should add asymetric puffs  (to support air in face on fa, not on miss), in which case pass in NAN to super class
        msPuff=varargin{11};
        r = class(r,'asymetricReinforcement',...
            reinforcementManager(msPenalty,msPuff,varargin{10},varargin{8}, varargin{9}, varargin{5}, varargin{6}));
           %(msPenalty, msPuff, scalar, fractionOpenTimeSoundIsOn, fractionPenaltySoundIsOn, requestRewardSizeULorMS, requestMode)
    otherwise
        nargin
        error('Wrong number of input arguments')
end