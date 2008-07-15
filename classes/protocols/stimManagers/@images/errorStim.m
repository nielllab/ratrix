function [out scale] = errorStim(stimManager,numFrames)
scale=0;

out = uint8(double(intmax('uint8'))*(0*ones(1,1,numFrames))); %black screen
% flicker intmax('uint8')*uint8(rand(1,1,numFrames)>.5);