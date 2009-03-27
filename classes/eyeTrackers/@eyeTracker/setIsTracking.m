function et=setIsTracking(et,value)

if islogical(value)
    et.isTracking=value;
else
    error('is tracking is a state that must be true or false')
end