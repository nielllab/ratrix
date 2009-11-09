function rm=setReinforcementParam(rm,param,val)



try
    verySmall=0; % msec... this enables the possibility of very small rewards or penalties... used for debugging... had not effect if set to zero.
    switch param
        case {'penaltyMS','msPenalty'}
            %if they are equal we change both of them. if one is 0 we
            %change the other one. if they are both nonzero but not equal
            %error.
            rm=setMsPenalty(rm,val);
            if rm.missMsPenalty==rm.falseAlarmMsPenalty
                rm.falseAlarmMsPenalty=val;
                rm.missMsPenalty=val;
            elseif (rm.missMsPenalty==0 || rm.missMsPenalty==verySmall)&& rm.falseAlarmMsPenalty>0
                rm.falseAlarmMsPenalty=val;
            elseif rm.missMsPenalty>0 && (rm.falseAlarmMsPenalty==0 || rm.falseAlarmMsPenalty==verySmall)
                rm.missMsPenalty=val;
            else
                error('dont know how to handle this case');
            end    
        case {'scalar', 'requestRewardSizeULorMS'}
            rm.reinforcementManager=setReinforcementParam(rm.reinforcementManager,param,val);
        case 'rewardULorMS'
            
            if rm.hitRewardSizeULorMS==rm.correctRejectRewardSizeULorMS
                rm.correctRejectRewardSizeULorMS=val;
                rm.hitRewardSizeULorMS=val;
            elseif (rm.hitRewardSizeULorMS==0 || rm.hitRewardSizeULorMS==verySmall) && rm.correctRejectRewardSizeULorMS>0
                rm.correctRejectRewardSizeULorMS=val;
            elseif rm.hitRewardSizeULorMS>0 && (rm.correctRejectRewardSizeULorMS==0 || rm.correctRejectRewardSizeULorMS==verySmall)
                rm.hitRewardSizeULorMS=val;
            else
                error('dont know how to handle this case');
            end
            
        otherwise
            param
            error('unrecognized param')
    end
catch ex
    if strcmp(ex.identifier,'MATLAB:UndefinedFunction')
        class(rm)    
        warning(sprintf('can''t set %s for reinforcementManager of this class',param))
        keyboard
    else
        param=param
        value=val
        rethrow(ex)
    end
end
