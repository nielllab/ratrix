function [out scale] = errorStim(stimManager,numFrames)
scale=0;

out = 255*uint8(rand(1,1,numFrames)>.5);