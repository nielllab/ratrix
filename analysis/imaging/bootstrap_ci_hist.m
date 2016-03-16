function [val cl cu] = bootstrap_ci_hist(data, bins, interval);
%%% calculates bootstrapped confidence interval for function @stat
%%% operates along second dimension

val = hist(data,bins);

d = bootstrp(100,@(x){hist(x,bins )},data);
d= cell2mat(d);

cl = prctile(d,0.5*(100-interval));
cu = prctile(d,100-0.5*(100-interval));