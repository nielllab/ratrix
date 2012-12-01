function out = nanmedianMW(x,d) %my nanmedian function shadows the stats toolbox one and is incompatible
if ~exist('d','var') || isempty(d)
    d = 1;
end

out = builtinEF('nanmedian','stats',x,d);
end