%This code plots averages over animals for size select stimulus
%It takes in the output files of analyzeSizeSelectGroup
%PRLP 02/01/2016 Niell Lab

plotrange = 5:9;
psfilename = 'c:\tempPhilWF.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

% load('C:\mapoverlay.mat');
% % xpts = xpts/4;
% % ypts = ypts/4;
% moviename = 'C:\sizeSelect2sf8sz26min.mat';
% load(moviename);
% imagerate=10;
% acqdurframes = imagerate*(isi+duration);
% timepts = [1:acqdurframes+acqdurframes/2]*0.1;
% % pointsfile = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\GroupSizeSelectPoints';
% % load(pointsfile);
% areas = {'V1','P','LM','AL','RL','AM','PM'};
% behavState = {'stationary','running'};
% ncut = 2;
% trials = length(sf)-ncut;
% sizeVals = [0 5 10 20 30 40 50 60];
% sf=sf(1:trials);contrasts=contrasts(1:trials);phase=phase(1:trials);radius=radius(1:trials);
% order=order(1:trials);tf=tf(1:trials);theta=theta(1:trials);xpos=xpos(1:trials);
% contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
% for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
% for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end

% % %plotting

%%%individual animal plots
cnt=1;
for i=1:numAni
    figure
    subplot(2,2,1)
    plot(1:length(sizes),squeeze(nanmean(allpeakspre(:,:,:,1,1,i),1)))
    legend(contrastlist,'location','northwest')
    axis([1 8 0 0.2])
    set(gca,'xtick',sizeVals,'xticklabel',sizes)
    ylabel('pre sit')
    axis square
    
    subplot(2,2,2)
    plot(1:length(sizes),squeeze(nanmean(allpeakspre(:,:,:,2,1,i),1)))
    legend(contrastlist,'location','northwest')
    axis([1 8 0 0.2])
    set(gca,'xtick',sizeVals,'xticklabel',sizes)
    ylabel('pre run')
    axis square
    
    subplot(2,2,3)
    plot(1:length(sizes),squeeze(nanmean(allpeakspost(:,:,:,1,1,i),1)))
    legend(contrastlist,'location','northwest')
    axis([1 8 0 0.2])
    set(gca,'xtick',sizeVals,'xticklabel',sizes)
    ylabel('post sit')
    axis square
    
    subplot(2,2,4)
    plot(1:length(sizes),squeeze(nanmean(allpeakspost(:,:,:,2,1,i),1)))
    legend(contrastlist,'location','northwest')
    axis([1 8 0 0.2])
    set(gca,'xtick',sizeVals,'xticklabel',sizes)
    ylabel('post run')
    axis square
    
    mtit(sprintf('%s %s V1 peaks',files(use(cnt)).subj,files(use(cnt)).inject))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
    cnt=cnt+2;
end

%%%plot of group data for response to sizes for contrast vs. dfof
figure
subplot(2,2,1)
plot(1:length(sizes),squeeze(nanmean(allpeakspre(:,:,:,1,1,i),1)))
legend(contrastlist,'location','northwest')
axis([1 8 0 0.2])
set(gca,'xtick',sizeVals,'xticklabel',sizes)
ylabel('pre sit')
axis square

subplot(2,2,2)
plot(1:length(sizes),squeeze(nanmean(allpeakspre(:,:,:,2,1,i),1)))
legend(contrastlist,'location','northwest')
axis([1 8 0 0.2])
set(gca,'xtick',sizeVals,'xticklabel',sizes)
ylabel('pre run')
axis square

subplot(2,2,3)
plot(1:length(sizes),squeeze(nanmean(allpeakspost(:,:,:,1,1,i),1)))
legend(contrastlist,'location','northwest')
axis([1 8 0 0.2])
set(gca,'xtick',sizeVals,'xticklabel',sizes)
ylabel('post sit')
axis square

subplot(2,2,4)
plot(1:length(sizes),squeeze(nanmean(allpeakspost(:,:,:,2,1,i),1)))
legend(contrastlist,'location','northwest')
axis([1 8 0 0.2])
set(gca,'xtick',sizeVals,'xticklabel',sizes)
ylabel('post run')
axis square

mtit('V1 Contrast Functions')
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

%manual peaks
limits = [0.2,..];
for j = 1:2
    figure
    for m = 1:length(areas)
        subplot(2,length(areas)/2,m)
        hold on
        errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(allpeakspre(:,end,:,j,m,:),1),6)),squeeze(nanstd(nanmean(allpeakspre(:,end,:,j,m,:),1),6))/sqrt(numAni),'k.-')
        errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(allpeakspost(:,end,:,j,m,:),1),6)),squeeze(nanstd(nanmean(allpeakspost(:,end,:,j,m,:),1),6))/sqrt(numAni),'r.-')
        set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
        xlabel('radius (deg)')
        ylabel(sprintf('%s',areas{m}))
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'))
        xlabel off
        axis([1 length(radiusRange) -0.1*limits(m) limits(m)])
%         legend('pre','post')
    end
    mtit(sprintf('%s Manual Peaks',behavState{j}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end   
end

% %peaks from autofind
for j = 1:2
    figure
    for m = 1:length(areas)-1
        subplot(2,length(areas)/2,m)
        hold on
        errorbar(1:length(radiusRange),squeeze(nanmean(allareapeakspre(end,:,j,m,:),5)),squeeze(nanstd(allareapeakspre(end,:,j,m,:),5))/sqrt(numAni),'ko')
        errorbar(1:length(radiusRange),squeeze(nanmean(allareapeakspost(end,:,j,m,:),5)),squeeze(nanstd(allareapeakspost(end,:,j,m,:),5))/sqrt(numAni),'ro')
        set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
        xlabel('radius (deg)')
        ylabel(sprintf('%s',areas{m}))
        axis square
%         axis([1 length(radiusRange) 0 0.1])
%         legend('pre','post')
    end
    mtit(sprintf('%s Autofind Peaks',behavState{j}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end   
end


%spread of points above half max
for j = 1:2
    figure
    for m = 1:length(areas)-1
        subplot(2,length(areas)/2,m)
        hold on
        errorbar(1:length(radiusRange),squeeze(nanmean(allhalfMaxpre(end,:,j,m,:),5)),squeeze(nanstd(allhalfMaxpre(end,:,j,m,:),5))/sqrt(numAni),'ko')
        errorbar(1:length(radiusRange),squeeze(nanmean(allhalfMaxpost(end,:,j,m,:),5)),squeeze(nanstd(allhalfMaxpost(end,:,j,m,:),5))/sqrt(numAni),'ro')
        set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
        xlabel('radius (deg)')
        ylabel(sprintf('%s',areas{m}))
        axis square
%         axis([1 length(radiusRange) 0 2500])
%         legend('pre','post')
    end
    mtit(sprintf('%s area above half max',behavState{j}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end   
end

%average mean dfof per area
for j = 1:2
    figure
    for m = 1:length(areas)-1
        subplot(2,length(areas)/2,m)
        hold on
        errorbar(1:length(radiusRange),squeeze(nanmean(allareameanspre(end,:,j,m,:),5)),squeeze(nanstd(allareameanspre(end,:,j,m,:),5))/sqrt(numAni),'ko')
        errorbar(1:length(radiusRange),squeeze(nanmean(allareameanspost(end,:,j,m,:),5)),squeeze(nanstd(allareameanspost(end,:,j,m,:),5))/sqrt(numAni),'ro')
        set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
        xlabel('radius (deg)')
        ylabel(sprintf('%s',areas{m}))
        axis square
%         axis([1 length(radiusRange) 0 2500])
%         legend('pre','post')
    end
    mtit(sprintf('%s mean dfof per area',behavState{j}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end   
end

%average x/y sigma from gaussian
for j = 1:2
    figure
    for m = 1:length(areas)-1
        subplot(2,length(areas)/2,m)
        hold on
        gaupremean = (allgauParamspre(end,:,j,m,4,:)+allgauParamspre(end,:,j,m,5,:))/2;
        gaupostmean = (allgauParamspost(end,:,j,m,4,:)+allgauParamspost(end,:,j,m,5,:))/2;
        hold on
        errorbar(1:length(radiusRange),squeeze(nanmean(gaupremean,6)),squeeze(nanstd(gaupremean,6))/sqrt(numAni),'ko')
        errorbar(1:length(radiusRange),squeeze(nanmean(gaupostmean,6)),squeeze(nanstd(gaupostmean,6))/sqrt(numAni),'ro')
        set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
        xlabel('radius (deg)')
        ylabel(sprintf('%s',areas{m}))
        axis square
        axis([1 length(radiusRange) 0 20])
%         legend('pre','post')
    end
    mtit(sprintf('%s Sigma from Gaussian',behavState{j}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end


%plot activity maps for the different contrasts/running, with rows=radius
for j = 1:2
    figure
    cnt=1;
    for k=1:length(radiusRange)
        for l=plotrange
            subplot(length(radiusRange),length(plotrange),cnt)
            imagesc(squeeze(nanmean(nanmean(alltrialcycavgpre(:,:,l,:,end,k,j,:),4),8)),[0 0.1])
            colormap(jet)
            axis square
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            cnt=cnt+1;
        end
    end
    mtit(sprintf('PRE %s %s contrast row=size',behavState{j}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end
for j = 1:2
    figure
    cnt=1;
    for k=1:length(radiusRange)
        for l=plotrange
            subplot(length(radiusRange),length(plotrange),cnt)
            imagesc(squeeze(nanmean(nanmean(alltrialcycavgpost(:,:,l,:,end,k,j,:),4),8)),[0 0.1])
            colormap(jet)
            axis square
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            cnt=cnt+1;
        end
    end
    mtit(sprintf('POST %s %s contrast row=size',behavState{j}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end

xstim = [acqdurframes/2-1 acqdurframes/2-1];
ystim = [-0.1 0.5];
% for m = 1:length(areas)
for i=1:2
    figure
    cnt=1;
    for k=1:length(radiusRange)
        subplot(2,4,cnt)
        hold on
        shadedErrorBar(timepts,squeeze(nanmean(nanmean(alltracespre(1,:,:,end,k,i,:),3),7)),squeeze(nanstd(nanmean(alltracespre(1,:,:,end,k,i,:),3),7))/sqrt(numAni),'-k',1)
        shadedErrorBar(timepts,squeeze(nanmean(nanmean(alltracespost(1,:,:,end,k,i,:),3),7)),squeeze(nanstd(nanmean(alltracespost(1,:,:,end,k,i,:),3),7))/sqrt(numAni),'-r',1)
        plot(xstim,ystim,'g-')
        set(gca,'LooseInset',get(gca,'TightInset'))
        axis([0 max(timepts) -0.05 0.2])
        legend(sprintf('%s deg',sizes{k}),'Location','northoutside')
        hold off
        cnt=cnt+1;
    end
    mtit(sprintf('V1 %s',behavState{i}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end
% end

%%get percent time running
figure
hold on
plot([ones(1,length(allmvpre)) 2*ones(1,length(allmvpre))],[allmvpre allmvpost],'ko')
errorbar([1 2],[nanmean(allmvpre,2) nanmean(allmvpost,2)],[nanstd(allmvpre,2)/sqrt(numAni) nanstd(allmvpost,2)/sqrt(numAni)]);
ylabel('fraction running')
ylim([0 1]);
set(gca,'xtick',[1 2],'xticklabel',{'Pre','Post'})
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

try
    dos(['ps2pdf ' psfilename ' "' [filename '.pdf'] '"'])

catch
    display('couldnt generate pdf');
end



%%old code

% % %peaks from autofind
% for m = 1:length(areas)
%     figure
%     cnt=0;
%     for j = 1:2
%         for i = 1:length(contrastRange)
%             cnt = cnt+1;
%             subplot(2,length(contrastRange),cnt)
%             hold on
%             errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(avgareapeakspre(:,:,i,:,j,m),1),2)),squeeze(nanmean(nanmean(seareapeakspre(:,:,i,:,j,m),1),2)),'ko')
%             errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(avgareapeakspost(:,:,i,:,j,m),1),2)),squeeze(nanmean(nanmean(seareapeakspost(:,:,i,:,j,m),1),2)),'ro')
%             set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
%             xlabel('radius (deg)')
%             ylabel('dfof')
%             axis square
%             axis([1 length(radiusRange) 0 0.1])
%             legend(sprintf('%s contrast %s',contrastlist{i},behavState{j}),'Location','northoutside')
%         end
%     end
%     mtit(sprintf('%s Auto Peaks',areas{m}))
%     if exist('psfilename','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfilename,'-append');
%     end   
% end
% 
% 
% %spread of points above half max
% for m = 1:length(areas)
%     figure
%     cnt=0;
%     for j = 1:2
%         for i = 1:length(contrastRange)
%             cnt = cnt+1;
%             subplot(2,length(contrastRange),cnt)
%             hold on
%             errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(avghalfMaxpre(:,:,i,:,j,m),1),2)),squeeze(nanmean(nanmean(sehalfMaxpre(:,:,i,:,j,m),1),2)),'ko')
%             errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(avghalfMaxpost(:,:,i,:,j,m),1),2)),squeeze(nanmean(nanmean(sehalfMaxpost(:,:,i,:,j,m),1),2)),'ro')
%             set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
%             xlabel('radius (deg)')
%             ylabel('dfof')
%             axis square
%             axis([1 length(radiusRange) 0 25000])
%             legend(sprintf('%s contrast %s',contrastlist{i},behavState{j}),'Location','northoutside')
%         end
%     end
%     mtit(sprintf('%s Area Above Half Max',areas{m}))
%     if exist('psfilename','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfilename,'-append');
%     end   
% end
% 
% 
% %average x/y sigma from gaussian
% for m = 1:length(areas)
%     figure
%     cnt=0;
%     for j = 1:2
%         for i = 1:length(contrastRange)
%             cnt = cnt+1;
%             subplot(2,length(contrastRange),cnt)
%             gaupremean = squeeze(nanmean(nanmean(avggauParamspre(:,:,i,:,j,m,4),1),2))+...
%                 squeeze(nanmean(nanmean(avggauParamspre(:,:,i,:,j,m,5),1),2))/2;
%             gaupresem = squeeze(nanmean(nanmean(segauParamspre(:,:,i,:,j,m,4),1),2))+...
%                 squeeze(nanmean(nanmean(segauParamspre(:,:,i,:,j,m,5),1),2))/2;
%             gaupostmean = squeeze(nanmean(nanmean(avggauParamspost(:,:,i,:,j,m,4),1),2))+...
%                 squeeze(nanmean(nanmean(avggauParamspost(:,:,i,:,j,m,5),1),2))/2;
%             gaupostsem = squeeze(nanmean(nanmean(segauParamspost(:,:,i,:,j,m,4),1),2))+...
%                 squeeze(nanmean(nanmean(segauParamspost(:,:,i,:,j,m,5),1),2))/2;
%                 hold on
%                 errorbar(1:length(radiusRange),gaupremean,gaupresem,'ko')
%                 errorbar(1:length(radiusRange),gaupostmean,gaupostsem,'ro')
%                 set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
%             xlabel('radius (deg)')
%             ylabel('dfof')
%             axis square
%             axis([1 length(radiusRange) 0 50])
%             legend(sprintf('%s contrast %s',contrastlist{i},behavState{j}),'Location','northoutside')
%         end
%     end
%     mtit(sprintf('%s Sigma from Gaussian',areas{m}))
%     if exist('psfilename','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfilename,'-append');
%     end
% end


% %%get peak response - baseline for all conditions
%     peakspre = nan(length(xrange),length(radiusRange),length(sfrange),length(tfrange));
%     peakspost = nan(length(xrange),length(radiusRange),length(sfrange),length(tfrange));
%     for i = 1:length(xrange)
%         for j = 1:length(radiusRange)
%             for k = 1:length(sfrange)
%                 for l = 1:length(tfrange)
%                     peakspre(i,j,k,l) = mean(avgtrialcycpre(y(1),x(1),12,find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l))),4);%-...
%                         %mean(avgtrialcycpre(y(1),x(1),5,find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l))),4);
%                     peakspost(i,j,k,l) = mean(avgtrialcycpost(y(1),x(1),12,find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l))),4);%-...
%                         %mean(avgtrialcycpost(y(1),x(1),5,find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l))),4);
%                 end
%             end
%         end
%     end

% [fname pname] = uigetfile('*.mat','points file');
% if fname~=0
%     load(fullfile(pname, fname));
% else
%     figure
%     imagesc(squeeze(mean(mean(avgtrialcycavgpre(:,:,12,1,3,:,:),6),7)),[0 0.05])
%     colormap(jet);
%     hold on; plot(ypts,xpts,'w.','Markersize',2)
%     axis square
%     [x y] = ginput(7);
%     x = round(x);y = round(y);
%     close(gcf);
%     [fname pname] = uiputfile('*.mat','save points?');
%     if fname~=0
%         save(fullfile(pname,fname),'x','y');
%     end
% end
% 
% for i=1:length(sfrange)
%         for j=1:length(tfrange)
%             figure
%             cnt=1;
%             for k=1:length(radiusRange)
%                 subplot(2,3,cnt)
%                 hold on
%                 shadedErrorBar([1:30]',squeeze(mean(avgtrialcycpre(y(1),x(1),:,find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j))),4)),...
%                     squeeze(mean(setrialcycpre(y(1),x(1),:,find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j))),4))/...
%                     sqrt(length(find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j)))),'-k',1)
%                 shadedErrorBar([1:30]',squeeze(mean(avgtrialcycpost(y(1),x(1),:,find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j))),4)),...
%                     squeeze(mean(setrialcycpost(y(1),x(1),:,find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j))),4))/...
%                     sqrt(length(find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j)))),'-r',1)
%                 plot(xstim,ystim,'g-')
%                 set(gca,'LooseInset',get(gca,'TightInset'))
%                 axis([1 30 -0.05 0.5])
%                 legend(sprintf('%0.0frad',radiusRange(k)))
%                 hold off
%                 cnt=cnt+1;
%              end
%             mtit(sprintf('group %0.2fsf %0.0ftf',sfrange(i),tfrange(j)))
%             if exist('psfilename','var')
%                 set(gcf, 'PaperPositionMode', 'auto');
%                 print('-dpsc',psfilename,'-append');
%             end
%         end
%     end