function [out scale] = errorStim(stimManager,numFrames)
scale=0;


%it only flickers darker than the mean screen
maxErrorLum=stimManager.mean/2;  
maxErrorLum=max(maxErrorLum,4/255);  %so you see some flicker even on black backgrounds

%add maxErrorLum to stimManager
out = uint8(rand(1,1,numFrames)*maxErrorLum*double(intmax('uint8')));
