function displayCumulativePhysAnalysis(sm,cumulativeData,plotsRequested)
% called by analysis manager when overwrite spikes is false, and analsis
% has generates a cumulative data for this range.  allows for display,
% without recomputation

%% 

c=cumulativeData; 

if 0 %
    %filter out some of them
    amp= calculateFeatures(c.spikeWaveforms,{'peakToValley'});
    which=amp<.4
    c.spikeWaveforms=c.spikeWaveforms(which,:) % remove the filtered..
    if length(c.spike.times)~=size(c.spikeWaveforms,1)
        error('need to track waveform identity, or better, only include the ones that are in c.spike')
    end
    f=fields(c.spike);
    for i=1:length(f)
        c.spike.(f{i})=c.spike.(f{i})(which)
    end
end
%%

numConditions=length(c.conditionNames); 
numCycles=size(c.conditionPerCycle,1);
numTrialTypes=numCycles/numConditions; % whatever the group actually was acording to ths sm
numInstances=numCycles/numConditions; % these 2 terms are the same 
    
   for i=1:numConditions
        which=find(c.conditionPerCycle==i);
        %this is prob not needed, but it garauntees temporal order as a secondary sort
        [junk order]=sort(c.cycleOnset(which)); ... requires 
        which=which(order);
        nthOccurence(which)=1:length(which);  %nthOccurence of this condition in this list
   end
    displayHeight=nthOccurence(c.spike.cycle)+(c.spike.condition-1)*numInstances;
    

plotsRequested={'ratePerCondition','PSTH'};
%plotsRequested={'raster','viewSort'}; 
if ~exist('plotsRequested','var') || isempty(plotsRequested)
    plotsRequested=c.plotsRequested;
end
[h w]=size(plotsRequested);

%figure  controlled by code caller
set(gcf,'position',[10 40 1200 900])

viewSort=any(ismember(plotsRequested(:),'viewSort'));
if viewSort
    sub=find(strcmp(plotsRequested','viewSort'));
    subplot(h,w,sub)
    plot(c.spikeWaveforms([c.processedClusters]~=1,:)','color',[0.2 0.2 0.2]);  hold on
    plot(c.spikeWaveforms(find([c.processedClusters]==1),:)','r');
    waveLn=size(c.spikeWaveforms,2);
    set(gca,'xLim',[1 waveLn],'yTick',[])
    ylabel('volts'); xlabel('msec')
    centerGuess=24;
    waveLn*1000/c.samplingRate;
    preMs=centerGuess*1000/c.samplingRate;
    postMs=(waveLn-centerGuess)*1000/c.samplingRate;
    set(gca,'xTickLabel',[-preMs 0 postMs],'xTick',[1 centerGuess waveLn])
end

viewDrops=any(ismember(plotsRequested(:),'viewDrops'));
if viewDrops
    sub=find(strcmp(plotsRequested','viewDrops'));
    subplot(h,w,sub)
    dropFraction=conv(c.droppedFrames,ones(1,100));
    plot(c.dropFraction)
    ylabel(sprintf('drops: %d',sum(c.droppedFrames)))
end



photodiodeAlignment=any(ismember(plotsRequested(:),'photodiodeAlignment'));
if photodiodeAlignment
    sub=find(strcmp(plotsRequested','photodiodeAlignment'));
    subplot(h,w,sub)
    imagesc(c.photodiodeRaster);  colormap(gray);
end


meanPhotoTargetSpike=any(ismember(plotsRequested(:),'meanPhotoTargetSpike'));
if meanPhotoTargetSpike
    sub=find(strcmp(plotsRequested','meanPhotoTargetSpike'));
    subplot(h,w,sub);hold on;
    
    meanLuminanceSignal=mean(c.photodiodeRaster);
    meanLuminanceSignal=meanLuminanceSignal-min(meanLuminanceSignal);
    meanLuminanceSignal=meanLuminanceSignal/max(meanLuminanceSignal);
    PSTH=mean(c.rasterDensity);
    PSTH=PSTH/max(PSTH);
    plot(meanLuminanceSignal,'r');
    plot(PSTH,'g');
    %plot(mean(tOn2),'.k');
    legend('photo','PSTH','Location','NorthWest') %'target',
    set(gca,'ytick',[0 1],'xtick',xlim);
    xlabel('frame')
    title(sprintf('spikes: %d',sum(c.numSpikesAnalyzed)))
end

plotEyes=any(ismember(plotsRequested(:),'plotEyes'));
if plotEyes
    sub=find(strcmp(plotsRequested','plotEyes'));
    subplot(h,w,sub);hold on;
    
    if ~isempty(c.eyeSig)
        if length(unique(c.eyeSig(:,1)))>10 % if at least 10 x-positions
            regionBoundsXY=[1 .5]; % these are CRX-PY bounds of unknown degrees
            [within ellipses]=selectDenseEyeRegions(c.eyeSig,1,regionBoundsXY);
        else
            disp(sprintf('no good eyeData on trials [%s]',num2str(c.trialNumbers)))
            text(0.5,0.5,'bad eye data')
        end
    else
        text(0.5,0.5,'no eye data');
        set(gca,'xTick',[],'yTick',[])
    end
end



plotRasterDensity=any(ismember(plotsRequested(:),'rasterDensity'));
if plotRasterDensity
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
end


%%
%DELETEABLE
    %onsetFrame=diff([0; targetIsOn])>0;
    %onset=spikeRecord.correctedFrameTimes(onsetFrame,1); % the time that the target starts
    
    plotRaster=any(ismember(plotsRequested(:),'raster'));
    if plotRaster
        sub=find(strcmp(plotsRequested','raster'));
        subplot(h,w,sub); hold on;
        
        for i=1:numConditions
            which=c.spike.condition==i;
            plot(c.spike.relTimes(which),-displayHeight(which),'.','color',brighten(c.colors(i,:),-0.2))
        end
        
        yTickVal=-fliplr((numInstances/2)+[0:numConditions-1]*numInstances);
        set(gca,'YTickLabel',fliplr(c.conditionNames),'YTick',yTickVal);
        ylabel([c.swept]);
        
        xlabel('time (msec)');
        timeToTarget=c.targetOnOff(1)*c.ifi/2;
        xvals=[ -timeToTarget 0  (c.targetOnOff*c.ifi)-timeToTarget];
        set(gca,'XTickLabel',xvals*1000,'XTick',xvals);
        
        n=diff(ylim);
        plot(xvals([2 2]),0.5+[-n 0],'k')
        plot(xvals([3 3]),0.5+[-n 0],'k')
        
        axis([xvals([1 4]) 0.5+[-n 0]])
        set(gca,'TickLength',[0 0])
    end

%%
plotRatePerCondition=any(ismember(plotsRequested(:),'ratePerCondition'));
if plotRatePerCondition
    sub=find(strcmp(plotsRequested','ratePerCondition'));
    subplot(h,w,sub); hold on;
    dur=diff(c.targetOnOff)*c.ifi;
    numTrials=length(unique(c.spike.trial));
    numRepeats=max(c.spike.repetition);
    
    
    for i=1:numConditions
        which=(c.spike.condition==i & c.spike.relTimes>0 & c.spike.relTimes<dur);
        count(i)=sum(which);
        for r=1:numRepeats
            countPerRep(i,r)=sum(which & c.spike.repetition==r);

        end
    end
    meanRatePerCond=count/(dur*numInstances*numTrials);
    SEMRatePerCond=std(countPerRep/(dur*numInstances*numTrials/numRepeats),[],2)/sqrt(numRepeats);
    
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
    for i=1:numConditions
        errorbar(i,meanRatePerCond(i),SEMRatePerCond(i),'color',c.colors(i,:));
        plot(i,meanRatePerCond(i),'.','color',c.colors(i,:));
    end
    ylabel('<rate>_{on}');
    set(gca,'xLim',[0.5 numConditions+0.5]);
    yl=ylim;
    set(gca,'yLim',[0 yl(2)]);
    set(gca,'XTickLabel',c.conditionNames,'XTick',1:numConditions);
    
end

%% 
showPSTH=any(ismember(plotsRequested(:),'PSTH'));
if showPSTH
    sub=find(strcmp(plotsRequested','PSTH'));
    subplot(h,w,sub); hold on;
    numTrials=length(unique(c.spike.trial));
    for i=1:numConditions
        spTm=c.spike.relTimes(c.spike.condition==i);
        countPerTrial=sum(c.spike.condition==i)/numTrials;
        [fi,ti] = ksdensity(spTm,'width',.01);
        plot(ti*1000,fi*countPerTrial/c.targetOnOff(2),'color',c.colors(i,:));
        plot(spTm*1000,-i+0.5*(rand(1,length(spTm))-0.5),'.','color',brighten(c.colors(i,:),-0.9));
        histc(spTm,[])
    end
    xlabel('time (msec)');
    timeToTarget=c.targetOnOff(1)*c.ifi/2;
    xvals=1000*[ -timeToTarget 0  (c.targetOnOff*c.ifi)-timeToTarget];
    set(gca,'xLim',xvals([1 4]))
    set(gca,'XTickLabel',xvals,'XTick',xvals);
        
    ylabel('rate');
    yl=ylim;
    set(gca,'yLim',[-(numConditions+1) yl(2)])
    set(gca,'yTickLabel',[0 yl(2)],'yTick',[0 yl(2)]);
end


cleanUpFigure
drawnow
%%
