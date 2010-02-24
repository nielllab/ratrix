function [out ff slidingMs f]=fanoFactor(evtTimesSecs,repeatStartSecs,doPlot)
f=[];
test=false;
if test
    close all
    clc
    format long g
    doPlot=true;
    
    numTrials=100;
    trialDurSecs=30;
    firingRate=50;
    repeatStartSecs=trialDurSecs*(0:numTrials-1);
    
    numSpks=numTrials*trialDurSecs*firingRate;
    expSecs=numTrials*trialDurSecs;
    if false
        evtTimesSecs=sort(rand(1,numSpks)*expSecs); %poisson should give ff=1
    elseif false
        evtTimesSecs=linspace(0,expSecs,numSpks); %regular should give ff=0
    else
        evtTimesSecs=sort(cumsum(abs(.01+randn(1,numSpks)*.05))); %intermediate
        evtTimesSecs=evtTimesSecs-min(evtTimesSecs);
        evtTimesSecs=evtTimesSecs/max(evtTimesSecs)*expSecs;
    end
end

windowSizesMs=[10 50 100 250 500 1000 5000 10000 30000];
slidingMs=50;

if ~all(cellfun(@(x) isvector(x) && all(diff(x)>=0),{evtTimesSecs,repeatStartSecs}))
    error('must be sorted ascending vectors')
end

smallest=min(diff(repeatStartSecs));

windowSizesMs=windowSizesMs(windowSizesMs<=smallest*1000);

repeatStartSecs(end+1)=inf;
for i=1:length(repeatStartSecs)-1
    repeat{i}=evtTimesSecs(evtTimesSecs>=repeatStartSecs(i) & evtTimesSecs<repeatStartSecs(i+1))-repeatStartSecs(i);
    repeat{i}=repeat{i}(repeat{i}<=smallest);
end
repeatStartSecs=repeatStartSecs(1:end-1);

windowStartTimes=0:slidingMs/1000:smallest;

ff=nan(length(windowSizesMs),length(windowStartTimes));
out=nan(1,length(windowSizesMs));
for i=1:length(windowSizesMs)
    fprintf('\nff: %d\n',windowSizesMs(i))
    
    windows=zeros(length(repeatStartSecs),length(windowStartTimes));
    
    for j=1:length(repeat)
        for k=1:length(repeat{j})
            t=repeat{j}(k);
            inds=find(windowStartTimes<=t & windowStartTimes>t-windowSizesMs(i)/1000);
            windows(j,inds)=windows(j,inds)+1;
            
            if false && rand>.999 && ~isempty(inds)
                j
                k
                inds
                keyboard
            end
        end
        fprintf('%g%% ',100*j/length(repeat))
    end
    
    for j=1:length(windowStartTimes)
        ff(i,j)=var(windows(:,j))/mean(windows(:,j));
    end
    
    tmp=ff(i,:);
    out(i)=mean(tmp(~isnan(tmp) & ~isinf(tmp)));
end

out=[out;windowSizesMs];

if doPlot
    f=figure;
    
    if false
        [h bins]=hist(cellfun(@length,repeat),10);
        subplot(2,1,1)
        plot(bins,h);
        hold on
        plot(firingRate*trialDurSecs*ones(1,2),[0 max(h)])
        
        subplot(2,1,2)
    end
    
    subplot(2,1,1)
    c=colormap;
    str={};
    cs={};
    for i=1:length(windowSizesMs)
        cs{i}=c(1+floor(size(c,1)*i/(length(windowSizesMs)+1)),:);
        plot(windowStartTimes,ff(i,:),'color',cs{i})
        hold on
        str{end+1}=sprintf('%d ms',windowSizesMs(i));
    end
    ylabel('fano factor')
    xlabel('sec')
    legend(str)
    for i=1:length(windowSizesMs)
        plot(windowStartTimes([1,end]),ones(1,2)*out(1,i),'color',cs{i});
    end
    
    subplot(2,1,2)
    plot(out(2,:),out(1,:),'k')
    ylabel('fano factor')
    xlabel('window (ms)')
    hold on
    for i=1:length(windowSizesMs)
        plot(out(2,i),out(1,i),'.','markersize',10,'color',cs{i});
    end
end