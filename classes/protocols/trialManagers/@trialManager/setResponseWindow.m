function t = setResponseWindow(t, w)

if isempty(w)
    t.responseWindowMs=[0 Inf];
else
    if isvector(w) && isnumeric(w) && length(w)==2
        if w(1)>w(2) || w(1)<0 || isinf(w(1))
            error('responseWindowMs must be [min max] within the range [0 Inf] where min cannot be infinite');
        else
            t.responseWindowMs=w;
        end
    else
        error('responseWindowMs must be a 2-element array');
    end
end