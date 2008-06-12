function [out scale] = errorStim(stimManager,numFrames)
scale=0;

out = intmax('uint8')*uint8(rand(1,1,numFrames)>.5);