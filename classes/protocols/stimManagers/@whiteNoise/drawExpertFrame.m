function [doFramePulse expertCache dynamicDetails textLabel i] = ...
    drawExpertFrame(stimulus,stim,i,phaseStartTime,window,textLabel,floatprecision,destRect,filtMode,expertCache,ifi,scheduledFrameNum,dropFrames)
% 10/31/08 - implementing expert mode for whiteNoise
% this function calculates a expert frame, and then makes and draws the texture; nothing needs to be done in runRealTimeLoop
% this should be a stimManager-specific implementation (if expert mode is supported for the given stimulus)

% increment i
if dropFrames
    i=scheduledFrameNum;
else
    i=i+1;
end
% stimulus = stimManager
doFramePulse=true;
dynamicDetails=[];
% ================================================================================
% start calculating frames now
meanLuminance = stimulus.meanLuminance;
std = stimulus.std;
requestedStimLocation = stimulus.requestedStimLocation;
stixelSize = stimulus.stixelSize;

%calculate spatialDim
spatialDim=ceil([requestedStimLocation(3)-requestedStimLocation(1) requestedStimLocation(4)-requestedStimLocation(2)]./stixelSize);

% set randn to the current frame's precalculated seed value
randn('state',stim.seedValues(i));
expertFrame = randn(spatialDim)*1*std+meanLuminance;
expertFrame(expertFrame<0) = 0;
expertFrame(expertFrame>1) = 1;

% 11/14/08 - moved the make and draw to stimManager specific getexpertFrame b/c they might draw differently
dynTex = Screen('MakeTexture', window, expertFrame,0,0,floatprecision);
Screen('DrawTexture', window, dynTex,[],destRect,[],filtMode);
% clear dynTex from vram
Screen('Close',dynTex);

end % end function