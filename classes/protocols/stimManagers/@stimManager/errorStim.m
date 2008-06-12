function [out scale] = errorStim(stimManager,numFrames)
scale=0;

out = double(rand(1,1,numFrames)>.5);