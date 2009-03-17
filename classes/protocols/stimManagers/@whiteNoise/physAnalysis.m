function [analysisdata] = physAnalysis(stimManager,spikeData,stimulusDetails,plotParameters,parameters,analysisdata,eyeData)
% stimManager is the stimulus manager
% spikes is a logical vector of size (number of neural data samples), where 1 represents a spike happening
% frameIndices is an nx2 array of frame start and stop indices - [start stop], n = number of frames
% stimulusDetails are the stimDetails from calcStim (hopefully they contain all the information needed to reconstruct stimData)
% photoDiode - currently not used
% plotParameters - currently not used

% stimData is the entire movie shown for this trial
% removed 1/26/09 and replaced with stimulusDetails
% reconstruct stimData from stimulusDetails - stimManager specific method
if (ischar(stimulusDetails.strategy) && strcmp(stimulusDetails.strategy,'expert')) || ...
        (exist('fieldsInLUT','var') && ismember('stimDetails.strategy',fieldsInLUT) && strcmp(LUTlookup(sessionLUT,stimulusDetails.strategy),'expert'))
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
        stixels = round(255*(randn(spatialDim)*std+meanLuminance));
        stixels(stixels>255)=255; 
        stixels(stixels<0)=0; 
        
        %stixels=randn(spatialDim);  % for test only
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
timeWindowMs=[300 50]; % parameter [300 50]

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
numSpikingFrames=sum(spikeCount>0);
numSpikes = sum(spikeCount);
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
    % and in a stim trigger for each spike
    triggers(:,:,1:framesBefore+framesAfter+1,triggerInd:(triggerInd+spikeCount(i)-1))= ...
        repmat(stimData(:,:,[i-framesBefore:i+framesAfter]),[1 1 1 spikeCount(i)]); % pad for border handling?
    triggerInd = triggerInd+spikeCount(i);
end
% spike triggered average
STA=mean(triggers,4);    %the mean over instances of the trigger
STV=var(triggers,0,4);  %the variance over instances of the trigger (not covariance!)
% this is not the "unbiased variance" but the second moment of the sample about its mean

% fill in analysisdata with new values
analysisdata.STA = STA;
analysisdata.STV = STV;
analysisdata.numSpikes = numSpikes;
analysisdata.trialNumber=parameters.trialNumber;
% if the cumulative values don't exist (first analysis)
if ~isfield(analysisdata, 'cumulativeSTA')
    analysisdata.cumulativeSTA = STA;
    analysisdata.cumulativeSTV = STV;
    analysisdata.cumulativeNumSpikes = analysisdata.numSpikes;
    analysisdata.cumulativeTrialNumbers=parameters.trialNumber;
    analysisdata.singleTrialTemporalRecord=[];
else
    % set STA and STV to weighted probability mass of num events (==spike count)
    analysisdata.cumulativeSTA = (analysisdata.cumulativeSTA*analysisdata.cumulativeNumSpikes + STA*analysisdata.numSpikes) / ...
        (analysisdata.cumulativeNumSpikes + analysisdata.numSpikes);
    analysisdata.cumulativeSTV = (analysisdata.cumulativeSTV*analysisdata.cumulativeNumSpikes + STV*analysisdata.numSpikes) / ...
        (analysisdata.cumulativeNumSpikes + analysisdata.numSpikes);
    %then increment the cumulative count
    analysisdata.cumulativeNumSpikes = analysisdata.cumulativeNumSpikes + analysisdata.numSpikes;
    analysisdata.cumulativeTrialNumbers(end+1)=parameters.trialNumber;
end


%this trial..history of bright ones saved
analysisdata.singleTrialTemporalRecord(end+1,:)=getTemporalSignal(STA,STV,numSpikes,'bright');

% cumulative
[brightSignal brightCI brightInd]=getTemporalSignal(analysisdata.cumulativeSTA,analysisdata.cumulativeSTV,analysisdata.cumulativeNumSpikes,'bright');
[darkSignal darkCI darkInd]=getTemporalSignal(analysisdata.cumulativeSTA,analysisdata.cumulativeSTV,analysisdata.cumulativeNumSpikes,'dark');

rng=[min(analysisdata.cumulativeSTA(:)) max(analysisdata.cumulativeSTA(:))];

% 11/25/08 - update GUI
figure(plotParameters.handle); % make the figure current and then plot into it
% size(analysisdata.cumulativeSTA)

doSpatial=~(size(STA,1)==1 & size(STA,2)==1); % if spatial dimentions exist
% %% spatial signal (best via bright)
if doSpatial
    subplot(2,2,1)
    imagesc(squeeze(analysisdata.cumulativeSTA(:,:,brightInd(3))),rng);
    colormap(gray); colorbar;
    hold on; plot(brightInd(1), brightInd(2),'bo')
    hold on; plot(darkInd(1)  , darkInd(2),'ro')
    xlabel(sprintf('cumulative (%d-%d)',min(analysisdata.cumulativeTrialNumbers),max(analysisdata.cumulativeTrialNumbers)))
    
    subplot(2,2,2)
    hold off; imagesc(squeeze(STA(:,:,brightInd(3))),[min(STA(:)) max(STA(:))]);
    colormap(gray); colorbar;
    
    xlabel(sprintf('this trial (%d)',analysisdata.trialNumber))
    
    subplot(2,2,3)
end

timeMs=linspace(-timeWindowMs(1),timeWindowMs(2),size(STA,3));
ns=length(timeMs);

hold off; plot(timeWindowFrames([1 1])+1, [0 255],'k');
hold on;  plot([1 ns],meanLuminance([1 1])*255,'k')
plot([1:ns], analysisdata.singleTrialTemporalRecord, 'color',[.8 .8 .8])
fh=fill([1:ns fliplr([1:ns])]',[darkCI(:,1); flipud(darkCI(:,2))],'b'); set(fh,'edgeAlpha',0,'faceAlpha',.5)
fh=fill([1:ns fliplr([1:ns])]',[darkCI(:,1); flipud(darkCI(:,2))],'r'); set(fh,'edgeAlpha',0,'faceAlpha',.5)
plot([1:ns], darkSignal(:)','b')
plot([1:ns], brightSignal(:)','r')

peakFrame=find(brightSignal==max(brightSignal(:)));
timeInds=[1 peakFrame timeWindowFrames(1)+1 size(STA,3)];
set(gca,'XTickLabel',unique(timeMs(timeInds)),'XTick',unique(timeInds),'XLim',minmax(timeInds),'YLim',[minmax(analysisdata.singleTrialTemporalRecord(:)')+[-5 5]]);
ylabel('RGB(gunVal)')
xlabel('msec')

if doSpatial
    subplot(2,2,4)
    montage(reshape(analysisdata.cumulativeSTA,[size(STA,1) size(STA,2) 1 size(STA,3) ] ),'DisplayRange',rng)
    % %% spatial signal (all)
    % for i=1:
    % subplot(4,n,2*n+i)
    % imagesc(STA(:,:,i),'range',[min(STA(:)) min(STA(:))]);
    % end
end



function [sig CI ind]=getTemporalSignal(STA,STV,numSpikes,selection)

switch selection
    case 'bright'
        [ind]=find(STA==max(STA(:)));  %shortcut for a relavent region
    case 'dark'
        [ind]=find(STA==min(STA(:)));
    otherwise
        error('bad selection')
end

[X Y T]=ind2sub(size(STA),ind);
ind=[X Y T];
sig = STA(X,Y,:);
if nargout>1
    er95= sqrt(STV(X,Y,:)/numSpikes)*1.96; % b/c std error(=std/sqrt(N)) of mean * 1.96 = 95% confidence interval for gaussian, norminv(.975)
    CI=repmat(sig(:),1,2)+er95(:)*[-1 1];
end