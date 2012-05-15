function [out scale] = correctStim(stimManager,numFrames)
%if nAFC, consider showing last frame of discriminandum for something like
%2x the reward duration or something

scale=0;

out = double(getInterTrialLuminance(stimManager));