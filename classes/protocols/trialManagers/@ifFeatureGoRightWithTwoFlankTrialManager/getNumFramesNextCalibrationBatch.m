function [frameIndices] = getNumFramesNextCalibrationBatch(trialManager, batch)

fpb = acceptableNumberOfFramesPerBatch(trialManager);
lastBatch = getNumCalibrationBatches(trialManager);

if batch == lastBatch
    totalFrames = findTotalCalibrationFrames(trialManager);
    frameIndices = (batch-1)*fpb+1: totalFrames;
else
    frameIndices = (batch-1)*fpb+1: (batch)*fpb;
end
    
