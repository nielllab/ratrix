function s=setShapeMethod(s,n)
allowed={'','position'};
if any(ismember(n,allowed))
    s.shapeMethod=n;
else
    allowed
    error('shape method must be one of above')
end