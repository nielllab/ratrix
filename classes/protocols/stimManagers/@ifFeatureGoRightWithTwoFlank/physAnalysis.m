function [analysisdata cumulativedata] = physAnalysis(stimManager,spikeRecord,stimulusDetails,plotParameters,parameters,cumulativedata,eyeData,LFPRecord)
% stimManager is the stimulus manager
% spikes is a logical vector of size (number of neural data samples), where 1 represents a spike happening
% frameIndices is an nx2 array of frame start and stop indices - [start stop], n = number of frames
% stimulusDetails are the stimDetails from calcStim (hopefully they contain all the information needed to reconstruct stimData)
% photoDiode - currently not used
% plotParameters - currently not used



%plotsRequested=plotParameters.plotsRequested
plotsRequested={'viewSort','viewDrops','rasterDensity';
    'plotEyes','spikeAlignment','raster';
    'meanPhotoTargetSpike','PSTH','ratePerCondition'};

plotsRequested={'viewSort','ratePerCondition';
    'raster', 'PSTH'};

[h w]=size(plotsRequested);

plotParameters.position=[10 40 1200 900];
figure(parameters.trialNumber); % new for each trial
set(gcf,'position',plotParameters.position)


%% common - should put in util function for all physAnalysis



% %CHOOSE CLUSTER
% spikes=spikeRecord.spikes; %all waveforms
% waveInds=find(spikes); % location of all waveforms
% if isstruct(spikeData.spikeDetails) && ismember({'processedClusters'},fields(spikeData.spikeDetails))
%     thisCluster=spikeData.spikeDetails.processedClusters==1;
% else
%     thisCluster=logical(ones(size(waveInds)));
%     %use all (photodiode uses this)
% end
% spikes(waveInds(~thisCluster))=0; % set all the non-spike waveforms to be zero;
% %spikes(waveInds(spikeData.assig
%
% %SET UP RELATION stimInd <--> frameInd
% analyzeDrops=true;
% if analyzeDrops
%     stimFrames=spikeData.stimIndices;
%     frameIndices=spikeData.frameIndices;
% else
%     numStimFrames=max(spikeData.stimIndices);
%     stimFrames=1:numStimFrames;
%     firstFramePerStimInd=~[0 diff(spikeData.stimIndices)==0];
%     frameIndices=spikeData.frameIndices(firstFramePerStimInd);
% end

%SET UP RELATION stimInd <--> frameInd
analyzeDrops=true;
if analyzeDrops
    stimFrames=spikeRecord.stimInds;
    correctedFrameIndices=spikeRecord.correctedFrameIndices;
else
    numStimFrames=max(spikeRecord.stimInds);
    stimFrames=1:numStimFrames;
    firstFramePerStimInd=~[0; diff(spikeRecord.stimInds)==0];
    correctedFrameIndices=spikeRecord.correctedFrameIndices(firstFramePerStimInd);
end

% SET stimulus and get basic features per frame 
s=setStimFromDetails(stimManager, stimulusDetails);
[targetIsOn flankerIsOn effectiveFrame cycleNum sweptID repetition]=isTargetFlankerOn(s,stimFrames);


%CHOOSE CLUSTER
allSpikes=spikeRecord.spikes; %all waveforms
waveInds=allSpikes; % location of all waveforms
if isstruct(spikeRecord.spikeDetails) && ismember({'processedClusters'},fields(spikeRecord.spikeDetails))
    try
        if  length([spikeRecord.spikeDetails.processedClusters])~=length(waveInds)
            length([spikeRecord.spikeDetails.processedClusters])
            length(waveInds)
            error('spikeDetails does not correspond to the spikeRecord''s spikes');
        end
    catch ex
        warning('oops')
        keyboard
        getReport(ex)
    end
    thisCluster=[spikeRecord.spikeDetails.processedClusters]==1;
else
    thisCluster=logical(ones(size(waveInds)));
    %use all (photodiode uses this)
end


%old way is empirically
%samplingRate=round(diff(minmax(find(spikeData.spikes)'))/ diff(spikeData.spikeTimestamps([1 end])));
samplingRate=parameters.samplingRate;

ifi=1/stimulusDetails.hz;      %in old mode used to be same as empiric (diff(spikeData.frameIndices'))/samplingRate;
ifi2=1/parameters.refreshRate; %parameters.refreshRate might be wrong, so check it
if (abs(ifi-ifi2)/ifi)>0.01  % 1 percent error tolerated
    ifi
    ifi2
    er=(abs(ifi-ifi2)/ifi)
    error('refresh rate doesn''t agree!')
end

spikes=allSpikes;
spikes(~thisCluster)=[]; % remove spikes that dont belong to thisCluster

% count the number of spikes per frame
% spikeCount is a 1xn vector of (number of spikes per frame), where n = number of frames
spikeCount=zeros(1,size(correctedFrameIndices,1));
for i=1:length(spikeCount) % for each frame
    spikeCount(i)=length(find(spikes>=correctedFrameIndices(i,1)&spikes<=correctedFrameIndices(i,2)));
    %spikeCount(i)=sum(spikes(frameIndices(i,1):frameIndices(i,2)));  % inclusive?  policy: include start & stop
end

swept=s.dynamicSweep.sweptParameters;
if isfield(cumulativedata,'swept')  & strcmp([cumulativedata.swept{:}],[swept{:}])
    addToCumulativeData=true;
    
    cumulativedata.trialNumbers=[cumulativedata.trialNumbers parameters.trialNumber];
    cumulativedata.numFrames=[cumulativedata.numFrames length(stimFrames)]; 
    if  any(cumulativedata.targetOnOff~=double(s.targetOnOff))
       error('not allowed to change targetOnOff between trials') 
    end
else %reset
    %initialize if trial is new type, or enforce blank if starting fresh
    addToCumulativeData=false;
    
    cumulativedata=[]; %wipe out whatever data we get
    cumulativedata.trialNumbers=parameters.trialNumber;
    cumulativedata.numFrames=length(stimFrames);
    cumulativedata.plotsRequested=plotsRequested;
    cumulativedata.targetOnOff=double(s.targetOnOff);
    cumulativedata.ifi=ifi;
end
analysisdata=[]; % per chunk is not used ever yet.. only cumulatuve saves
    
    
viewSort=any(ismember(plotsRequested(:),'viewSort'));
if viewSort
    figure(parameters.trialNumber);
    sub=find(strcmp(plotsRequested','viewSort'));
    subplot(h,w,sub)
    plot(spikeRecord.spikeWaveforms([spikeRecord.spikeDetails.processedClusters]~=1,:)','color',[0.2 0.2 0.2]);  hold on
    plot(spikeRecord.spikeWaveforms(find([spikeRecord.spikeDetails.processedClusters]==1),:)','r');
    waveLn=size(spikeRecord.spikeWaveforms,2);
    set(gca,'xLim',[1 waveLn],'yTick',[])
    ylabel('volts'); xlabel('msec')
    centerGuess=24;
    waveLn*1000/samplingRate;
    preMs=centerGuess*1000/samplingRate;
    postMs=(waveLn-centerGuess)*1000/samplingRate;
    set(gca,'xTickLabel',[-preMs 0 postMs],'xTick',[1 centerGuess waveLn])
end

%for now we always add the waveforms, but (for memory) could restrict to cases where viewSort = true
if addToCumulativeData
    cumulativedata.spikeWaveforms=[cumulativedata.spikeWaveforms; spikeRecord.spikeWaveforms];
    cumulativedata.processedClusters=[cumulativedata.processedClusters [spikeRecord.spikeDetails.processedClusters]];
    if samplingRate~=cumulativedata.samplingRate;
        error('switched sampling rate across these trials')
    end
else %reset
    cumulativedata.swept=swept;
    cumulativedata.spikeWaveforms=spikeRecord.spikeWaveforms;
    cumulativedata.processedClusters=[spikeRecord.spikeDetails.processedClusters];
    cumulativedata.samplingRate=samplingRate;
end

viewDrops=any(ismember(plotsRequested(:),'viewDrops'));
if viewDrops
    figure(parameters.trialNumber);
    sub=find(strcmp(plotsRequested','viewDrops'));
    subplot(h,w,sub)
    droppedFrames=[diff(stimFrames)==0; 0];
    dropFraction=conv(droppedFrames,ones(1,100));
    plot(dropFraction)
    ylabel(sprintf('drops: %d',sum(diff(stimFrames)==0)))
    
    if addToCumulativeData
        cumulativedata.totalDrops=sum(droppedFrames); % this summary statistic is trust worthy
        cumulativedata.droppedFrames=[cumulativedata.droppedFrames; droppedFrames];  % this is a crude concatenation across trials; and find(drops) should not be trusted withouit serious checking of groud facts. 
    else %reset
        cumulativedata.totalDrops=sum(droppedFrames);
        cumulativedata.droppedFrames=droppedFrames;
    end
end

viewDropsAndCycles=sum(diff(stimFrames)==0)>0; % a side plot when drops exist
if viewDropsAndCycles
    figure
    dropFraction=conv([diff(stimFrames)==0; 0],ones(1,100));
    subplot(6,1,1); plot(effectiveFrame)
    subplot(6,1,2); plot(stimFrames)
    %subplot(6,1,3); plot(cycleNum)
    subplot(6,1,3); plot(dropFraction)
    ylabel(sprintf('drops: %d',sum(diff(stimFrames)==0)))
    subplot(6,1,4); plot(sweptID)
    subplot(6,1,5); plot(repetition)
    subplot(6,1,6); plot(targetIsOn)
end

%%

%assemble a vector struct per frame (like per trial)
d.date=correctedFrameIndices(:,1)'/(samplingRate*60*60*24); %define field just to avoid errors
for i=1:length(swept)
    switch swept{i}
        case {'targetContrast','flankerContrast'}
            d.(swept{i})=s.dynamicSweep.sweptValues(i,sweptID);
        case 'targetOrientations'
            d.targetOrientation=s.dynamicSweep.sweptValues(i,sweptID);
        case 'flankerOrientations'
            d.flankerOrientation=s.dynamicSweep.sweptValues(i,sweptID);
        case 'phase'
            d.targetPhase=s.dynamicSweep.sweptValues(i,sweptID);
            d.flankerPhase=d.targetPhase;
        otherwise
            d.(swept{i})= s.dynamicSweep.sweptValues(i,sweptID);
    end
end

%get the condition inds depending on what was swept
if any(strcmp(swept,'targetOrientations'))...
        && any(strcmp(swept,'flankerOrientations'))...
        && any(strcmp(swept,'flankerPosAngle'))...
        && any(strcmp(swept,'phase'))...
        && size(swept,2)==4;
    conditionType='colin+3';
    [conditionInds conditionNames haveData colors]=getFlankerConditionInds(d,[],conditionType);
    colors(2,:)=colors(3,:); % both pop-outs the same
    colors(4,:)=[.5 .5 .5]; % grey not black
    % elseif any(strcmp(swept,'targetContrast'))...
    %     && any(strcmp(swept,'flankerContrast'))...
    %     && size(swept,2)==2;
    %
    %     %flanker contrast only right now...
    %     [conditionInds conditionNames haveData colors]=getFlankerConditionInds(d,[],'fiveFlankerContrastsFullRange');
    
    %
elseif any(strcmp(swept,'targetOrientations'))...
        && any(strcmp(swept,'phase'))...
        && size(swept,2)==2;
    conditionType='allTargetOrientationAndPhase';
    [conditionInds conditionNames haveData colors]=getFlankerConditionInds(d,[],conditionType);
elseif any(strcmp(swept,'targetContrast'))...
        && any(strcmp(swept,'phase'))...
        && size(swept,2)==2;
    conditionType='allTargetContrastAndPhase';
    conditionType='allTargetContrasts';
    %conditionType='allPhases' %need both, i think
    [conditionInds conditionNames haveData colors]=getFlankerConditionInds(d,[],conditionType);
else
    
    %default to each unique
    conditionsInds=zeros(max(sweptID),length(stimFrames));
    allSweptIDs=unique(sweptID);
    for i=1:length(allSweptIDs)
        conditionInds(i,:)=sweptID==allSweptIDs(i);
        conditionNames{i}=num2str(i);
    end
    colors=jet(length(allSweptIDs));
end
cumulativedata.conditionNames=conditionNames;
cumulativedata.colors=colors;


numConditions=size(conditionInds,1); % regroup as flanker conditions
numTrialTypes=length(unique(sweptID)); % whatever the group actually was acording to ths sm
numRepeats=max(repetition);
numUniqueFrames=max(effectiveFrame);
frameDurs=(correctedFrameIndices(:,2)-correctedFrameIndices(:,1))'/samplingRate;
%% set the values into the conditions
f=fields(d);
f(ismember(f,'date'))=[];  % the date is not part of the condition
for i=1:numConditions
    for j=1:length(f)
        firstInstance=min(find(conditionInds(i,:)));
        value=d.(f{j})(firstInstance);
        if isempty(value)
            value=nan;
        end
        c.(f{j})(i)=value;
        
        if addToCumulativeData && value~=cumulativedata.conditionValues.(f{j})(i)
            cumulativedata.conditionValues
            f{j}
            cumulativedata.conditionValues.(f{j})(i)
            value
            error('these values must be the same to combine across trials')
        end
    end
end

if addToCumulativeData
    cumulativedata.conditionValues=c; % no need to add
    % b/c we confrimed they are the same
else %reset
    cumulativedata.conditionValues=c;
end


%% OLD
% 
% events=nan(numRepeats,numConditions,numUniqueFrames);
% possibleEvents=events;
% photodiode=events;
% rasterDensity=ones(numRepeats*numConditions,numUniqueFrames)*0.1;
% photodiodeRaster=rasterDensity;
% tOn2=rasterDensity;
% fprintf('%d repeats',numRepeats)
% for i=1:numRepeats
%     fprintf('.%d',i)
%     for j=1:numConditions
%         for k=1:numUniqueFrames
%             which=find(conditionInds(j,:)' & repetition==i & effectiveFrame==k);
%             events(i,j,k)=sum(spikeCount(which));
%             possibleEvents(i,j,k)=length(which);
%             %[i j k]
%             photodiode(i,j,k)=sum(spikeRecord.photoDiode(which))/sum(frameDurs(which));
%             %             if photodiode(i,j,k)==theNumber
%             %                 which
%             %             end
%             if isempty(which)
%                 [i j k]
%                 warning('should be at least 1!')
%             end
%             tOn(i,j,k)=mean(targetIsOn(which)>0.5);
%             %in last repeat density = 0, for parsing and avoiding misleading half data
%             if numRepeats~=i
%                 y=(j-1)*(numRepeats)+i;
%                 rasterDensity(y,k)=events(i,j,k)./possibleEvents(i,j,k);
%                 
%                 photodiodeRaster(y,k)=photodiode(i,j,k);
%                 tOn2(y,k)=tOn(i,j,k);
%                 %                 if ~(ismember(rasterDensity(y,k),[0 1 2 3 4]))
%                 %                     rasterDensity(y,k)
%                 %                     [i j k]
%                 %                     pos=possibleEvents(i,j,k)
%                 %                 end
%             end
%         end
%     end
% end


%% NEW
%sweptID
%cycleNum

events=nan(numRepeats,numTrialTypes,numUniqueFrames);
possibleEvents=events;
photodiode=events;
rasterDensity=ones(numRepeats*numTrialTypes,numUniqueFrames)*0.1;
photodiodeRaster=rasterDensity;
tOn2=rasterDensity;
fprintf('%d repeats',numRepeats)
for i=1:numRepeats
    fprintf('.%d',i)
    for j=1:numTrialTypes
        for k=1:numUniqueFrames
            which=find(sweptID==j & repetition==i & effectiveFrame==k);
            events(i,j,k)=sum(spikeCount(which));
            possibleEvents(i,j,k)=length(which);
            
            photodiode(i,j,k)=sum(spikeRecord.photoDiode(which))/sum(frameDurs(which));
            if isempty(which)
                error(sprintf('count should be at least 1!, [i j k] = [%d %d %d]',i,j,k))
            end
            %tOn(i,j,k)=mean(targetIsOn(which)>0.5); where is should be on
            %in last repeat density = 0, for parsing and avoiding misleading half data
            if numRepeats~=i
                y=(j-1)*(numRepeats)+i;
                rasterDensity(y,k)=events(i,j,k)./possibleEvents(i,j,k);
                photodiodeRaster(y,k)=photodiode(i,j,k);
                %tOn2(y,k)=tOn(i,j,k); where is should be on
            end
        end
    end
end


%%

rasterDensity(isnan(rasterDensity))=0;
photodiodeRaster(photodiodeRaster==0.1)=mean(photodiodeRaster(:)); photodiodeRaster(1)=mean(photodiodeRaster(:));  % a known problem from drops

photodiodeAlignment=any(ismember(plotsRequested(:),'photodiodeAlignment'));
if photodiodeAlignment
    figure(parameters.trialNumber);
    sub=find(strcmp(plotsRequested','photodiodeAlignment'));
    subplot(h,w,sub)
    imagesc(photodiodeRaster);  colormap(gray);
    %imagesc(tOn2); where is should be on
    %imagesc(targetIsOnMatrix);
end


%NOT USING THIS ANYMORE ... use 'rasterDensity' to plotRasterDensity ...
%that will work with the cumulative display, this won't
%
% spikeAlignment=any(ismember(plotsRequested(:),'spikeAlignment'));
% if spikeAlignment
%     figure(parameters.trialNumber);
%     sub=find(strcmp(plotsRequested','spikeAlignment'));
%     subplot(h,w,sub);hold on;
%     imagesc(rasterDensity);  colormap(gray);
%     xlabel(sprintf('spikes: %d',sum(spikeCount)))
%     set(gca,'xLim',[1 numUniqueFrames]-0.5,'yLim',[1 120]+0.5)
% end

meanPhotoTargetSpike=any(ismember(plotsRequested(:),'meanPhotoTargetSpike'));
if meanPhotoTargetSpike
    figure(parameters.trialNumber);
    sub=find(strcmp(plotsRequested','meanPhotoTargetSpike'));
    subplot(h,w,sub);hold on;
    
    meanLuminanceSignal=mean(photodiodeRaster);
    meanLuminanceSignal=meanLuminanceSignal-min(meanLuminanceSignal);
    meanLuminanceSignal=meanLuminanceSignal/max(meanLuminanceSignal);
    PSTH=mean(rasterDensity);
    PSTH=PSTH/max(PSTH);
    plot(meanLuminanceSignal,'r');
    plot(mean(tOn2),'.k');
    plot(PSTH,'g');
    legend('photo','target','PSTH','Location','NorthWest')
    set(gca,'ytick',[0 1],'xtick',xlim);
    xlabel('frame')
    title(sprintf('spikes: %d',sum(spikeCount)))
end

if  ( photodiodeAlignment || meanPhotoTargetSpike)
    if addToCumulativeData
        cumulativedata.photodiodeRaster=[cumulativedata.photodiodeRaster; photodiodeRaster];
    else %reset
        cumulativedata.photodiodeRaster=photodiodeRaster;
    end
end
    
plotEyes=any(ismember(plotsRequested(:),'plotEyes'));
if plotEyes
    figure(parameters.trialNumber);
    sub=find(strcmp(plotsRequested','plotEyes'));
    subplot(h,w,sub);hold on;
    
    if ~isempty(eyeData)
        [px py crx cry]=getPxyCRxy(eyeData);
        eyeSig=[crx-px cry-py];
        eyeSig(end,:)=[]; % remove last ones to match (not principled... what if we should throw out the first ones?)
        
        if length(unique(eyeSig(:,1)))>10 % if at least 10 x-positions
            regionBoundsXY=[1 .5]; % these are CRX-PY bounds of unknown degrees
            [within ellipses]=selectDenseEyeRegions(eyeSig,1,regionBoundsXY);
        else
            disp(sprintf('no good eyeData on trial %d',parameters.trialNumber))
            text(0.5,0.5,'bad eye data')
        end
    else
        text(0.5,0.5,'no eye data');
        set(gca,'xTick',[],'yTick',[])
    end
    
    if addToCumulativeData 
        cumulativedata.eyeSig=[cumulativedata.eyeSig; eyeSig];
    else %reset
        cumulativedata.eyeSig=eyeSig;
    end
end
%%
fullRate=events./(possibleEvents*ifi);
fullPhotodiode=photodiode(2:end,:,:);
rate=reshape(sum(events)./(sum(possibleEvents)*ifi),numTrialTypes,numUniqueFrames); % combine repetitions

if numRepeats>2
    rateSEM=reshape(std(events(1:end-1,:,:)./(possibleEvents(1:end-1,:,:)*ifi)),numTrialTypes,numUniqueFrames)/sqrt(numRepeats-1);
    photodiodeSEM=reshape(std(photodiode(1:end-1,:,:)),numTrialTypes,numUniqueFrames)/sqrt(numRepeats-1);
else
    rateSEM=nan(size(rate));
    photodiodeSEM=nan(size(rate));
end

noStimDur=min([s.targetOnOff s.flankerOnOff]);
shift=floor(noStimDur/2);
shiftedFrameOrder=[(1+shift):numUniqueFrames  1:shift];

%%
photodiode=reshape(mean(photodiode(2:end,:,:),1),numTrialTypes,numUniqueFrames); % combine repetitions
%%
%reshapeRate but half the means screen in front and half behind
% maybe do this b4 on all of them
rate=rate(:,shiftedFrameOrder);
rateSEM=rateSEM(:,shiftedFrameOrder);
rasterDensity=rasterDensity(:,shiftedFrameOrder);
fullPhotodiode=fullPhotodiode(:,:,shiftedFrameOrder);
photodiode=photodiode(:,shiftedFrameOrder);
photodiodeSEM=photodiodeSEM(:,shiftedFrameOrder);



%%
plotRasterDensity=any(ismember(plotsRequested(:),'rasterDensity'));
if plotRasterDensity
    figure(parameters.trialNumber);
    sub=find(strcmp(plotsRequested','rasterDensity'));
    subplot(h,w,sub); hold on;
    imagesc(flipud(rasterDensity));  colormap(gray)
    yTickVal=(numRepeats/2)+[0:numConditions-1]*numRepeats;
    set(gca,'YTickLabel',fliplr(conditionNames),'YTick',yTickVal);
    ylabel([swept]);
    
    xlabel('time (msec)');
    set(gca,'XTickLabel',xvals,'XTick',xloc);
    
    
    plot(xloc([2 2]),[0.5 size(rasterDensity,1)+0.5],'g')
    plot(xloc([3 3]),[0.5 size(rasterDensity,1)+0.5],'g')
    
    axis([xloc([1 4]) 0.5+[0 size(rasterDensity,1)]])
    set(gca,'TickLength',[0 0])
    
    if addToCumulativeData
        cumulativedata.rasterDensity=[cumulativedata.rasterDensity; rasterDensity];
    else %reset
        cumulativedata.rasterDensity=rasterDensity;
    end
end


%%

try
    spike.times=spikeRecord.spikeTimestamps(thisCluster)';
    onsetFrame=diff([0; targetIsOn])>0;
    cycleOnset=spikeRecord.correctedFrameTimes(onsetFrame,1); % the time that the target starts

    %REMOVE SPIKES THAT ARE BEFORE THE FIRST STIM OF THE TRIAL BY MORE THAN ~ 200ms
    timeToTarget=double(s.targetOnOff(1))*ifi/2;
    tooEarly=spike.times<cycleOnset(1)-timeToTarget;
    spike.times(tooEarly)=[];
    
    %INIT AND SET PROPERTIES FOR EACH SPIKE
    spike.relTimes=zeros(size(spike.times));
    spike.frame=zeros(size(spike.times));
    spike.cycle=zeros(size(spike.times));
    spike.condition=zeros(size(spike.times));
    for i=1:length(spike.times)
        spike.cycle(i)=max(find(spike.times(i)>cycleOnset-timeToTarget)); % the stimulus cycle of each spike
        spike.frame(i)=max(find(spike.times(i)>spikeRecord.correctedFrameTimes(:,1))); % the frame of each spike
        spike.relTimes(i)=spike.times(i)-cycleOnset(spike.cycle(i)); % the relative time to the target onset of this cycle
        spike.condition(i)=find(conditionInds(:,spike.frame(i))); % what condition this spike occurred in
        spike.repetition(i)=repetition(spike.frame(i)); % what rep this spike occurred in
    end
    % save trial infor per spike b/c going to have info across many trials
    spike.trial=parameters.trialNumber(ones(1,length(spike.times)))
    
    % SKIPPED CHECK
    % % this check passes when timeToTarget is targetOnOff(1)*ifi, but we shift
    % % the display halfways to view the offset better, so expect this error
    % % check to fail if we turned it on
    % if any(cycleNum(spike.frame)~=spike.cycle)
    %     error('calculation of cycle of each spike differs between methods')
    % end
    
    %CALCULATE AND SAVE conditionPerCycle
    [conditionPerCycle junk]=find(conditionInds(:,onsetFrame));
    if addToCumulativeData
        cumulativedata.conditionPerCycle=[cumulativedata.conditionPerCycle conditionPerCycle];
    else %reset
        cumulativedata.conditionPerCycle=conditionPerCycle;
    end

    
    %CALCULATE DISPLAY HEIGHT
    for i=1:numConditions
        which=find(conditionPerCycle==i);
        %this is prob not needed, but it garauntees temporal order as a secondary sort
        [junk order]=sort(cycleOnset(which));
        which=which(order);
        nthOccurence(which)=1:length(which);  %nthOccurence of this condition in this list
    end
    instancesPerTrial=length(conditionPerCycle)/numConditions; % 24 in this test
    displayHeight=nthOccurence(spike.cycle)+(spike.condition-1)*instancesPerTrial;
    
    plotRaster=any(ismember(plotsRequested(:),'raster'));
    if plotRaster
        figure(parameters.trialNumber);
        sub=find(strcmp(plotsRequested','raster'));
        subplot(h,w,sub); hold on;
        
        for i=1:numConditions
            which=spike.condition==i;
            plot(spike.relTimes(which),-displayHeight(which),'.','color',brighten(colors(i,:),-0.2))
        end
        
        yTickVal=-fliplr((instancesPerTrial/2)+[0:numConditions-1]*instancesPerTrial);
        set(gca,'YTickLabel',fliplr(conditionNames),'YTick',yTickVal);
        ylabel([swept]);
        
        xlabel('time (msec)');
        xvals=[ -timeToTarget 0  (double(s.targetOnOff)*ifi)-timeToTarget];
        set(gca,'XTickLabel',xvals*1000,'XTick',xvals);
        
        n=length(cycleOnset);
        plot(xvals([2 2]),0.5+[-n 0],'k')
        plot(xvals([3 3]),0.5+[-n 0],'k')
        
        axis([xvals([1 4]) 0.5+[-n 0]])
        set(gca,'TickLength',[0 0])
    end
catch ex
    warning('uh oh')
    keyboard
    rethrow(ex)
end




%%
plotRatePerCondition=any(ismember(plotsRequested(:),'ratePerCondition'));
if plotRatePerCondition && 0 % skip it here run as cumulative
    figure(parameters.trialNumber);
    sub=find(strcmp(plotsRequested','ratePerCondition'));
    subplot(h,w,sub); hold on;
    dur=double(diff(s.targetOnOff))*ifi;
    
    try
        for i=1:numConditions
            %which=(c.spike.condition==i & c.spike.relTimes>0 &
            %c.spike.relTimes<dur);  %WHA?
            which=(spike.condition==i & spike.relTimes>0 & spike.relTimes<dur);
            count(i)=sum(which);
            for r=1:numRepeats
                %countPerRep(i,r)=sum(which & c.spike.repetition==r); %WHA?
                countPerRep(i,r)=sum(which & spike.repetition==r);
                
            end
        end
        meanRatePerCond=count/(dur*numInstances*numTrials);
        SEMRatePerCond=std(countPerRep)*0;%/(dur*numInstances*numTrials/numRepeats),[],2)/sqrt(numRepeats);
    catch ex
        getReport(ex)
        warning('oops')
        keyboard
    end
    
    warning('add in repeat per trial')
    which=(c.spike.relTimes<0 | c.spike.relTimes>dur);
    for r=1:numRepeats
        baseline(r)=sum(which & c.spike.repetition==r);
    end
    baselineRate=baseline./(c.targetOnOff(2)*c.ifi*numInstances*numTrials);
    meanBaseLine=mean(baselineRate);
    stdBaseLine=std(baselineRate)/sqrt(numRepeats);
    minmaxBaseLine=[min(baselineRate) max(baselineRate)];
    
    fill([0 0 numConditions([1 1])+1 ],minmaxBaseLine([2 1 1 2]),'m','FaceColor',[.9 .9 .9],'EdgeAlpha',0)
    fill([0 0 numConditions([1 1])+1 ],meanBaseLine+stdBaseLine*[1 -1 -1 1],'m','FaceColor',[.8 .8 .8],'EdgeAlpha',0)
    %OLD METHOD PROBABLY WRONG NOW
%     %meanPerRepetition?  divide by dur vs. divide by repetitions...  
%     %meanRateDuringPeriod=sum(fullRate(:,:,relevantRange)/dur,3);
%     meanRateDuringPeriod=mean(fullRate(:,:,relevantRange),3);
%     if isnan(meanRateDuringPeriod(end))  %iF nan REPLACE THE LAST VALUE WITH THE AVERAGE ABOVE IT
%         meanRateDuringPeriod(end)=mean(meanRateDuringPeriod(1:end-1,end));
%     end
    %meanRatePerCond=mean(meanRateDuringPeriod,1); % 2 vs 3 check!
    %SEMRatePerCond=std(meanRateDuringPeriod,[],1)/sqrt(numRepeats);
    %stdRatePerCond=std(meanRateDuringPeriod,[],1);
    
    for i=1:numConditions
        errorbar(i,meanRatePerCond(i),SEMRatePerCond(i),'color',colors(i,:));
        plot(i,meanRatePerCond(i),'.','color',colors(i,:));
    end
    ylabel('<rate>_{on}');
    set(gca,'xLim',[0 numConditions+1]);
    set(gca,'XTickLabel',conditionNames,'XTick',1:numConditions);
end

%% 
showPSTH=any(ismember(plotsRequested(:),'PSTH'));
if showPSTH
    figure(parameters.trialNumber);
    sub=find(strcmp(plotsRequested','PSTH'));
    subplot(h,w,sub); hold on;

    x=[1:numUniqueFrames];
    for i=1:numConditions
        
        spTm=spike.relTimes(spike.condition==i);
        count=sum(spike.condition==i);
        try
            if count>0
        [fi,ti] = ksdensity(spTm,'width',.01);
            else
                fi=[0 0]
                ti=[.2 .4];
            end
        catch
           warning('oops')
           keyboard
        end
        plot(ti*1000,fi*count/double(s.targetOnOff(2)),'color',colors(i,:));
        plot(spTm*1000,-i+0.5*(rand(1,length(spTm))-0.5),'.','color',brighten(colors(i,:),-0.9));
        histc(spTm,[])

        %plot(x,rate(i,:),'color',colors(i,:))
        %plot([x; x]+(i*0.05),[rate(i,:); rate(i,:)]+(rateSEM(i,:)'*[-1 1])','color',colors(i,:))
        %plot(x,conv(rate(i,:),fspecial('gauss',[1 10],2),'same'),'color',colors(i,:))
    end
    xlabel('time (msec)');
    xvals=1000*[ -timeToTarget 0  (double(s.targetOnOff)*ifi)-timeToTarget];
    set(gca,'xLim',xvals([1 4]))
    set(gca,'XTickLabel',xvals,'XTick',xvals);
        
    ylabel('rate');
    yl=ylim;
    set(gca,'yLim',[-(numConditions+1) yl(2)])
    set(gca,'yTickLabel',[0 yl(2)],'yTick',[0 yl(2)]);
end

if (showPSTH || plotRatePerCondition )
    if addToCumulativeData  
        f=fields(spike);
        for i=1:length(f)
            cumulativedata.spike.(f{i})=[cumulativedata.spike.(f{i}) spike.(f{i})];
        end 
        cumulativedata.cycleOnset=[cumulativedata.cycleOnset; cycleOnset];
    else %reset
        cumulativedata.spike=spike;
        cumulativedata.cycleOnset=cycleOnset;
    end
end

if addToCumulativeData
    cumulativedata.numSpikesAnalyzed=[cumulativedata.numSpikesAnalyzed length(spike.times)];
else %reset
    cumulativedata.numSpikesAnalyzed=length(spike.times)% more accurate than sum(spikeCount) by a few spikes
end


%%
cleanUpFigure
drawnow
%%

%PHOTODIODE
%%
doPhotodiode=0;
if doPhotodiode
    %figure; hold on;
    switch conditionType
        case 'allTargetOrientationAndPhase'
            %%
            %close all
            
            %%
            subplot(1,2,1); hold on
            title(sprintf('grating %dppc',stimulusDetails.pixPerCycs(1)))
            
            ss=1+round(stimulusDetails.targetOnOff(1)/2);
            ee=ss+round(diff(stimulusDetails.targetOnOff))-1;
            or=unique(c.targetOrientation);
            if or(1)==0 && or(2)==pi/2
                l1='V';
                l2='H';
            elseif abs(or(1))==abs(or(2)) && or(1)<0 && or(2)>0
                l1=sprintf('%2.0f CW',180*or(2)/pi);
                l2='CCW';
            else
                l1='or1';
                l2='or2'
            end
            
            for i=1:length(or)
                which=find(c.targetOrientation==or(i));
                pho=photodiode(which,:)';
                [photoTime photoPhase ]=find(pho==max(pho(:)));
                phoSEM=photodiodeSEM(photoPhase,:);
                
                whichPlot='maxPhase'
                switch whichPlot
                    case 'maxPhase'
                        plot(1:numUniqueFrames,[pho(:,photoPhase) pho(:,photoPhase)],'.','color',colors(min(which),:));
                    case 'allRepsMaxPhase'
                        theseData=reshape(fullPhotodiode(:,which(photoPhase),:),size(fullPhotodiode,1),[]);
                        theFrames=repmat([1:numUniqueFrames],size(fullPhotodiode,1),1);
                        plot(theFrames,theseData,'.','color',colors(min(which),:))
                end
                
                h(i)=plot(pho(:,photoPhase),'color',colors(min(which),:));
                %plot([1:length(pho); 1:length(pho)],[pho(:,photoPhase) pho(:,photoPhase)]'+(phoSEM'*[-1 1])','color',colors(min(find(which)),:))
            end
            xlabel('frame #')
            ylabel('sum(volts)')
            legend(h,{l1,l2})
            %set(gca,'xlim',[0 size(pho,1)*2],'ylim',[7 11])
            
            subplot(1,2,2); hold on
            for i=1:length(or)
                which=find(c.targetOrientation==or(i));
                pha=c.targetPhase(which);
                pho=photodiode(which,:)';
                [photoTime photoPhase ]=find(pho==max(pho(:)));
                
                options=optimset('TolFun',10^-14,'TolX',10^-14);
                lb=[0 0 -pi*2]; ub=[6000 4000 2*pi]; % lb=[]; ub=[];
                
                
                p=linspace(0,4*pi,100);
                
                whichPlot='allRepsOneTime';
                switch whichPlot
                    
                    case 'maxTime'
                        params = lsqcurvefit(@(x,xdata) x(1)+x(2)*sin(xdata+x(3)),[1000 100 1],pha,pho(photoTime,:),lb,ub,options); params(3)=mod(params(3),2*pi);
                        plot([pha pha+2*pi]+params(3),[pho(photoTime,:) pho(photoTime,:)],'.','color',colors(min(which),:));
                        
                        %plot([pha pha+2*pi]+params(3),[pho pho],'.','color',colors(min(find(which)),:));
                    case 'allRepsOneTime'
                        params = lsqcurvefit(@(x,xdata) x(1)+x(2)*sin(xdata+x(3)),[1000 100 1],pha,pho(photoTime,:),lb,ub,options); params(3)=mod(params(3),2*pi);
                        theseData=reshape(fullPhotodiode(:,which,photoTime),size(fullPhotodiode,1),[]);
                        thePhases=repmat(pha+params(3),size(fullPhotodiode,1),1);
                        plot(thePhases,theseData,'.','color',colors(min(which),:))
                    case 'allRepsTimeAveraged'
                        
                    case  'timeAveragedRepAveraged'
                        meanPho=mean(pho);
                        validPho=~isnan(meanPho);
                        params = lsqcurvefit(@(x,xdata) x(1)+x(2)*sin(xdata+x(3)),[1000 100 1],pha(validPho),meanPho(validPho),lb,ub,options); params(3)=mod(params(3),2*pi);
                        plot([pha pha+2*pi]+params(3),[mean(pho) mean(pho)],'.','color',colors(min(which),:));
                    case  'stimOnTimeAveragedRepAveraged'
                        meanPho=mean(pho(ss:ee,:));
                        validPho=~isnan(meanPho);
                        params = lsqcurvefit(@(x,xdata) x(1)+x(2)*sin(xdata+x(3)),[1000 100 1],pha(validPho),meanPho(validPho),lb,ub,options); params(3)=mod(params(3),2*pi);
                        plot([pha pha+2*pi]+params(3),[meanPho meanPho],'.','color',colors(min(which),:));
                        
                end
                plot(p,params(1)+params(2)*sin(p),'-','color',colors(min(which),:))
                
                
                amp(i)=params(2);
                mn(i)=params(1);
            end
            meanFloor=min(photodiode(:));
            ratioDC=(mn(1)-meanFloor)/(mn(2)-meanFloor);
            string=sprintf('%s:%s = %2.3f mean  %2.3f amp',l1,l2,ratioDC,abs(amp(1)/amp(2)));
            title(string)
            xlabel('phase (\pi)')
            set(gca,'ytick',[ylim ],'yticklabel',[ylim ])
            set(gca,'xtick',[0 pi 2*pi 3*pi 4*pi],'xticklabel',[0 1 2 3 4],'xlim',[0 6*pi]);%,'ylim',[1525 1600])
            cleanUpFigure
        otherwise
            %% inspect distribution of photodiode output
            close all
            figure;
            subplot(2,2,1); hist(photodiode(:),100)
            xlabel ('luminance (volts)'); ylabel ('count')
            subplot(2,2,2); plot(diff(spikeRecord.correctedFrameTimes',1)*1000,spikeRecord.photoDiode,'.');
            xlabel('frame time (msec)'); ylabel ('luminance (volts)')
            subplot(2,2,3); plot(spikeRecord.spikeWaveforms(8,:)')
            

            %%
            
            subplot(1,2,1); hold on
            for i=1:numConditions
                plot(x,photodiode(i,:),'color',colors(i,:));
                plot([x; x]+(i*0.05),[photodiode(i,:); photodiode(i,:)]+(photodiodeSEM(i,:)'*[-1 1])','color',colors(i,:))
            end
            xlabel('time (msec)');
            set(gca,'XTickLabel',xvals,'XTick',xloc);
            ylabel('sum volts (has errorbars)');
            set(gca,'Xlim',[1 numUniqueFrames])
            
            %rate density over phase... doubles as a legend
            subplot(1,2,2); hold on
            im=zeros([size(rasterDensity) 3]);
            hues=rgb2hsv(colors);  % get colors to match jet
            hues=repmat(hues(:,1)',numRepeats,1); % for each rep
            hues=repmat(hues(:),1,numUniqueFrames);  % for each phase bin
            grey=repmat(all((colors==repmat(colors(:,1),1,3))'),numRepeats,1); % match grey vals to hues
            im(:,:,1)=hues; % hue
            im(grey(:)~=1,:,2)=0.6; % saturation
            im(:,:,3)=rasterDensity/max(rasterDensity(:)); % value
            rgbIm=hsv2rgb(im);
            image(rgbIm);
            axis([0 size(im,2) 0 size(im,1)]+.5);
            set(gca,'YTickLabel',conditionNames,'YTick',size(im,1)*([1:length(conditionNames)]-.5)/length(conditionNames))
            xlabel('time');
            %set(gca,'XTickLabel',{'0','pi','2pi'},'XTick',([0 .5  1]*numPhaseBins)+.5);
            
    end
end

