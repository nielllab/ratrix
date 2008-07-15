function tm=setEyeTracker(tm,et)

if isa(et,'eyeTracker')
    tm.eyeTracker=et;
else
    error('not an eyeTracker')
end