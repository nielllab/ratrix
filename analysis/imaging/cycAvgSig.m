function out = cycAvgSig(sig,period);
out = zeros(1,period);
for i = 1:period
    out(i) = mean(sig(i:period:length(sig)));
end
    