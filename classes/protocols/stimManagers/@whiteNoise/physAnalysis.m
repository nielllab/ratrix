function [analysisdata cumulativedata] = physAnalysis(stimManager,spikeRecord,stimulusDetails,plotParameters,parameters,cumulativedata,eyeData)
% stimManager is the stimulus manager
% spikes is a logical vector of size (number of neural data samples), where 1 represents a spike happening
% correctedFrameIndices is an nx2 array of frame start and stop indices - [start stop], n = number of frames
% stimulusDetails are the stimDetails from calcStim (hopefully they contain all the information needed to reconstruct stimData)
% photoDiode - currently not used
% plotParameters - currently not used
% 4/17/09 - spikeRecord contains all the data from this ENTIRE trial, but we should only do analysis on the current chunk
% to prevent memory problems

% to save memory, only do analysis on spikeRecord.currentChunk's data
which=find(spikeRecord.chunkID==spikeRecord.currentChunk);
spikeRecord.spikes=spikeRecord.spikes(which);
spikeRecord.spikeTimestamps=spikeRecord.spikeTimestamps(which);
spikeRecord.spikeWaveforms=spikeRecord.spikeWaveforms(which,:);
spikeRecord.assignedClusters=spikeRecord.assignedClusters(which,:);
spikeRecord.chunkID=spikeRecord.chunkID(which);
which=find(spikeRecord.chunkIDForCorrectedFrames==spikeRecord.currentChunk);
spikeRecord.correctedFrameIndices=spikeRecord.correctedFrameIndices(which,:);
spikeRecord.stimInds=spikeRecord.stimInds(which);
which=find(spikeRecord.chunkIDForDetails==spikeRecord.currentChunk);
spikeRecord.photoDiode=spikeRecord.photoDiode(which);
spikeRecord.spikeDetails=spikeRecord.spikeDetails(which);

% timeWindowMs
timeWindowMs=[300 50]; % parameter [300 50]
% refreshRate - try to retrieve from neuralRecord (passed from stim computer)
if isfield(parameters, 'refreshRate')
    refreshRate = parameters.refreshRate;
else
    error('dont use default refreshRate');
    refreshRate = 100;
end
% calculate the number of frames in the window for each spike
timeWindowFrames=ceil(timeWindowMs*(refreshRate/1000));

if (ischar(stimulusDetails.strategy) && strcmp(stimulusDetails.strategy,'expert')) || ...
        (exist('fieldsInLUT','var') && ismember('stimDetails.strategy',fieldsInLUT) && strcmp(LUTlookup(sessionLUT,stimulusDetails.strategy),'expert'))
    seeds=stimulusDetails.seedValues;
    spatialDim = stimulusDetails.spatialDim;
    std = stimulusDetails.std;
    meanLuminance = stimulusDetails.meanLuminance;
    height=stimulusDetails.height;
    width=stimulusDetails.width;
    factor = width/spatialDim(1);
end

%SET UP RELATION stimInd <--> frameInd
analyzeDrops=true;
if analyzeDrops
    stimFrames=spikeRecord.stimInds;
    correctedFrameIndices=spikeRecord.correctedFrameIndices;
else
    numStimFrames=max(spikeRecord.stimInds);
    stimFrames=1:numStimFrames;
    firstFramePerStimInd=~[0 diff(spikeRecord.stimInds)==0];
    correctedFrameIndices=spikeRecord.correctedFrameIndices(firstFramePerStimInd);
end

% reconstruct stimData from stimulusDetails - stimManager specific method
%  stimData=zeros(height,width,length(seeds)); % method 1
stimData=nan(spatialDim(1),spatialDim(2),length(stimFrames)); % method 2
for i=1:length(stimFrames)
    randn('state',seeds(mod(stimFrames(i)-1,length(seeds))+1)); % we only have enough seeds for a single repeat of whiteNoise; if numRepeats>1, need to modulo
    whiteVal=255;
    stixels = round(whiteVal*(randn(spatialDim)*std+meanLuminance));
    stixels(stixels>whiteVal)=whiteVal;
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
    %                             stimData(factor*(stRow-1)+1:factor*stRow,:,i) = repmat(pxRow, [factor 1]);
    %                         end
    %                         % reset variables
    %                         pxRow=[];
    % =======================================================
    % method 2 - leave stimData in stixel size
    stimData(:,:,i) = stixels;


    % =======================================================
end
if any(isnan(stimData))
    error('missed a frame in reconstruction')
end

%Check num stim frames makes sense
if size(spikeRecord.correctedFrameIndices,1)~=size(stimData,3)
    calculatedNumberOfFrames = size(spikeRecord.correctedFrameIndices,1)
    storedNumberOfFrames = size(stimData,3)
    error('the number of frame start/stop times does not match the number of movie frames');
end

%CHOOSE CLUSTER
allSpikes=spikeRecord.spikes; %all waveforms
waveInds=allSpikes; % location of all waveforms
if isstruct(spikeRecord.spikeDetails) && ismember({'processedClusters'},fields(spikeRecord.spikeDetails))
    if length(spikeRecord.spikeDetails.processedClusters)~=length(waveInds)
        length(spikeRecord.spikeDetails.processedClusters)
        length(waveInds)
        error('spikeDetails does not correspond to the spikeRecord''s spikes');
    end
    thisCluster=[spikeRecord.spikeDetails.processedClusters]==1;
else
    thisCluster=logical(ones(size(waveInds)));
    %use all (photodiode uses this)
end
allSpikes(~thisCluster)=[]; % remove spikes that dont belong to thisCluster

analysisdata=[];
% figure out safe "piece" size based on spatialDim and timeWindowFrames
% we only need to reduce the size of spikes
maxSpikes=floor(15000000/(spatialDim(1)*spatialDim(2)*sum(timeWindowFrames))); % equiv to 100 spikes at 64x64 spatial dim, 36 frame window
starts=[1:maxSpikes:length(allSpikes) length(allSpikes)+1];
for piece=1:(length(starts)-1)
    spikes=allSpikes(starts(piece):(starts(piece+1)-1));


    % count the number of spikes per frame
    % spikeCount is a 1xn vector of (number of spikes per frame), where n = number of frames

    spikeCount=zeros(1,size(correctedFrameIndices,1));
    for i=1:length(spikeCount) % for each frame
        spikeCount(i)=length(find(spikes>=correctedFrameIndices(i,1)&spikes<=correctedFrameIndices(i,2)));
    %     spikeCount(i)=sum(spikes(spikeRecord.correctedFrameIndices(i,1):spikeRecord.correctedFrameIndices(i,2)));  % inclusive?  policy: include start & stop
    end



    %figure out which spikes to use based on eyeData
    if ~isempty(eyeData)
        [px py crx cry]=getPxyCRxy(eyeData);
        eyeSig=[crx-px cry-py];

        if length(unique(eyeSig(:,1)))>10 % if at least 10 x-positions
            %do stuff
            density=hist3(eyeSig);
        else
            disp(sprintf('no good eyeData on trial %d',parameters.trialNumber))
        end
    end


    % grab the window for each spike, and store into triggers
    % triggers is a 4-d matrix:
    % each 3d element is a movie corresponding to the spike (4th dim)
    numSpikingFrames=sum(spikeCount>0);
    numSpikes = sum(spikeCount);
    triggerInd = 1;
    % triggers = zeros(stim_width, stim_height, # of window frames per spike, number of spikes)
    %initialize trigger with mean values for temporal border padding
    meanValue=whiteVal*stimulusDetails.meanLuminance;
    try
    triggers=meanValue(ones(size(stimData,1),size(stimData,2),sum(timeWindowFrames)+1,numSpikes)); % +1 is for the frame that is on the spike
    catch ex
        disp(['CAUGHT EX (in whiteNoise.physAnalysis):' getReport(ex)]);
        memory
        keyboard
    end
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
    try
        STV=var(triggers,0,4);  %the variance over instances of the trigger (not covariance!)
        % this is not the "unbiased variance" but the second moment of the sample about its mean
    catch ex
        getReport(ex); % common place to run out of memory
        STV=nan(size(STA)); % thus no confidence will be reported
    end

    % fill in partialdata with new values
    partialdata=[];
    partialdata.STA = STA;
    partialdata.STV = STV;
    partialdata.numSpikes = numSpikes;
    partialdata.trialNumber=parameters.trialNumber;
    partialdata.chunkID=parameters.chunkID;
    
    if isempty(analysisdata) %first piece
        analysisdata=partialdata;
    else % not the first piece of analysisdata
        [analysisdata.STA analysisdata.STV analysisdata.numSpikes junk] = ...
            updateCumulative(analysisdata.STA,analysisdata.STV,analysisdata.numSpikes,analysisdata.trialNumber,analysisdata.chunkID,...
            partialdata.STA,partialdata.STV,partialdata.numSpikes,partialdata.trialNumber,partialdata.chunkID);
    end
end
% end loop over safe "pieces"


% now we should have our analysisdata for all "pieces"
% if the cumulative values don't exist (first analysis)
if ~isfield(cumulativedata, 'cumulativeSTA')  || ~all(size(analysisdata.STA)==size(cumulativedata.cumulativeSTA)) %first trial through with these parameters
    cumulativedata.cumulativeSTA = analysisdata.STA;
    cumulativedata.cumulativeSTV = analysisdata.STV;
    cumulativedata.cumulativeNumSpikes = analysisdata.numSpikes;
    cumulativedata.cumulativeTrialNumbers=parameters.trialNumber;
    cumulativedata.cumulativeChunkIDs=parameters.chunkID;
    analysisdata.singleChunkTemporalRecord=[];
    addSingleTrial=true;
elseif isempty(find(parameters.trialNumber==cumulativedata.cumulativeTrialNumbers&...
        parameters.chunkID==cumulativedata.cumulativeChunkIDs))
    %only for new trials or new chunks
    [cumulativedata.cumulativeSTA cumulativedata.cumulativeSTV cumulativedata.cumulativeNumSpikes ...
        cumulativedata.cumulativeTrialNumbers cumulativedata.cumulativeChunkIDs] = ...
        updateCumulative(cumulativedata.cumulativeSTA,cumulativedata.cumulativeSTV,cumulativedata.cumulativeNumSpikes,...
        cumulativedata.cumulativeTrialNumbers,cumulativedata.cumulativeChunkIDs,...
        analysisdata.STA,analysisdata.STV,analysisdata.numSpikes,...
        analysisdata.trialNumber,analysisdata.chunkID);
    addSingleTrial=true;
else % repeat sweep through same trial
    %do nothing
    addSingleTrial=false;
end
if addSingleTrial
    %this trial..history of bright ones saved
    analysisdata.singleChunkTemporalRecord(1,:)=...
        getTemporalSignal(analysisdata.STA,analysisdata.STV,analysisdata.numSpikes,'bright');
end

% cumulative
[brightSignal brightCI brightInd]=getTemporalSignal(cumulativedata.cumulativeSTA,cumulativedata.cumulativeSTV,cumulativedata.cumulativeNumSpikes,'bright');
[darkSignal darkCI darkInd]=getTemporalSignal(cumulativedata.cumulativeSTA,cumulativedata.cumulativeSTV,cumulativedata.cumulativeNumSpikes,'dark');

rng=[min(cumulativedata.cumulativeSTA(:)) max(cumulativedata.cumulativeSTA(:))];

% 11/25/08 - update GUI
%figure(plotParameters.handle); % make the figure current and then plot into it
figure(min(cumulativedata.cumulativeTrialNumbers)) % trialBased is better
set(gcf,'Units','pixels');
set(gcf,'position',[100 100 800 700]);
% size(analysisdata.cumulativeSTA)

doSpatial=~(size(STA,1)==1 & size(STA,2)==1); % if spatial dimentions exist
% %% spatial signal (best via bright)
if doSpatial
    
    
    %fit model to best spatial
    stdThresh=1;
    [STAenvelope STAparams] =fitGaussianEnvelopeToImage(cumulativedata.cumulativeSTA(:,:,brightInd(3)),stdThresh,false,false,false);
    cx=STAparams(2)*size(STAenvelope,2)+1;
    cy=STAparams(3)*size(STAenvelope,1)+1;
    stdx=size(STAenvelope,2)*STAparams(5);
    stdy=size(STAenvelope,1)*STAparams(5);
    e1 = fncmb(fncmb(rsmak('circle'),[stdx*1 0;0 stdy*1]),[cx;cy]);
    e2 = fncmb(fncmb(rsmak('circle'),[stdx*2 0;0 stdy*2]),[cx;cy]);
    e3 = fncmb(fncmb(rsmak('circle'),[stdx*3 0;0 stdy*3]),[cx;cy]);
    
    
    %get significant pixels and denoised spots
    stdStimulus = stimulusDetails.std*whiteVal;
    meanLuminanceStimulus = stimulusDetails.meanLuminance*whiteVal;
    [bigSpots sigPixels]=getSignificantSTASpots(cumulativedata.cumulativeSTA(:,:,brightInd(3)),cumulativedata.cumulativeNumSpikes,meanLuminanceStimulus,stdStimulus,ones(3),3,0.05);
    [bigIndY bigIndX]=find(bigSpots~=0);
    [sigIndY sigIndX]=find(sigPixels~=0);
    
    
        subplot(2,2,1)
    imagesc(squeeze(cumulativedata.cumulativeSTA(:,:,brightInd(3))),rng);
    colormap(gray); colorbar;
    hold on; plot(brightInd(2), brightInd(1),'bo')
    hold on; plot(darkInd(2)  , darkInd(1),  'ro')
    hold on; plot(bigIndX     , bigIndY,     'y.')
    hold on; plot(sigIndX     , sigIndY,     'y.','markerSize',1)
    minTrial=min(cumulativedata.cumulativeTrialNumbers);
    maxTrial=max(cumulativedata.cumulativeTrialNumbers);
    xlabel(sprintf('cumulative (trials.chunk %d.%d-%d.%d)',...
        minTrial,min(cumulativedata.cumulativeChunkIDs(find(cumulativedata.cumulativeTrialNumbers==minTrial))),...
        maxTrial,max(cumulativedata.cumulativeChunkIDs(find(cumulativedata.cumulativeTrialNumbers==maxTrial)))));
    fnplt(e1,1,'g'); fnplt(e2,1,'g'); fnplt(e3,1,'g'); % plot elipses
        
    
    subplot(2,2,2)
    hold off; imagesc(squeeze(analysisdata.STA(:,:,brightInd(3))),[min(analysisdata.STA(:)) max(analysisdata.STA(:))]);
    hold on; plot(brightInd(2), brightInd(1),'bo')
    hold on; plot(darkInd(2)  , darkInd(1),'ro')
    colormap(gray); colorbar;
    fnplt(e1,1,'g'); fnplt(e2,1,'g'); fnplt(e3,1,'g'); % plot elipses
    xlabel(sprintf('this trial (%d) - this chunk (%d)',analysisdata.trialNumber,analysisdata.chunkID))
    
    subplot(2,2,3)
    
    
end

timeMs=linspace(-timeWindowMs(1),timeWindowMs(2),size(analysisdata.STA,3));
ns=length(timeMs);
hold off; plot(timeWindowFrames([1 1])+1, [0 whiteVal],'k');
hold on;  plot([1 ns],meanLuminance([1 1])*whiteVal,'k')
try
plot([1:ns], analysisdata.singleChunkTemporalRecord, 'color',[.8 .8 1])
catch
    keyboard
end
fh=fill([1:ns fliplr([1:ns])]',[darkCI(:,1); flipud(darkCI(:,2))],'r'); set(fh,'edgeAlpha',0,'faceAlpha',.5)
fh=fill([1:ns fliplr([1:ns])]',[brightCI(:,1); flipud(brightCI(:,2))],'b'); set(fh,'edgeAlpha',0,'faceAlpha',.5)
plot([1:ns], darkSignal(:)','r')
plot([1:ns], brightSignal(:)','b')

peakFrame=find(brightSignal==max(brightSignal(:)));
timeInds=[1 peakFrame timeWindowFrames(1)+1 size(analysisdata.STA,3)];
set(gca,'XTickLabel',unique(timeMs(timeInds)),'XTick',unique(timeInds),'XLim',minmax(timeInds));
set(gca,'YLim',[minmax([analysisdata.singleChunkTemporalRecord(:)' darkCI(:)' brightCI(:)'])+[-5 5]])
ylabel('RGB(gunVal)')
xlabel('msec')

if doSpatial
    subplot(2,2,4)
    montage(reshape(cumulativedata.cumulativeSTA,[size(analysisdata.STA,1) size(analysisdata.STA,2) 1 size(analysisdata.STA,3) ] ),...
        'DisplayRange',rng)
    % %% spatial signal (all)
    % for i=1:
    % subplot(4,n,2*n+i)
    % imagesc(STA(:,:,i),'range',[min(STA(:)) min(STA(:))]);
    % end
end

drawnow


function [sig CI ind]=getTemporalSignal(STA,STV,numSpikes,selection)

    switch selection
        case 'bright'
            [ind]=find(STA==max(STA(:)));  %shortcut for a relavent region
        case 'dark'
            [ind]=find(STA==min(STA(:)));
        otherwise
            error('bad selection')
    end
try
    ind=ind(1); %use the first one if there is a tie. (more common with low samples)
catch
    ple
    keyboard
end
    [X Y T]=ind2sub(size(STA),ind);
    ind=[X Y T];
    sig = STA(X,Y,:);
    if nargout>1
        er95= sqrt(STV(X,Y,:)/numSpikes)*1.96; % b/c std error(=std/sqrt(N)) of mean * 1.96 = 95% confidence interval for gaussian, norminv(.975)
        CI=repmat(sig(:),1,2)+er95(:)*[-1 1];
    end

end % end function

function [cSTA cSTV cNumSpikes cTrialNumbers cChunkIDs] = updateCumulative(cSTA,cSTV,cNumSpikes,cTrialNumbers,cChunkIDs,...
        STA,STV,numSpikes,trialNumbers,chunkID)
    % only update the cumulatives if the partials are NOT nan (arithmetic w/ nans wipes out any valid numbers)
    if ~any(isnan(STA(:)))
        cSTA=(cSTA*cNumSpikes + STA*numSpikes) / (cNumSpikes + numSpikes);
    else
        warning('found NaNs in partial STA - did not update cumulative STA');
    end
    if ~any(isnan(STV(:)))
        cSTV=(cSTV*cNumSpikes + STV*numSpikes) / (cNumSpikes + numSpikes);
    else
        warning('found NaNs in partial STV - did not update cumulative STV');
    end
    cNumSpikes=cNumSpikes + numSpikes;
    cTrialNumbers=[cTrialNumbers trialNumbers];
    cChunkIDs=[cChunkIDs chunkID];
end

end % end MAIN function
