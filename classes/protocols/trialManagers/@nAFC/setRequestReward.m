function tm=setRequestReward(tm,value,verbose)

if ~exist('verbose','var')
    verbose=0;
end

if value >=0;
    if verbose
        disp(sprintf('request used to be %2.2g and is now %2.2g',tm.requestRewardSizeULorMS,value))
    end
    tm.requestRewardSizeULorMS=value;
else
    value
    error('not a good value for requestRewardSizeULorMS, must be >=0')
end