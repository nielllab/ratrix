function p=stopEyeTracking(p,step)

p.trainingSteps{step}=stopEyeTracking(p.trainingSteps{step});
