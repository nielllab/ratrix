function [analysisdata] = physAnalysis(stimManager,spikeData,stimulusDetails,plotParameters,parameters,analysisdata)
% stimManager is the stimulus manager
% spikes is a logical vector of size (number of neural data samples), where 1 represents a spike happening
% frameIndices is an nx2 array of frame start and stop indices - [start stop], n = number of frames
% stimulusDetails are the stimDetails from calcStim (hopefully they contain all the information needed to reconstruct stimData)
% photoDiode - currently not used
% plotParameters - currently not used

% stimData is the entire movie shown for this trial
% removed 1/26/09 and replaced with stimulusDetails
% reconstruct stimData from stimulusDetails - stimManager specific method
if strcmp(stimulusDetails.strategy,'expert')
    seeds=stimulusDetails.seedValues;
    spatialDim = stimulusDetails.spatialDim;
    std = stimulusDetails.std;
    meanLuminance = stimulusDetails.meanLuminance;
    height=stimulusDetails.height;
    width=stimulusDetails.width;
    factor = width/spatialDim(1);

    %                     stimData=zeros(height,width,length(seeds)); % method 1
    stimData=zeros(spatialDim(1),spatialDim(2),length(seeds)); % method 2
    for frameNum=1:length(seeds)
        randn('state',seeds(frameNum));
        stixels = randn(spatialDim)*255*std+meanLuminance;

        % =======================================================
        % method 1 - resize the movie frame to full pixel size
        % for each stixel row, expand it to a full pixel row
        %                         for stRow=1:size(stixels,1)
        %                             pxRow=[];
        %                             for stCol=1:size(stixels,2) % for each column stixel, repmat it to width/spatialDim
        %                                 pxRow(end+1:end+factor) = repmat(stixels(stRow,stCol), [1 factor]);
        %                             end
        %                             % now repmat pxRow vertically in stimData
        %                             stimData(factor*(stRow-1)+1:factor*stRow,:,frameNum) = repmat(pxRow, [factor 1]);
        %                         end
        %                         % reset variables
        %                         pxRow=[];
        % =======================================================
        % method 2 - leave stimData in stixel size
        stimData(:,:,frameNum) = stixels;


        % =======================================================
    end
end


% refreshRate - try to retrieve from neuralRecord (passed from stim computer)
if isfield(parameters, 'refreshRate')
    refreshRate = parameters.refreshRate;
else
    refreshRate = 100;
end

% timeWindowMs
timeWindowMs=[10 10]; % parameter [300 50]

%Check num stim frames makes sense
if size(spikeData.frameIndices,1)~=size(stimData,3)
    calculatedNumberOfFrames = size(spikeData.frameIndices,1)
    storedNumberOfFrames = size(stimData,3)
    error('the number of frame start/stop times does not match the number of movie frames');
end

% count the number of spikes per frame
% spikeCount is a 1xn vector of (number of spikes per frame), where n = number of frames
spikeCount=zeros(1,size(spikeData.frameIndices,1));
for i=1:length(spikeCount) % for each frame
    spikeCount(i)=sum(spikeData.spikes(spikeData.frameIndices(i,1):spikeData.frameIndices(i,2)));  % inclusive?  policy: include start & stop
end

% calculate the number of frames in the window for each spike
timeWindowFrames=ceil(timeWindowMs*(refreshRate/1000));

% grab the window for each spike, and store into triggers
% triggers is a 4-d matrix:
% each 3d element is a movie corresponding to the spike (4th dim)
numSpikes=sum(spikeCount>0);
triggerInd = 1;
% triggers = zeros(stim_width, stim_height, # of window frames per spike, number of spikes)
triggers=zeros(size(stimData,1),size(stimData,2),sum(timeWindowFrames)+1,numSpikes); % +1 is for the frame that is on the spike
for i=find(spikeCount>0) % for each index that has spikes
    %every frame with a spike count, gets included... it is multiplied by the number of spikes in that window
    framesBefore = timeWindowFrames(1);
    framesAfter = timeWindowFrames(2);
    % border handling (if spike was in first frame, cant get any framesBefore)
    if i-framesBefore <= 0
        framesBefore = i-1;
    end
    if i+framesAfter > size(stimData,3)
        framesAfter = size(stimData,3) - i - 1;
    end
    triggers(:,:,1:framesBefore+framesAfter+1,triggerInd)= ...
        spikeCount(i).* stimData(:,:,[i-framesBefore:i+framesAfter]); % pad for border handling?
    triggerInd = triggerInd+1;
end
% spike triggered average
STA=mean(triggers,4);  %the mean over instances of the trigger



%% temporal signal
[brightInd]=find(STA==max(STA(:)));  %shortcut for a relavent region
[darkInd]=find(STA==min(STA(:)));  %shortcut for a relavent region
[brightX brightY brightT]=ind2sub(size(STA),brightInd);
[darkX darkY darkT]=ind2sub(size(STA),darkInd);

brightSignal = STA(brightX,brightY,:);
darkSignal = STA(darkX,darkY,:);
brightSignalPlottable(1:size(brightSignal,3)) = brightSignal(1,1,:);
darkSignalPlottable(1:size(darkSignal,3)) = darkSignal(1,1,:);
brightSignalPlottable = brightSignalPlottable';
darkSignalPlottable = darkSignalPlottable';

% subplot(2,2,1) 
% plot([1:length(brightSignalPlottable)], [brightSignalPlottable darkSignalPlottable])
% 
% 
% %% spatial signal (best)
% subplot(2,2,2) 
% imagesc(squeeze(STA(:,:,brightT)),[min(STA(:)) max(STA(:))]);
% 
% 
% %% spatial signal (all)
% subplot(2,1,2) 
% montage(STA)
% for i=1:
% subplot(4,n,2*n+i) 
% imagesc(STA(:,:,i),'range',[min(STA(:)) min(STA(:))]);
% end


% fill in analysisdata with new values
% if the cumulative values don't exist (first analysis)
if ~isfield(analysisdata, 'cumulativeSTA')
    analysisdata.cumulativeSTA = STA;
else
    % if it does exist, then set to weighted average
    analysisdata.cumulativeSTA = (analysisdata.cumulativeSTA*sum(analysisdata.cumulativeSpikeCount) + STA*sum(spikeCount)) / ...
        sum(analysisdata.cumulativeSpikeCount + spikeCount);
end
% fill in spikeCount
if ~isfield(analysisdata, 'cumulativeSpikeCount')
    analysisdata.cumulativeSpikeCount = spikeCount;
else
    analysisdata.cumulativeSpikeCount = analysisdata.cumulativeSpikeCount + spikeCount;
end

analysisdata.STA = STA;
analysisdata.spikeCount = spikeCount;
% 11/25/08 - update GUI
figure(plotParameters.handle); % make the figure current and then plot into it
% size(analysisdata.cumulativeSTA)
imagesc(analysisdata.cumulativeSTA(:,:,2));
colormap(gray); colorbar;

end % end function
% ===============================================================================================