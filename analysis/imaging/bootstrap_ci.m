function [val cl cu] = bootstrap_ci(data, stat, interval);
%%% calculates bootstrapped confidence interval for function @stat
%%% operates along second dimension
for i = 1:size(data,1);
    val(i) = feval(stat,data(i,:));
    dist = bootstrp(1000,stat,data(i,:));
    cl(i) = prctile(dist,0.5*(100-interval));
    cu(i) = prctile(dist,100-0.5*(100-interval));
end

