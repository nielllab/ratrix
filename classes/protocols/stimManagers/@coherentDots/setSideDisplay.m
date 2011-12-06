function s=setSideDisplay(s,n)
if n>=0 && n<=1
    s.sideDisplay=n;
else
    error('0<=n<=1')
end