function s=setCoherence(s,n)
if n>=0 && n<=1
    s.coherence=n;
else
    error('0<=n<=1')
end