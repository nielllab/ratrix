function tm=setRequestReward(tm,value,verbose)
% error('error check on value is inadequate (should check real numeric scalar) and redundant with constructor''s error check, please rewrite and route constructor through this method')
if ~exist('verbose','var')
    verbose=0;
end

if value >=0 && isreal(value) && isnumeric(value) && isscalar(value)
    if verbose
        disp(sprintf('request used to be %2.2g and is now %2.2g',tm.requestRewardSizeULorMS,value))
    end
    tm.requestRewardSizeULorMS=value;
else
    value
    error('not a good value for requestRewardSizeULorMS, must be >=0')
end