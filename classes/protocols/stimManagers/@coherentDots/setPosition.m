function s=setPosition(s,n)
if n>=0 && n<=1
    s.position=n;
else
    error('0<=n<=1')
end