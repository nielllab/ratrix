%%%loads in individual animal 2p size select data and performs group
%%%analysis
close all
clear all

%%choose dataset
batchPhil2pSizeSelect

path = '\\langevin\backup\twophoton\Phil\Compiled2p\'

psfile = 'c:\tempPhil2p.ps';
if exist(psfile,'file')==2;delete(psfile);end

cd(path);

group = input('which group? 1=saline naive, 2=saline trained, 3=DOI naive, 4=DOI trained: ')
redoani = input('reanalyze individual animal data? 0=no, 1=yes: ')
redogrp = input('reanalyze group data? 0=no, 1=yes: ')

if group==1
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'SalineNaive2pSizeSelectGrats'
elseif group==2
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'SalineTrained2pSizeSelectGrats'
elseif group==3
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOINaive2pSizeSelectGrats'
elseif group==4
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOITrained2pSizeSelectGrats'
else
    sprintf('please restart and choose a number 1-4')
end

if isempty(use)
    sprintf('No animals in this group')
    return
end

if redoani==1
    patchOri2pAnalysis
    sizeSelect2pAnalysisGrats
end

%%%plotting
numAni = length(use)/2;
dfWindow = 9:11;
spWindow = 6:10;
dt = 0.1;
cyclelength = 1/0.1;
respthresh=0.025;
dpix = 0.8022; centrad = 10; ycent = 72/2; xcent = 128/2; %%deg/pix, radius of response size cutoff, x and y screen centers
moviefname = 'C:\sizeSelect2sf8sz26min.mat';
load(moviefname)
sizeVals = [0 5 10 20 30 40 50 60];
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end
thetamod = mod(theta,pi)-pi/8;
thetaQuad = zeros(1,length(theta)); %break orientation into quadrants, 1=top,2=right,3=bot,4=left, offset pi/8 CCW
thetaQuad(1,find(-pi/8<thetamod&thetamod<=pi/8))=1;
thetaQuad(1,find(pi/8<=thetamod&thetamod<=3*pi/8))=2;
thetaQuad(1,find(3*pi/8<=thetamod&thetamod<=5*pi/8))=3;
thetaQuad(1,find(5*pi/8<=thetamod&thetamod<=7*pi/8))=4;
thetaRange = unique(thetaQuad);
dirrange = 0:pi/6:2*pi-pi/6;
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;
timepts = timepts - isi;

%%%load individual animal data intro group arrays for analysis/plotting
if redogrp
    cnt=1;
    cellcnt=1;
    grprf=nan(10000,2);
    session = nan(10000,1);%%%make an array for animal #/session
    grpdfsize = nan(10000,15,length(contrastlist),length(sizes),2,2);
    grpdfsizebest = grpdfsize;
    grpdfgrat = nan(10000,15,2,2);
    grposi = nan(10000,2,2);
    grpdsi = nan(10000,2,2);
    grpdfori = nan(10000,12,2,2);
    for i= 1:2:length(use)
        sprintf('loading %s out of %s sessions',num2str(i),num2str(length(use)))
        aniFile = files(use(i)).sizeanalysis
        load(aniFile,'dfgrat','dfsize','dfsizebest','userf','sizecurve','useosi','usedsi','usedfori')
        expcells = size(userf,1)-1;
        grprf(cellcnt:cellcnt+expcells,:) = userf;
        session(cellcnt:cellcnt+expcells) = (i+1)/2;
        grpdfsize(cellcnt:cellcnt+expcells,:,:,:,:,1) = dfsize; %cell#,t,contr,size,run,pre/post
        grpdfsizebest(cellcnt:cellcnt+expcells,:,:,:,:,1) = dfsizebest; %cell#,t,contr,size,run,pre/post
        grpdfgrat(cellcnt:cellcnt+expcells,:,:,1) = dfgrat; %cell#,t,run,pre/post
        grposi(cellcnt:cellcnt+expcells,:,1) = useosi; %osi,pre/post
        grpdsi(cellcnt:cellcnt+expcells,:,1) = usedsi; %dsi,pre/post
        grpdfori(cellcnt:cellcnt+expcells,:,:,1) = usedfori; %cell#,12 dirs, pre/post
        sprintf('loading %s out of %s files',num2str(i+1),num2str(length(use)))
        aniFile = files(use(i+1)).sizeanalysis
        load(aniFile,'dfsize','dfsizebest','userf','sizecurve','usecells')
        grpdfsize(cellcnt:cellcnt+expcells,:,:,:,:,2) = dfsize; %cell#,t,contr,size,run,pre/post
        grpdfsizebest(cellcnt:cellcnt+expcells,:,:,:,:,2) = dfsizebest; %cell#,t,contr,size,run,pre/post
        aniFile = files(use(i+1)).gratinganalysis
        load(aniFile,'dfgrat','osi','dsi','dfori')
        grposi(cellcnt:cellcnt+expcells,:,2) = osi(usecells,:); %osi,pre/post
        grpdsi(cellcnt:cellcnt+expcells,:,2) = dsi(usecells,:); %dsi,pre/post
        grpdfori(cellcnt:cellcnt+expcells,:,:,2) = dfori(usecells,:,:); %cell#,12 dirs, pre/post
        grpdfgrat(cellcnt:cellcnt+expcells,:,:,2) = dfgrat(usecells,:,:);%cell#,t,run,pre/post
        grpusecells(cellcnt:cellcnt+expcells) = usecells;
        cellcnt=cellcnt+expcells;
    end
    
    grprf = grprf(1:cellcnt,:);
    session = session(1:cellcnt);
    grpdfsize = grpdfsize(1:cellcnt,:,:,:,:,:); %cell#,t,contr,size,run,pre/post
    grpdfsizebest = grpdfsizebest(1:cellcnt,:,:,:,:,:); %cell#,t,contr,size,run,pre/post
    grpdfgrat = grpdfgrat(1:cellcnt,:,:,:); %cell#,t,run,pre/post
    grposi = grposi(1:cellcnt,:,:); %osi,pre/post
    grpdsi = grpdsi(1:cellcnt,:,:); %dsi,pre/post
    grpdfori = grpdfori(1:cellcnt,:,:,:); %cell#,12 dirs, pre/post
    
    sprintf('saving group file...')
    save(grpfilename,'grprf','session','grpdfsize','grpdfsizebest','grpdfgrat','grposi','grpdsi','grpdfori','grpusecells')
    sprintf('done')
else
    sprintf('loading data')
    load(grpfilename)
end

% %%%quantify fraction responsive to each size based on grat params
% figure
% for i=1:length(sizes)
%     subplot(2,4,i)
%     preresp = find(squeeze(nanmean(grpdfsize(:,dfWindow,end,i,1,1),2))>=0.1);
%     postresp = find(squeeze(nanmean(grpdfsize(:,dfWindow,end,i,1,2),2))>=0.1);
%     bothresp = intersect(preresp,postresp);
%     totcells = sum(~isnan(grprf(:,1)));
%     fractions = [length(preresp)/totcells length(postresp)/totcells length(bothresp)/totcells];
%     hold on
%     bar(1,fractions(1),'g')
%     bar(2,fractions(2),'r')
%     bar(3,fractions(3),'b')
%     set(gca,'xtick',[1 2 3],'xticklabel',{'pre','post','both'},'fontsize',5)
%     axis([0 4 0 1])
%     ylabel('%responsive')
%     set(gca,'LooseInset',get(gca,'TightInset'))
% end
% mtit('Responsive cells/size (grat params)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% % %%%quantify fraction responsive to each size based on size params
% % figure
% % for i=1:length(sizes)
% %     subplot(2,4,i)
% %     preresp = find(squeeze(nanmean(grpdfsizebest(:,dfWindow,end,i,1,1),2))>=0.1);
% %     postresp = find(squeeze(nanmean(grpdfsizebest(:,dfWindow,end,i,1,2),2))>=0.1);
% %     bothresp = intersect(preresp,postresp);
% %     totcells = sum(~isnan(grprf(:,1)));
% %     fractions = [length(preresp)/totcells length(postresp)/totcells length(bothresp)/totcells];
% %     hold on
% %     bar(1,fractions(1),'g')
% %     bar(2,fractions(2),'r')
% %     bar(3,fractions(3),'b')
% %     set(gca,'xtick',[1 2 3],'xticklabel',{'pre','post','both'},'fontsize',5)
% %     axis([0 4 0 1])
% %     ylabel('%responsive')
% %     set(gca,'LooseInset',get(gca,'TightInset'))
% % end
% % mtit('Responsive cells for each size (size params)')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% 
% %%%plot responsive cells for each size (grat params)
% figure
% for i=1:length(sizes)
%     subplot(2,4,i)
%     preresp = find(squeeze(nanmedian(grpdfsize(:,dfWindow,end,i,1,1),2))>=0.1);
%     postresp = find(squeeze(nanmedian(grpdfsize(:,dfWindow,end,i,1,2),2))>=0.1);
%     hold on
%     p1 = plot(grprf(:,2),grprf(:,1),'.','color',[0.5 0.5 0.5],'MarkerSize',8); %%% the rfAmp criterion wasn't being applied here
%     p2 = plot(grprf(preresp,2),grprf(preresp,1),'g.','MarkerSize',8);
%     p3 = plot(grprf(postresp,2),grprf(postresp,1),'r.','MarkerSize',8);
%     p4 = plot(grprf(intersect(preresp,postresp),2),grprf(intersect(preresp,postresp),1),'b.','MarkerSize',8);
%     circle(ycent,xcent,sizeVals(i)/2/dpix)
%     axis equal;
%     axis([0 72 0 128]);
%     set(gca,'xticklabel','','yticklabel','')
%     hold off
%     set(gca,'LooseInset',get(gca,'TightInset'))
% %     if i==8
% %         legend([p1 p2 p3 p4],'all cells','pre only','post only','both pre/post','Location','northoutside')
% %     end
% end
% mtit('Stationary responsive cells/size (grat params)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% % %%%plot responsive cells for each size for group data
% % figure
% % for i=1:length(sizes)
% %     subplot(2,4,i)
% %     preresp = find(squeeze(nanmedian(grpdfsizebest(:,dfWindow,end,i,1,1),2))>=0.1);
% %     postresp = find(squeeze(nanmedian(grpdfsizebest(:,dfWindow,end,i,1,2),2))>=0.1);
% %     hold on
% %     p1 = plot(grprf(:,2),grprf(:,1),'.','color',[0.5 0.5 0.5],'MarkerSize',8); %%% the rfAmp criterion wasn't being applied here
% %     p2 = plot(grprf(preresp,2),grprf(preresp,1),'g.','MarkerSize',8);
% %     p3 = plot(grprf(postresp,2),grprf(postresp,1),'r.','MarkerSize',8);
% %     p4 = plot(grprf(intersect(preresp,postresp),2),grprf(intersect(preresp,postresp),1),'b.','MarkerSize',8);
% %     circle(ycent,xcent,sizeVals(i)/2/dpix)
% %     axis equal;
% %     axis([0 72 0 128]);
% %     set(gca,'xticklabel','','yticklabel','')
% %     hold off
% %     set(gca,'LooseInset',get(gca,'TightInset'))
% % %     if i==8
% % %         legend([p1 p2 p3 p4],'all cells','pre only','post only','both pre/post','Location','northoutside')
% % %     end
% % end
% % mtit('Responsive cells for each size (size params)')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% 
% %%%%plots by cells across all animals
% %%%plot osi/dsi
% figure
% subplot(1,2,1)
% hold on
% plot([1 2],[grposi(:,1,1) grposi(:,1,2)],'.','color',[0.8 0.8 0.8],'Markersize',5)
% errorbar([1 2],[nanmean(grposi(:,1,1)) nanmean(grposi(:,1,2))],...
%     [nanstd(grposi(:,1,1))/sqrt(numAni) nanstd(grposi(:,1,2))/sqrt(numAni)],'r')
% axis([0 3 0 1])
% set(gca,'xtick',[1 2],'xticklabel',{'pre','post'})
% ylabel('OSI')
% axis square
% set(gca,'LooseInset',get(gca,'TightInset'))
% hold off
% subplot(1,2,2)
% hold on
% plot([1 2],[grpdsi(:,1,1) grpdsi(:,1,2)],'.','color',[0.8 0.8 0.8],'Markersize',5)
% errorbar([1 2],[nanmean(grpdsi(:,1,1)) nanmean(grpdsi(:,1,2))],...
%     [nanstd(grpdsi(:,1,1))/sqrt(numAni) nanstd(grpdsi(:,1,2))/sqrt(numAni)],'r')
% axis([0 3 0 1])
% set(gca,'xtick',[1 2],'xticklabel',{'pre','post'})
% ylabel('DSI')
% axis square
% set(gca,'LooseInset',get(gca,'TightInset'))
% hold off
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% %%%plot size suppression curves gratings params
% figure
% hold on
% pre = squeeze(nanmedian(nanmean(grpdfsize(:,dfWindow,:,:,1,1),2),1));
% post = squeeze(nanmedian(nanmean(grpdfsize(:,dfWindow,:,:,1,2),2),1));
% subplot(2,2,1)
% plot(1:length(radiusRange),pre,'-o','Markersize',5)
% xlabel('Stim Size (deg)')
% ylabel('pre sit dfof')
% axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% subplot(2,2,2)
% plot(1:length(radiusRange),post,'-o','Markersize',5)
% xlabel('Stim Size (deg)')
% ylabel('post sit dfof')
% axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% 
% pre = squeeze(nanmedian(nanmean(grpdfsize(:,dfWindow,:,:,2,1),2),1));
% post = squeeze(nanmedian(nanmean(grpdfsize(:,dfWindow,:,:,2,2),2),1));
% subplot(2,2,3)
% plot(1:length(radiusRange),pre,'-o','Markersize',5)
% xlabel('Stim Size (deg)')
% ylabel('pre run dfof')
% axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% subplot(2,2,4)
% plot(1:length(radiusRange),post,'-o','Markersize',5)
% xlabel('Stim Size (deg)')
% ylabel('post run dfof')
% axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% mtit('Size Suppression Curve (grat params)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% % %%%plot size suppression curves size params
% % figure
% % hold on
% % pre = squeeze(nanmedian(nanmean(grpdfsizebest(:,dfWindow,:,:,1,1),2),1));
% % post = squeeze(nanmedian(nanmean(grpdfsizebest(:,dfWindow,:,:,1,2),2),1));
% % subplot(2,2,1)
% % plot(1:length(radiusRange),pre,'-o','Markersize',5)
% % xlabel('Stim Size (deg)')
% % ylabel('pre sit dfof')
% % axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% % axis square
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% % subplot(2,2,2)
% % plot(1:length(radiusRange),post,'-o','Markersize',5)
% % xlabel('Stim Size (deg)')
% % ylabel('post sit dfof')
% % axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% % axis square
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% % 
% % pre = squeeze(nanmedian(nanmean(grpdfsizebest(:,dfWindow,:,:,2,1),2),1));
% % post = squeeze(nanmedian(nanmean(grpdfsizebest(:,dfWindow,:,:,2,2),2),1));
% % subplot(2,2,3)
% % plot(1:length(radiusRange),pre,'-o','Markersize',5)
% % xlabel('Stim Size (deg)')
% % ylabel('pre run dfof')
% % axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% % axis square
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% % subplot(2,2,4)
% % plot(1:length(radiusRange),post,'-o','Markersize',5)
% % xlabel('Stim Size (deg)')
% % ylabel('post run dfof')
% % axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% % axis square
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% % mtit('Size Suppression Curve (size params)')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% 
% %%%plot cycle averages (grat params)
% figure
% for i = 1:length(sizes)
%     subplot(2,4,i)
%     hold on
%     shadedErrorBar(timepts,squeeze(nanmedian(grpdfsize(:,:,end,i,1,1),1)),...
%         squeeze(nanstd(grpdfsize(:,:,end,i,1,1),1))/sqrt(totcells),'k',1)
%     shadedErrorBar(timepts,squeeze(nanmedian(grpdfsize(:,:,end,i,1,2),1)),...
%         squeeze(nanstd(grpdfsize(:,:,end,i,1,2),1))/sqrt(totcells),'r',1)
%     axis square
%     axis([timepts(1) timepts(end) -0.01 0.25])
%     set(gca,'LooseInset',get(gca,'TightInset'))
% end
% mtit('Stationary response/size (grat params)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% figure
% for i = 1:length(sizes)
%     subplot(2,4,i)
%     hold on
%     shadedErrorBar(timepts,squeeze(nanmedian(grpdfsize(:,:,end,i,2,1),1)),...
%         squeeze(nanstd(grpdfsize(:,:,end,i,1,1),1))/sqrt(totcells),'k',1)
%     shadedErrorBar(timepts,squeeze(nanmedian(grpdfsize(:,:,end,i,2,2),1)),...
%         squeeze(nanstd(grpdfsize(:,:,end,i,1,2),1))/sqrt(totcells),'r',1)
%     axis square
%     axis([timepts(1) timepts(end) -0.01 0.25])
%     set(gca,'LooseInset',get(gca,'TightInset'))
% end
% mtit('Running response/size (grat params)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% % %%%plot cycle averages (size params)
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     shadedErrorBar(timepts,squeeze(nanmedian(grpdfsizebest(:,:,end,i,1,1),1)),...
% %         squeeze(nanstd(grpdfsizebest(:,:,end,i,1,1),1))/sqrt(totcells),'k',1)
% %     shadedErrorBar(timepts,squeeze(nanmedian(grpdfsizebest(:,:,end,i,1,2),1)),...
% %         squeeze(nanstd(grpdfsizebest(:,:,end,i,1,2),1))/sqrt(totcells),'r',1)
% %     axis square
% %     axis([timepts(1) timepts(end) -0.01 0.25])
% %     set(gca,'LooseInset',get(gca,'TightInset'))
% % end
% % mtit('Stationary response per size (size params)')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     shadedErrorBar(timepts,squeeze(nanmedian(grpdfsizebest(:,:,end,i,2,1),1)),...
% %         squeeze(nanstd(grpdfsizebest(:,:,end,i,1,1),1))/sqrt(totcells),'k',1)
% %     shadedErrorBar(timepts,squeeze(nanmedian(grpdfsizebest(:,:,end,i,2,2),1)),...
% %         squeeze(nanstd(grpdfsizebest(:,:,end,i,1,2),1))/sqrt(totcells),'r',1)
% %     axis square
% %     axis([timepts(1) timepts(end) -0.01 0.25])
% %     set(gca,'LooseInset',get(gca,'TightInset'))
% % end
% % mtit('Running response per size (size params)')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% 
% %%%%plot averages by animal
% %%%plot size suppression curves gratings params
% figure
% pre=nan(length(unique(session)),length(contrastlist),length(sizes));post=pre;
% for i = 1:length(unique(session))
%     pre(i,:,:) = squeeze(nanmedian(nanmean(grpdfsize(find(session==i),dfWindow,:,:,1,1),2),1));
%     post(i,:,:) = squeeze(nanmedian(nanmean(grpdfsize(find(session==i),dfWindow,:,:,1,2),2),1));
% end
% subplot(2,2,1)
% hold on
% if length(unique(session))==1
%     plot(1:length(radiusRange),squeeze(pre),'-o','Markersize',5)
% else
%     plot(1:length(radiusRange),squeeze(nanmedian(pre,1)),'-o','Markersize',5)
% end
% xlabel('Stim Size (deg)')
% ylabel('pre sit dfof')
% if length(unique(session))==1
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01...
%         max(max([pre post]))+0.01])
% else
%     axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
%         max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% end
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% hold off
% subplot(2,2,2)
% hold on
% if length(unique(session))==1
%     plot(1:length(radiusRange),squeeze(post),'-o','Markersize',5)
% else
%     plot(1:length(radiusRange),squeeze(nanmedian(post,1)),'-o','Markersize',5)
% end
% xlabel('Stim Size (deg)')
% ylabel('post sit dfof')
% if length(unique(session))==1
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01...
%         max(max([pre post]))+0.01])
% else
%     axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
%         max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% end
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% hold off
% pre=nan(length(unique(session)),length(contrastlist),length(sizes));post=pre;
% for i = 1:length(unique(session))
%     pre(i,:,:) = squeeze(nanmedian(nanmean(grpdfsize(find(session==i),dfWindow,:,:,2,1),2),1));
%     post(i,:,:) = squeeze(nanmedian(nanmean(grpdfsize(find(session==i),dfWindow,:,:,2,2),2),1));
% end
% subplot(2,2,3)
% hold on
% if length(unique(session))==1
%     plot(1:length(radiusRange),squeeze(pre),'-o','Markersize',5)
% else
%     plot(1:length(radiusRange),squeeze(nanmedian(pre,1)),'-o','Markersize',5)
% end
% xlabel('Stim Size (deg)')
% ylabel('pre run dfof')
% if length(unique(session))==1
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01...
%         max(max([pre post]))+0.01])
% else
%     axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
%         max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% end
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% hold off
% subplot(2,2,4)
% hold on
% if length(unique(session))==1
%     plot(1:length(radiusRange),squeeze(post),'-o','Markersize',5)
% else
%     plot(1:length(radiusRange),squeeze(nanmedian(post,1)),'-o','Markersize',5)
% end
% xlabel('Stim Size (deg)')
% ylabel('post run dfof')
% if length(unique(session))==1
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01...
%         max(max([pre post]))+0.01])
% else
%     axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
%         max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% end
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% hold off
% mtit('Size Suppression Curve (grat params, animal avg)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% % %%%plot size suppression curves size params
% % figure
% % pre=nan(length(unique(session)),length(contrastlist),length(sizes));post=pre;
% % for i = 1:length(unique(session))
% %     pre(i,:,:) = squeeze(nanmean(nanmean(grpdfsizebest(find(session==i),dfWindow,:,:,1,1),2),1));
% %     post(i,:,:) = squeeze(nanmean(nanmean(grpdfsizebest(find(session==i),dfWindow,:,:,1,2),2),1));
% % end
% % subplot(2,2,1)
% % hold on
% % plot(1:length(radiusRange),squeeze(nanmedian(pre,1)),'-o','Markersize',5)
% % xlabel('Stim Size (deg)')
% % ylabel('pre sit dfof')
% % axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
% %     max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% % axis square
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% % hold off
% % subplot(2,2,2)
% % hold on
% % plot(1:length(radiusRange),squeeze(nanmedian(post,1)),'-o','Markersize',5)
% % xlabel('Stim Size (deg)')
% % ylabel('post sit dfof')
% % axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
% %     max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% % axis square
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% % hold off
% % 
% % pre=nan(length(unique(session)),length(contrastlist),length(sizes));post=pre;
% % for i = 1:length(unique(session))
% %     pre(i,:,:) = squeeze(nanmean(nanmean(grpdfsizebest(find(session==i),dfWindow,:,:,2,1),2),1));
% %     post(i,:,:) = squeeze(nanmean(nanmean(grpdfsizebest(find(session==i),dfWindow,:,:,2,2),2),1));
% % end
% % subplot(2,2,3)
% % plot(1:length(radiusRange),squeeze(nanmedian(pre,1)),'-o','Markersize',5)
% % xlabel('Stim Size (deg)')
% % ylabel('pre run dfof')
% % axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
% %     max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% % axis square
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% % subplot(2,2,4)
% % plot(1:length(radiusRange),squeeze(nanmedian(post,1)),'-o','Markersize',5)
% % xlabel('Stim Size (deg)')
% % ylabel('post run dfof')
% % axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
% %     max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% % axis square
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% % mtit('Size Suppression Curve (size params, animal avg)')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% 
% %%%plot cycle averages (grat params)
% figure
% for i = 1:length(sizes)
%     subplot(2,4,i)
%     hold on
%     pre=nan(length(unique(session)),15);post=pre;
%     for j = 1:length(unique(session))
%             pre(j,:) = nanmedian(grpdfsize(find(session==j),:,end,i,1,1),1);
%             post(j,:) = nanmedian(grpdfsize(find(session==j),:,end,i,1,2),1);
%     end
%     if length(unique(session))==1
%         plot(timepts,pre,'k')
%         plot(timepts,post,'r')
%     else
%         shadedErrorBar(timepts,nanmedian(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
%         shadedErrorBar(timepts,nanmedian(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
%     end
%     axis square
%     axis([timepts(1) timepts(end) -0.01 0.25])
%     set(gca,'LooseInset',get(gca,'TightInset'))
% end
% mtit('Stationary response/size (grat params, animal avg)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% figure
% for i = 1:length(sizes)
%     subplot(2,4,i)
%     hold on
%     pre=nan(length(unique(session)),15);post=pre;
%     for j = 1:length(unique(session))
%             pre(j,:) = nanmedian(grpdfsize(find(session==j),:,end,i,2,1),1);
%             post(j,:) = nanmedian(grpdfsize(find(session==j),:,end,i,2,2),1);
%     end
%     if length(unique(session))==1
%         plot(timepts,pre,'k')
%         plot(timepts,post,'r')
%     else
%         shadedErrorBar(timepts,nanmedian(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
%         shadedErrorBar(timepts,nanmedian(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
%     end
%     axis square
%     axis([timepts(1) timepts(end) -0.01 0.25])
%     set(gca,'LooseInset',get(gca,'TightInset'))
% end
% mtit('Running response/size (grat params, animal avg)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% % %%%plot cycle averages (size params)
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     pre=nan(length(unique(session)),15);post=pre;
% %     for j = 1:length(unique(session))
% %         pre(j,:) = nanmedian(grpdfsizebest(find(session==j),:,end,i,1,1),1);
% %         post(j,:) = nanmedian(grpdfsizebest(find(session==j),:,end,i,1,2),1);
% %     end
% %     shadedErrorBar(timepts,nanmedian(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
% %     shadedErrorBar(timepts,nanmedian(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
% %     axis square
% %     axis([timepts(1) timepts(end) -0.01 0.25])
% %     set(gca,'LooseInset',get(gca,'TightInset'))
% % end
% % mtit('Stationary response per size (size params)')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     pre=nan(length(unique(session)),15);post=pre;
% %     for j = 1:length(unique(session))
% %         pre(j,:) = nanmedian(grpdfsizebest(find(session==j),:,end,i,2,1),1);
% %         post(j,:) = nanmedian(grpdfsizebest(find(session==j),:,end,i,2,2),1);
% %     end
% %     shadedErrorBar(timepts,nanmedian(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
% %     shadedErrorBar(timepts,nanmedian(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
% %     axis square
% %     axis([timepts(1) timepts(end) -0.01 0.25])
% %     set(gca,'LooseInset',get(gca,'TightInset'))
% % end
% % mtit('Running response per size (size params)')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% 
% 
% %%%make cutoff to eliminate noisy cells - threshold for size response
% sizethresh = 0.05;
% sizeresp = find(max(nanmean(grpdfsize(:,dfWindow,end,:,1),2),[],4)>sizethresh);
% 
% figure
% hold on
% pre = squeeze(nanmedian(nanmean(grpdfsize(sizeresp,dfWindow,:,:,1,1),2),1));
% post = squeeze(nanmedian(nanmean(grpdfsize(sizeresp,dfWindow,:,:,1,2),2),1));
% subplot(2,2,1)
% plot(1:length(radiusRange),pre,'-o','Markersize',5)
% xlabel('Stim Size (deg)')
% ylabel('pre sit dfof')
% axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% subplot(2,2,2)
% plot(1:length(radiusRange),post,'-o','Markersize',5)
% xlabel('Stim Size (deg)')
% ylabel('post sit dfof')
% axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% 
% pre = squeeze(nanmedian(nanmean(grpdfsize(sizeresp,dfWindow,:,:,2,1),2),1));
% post = squeeze(nanmedian(nanmean(grpdfsize(sizeresp,dfWindow,:,:,2,2),2),1));
% subplot(2,2,3)
% plot(1:length(radiusRange),pre,'-o','Markersize',5)
% xlabel('Stim Size (deg)')
% ylabel('pre run dfof')
% axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% subplot(2,2,4)
% plot(1:length(radiusRange),post,'-o','Markersize',5)
% xlabel('Stim Size (deg)')
% ylabel('post run dfof')
% axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% mtit('Size Suppression Curve (grat params, size thresh)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% %%%%plot averages by animal
% %%%plot size suppression curves gratings params
% figure
% pre=nan(length(unique(session)),length(contrastlist),length(sizes));post=pre;
% for i = 1:length(unique(session))
%     if length(intersect(find(session==i),sizeresp))==1
%         pre(i,:,:) = squeeze(nanmean(grpdfsize(intersect(find(session==i),sizeresp),dfWindow,:,:,1,1),2));
%         post(i,:,:) = squeeze(nanmean(grpdfsize(intersect(find(session==i),sizeresp),dfWindow,:,:,1,2),2));
%     else
%         pre(i,:,:) = squeeze(nanmedian(nanmean(grpdfsize(intersect(find(session==i),sizeresp),dfWindow,:,:,1,1),2),1));
%         post(i,:,:) = squeeze(nanmedian(nanmean(grpdfsize(intersect(find(session==i),sizeresp),dfWindow,:,:,1,2),2),1));
%     end
% end
% subplot(2,2,1)
% hold on
% if length(unique(session))==1
%     plot(1:length(radiusRange),squeeze(pre),'-o','Markersize',5)
% else
%     plot(1:length(radiusRange),squeeze(nanmedian(pre,1)),'-o','Markersize',5)
% end
% xlabel('Stim Size (deg)')
% ylabel('pre sit dfof')
% if length(unique(session))==1
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01...
%         max(max([pre post]))+0.01])
% else
%     axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
%         max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% end
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% hold off
% subplot(2,2,2)
% hold on
% if length(unique(session))==1
%     plot(1:length(radiusRange),squeeze(post),'-o','Markersize',5)
% else
%     plot(1:length(radiusRange),squeeze(nanmedian(post,1)),'-o','Markersize',5)
% end
% xlabel('Stim Size (deg)')
% ylabel('post sit dfof')
% if length(unique(session))==1
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01...
%         max(max([pre post]))+0.01])
% else
%     axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
%         max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% end
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% hold off
% 
% pre=nan(length(unique(session)),length(contrastlist),length(sizes));post=pre;
% for i = 1:length(unique(session))
%     if length(intersect(find(session==i),sizeresp))==1
%         pre(i,:,:) = squeeze(nanmean(grpdfsize(intersect(find(session==i),sizeresp),dfWindow,:,:,2,1),2));
%         post(i,:,:) = squeeze(nanmean(grpdfsize(intersect(find(session==i),sizeresp),dfWindow,:,:,2,2),2));
%     else
%         pre(i,:,:) = squeeze(nanmedian(nanmean(grpdfsize(intersect(find(session==i),sizeresp),dfWindow,:,:,2,1),2),1));
%         post(i,:,:) = squeeze(nanmedian(nanmean(grpdfsize(intersect(find(session==i),sizeresp),dfWindow,:,:,2,2),2),1));
%     end
% end
% subplot(2,2,3)
% hold on
% if length(unique(session))==1
%     plot(1:length(radiusRange),squeeze(pre),'-o','Markersize',5)
% else
%     plot(1:length(radiusRange),squeeze(nanmedian(pre,1)),'-o','Markersize',5)
% end
% xlabel('Stim Size (deg)')
% ylabel('pre run dfof')
% if length(unique(session))==1
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01...
%         max(max([pre post]))+0.01])
% else
%     axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
%         max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% end
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% hold off
% subplot(2,2,4)
% hold on
% if length(unique(session))==1
%     plot(1:length(radiusRange),squeeze(post),'-o','Markersize',5)
% else
%     plot(1:length(radiusRange),squeeze(nanmedian(post,1)),'-o','Markersize',5)
% end
% xlabel('Stim Size (deg)')
% ylabel('post run dfof')
% if length(unique(session))==1
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01...
%         max(max([pre post]))+0.01])
% else
%     axis([0 length(radiusRange)+1 min(min([nanmedian(pre,1) nanmedian(post,1)]))-0.01...
%         max(max([nanmedian(pre,1) nanmedian(post,1)]))+0.01])
% end
% axis square
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% hold off
% mtit('Size Suppression Curve (grat params, size thresh, animal avg)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% 
% %%%plot cycle averages (grat params)
% figure
% for i = 1:length(sizes)
%     subplot(2,4,i)
%     hold on
%     pre=nan(length(unique(session)),15);post=pre;
%     for j = 1:length(unique(session))
%         if length(intersect(find(session==j),sizeresp))==1
%             pre(j,:) = squeeze(grpdfsize(intersect(find(session==j),sizeresp),:,end,i,1,1));
%             post(j,:) = squeeze(grpdfsize(intersect(find(session==j),sizeresp),:,end,i,1,2));
%         else
%             pre(j,:) = nanmedian(grpdfsize(intersect(find(session==j),sizeresp),:,end,i,1,1),1);
%             post(j,:) = nanmedian(grpdfsize(intersect(find(session==j),sizeresp),:,end,i,1,2),1);
%         end
%     end
%     if length(unique(session))==1
%         plot(timepts,pre,'k')
%         plot(timepts,post,'r')
%     else
%         shadedErrorBar(timepts,nanmedian(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
%         shadedErrorBar(timepts,nanmedian(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
%     end
%     axis square
%     axis([timepts(1) timepts(end) -0.01 0.25])
%     set(gca,'LooseInset',get(gca,'TightInset'))
% end
% mtit('Stationary response/size (grat params, size thresh, animal avg)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% figure
% for i = 1:length(sizes)
%     subplot(2,4,i)
%     hold on
%     pre=nan(length(unique(session)),15);post=pre;
%     for j = 1:length(unique(session))
%         if length(intersect(find(session==j),sizeresp))==1
%             pre(j,:) = squeeze(grpdfsize(intersect(find(session==j),sizeresp),:,end,i,2,1));
%             post(j,:) = squeeze(grpdfsize(intersect(find(session==j),sizeresp),:,end,i,2,2));
%         else
%             pre(j,:) = nanmedian(grpdfsize(intersect(find(session==j),sizeresp),:,end,i,2,1),1);
%             post(j,:) = nanmedian(grpdfsize(intersect(find(session==j),sizeresp),:,end,i,2,2),1);
%         end
%     end
%     if length(unique(session))==1
%         plot(timepts,pre,'k')
%         plot(timepts,post,'r')
%     else
%         shadedErrorBar(timepts,nanmedian(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
%         shadedErrorBar(timepts,nanmedian(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
%     end
%     axis square
%     axis([timepts(1) timepts(end) -0.01 0.25])
%     set(gca,'LooseInset',get(gca,'TightInset'))
% end
% mtit('Running response/size (grat params, size thresh, animal avg)')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end
% 
% %%%plot individual cell data
% for i=1:length(sizeresp)
%     figure
% 
%     %%%direction tuning curve
%     subplot(2,4,1)
%     precurv = grpdfori(sizeresp(i),:,1,1);
%     postcurv = grpdfori(sizeresp(i),:,1,2);
%     hold on
%     plot(1:12,precurv,'k-')
%     plot(1:12,postcurv,'r-')
%     xlabel('Direction')
%     ylabel('dfof')
%     axis([1 12 min([precurv postcurv])+0.01 max([precurv postcurv])+0.01])
%     axis square
%     set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%     hold off
% 
%     %%%polar direction tuning curve
%     subplot(2,4,2)
%     prepol = grpdfori(sizeresp(i),:,1,1);prepol(prepol<0)=0;
%     postpol = grpdfori(sizeresp(i),:,1,2);postpol(postpol<0)=0;
%     polarplot([dirrange dirrange(1)],[prepol prepol(1)],'k-')
%     hold on
%     polarplot([dirrange dirrange(1)],[postpol postpol(1)],'r-')
%     set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%     hold off
% 
%     %%%osi/dsi
%     subplot(2,4,3)
%     hold on
%     plot([1 2],[grposi(sizeresp(i),1,1) grpdsi(sizeresp(i),1,1)],'k.','Markersize',20)
%     plot([1 2],[grposi(sizeresp(i),1,2) grpdsi(sizeresp(i),1,2)],'r.','Markersize',20)
%     axis([0 3 0 1])
%     set(gca,'xtick',[1 2],'xticklabel',{'OSI','DSI'})
%     axis square
%     set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%     hold off
% 
%     %%%avg resp to best grating stim
%     subplot(2,4,4)
%     hold on
%     plot(timepts,grpdfgrat(sizeresp(i),:,1,1),'k')
%     plot(timepts,grpdfgrat(sizeresp(i),:,1,2),'r')
%     xlabel('Time(s)')
%     ylabel('best grat dfof')
%     axis([timepts(1) timepts(end) min(min(grpdfgrat(sizeresp(i),:,1,:)))-0.01 max(max(grpdfgrat(sizeresp(i),:,1,:)))+0.01])
%     axis square
%     set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%     hold off
% 
%     %%%size curve (grat params)
%     subplot(2,4,5)
%     hold on
%     splotpre = squeeze(nanmean(grpdfsize(sizeresp(i),dfWindow,end,:,1,1),2));
%     splotpost = squeeze(nanmean(grpdfsize(sizeresp(i),dfWindow,end,:,1,2),2));
%     plot(1:length(radiusRange),splotpre,'k-o','Markersize',5)
%     plot(1:length(radiusRange),splotpost,'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
%     ylabel('grat param dfof')
%     axis([0 length(radiusRange)+1 min(min([splotpre splotpost]))-0.01 max(max([splotpre splotpost]))+0.01])
%     set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%     axis square
%     set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%     hold off
%     
%     %%%size curve (size params)
%     subplot(2,4,6)
%     hold on
%     splotpre = squeeze(nanmean(grpdfsizebest(sizeresp(i),dfWindow,end,:,1,1),2));
%     splotpost = squeeze(nanmean(grpdfsizebest(sizeresp(i),dfWindow,end,:,1,2),2));
%     plot(1:length(radiusRange),splotpre,'k-o','Markersize',5)
%     plot(1:length(radiusRange),splotpost,'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
%     ylabel('size param dfof')
%     axis([0 length(radiusRange)+1 min(min([splotpre splotpost]))-0.01 max(max([splotpre splotpost]))+0.01])
%     set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
%     axis square
%     set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%     hold off
% 
%     %%%contrast function (grat params)
%     subplot(2,4,7)
%     hold on
%     splotpre = squeeze(nanmean(grpdfsize(sizeresp(i),dfWindow,:,[1 4 7],1,1),2));
%     splotpost = squeeze(nanmean(grpdfsize(sizeresp(i),dfWindow,:,[1 4 7],1,2),2));
% 
%     plot(1:length(contrastlist),splotpre,'k-o','Markersize',5)
% %             set(groot,'defaultAxesColorOrder',sitcolor)
%     plot(1:length(contrastlist),splotpost,'r-o','Markersize',5)
% %             set(groot,'defaultAxesColorOrder',runcolor)
%     xlabel('contrast')
%     ylabel('grat params dfof')
%     axis([0 length(contrastlist)+1 min(min([splotpre splotpost]))-0.01 max(max([splotpre splotpost]))+0.01])
%     set(gca,'xtick',1:length(contrastlist),'xticklabel',contrastlist)
%     axis square
%     set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%     hold off
%     
%     %%%contrast function (size params)
%     subplot(2,4,8)
%     hold on
%     splotpre = squeeze(nanmean(grpdfsizebest(sizeresp(i),dfWindow,:,[1 4 7],1,1),2));
%     splotpost = squeeze(nanmean(grpdfsizebest(sizeresp(i),dfWindow,:,[1 4 7],1,2),2));
% 
%     plot(1:length(contrastlist),splotpre,'k-o','Markersize',5)
% %             set(groot,'defaultAxesColorOrder',sitcolor)
%     plot(1:length(contrastlist),splotpost,'r-o','Markersize',5)
% %             set(groot,'defaultAxesColorOrder',runcolor)
%     xlabel('contrast')
%     ylabel('size params dfof')
%     axis([0 length(contrastlist)+1 min(min([splotpre splotpost]))-0.01 max(max([splotpre splotpost]))+0.01])
%     set(gca,'xtick',1:length(contrastlist),'xticklabel',contrastlist)
%     axis square
%     set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%     hold off
% 
%     mtit(sprintf('Cell #%d session #%d tuning',sizeresp(i),session(sizeresp(i))))
%     if exist('psfile','var')
%         set(gcf, 'PaperPositionMode', 'auto'); %%%figure out how to make this full page landscape
%         print('-dpsc',psfile,'-append');
%     end
% end
% 
% 
% try
%     dos(['ps2pdf ' psfile ' "' [grpfilename '.pdf'] '"'] )
% catch
%     display('couldnt generate pdf');
% end
% 
% delete(psfile);

    
    
%%%old code    
    
    
    
% 
% 
% 
% figure
% hold on
% for i=1:length(sizes)
%     subplot(2,4,i)
%     respCells = find(allCells&squeeze(nanmean(nanmean(nanmean(nanmean(grptuning(:,dfWindow,:,:,:,end,i,1,1),2),3),4),5))>respthresh); %%%respCells = respCells(respCells<=cellCutoff);
%     hold on
%     plot(rf(:,2),rf(:,1),'.','color',[0.5 0.5 0.5]); %%% the rfAmp criterion wasn't being applied here
%     plot(rf(:,2),rf(:,1),'b.');
%     circle(ycent,xcent,centrad/dpix)
%     axis equal;
%     axis([0 72 0 128]);
% end
% title('Responsive cells/size')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end

% % 
% % numAni = length(use);
% % 
% % %%%for each cell make a figure where each plot is the individual data for
% % %%%that cell (SS curve, RF location)
% % 
% % %%plot all cells based on RF location, and by reponse criteria (e.g.>0.1)
% % %%or all cells that respond to size 1 or 2 etc
% % 
% % dfWindow = 9:11;
% % spWindow = 6:10;
% % spWindows = {6:8;8:10;6:10};
% % spWindowsNames = {'First Half','Second Half','Stim Window'};
% % dt = 0.1;
% % cyclelength = 1/0.1;
% % 
% % %stimulus file
% % moviename = 'C:\sizeSelect2sf8sz26min.mat';
% % load(moviename);
% % sizeVals = [0 5 10 20 30 40 50 60];
% % contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
% % for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
% % for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end
% % % sf=[sf sf];phase=[phase phase];radius=[radius radius];tf=[tf tf];theta=[theta theta];xpos=[xpos xpos];ypos=[ypos ypos];
% % ntrials= length(contrasts);
% % onsets = dt + (0:ntrials-1)*(isi+duration);
% % timepts = 1:(2*isi+duration)/dt;
% % timepts = (timepts-1)*dt;
% % 
% % %load pre data
% % cellcnt = 1;
% % grpdftuningPRE = nan(10000,15,2,6,4,8,2);
% % grpsptuningPRE = nan(10000,15,2,6,4,8,2);
% % % grppeaksPRE = nan(length(dirs),8,2);
% % for i = 1:length(use)
% %     load(files(use(i)).sizeanalysisPRE)
% %     numcells = size(dftuning,1);
% %     grpdftuningPRE(cellcnt:cellcnt+numcells-1,:,:,:,:,:,:) = dftuning;
% %     grpsptuningPRE(cellcnt:cellcnt+numcells-1,:,:,:,:,:,:) = sptuning;
% % %     grppeaksPRE(i,:,:) = avgpeaks;
% %     cellcnt = cellcnt + numcells;
% % end
% % 
% % %load post data
% % cellcnt = 1;
% % grpdftuningPOST = nan(1000,15,2,6,4,8,2);
% % grpsptuningPOST = nan(1000,15,2,6,4,8,2);
% % % grppeaksPOST = nan(length(dirs),8,2);
% % for i = 1:length(use)
% %     load(fullfile(dirs{i},'ssSummaryPOST.mat'))
% %     numcells = size(dftuning,1);
% %     grpdftuningPOST(cellcnt:cellcnt+numcells-1,:,:,:,:,:,:) = dftuning;
% %     grpsptuningPOST(cellcnt:cellcnt+numcells-1,:,:,:,:,:,:) = sptuning;
% % %     grppeaksPOST(i,:,:) = avgpeaks;
% %     cellcnt = cellcnt + numcells;
% % end
% % 
% % %baseline all traces
% % for h = 1:cellcnt
% %     for i = 1:length(sfrange)
% %         for j = 1:length(phaserange)
% %             for k = 1:length(contrastRange)
% %                 for l = 1:length(radiusRange)
% %                     grpdftuningPRE(h,:,i,j,k,l,1) = grpdftuningPRE(h,:,i,j,k,l,1)-grpdftuningPRE(h,5,i,j,k,l,1);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(h,:,i,j,k,1,1),1),3),4),5));
% %                     grpdftuningPRE(h,:,i,j,k,l,2) = grpdftuningPRE(h,:,i,j,k,l,2)-grpdftuningPRE(h,5,i,j,k,l,2);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(h,:,i,j,k,1,2),1),3),4),5));
% %                     grpsptuningPRE(h,:,i,j,k,l,1) = grpsptuningPRE(h,:,i,j,k,l,1)-grpsptuningPRE(h,5,i,j,k,l,1);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(h,:,i,j,k,1,1),1),3),4),5));
% %                     grpsptuningPRE(h,:,i,j,k,l,2) = grpsptuningPRE(h,:,i,j,k,l,2)-grpsptuningPRE(h,5,i,j,k,l,2);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(h,:,i,j,k,1,2),1),3),4),5));
% %                     grpdftuningPOST(h,:,i,j,k,l,1) = grpdftuningPOST(h,:,i,j,k,l,1)-grpdftuningPOST(h,5,i,j,k,l,1);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(h,:,i,j,k,1,1),1),3),4),5));
% %                     grpdftuningPOST(h,:,i,j,k,l,2) = grpdftuningPOST(h,:,i,j,k,l,2)-grpdftuningPOST(h,5,i,j,k,l,2);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(h,:,i,j,k,1,2),1),3),4),5));
% %                     grpsptuningPOST(h,:,i,j,k,l,1) = grpsptuningPOST(h,:,i,j,k,l,1)-grpsptuningPOST(h,5,i,j,k,l,1);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(h,:,i,j,k,1,1),1),3),4),5));
% %                     grpsptuningPOST(h,:,i,j,k,l,2) = grpsptuningPOST(h,:,i,j,k,l,2)-grpsptuningPOST(h,5,i,j,k,l,2);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(h,:,i,j,k,1,2),1),3),4),5));                    
% %                 end
% %             end
% %         end
% %     end
% % end
% % 
% % %subtract off zero size, separately for stationary/running trials
% % for h = 1:cellcnt
% %     dfZeroPreSta = squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(h,:,:,:,:,1,1),3),4),5));
% %     dfZeroPreRun = squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(h,:,:,:,:,1,2),3),4),5));
% %     spZeroPreSta = squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(h,:,:,:,:,1,1),3),4),5));
% %     spZeroPreRun = squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(h,:,:,:,:,1,2),3),4),5));
% %     dfZeroPostSta = squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(h,:,:,:,:,1,1),3),4),5));
% %     dfZeroPostRun = squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(h,:,:,:,:,1,2),3),4),5));
% %     spZeroPostSta = squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(h,:,:,:,:,1,1),3),4),5));
% %     spZeroPostRun = squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(h,:,:,:,:,1,2),3),4),5));
% %     for i = 1:length(sfrange)
% %         for j = 1:length(phaserange)
% %             for k = 1:length(contrastRange)
% %                 for l = 1:length(radiusRange)
% %                     grpdftuningPRE(h,:,i,j,k,l,1) = grpdftuningPRE(h,:,i,j,k,l,1)-dfZeroPreSta;
% %                     grpdftuningPRE(h,:,i,j,k,l,2) = grpdftuningPRE(h,:,i,j,k,l,2)-dfZeroPreRun;
% %                     grpsptuningPRE(h,:,i,j,k,l,1) = grpsptuningPRE(h,:,i,j,k,l,1)-spZeroPreSta;
% %                     grpsptuningPRE(h,:,i,j,k,l,2) = grpsptuningPRE(h,:,i,j,k,l,2)-spZeroPreRun;
% %                     grpdftuningPOST(h,:,i,j,k,l,1) = grpdftuningPOST(h,:,i,j,k,l,1)-dfZeroPostSta;
% %                     grpdftuningPOST(h,:,i,j,k,l,2) = grpdftuningPOST(h,:,i,j,k,l,2)-dfZeroPostRun;
% %                     grpsptuningPOST(h,:,i,j,k,l,1) = grpsptuningPOST(h,:,i,j,k,l,1)-spZeroPostSta;
% %                     grpsptuningPOST(h,:,i,j,k,l,2) = grpsptuningPOST(h,:,i,j,k,l,2)-spZeroPostRun;                    
% %                 end
% %             end
% %         end
% %     end
% % end
% % 
% % %only take cells with response >0.01 during pre period
% % % goodcells = zeros(cellcnt,1);
% % cnt=1;
% % for i = 1:cellcnt
% %     [peak, prefsize] = max(squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(i,dfWindow,:,:,end,:,1),4),3),2)));
% %     if peak>=0.01
% %         goodcells(cnt,1) = i;
% %         cnt=cnt+1;
% %     end
% % end
% % 
% % cellcnt = length(goodcells);
% % a = grpdftuningPRE(goodcells,:,:,:,:,:,:);
% % b = grpdftuningPOST(goodcells,:,:,:,:,:,:);
% % c = grpsptuningPRE(goodcells,:,:,:,:,:,:);
% % d = grpsptuningPOST(goodcells,:,:,:,:,:,:);
% % clear grp*
% % grpdftuningPRE = a;
% % grpdftuningPOST = b;
% % grpsptuningPRE = c;
% % grpsptuningPOST = d;
% % 
% % %%%dfof plotting
% % %%%plot responses as a function of contrast/size
% % figure
% % subplot(2,2,1)
% % hold on
% % for i=1:length(contrastRange)
% %     plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,i,:,1),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,i,:,1),4),3),1)));
% % end
% % axis([0 length(radiusRange)+1 -0.01 0.1])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend(contrastlist,'location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('PRE stationary dfof')
% % subplot(2,2,2)
% % hold on
% % for i=1:length(contrastRange)
% %     plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,i,:,2),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,i,:,2),4),3),1)));
% % end
% % axis([0 length(radiusRange)+1 -0.01 0.1])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend(contrastlist,'location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('PRE running dfof')
% % subplot(2,2,3)
% % hold on
% % for i=1:length(contrastRange)
% %     plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,i,:,1),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,5,:,:,i,:,1),4),3),1)));
% % end
% % axis([0 length(radiusRange)+1 -0.01 0.1])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend(contrastlist,'location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('POST stationary dfof')
% % subplot(2,2,4)
% % hold on
% % for i=1:length(contrastRange)
% %     plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,i,:,2),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,5,:,:,i,:,2),4),3),1)));
% % end
% % axis([0 length(radiusRange)+1 -0.01 0.1])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend(contrastlist,'location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('POST running dfof')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % mtit('dfof peak as function of contrast')
% % 
% % %%%plot full contrast response peaks across sizes 
% % figure
% % subplot(1,2,1)
% % hold on
% % errorbar(1:length(radiusRange),...
% %     squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,end,:,1),4),3),1),2)),...
% %     squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPRE(:,dfWindow,:,:,end,:,1),4),3),1),2))/sqrt(cellcnt),'k');
% % errorbar(1:length(radiusRange),...
% %     squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,end,:,1),4),3),1),2)),...
% %     squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPOST(:,dfWindow,:,:,end,:,1),4),3),1),2))/sqrt(cellcnt),'r');
% % axis([0 length(radiusRange)+1 -0.01 0.15])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend('PRE','POST','location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('stationary dfof')
% % subplot(1,2,2)
% % hold on
% % errorbar(1:length(radiusRange),...
% %     squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,end,:,2),4),3),1),2)),...
% %     squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPRE(:,dfWindow,:,:,end,:,2),4),3),1),2))/sqrt(cellcnt),'k');
% % errorbar(1:length(radiusRange),...
% %     squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,end,:,2),4),3),1),2)),...
% %     squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPOST(:,dfWindow,:,:,end,:,2),4),3),1),2))/sqrt(cellcnt),'r');
% % axis([0 length(radiusRange)+1 -0.01 0.15])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend('PRE','POST','location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('running dfof')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % mtit('full contrast dfof peaks')
% % 
% % %%%plot cycle averages for all sizes
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,ceil(length(sizes)/2),i)
% %     hold on
% %     shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,:,:,:,end,i,1),4),3),1)),...
% %         squeeze(nanstd(nanstd(nanstd(grpdftuningPRE(:,:,:,:,end,i,1),4),3),1))/sqrt(cellcnt),'k',1);
% %     shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,:,:,:,end,i,1),4),3),1)),...
% %         squeeze(nanstd(nanstd(nanstd(grpdftuningPOST(:,:,:,:,end,i,1),4),3),1))/sqrt(cellcnt),'r');
% %     axis([timepts(1) timepts(end) -0.01 0.15])
% % end
% % mtit('Stationary dfof per size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,ceil(length(sizes)/2),i)
% %     hold on
% %     shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,:,:,:,end,i,2),4),3),1)),...
% %         squeeze(nanstd(nanstd(nanstd(grpdftuningPRE(:,:,:,:,end,i,2),4),3),1))/sqrt(cellcnt),'k',1);
% %     shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,:,:,:,end,i,2),4),3),1)),...
% %         squeeze(nanstd(nanstd(nanstd(grpdftuningPOST(:,:,:,:,end,i,2),4),3),1))/sqrt(cellcnt),'r',1);
% %     axis([timepts(1) timepts(end) -0.01 0.15])
% % end
% % mtit('Running dfof per size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%plot cycle averages with sizes on same plot
% % figure
% % subplot(1,2,1)
% % hold on
% % for i = 1:length(sizes)
% %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,:,:,:,end,i,1),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,i,1),4),3),1)))
% % end
% % legend(sizes,'location','northwest')
% % xlabel('Time (s)')
% % ylabel('Stationary dfof')
% % axis([timepts(1) timepts(end) -0.01 0.15])
% % subplot(1,2,2)
% % hold on
% % for i = 1:length(sizes)
% %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,:,:,:,end,i,2),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,i,2),4),3),1)))
% % end
% % legend(sizes,'location','northwest')
% % xlabel('Time (s)')
% % ylabel('Running dfof')
% % axis([timepts(1) timepts(end) -0.01 0.15])
% % mtit('PRE')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % subplot(1,2,1)
% % hold on
% % for i = 1:length(sizes)
% %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,:,:,:,end,i,1),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,i,1),4),3),1)))
% % end
% % legend(sizes,'location','northwest')
% % xlabel('Time (s)')
% % ylabel('Stationary dfof')
% % axis([timepts(1) timepts(end) -0.01 0.15])
% % subplot(1,2,2)
% % hold on
% % for i = 1:length(sizes)
% %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,:,:,:,end,i,2),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,i,2),4),3),1)))
% % end
% % legend(sizes,'location','northwest')
% % xlabel('Time (s)')
% % ylabel('Running dfof')
% % axis([timepts(1) timepts(end) -0.01 0.15])
% % mtit('POST')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%same plotting for spikes
% % %%%plot responses as a function of contrast/size
% % figure
% % subplot(2,2,1)
% % hold on
% % for i=1:length(contrastRange)
% %     plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,i,:,1),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,i,:,1),4),3),1)));
% % end
% % axis([0 length(radiusRange)+1 -0.01 0.3])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend(contrastlist,'location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('PRE stationary spikes')
% % subplot(2,2,2)
% % hold on
% % for i=1:length(contrastRange)
% %     plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,i,:,2),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,i,:,2),4),3),1)));
% % end
% % axis([0 length(radiusRange)+1 -0.01 0.3])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend(contrastlist,'location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('PRE running spikes')
% % subplot(2,2,3)
% % hold on
% % for i=1:length(contrastRange)
% %     plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,i,:,1),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,i,:,1),4),3),1)));
% % end
% % axis([0 length(radiusRange)+1 -0.01 0.3])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend(contrastlist,'location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('POST stationary spikes')
% % subplot(2,2,4)
% % hold on
% % for i=1:length(contrastRange)
% %     plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,i,:,2),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,i,:,2),4),3),1)));
% % end
% % axis([0 length(radiusRange)+1 -0.01 0.3])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend(contrastlist,'location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('POST running spikes')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % mtit('spike peak as function of contrast')
% % 
% % %%%plot full contrast response peaks across sizes 
% % figure
% % subplot(1,2,1)
% % hold on
% % % plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,end,:,1),4),3),1),2)),'k');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,:,1),4),3),1)),'k');
% % % plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,end,:,1),4),3),1),2)),'r');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,end,:,1),4),3),1)),'r');
% % errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,end,:,1),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPRE(:,spWindow,:,:,end,:,1),4),3),1),2))/sqrt(cellcnt),'k');
% % errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,end,:,1),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPOST(:,spWindow,:,:,end,:,1),4),3),1),2))/sqrt(cellcnt),'r');
% % axis([0 length(radiusRange)+1 -0.01 0.2])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend('PRE','POST','location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('stationary spikes')
% % subplot(1,2,2)
% % hold on
% % % plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,end,:,2),4),3),1),2)),'k');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,:,2),4),3),1)),'k');
% % % plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,end,:,2),4),3),1),2)),'r');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,end,:,2),4),3),1)),'r');
% % errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,end,:,2),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPRE(:,spWindow,:,:,end,:,2),4),3),1),2))/sqrt(cellcnt),'k');
% % errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,end,:,2),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPOST(:,spWindow,:,:,end,:,2),4),3),1),2))/sqrt(cellcnt),'r');
% % axis([0 length(radiusRange)+1 -0.01 0.2])
% % set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% % legend('PRE','POST','location','northwest')
% % xlabel('Stim Size (deg)')
% % ylabel('running spikes')
% % mtit('full contrast spike peaks')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%plot full contrast response peaks across sizes for stationary using
% % %%%different windows
% % figure
% % for i = 1:size(spWindows,1)
% %     subplot(1,size(spWindows,1),i)
% %     hold on
% %     errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindows{i},:,:,end,:,1),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPRE(:,spWindows{i},:,:,end,:,1),4),3),1),2))/sqrt(cellcnt),'k');
% %     errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindows{i},:,:,end,:,1),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPOST(:,spWindows{i},:,:,end,:,1),4),3),1),2))/sqrt(cellcnt),'r');
% %     axis([0 length(radiusRange)+1 -0.01 0.2])
% %     set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% %     legend('PRE','POST','location','northwest')
% %     xlabel('Stim Size (deg)')
% %     ylabel(sprintf('stationary spikes %s', spWindowsNames{i}))
% % end
% % mtit('spike peaks across diff windows')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%plot cycle averages for all sizes
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,ceil(length(sizes)/2),i)
% %     hold on
% % %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,1),4),3),1)),'k');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,1),4),3),1)),'k')
% % %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,1),4),3),1)),'r');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,end,i,1),4),3),1)),'r')
% %     shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,1),4),3),1)),squeeze(nanstd(nanstd(nanstd(grpsptuningPRE(:,:,:,:,end,i,1),4),3),1))/sqrt(cellcnt),'k');
% %     shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,1),4),3),1)),squeeze(nanstd(nanstd(nanstd(grpsptuningPOST(:,:,:,:,end,i,1),4),3),1))/sqrt(cellcnt),'r');
% %     axis([timepts(1) timepts(end) -0.01 0.3])
% % end
% % mtit('Stationary spikes per size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,ceil(length(sizes)/2),i)
% %     hold on
% % %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,2),4),3),1)),'k');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,2),4),3),1)),'k')
% % %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,2),4),3),1)),'r');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,end,i,2),4),3),1)),'r')
% %     shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,2),4),3),1)),squeeze(nanstd(nanstd(nanstd(grpsptuningPRE(:,:,:,:,end,i,2),4),3),1))/sqrt(cellcnt),'k');
% %     shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,2),4),3),1)),squeeze(nanstd(nanstd(nanstd(grpsptuningPOST(:,:,:,:,end,i,2),4),3),1))/sqrt(cellcnt),'r');
% %     axis([timepts(1) timepts(end) -0.01 0.3])
% % end
% % mtit('Running spikes per size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%plot cycle averages with sizes on same plot
% % figure
% % subplot(1,2,1)
% % hold on
% % for i = 1:length(sizes)
% %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,1),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,1),4),3),1)))
% % end
% % legend(sizes,'location','northwest')
% % xlabel('Time (s)')
% % ylabel('Stationary spikes')
% % axis([timepts(1) timepts(end) -0.01 0.3])
% % subplot(1,2,2)
% % hold on
% % for i = 1:length(sizes)
% %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,2),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,2),4),3),1)))
% % end
% % legend(sizes,'location','northwest')
% % xlabel('Time (s)')
% % ylabel('Running spikes')
% % axis([timepts(1) timepts(end) -0.01 0.3])
% % mtit('PRE')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % subplot(1,2,1)
% % hold on
% % for i = 1:length(sizes)
% %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,1),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,1),4),3),1)))
% % end
% % legend(sizes,'location','northwest')
% % xlabel('Time (s)')
% % ylabel('Stationary spikes')
% % axis([timepts(1) timepts(end) -0.01 0.3])
% % subplot(1,2,2)
% % hold on
% % for i = 1:length(sizes)
% %     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,2),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,2),4),3),1)))
% % end
% % legend(sizes,'location','northwest')
% % xlabel('Time (s)')
% % ylabel('Running spikes')
% % axis([timepts(1) timepts(end) -0.01 0.3])
% % mtit('POST')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%plot response as a function of contrast for each size
% % figure
% % for i=1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     shadedErrorBar(1:length(contrastlist),...
% %         squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,:,i,1),1),2),3),4)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPRE(:,dfWindow,:,:,:,i,1),1),2),3),4)),'k',1)
% %     shadedErrorBar(1:length(contrastlist),...
% %         squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,:,i,1),1),2),3),4)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPOST(:,dfWindow,:,:,:,i,1),1),2),3),4)),'r',1)
% %     axis([0 length(contrastlist)+1 -0.01 0.1])
% %     axis square
% %     set(gca,'xtick',1:length(contrastlist),'xticklabel',contrastlist)
% % end
% % mtit('stationary contrast vs. df peak per size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i=1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     shadedErrorBar(1:length(contrastlist),...
% %         squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,:,i,2),1),2),3),4)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPRE(:,dfWindow,:,:,:,i,2),1),2),3),4)),'k',1)
% %     shadedErrorBar(1:length(contrastlist),...
% %         squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,:,i,2),1),2),3),4)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPOST(:,dfWindow,:,:,:,i,2),1),2),3),4)),'r',1)
% %     axis([0 length(contrastlist)+1 -0.01 0.1])
% %     axis square
% %     set(gca,'xtick',1:length(contrastlist),'xticklabel',contrastlist)
% % end
% % mtit('running contrast vs. df peak per size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i=1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     shadedErrorBar(1:length(contrastlist),...
% %         squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,dfWindow,:,:,:,i,1),1),2),3),4)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPRE(:,dfWindow,:,:,:,i,1),1),2),3),4)),'k',1)
% %     shadedErrorBar(1:length(contrastlist),...
% %         squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,dfWindow,:,:,:,i,1),1),2),3),4)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPOST(:,dfWindow,:,:,:,i,1),1),2),3),4)),'r',1)
% %     axis([0 length(contrastlist)+1 -0.01 0.2])
% %     axis square
% %     set(gca,'xtick',1:length(contrastlist),'xticklabel',contrastlist)
% % end
% % mtit('stationary contrast vs. spike peak per size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i=1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     shadedErrorBar(1:length(contrastlist),...
% %         squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,dfWindow,:,:,:,i,2),1),2),3),4)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPRE(:,dfWindow,:,:,:,i,2),1),2),3),4)),'k',1)
% %     shadedErrorBar(1:length(contrastlist),...
% %         squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,dfWindow,:,:,:,i,2),1),2),3),4)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPOST(:,dfWindow,:,:,:,i,2),1),2),3),4)),'r',1)
% %     axis([0 length(contrastlist)+1 -0.01 0.2])
% %     axis square
% %     set(gca,'xtick',1:length(contrastlist),'xticklabel',contrastlist)
% % end
% % mtit('running contrast vs. spike peak per size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % 
% % %%%pull out unconstrained peaks, peak times
% % peakdf = nan(cellcnt,2,2,8);peaktdf = zeros(cellcnt,2,2,8); %%peak and time: cell,pre/post,sit/run,size
% % peaksp = nan(cellcnt,2,2,8);peaktsp = zeros(cellcnt,2,2,8);
% % for i = 1:cellcnt
% %     for j = 1:length(sizes)
% %         for k = 1:2
% %             [peakdf(i,1,k,j),t] = max(nanmean(nanmean(grpdftuningPRE(i,5:15,:,:,end,j,k),3),4));
% %             peaktdf(i,1,k,j) = timepts(t+4);
% %             [peakdf(i,2,k,j),t] = max(nanmean(nanmean(grpdftuningPOST(i,5:15,:,:,end,j,k),3),4));
% %             peaktdf(i,2,k,j) = timepts(t+4);
% %             [peaksp(i,1,k,j),t] = max(nanmean(nanmean(grpsptuningPRE(i,5:15,:,:,end,j,k),3),4));
% %             peaktsp(i,1,k,j) = timepts(t+4);
% %             [peaksp(i,2,k,j),t] = max(nanmean(nanmean(grpsptuningPOST(i,5:15,:,:,end,j,k),3),4));
% %             peaktsp(i,2,k,j) = timepts(t+4);
% %         end
% %     end
% % end
% % 
% % %%%plot peaks for pre vs. post for each cell, w/mean + sd
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     plot(peakdf(:,1,1,i),peakdf(:,2,1,i),'k.')
% %     errorbar(nanmean(peakdf(:,1,1,i),1),nanmean(peakdf(:,2,1,i),1),...
% %         nanstd(peakdf(:,1,1,i),1),nanstd(peakdf(:,2,1,i),1),'r.','MarkerSize',15)
% %     plot([0,0.4],[0,0.4],'k-')
% %     axis square
% %     axis([0 0.4 0 0.4])
% % end
% % mtit('stationary pre vs. post peak df')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     plot(peaktdf(:,1,2,i),peaktdf(:,2,2,i),'k.')
% %     errorbar(nanmean(peaktdf(:,1,1,i),1),nanmean(peaktdf(:,2,1,i),1),...
% %         nanstd(peaktdf(:,1,1,i),1),nanstd(peaktdf(:,2,1,i),1),'r.','MarkerSize',15)
% %     plot([0,1.6],[0,1.6],'k-')
% %     axis square
% %     axis([0 1.6 0 1.6])
% % end
% % mtit('running pre vs. post peak df time')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     plot(peaksp(:,1,1,i),peaksp(:,2,1,i),'k.')
% %     errorbar(nanmean(peaksp(:,1,1,i),1),nanmean(peaksp(:,2,1,i),1),...
% %         nanstd(peaksp(:,1,1,i),1),nanstd(peaksp(:,2,1,i),1),'r.','MarkerSize',15)
% %     plot([0,0.5],[0,0.5],'k-')
% %     axis square
% %     axis([0 0.5 0 0.5])
% % end
% % mtit('stationary pre vs. post peak spike')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     plot(peaktsp(:,1,2,i),peaktsp(:,2,2,i),'k.')
% %     errorbar(nanmean(peaktsp(:,1,1,i),1),nanmean(peaktsp(:,2,1,i),1),...
% %         nanstd(peaktsp(:,1,1,i),1),nanstd(peaktsp(:,2,1,i),1),'r.','MarkerSize',15)
% %     plot([0,1.6],[0,1.6],'k-')
% %     axis square
% %     axis([0 1.6 0 1.6])
% % end
% % mtit('running pre vs. post peak spike time')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%instead of peak, use average over window
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     plot(squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(1:cellcnt,dfWindow,:,:,end,i,1),4),3),2)),...
% %         squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(1:cellcnt,dfWindow,:,:,end,i,1),4),3),2)),'k.')
% %     errorbar(squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,end,i,1),4),3),2),1)),...
% %         squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,end,i,1),4),3),2),1)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPRE(:,dfWindow,:,:,end,i,1),4),3),2),1)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPOST(:,dfWindow,:,:,end,i,1),4),3),2),1)),'r.','MarkerSize',15)
% %     plot([0,0.4],[0,0.4],'k-')
% %     axis square
% %     axis([0 0.4 0 0.4])
% % end
% % mtit('stationary pre vs. post window df')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i = 1:length(sizes)
% %     subplot(2,4,i)
% %     hold on
% %     plot(squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(1:cellcnt,dfWindow,:,:,end,i,2),4),3),2)),...
% %         squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(1:cellcnt,dfWindow,:,:,end,i,2),4),3),2)),'k.')
% %     errorbar(squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,end,i,2),4),3),2),1)),...
% %         squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,end,i,2),4),3),2),1)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPRE(:,dfWindow,:,:,end,i,2),4),3),2),1)),...
% %         squeeze(nanstd(nanstd(nanstd(nanstd(grpdftuningPOST(:,dfWindow,:,:,end,i,2),4),3),2),1)),'r.','MarkerSize',15)
% %     plot([0,0.4],[0,0.4],'k-')
% %     axis square
% %     axis([0 0.4 0 0.4])
% % end
% % mtit('running pre vs. post window df')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%calculate suppression index for df
% % SIdf = nan(cellcnt,2,2,2); %cell, pre/post, sit/run, SI/pref size
% % for i = 1:cellcnt
% %     for j = 1:2
% %         [peak, prefsize] = max(squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(i,dfWindow,:,:,end,:,j),4),3),2)));
% % %         SIdf(i,1,j,1) = (peak-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(i,dfWindow,:,:,end,end,j),4),3),2)))/...
% % %             squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(i,dfWindow,:,:,end,end,j),4),3),2));
% % %         if peak>=0.01
% %             SIdf(i,1,j,1) = (peak-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(i,dfWindow,:,:,end,end,j),4),3),2)))/peak;
% %             SIdf(i,1,j,2) = sizeVals(prefsize);
% % %         else
% % %             SIdf(i,1,j,1)=NaN;SIdf(i,1,j,2)=NaN;
% % %         end
% %         [peak, prefsize] = max(squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(i,dfWindow,:,:,end,:,j),4),3),2)));
% % %         SIdf(i,2,j,1) = (peak-squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(i,dfWindow,:,:,end,end,j),4),3),2)))/...
% % %             squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(i,dfWindow,:,:,end,end,j),4),3),2));
% % %         if peak>=0.01
% %             SIdf(i,2,j,1) = (peak-squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(i,dfWindow,:,:,end,end,j),4),3),2)))/peak;
% %             SIdf(i,2,j,2) = sizeVals(prefsize);
% % %         else
% % %             SIdf(i,2,j,1)=NaN;SIdf(i,2,j,2)=NaN;
% % %         end
% %     end
% % end
% % 
% % % SIdf = SIdf(SIdf(:,1,1,1)<=1&SIdf(:,1,1,1)>=-0.1,:,:,:);
% % 
% % %%%plot suppression index vs preferred size
% % figure
% % subplot(2,2,1)
% % plot(SIdf(:,1,1,2),SIdf(:,1,1,1),'k.')
% % axis([0 70 -0.2 1])
% % xlabel('Preferred stim size')
% % ylabel('Suppression Index')
% % legend('pre sit','location','northoutside')
% % subplot(2,2,2)
% % plot(SIdf(:,2,1,2),SIdf(:,2,1,1),'k.')
% % axis([0 70 -0.2 1])
% % xlabel('Preferred stim size')
% % ylabel('Suppression Index')
% % legend('post sit','location','northoutside')
% % subplot(2,2,3)
% % plot(SIdf(:,1,2,2),SIdf(:,1,2,1),'k.')
% % axis([0 70 -0.2 1])
% % xlabel('Preferred stim size')
% % ylabel('Suppression Index')
% % legend('pre run','location','northoutside')
% % subplot(2,2,4)
% % plot(SIdf(:,2,2,2),SIdf(:,2,2,1),'k.')
% % axis([0 70 -0.2 1])
% % xlabel('Preferred stim size')
% % ylabel('Suppression Index')
% % legend('post run','location','northoutside')
% % mtit('df Suppression Index vs. Preferred Size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%plot suppression index pre vs. post
% % figure
% % subplot(1,2,1)
% % hold on
% % plot(SIdf(:,1,1,1),SIdf(:,2,1,1),'k.')
% % plot(squeeze(nanmedian(SIdf(:,1,1,1),1)),squeeze(nanmedian(SIdf(:,2,1,1),1)),'r.','MarkerSize',25)%,...
% % %     squeeze(nanstd(SI(:,1,1,1),1)),squeeze(nanstd(SI(:,2,1,1),1)),'r','MarkerSize',25)
% % plot([-0.2,1],[-0.2,1],'k-')
% % axis([-0.2 1 -0.2 1])
% % axis square
% % xlabel('Pre Sit SI')
% % ylabel('Post Sit SI')
% % subplot(1,2,2)
% % hold on
% % plot(SIdf(:,1,2,1),SIdf(:,2,2,1),'k.')
% % plot(squeeze(nanmedian(SIdf(:,1,2,1),1)),squeeze(nanmedian(SIdf(:,2,2,1),1)),'r.','MarkerSize',25)%,...
% % %     squeeze(nanstd(SI(:,1,1,1),1)),squeeze(nanstd(SI(:,2,1,1),1)),'r','MarkerSize',25)
% % plot([-0.2,1],[-0.2,1],'k-')
% % axis([-0.2 1 -0.2 1])
% % axis square
% % xlabel('Pre Run SI')
% % ylabel('Post Run SI')
% % mtit('df Suppression Index (SI)')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%plot preferred stimulus size pre vs. post
% % figure
% % subplot(1,2,1)
% % hold on
% % plot(SIdf(:,1,1,2),SIdf(:,2,1,2),'k.')
% % plot(squeeze(nanmedian(SIdf(:,1,1,2),1)),squeeze(nanmedian(SIdf(:,2,1,2),1)),'r.','MarkerSize',25)%,...
% % %     squeeze(nanstd(SI(:,1,1,1),1)),squeeze(nanstd(SI(:,2,1,1),1)),'r','MarkerSize',25)
% % plot([0,70],[0,70],'k-')
% % axis([0 70 0 70])
% % axis square
% % xlabel('Pre Sit Degrees')
% % ylabel('Post Sit Degrees')
% % subplot(1,2,2)
% % hold on
% % plot(SIdf(:,1,2,2),SIdf(:,2,2,2),'k.')
% % plot(squeeze(nanmedian(SIdf(:,1,2,2),1)),squeeze(nanmedian(SIdf(:,2,2,2),1)),'r.','MarkerSize',25)%,...
% % %     squeeze(nanstd(SI(:,1,1,1),1)),squeeze(nanstd(SI(:,2,1,1),1)),'r','MarkerSize',25)
% % plot([0,70],[0,70],'k-')
% % axis([0 70 0 70])
% % axis square
% % xlabel('Pre Run Degrees')
% % ylabel('Post Run Degrees')
% % mtit('df Preferred Size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%calculate suppression index for spikes
% % SIsp = nan(cellcnt,2,2,2); %cell, pre/post, sit/run, SI/pref size
% % for i = 1:cellcnt
% %     for j = 1:2
% %         [peak, prefsize] = max(squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(i,spWindows{3},:,:,end,:,j),4),3),2)));
% %         SIsp(i,1,j,1) = (peak-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(i,spWindows{3},:,:,end,end,j),4),3),2)))/peak;%...
% % %             squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(i,spWindows{1},:,:,end,end,j),4),3),2));
% %         SIsp(i,1,j,2) = sizeVals(prefsize);
% %         [peak, prefsize] = max(squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(i,spWindows{3},:,:,end,:,j),4),3),2)));
% %         SIsp(i,2,j,1) = (peak-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(i,spWindows{3},:,:,end,end,j),4),3),2)))/peak;%...
% % %             squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(i,spWindows{1},:,:,end,end,j),4),3),2));
% %         SIsp(i,2,j,2) = sizeVals(prefsize);
% %     end
% % end
% % %plot cells w/ pre post and suppression index
% % 
% % % SIsp = SIsp(SIsp(:,1,1,1)<=1&SIsp(:,1,1,1)>=-0.1,:,:,:);
% % 
% % %%%plot suppression index vs preferred size
% % figure
% % subplot(2,2,1)
% % plot(SIsp(:,1,1,2),SIsp(:,1,1,1),'k.')
% % axis([0 70 -0.2 1])
% % xlabel('Preferred stim size')
% % ylabel('Suppression Index')
% % legend('pre sit','location','northoutside')
% % subplot(2,2,2)
% % plot(SIsp(:,2,1,2),SIsp(:,2,1,1),'k.')
% % axis([0 70 -0.2 1])
% % xlabel('Preferred stim size')
% % ylabel('Suppression Index')
% % legend('post sit','location','northoutside')
% % subplot(2,2,3)
% % plot(SIsp(:,1,2,2),SIsp(:,1,2,1),'k.')
% % axis([0 70 -0.2 1])
% % xlabel('Preferred stim size')
% % ylabel('Suppression Index')
% % legend('pre run','location','northoutside')
% % subplot(2,2,4)
% % plot(SIsp(:,2,2,2),SIsp(:,2,2,1),'k.')
% % axis([0 70 -0.2 1])
% % xlabel('Preferred stim size')
% % ylabel('Suppression Index')
% % legend('post run','location','northoutside')
% % mtit('spike Suppression Index vs. Preferred Size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%plot suppression index pre vs. post
% % figure
% % subplot(1,2,1)
% % hold on
% % plot(SIsp(:,1,1,1),SIsp(:,2,1,1),'k.')
% % plot(squeeze(nanmedian(SIsp(:,1,1,1),1)),squeeze(nanmedian(SIsp(:,2,1,1),1)),'r.','MarkerSize',25)%,...
% % %     squeeze(nanstd(SI(:,1,1,1),1)),squeeze(nanstd(SI(:,2,1,1),1)),'r','MarkerSize',25)
% % plot([-0.2,1],[-0.2,1],'k-')
% % axis([-0.2 1 -0.2 1])
% % axis square
% % xlabel('Pre Sit SI')
% % ylabel('Post Sit SI')
% % subplot(1,2,2)
% % hold on
% % plot(SIsp(:,1,2,1),SIsp(:,2,2,1),'k.')
% % plot(squeeze(nanmedian(SIsp(:,1,2,1),1)),squeeze(nanmedian(SIsp(:,2,2,1),1)),'r.','MarkerSize',25)%,...
% % %     squeeze(nanstd(SI(:,1,1,1),1)),squeeze(nanstd(SI(:,2,1,1),1)),'r','MarkerSize',25)
% % plot([-0.2,1],[-0.2,1],'k-')
% % axis([-0.2 1 -0.2 1])
% % axis square
% % xlabel('Pre Run SI')
% % ylabel('Post Run SI')
% % mtit('spike Suppression Index (SI)')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % %%%plot preferred stimulus size pre vs. post
% % %use a 2d heatmap myHist2?
% % figure
% % subplot(1,2,1)
% % hold on
% % plot(SIsp(:,1,1,2),SIsp(:,2,1,2),'k.')
% % plot(squeeze(nanmedian(SIsp(:,1,1,2),1)),squeeze(nanmedian(SIsp(:,2,1,2),1)),'r.','MarkerSize',25)%,...
% % %     squeeze(nanstd(SI(:,1,1,1),1)),squeeze(nanstd(SI(:,2,1,1),1)),'r','MarkerSize',25)
% % plot([0,70],[0,70],'k-')
% % axis([0 70 0 70])
% % axis square
% % xlabel('Pre Sit Degrees')
% % ylabel('Post Sit Degrees')
% % subplot(1,2,2)
% % hold on
% % plot(SIsp(:,1,2,2),SIsp(:,2,2,2),'k.')
% % plot(squeeze(nanmedian(SIsp(:,1,2,2),1)),squeeze(nanmedian(SIsp(:,2,2,2),1)),'r.','MarkerSize',25)%,...
% % %     squeeze(nanstd(SI(:,1,1,1),1)),squeeze(nanstd(SI(:,2,1,1),1)),'r','MarkerSize',25)
% % plot([0,70],[0,70],'k-')
% % axis([0 70 0 70])
% % axis square
% % xlabel('Pre Run Degrees')
% % ylabel('Post Run Degrees')
% % mtit('spike Preferred Size')
% % if exist('psfile','var')
% %     set(gcf, 'PaperPositionMode', 'auto');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % if plotallcells
% %     for i = 1:10:cellcnt
% %         figure
% %         for j = 1:length(sizes)
% %             subplot(2,4,j)
% %             hold on
% %             plot(timepts,squeeze(nanmean(nanmean(grpdftuningPRE(i,:,:,end,end,j,1),4),3)),'k-')
% %             plot(timepts,squeeze(nanmean(nanmean(grpdftuningPOST(i,:,:,end,end,j,2),4),3)),'r-')
% %             axis square
% %             axis([timepts(1) timepts(end) -0.05 0.5])
% %         end
% %         mtit(sprintf('cell %d df',i))
% %         figure
% %         for j = 1:length(sizes)
% %             subplot(2,4,j)
% %             hold on
% %             plot(timepts,squeeze(nanmean(nanmean(grpsptuningPRE(i,:,:,end,end,j,1),4),3)),'k-')
% %             plot(timepts,squeeze(nanmean(nanmean(grpsptuningPOST(i,:,:,end,end,j,2),4),3)),'r-')
% %             axis square
% %             axis([timepts(1) timepts(end) -0.05 0.5])
% %         end
% %         mtit(sprintf('cell %d spikes',i))
% %     end
% % end
% % 
% % save(filename,'grpdftuningPRE','grpdftuningPOST','grpsptuningPRE','grpsptuningPOST')%,'grppeaksPRE','grppeaksPOST')
% % 
% % try
% %     dos(['ps2pdf ' psfile ' "' [filename '.pdf'] '"'])
% % 
% % catch
% %     display('couldnt generate pdf');
% % end
