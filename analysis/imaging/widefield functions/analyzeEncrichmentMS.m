%% analyzeEncrichmentMS
close all
clear all
dbstop if error
warning('off','all')

savename = 'EEcohort2_DiffPeaksSpatial' %pdf file name
pathname = 'F:\Alyssa\EnrichmentWidefield\cohort2' %location you want PDF saved

[ctlfile p] = uigetfile('*.mat','select CONTROL file');
cd(p)
[enrfile p] = uigetfile('*.mat','select ENRICHMENT file');
fnames = {ctlfile,enrfile};grpnames = {'control','enrichment'};

%create a temp file for pdf generation
psfilename = 'tempWF.ps'; 
if exist(psfilename,'file')==2;delete(psfilename);end

mycol = {'k','r'};%colors for plotting
areas = {'V1','P','LM','AL','RL','AM','PM','MM'};%labels for the different areas
pltrange = [0 0.01];%colormap range for plotting images
csval=11; %circular shift for nat im data

imagerate = 10;
load('C:\src\Movies\naturalImagesEnrichment8mag648s.mat','isi','duration','familiar');
cyclength = (isi+duration)*imagerate;
base = 8:10; %indices for baseline
peak = 14:16; %indices for peak response
imrange = [0 0.05]; %range to display images at
ptsrange = 2; %+/- pixels from selected point to average over
range = -ptsrange:ptsrange;
timepts = 0:1/imagerate:cyclength/imagerate-1/imagerate; %cycle time points

load('F:\Mandi\EnrichmentWidefield\NewPts070119.mat')%selected points for looking at cycle averages for each area
load('C:\mapOverlay5mm.mat')%borders of visual areas for plotting
dt=0.1;%time between imaging frames
f1 = figure;f2 = figure;%initialize figures
load(ctlfile,'allfam','allims','allfiles')
for i = 1:length(allims)
    fig(i) = figure;
    ax1 = subplot(2,3,1);
    imshow(allims{i})
    colormap(ax1,'gray')
end
for i = 1:2
    f3(i) = figure;
    f4(i) = figure;
end
for i = 1:length(x)
    tunfig(i) = figure;
end

xydata = zeros(2,length(allims));

cnt=1;
for f = 1:length(fnames)
%     %%%3x2y analysis
%     clear cycavg
%     load(fullfile(p,fnames{f}),'cycavg','shiftData','mnfit')
%     if length(size(cycavg))==4
%         semcycavg = std(cycavg,[],4)/sqrt(size(cycavg,4));
%         cycavg = mean(cycavg,4);
%     else
%         semcycavg = zeros(size(cycavg));
%     end
%     cycavg = circshift(cycavg,5,3);
%     figure(f1)
%     for i = 1:length(x)
%         subplot(2,floor(length(x)/2)+1,i)
%         hold on
%         im = cycavg(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:);
%         im = squeeze(mean(mean(im,2),1));
%         im = im-(mean(im(1:2)));
%         sim = semcycavg(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:);
%         sim = squeeze(mean(mean(sim,2),1));
%         sim = sim-(mean(sim(1:2)));
%         shadedErrorBar(0:dt:length(im)*dt-dt,im,sim,mycol{f},1)
%         axis([0 length(im)*dt-dt 0 0.03])
%         set(gca,'ytick',0:0.01:0.03)
%         ylabel(sprintf('%s dfof',areas{i}))
%         xlabel('time (s)')
%         axis square
%         hold off
%     end
% %     legend('control','enrichment')
%     subplot(2,floor(length(x)/2)+1,length(x)+f)
%     colormap jet
%     im = mean(cycavg(:,:,6:8),3)-mean(cycavg(:,:,1:2),3);
%     imagesc(im,pltrange)
%     hold on; plot(ypts,xpts,'w.','Markersize',2);
%     for i = 1:length(x)
%         plot(y(i),x(i),'k.','MarkerSize',10)
%     end
%     axis image
%     axis off
%     title(sprintf('%s',grpnames{f}))
%     hold off
%     
%     figure(f2)
%     colormap jet
%     for i = 4:10
%         subplot(2,7,cnt)
%         im = squeeze(cycavg(:,:,i));
%         imagesc(im,pltrange)
%         hold on; plot(ypts,xpts,'w.','Markersize',2);
%         axis image
%         axis off
%         hold off
%         cnt=cnt+1;
%     end
%     
%     for i = 1:length(x)
%         figure(tunfig(i))
% 
%         subplot(2,3,1)
%         imagesc(mean(shiftData(:,:,5,:),4));
%         hold on
%         plot([y(i)-ptsrange y(i)-ptsrange y(i)+ptsrange y(i)+ptsrange y(i)-ptsrange],...
%             [x(i)-ptsrange x(i)+ptsrange x(i)+ptsrange x(i)-ptsrange x(i)-ptsrange],'k','LineWidth',2)
%         plot(ypts,xpts,'w.','Markersize',2); axis off; axis image
%         hold off
%         
%         subplot(2,3,2);
%         hold on
%         d=squeeze(mean(mean(mnfit(x(i)+range,y(i)+range,1:3),2),1));
%         maxx=max(d);
%         plot(d,mycol{f},'LineWidth',2);
%         hold off
%         
%         subplot(2,3,3)
%         hold on
%         d=squeeze(mean(mean(mnfit(x(i)+range,y(i)+range,4:5),2),1));
%         plot(d*maxx,mycol{f},'LineWidth',2);
%         hold off
%         
%         subplot(2,3,4);
%         hold on
%         d =  squeeze(mean(mean(mnfit(x(i)+range,y(i)+range,6:11),2),1));
%         plot(d*maxx,[mycol{f} 'o'],'LineWidth',2);
%         plot(2:6,d(2:6)*maxx,mycol{f},'LineWidth',2);
%         hold off
%         
%         subplot(2,3,5);
%         hold on
%         d=squeeze(mean(mean(mnfit(x(i)+range,y(i)+range,12:15),2),1));
%         plot(d*maxx,mycol{f},'LineWidth',2);
%         hold off
%         
%         subplot(2,3,6);
%         hold on
%         d=squeeze(mean(mean(mean(cycavg(x(i)+range,y(i)+range,:,:),4),2),1));
%         plot((circshift(d',10)-min(d)),mycol{f},'LineWidth',2);
%         hold off
%     end
    
    %%%natural images analysis
    load(fullfile(p,fnames{f}),'natimcyc','natimcycavg')
    if length(size(natimcyc))==5
        semnatimcyc = std(natimcyc,[],5)/sqrt(size(natimcyc,5));
        natimcyc = mean(natimcyc,5);
    else
        semnatimcyc = zeros(size(natimcyc));
    end
%     natimcyc = circshift(natimcyc,5,3);
    if length(size(natimcycavg))==6
        semnatimcycavg = std(natimcycavg,[],6)/sqrt(size(natimcycavg,6));
        natimcycavg = mean(natimcycavg,6);
    else
        semnatimcycavg = zeros(size(natimcycavg));
    end
%     natimcycavg = circshift(natimcycavg,5,3);
    
    %%%plot the peak response to each stimulus
    figure(f3(f)); colormap jet
    for i = 1:length(allims)
        subplot(5,ceil(length(allims)/5),i)
        im = nanmean(nanmean(natimcycavg(:,:,peak,i,:),3),5)-nanmean(nanmean(natimcycavg(:,:,base,i,:),3),5);
        imagesc(im,imrange)
        hold on;plot(ypts,xpts,'w.','Markersize',2)
        axis off
        axis image
        hold off
    end
        
    %%%plot familiar vs. unfamiliar average
    figure(f4(f))
    fam = find(familiar==1);
    unfam = find(familiar==0);
    for i = 1:length(x)
        subplot(2,ceil(length(x)/2),i)
        trace = squeeze(nanmean(nanmean(nanmean(natimcyc(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:,fam),1),2),4));
        semtrace = squeeze(nanmean(nanmean(nanmean(semnatimcyc(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:,fam),1),2),4));
        shadedErrorBar(timepts,circshift(trace-mean(trace(base)),csval),circshift(semtrace,csval),'k',1)
        hold on
        trace = squeeze(nanmean(nanmean(nanmean(natimcyc(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:,unfam),1),2),4));
        semtrace = squeeze(nanmean(nanmean(nanmean(semnatimcyc(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:,unfam),1),2),4));
        shadedErrorBar(timepts,circshift(trace-mean(trace(base)),csval),circshift(semtrace,csval),'r',1)
        xlabel('time (s)')
        ylabel(sprintf('%s dfof',areas{i}))
        yv=get(gca,'ylim');
        axis([0 timepts(end) -0.01 yv(2)+0.01])
        axis square
        hold off
    end
%     legend('familiar','unfamiliar','Location','southeast')
        
    %%%make plots for each natural image
    for i = 1:length(allims)
        figure(fig(i))
        
        ax2 = subplot(2,3,2);colormap(ax2,'jet');
        ax3 = subplot(2,3,3);colormap(ax3,'jet');
        subplot(2,3,2+(f-1))
        im = nanmean(nanmean(natimcycavg(:,:,peak,i+1,:),3),5)-nanmean(nanmean(natimcycavg(:,:,base,i+1,:),3),5);%1st idx is blank so add 1
        imagesc(im,imrange)
        hold on;plot(ypts,xpts,'w.','Markersize',2)
        axis image
        axis off
        title(grpnames{f})
        hold off
        
        subplot(2,3,4+(f-1))
        hold on
        cmap = colormap(jet);cmap=cmap(1:length(x):end,:);
        for j = 1:length(x)
            trace = squeeze(nanmean(nanmean(nanmean(natimcycavg(x(j)-ptsrange:x(j)+ptsrange,y(j)-ptsrange:y(j)+ptsrange,:,i+1,:),5),2),1)); %1st idx is blank so add 1
            semtrace = squeeze(nanmean(nanmean(nanmean(semnatimcycavg(x(j)-ptsrange:x(j)+ptsrange,y(j)-ptsrange:y(j)+ptsrange,:,i+1,:),5),2),1)); %1st idx is blank so add 1
%             shadedErrorBar(timepts,trace-mean(trace(base)),semtrace,cmap(j,:),1)
            plot(timepts,circshift(trace-mean(trace(base)),csval))
        end
        lgd = legend(areas,'Location','Northeast');
        lgd.FontSize = 8;
        xlabel('time (s)')
        ylabel('dfof')
        yv=get(gca,'ylim');
        axis([0 timepts(end) -0.01 yv(2)+0.01])
        axis square
        title(grpnames{f})
        hold off
        
        subplot(2,3,6)
        hold on
        trace = squeeze(nanmean(nanmean(nanmean(natimcycavg(x(1)-ptsrange:x(1)+ptsrange,y(1)-ptsrange:y(1)+ptsrange,:,i+1,:),5),2),1)); %1st idx is blank so add 1
        semtrace = squeeze(nanmean(nanmean(nanmean(semnatimcycavg(x(1)-ptsrange:x(1)+ptsrange,y(1)-ptsrange:y(1)+ptsrange,:,i+1,:),5),2),1)); %1st idx is blank so add 1
        shadedErrorBar(timepts,circshift(trace-mean(trace(base)),csval),circshift(semtrace,csval),mycol{f},1)
        xlabel('time (s)')
        ylabel('dfof')
        yv=get(gca,'ylim');
        axis([0 timepts(end) -0.01 yv(2)+0.01])
        axis square
        hold off
        
        xydata(f,i) = mean(trace(peak))-mean(trace(base));
    end
    
end

figure(f1)
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

for i = 1:length(x)
    figure(tunfig(i))

    subplot(2,3,1)
    legend(areas{i})
    
    subplot(2,3,2);
    title('x');
    yv=get(gca,'ylim');
    axis([1 3 0 yv(2)+0.01])
    set(gca,'Xtick',[1 3]);
    set(gca,'Xticklabel',{'medial','lateral'});

    subplot(2,3,3)
    title('y');
    yv=get(gca,'ylim');
    axis([1 2 0 yv(2)+0.01])
    set(gca,'Xtick',[1 2]);
    set(gca,'Xticklabel',{'top','bottom'});

    subplot(2,3,4);
    title('sf');
    yv=get(gca,'ylim');
    axis([0.75 6.25 0 yv(2)+0.01])
    set(gca,'Xtick',[1 3 5]);
    set(gca,'Xticklabel',{'0','0.04','0.16','0.32'});
    xlabel('cpd')

    subplot(2,3,5);
    title('tf');
    yv=get(gca,'ylim');
    axis([1 4 0 yv(2)+0.01])
    set(gca,'XtickLabel',{'0', '2','8'});
    xlabel('Hz')

    subplot(2,3,6);
    title('timecourse');
    yv=get(gca,'ylim');
    axis([1 15 0 yv(2)+0.01])
    set(gca,'xtick',0:5:15,'xticklabel',0:0.5:1.5)
    xlabel('time')
    mtit(sprintf('tuning for %s',areas{i}))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
end

for i = 1:2
    figure(f3(i))
    mtit(sprintf('%s peak resp natural images',grpnames{i}))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
    
    figure(f4(i))
    mtit(sprintf('%s familiar (red) vs. unfamiliar (black)',grpnames{i}))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
end

for i = 1:length(allims)
    figure(fig(i))
    subplot(2,3,6)
%     legend(grpnames)
    mtit(sprintf('%s %s familiar=%d',allfiles{i},allfam(i)))
    if exist('psfilename','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfilename,'-append');
    end
end

xyfig=figure;
hold on
for i = 1:length(allims)
    if allfam(i)==0
        plot(xydata(1,i),xydata(2,i),'ko','Markersize',15)
    else
        plot(xydata(1,i),xydata(2,i),'ro','Markersize',15)
    end
end
yv = get(gca,'ylim');xv = get(gca,'ylim');
xylim = max(yv(2),xv(2))+0.01;
plot([0 xylim],[0 xylim],'k:')
axis([0 xylim 0 xylim])
xlabel('control dfof')
ylabel('enchriched dfof')
title('unfamiliar (black) vs. familiar (red)')
axis square
set(gca,'xtick',0:0.025:xylim,'ytick',0:0.025:xylim)
hold off
if exist('psfilename','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfilename,'-append');
end

try
    dos(['ps2pdf ' psfilename ' "' 'EnrichmentGroupsAnalysis.pdf' '"'])
    delete(psfilename);
catch
    disp('couldnt generate pdf');
    keyboard
end
