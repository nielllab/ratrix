function tm=setReinforcementParam(tm,param,val)

switch param
    case 'requestReward'
        tm=setRequestReward(tm,val,true);
    otherwise
        tm= setReinforcementManager(tm,setReinforcementParam(getReinforcementManager(tm),param,val));
end