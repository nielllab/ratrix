function displayCumulativePhysAnalysis(sm,cumulativedata,parameters)
% setup for plotting
sweptParameter = char(cumulativedata.stimInfo.sweptParameter);
numTypes = cumulativedata.stimInfo.numTypes;
vals = cumulativedata.stimInfo.(sweptParameter);
[junk order] = sort(vals,'ascend');
if strcmp(sweptParameter,'orientations')
    vals=rad2deg(vals);
end

if all(rem(vals,1)==0)
    format='%2.0f';
else
    format='%1.2f';
end
for i=1:length(vals);
    valNames{i}=num2str(vals(order(i)),format);
end;

colors=jet(numTypes);
figure(parameters.figHandle); % new for each trial
clf(parameters.figHandle);
set(gcf,'position',[100 300 560 620])
figName = sprintf('%s. %s. trialRange: %s',parameters.trodeName,parameters.stepName,mat2str(parameters.trialRange));
set(gcf,'Name',figName,'NumberTitle','off')

subplot(3,2,1); hold off; %p=plot([1:numPhaseBins]-.5,rate')
colordef white

numRepeats = cumulativedata.stimInfo.numRepeats;
numPhaseBins = cumulativedata.numPhaseBins;
rate = cumulativedata.rate(order,:);
rateSEM = cumulativedata.rateSEM(order,:);
pow = cumulativedata.pow(order);
coh = cumulativedata.coh(order);
cohLB = cumulativedata.cohLB(order);
temp = cumulativedata.phaseDensity;
for i = 1:numTypes
    phaseDensity((i-1)*numRepeats+1:i*numRepeats,:) = temp((order(i)-1)*numRepeats+1:order(i)*numRepeats,:);
end
powSEM = cumulativedata.powSEM(order);
cohSEM = cumulativedata.cohSEM(order);
eyeData = cumulativedata.eyeData;

plot([0 numPhaseBins], [rate(1) rate(1)],'color',[1 1 1]); hold on;% to save tight axis chop
x=[1:numPhaseBins]-.5;
for i=1:numTypes
    plot(x,rate(order(i),:),'color',colors(order(i),:))
    plot([x; x],[rate(order(i),:); rate(order(i),:)]+(rateSEM(order(i),:)'*[-1 1])','color',colors(order(i),:))
end
maxPowerInd=find(pow==max(pow));
if length(maxPowerInd)>1
    maxPowerInd = maxPowerInd(1);
end
if ~isempty(pow)
    plot(x,rate(maxPowerInd,:),'color',colors(maxPowerInd,:),'lineWidth',2);
end
xlabel('phase');  set(gca,'XTickLabel',{'0','pi','2pi'},'XTick',([0 .5 1]*numPhaseBins)); ylabel('rate'); set(gca,'YTickLabel',[0:.1:1]*cumulativedata.refreshRate,'YTick',[0:.1:1])
axis tight

%rate density over phase... doubles as a legend
subplot(3,2,2); hold off;
im=zeros([size(phaseDensity) 3]);
hues=rgb2hsv(colors);  % get colors to match jet
hues=repmat(hues(:,1)',numRepeats,1); % for each rep
hues=repmat(hues(:),1,numPhaseBins);  % for each phase bin
im(:,:,1)=hues; % hue
im(:,:,2)=1; % saturation
im(:,:,3)=phaseDensity/max(phaseDensity(:)); % value
rgbIm=hsv2rgb(im);
image(rgbIm); hold on
axis([0 size(im,2) 0 size(im,1)]+.5);
ylabel(sweptParameter); set(gca,'YTickLabel',valNames,'YTick',size(im,1)*([1:length(vals)]-.5)/length(vals))
xlabel('phase');  set(gca,'XTickLabel',{'0','pi','2pi'},'XTick',([0 .5 1]*numPhaseBins)+.5);

subplot(3,2,3); hold off; plot(mean(rate'),'k','lineWidth',2); hold on; %legend({'Fo'})
xlabel(sweptParameter); set(gca,'XTickLabel',valNames,'XTick',[1:length(vals)]); ylabel('rate (f0)'); set(gca,'YTickLabel',[0:.1:1]*cumulativedata.refreshRate,'YTick',[0:.1:1])
set(gca,'XLim',[1 length(vals)])


subplot(3,2,4); hold off
if ~isempty(pow)
    modulation=pow./(cumulativedata.refreshRate*mean(rate'));
    plot(pow,'k','lineWidth',1); hold on;
    plot(modulation,'--k','lineWidth',2); hold on;
    cohScaled=coh*max(pow); %1 is peak FR
    plot(cohScaled,'color',[.8 .8 .8],'lineWidth',1);
    sigs=find(cohLB>0);
    plot(sigs,cohScaled(sigs),'o','color',[.6 .6 .6]);
    legend({'f1','f1/f0','coh'})
    
    
    plot([1:length(vals); 1:length(vals)],[pow; pow]+(powSEM'*[-1 1])','k')
    %plot([1:length(vals); 1:length(vals)],[pow; pow]+(powSEM'*[-1 1])','k')
    plot([1:length(vals); 1:length(vals)]+0.1,[coh; coh]+(cohSEM'*[-1 1])','color',[.8 .8 .8])
    xlabel(sweptParameter); set(gca,'XTickLabel',valNames,'XTick',[1:length(vals)]); ylabel('modulation (f1/f0)');
    ylim=get(gca,'YLim'); yvals=[ ylim(1) mean(ylim) ylim(2)];set(gca,'YTickLabel',yvals,'YTick',yvals)
    set(gca,'XLim',[1 length(vals)])
else
    xlabel(sprintf('not enough data for all %s yet',sweptParameter))
end
meanRate=cumulativedata.spikeCount;
isi=diff(cumulativedata.spikeTimestamps)*1000;
N=sum(isi<cumulativedata.ISIviolationMS); percentN=100*N/length(isi);
ylim=get(gca,'YLim');

subplot(3,2,5);
numBins=40; maxTime=10; % ms
edges=linspace(0,maxTime,numBins); [count]=histc(isi,edges);
hold off; bar(edges,count,'histc'); axis([0 maxTime get(gca,'YLim')]);
hold on; plot(cumulativedata.ISIviolationMS([1 1]),get(gca,'YLim'),'k' )
xvalsName=[0 cumulativedata.ISIviolationMS maxTime]; xvals=xvalsName*cumulativedata.samplingRate/(1000*numBins);
set(gca,'XTickLabel',xvalsName,'XTick',xvals)
infoString=sprintf('viol: %2.2f%%\n(%d /%d)',percentN,N,length(isi))
text(xvals(3),max(count),infoString,'HorizontalAlignment','right','VerticalAlignment','top');
ylabel('count'); xlabel('isi (ms)')

subplot(3,2,6); hold off;
if ~isempty(eyeData)
    [px py crx cry]=getPxyCRxy(eyeData,10);
    eyeSig=[crx-px cry-py];
    eyeSig(end,:)=[]; % remove last ones to match (not principled... what if we should throw out the first ones?)
    plot(eyeSig(1,1),eyeSig(1,2),'.k');  hold on; % plot one dot to flush history
    if exist('ellipses','var')
        plotEyeElipses(eyeSig,ellipses,within,true)
    else
        text(.5,.5,'no good eye data')
    end
    xlabel('eye position (cr-p)')
else
    text(.5,.5,'no eye data')
end

% now plot the spikes
ax = axes('Position',[0.91 0.91 0.08 0.08]);

plot(cumulativedata.spikeWaveforms','r')
axis tight
set(ax,'XTick',[],'Ytick',[]);

end
