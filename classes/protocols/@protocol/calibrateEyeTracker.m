function p=calibrateEyeTracker(p,step)

p.trainingSteps{step}=calibrateEyeTracker(p.trainingSteps{step});

%if multistep, change all eyeTrackers on subsequent steps of the same type
%here in protocols eyetracker

