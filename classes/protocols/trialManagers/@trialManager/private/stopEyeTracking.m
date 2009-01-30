function trialManager=stopEyeTracking(trialManager)

if isempty(trialManager.eyeTracker)
    %empty eyeTracker?  don't do anything!
else
    trialManager.eyeTracker=stop(trialManager.eyeTracker);
end

