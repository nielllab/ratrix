%%%comparePatchOnPatch - this scripts compares DOI/Saline groups
close all;clear all;dbstop if error;

deconvplz = 1;

ctlg = 5; %select control group from grpfiles list
expg = 6; %select experimental group

grpfiles = {'SalineNaiveIsoCrossWF'...
            'SalineTrainedIsoCrossWF'...
            'DOINaiveIsoCrossWF'...
            'DOITrainedIsoCrossWF'...
            'SalineIsoCrossWF'...
            'DOIIsoCrossWF'};

grpnames = {'saline naive'...
            'saline trained'...
            'doi naive'...
            'doi trained'...
            'saline'...
            'doi'};

load('C:\patchonpatch16min')
imagerate=10;
cyclength = imagerate*(isi+duration);
timepts = 0:1/imagerate:(2*isi+duration);timepts = timepts - isi;timepts = timepts(1:end-1);
dfrangesit = [-0.01 0.025]; %%%range for imagesc visualization
dfrangerun = [-0.01 0.03]; %%%range for imagesc visualization

if deconvplz
%     base = isi*imagerate-2:isi*imagerate;
    base = 5:isi*imagerate-1;
    peakWindow = 11:20;%peakWindow = isi*imagerate+1:isi*imagerate+3;
    pathname = '\\langevin\backup\widefield\DOIpaper\patchonpatch\decon\';
else
    base = isi*imagerate-2:isi*imagerate;
    peakWindow = 12:21;%peakWindow = isi*imagerate+8:isi*imagerate+10;
    pathname = '\\langevin\backup\widefield\DOIpaper\patchonpatch\nodecon';
end
cd(pathname)

psfile = 'c:\tempPhilWF.ps';
if exist(psfile,'file')==2;delete(psfile);end

%% Figure 1 - pixelwise response
% figure;set(gcf,'color','w');colormap jet
load(grpfiles{ctlg},'grpcyc') %control group
resp = squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,2,:,1,1),4),6),1));
% satisfied=0;
% while satisfied~=1
%     figure;colormap jet
%     imagesc(resp,[-0.01 0.025])
%     title('select back then front')
%     [y x] = ginput(2);
%     x=round(x);y=round(y);
% 
%     theta = -rad2deg(atan((x(1)-x(2))/(y(2)-y(1))));
% 
%     resp2 = imrotate(resp,theta,'crop');
%     centOffset = 100; %effective diameter of circle
%     downsample=1;
%     buf = 0;%20*downsample; %centers brain since it's slightly longer than wide
%     crad = (centOffset*downsample)/2;
%     y0 = round(y(2)-crad+buf*2);x0 = round(x(1)-buf);
%     hold on;plot(y0,x0,'ro')
%     resp2 = resp2(x0-crad:x0+crad,y0-crad:y0+crad);
%     figure;colormap jet
%     imagesc(resp2,[-0.01 0.025])
%     axis off
% 
%     satisfied = input('satisfied? 1=yes, 0=no: ');
% end
% 
% [Y X] = meshgrid(1:size(resp,2),1:size(resp,1));
% circ = sqrt((X-x0).^2 + (Y-y0).^2);
% 
% figure;imagesc(circ>crad)
% 
% resp2=resp;resp2(circ>crad)=0;
% resp2=resp2(x0-crad:x0+crad,y0-crad:y0+crad);
% figure;colormap jet
% imagesc(resp2,[-0.01 0.025])
% axis square; axis off
% 
% 
% resp = resp2
figure;set(gcf,'color','w');colormap jet%subplot(2,2,1)
imagesc(resp,dfrangesit)
axis off
title('saline pre')
figure;set(gcf,'color','w');colormap jet%subplot(2,2,2)
imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,2,:,1,2),4),6),1)),dfrangesit)
axis off
title('saline post')

load(grpfiles{expg},'grpcyc') %control group
figure;set(gcf,'color','w');colormap jet%subplot(2,2,3)
imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,2,:,1,1),4),6),1)),dfrangesit)
axis off
title('DOI pre')
figure;set(gcf,'color','w');colormap jet%subplot(2,2,4)
imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,2,:,1,2),4),6),1)),dfrangesit)
axis off
title('DOI post')

% if exist('psfile','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfile,'-append');
% end


%% Figure 2 - cycle averages and spread
figure;set(gcf,'color','w');
subplot(2,2,1)
load(grpfiles{ctlg},'grptrace','grpring') %control group
ringx = size(grpring,2);pixbin=5;ringxrange=4;%1X obj is 50 microns/pixel
numAni = size(grptrace,1);
pre = squeeze(nanmean(grptrace(:,:,2,:,1,1),4));post = squeeze(nanmean(grptrace(:,:,2,:,1,2),4));
hold on
shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
ylabel('dfof')
xlabel('time(s)')
axis([timepts(1) timepts(end) -0.01 0.07])
axis square
title('saline cyc avg')
set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',12,'tickdir','out')

subplot(2,2,3)
pre = squeeze(nanmean(grpring(:,:,2,:,1,1),4));post = squeeze(nanmean(grpring(:,:,2,:,1,2),4));
hold on
shadedErrorBar(0:ringx-1,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
shadedErrorBar(0:ringx-1,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
ylabel('dfof')
xlabel('distance from cent (um)')
axis([0 ringxrange -0.001 0.04])
set(gca,'xtick',0:1:ringxrange,'xticklabel',0:pixbin*50:ringxrange*pixbin*50,'ytick',0:0.01:0.04)
axis square
title('saline spread')
set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',12,'tickdir','out')

subplot(2,2,2)
load(grpfiles{expg},'grptrace','grpring') %control group
numAni = size(grptrace,1);
pre = squeeze(nanmean(grptrace(:,:,2,:,1,1),4));post = squeeze(nanmean(grptrace(:,:,2,:,1,2),4));
hold on
shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
ylabel('dfof')
xlabel('time(s)')
axis([timepts(1) timepts(end) -0.01 0.07])
axis square
title('DOI cyc avg')
set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',12,'tickdir','out')

subplot(2,2,4)
pre = squeeze(nanmean(grpring(:,:,2,:,1,1),4));post = squeeze(nanmean(grpring(:,:,2,:,1,2),4));
hold on
shadedErrorBar(0:ringx-1,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
shadedErrorBar(0:ringx-1,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
ylabel('dfof')
xlabel('distance from cent (um)')
axis([0 ringxrange -0.001 0.04])
set(gca,'xtick',0:1:ringxrange,'xticklabel',0:pixbin*50:ringxrange*pixbin*50,'ytick',0:0.01:0.04)
axis square
title('DOI spread')
set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',12,'tickdir','out')

% if exist('psfile','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfile,'-append');
% end

%% Figure 3 - all group comparison
grpdiff = nan(10,4); %group difference array for stats 

grpfig=figure;set(gcf,'color','w');
for i = 1:4
    load(grpfiles{i},'grptrace')
    numAni = size(grptrace,1);
    pre = squeeze(nanmean(nanmean(grptrace(:,peakWindow,2,:,1,1),4),2))-squeeze(nanmean(nanmean(grptrace(:,base,2,:,1,1),4),2)); %center only
    post = squeeze(nanmean(nanmean(grptrace(:,peakWindow,2,:,1,2),4),2))-squeeze(nanmean(nanmean(grptrace(:,base,2,:,1,2),4),2)); %center only
%     pre = squeeze(nanmean(nanmean(grptrace(:,peakWindow,4,:,1,1),4),2)); %iso+cross
%     post = squeeze(nanmean(nanmean(grptrace(:,peakWindow,4,:,1,2),4),2)); %iso+cross
    diff = 2*post./(post+pre);
    
%     subplot(1,2,1)
%     hold on
%     plot(i*ones(1,length(diff)),pre,'ko','MarkerSize',8)
%     errorbar(i,mean(pre),std(pre)/numAni,'.k','LineWidth',1,'MarkerSize',24)
%     plot(i*ones(1,length(diff)),post,'ro','MarkerSize',8)
%     errorbar(i,mean(post),std(post)/numAni,'.r','LineWidth',1,'MarkerSize',24)
%     axis([0 5 0 0.1])
%     axis square
%     ylabel('dfof pre(black) post(red)')
%     set(gca,'xtick',1:4,'xticklabel',grpnames(1:4),'LooseInset',get(gca,'TightInset'),'fontsize',12,'tickdir','out')
%     
%     subplot(1,2,2)
    figure(grpfig)
    hold on
    plot(i*ones(1,length(diff)),diff,'ko','MarkerSize',15)
    errorbar(i,mean(diff),std(diff)/numAni,'k.','LineWidth',1,'MarkerSize',20)
        
    [h,p] = ttest(pre,post);
    sprintf('%s p=%0.4f',grpfiles{i},p)
    
    grpdiff(1:numAni,i) = diff;
    
    figure;
    for j = 1:numAni
        subplot(2,3,j)
        pre = squeeze(nanmean(grptrace(j,:,2,:,1,1),4));
        post = squeeze(nanmean(grptrace(j,:,2,:,1,2),4));
        hold on
        plot(timepts,pre,'k')
        plot(timepts,post,'r')
        ylabel('dfof')
        xlabel('time(s)')
        axis([timepts(1) timepts(end) -0.05 0.1])
        axis square
    end
    mtit(sprintf('%s',grpnames{i}))
end

figure(grpfig)
plot(0:5,ones(1,6),':','Color',[0.5 0.5 0.5])
axis([0 5 0 2])
axis square
ylabel('post/(pre+post)')
set(gca,'xtick',1:4,'xticklabel',grpnames(1:4),'ytick',0:0.5:2,'fontsize',12,'tickdir','out')

% if exist('psfile','var')
%     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%     print('-dpsc',psfile,'-append');
% end

%% stats for group analysis
%%%non-parametric test
[p,tbl,stats] = kruskalwallis(grpdiff)

%%%tukey kramer post-hoc
[c,m,h,gnames] = multcompare(stats)

%%%unpaired ttest
group1 = [1 1 1 2 2 3];
group2 = [2 3 4 3 4 4];
sprintf('alpha = %0.4f',0.05/4)
for i = 1:length(group1)
    grp1 = grpdiff(:,group1(i));grp1 = grp1(~isnan(grp1));
    grp2 = grpdiff(:,group2(i));grp2 = grp2(~isnan(grp2));
    [h,p] = ttest2(grp1,grp2,'alpha',0.05/4);
    sprintf('%s vs %s p = %0.4f',grpnames{group1(i)},grpnames{group2(i)},p)
end
        

%% save pdf

try
    dos(['ps2pdf ' psfile ' "' 'comparePatchOnPatch.pdf' '"'])
catch
    display('couldnt generate pdf');
end

delete(psfile);