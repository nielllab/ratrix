function d = calcAutoRequest(hzd)
d=hzd.earliestStimTime + rand(1)*(hzd.latestStimTime - hzd.earliestStimTime);

end