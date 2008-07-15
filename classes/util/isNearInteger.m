function out=isNearInteger(x)
if isinteger(x)
    out=true;
else
    y=x-round(x);
    out = all(abs(y(:)))<.000001;
end