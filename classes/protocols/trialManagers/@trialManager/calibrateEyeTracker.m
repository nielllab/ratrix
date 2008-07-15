function trialManager=calibrateEyeTracker(trialManager)

if isempty(trialManager.eyeTracker)
    %empty eyeTracker?  don't do anything!
else
    trialManager.eyeTracker=calibrate(trialManager.eyeTracker);
end

