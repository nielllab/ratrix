%% analyzeEncrichmentMS
close all
clear all
dbstop if error

[ctlfile p] = uigetfile('*.mat','select CONTROL file');
cd(p)
[enrfile p] = uigetfile('*.mat','select ENRICHED file');
fnames = {ctlfile,enrfile};grpnames = {'control','enriched'};
mycol = {'k','r'};
areas = {'V1','P','LM','AL','RL','AM','PM','MM'};
pltrange = [0 0.01];
cyclength = (isi+duration)*imagerate;
base = 8:10; %indices for baseline
peak = 11:13; %indices for peak response
imrange = [0 0.05]; %range to display images at
ptsrange = 2; %+/- pixels from selected point to average over
timepts = 0:1/imagerate:cyclength/imagerate-1/imagerate; %cycle time points

load('F:\Mandi\EnrichmentWidefield\CrisPts.mat')
load('C:\mapOverlay5mm.mat')
dt=0.1;
f1 = figure;f2 = figure;
load(ctlfile,'allfam','allims','allfiles')
for i = 1:length(allims)
    fig(i) = figure;
    ax1 = subplot(2,2,1);
    imshow(allims{i})
    colormap(ax1,'gray')
end
for i = 1:2
    f3(i) = figure;
    f4(i) = figure;
end

cnt=1;
for f = 1:length(fnames)
    %%%3x2y analysis
    clear cycavg
    load(fullfile(p,fnames{f}),'cycavg')
    if length(size(cycavg))==4
        semcycavg = std(cycavg,[],4)/sqrt(size(cycavg,4));
        cycavg = mean(cycavg,4);
    else
        semcycavg = zeros(size(cycavg));
    end
    cycavg = circshift(cycavg,5,3);
    figure(f1)
    for i = 1:length(x)
        subplot(2,round(length(x)/2),i)
        hold on
        im = cycavg(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:);
        im = squeeze(mean(mean(im,2),1));
        im = im-(mean(im(1:2)));
        sim = semcycavg(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:);
        sim = squeeze(mean(mean(sim,2),1));
        sim = sim-(mean(sim(1:2)));
        shadedErrorBar(0:dt:length(im)*dt-dt,im,sim,mycol{f},1)
        axis([0 length(im)*dt-dt -0.005 0.05])
        ylabel(sprintf('%s dfof',areas{i}))
        xlabel('time (s)')
        axis square
    end
    
    figure(f2)
    colormap jet
    for i = 4:10
        subplot(2,7,cnt)
        im = squeeze(cycavg(:,:,i));
        imagesc(im,pltrange)
        hold on; plot(ypts,xpts,'w.','Markersize',2);
        axis image
        axis off
        cnt=cnt+1;
    end
    
    %%%natural images analysis
    load(fullfile(p,fnames{f}),'natimcyc','natimcycavg')
    if length(size(natimcyc))==5
        semnatimcyc = std(natimcyc,[],5)/sqrt(size(natimcyc,5));
        natimcyc = mean(natimcyc,5);
    else
        semnatimcyc = zeros(size(natimcyc));
    end
    natimcyc = circshift(natimcyc,5,3);
    if length(size(natimcycavg))==5
        semnatimcycavg = std(natimcycavg,[],5)/sqrt(size(natimcycavg,5));
        natimcycavg = mean(natimcycavg,5);
    else
        semnatimcycavg = zeros(size(natimcycavg));
    end
    natimcycavg = circshift(natimcycavg,5,3);
    
    %%%plot the peak response to each stimulus
    figure(f3(f)); colormap jet
    for i = 1:length(stimuli)
        subplot(5,ceil(length(stimuli)/5),i)
        im = nanmean(nanmean(natimcycavg(:,:,peak,i,:),3),5);%-nanmean(nanmean(natimcycavg(:,:,base,i,:),3),5);
        imagesc(im,imrange)
        hold on;plot(ypts,xpts,'w.','Markersize',2)
        axis off
        axis image
    end
        
    %%%plot familiar vs. unfamiliar average
    figure(f4(f))
    fam = find(familiar==1);
    unfam = find(familiar==0);
    for i = 1:length(x)
        subplot(2,ceil(length(x)/2),i)
        trace = squeeze(nanmean(nanmean(nanmean(natimcyc(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:,fam),1),2),4));
        semtrace = squeeze(nanmean(nanmean(nanmean(semnatimcyc(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:,fam),1),2),4));
        shadedErrorBar(timepts,trace-mean(trace(base)),semtrace,'k')
        hold on
        trace = squeeze(nanmean(nanmean(nanmean(natimcyc(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:,unfam),1),2),4));
        semtrace = squeeze(nanmean(nanmean(nanmean(semnatimcyc(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:,unfam),1),2),4));
        shadedErrorBar(timepts,trace-mean(trace(base)),semtrace,'r')
        xlabel('time (s)')
        ylabel(sprintf('%s dfof',visareas{i}))
        axis([0 timepts(end) -0.005 0.05])
    end
    legend('familiar','unfamiliar','Location','southeast')
        
    %%%make plots for each natural image
    for i = 1:length(allims)
        figure(fig(i))
        
        ax2 = subplot(2,3,2);colormap(ax2,'jet');title('control')
        ax3 = subplot(2,3,3);colormap(ax3,'jet');title('enriched')
        subplot(2,2,2+(f-1))
        im = nanmean(nanmean(natimcycavg(:,:,peak,i+1,:),3),5);%1st idx is blank so add 1
        imagesc(im,imrange)
        hold on;plot(ypts,xpts,'w.','Markersize',2)
        axis image
        axis off
        
        subplot(2,3,4+(f-1))
        hold on
        cmap = colormap(jet);cmap=cmap(1:length(x):end,:);
        for j = 1:length(x)
            trace = squeeze(nanmean(nanmean(nanmean(natimcycavg(x(j)-ptsrange:x(j)+ptsrange,y(j)-ptsrange:y(j)+ptsrange,:,i+1,:),5),2),1)); %1st idx is blank so add 1
            semtrace = squeeze(nanmean(nanmean(nanmean(semnatimcycavg(x(j)-ptsrange:x(j)+ptsrange,y(j)-ptsrange:y(j)+ptsrange,:,i+1,:),5),2),1)); %1st idx is blank so add 1
            shadedErrorBar(timepts,trace-mean(trace(base)),semtrace,cmap(j,:),1)
        end
        legend(visareas,'Location','Northwest')
        xlabel('time (s)')
        ylabel('dfof')
        axis([0 timepts(end) -0.005 0.1])
        axis square
        title(grpnames{f})
        
        subplot(2,3,6)
        hold on
        trace = squeeze(nanmean(nanmean(nanmean(natimcycavg(x(1)-ptsrange:x(1)+ptsrange,y(1)-ptsrange:y(1)+ptsrange,:,i+1,:),5),2),1)); %1st idx is blank so add 1
        semtrace = squeeze(nanmean(nanmean(nanmean(semnatimcycavg(x(1)-ptsrange:x(1)+ptsrange,y(1)-ptsrange:y(1)+ptsrange,:,i+1,:),5),2),1)); %1st idx is blank so add 1
        shadedErrorBar(timepts,trace-mean(trace(base)),semtrace,mycol{f},1)
        xlabel('time (s)')
        ylabel('dfof')
        axis([0 timepts(end) -0.005 0.1])
        axis square
        
    end
    
end

figure(f1)
legend('pre','post')
subplot(2,round(length(x)/2),length(x)+1)
colormap jet
im = mean(cycavg(:,:,6:8),3)-mean(cycavg(:,:,1:2),3);
imagesc(im,pltrange)
hold on; plot(ypts,xpts,'w.','Markersize',2);
for i = 1:length(x)
    plot(y(i),x(i),'k.','MarkerSize',10)
end
axis image
axis off
mtit('3x2y cycavg for each visual area')
if exist('psfilename','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfilename,'-append');
end

figure(f2)
mtit('control (top) vs. enriched (bottom) 3x2y cycavg')
if exist('psfilename','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfilename,'-append');
end

for i = 1:2
    f3(i)
    mtit(sprintf('%s peak resp natural images',grpnames{i}))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    
    f4(i) = figure;
    mtit(sprintf('%s natural images',grpnames{i}))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
end

for i = 1:nims
    figure(fig(i))
    subplot(2,3,6)
    legend(grpnames)
    mtit(sprintf('%s %s familiar=%d',allfiles{i},allfam(i)))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
end
