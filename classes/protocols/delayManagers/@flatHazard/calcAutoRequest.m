function d = calcAutoRequest(hzd)
% returns autoRequest delay in terms of ms

% continuous (exponential function)
p = -hzd.value/log(1-hzd.percentile);
d=exprnd(p)+hzd.fixedDelayMs;

% discrete (geometric function)
% p = 1-exp(log(1-hzd.percentile)/(hzd.value+1));
% d=geornd(p)+hzd.fixedDelayMs;

end