function [analysisdata cumulativedata] = physAnalysis(stimManager,spikeRecord,stimulusDetails,plotParameters,parameters,cumulativedata,eyeData)
% stimManager is the stimulus manager
% spikes is a logical vector of size (number of neural data samples), where 1 represents a spike happening
% frameIndices is an nx2 array of frame start and stop indices - [start stop], n = number of frames
% stimulusDetails are the stimDetails from calcStim (hopefully they contain all the information needed to reconstruct stimData)
% photoDiode - currently not used
% plotParameters - currently not used



%% common - should put in util function for all physAnalysis
analysisdata=[]; %nothing passed out
cumulativedata=[]; % not used yet, wipe out whatever data we get

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
    firstFramePerStimInd=~[0 diff(spikeRecord.stimInds)==0];
    correctedFrameIndices=spikeRecord.correctedFrameIndices(firstFramePerStimInd);
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

s=setStimFromDetails(stimManager, stimulusDetails);
[targetIsOn flankerIsOn effectiveFrame cycleNum sweptID repetition]=isTargetFlankerOn(s,stimFrames);

%old way is empirically
%samplingRate=round(diff(minmax(find(spikeData.spikes)'))/ diff(spikeData.spikeTimestamps([1 end])));
samplingRate=parameters.samplingRate;

ifi=1/stimulusDetails.hz;      %in old mode used to be same as empiric (diff(spikeData.frameIndices'))/samplingRate;
ifi2=1/parameters.refreshRate; %parameters.refreshRate might be wrong, so check it
if ifi~=ifi2
    ifi
    ifi2
    error('refresh rate doesn''t agree!')
end


% count the number of spikes per frame
% spikeCount is a 1xn vector of (number of spikes per frame), where n = number of frames
spikeCount=zeros(1,size(correctedFrameIndices,1));
for i=1:length(spikeCount) % for each frame
    spikeCount(i)=length(find(spikes>=correctedFrameIndices(i,1)&spikes<=correctedFrameIndices(i,2)));
    %spikeCount(i)=sum(spikes(frameIndices(i,1):frameIndices(i,2)));  % inclusive?  policy: include start & stop
end


%%

swept=s.dynamicSweep.sweptParameters;
%assemble a vector struct per frame (like per trial)
d.date=correctedFrameIndices(:,1)'/(samplingRate*60*60*24); %define field just to avoid errors
for i=1:length(swept)
    switch swept{i}
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
        size(swept,2)==4; 
    [conditionInds conditionNames haveData colors]=getFlankerConditionInds(d,[],'colin+3');
    numUniqueTypes=size(conditionInds,1); % regroup as flanker conditions
    colors(2,:)=colors(3,:); % both pop-outs the same
    colors(4,:)=[.5 .5 .5]; % grey not black
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

numConditions=size(conditionInds,1); % regroup as flanker conditions
numRepeats=max(repetition);
numUniqueFrames=max(effectiveFrame);

events=nan(numRepeats,numConditions,numUniqueFrames);
possibleEvents=events;
rasterDensity=zeros(numRepeats*numConditions,numUniqueFrames);
for i=1:numRepeats
    for j=1:numConditions
        for k=1:numUniqueFrames
            which=find(conditionInds(j,:) & repetition==i & effectiveFrame==k);
            events(i,j,k)=sum(spikeCount(which));
            possibleEvents(i,j,k)=length(which);
            %photodiode(i,j,k)=sum(spikeData.photoDiode(which));
            %in last repeat density = 0, for parsing and avoiding misleading half data
            if numRepeats~=i
                y=(j-1)*(numRepeats)+i;
                rasterDensity(y,k)=events(i,j,k)/possibleEvents(i,j,k);
            end
        end
    end
end



% if ~isempty(eyeData)
%     [px py crx cry]=getPxyCRxy(eyeData);
%     eyeSig=[crx-px cry-py];
%     eyeSig(end,:)=[]; % remove last ones to match (not principled... what if we should throw out the first ones?)
%     
%     if length(unique(eyeSig(:,1)))>10 % if at least 10 x-positions   
%         regionBoundsXY=[1 .5]; % these are CRX-PY bounds of unknown degrees
%         [within ellipses]=selectDenseEyeRegions(eyeSig,1,regionBoundsXY);  
%     else
%         disp(sprintf('no good eyeData on trial %d',parameters.trialNumber))
%     end
% end

fullRate=events./(possibleEvents*ifi);
%fullPhotodiode=photodiode(2:end,:,:);
rate=reshape(sum(events)./(sum(possibleEvents)*ifi),numConditions,numUniqueFrames); % combine repetitions

if numRepeats>2
    rateSEM=reshape(std(events(1:end-1,:,:)./(possibleEvents(1:end-1,:,:)*ifi)),numConditions,numUniqueFrames)/sqrt(numRepeats-1);
    %photodiodeSEM=reshape(std(photodiode(1:end-1,:,:)),numConditions,numUniqueFrames)/sqrt(numRepeats-1);
else
    rateSEM=nan(size(rate));
    %photodiodeSEM=nan(size(rate));
end

%photodiode=reshape(sum(photodiode(2:end,:,:)),numConditions,numUniqueFrames); % combine repetitions

%reshapeRate but half the means screen in front and half behind
% maybe do this b4 on all of them
noStimDur=min([s.targetOnOff s.flankerOnOff]);
shift=floor(noStimDur/2);
rate=[rate(:,1+shift:end) rate(:,1:shift)];
rateSEM=[rateSEM(:,1+shift:end) rateSEM(:,1:shift)];
rasterDensity=[rasterDensity(:,1+shift:end) rasterDensity(:,1:shift)];
%photodiode=[photodiode(:,1+shift:end) photodiode(:,1:shift)];
%photodiodeSEM=[photodiodeSEM(:,1+shift:end) photodiodeSEM(:,1:shift)];

figure(parameters.trialNumber); % new for each trial
set(gcf,'position',[100 400 560 620])
subplot(2,2,1); hold on; %p=plot([1:numPhaseBins]-.5,rate')
%plot([0 numUniqueFrames], [rate(1) rate(1)],'color',[1 1 1]); % to save tight axis chop
x=[1:numUniqueFrames]; 
for i=1:numConditions
    plot(x,rate(i,:),'color',colors(i,:))
    plot([x; x]+(i*0.05),[rate(i,:); rate(i,:)]+(rateSEM(i,:)'*[-1 1])','color',colors(i,:))
end
%plot(x,rate(maxPowerInd,:),'color',colors(maxPowerInd,:),'lineWidth',2);
xlabel('time (msec)'); 
xvals=round(double([-shift 0 diff(s.targetOnOff) numUniqueFrames-shift])*ifi*1000);
xloc=[0 shift shift+diff(s.targetOnOff) numUniqueFrames];
set(gca,'XTickLabel',xvals,'XTick',xloc); 
ylabel('rate'); 
%set(gca,'YTickLabel',[0:.1:1]*parameters.refreshRate,'YTick',[0:.1:1])
axis tight

%PHOTODIODE
% subplot(2,2,3); hold on; 
% for i=1:numConditions
%     plot(x,photodiode(i,:),'color',colors(i,:));
%     plot([x; x]+(i*0.05),[photodiode(i,:); photodiode(i,:)]+(photodiodeSEM(i,:)'*[-1 1])','color',colors(i,:))
% end
% xlabel('time (msec)'); 
% set(gca,'XTickLabel',xvals,'XTick',xloc); 
% ylabel('sum volts (has errorbars)'); 
% set(gca,'Xlim',[1 numUniqueFrames])

% %rate density over phase... doubles as a legend
% subplot(2,2,2); hold on
% im=zeros([size(rasterDensity) 3]);
% hues=rgb2hsv(colors);  % get colors to match jet
% hues=repmat(hues(:,1)',numRepeats,1); % for each rep
% hues=repmat(hues(:),1,numUniqueFrames);  % for each phase bin
% grey=repmat(all((colors==repmat(colors(:,1),1,3))'),numRepeats,1); % match grey vals to hues
% im(:,:,1)=hues; % hue
% im(grey(:)~=1,:,2)=0.6; % saturation
% im(:,:,3)=rasterDensity/max(rasterDensity(:)); % value
% rgbIm=hsv2rgb(im);
% image(rgbIm);
% axis([0 size(im,2) 0 size(im,1)]+.5);
% set(gca,'YTickLabel',conditionNames,'YTick',size(im,1)*([1:length(conditionNames)]-.5)/length(conditionNames))
% xlabel('time');  
% %set(gca,'XTickLabel',{'0','pi','2pi'},'XTick',([0 .5 1]*numPhaseBins)+.5);

subplot(2,2,2); %2,2,4
hold on
dur=double(diff(s.targetOnOff));
relevantRange=[numUniqueFrames-dur:numUniqueFrames];

meanRateDuringPeriod=sum(fullRate(:,:,relevantRange)/dur,3);
meanRatePerCond=mean(meanRateDuringPeriod,2); % 2 vs 3 check!
SEMRatePerCond=std(meanRateDuringPeriod,[],2)/sqrt(numRepeats);
stdRatePerCond=std(meanRateDuringPeriod,[],2);
for i=1:numConditions
    errorbar(i,meanRatePerCond(i),stdRatePerCond(i),'color',colors(i,:));
    plot(i,meanRatePerCond(i),'.','color',colors(i,:));
end
ylabel('<rate>_{on}'); 
set(gca,'xLim',[0 numConditions+1]);
set(gca,'XTickLabel',conditionNames,'XTick',1:numConditions); 


%%UGLY HACK REMOVED SOON
subplot(2,2,4); 
hold on
dur=double(diff(s.targetOnOff));
relevantRange=[numUniqueFrames-dur:numUniqueFrames];

meanRateDuringPeriod=sum(fullPhotodiode(:,:,relevantRange)/dur,3);
meanRatePerCond=mean(meanRateDuringPeriod,2); % 2 vs 3 check!
SEMRatePerCond=std(meanRateDuringPeriod,[],2)/sqrt(numRepeats);
stdRatePerCond=std(meanRateDuringPeriod,[],2);
for i=1:numConditions
    errorbar(i,meanRatePerCond(i),stdRatePerCond(i),'color',colors(i,:));
    plot(i,meanRatePerCond(i),'.','color',colors(i,:));
end
ylabel('sum volts_{on}'); 
set(gca,'xLim',[0 numConditions+1]);
set(gca,'yLim',[106 108]);
set(gca,'XTickLabel',conditionNames,'XTick',1:numConditions);

