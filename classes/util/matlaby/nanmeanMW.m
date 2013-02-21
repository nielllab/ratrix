function out = nanmeanMW(x,d) %my nanmean function shadows the stats toolbox one and is incompatible
if ~exist('d','var') || isempty(d)
    d = 1;
end

out = builtinEF('nanmean','stats',x,d);
end