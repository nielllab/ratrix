close all
clear all

pathname = 'C:\Users\nlab\Box Sync\Phil Niell Lab\2pData';

psfile = 'c:\tempPhil2pSize.ps';
if exist(psfile,'file')==2;delete(psfile);end
global S2P
S2P = 0; %S2P analysis = 1, other = 0

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
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(radiusRange); sizes{i} = num2str(radiusRange(i)*2); end
thetaRange = unique(theta);
timepts = 1:(2*isi+duration)/dt; timepts = (timepts-1)*dt; timepts = timepts - isi;

f1=figure;f2=figure;f3=figure;f4=figure;
for i = 1:length(grpfiles)
    sprintf('loading %s data',grpnames{i})
    load(fullfile(pathname,grpfiles{i}))
    
    figure(f1)%%%stationary size curves
    subplot(1,length(grpfiles),i)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow,:,1,1),2),1));
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow,:,1,2),2),1));
    end
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.25])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)

    
    figure(f2)%%%running size curves
    subplot(1,length(grpfiles),i)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow,:,2,1),2),1));
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow,:,2,2),2),1));
    end
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s run',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.35])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    
    
    figure(f3)%%%stationary spread
    subplot(4,4,1+i-1)%%5 deg
    pre=squeeze(grpring(:,:,1,2,1,1)) - squeeze(grpring(:,:,1,1,1,1));post=squeeze(grpring(:,:,1,2,1,2))- squeeze(grpring(:,:,1,1,1,2));
    hold on
    shadedErrorBar(1:80,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(1:80,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 5deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(4,4,5+i-1)%%20 deg
    pre=squeeze(grpring(:,:,1,4,1,1)) - squeeze(grpring(:,:,1,1,1,1));post=squeeze(grpring(:,:,1,4,1,2))- squeeze(grpring(:,:,1,1,1,2));
    hold on
    shadedErrorBar(1:80,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(1:80,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 20deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(4,4,9+i-1)%%50 deg
    pre=squeeze(grpring(:,:,1,7,1,1)) - squeeze(grpring(:,:,1,1,1,1));post=squeeze(grpring(:,:,1,7,1,2))- squeeze(grpring(:,:,1,1,1,2));
    hold on
    shadedErrorBar(1:80,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(1:80,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 50deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(4,4,13+i-1)%%50 deg
    pre=squeeze(nanmean(grpring(:,1:3,1,:,1,1),2));post=squeeze(nanmean(grpring(:,1:3,1,:,1,2),2));
    for j = 1:size(pre,1)
        pre(j,:) = pre(j,:)-squeeze(grpring(j,1,1,1,1,1));
        post(j,:) = post(j,:)-squeeze(grpring(j,1,1,1,1,2));
    end
    hold on
    errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
    errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
    axis square
    axis([0 length(sizes)+1 -0.1 0.3])
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    
    
    figure(f4)%%%running spread
    subplot(4,4,1+i-1)%%5 deg
    pre=squeeze(grpring(:,:,1,2,2,1)) - squeeze(grpring(:,:,1,1,2,1));post=squeeze(grpring(:,:,1,2,2,2))- squeeze(grpring(:,:,1,1,2,2));
    hold on
    shadedErrorBar(1:80,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(1:80,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 5deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(4,4,5+i-1)%%20 deg
    pre=squeeze(grpring(:,:,1,4,2,1)) - squeeze(grpring(:,:,1,1,2,1));post=squeeze(grpring(:,:,1,4,2,2))- squeeze(grpring(:,:,1,1,2,2));
    hold on
    shadedErrorBar(1:80,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(1:80,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 20deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(4,4,9+i-1)%%50 deg
    pre=squeeze(grpring(:,:,1,7,2,1)) - squeeze(grpring(:,:,1,1,2,1));post=squeeze(grpring(:,:,1,7,2,2))- squeeze(grpring(:,:,1,1,2,2));
    hold on
    shadedErrorBar(1:80,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(1:80,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 50deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(4,4,13+i-1)%%50 deg
    pre=squeeze(nanmean(grpring(:,1:3,1,:,2,1),2));post=squeeze(nanmean(grpring(:,1:3,1,:,2,2),2));
    for j = 1:size(pre,1)
        pre(j,:) = pre(j,:)-squeeze(grpring(j,1,1,1,2,1));
        post(j,:) = post(j,:)-squeeze(grpring(j,1,1,1,2,2));
    end
    hold on
    errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
    errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
    axis square
    axis([0 length(sizes)+1 -0.1 0.3])
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s run',grpnames{i}))
    set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    
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
mtit('stationary pixelwise analysis')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f4)
mtit('running pixelwise analysis')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

try
    dos(['ps2pdf ' psfile ' "' [fullfile(pathname,'2pSizeSummary') '.pdf'] '"'] )
catch
    display('couldnt generate pdf');
end

delete(psfile);
    