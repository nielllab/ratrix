function d = calcAutoRequest(hzd)
p = 1-exp(log(1-hzd.percentile)/(hzd.value+1));
d=geornd(p)+hzd.fixedDelayMs;

end