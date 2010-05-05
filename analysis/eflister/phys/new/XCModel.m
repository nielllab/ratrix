function out=XCModel(x,n,period)
out=zeros(1,n);
out(1:period:n)=1;
out=out.*((1:n)-n)/(1-n);
if ~isscalar(x)
    if ~all(x==1:n)
        error('x input error')
    end
else
    out=interp1(1:n,out,x);
end
end