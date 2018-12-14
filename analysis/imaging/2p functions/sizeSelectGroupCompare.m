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
            'DOITrained2pSizeSelectEff'};%...
%             'Saline2pSizeSelectEff'...
%             'DOI2pSizeSelectEff'};

grpnames = {'saline naive'...
            'saline trained'...
            'doi naive'...
            'doi trained'};%...
%             'saline'...
%             'doi'};

moviefname = 'C:\src\movies\sizeselectBin22min';
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
asize = 0.05/(length(sizes)-1); %%%significance level for size comparison
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
grps = length(grpfiles);

f1=figure;f2=figure;f3=figure;f4=figure;f5=figure;f6=figure;f7=figure;f8=figure;f9=figure;
grpchange = nan(grps,length(sizes),2); %group,size,sit/run
grpbase = nan(15,grps,2); %groups, animal, baseline response (avg across sizes), sit/run
for i = 1:length(grpfiles)
    sprintf('loading %s data',grpnames{i})
    load(fullfile(grppath,grpfiles{i}))
    session = sess;
    
    figure(f1)%%%stationary size curves
    subplot(3,grps,i)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow{1},:,1,1),2),1));
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow{1},:,1,2),2),1));
    end
    grpchange(i,:,1) = (nanmean(pre)-nanmean(post))./nanmean(pre);
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.5,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.5])
    axis square
    title(sprintf('all n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(3,grps,i+grps)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),6:7,:,1,1),2),1));
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),6:7,:,1,2),2),1));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.5,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.5])
    axis square
    title(sprintf('1st half n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(3,grps,i+grps*2)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),8:10,:,1,1),2),1));
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),8:10,:,1,2),2),1));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.5,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.5])
    axis square
    title(sprintf('2nd half n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)

    
    figure(f2)%%%running size curves
    subplot(3,grps,i)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow{1},:,2,1),2),1));
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow{1},:,2,2),2),1));
    end
    grpchange(i,:,2) = (nanmean(pre)-nanmean(post))./nanmean(pre);
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.5,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s run',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.5])
    axis square
    title(sprintf('all n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(3,grps,i+grps)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),6:7,:,2,1),2),1));
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),6:7,:,2,2),2),1));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.5,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s run',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.5])
    axis square
    title(sprintf('1st half n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(3,grps,i+grps*2)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),8:10,:,2,1),2),1));
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),8:10,:,2,2),2),1));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.5,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s run',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.5])
    axis square
    title(sprintf('2nd half n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    
    figure(f3)%%%stationary size curves
    subplot(3,grps,i)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),spWindow{1},:,:,:,1,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),spWindow{1},:,:,:,1,2),4),3),2),1));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.7,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.3])
    axis square
    title(sprintf('all n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(3,grps,i+grps)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),6:7,:,:,:,1,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),6:7,:,:,:,1,2),4),3),2),1));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.7,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.3])
    axis square
    title(sprintf('1st half n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(3,grps,i+grps*2)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),8:10,:,:,:,1,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),8:10,:,:,:,1,2),4),3),2),1));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.7,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.3])
    axis square
    title(sprintf('2nd half n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)

    
    figure(f4)%%%running size curves
    subplot(3,grps,i)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
       pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),spWindow{1},:,:,:,2,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),spWindow{1},:,:,:,2,2),4),3),2),1));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.7,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s run',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.3])
    axis square
    title(sprintf('all n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(3,grps,i+grps)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
       pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),6:7,:,:,:,2,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),6:7,:,:,:,2,2),4),3),2),1));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.7,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s run',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.3])
    axis square
    title(sprintf('1st half n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(3,grps,i+grps*2)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
       pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),8:10,:,:,:,2,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(find(session==j),8:10,:,:,:,2,2),4),3),2),1));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    plot(1:length(radiusRange),hvals-0.7,'b*')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s run',grpnames{i}))
    axis([0 length(radiusRange)+1 -0.025 0.3])
    axis square
    title(sprintf('2nd half n=%d ani %d cells',numAni,size(grpspsize,1)))
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    
    figure(f5)%%%stationary spread
    zeropre = squeeze(nanmean(grpring(:,:,:,1,1,1),3));zeropost = squeeze(nanmean(grpring(:,:,:,1,1,2),3));
    subplot(4,grps,i)%%5 deg
    pre=squeeze(nanmean(grpring(:,:,:,2,1,1),3)) - zeropre;post=squeeze(nanmean(grpring(:,:,:,2,1,2),3)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.2])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 5deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(4,grps,grps+i)%%20 deg
    pre=squeeze(nanmean(grpring(:,:,:,3,1,1),3)) - zeropre;post=squeeze(nanmean(grpring(:,:,:,3,1,2),3)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.2])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 10deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(4,grps,2*grps+i)%%50 deg
    pre=squeeze(nanmean(grpring(:,:,:,7,1,1),3)) - zeropre;post=squeeze(nanmean(grpring(:,:,:,7,1,2),3)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.2])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 50deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(4,grps,3*grps+i)%%size curves
    pre=squeeze(nanmean(nanmean(grpring(:,centwin,:,:,1,1),3),2));post=squeeze(nanmean(nanmean(grpring(:,centwin,:,:,1,2),3),2));
    for j = 1:size(pre,1)
        pre(j,:) = pre(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,1,1),2),3));
        post(j,:) = post(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,1,2),2),3));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    hold on
    errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
    errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
    plot(1:length(radiusRange),hvals-0.8,'b*')
    axis square
    axis([0 length(sizes)+1 -0.1 0.2])
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    
    
    figure(f6)%%%running spread
    zeropre = squeeze(nanmean(grpring(:,:,:,1,2,1),3));zeropost = squeeze(nanmean(grpring(:,:,:,1,2,2),3));
    subplot(4,grps,i)%%5 deg
    pre=squeeze(nanmean(grpring(:,:,:,2,2,1),3)) - zeropre;post=squeeze(nanmean(grpring(:,:,:,2,2,2),3)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.2])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 5deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(4,grps,grps+i)%%20 deg
    pre=squeeze(nanmean(grpring(:,:,:,3,2,1),3)) - zeropre;post=squeeze(nanmean(grpring(:,:,:,3,2,2),3)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.2])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 10deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(4,grps,2*grps+i)%%50 deg
    pre=squeeze(nanmean(grpring(:,:,:,7,2,1),3)) - zeropre;post=squeeze(nanmean(grpring(:,:,:,7,2,2),3)) - zeropost;
    hold on
    shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.2])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%s 50deg',grpnames{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
    subplot(4,grps,3*grps+i)%%size curves
    pre=squeeze(nanmean(nanmean(grpring(:,centwin,:,:,2,1),3),2));post=squeeze(nanmean(nanmean(grpring(:,centwin,:,:,2,2),3),2));
    for j = 1:size(pre,1)
        pre(j,:) = pre(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,2,1),2),3));
        post(j,:) = post(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,2,2),2),3));
    end
    [hvals pvals] = ttest(pre,post,'alpha',asize);
    hold on
    errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
    errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
    plot(1:length(radiusRange),hvals-0.8,'b*')
    axis square
    axis([0 length(sizes)+1 -0.1 0.2])
    xlabel('Stim Size (deg)')
    ylabel(sprintf('%s sit',grpnames{i}))
    set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    
    figure(f9)
    presit=nan(length(unique(session)),length(sizes));prerun=presit;
    for j = 1:length(unique(session))
        presit(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow{1},:,1,1),2),1));
        prerun(j,:) = squeeze(nanmean(nanmean(grpspsize(find(session==j),spWindow{1},:,2,1),2),1));
    end
    subplot(1,2,1)
    hold on
    errorbar(1:length(radiusRange),nanmean(presit,1),nanstd(presit,1)/sqrt(numAni),'-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('Stationary dfof')
    axis([0 length(radiusRange)+1 -0.025 0.75])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'ytick',0:0.25:0.75,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    hold off
    subplot(1,2,2)
    hold on
    errorbar(1:length(radiusRange),nanmean(prerun,1),nanstd(prerun,1)/sqrt(numAni),'-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('Stationary dfof')
    axis([0 length(radiusRange)+1 -0.025 0.75])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'ytick',0:0.25:0.75,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    hold off
    
    grpbase(1:numAni,i,1) = nanmean(presit(:,2:end),2);
    grpbase(1:numAni,i,2) = nanmean(prerun(:,2:end),2);
    
    
%     figure(f5)%%%stationary spread
%     zeropre = squeeze(nanmean(grpring(:,:,:,1,1,1),3));zeropost = squeeze(nanmean(grpring(:,:,:,1,1,2),3));
%     subplot(4,grps,i)%%5 deg
%     pre=squeeze(grpring(:,:,1,2,1,1)) - zeropre;post=squeeze(grpring(:,:,1,2,1,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.2])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 5deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,grps+i)%%20 deg
%     pre=squeeze(grpring(:,:,1,3,1,1)) - zeropre;post=squeeze(grpring(:,:,1,3,1,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.2])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 10deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,2*grps+i)%%50 deg
%     pre=squeeze(grpring(:,:,1,7,1,1)) - zeropre;post=squeeze(grpring(:,:,1,7,1,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.2])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 50deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,3*grps+i)%%size curves
%     pre=squeeze(nanmean(grpring(:,centwin,1,:,1,1),2));post=squeeze(nanmean(grpring(:,centwin,1,:,1,2),2));
%     for j = 1:size(pre,1)
%         pre(j,:) = pre(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,1,1),2),3));
%         post(j,:) = post(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,1,2),2),3));
%     end
%     [hvals pvals] = ttest(pre,post,'alpha',asize);
%     hold on
%     errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
%     errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
%     plot(1:length(radiusRange),hvals-0.8,'b*')
%     axis square
%     axis([0 length(sizes)+1 -0.1 0.2])
%     xlabel('Stim Size (deg)')
%     ylabel(sprintf('%s sit',grpnames{i}))
%     set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     
%     
%     figure(f6)%%%running spread
%     zeropre = squeeze(nanmean(grpring(:,:,:,1,2,1),3));zeropost = squeeze(nanmean(grpring(:,:,:,1,2,2),3));
%     subplot(4,grps,i)%%5 deg
%     pre=squeeze(grpring(:,:,1,2,2,1)) - zeropre;post=squeeze(grpring(:,:,1,2,2,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.3])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 5deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,grps+i)%%20 deg
%     pre=squeeze(grpring(:,:,1,4,2,1)) - zeropre;post=squeeze(grpring(:,:,1,4,2,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.3])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 20deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,2*grps+i)%%50 deg
%     pre=squeeze(grpring(:,:,1,7,2,1)) - zeropre;post=squeeze(grpring(:,:,1,7,2,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.3])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 50deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,3*grps+i)%%50 deg
%     pre=squeeze(nanmean(grpring(:,centwin,1,:,2,1),2));post=squeeze(nanmean(grpring(:,centwin,1,:,2,2),2));
%     for j = 1:size(pre,1)
%         pre(j,:) = pre(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,2,1),2),3));
%         post(j,:) = post(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,2,2),2),3));
%     end
%     [hvals pvals] = ttest(pre,post,'alpha',asize);
%     hold on
%     errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
%     errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
%     plot(1:length(radiusRange),hvals-0.7,'b*')
%     axis square
%     axis([0 length(sizes)+1 -0.1 0.3])
%     xlabel('Stim Size (deg)')
%     ylabel(sprintf('%s run',grpnames{i}))
%     set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     
%     figure(f7)%%%stationary spread
%     zeropre = squeeze(nanmean(grpring(:,:,:,1,1,1),3));zeropost = squeeze(nanmean(grpring(:,:,:,1,1,2),3));
%     subplot(4,grps,i)%%5 deg
%     pre=squeeze(grpring(:,:,2,2,1,1)) - zeropre;post=squeeze(grpring(:,:,2,2,1,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.3])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 5deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,grps+i)%%20 deg
%     pre=squeeze(grpring(:,:,2,4,1,1)) - zeropre;post=squeeze(grpring(:,:,2,4,1,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.3])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 20deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,2*grps+i)%%50 deg
%     pre=squeeze(grpring(:,:,2,7,1,1)) - zeropre;post=squeeze(grpring(:,:,2,7,1,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.3])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 50deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,3*grps+i)%%size curves
%     pre=squeeze(nanmean(grpring(:,centwin,2,:,1,1),2));post=squeeze(nanmean(grpring(:,centwin,2,:,1,2),2));
%     for j = 1:size(pre,1)
%         pre(j,:) = pre(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,1,1),2),3));
%         post(j,:) = post(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,1,2),2),3));
%     end
%     [hvals pvals] = ttest(pre,post,'alpha',asize);
%     hold on
%     errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
%     errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
%     plot(1:length(radiusRange),hvals-0.8,'b*')
%     axis square
%     axis([0 length(sizes)+1 -0.1 0.2])
%     xlabel('Stim Size (deg)')
%     ylabel(sprintf('%s sit',grpnames{i}))
%     set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     
%     
%     figure(f8)%%%running spread
%     zeropre = squeeze(nanmean(grpring(:,:,:,1,2,1),3));zeropost = squeeze(nanmean(grpring(:,:,:,1,2,2),3));
%     subplot(4,grps,i)%%5 deg
%     pre=squeeze(grpring(:,:,2,2,2,1)) - zeropre;post=squeeze(grpring(:,:,2,2,2,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.3])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 5deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,grps+i)%%20 deg
%     pre=squeeze(grpring(:,:,2,4,2,1)) - zeropre;post=squeeze(grpring(:,:,2,4,2,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.3])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 20deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,2*grps+i)%%50 deg
%     pre=squeeze(grpring(:,:,2,7,2,1)) - zeropre;post=squeeze(grpring(:,:,2,7,2,2)) - zeropost;
%     hold on
%     shadedErrorBar(0:79,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
%     shadedErrorBar(0:79,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
%     plot([0 10],[0 0],'b:')
%     axis square
%     axis([0 10 -0.05 0.3])
%     xlabel('dist from cent (um)')
%     ylabel(sprintf('%s 50deg',grpnames{i}))
%     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth],'LooseInset',get(gca,'TightInset'),'fontsize',8)
%     subplot(4,grps,3*grps+i)%%50 deg
%     pre=squeeze(nanmean(grpring(:,centwin,2,:,2,1),2));post=squeeze(nanmean(grpring(:,centwin,2,:,2,2),2));
%     for j = 1:size(pre,1)
%         pre(j,:) = pre(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,2,1),2),3));
%         post(j,:) = post(j,:)-squeeze(nanmean(nanmean(grpring(j,centwin,:,1,2,2),2),3));
%     end
%     [hvals pvals] = ttest(pre,post,'alpha',asize);
%     hold on
%     errorbar(1:length(sizes),nanmean(pre),nanstd(pre)/sqrt(numAni),'k')
%     errorbar(1:length(sizes),nanmean(post),nanstd(post)/sqrt(numAni),'r')
%     plot(1:length(radiusRange),hvals-0.5,'b*')
%     axis square
%     axis([0 length(sizes)+1 -0.1 0.5])
%     xlabel('Stim Size (deg)')
%     ylabel(sprintf('%s run',grpnames{i}))
%     set(gca,'xtick',1:length(sizes),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',8)
    
end

figure(f1)
mtit('stationary size curves (pref stim)')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f2)
mtit('running size curves (pref stim)')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f3)
mtit('stationary size curves (all stim)')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f4)
mtit('running size curves (all stim)')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f5)
mtit('stationary pixelwise analysis')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f6)
mtit('running pixelwise analysis')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure(f9)
subplot(1,2,1)
legend(grpnames)
set(gcf,'color','white')
mtit('Baseline response comparison')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

%% stats for baseline comparison

for r = 1:2
    %%%non-parametric test
    [p,tbl,stats] = kruskalwallis(squeeze(grpbase(:,:,r)))

    %%%tukey kramer post-hoc
    [c,m,h,gnames] = multcompare(stats)

    %%%unpaired ttest
    group1 = [1 1 1 2 2 3];
    group2 = [2 3 4 3 4 4];
    sprintf('alpha = %0.4f',0.05/4)
    for i = 1:length(group1)
        grp1 = squeeze(grpbase(:,group1(i),r));grp1 = grp1(~isnan(grp1));
        grp2 = squeeze(grpbase(:,group2(i),r));grp2 = grp2(~isnan(grp2));
        [h,p] = ttest2(grp1,grp2,'alpha',0.05/4);
        sprintf('%s vs %s p = %0.4f',grpnames{group1(i)},grpnames{group2(i)},p)
    end
end

%%

% figure(f5)
% mtit('stationary pixelwise analysis 0.04cpd')
% if exist('psfile','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfile,'-append');
% end
% 
% figure(f6)
% mtit('running pixelwise analysis 0.04cpd')
% if exist('psfile','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfile,'-append');
% end
% 
% figure(f7)
% mtit('stationary pixelwise analysis 0.16cpd')
% if exist('psfile','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfile,'-append');
% end
% 
% figure(f8)
% mtit('running pixelwise analysis 0.16cpd')
% if exist('psfile','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfile,'-append');
% end

% figure;
% hold on
% for i = 1:grps
%     plot(1:length(sizes),grpchange(i,:,1))
% end
% axis([1 length(sizes) -0.5 1])
% axis square
% legend(grpnames)

try
    dos(['ps2pdf ' psfile ' "' [fullfile(grppath,'2pSizeSummary') '.pdf'] '"'] )
catch
    display('couldnt generate pdf');
end

delete(psfile);
    