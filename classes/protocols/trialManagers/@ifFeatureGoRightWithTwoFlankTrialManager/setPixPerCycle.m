function t=setPixPerCycle(t, ppc, updateNow)

if ~exist('updateNow', 'var')
    updateNow = 1;
end

t.pixPerCycs = ppc;

if updateNow
t = deflate(t);
t = inflate(t);
end
