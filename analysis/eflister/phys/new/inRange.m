function out=inRange(in,range)
if isvector(range) && all(range==sort(range)) && length(unique(range))==2 && all(isreal(range))
    out = in>=range(1) & in<=range(2);
else
    error('range must be real strictly ascending 2-vector')
end
end