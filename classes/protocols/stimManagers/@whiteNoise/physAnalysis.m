function [analysisdata cumulativedata] = physAnalysis(stimManager,spikeRecord,stimulusDetails,plotParameters,parameters,cumulativedata,eyeData,LFPRecord)
% stimManager is the stimulus manager
% spikes is a logical vector of size (number of neural data samples), where 1 represents a spike happening
% correctedFrameIndices is an nx2 array of frame start and stop indices - [start stop], n = number of frames
% stimulusDetails are the stimDetails from calcStim (hopefully they contain all the information needed to reconstruct stimData)
% photoDiode - currently not used
% plotParameters - currently not used
% 4/17/09 - spikeRecord contains all the data from this ENTIRE trial, but we should only do analysis on the current chunk
% to prevent memory problems
if ~exist('LFPRecord','var')||isempty(LFPRecord)
    doLFPAnalysis = false;
else
    doLFPAnalysis = true;
end

try
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
    %spikeRecord.photoDiode=spikeRecord.photoDiode(which);  % HACK! we need this, right?
    spikeRecord.spikeDetails=spikeRecord.spikeDetails(which);
    
    if size(spikeRecord.correctedFrameIndices,1)==0 || size(spikeRecord.spikes,1)==0
        %if this chunk has either no spikes or no stim frames, then return the cumulative data as is
        analysisdata=[];
        cumulativedata=cumulativedata;
        warning(sprintf('skipping white noise analysis for trial %d chunk %d because there are %d stim frames and %d spikes',...
            parameters.trialNumber,spikeRecord.currentChunk,size(spikeRecord.correctedFrameIndices,1),size(spikeRecord.spikes,1)))
        return
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
    
    %CHOOSE CLUSTER
    allSpikes=spikeRecord.spikes; %all waveforms
    waveInds=allSpikes; % location of all waveforms
    if isstruct(spikeRecord.spikeDetails) && ismember({'processedClusters'},fields(spikeRecord.spikeDetails))
        if length([spikeRecord.spikeDetails.processedClusters])~=length(waveInds)
            length([spikeRecord.spikeDetails.processedClusters])
            length(waveInds)
            error('spikeDetails does not correspond to the spikeRecord''s spikes');
        end
        thisCluster=[spikeRecord.spikeDetails.processedClusters]==1;
    else
        thisCluster=logical(ones(size(waveInds)));
        %use all (photodiode uses this)
    end
    allSpikes(~thisCluster)=[]; % remove spikes that dont belong to thisCluster
    
    
    % xtra user paramss
    spatialSmoothingOn=true;
    doSTC=false;
    xtraPlot={'spaceTimeContext'}; % eyes, spaceTimeContext, montage
    
    % timeWindowMs
    timeWindowMsStim=[300 50]; % parameter [300 50]
    timeWindowMsLFP =[1000 1000]; 
    
    % refreshRate - try to retrieve from neuralRecord (passed from stim computer)
    if isfield(parameters, 'refreshRate')
        refreshRate = parameters.refreshRate;
    else
        error('dont use default refreshRate');
        refreshRate = 100;
    end
    
    % calculate the number of frames in the window for each spike
    timeWindowFramesStim=ceil(timeWindowMsStim*(refreshRate/1000));
    
    if spatialSmoothingOn
        filt=... a mini gaussian like fspecial('gaussian')
            [0.0113  0.0838  0.0113;
            0.0838  0.6193  0.0838;
            0.0113  0.0838  0.0113];
    end
    
    if (ischar(stimulusDetails.strategy) && strcmp(stimulusDetails.strategy,'expert')) || ...
            (exist('fieldsInLUT','var') && ismember('stimDetails.strategy',fieldsInLUT) && strcmp(LUTlookup(sessionLUT,stimulusDetails.strategy),'expert'))
        seeds=stimulusDetails.seedValues;
        spatialDim = stimulusDetails.spatialDim;
        
        if isfield(stimulusDetails,'distribution')
            switch stimulusDetails.distribution.type
                case 'gaussian'
                    std = stimulusDetails.distribution.std;
                    meanLuminance = stimulusDetails.distribution.meanLuminance;
                case 'binary'
                    p=stimulusDetails.distribution.probability;
                    hiLoDiff=(stimulusDetails.distribution.hiVal-stimulusDetails.distribution.lowVal);
                    std=hiLoDiff*p*(1-p);
                    meanLuminance=(p*stimulusDetails.distribution.hiVal)+((1-p)*stimulusDetails.distribution.lowVal);
            end
        else
            error('dont use old convention for whiteNoise');
            %old convention prior to april 17th, 2009
            %stimulusDetails.distribution.type='gaussian';
            %std = stimulusDetails.std;
            %meanLuminance = stimulusDetails.meanLuminance;
        end
    end
    height=stimulusDetails.height;
    width=stimulusDetails.width;
    
    
    % stimData is the entire movie shown for this trial
    % removed 1/26/09 and replaced with stimulusDetails
    % reconstruct stimData from stimulusDetails - stimManager specific method
    stimData=nan(spatialDim(2),spatialDim(1),length(stimFrames));
    for i=1:length(stimFrames)
        
        %recompute stim - note: all sha1ing would have to happen w/o whiteVal and round
        whiteVal=255;
        switch stimulusDetails.distribution.type
            case 'gaussian'
                % we only have enough seeds for a single repeat of whiteNoise; if numRepeats>1, need to modulo
                randn('state',seeds(mod(stimFrames(i)-1,length(seeds))+1));
                %randn('state',seeds(stimFrames(i)));
                stixels = round(whiteVal*(randn(spatialDim([2 1]))*std+meanLuminance));
                stixels(stixels>whiteVal)=whiteVal;
                stixels(stixels<0)=0;
            case 'binary'
                rand('state',seeds(mod(stimFrames(i)-1,length(seeds))+1));
                stixels = round(whiteVal* (stimulusDetails.distribution.lowVal+(double(rand(spatialDim([2 1]))<stimulusDetails.distribution.probability)*hiLoDiff)));
            otherwise
                error('never')
        end
        
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
    
    
    
    analysisdata=[];
    % figure out safe "piece" size based on spatialDim and timeWindowFramesStim
    % we only need to reduce the size of spikes
    maxSpikes=floor(10000000/(spatialDim(1)*spatialDim(2)*sum(timeWindowFramesStim))); % equiv to 100 spikes at 64x64 spatial dim, 36 frame window
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
            [px py crx cry eyeTime]=getPxyCRxy(eyeData);
            eyeSig=[crx-px cry-py];
            
            if length(unique(eyeSig(:,1)))>10 % if at least 10 x-positions
                
                regionBoundsXY=[.5 .5]; % these are CRX-PY bounds of unknown degrees
                minMaxFractionExcluded=0.05;
                [within ellipses]=selectDenseEyeRegions(eyeSig,1,regionBoundsXY,minMaxFractionExcluded);
                
                
                % currently only look at frames in which each sample was within bounds (conservative)
                %framesEyeSamples=unique(eyeData.eyeDataFrameInds);  % this is not every frame!
                framesSomeEyeWithin=unique(eyeData.eyeDataFrameInds(within));  % at least one sable within
                framesSomeEyeNotIn=unique(eyeData.eyeDataFrameInds(~within));  % at least one smple without
                framesAllEyeWithin=setdiff(framesSomeEyeWithin,framesSomeEyeNotIn);
                
                
                if 0 %remove when eye out of bound and view temporal selected data
                    warning('don''t know if eyeDataFrameInds are the correct values -  need to check frame drops, etc')
                    error('will this account for the chunked spike analysis?')
                    %stimFrameseyeData.eyeDataFrameInds)...?
                    %stimFrames(framesSomeEyeNotIn)...?
                    
                    figure
                    %plot(eyeTime, eyeSig(:,1),'k',eyeTime(within), eyeSig(within,1),'c.')
                    plot(eyeData.eyeDataFrameInds, eyeSig(:,1),'k',eyeData.eyeDataFrameInds(within), eyeSig(within,1),'c.')
                    hold on; plot(stimFrames,spikeCount,'r')
                    
                    spikeCount(framesSomeEyeNotIn)=0;  % need to know if these are stimFramesor Nth frame that occured...
                    plot(stimFrames,spikeCount,'c');
                end
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
        try
            meanValue=whiteVal*meanLuminance;
        catch ex
            keyboard
        end
        
        try
            triggers=meanValue(ones(size(stimData,1),size(stimData,2),sum(timeWindowFramesStim)+1,numSpikes)); % +1 is for the frame that is on the spike
        catch ex
            disp(['CAUGHT EX (in whiteNoise.physAnalysis):' getReport(ex)]);
            memory
            keyboard
        end
        for i=find(spikeCount>0) % for each index that has spikes
            %every frame with a spike count, gets included... it is multiplied by the number of spikes in that window
            framesBefore = timeWindowFramesStim(1);
            framesAfter = timeWindowFramesStim(2);
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
        
    end %loop over safe "pieces"
    
    
    % now get the spikeTriggeredLFPs
    try
        LFPs = zeros(length(spikes),ceil((sum(timeWindowMsLFP)/1000)*mean(LFPRecord.LFPSamplingRateHz)),size(LFPRecord.data,2));
    catch ex
        getReport(ex)
        memory
        keyboard
    end
        
    processedSpikeTimeStamps = spikeRecord.spikeTimestamps(thisCluster);
    unprocessedSpikeNum = [];
    for currSpikeNum = 1:length(spikes)
        currTimeStamp = processedSpikeTimeStamps(currSpikeNum);
        if ((currTimeStamp-(timeWindowMsLFP(1)/1000))<min(spikeRecord.spikeTimestamps))...
                ||((currTimeStamp+(timeWindowMsLFP(2)/1000))>max(spikeRecord.spikeTimestamps))
            % only process those LFP samples where you are guaranteed that
            % the neural signal exists in the LFPRecord for that chunk!
            unprocessedSpikeNum = [unprocessedSpikeNum currSpikeNum];
            
        else
            relevantLFPRecord = LFPRecord.data((LFPRecord.dataTimes>(currTimeStamp-(timeWindowMsLFP(1)/1000)))&...
                (LFPRecord.dataTimes<(currTimeStamp+(timeWindowMsLFP(2)/1000))),:);
            LFPs(currSpikeNum,:,:) = resample(relevantLFPRecord,ceil((sum(timeWindowMsLFP)/1000)*mean(LFPRecord.LFPSamplingRateHz)),...
                length(relevantLFPRecord));
        end
    end
    LFPs(unprocessedSpikeNum,:,:) = [];
    ST_LFPA = mean(LFPs,1);
    ST_LFPV = var(LFPs,0,1);
    numSpikesForLFP = size(LFPs,1);
        
    
    % now we should have our analysisdata for all "pieces"
    % if the cumulative values don't exist (first analysis)
    % 6/23/09 fli - why do we always do this first thing instead of checking for cumulative values???
    % sometimes empty... think about : isempty(cumulativedata) ||
    
    try
        x=isempty(cumulativedata) || ~isfield(cumulativedata, 'cumulativeSTA')  || ~all(size(analysisdata.STA)==size(cumulativedata.cumulativeSTA)) %first trial through with these parameters
    catch
        warning('here')
        keyboard
    end
        
    if  isempty(cumulativedata) || ~isfield(cumulativedata, 'cumulativeSTA')  || ~all(size(analysisdata.STA)==size(cumulativedata.cumulativeSTA)) %first trial through with these parameters
        cumulativedata=[];
        cumulativedata.cumulativeSTA = analysisdata.STA;
        cumulativedata.cumulativeSTV = analysisdata.STV;
        cumulativedata.cumulativeNumSpikes = analysisdata.numSpikes;
        cumulativedata.cumulativeTrialNumbers=parameters.trialNumber;
        cumulativedata.cumulativeChunkIDs=parameters.chunkID;
        cumulativedata.cumulativeST_LFPA = ST_LFPA;
        cumulativedata.cumulativeST_LFPV = ST_LFPV;
        cumulativedata.numSpikesForLFP = numSpikesForLFP;
        analysisdata.singleChunkTemporalRecord=[];
        addSingleTrial=true;
    elseif isempty(find(parameters.trialNumber==cumulativedata.cumulativeTrialNumbers&...
            parameters.chunkID==cumulativedata.cumulativeChunkIDs))
        %only for new trials or new chunks
        [cumulativedata.cumulativeSTA cumulativedata.cumulativeSTV cumulativedata.cumulativeNumSpikes ...
            cumulativedata.cumulativeTrialNumbers cumulativedata.cumulativeChunkIDs cumulativedata.cumulativeST_LFPA ...
            cumulativedata.cumulativeST_LFPV cumulativedata.numSpikesForLFP] = ...
            updateCumulative(cumulativedata.cumulativeSTA,cumulativedata.cumulativeSTV,cumulativedata.cumulativeNumSpikes,...
            cumulativedata.cumulativeTrialNumbers,cumulativedata.cumulativeChunkIDs,cumulativedata.cumulativeST_LFPA,...
            cumulativedata.cumulativeST_LFPV, cumulativedata.numSpikesForLFP,...
            analysisdata.STA,analysisdata.STV,analysisdata.numSpikes,...
            analysisdata.trialNumber,analysisdata.chunkID,ST_LFPA,...
            ST_LFPV,numSpikesForLFP);
        
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
    if plotParameters.showSpikeAnalysis
        figureName = [num2str(min(cumulativedata.cumulativeTrialNumbers)) '-' num2str(max(cumulativedata.cumulativeTrialNumbers))];
        figure(min(cumulativedata.cumulativeTrialNumbers));
        set(gcf,'Name',figureName); % trialBased is better
        set(gcf,'Units','pixels');
        set(gcf,'position',[100 100 800 700]);
    end
    % size(analysisdata.cumulativeSTA)
    
    
    % or use analysisdata.STA?
    doSpatial=~(size(STA,1)==1 & size(STA,2)==1); % if spatial dimentions exist
    
    % %% spatial signal (best via bright)
    if doSpatial
        
        contextInd=brightInd;
        
        %fit model to best spatial
        stdThresh=1;
        [STAenvelope STAparams] =fitGaussianEnvelopeToImage(cumulativedata.cumulativeSTA(:,:,contextInd(3)),stdThresh,false,false,false);
        cx=STAparams(2)*size(STAenvelope,2)+1;
        cy=STAparams(3)*size(STAenvelope,1)+1;
        stdx=size(STAenvelope,2)*STAparams(5);
        stdy=size(STAenvelope,1)*STAparams(5);
        e1 = fncmb(fncmb(rsmak('circle'),[stdx*1 0;0 stdy*1]),[cx;cy]);
        e2 = fncmb(fncmb(rsmak('circle'),[stdx*2 0;0 stdy*2]),[cx;cy]);
        e3 = fncmb(fncmb(rsmak('circle'),[stdx*3 0;0 stdy*3]),[cx;cy]);
        
        
        %get significant pixels and denoised spots
        switch stimulusDetails.distribution.type
            case 'gaussian'
                stdStimulus = std*whiteVal;
            case 'binary'
                stdStimulus = std*whiteVal*100; % somthing very large to prevent false positives... need to figure it out analytically.. maybe use different function
                %std=hiLoDiff*p*(1-p);
        end
        meanLuminanceStimulus = meanLuminance*whiteVal;
        [bigSpots sigPixels]=getSignificantSTASpots(cumulativedata.cumulativeSTA(:,:,contextInd(3)),cumulativedata.cumulativeNumSpikes,meanLuminanceStimulus,stdStimulus,ones(3),3,0.05);
        [bigIndY bigIndX]=find(bigSpots~=0);
        [sigIndY sigIndX]=find(sigPixels~=0);
        if plotParameters.showSpikeAnalysis
            subplot(2,2,1)
        end
        %     im=single(squeeze(analysisdata.cumulativeSTA(:,:,contextInd(3))));
        %    imagesc(squeeze(cumulativedata.cumulativeSTA(:,:,contextInd(3))),rng);
        im=single(squeeze(cumulativedata.cumulativeSTA(:,:,contextInd(3))));
        
        if spatialSmoothingOn
            im=imfilter(im,filt,'replicate','same');
        end
        if plotParameters.showSpikeAnalysis
            imagesc(im,rng);
            %colorbar; %colormap(blueToRed(meanLuminanceStimulus,rng));
            hold on; plot(brightInd(2), brightInd(1),'y+')
            hold on; plot(darkInd(2)  , darkInd(1),  'y-')
            hold on; plot(bigIndX     , bigIndY,     'y.')
            hold on; plot(sigIndX     , sigIndY,     'y.','markerSize',1)
            minTrial=min(cumulativedata.cumulativeTrialNumbers);
            maxTrial=max(cumulativedata.cumulativeTrialNumbers);
            xlabel(sprintf('cumulative (%d.%d --> %d.%d)',...
                minTrial,min(cumulativedata.cumulativeChunkIDs(find(cumulativedata.cumulativeTrialNumbers==minTrial))),...
                maxTrial,max(cumulativedata.cumulativeChunkIDs(find(cumulativedata.cumulativeTrialNumbers==maxTrial)))));
            fnplt(e1,1,'g'); fnplt(e2,1,'g'); fnplt(e3,1,'g'); % plot elipses
            
            
            subplot(2,2,2)
            
            %hold off; imagesc(squeeze(STA(:,:,contextInd(3))),[min(STA(:)) max(STA(:))]);
            hold off; imagesc(squeeze(analysisdata.STA(:,:,contextInd(3))),[min(analysisdata.STA(:)) max(analysisdata.STA(:))]);
            hold on; plot(brightInd(2), brightInd(1),'y+')
            hold on; plot(darkInd(2)  , darkInd(1),'y-')
            %colorbar;
            colormap(gray);
            %colormap(blueToRed(meanLuminanceStimulus,rng,true));
            
            fnplt(e1,1,'g'); fnplt(e2,1,'g'); fnplt(e3,1,'g'); % plot elipses
            
            xlabel(sprintf('this trial/chunk (%d-%d)',analysisdata.trialNumber,analysisdata.chunkID))
            
            subplot(2,2,3)
        end
    end
    
    timeMs=linspace(-timeWindowMsStim(1),timeWindowMsStim(2),size(analysisdata.STA,3));
    ns=length(timeMs);
    if plotParameters.showSpikeAnalysis
        hold off; plot(timeWindowFramesStim([1 1])+1, [0 whiteVal],'k');
        hold on;  plot([1 ns],meanLuminance([1 1])*whiteVal,'k')
        try
            plot([1:ns], analysisdata.singleChunkTemporalRecord, 'color',[.8 .8 1])
        catch
            keyboard
        end
        fh=fill([1:ns fliplr([1:ns])]',[darkCI(:,1); flipud(darkCI(:,2))],'b'); set(fh,'edgeAlpha',0,'faceAlpha',.5)
        fh=fill([1:ns fliplr([1:ns])]',[brightCI(:,1); flipud(brightCI(:,2))],'r'); set(fh,'edgeAlpha',0,'faceAlpha',.5)
        plot([1:ns], darkSignal(:)','b')
        plot([1:ns], brightSignal(:)','r')
        
        peakFrame=find(brightSignal==max(brightSignal(:)));
        timeInds=[1 peakFrame(end) timeWindowFramesStim(1)+1 size(analysisdata.STA,3)];
        set(gca,'XTickLabel',unique(timeMs(timeInds)),'XTick',unique(timeInds),'XLim',minmax(timeInds));
        set(gca,'YLim',[minmax([analysisdata.singleChunkTemporalRecord(:)' darkCI(:)' brightCI(:)'])+[-5 5]])
        ylabel('RGB(gunVal)')
        xlabel('msec')
    end
    if doSpatial
            subplot(2,2,4)
            
            switch xtraPlot{1}
                case 'montage'
                    % montage(reshape(cumulativedata.cumulativeSTA,[size(cumulativedata.STA,1) size(cumulativedata.STA,2) 1 size(cumulativedata.STA,3) ] ), 'DisplayRange',rng)
                    montage(reshape(cumulativedata.cumulativeSTA,[size(STA,1) size(STA,2) 1 size(STA,3) ] ),'DisplayRange',rng)
                    colormap(blueToRed(meanLuminanceStimulus,rng,true));
                    % %% spatial signal (all)
                    % for i=1:
                    % subplot(4,n,2*n+i)
                    % imagesc(STA(:,:,i),'range',[min(STA(:)) min(STA(:))]);
                    % end
                    
                    if max(parameters.trialNumber)==318
                        keyboard
                    end
                case 'eyes'
                    
                    figure(parameters.trialNumber)
                    if exist('ellipses','var')
                        plotEyeElipses(eyeSig,ellipses,within,true);
                    else
                        msg=sprintf('no good eyeData on trial %d\n will analyze all data',parameters.trialNumber)
                        text(.5,.5, msg)
                    end
                case 'spaceTimeContext'
                    %uses defaults on phys monitor may 2009, might not be up to
                    %date after changes in hardware
                    
                    %user controls these somehow... params?
                    eyeToMonitorMm=330;
                    contextSize=2;
                    pixelPad=0.1; %fractional pad 0-->0.5
                    
                    
                    %stimRect=[500 1000 800 1200]; %need to get this stuff!
                    stimRect=[0 0 stimulusDetails.width stimulusDetails.height]; %need to get this! now forcing full screen
                    stimRectFraction=stimRect./[stimulusDetails.width stimulusDetails.height stimulusDetails.width stimulusDetails.height];
                    [vRes hRes]=getAngularResolutionFromGeometry(size(STA,2),size(STA,1),eyeToMonitorMm,stimRectFraction);
                    contextResY=vRes(contextInd(1),contextInd(2));
                    contextResX=hRes(contextInd(1),contextInd(2));
                    
                    
                    contextOffset=-contextSize:1:contextSize;
                    n=length(contextOffset); % 2*c+1
                    contextIm=ones(n,n)*meanLuminanceStimulus;
                    selection=nan(n,n);
                    maxAmp=max(abs(meanLuminanceStimulus-rng))*2; %normalize to whatever lobe is larger: positive or negative
                    hold off; plot(0,0,'.')
                    hold on
                    for i=1:n
                        yInd=contextInd(1)+contextOffset(i);
                        for j=1:n
                            xInd=contextInd(2)+contextOffset(j);
                            if xInd>0 && xInd<=size(STA,2) && yInd>0 && yInd<=size(STA,1)
                                %make the image
                                selection(i,j)=sub2ind(size(STA),yInd,xInd,contextInd(3));
                                contextIm(i,j)=cumulativedata.cumulativeSTA(selection(i,j));
                                %get temporal signal
                                [stixSig stixCI stixtInd]=getTemporalSignal(cumulativedata.cumulativeSTA,cumulativedata.cumulativeSTV,cumulativedata.cumulativeNumSpikes,selection(i,j));
                                yVals{i,j}=((1-pixelPad*2)   *  (stixSig(:)-meanLuminanceStimulus)/maxAmp)  +  n-i+1; % pad, normalize, and then postion in grid
                                xVals{i,j}=linspace(j-.5+pixelPad,j+.5-pixelPad,length(stixSig(:)));
                                
                            end
                        end
                    end
                    
                    % plot the image
                    imagesc(flipud(contextIm),rng)
                    colormap(blueToRed(meanLuminanceStimulus,rng,true));
                    
                    %plot the temporal signal
                    for i=1:n
                        for j=1:n
                            if ~isnan(selection(i,j))
                                plot(xVals{i,j},yVals{i,j},'y')
                            end
                        end
                    end
                    
                    % we only take the degrees of the selected pixel.
                    %neighbors may differ by a few % depending how big they are,
                    %geometery, etc.
                    
                    
                    axis([.5 n+.5 .5 n+.5])
                    set(gca,'xTick',[]); set(gca,'yTick',[])
                    xlabel(sprintf('%2.1f deg/pix',contextResX));
                    ylabel(sprintf('%2.1f deg/pix',contextResY));
                    
                otherwise
                    error('bad xtra plot request')
            end
        
    end
    
    figure(min(cumulativedata.cumulativeTrialNumbers)+1000);
    set(gcf,'Name','LFP Analysis','NumberTitle','off');
%     ST_LFPTime = linspace(-1000,1000,length(cumulativedata.cumulativeST_LFPA));
%     plot(ST_LFPTime,cumulativedata.cumulativeST_LFPA,'LineWidth',2);
    imagesc([-1000 1000],[1 14,],squeeze(cumulativedata.cumulativeST_LFPA)');colorbar;
%     hold on;
%     plot(ST_LFPTime,cumulativedata.cumulativeST_LFPA+sqrt(cumulativedata.cumulativeST_LFPV));
%     plot(ST_LFPTime,cumulativedata.cumulativeST_LFPA-sqrt(cumulativedata.cumulativeST_LFPV));
%     hold off;
catch ex
    disp(['CAUGHT EX: ' getReport(ex)])
    %             break
    % 11/25/08 - restart dir loop if tried to load corrupt file
    rethrow(ex)
    keyboard
end
end
% drawnow




function [sig CI ind]=getTemporalSignal(STA,STV,numSpikes,selection)
switch class(selection)
    case 'char'
        switch selection
            case 'bright'
                [ind]=find(STA==max(STA(:)));  %shortcut for a relavent region
            case 'dark'
                [ind]=find(STA==min(STA(:)));
            otherwise
                selection
                error('bad selection')
        end
        
    case 'double'
        temp=cumprod(size(STA));
        if iswholenumber(selection) && all(size(selection)==1) && selection<=temp(end)
            ind=selection;
        else
            error('bad selection as a double, which should be an index into STA')
        end
    otherwise
        error('bad class for selection')
        
end

try
    %if numSpikes==0 || all(isnan(STA(:)))
    %    ind=1; %to prevent downstream errors, just make one up  THIS DOES
    %    NOT FULLY WORK... need to be smarter... prob no spikes this trial
    %end
    if  numSpikes==0 
        ind=1; %to prevent downstream errors, just make one up
    else
        ind=ind(1); %use the first one if there is a tie. (more common with low samples)
    end
catch
    keyboard
end

[X Y T]=ind2sub(size(STA),ind);
ind=[X Y T];
sig = STA(X,Y,:);
if nargout>1
    er95= sqrt(STV(X,Y,:)/numSpikes)*1.96; % b/c std error(=std/sqrt(N)) of mean * 1.96 = 95% confidence interval for gaussian, norminv(.975)
    CI=repmat(sig(:),1,2)+er95(:)*[-1 1];
end
end


function new=hasNewParameters(stimManager,analysisdata,stimulusDetails) %first trial through with these parameters
new=false;

%different size
if  ~all(size(analysisdata.STA)==size(analysisdata.cumulativeSTA))
    new=true;
end

%different distribution
if ~strcmp(analysisdata.distribution.type,stimulusDetails.distribution.type)
    new=true;
end

%different parameters - a pretty general check of the params
if ~new % only  check if they are the same distribution
    f=fields(stimulusDetails.distribution);
    numFields=length(f);
    %check all numverical parameters (note for future: won't work for uneven vector lengths or strings)
    for i=2:numFields; % skip type i=1
        if ~all(stimulusDetails.distribution.(f{i})==analysisdata.distribution.(f{i}))
            new=true;
        end
    end
end
end

function [cSTA cSTV cNumSpikes cTrialNumbers cChunkIDs cST_LFPA cST_LFPV cNumSpikesForLFP] = updateCumulative(cSTA,cSTV,...
    cNumSpikes,cTrialNumbers,cChunkIDs,cST_LFPA,cST_LFPV,cNumSpikesForLFP,STA,STV,numSpikes,trialNumbers,chunkID,ST_LFPA,...
    ST_LFPV,numSpikesForLFP)
% only update the cumulatives if the partials are NOT nan (arithmetic w/ nans wipes out any valid numbers)
if ~any(isnan(STA(:)))
    cSTA=(cSTA*cNumSpikes + STA*numSpikes) / (cNumSpikes + numSpikes);
else
    warning('found NaNs in partial STA - did not update cumulative STA')
end
if ~any(isnan(STV(:)))
    cSTV=(cSTV*cNumSpikes + STV*numSpikes) / (cNumSpikes + numSpikes);
else
    warning('found NaNs in partial STV - did not update cumulative STV');
end

if exist('cST_LFPA','var') % updateCumulative is also used for piece-wise data
    if ~any(isnan(ST_LFPA(:)))
        cST_LFPA=(cST_LFPA*cNumSpikesForLFP + ST_LFPA*numSpikesForLFP) / (cNumSpikesForLFP + numSpikesForLFP);
    else
        warning('found NaNs in partial cST_LFPA - did not update cumulative ST_LFPA')
    end
    if ~any(isnan(ST_LFPV(:)))
        cST_LFPV=(cST_LFPV*cNumSpikesForLFP + ST_LFPV*numSpikesForLFP) / (cNumSpikesForLFP + numSpikesForLFP);
    else
        warning('found NaNs in partial ST_LFPV - did not update cumulative ST_LFPV');
    end
    cNumSpikesForLFP = cNumSpikesForLFP + numSpikesForLFP;
else
    cST_LFPA = [];
    cST_LFPV = [];
    cNumSpikesForLFP = [];
end

cNumSpikes=cNumSpikes + numSpikes;
cTrialNumbers=[cTrialNumbers trialNumbers];
cChunkIDs=[cChunkIDs chunkID];
end


