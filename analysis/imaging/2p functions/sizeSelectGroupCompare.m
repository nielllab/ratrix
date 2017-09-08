close all
clear all

grppath = 'C:\Users\nlab\Box Sync\Phil Niell Lab\2pData';

psfile = 'c:\tempPhil2pSize.ps';
if exist(psfile,'file')==2;delete(psfile);end
global S2P
S2P = 0; %S2P analysis = 1, other = 0

centwin = 1:3; %%%window for measurment of response at center (20um bins currently)

grpfiles = {'SalineNaive2pSizeSelectEff'...
            'SalineTrained2pSizeSelectEff'...
            'DOINaive2pSizeSelectEff'...
            'DOITrained2pSizeSelectEff'};

grpnames = {'saline naive'...
            'saline trained'...
            'doi naive'...
            'doi trained'};

moviefname = 'C:\sizeselectBin22min';
load(moviefname)
dfWindow = 9:11;
spWindow = 6:10;
dt = 0.1;
cyclelength = 1/0.1;
timepts = 1:(2*isi+duration)/dt; timepts = (timepts-1)*dt; timepts = timepts - isi;
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);thetaRange = unique(theta);radiusrange = unique(radius);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(radiusRange); sizes{i} = num2str(radiusRange(i)*2); end
numtrialtypes = length(sfrange)*length(contrastRange)*length(radiusRange)*length(thetaRange);
trialtype = nan(numtrialtypes,length(sf)/numtrialtypes);
cnt=1;
for i = 1:length(sfrange)
    for j = 1:length(contrastRange)
        for k = 1:length(radiusrange)
            for l = 1:length(thetaRange)
                trialtype(cnt,:) = find(sf==sfrange(i)&contrasts==contrastRange(j)&...
                    radius==radiusrange(k)&theta==thetaRange(l));
                cnt=cnt+1;
            end
        end
    end
end

f1=figure;f2=figure;f3=figure;f4=figure;f5=figure;f6=figure;
hvals=zeros(4,length(sizes),4);
pvals=zeros(4,length(sizes));
for i = 1:length(grpfiles)
    sprintf('loading %s data',grpnames{i})
    load(fullfile(grppath,grpfiles{i}))
    
    figure(f1)%%%stationary size curves
    subplot(1,length(grpfiles),i)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow,:,1,1),2),1));
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow,:,1,2),2),1));
    end
    [hvals(i,:,1) pvals(i,:,1)] = ttest(pre,post,'alpha',0.05);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     plot(1:length(radiusRange),hvals(i,:,1)-0.75,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.25])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',10)
    

    
    figure(f2)%%%running size curves
    subplot(1,length(grpfiles),i)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow,:,2,1),2),1));
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow,:,2,2),2),1));
    end
    [hvals(i,:,2) pvals(i,:,2)] = ttest(pre,post,'alpha',0.05);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     plot(1:length(radiusRange),hvals(i,:,2)-0.65,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s run',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.35])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',10)
    
    
    figure(f3)%%%stationary spread
    zeropre = squeeze(nanmean(grpring(:,:,:,1,1,1),3));zeropost = squeeze(nanmean(grpring(:,:,:,1,1,2),3));
    subplot(4,4,1+i-1)%%5 deg
    pre=squeeze(grpring(:,:,1,2,1,1)) - zeropre;post=squeeze(grpring(:,:,1,2,1,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.2])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 5deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,5+i-1)%%20 deg
    pre=squeeze(grpring(:,:,1,4,1,1)) - zeropre;post=squeeze(grpring(:,:,1,4,1,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.2])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 20deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,9+i-1)%%50 deg
    pre=squeeze(grpring(:,:,1,7,1,1)) - zeropre;post=squeeze(grpring(:,:,1,7,1,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.2])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 50deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,13+i-1)%%size curves
    pre=squeeze(nanmean(grpring(:,centwin,1,:,1,1),2));post=squeeze(nanmean(grpring(:,centwin,1,:,1,2),2));
    for j = 1:size(pre,1)
        pre(j,:) = pre(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,1,1),2),3));
        post(j,:) = post(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,1,2),2),3));
    end
    [hvals(i,:,3) pvals(i,:,3)] = ttest(pre,post,'alpha',0.05);
    hold on
    errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
    errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
%     plot(1:length(radiusRange),hvals(i,:,3)-0.7,'b*')
    axis square
    axis([0 length(sizes)+1 -0.1 0.2])
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',10)
    
    
    figure(f4)%%%running spread
    zeropre = squeeze(nanmean(grpring(:,:,:,1,2,1),3));zeropost = squeeze(nanmean(grpring(:,:,:,1,2,2),3));
    subplot(4,4,1+i-1)%%5 deg
    pre=squeeze(grpring(:,:,1,2,2,1)) - zeropre;post=squeeze(grpring(:,:,1,2,2,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 5deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,5+i-1)%%20 deg
    pre=squeeze(grpring(:,:,1,4,2,1)) - zeropre;post=squeeze(grpring(:,:,1,4,2,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 20deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,9+i-1)%%50 deg
    pre=squeeze(grpring(:,:,1,7,2,1)) - zeropre;post=squeeze(grpring(:,:,1,7,2,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 50deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,13+i-1)%%50 deg
    pre=squeeze(nanmean(grpring(:,centwin,1,:,2,1),2));post=squeeze(nanmean(grpring(:,centwin,1,:,2,2),2));
    for j = 1:size(pre,1)
        pre(j,:) = pre(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,2,1),2),3));
        post(j,:) = post(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,2,2),2),3));
    end
    [hvals(i,:,4) pvals(i,:,4)] = ttest(pre,post,'alpha',0.05);
    hold on
    errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
    errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
%     plot(1:length(radiusRange),hvals(i,:,4)-0.7,'b*')
    axis square
    axis([0 length(sizes)+1 -0.1 0.3])
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s run',grpnames{i}))
    set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',10)
    
    figure(f5)%%%stationary spread
    zeropre = squeeze(nanmean(grpring(:,:,:,1,1,1),3));zeropost = squeeze(nanmean(grpring(:,:,:,1,1,2),3));
    subplot(4,4,1+i-1)%%5 deg
    pre=squeeze(grpring(:,:,2,2,1,1)) - zeropre;post=squeeze(grpring(:,:,2,2,1,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 5deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,5+i-1)%%20 deg
    pre=squeeze(grpring(:,:,2,4,1,1)) - zeropre;post=squeeze(grpring(:,:,2,4,1,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 20deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,9+i-1)%%50 deg
    pre=squeeze(grpring(:,:,2,7,1,1)) - zeropre;post=squeeze(grpring(:,:,2,7,1,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 50deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,13+i-1)%%size curves
    pre=squeeze(nanmean(grpring(:,centwin,2,:,1,1),2));post=squeeze(nanmean(grpring(:,centwin,2,:,1,2),2));
    for j = 1:size(pre,1)
        pre(j,:) = pre(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,1,1),2),3));
        post(j,:) = post(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,1,2),2),3));
    end
    [hvals(i,:,3) pvals(i,:,3)] = ttest(pre,post,'alpha',0.05);
    hold on
    errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
    errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
%     plot(1:length(radiusRange),hvals(i,:,3)-0.7,'b*')
    axis square
    axis([0 length(sizes)+1 -0.1 0.3])
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',10)
    
    
    figure(f6)%%%running spread
    zeropre = squeeze(nanmean(grpring(:,:,:,1,2,1),3));zeropost = squeeze(nanmean(grpring(:,:,:,1,2,2),3));
    subplot(4,4,1+i-1)%%5 deg
    pre=squeeze(grpring(:,:,2,2,2,1)) - zeropre;post=squeeze(grpring(:,:,2,2,2,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 5deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,5+i-1)%%20 deg
    pre=squeeze(grpring(:,:,2,4,2,1)) - zeropre;post=squeeze(grpring(:,:,2,4,2,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 20deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,9+i-1)%%50 deg
    pre=squeeze(grpring(:,:,2,7,2,1)) - zeropre;post=squeeze(grpring(:,:,2,7,2,2)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 50deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',10)
    subplot(4,4,13+i-1)%%50 deg
    pre=squeeze(nanmean(grpring(:,centwin,2,:,2,1),2));post=squeeze(nanmean(grpring(:,centwin,2,:,2,2),2));
    for j = 1:size(pre,1)
        pre(j,:) = pre(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,2,1),2),3));
        post(j,:) = post(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,2,2),2),3));
    end
    [hvals(i,:,4) pvals(i,:,4)] = ttest(pre,post,'alpha',0.05);
    hold on
    errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
    errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
%     plot(1:length(radiusRange),hvals(i,:,4)-0.7,'b*')
    axis square
    axis([0 length(sizes)+1 -0.1 0.3])
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s run',grpnames{i}))
    set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',10)
    
end

figure(f1)
mtit('stationary size curves')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f2)
mtit('running size curves')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f3)
mtit('stationary pixelwise analysis 0.04cpd')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f4)
mtit('running pixelwise analysis 0.04cpd')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f5)
mtit('stationary pixelwise analysis 0.16cpd')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f6)
mtit('running pixelwise analysis 0.16cpd')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

try
    dos(['ps2pdf ' psfile ' "' [fullfile(grppath,'2pSizeSummary') '.pdf'] '"'] )
catch
    display('couldnt generate pdf');
end

delete(psfile);
    