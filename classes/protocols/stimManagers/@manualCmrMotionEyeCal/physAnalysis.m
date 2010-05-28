function [analysisdata cumulativedata] = physAnalysis(stimManager,spikeRecord,stimulusDetails,plotParameters,parameters,cumulativedata,eyeData,LFPRecord)
% error('remove this error when you update physAnalysis to be manualCmrMotionEyeCal');

analysisdata=[];
if ~isfield(cumulativedata,'medianA')
    cumulativedata.medianA=[];
end
if ~isfield(cumulativedata,'medianB')
    cumulativedata.medianB=[];
end
if ~isfield(cumulativedata,'trialNumberA')
    cumulativedata.trialNumberA=[];
end
if ~isfield(cumulativedata,'trialNumberB')
    cumulativedata.trialNumberB=[];
end

% stimManager is the stimulus manager
% spikes is a logical vector of size (number of neural data samples), where 1 represents a spike happening
% correctedFrameIndices is an nx2 array of frame start and stop indices - [start stop], n = number of frames
% stimulusDetails are the stimDetails from calcStim (hopefully they contain all the information needed to reconstruct stimData)
% photoDiode - currently not used
% plotParameters - currently not used
% 4/17/09 - spikeRecord contains all the data from this ENTIRE trial, but we should only do analysis on the current chunk
% to prevent memory problems

intervalsA=stimulusDetails.recordingIntervalsA;
intervalsB=stimulusDetails.recordingIntervalsB;
figure
title('position A')
xlabel('eye position (cr-p)')
hold on
for i=1:size(intervalsA,1)
    %get eyeData for phase-eye analysis
    % do this separately for each recording interval
    which=eyeData.eyeDataFrameInds>=intervalsA(i,1)&eyeData.eyeDataFrameInds<=intervalsA(i,2);
    if isempty(find(which)) % this interval never actually ran - so skip and go to next
        continue;
    end
    medianEyeSig=doPlot(eyeData,which);
    cumulativedata.medianA=[cumulativedata.medianA; medianEyeSig];
    cumulativedata.trialNumberA=[cumulativedata.trialNumberA; parameters.trialNumber];
end

figure
title('position B')
xlabel('eye position (cr-p)')
hold on
for i=1:size(intervalsB,1)
    %get eyeData for phase-eye analysis
    % do this separately for each recording interval
    which=eyeData.eyeDataFrameInds>=intervalsB(i,1)&eyeData.eyeDataFrameInds<=intervalsB(i,2);
    if isempty(find(which)) % this interval never actually ran - so skip and go to next
        continue;
    end
    medianEyeSig=doPlot(eyeData,which);
    cumulativedata.medianB=[cumulativedata.medianB; medianEyeSig];
    cumulativedata.trialNumberB=[cumulativedata.trialNumberB; parameters.trialNumber];
end

end % end function


function medianEyeSig=doPlot(eyeData,which)
thisIntEyeData=eyeData;
thisIntEyeData.eyeData=thisIntEyeData.eyeData(which,:);

[px py crx cry]=getPxyCRxy(thisIntEyeData,10);
eyeSig=[crx-px cry-py];
eyeSig(end,:)=[]; % remove last ones to match (not principled... what if we should throw out the first ones?)

% throw out any nans before calculating median
toRemove=isnan(eyeSig(:,1));
eyeSig(toRemove,:)=[];

medianEyeSig=[median(eyeSig(:,1)) median(eyeSig(:,2))];
plot(medianEyeSig(1),medianEyeSig(2),'.g','MarkerSize',24);
plot(eyeSig(:,1)',eyeSig(:,2)','.b','MarkerSize',4);
end