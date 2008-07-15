function numBatches = getNumCalibrationBatches(trialManager)

totalFrames = findTotalCalibrationFrames(trialManager);
fpb = acceptableNumberOfFramesPerBatch(trialManager); 
numBatches = ceil(totalFrames / fpb);
