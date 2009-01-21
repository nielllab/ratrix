function p=setUpOrStopDatanet(p,step,flag,data)

p.trainingSteps{step}=setUpOrStopDatanet(p.trainingSteps{step}, flag,data);

end % end function

