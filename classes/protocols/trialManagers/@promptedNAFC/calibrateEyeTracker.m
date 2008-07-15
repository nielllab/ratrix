function trialManager=calibrateEyeTracker(trialManager)



eyeTracker=getEyeTracker(trialManager);
if isempty(eyeTracker)
    %empty eyeTracker?  don't do anything!
else
    eyeTracker=calibrate(eyeTracker);
    trialManager=setEyeTracker(trialManager,eyeTracker);
end

