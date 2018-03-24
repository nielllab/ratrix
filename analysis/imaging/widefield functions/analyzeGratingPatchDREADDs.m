%%%analyzeGratingPatchDREADDs
close all
clear all
dbstop if error

%select batch file and movie
batchKristenBehavior
% grpnames = {'ControlGratingPatchWF','EnrichmentGratingPatchWF'};
moviename = 'C:\gratingpatch3sf2tf8dir';

cd(pathname)
load(moviename)
 
%select animals to use
use = find(strcmp({files.notes},'good imaging session') & strcmp({files.dose},'0.1'))
sprintf('%d experiments for individual analysis',length(use))

%%%user settings
deconvplz = 0 %choose if you want deconvolution
downsample = 0.5; %downsample ratio
imagerate=10; %acquisition rate in Hz
pixbin = 5 %choose binning for gaussian analysis of spread
plotbins = 5; %choose how far out to plot the spread
dfrange = [-0.01 0.05;-0.01 0.15]; %%%range for imagesc visualization, row is running/stationary
behavState = {'stationary','running'};

if deconvplz
    base = isi*imagerate-2:isi*imagerate;
    peakWindow = isi*imagerate+1:isi*imagerate+3;
%     outpathname = '\\langevin\backup\widefield\Denise\Enrichment\decon\';
else
    base = isi*imagerate-2:isi*imagerate;
    peakWindow = isi*imagerate+8:isi*imagerate+10;
%     outpathname = '\\langevin\backup\widefield\Denise\Enrichment\nodecon\';
end

indani = input('analyze individual data? 0=no 1=yes: '); %0 skips to group analysis/plotting
if indani
    redoani = input('reanalyze old experiments? 0=no, 1=yes: '); %rerun experiments that have already been analyzed
    if redoani
        reselect = input('reselect ROI in each experiment? 0=no, 1=yes: '); %option to reselect the activation point
    else
        reselect = 0;
    end
else
    redoani = 0;
end   

redogrp = input('redo group analysis? 0=no 1=yes: '); %option to reanalyze the group data

alluse = use;%needed for doTopography
allsubj = unique({files(alluse).subj}); %needed for doTopography
if indani
    for s=1:1 %needed for doTopography
    %     rotateCropWF; %%%manually rotate and crop dF movies first
        doTopography; %%%align across animals second
        doGratingPatch; %%%run individual analysis
    end
    sprintf('individual analysis complete, starting group...')
end

%%%load stimulus info
load(moviename)
sfrange = unique(sf);tfrange = unique(tf);thetarange = unique(theta);xrange = unique(xpos);
imagerate=10;
cyclength = imagerate*(isi+duration);
timepts = 0:1/imagerate:(2*isi+duration);timepts = timepts - isi;timepts = timepts(1:end-1);

% %% concatenate individual experiments into group data
% if redogrp
%     for group=1:2
% 
%         if group==1
%             use = find((strcmp({files.cond},'control') & strcmp({files.notes},'good imaging session')))
%             grpfilename = grpnames{1}
%         elseif group==2
%             use = find((strcmp({files.cond},'enrichment') & strcmp({files.notes},'good imaging session')))
%             grpfilename = grpnames{2}
%         end
%         numAni = length(use);
% 
%         if isempty(use)
%             sprintf('No animals in %s',grpfilename)
%             return
%         end
% 
%         psfilename = 'C:\Users\nlab\Documents\MATLAB\tempDeniseWF.ps';
%         if exist(psfilename,'file')==2;delete(psfilename);end
% 
%         
%     
%         cd(outpathname)
%         load(sprintf('%s_%s_%s_gratingpatch.mat',files(use(1)).expt,files(use(1)).subj,files(use(1)).cond));
%         grpring = nan(numAni,50,size(ring,2),size(ring,3),size(ring,4),size(ring,5),2); %spread of response
%         grpcyc = nan(numAni,size(trialcycavg,1),size(trialcycavg,2),size(trialcycavg,3),size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),size(trialcycavg,7),2); %full image cycle averages
%         grptrace = nan(numAni,size(trialcycavg,3),size(trialcycavg,4),size(trialcycavg,5),size(trialcycavg,6),size(trialcycavg,7),2); %cycle average using selected points
% 
%         anicnt = 1;
%         for f = 1:length(use) %loop through animals in group and populate group analysis files
%             aniFile = sprintf('%s_%s_%s_gratingpatch.mat',files(use(f)).expt,files(use(f)).subj,files(use(f)).cond);
%             load(aniFile,'ring','trialcycavg','x','y')
%             grpcyc(anicnt,:,:,:,:,:,:,:,:) = trialcycavg;
%             for i = 1:length(xrange)
%                 grpring(anicnt,1:size(ring,1),:,:,:,:,:) = ring;
%                 grptrace(anicnt,:,i,:,:,:,:) = squeeze(nanmean(nanmean(trialcycavg(x(i)-2:x(i)+2,y(i)-2:y(i)+2,:,i,:,:,:,:),1),2));
%             end
% 
%             anicnt = anicnt+1;
%         end
%         try
%             save(fullfile(outpathname,grpfilename),'grpcyc','grpring','grptrace','-v7.3','-append');
%         catch
%             save(fullfile(outpathname,grpfilename),'grpcyc','grpring','grptrace','-v7.3');
%         end
%     
% 
% 
%     %% plot averages for each individual group
% 
%         sprintf('plotting responses')
%         dfrange = [-0.01 0.05;-0.01 0.15]; %%%range for imagesc visualization, row is running/stationary
% 
%         %%%plot pixelwise responses
%         for m = 1:2 %sit/run
%             for i = 1:length(xrange) %cycle through x positions
%                 
%                 figure;colormap jet %plot average pixelwise maps
%                 figcnt=1;
%                 for j = 1:length(sfrange)
%                     for k = 1:length(tfrange)
%                         subplot(length(sfrange),length(tfrange),figcnt)
%                         imagesc(squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,i,j,k,:,m),8),4),1)),dfrange(1,:))
%                         axis off;axis equal;
%                         title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
%                         figcnt=figcnt+1;
%                     end
%                 end
%                 mtit(sprintf('%s pixelwise xpos%d %s',grpfilename,i,behavState{m}))
%                 if exist('psfilename','var')
%                     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%                     print('-dpsc',psfilename,'-append');
%                 end
% 
%                 figure; %plot point cycle averages
%                 figcnt=1;
%                 for j = 1:length(sfrange)
%                     for k = 1:length(tfrange)
%                         subplot(length(sfrange),length(tfrange),figcnt)
%                         vals = bsxfun(@minus,squeeze(nanmean(grptrace(:,:,i,j,k,:,m),6)),squeeze(nanmean(nanmean(grptrace(:,base,i,j,k,:,m),6),2)));
%                         shadedErrorBar(timepts,nanmean(vals,1),nanstd(vals,[],1)/sqrt(size(vals,1)))
%                         ylabel('dfof')
%                         xlabel('time(s)')
%                         axis([timepts(base(1)) timepts(end) -0.025 0.15])
%                         axis square
%                         title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
%                         figcnt=figcnt+1;
%                     end
%                 end
%                 mtit(sprintf('%s cycavg xpos%d %s',grpfilename,i,behavState{m}))
%                 if exist('psfilename','var')
%                     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%                     print('-dpsc',psfilename,'-append');
%                 end
% 
%                 figure; %plot spread of response
%                 figcnt=1;
%                 for j = 1:length(sfrange)
%                     for k = 1:length(tfrange)
%                         subplot(length(sfrange),length(tfrange),figcnt)
%                         plot(0:size(grpring,2)-1,squeeze(nanmean(nanmean(grpring(:,:,i,j,k,:,m),6),1)))
%                         ylabel('dfof')
%                         xlabel('distance from cent (pix)')
%                         axis([0 plotbins -0.025 0.15])
%                         set(gca,'LooseInset',get(gca,'TightInset'),'xtick',0:1:plotbins,'xticklabel',0:pixbin:plotbins*pixbin)
%                         axis square
%                         title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
%                         figcnt = figcnt+1;
%                     end
%                 end
%                 mtit(sprintf('%s spread xpos%d %s',grpfilename,i,behavState{m}))
%                 if exist('psfilename','var')
%                     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%                     print('-dpsc',psfilename,'-append');
%                 end
%             end
%         end
% 
% 
%         %% save pdf
% 
%         try
%             dos(['ps2pdf ' psfilename ' "' fullfile(outpathname,grpfilename) '.pdf' '"'])
%         catch
%             display('couldnt generate pdf');
%         end
% 
%         delete(psfilename);
%         close all
%     end  
% end
% 
% %% overlay group data
% 
% psfilename = 'C:\Users\nlab\Documents\MATLAB\tempDeniseWF.ps';
% if exist(psfilename,'file')==2;delete(psfilename);end
% 
% for i = 1:(length(xrange)*3*length(grpnames)+6) %generate figures to loop over
%     figlist{i} = figure;
% end
% plotcol = {'k','r'};
% 
% for group=1:2
%     load(fullfile(outpathname,grpnames{group}))
%     f = 1;
%     for m = 1:2 %sit/run
% 
%         figure(figlist{f}) %plot dfof average/sem for different stim parameters
%         respmn = nan(length(sfrange),length(tfrange));respsem = respmn;
%         for j = 1:length(sfrange)
%             for k = 1:length(tfrange)
%                 vals = squeeze(nanmean(nanmean(nanmean(grptrace(:,peakWindow,:,j,k,:,m),6),3),2)-nanmean(nanmean(nanmean(grptrace(:,base,:,j,k,:,m),6),3),2));
%                 respmn(j,k) = nanmean(vals);
%                 respsem(j,k) = nanstd(vals)/length(vals);
%             end
%         end
%         for k = 1:length(tfrange)
%             subplot(1,length(tfrange),k)
%             hold on
%             errorbar(sfrange,respmn(:,k),respsem(:,k),plotcol{group})
%             ylabel('dfof')
%             xlabel('cycles/deg')
%             axis([0 sfrange(end)+sfrange(1) 0 0.1])
%             axis square
%             title(sprintf('acuity %dHz',tfrange(k)))
%             set(gca,'LooseInset',get(gca,'TightInset'))
%         end
% 
%         f=f+1;
%         
%         figure(figlist{f}) %plot cycle averages with all x positions averaged across
%         figcnt=1;
%         for j = 1:length(sfrange)
%             for k = 1:length(tfrange)
%                 subplot(length(sfrange),length(tfrange),figcnt)
%                 hold on
%                 vals = bsxfun(@minus,squeeze(nanmean(nanmean(grptrace(:,:,:,j,k,:,m),6),3)),squeeze(nanmean(nanmean(nanmean(grptrace(:,base,:,j,k,:,m),6),3),2)));
%                 shadedErrorBar(timepts,nanmean(vals,1),nanstd(vals,[],1)/sqrt(size(vals,1)),plotcol{group},1)
%                 ylabel('dfof')
%                 xlabel('time(s)')
%                 axis([timepts(base(1)) timepts(end) -0.025 0.15])
%                 axis square
%                 title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
%                 set(gca,'LooseInset',get(gca,'TightInset'))
%                 figcnt=figcnt+1;
%             end
%         end
% 
%         f=f+1;
% 
%         figure(figlist{f}) %plot spread averaged across x positions
%         figcnt=1;
%         for j = 1:length(sfrange)
%             for k = 1:length(tfrange)
%                 subplot(length(sfrange),length(tfrange),figcnt)
%                 hold on
%                 vals = squeeze(nanmean(nanmean(grpring(:,:,:,j,k,:,m),6),3));
%                 shadedErrorBar(0:size(grpring,2)-1,nanmean(vals,1),nanstd(vals,[],1)/sqrt(size(vals,1)),plotcol{group},1)
%                 ylabel('dfof')
%                 xlabel('distance from cent (pix)')
%                 axis([0 plotbins -0.025 0.15])
%                 set(gca,'LooseInset',get(gca,'TightInset'),'xtick',0:1:plotbins,'xticklabel',0:pixbin:plotbins*pixbin)
%                 axis square
%                 title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
%                 figcnt = figcnt+1;
%             end
%         end
% 
%         f=f+1;
%         
%         for i = 1:length(xrange) %individual x position plots
%             
%             figure(figlist{f});colormap jet %plot pixelwise averages
%             figcnt=1+length(sfrange)*length(tfrange)*(group-1);
%             for j = 1:length(sfrange)
%                 for k = 1:length(tfrange)
%                     subplot(2,length(tfrange)*length(sfrange),figcnt)
%                     frm = squeeze(nanmean(nanmean(nanmean(grpcyc(:,:,:,peakWindow,i,j,k,:,m),8),4),1));
%                     imagesc(frm,dfrange(1,:))
%                     axis off; axis equal
%                     title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
%                     figcnt=figcnt+1;
%                 end
%             end
%             
%             f=f+1;
%                         
%             figure(figlist{f}) %plot cycle averages
%             figcnt=1;
%             for j = 1:length(sfrange)
%                 for k = 1:length(tfrange)
%                     subplot(length(sfrange),length(tfrange),figcnt)
%                     hold on
%                     vals = bsxfun(@minus,squeeze(nanmean(grptrace(:,:,i,j,k,:,m),6)),squeeze(nanmean(nanmean(grptrace(:,base,i,j,k,:,m),6),2)));
%                     shadedErrorBar(timepts,nanmean(vals,1),nanstd(vals,[],1)/sqrt(size(vals,1)),plotcol{group},1)
%                     ylabel('dfof')
%                     xlabel('time(s)')
%                     axis([timepts(base(1)) timepts(end) -0.025 0.15])
%                     axis square
%                     title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
%                     set(gca,'LooseInset',get(gca,'TightInset'))
%                     figcnt=figcnt+1;
%                 end
%             end
%             
%             f=f+1;
%             
%             figure(figlist{f}) %plot spread
%             figcnt=1;
%             for j = 1:length(sfrange)
%                 for k = 1:length(tfrange)
%                     subplot(length(sfrange),length(tfrange),figcnt)
%                     hold on
%                     vals = squeeze(nanmean(grpring(:,:,i,j,k,:,m),6));
%                     shadedErrorBar(0:size(grpring,2)-1,nanmean(vals,1),nanstd(vals,[],1)/sqrt(size(vals,1)),plotcol{group},1)
%                     ylabel('dfof')
%                     xlabel('distance from cent (pix)')
%                     axis([0 plotbins -0.025 0.15])
%                     set(gca,'LooseInset',get(gca,'TightInset'),'xtick',0:1:plotbins,'xticklabel',0:pixbin:plotbins*pixbin)
%                     axis square
%                     title(sprintf('%0.2fcpd %dHz',sfrange(j),tfrange(k)))
%                     figcnt = figcnt+1;
%                 end
%             end
%             
%             f=f+1;
%         end
%     end
% end
% 
% f = 1;
% for m = 1:2 %sit/run %go through and label/print the figures to pdf
%     
%     figure(figlist{f})
%     mtit(sprintf('%s',behavState{m}))
%     if exist('psfilename','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfilename,'-append');
%     end
%     f=f+1;
%     
%     figure(figlist{f})
%     mtit(sprintf('all pos cycavg %s',behavState{m}))
%     if exist('psfilename','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfilename,'-append');
%     end
%     f=f+1;
% 
%     figure(figlist{f})
%     mtit(sprintf('all pos spread %s',behavState{m}))
%     if exist('psfilename','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfilename,'-append');
%     end
%     f=f+1;
% 
%     for i = 1:length(xrange)
%         figure(figlist{f})
%         mtit(sprintf('pixelwise xpos%d %s',i,behavState{m}))
%         if exist('psfilename','var')
%             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%             print('-dpsc',psfilename,'-append');
%         end
%         f=f+1;
%             
%         figure(figlist{f})
%         mtit(sprintf('cycavg xpos%d %s',i,behavState{m}))
%         if exist('psfilename','var')
%             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%             print('-dpsc',psfilename,'-append');
%         end
%         f=f+1;
% 
%         figure(figlist{f})
%         mtit(sprintf('spread xpos%d %s',i,behavState{m}))
%         if exist('psfilename','var')
%             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%             print('-dpsc',psfilename,'-append');
%         end
%         f=f+1;
%     end
% end
% 
% try
%     dos(['ps2pdf ' psfilename ' "' fullfile(outpathname,'EnrichmentCompare.pdf') '"'])
% catch
%     display('couldnt generate pdf');
% end
% 
% delete(psfilename);