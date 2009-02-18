function rm=setReinforcementParam(rm,param,val)

try
    switch param
        case {'penaltyMS','msPenalty'}
            rm=setMsPenalty(rm,val);
        case 'scalar'
            rm=setScalar(rm,val);
        case 'rewardULorMS'
            rm=setRewardSizeULorMS(rm,val);
        case 'requestRewardSizeULorMS'
            rm=setRequestRewardSizeULorMS(rm,val);
        otherwise
            param
            error('unrecognized param')
    end
catch
    ex=lasterror
    if strcmp(ex.identifier,'MATLAB:UndefinedFunction')
        class(rm)    
        warning(sprintf('can''t set %s for reinforcementManager of this class',param))
    else
        param=param
        value=val
        rethrow(ex)
    end
end