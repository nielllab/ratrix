function tm=setReinforcementParam(tm,param,val)

tm= setReinforcementManager(tm,setReinforcementParam(getReinforcementManager(tm),param,val));