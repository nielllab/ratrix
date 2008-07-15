function fLum=addToLumStruct(trialManager, fLum, frameDetails, frameIndices, luminanceData)

if isempty(fLum)
    fLum.targetLuminance = [];
    fLum.frameIndices= [];
    fLum.targetPhase = [];
    fLum.targetOrientation = [];
    fLum.targetContrast = [];
    fLum.flankerContrast = [];
    fLum.flankerOrientation = [];
    fLum.flankerPhase = [];
    fLum.deviation = [];
    fLum.xPositionPercent = [];
    fLum.yPositionPercent = [];
    fLum.stdGaussMask = [];
    fLum.mean = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

temp = repmat(frameIndices, [size(luminanceData,2),1]);
frameIndices = reshape(temp, 1,numel(temp)); % remapping the frame indices to repeat the number of measurement times

luminanceData = reshape(luminanceData', 1, numel(luminanceData)); % remapping luminance data

temp = [frameDetails{frameIndices}];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fLum.frameIndices= [fLum.frameIndices, frameIndices];
fLum.targetPhase = [fLum.targetPhase, [temp.targetPhase]];
fLum.targetOrientation = [fLum.targetOrientation,  [temp.targetOrientation]];
fLum.targetLuminance = [fLum.targetLuminance,  luminanceData];
fLum.targetContrast = [fLum.targetContrast, [temp.targetContrast]];
fLum.flankerContrast = [fLum.flankerContrast, [temp.flankerContrast]];
fLum.flankerOrientation = [fLum.flankerOrientation, [temp.flankerOrientation]];
fLum.flankerPhase = [fLum.flankerPhase, [temp.flankerPhase]];
fLum.deviation = [fLum.deviation, [temp.deviation]];
fLum.xPositionPercent = [fLum.xPositionPercent, [temp.xPositionPercent]];
fLum.yPositionPercent = [fLum.yPositionPercent, [temp.yPositionPercent]];
fLum.stdGaussMask = [fLum.stdGaussMask, [temp.stdGaussMask]];
fLum.mean = [fLum.mean, double([temp.mean])];




