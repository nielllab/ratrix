function x=normalizeByDim(x,dim)

switch dim
    case 1
        a=size(x,1);
        b=1;
    case 2
        a=1;
        b=size(x,2);
    otherwise
        error('only works for 1 or 2')
end

mins=min(x,[],dim);
x=x-repmat(mins,a,b);

maxs=max(x,[],dim);
x=x./repmat(maxs,a,b);
end