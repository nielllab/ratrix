function s=setDur(s,n)
if n>=0
    s.movie_duration=n;
else
    error('0<=n')
end