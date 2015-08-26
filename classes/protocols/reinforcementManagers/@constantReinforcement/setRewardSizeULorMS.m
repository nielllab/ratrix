function r=setRewardSizeULorMS(r, v)

if v>=0 && isreal(v) && isscalar(v) && isnumeric(v)
    r.rewardSizeULorMS=v;
else
    error('rewardSizeULorMS must be real numeric scalar >=0')
end