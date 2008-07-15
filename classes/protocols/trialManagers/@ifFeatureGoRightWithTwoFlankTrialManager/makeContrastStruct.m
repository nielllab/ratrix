function fContrast = makeContrastStruct(trialManager, fLum)


%     fLum.targetLuminance = [];
%     fLum.frameIndices= [];
%     fLum.targetPhase = [];
    
%     varyingParams = ...
%     [fLum.targetOrientation;...
%     fLum.targetContrast;...
%     fLum.flankerContrast;...
%     fLum.flankerOrientation;...
%     fLum.flankerPhase;...
%     fLum.deviation;...
%     fLum.xPositionPercent;...
%     fLum.yPositionPercent;...
%     fLum.stdGaussMask;...
%     fLum.mean]';

dataNames = fieldnames(fLum);
dataTemp = struct2cell(fLum); 
dataTemp = cell2mat(dataTemp); % converting fLum into a numFields x data array

[contexts junk contextInd] = unique(dataTemp(4:end,:)', 'rows');
numRepeats = size(fLum.frameIndices,2) / size(unique(fLum.frameIndices),2);
% cycles through the indices per phase (i.e two orientations: vertical and
% horizontal)


contrastMethod = 'std'; % this should be classified from the higher level function

for i = 1:max(contextInd) 
    if (sum(contextInd == i)/numRepeats)~= size(trialManager.phase)
        error('not enough phases to computer contrast structure');
    end
    % check that phase is monotonically increasing  ,   all(diff(phase) > 0) 
    measuredData = fLum.targetLuminance(contextInd == i);
    [fContrast.measuredContrast(i), fContrast.measuredMean(i), fContrast.measuredSNR(i), fContrast.measuredPeak(i), fContrast.measuredTrough(i)] = getAmplitudeFromFlum(trialManager, measuredData,  numRepeats, contrastMethod);
end 

fContrast.contexts = contexts;
fContrast.dataNames = dataNames(4:end);
