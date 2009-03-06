function [out scale] = correctStim(stimManager,numFrames)
scale=0;

out = double(getInterTrialLuminance(stimManager));