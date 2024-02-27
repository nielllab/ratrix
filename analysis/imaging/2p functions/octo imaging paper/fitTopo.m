function [beta err r2 bad] = fitTopo(x,y,rf,thresh);

[beta sigma e] = mvregress([x,y, ones(size(x))],rf);
rf(abs(e)>thresh) = NaN; rf(abs(e)>thresh) = NaN;
[beta sigma e] = mvregress([x,y, ones(size(x))],rf);
err = sqrt(nanmean(e.^2));
r2 = 1-nanvar(e)/nanvar(rf);
bad = mean(isnan(e));