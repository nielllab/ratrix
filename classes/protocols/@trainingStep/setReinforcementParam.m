function ts=setReinforcementParam(ts,param,val)

ts=setTrialManager(ts,setReinforcementParam(getTrialManager(ts),param,val));