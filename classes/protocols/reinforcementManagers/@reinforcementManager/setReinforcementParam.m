function rm=setReinforcementParam(rm,param,val)
switch param
    case 'penaltyMS'
        rm=setMsPenalty(rm,val);
    case 'rewardULorMS'
        try
            rm=setRewardSizeULorMS(rm,val);
        catch ex
            if ismember(ex.message,{'Input argument "val" is undefined.',...
                    'Undefined function or method ''setRewardULorMS'' for input arguments of type ''reinforcementManager''.'})
                class(rm)
                warning('can''t set rewardULorMS for reinforcementManager of this class')
            else
                rethrow(ex)
            end
        end
    otherwise
        error('unrecognized param')
end