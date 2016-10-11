%This code performs averaging over animals for size select stimulus
%It takes in the output files of analyzeSizeSelect
%PRLP 02/01/2016 Niell Lab
dbstop if error

ptsdir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data';

%%%saline naive data
% filename = 'SalineNaiveSizeSelect'; %pdf name
% predir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Pre_Saline';
% postdir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Post_Saline';
% datafiles = {'072816_G62BB6RT_SALINE_RIG2_SizeSelectAnalysis.mat',...
%             '080116_G62AA3TT_SALINE_RIG2_SizeSelectAnalysis.mat',...
%             '082416_G62Y9RT_SALINE_RIG2_SizeSelectAnalysis.mat',...
%             '082516_G62TX210_2_SALINE_RIG2_SizeSelectAnalysis.mat'};
% ptsfile = {'G62BB6RT_points.mat',...
%           'G62AA3TT_points.mat',...
%           'G62Y9RT_points.mat'...
%           'G62TX210TT_points.mat'}; %specific point files for animals
      
% %%%saline trained data
% filename = 'SalineTrainedSizeSelect'; %pdf name
% predir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Pre_Saline';
% postdir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Post_Saline';
% datafiles = {'082516_G62EE6LT_SALINE_RIG2_SizeSelectAnalysis.mat',...
%             '083116_G62TX19TT_SALINE_RIG2_SizeSelectAnalysis.mat'};
% ptsfile = {'G62EE6LT_points.mat'...
%           'G62TX19LT_points.mat'}; %specific point files for animals

% %%doi naive data
% filename = 'DOINaiveSizeSelect'; %pdf name
% predir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Pre_DOI';
% postdir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Post_DOI';
% datafiles = {'071216_G62Y9RT_DOI_RIG2_SizeSelectAnalysis.mat',...
%             '071316_G62AA3TT_DOI_RIG2_SizeSelectAnalysis.mat',...
%             '071316_G62BB6RT_DOI_RIG2_SizeSelectAnalysis.mat',...
%             '072816_G62TX210TT_DOI_RIG2_SizeSelectAnalysis.mat'};
% ptsfile = {'G62Y9RT_DOIpoints.mat',...
%           'G62AA3TT_DOIpoints.mat'...
%           'G62BB6RT_DOIpoints.mat',...          
%           'G62TX210TT_DOIpoints.mat'}; %specific point files for animals
      
% % % %%doi trained data
filename = 'DOITrainedSizeSelect'; %pdf name
predir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Pre_DOI';
postdir = '\\langevin\backup\widefield\DOI_experiments\Phil_Size_Suppression_Data\Post_DOI';
datafiles = {'071216_G62TX19LT_DOI_RIG2_SizeSelectAnalysis.mat',...
            '071216_G62EE6LT_DOI_RIG2_SizeSelectAnalysis.mat',...
            '071316_G62EE8TT_DOI_RIG2_SizeSelectAnalysis.mat',...
            '071316_G62BB8TT_DOI_RIG2_SizeSelectAnalysis.mat'};
ptsfile = {'G62TX19LT_DOIpoints.mat',...
          'G62EE6LT_DOIpoints.mat'...
          'G62EE8TT_DOIpoints.mat'...
          'G62BB8TT_DOIpoints.mat'}; %specific point files for animals
 
          
% predir = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\Trained Pre';
% postdir = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\Trained Post';
% datafiles = {'021316_G62TX2.6LT_RIG2_DOI_SizeSelectAnalysis.mat',...
%             '021316_G62TX2.6RT_RIG2_DOI_SizeSelectAnalysis.mat',...
%             '021515_G62BB2RT_RIG2_DOI_SizeSelectAnalysis.mat',...
%             '021516_G62T6LT_RIG2_DOI_SizeSelectAnalysis.mat',...
%             '021716_G62W7LN_RIG2_DOI_SizeSelectAnalysis.mat',...
%             '021716_G62W7TT_RIG2_DOI_SizeSelectAnalysis.mat'};
% datafiles = {'032816_CALB25B5RT_RIG2_DOI_SizeSelectAnalysis'};
% ptsfile = {'G62TX2.6LT_SizeSelectPoints.mat',...
%           'G62TX2.6RT_SizeSelectPoints.mat',...
%           'G62BB2RT_SizeSelectPoints.mat',...
%           'G62T6LT_SizeSelectPoints.mat',...
%           'G62W7LN_SizeSelectPoints.mat',...
%           'G62W7TT_SizeSelectPoints.mat'};
% ptsfile = {'CALB25B5RT_SizeSelectPoints'};
load(filename)
plotrange = 5:9;

psfilename = 'c:\temp.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

load('C:\mapoverlay.mat');
% xpts = xpts/4;
% ypts = ypts/4;
moviename = 'C:\sizeSelect2sf8sz26min.mat';
load(moviename);
imagerate=10;
acqdurframes = imagerate*(isi+duration);
timepts = [1:acqdurframes+acqdurframes/2]*0.1;
% pointsfile = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\GroupSizeSelectPoints';
% load(pointsfile);
areas = {'V1','P','LM','AL','RL','AM','PM'};
behavState = {'stationary','running'};
ncut = 2;
trials = length(sf)-ncut;
sizeVals = [0 5 10 20 30 40 50 60];
sf=sf(1:trials);contrasts=contrasts(1:trials);phase=phase(1:trials);radius=radius(1:trials);
order=order(1:trials);tf=tf(1:trials);theta=theta(1:trials);xpos=xpos(1:trials);
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end

% alltrialcycavgpre = zeros(260,260,acqdurframes+acqdurframes/2,length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(datafiles));
% allpeakspre = zeros(length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
% alltracespre = zeros(length(areas),acqdurframes+acqdurframes/2,length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(datafiles));
% allgauParamspre = zeros(length(contrastRange),length(radiusRange),2,length(areas),5,length(datafiles));
% allhalfMaxpre = zeros(length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
% allareapeakspre = zeros(length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
% for i= 1:length(datafiles) %collates all conditions (numbered above) 
%     load(fullfile(predir,datafiles{i}),'trialcycavg','peaks','mv','areapeaks','gauParams','halfMax')
%     alltrialcycavgpre(:,:,:,:,:,:,:,:,i) = trialcycavg;
%     allpeakspre(:,:,:,:,:,:,i) = peaks;
%     allmvpre(:,i) = mv;
%     allgauParamspre(:,:,:,:,:,i) = gauParams;
%     allhalfMaxpre(:,:,:,:,i) = halfMax;
%     allareapeakspre(:,:,:,:,i) = areapeaks;
%     load(fullfile(ptsdir,ptsfile{i}));
%     for j=1:length(x)
%         alltracespre(j,:,:,:,:,:,:,i) = squeeze(nanmean(nanmean(trialcycavg(y(j)-2:y(j)+2,x(j)-2:x(j)+2,:,:,:,:,:,:),1),2));
%     end
% end
% 
avgtrialcycavgpre = nanmean(alltrialcycavgpre,9);%group mean frames by trial
setrialcycavgpre = nanstd(alltrialcycavgpre,9)/sqrt(length(datafiles));%group standard error
avgpeakspre = nanmean(allpeakspre,7);
sepeakspre = nanstd(allpeakspre,7)/sqrt(length(datafiles));
avgtracespre = nanmean(alltracespre,8);
setracespre = nanstd(alltracespre,8)/sqrt(length(datafiles));
avgmvpre = nanmean(allmvpre,2);
semvpre = nanstd(allmvpre,2)/sqrt(length(datafiles));
avggauParamspre = nanmean(allgauParamspre,6);
segauParamspre = nanstd(allgauParamspre,6)/sqrt(length(datafiles));
avghalfMaxpre = nanmean(allhalfMaxpre,5);
sehalfMaxpre = nanstd(allhalfMaxpre,5)/sqrt(length(datafiles));
avgareapeakspre = nanmean(allareapeakspre,5);
seareapeakspre = nanstd(allareapeakspre,5)/sqrt(length(datafiles));
% 
% alltrialcycavgpost = zeros(260,260,acqdurframes+acqdurframes/2,length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(datafiles));
% allpeakspost = zeros(length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
% alltracespost = zeros(length(areas),acqdurframes+acqdurframes/2,length(sfrange),length(phaserange),length(contrastRange),length(radiusRange),2,length(datafiles));
% allgauParamspost = zeros(length(contrastRange),length(radiusRange),2,length(areas),5,length(datafiles));
% allhalfMaxpost = zeros(length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
% allareapeakspost = zeros(length(contrastRange),length(radiusRange),2,length(areas),length(datafiles));
% for i= 1:length(datafiles) %collates all conditions (numbered above) 
%     load(fullfile(postdir,datafiles{i}),'trialcycavg','peaks','mv','areapeaks','gauParams','halfMax')
%     alltrialcycavgpost(:,:,:,:,:,:,:,:,i) = trialcycavg;
%     allpeakspost(:,:,:,:,:,:,i) = peaks;
%     allmvpost(:,i) = mv;
%     allgauParamspost(:,:,:,:,:,i) = gauParams;
%     allhalfMaxpost(:,:,:,:,i) = halfMax;
%     allareapeakspost(:,:,:,:,i) = areapeaks;
%     load(fullfile(ptsdir,ptsfile{i}));
%     for j=1:length(x)
%         alltracespost(j,:,:,:,:,:,:,i) = squeeze(nanmean(nanmean(trialcycavg(y(j)-2:y(j)+2,x(j)-2:x(j)+2,:,:,:,:,:,:),1),2));
%     end
% end
% 
avgtrialcycavgpost = nanmean(alltrialcycavgpost,9);%group mean frames by trial
setrialcycavgpost = nanstd(alltrialcycavgpost,9)/sqrt(length(datafiles));%group standard error
avgpeakspost = nanmean(allpeakspost,7);
sepeakspost = nanstd(allpeakspost,7)/sqrt(length(datafiles));
avgtracespost = nanmean(alltracespost,8);
setracespost = nanstd(alltracespost,8)/sqrt(length(datafiles));
avgmvpost = nanmean(allmvpost,2);
semvpost = nanstd(allmvpost,2)/sqrt(length(datafiles));
avggauParamspost = nanmean(allgauParamspost,6);
segauParamspost = nanstd(allgauParamspost,6)/sqrt(length(datafiles));
avghalfMaxpost = nanmean(allhalfMaxpost,5);
sehalfMaxpost = nanstd(allhalfMaxpost,5)/sqrt(length(datafiles));
avgareapeakspost = nanmean(allareapeakspost,5);
seareapeakspost = nanstd(allareapeakspost,5)/sqrt(length(datafiles));

for i = 1:length(sfrange)
    for j = 1:length(phaserange)
        for k = 1:length(contrastRange)
            for l = 1:length(radiusRange)
                for m = 1:2
                    for fr=1:size(avgtrialcycavgpre,3)
                        avgtrialcycavgpre(:,:,fr,i,j,k,l,m) = avgtrialcycavgpre(:,:,fr,i,j,k,l,m) - nanmean(avgtrialcycavgpre(:,:,1:acqdurframes/2,i,j,k,l,m),3);
                        avgtrialcycavgpost(:,:,fr,i,j,k,l,m) = avgtrialcycavgpost(:,:,fr,i,j,k,l,m) - nanmean(avgtrialcycavgpost(:,:,1:acqdurframes/2,i,j,k,l,m),3);
                    end
                end
            end
        end
    end
end

% % %plotting

%manual peaks
for m = 1:length(areas)
    figure
    cnt=0;
    for j = 1:2
        for i = 1:length(contrastRange)
            cnt = cnt+1;
            subplot(2,length(contrastRange),cnt)
            hold on
            errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(avgpeakspre(:,:,i,:,j,m),1),2)),squeeze(nanmean(nanmean(sepeakspre(:,:,i,:,j,m),1),2)),'ko')
            errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(avgpeakspost(:,:,i,:,j,m),1),2)),squeeze(nanmean(nanmean(sepeakspost(:,:,i,:,j,m),1),2)),'ro')
            set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
            xlabel('radius (deg)')
            ylabel('dfof')
            axis square
            axis([1 length(radiusRange) 0 0.1])
            legend(sprintf('%s contrast %s',contrastlist{i},behavState{j}),'Location','northoutside')
        end
    end
    mtit(sprintf('%s Manual Peaks',areas{m}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end   
end



% %peaks from autofind
for m = 1:length(areas)
    figure
    cnt=0;
    for j = 1:2
        for i = 1:length(contrastRange)
            cnt = cnt+1;
            subplot(2,length(contrastRange),cnt)
            hold on
            errorbar(1:length(radiusRange),squeeze(avgareapeakspre(i,:,j,m)),squeeze(seareapeakspre(i,:,j,m)),'ko')
            errorbar(1:length(radiusRange),squeeze(avgareapeakspost(i,:,j,m)),squeeze(seareapeakspost(i,:,j,m)),'ro')
            set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
            xlabel('radius (deg)')
            ylabel('dfof')
            axis square
            axis([1 length(radiusRange) 0 0.1])
            legend(sprintf('%s contrast %s',contrastlist{i},behavState{j}),'Location','northoutside')
        end
    end
    mtit(sprintf('%s Auto Peaks',areas{m}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end   
end


%spread of points above half max
for m = 1:length(areas)
    figure
    cnt=0;
    for j = 1:2
        for i = 1:length(contrastRange)
            cnt = cnt+1;
            subplot(2,length(contrastRange),cnt)
            hold on
            errorbar(1:length(radiusRange),squeeze(avghalfMaxpre(i,:,j,m)),squeeze(sehalfMaxpre(i,:,j,m)),'ko')
            errorbar(1:length(radiusRange),squeeze(avghalfMaxpost(i,:,j,m)),squeeze(sehalfMaxpost(i,:,j,m)),'ro')
            set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
            xlabel('radius (deg)')
            ylabel('dfof')
            axis square
            axis([1 length(radiusRange) 0 25000])
            legend(sprintf('%s contrast %s',contrastlist{i},behavState{j}),'Location','northoutside')
        end
    end
    mtit(sprintf('%s Area Above Half Max',areas{m}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end   
end


%average x/y sigma from gaussian
for m = 1:length(areas)
    figure
    cnt=0;
    for j = 1:2
        for i = 1:length(contrastRange)
            cnt = cnt+1;
            subplot(2,length(contrastRange),cnt)
            gaupremean = squeeze(avggauParamspre(i,:,j,m,4))+squeeze(avggauParamspre(i,:,j,m,5))/2;
            gaupresem = squeeze(segauParamspre(i,:,j,m,4))+squeeze(segauParamspre(i,:,j,m,5))/2;
            gaupostmean = squeeze(avggauParamspost(i,:,j,m,4))+squeeze(avggauParamspost(i,:,j,m,5))/2;
            gaupostsem = squeeze(segauParamspost(i,:,j,m,4))+squeeze(segauParamspost(i,:,j,m,5))/2;
                hold on
                errorbar(1:length(radiusRange),gaupremean,gaupresem,'ko')
                errorbar(1:length(radiusRange),gaupostmean,gaupostsem,'ro')
                set(gca,'Xtick',1:length(radiusRange),'Xticklabel',sizes)
            xlabel('radius (deg)')
            ylabel('dfof')
            axis square
            axis([1 length(radiusRange) 0 50])
            legend(sprintf('%s contrast %s',contrastlist{i},behavState{j}),'Location','northoutside')
        end
    end
    mtit(sprintf('%s Sigma from Gaussian',areas{m}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end


%plot activity maps for the different contrasts/running, with rows=radius
for i=1:2
    for j=1:length(contrastRange)
        figure
        cnt=1;
        for k=1:length(radiusRange)
            for l=plotrange
                subplot(length(radiusRange),length(plotrange),cnt)
                    imagesc(squeeze(nanmean(nanmean(avgtrialcycavgpre(:,:,l,:,:,j,k,i),4),5)),[0 0.15])
                    colormap(jet)
                    axis square
                    axis off
                    set(gca,'LooseInset',get(gca,'TightInset'))
                    hold on; plot(ypts,xpts,'w.','Markersize',2)
                    cnt=cnt+1;
            end
        end
        mtit(sprintf('PRE %s %s contrast row=size',behavState{i},contrastlist{j}))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
    end
end

for i=1:2
    for j=1:length(contrastRange)
        figure
        cnt=1;
        for k=1:length(radiusRange)
            for l=plotrange
                subplot(length(radiusRange),length(plotrange),cnt)
                    imagesc(squeeze(nanmean(nanmean(avgtrialcycavgpost(:,:,l,:,:,j,k,i),4),5)),[0 0.15])
                    colormap(jet)
                    axis square
                    axis off
                    set(gca,'LooseInset',get(gca,'TightInset'))
                    hold on; plot(ypts,xpts,'w.','Markersize',2)
                    cnt=cnt+1;
            end
        end
        mtit(sprintf('POST %s %s contrast row=size',behavState{i},contrastlist{j}))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
    end
end

xstim = [acqdurframes/2-1 acqdurframes/2-1];
ystim = [-0.1 0.5];

% for m = 1:length(areas)
    for i=1:2
        for j=1:length(contrastRange)
            figure
            cnt=1;
            for k=1:length(radiusRange)
                subplot(2,4,cnt)
                hold on
                shadedErrorBar(timepts,squeeze(nanmean(nanmean(avgtracespre(1,:,:,:,j,k,i),3),4)),squeeze(nanmean(nanmean(setracespre(1,:,:,:,j,k,i),4),5)),'-k',1)
                shadedErrorBar(timepts,squeeze(nanmean(nanmean(avgtracespost(1,:,:,:,j,k,i),3),4)),squeeze(nanmean(nanmean(setracespost(1,:,:,:,j,k,i),4),5)),'-r',1)
                plot(xstim,ystim,'g-')
                set(gca,'LooseInset',get(gca,'TightInset'))
                axis([0 max(timepts) -0.05 0.2])
                legend(sprintf('%s deg',sizes{k}),'Location','northoutside')
                hold off
                cnt=cnt+1;
            end
            mtit(sprintf('V1 %s %s contrast',behavState{i},contrastlist{j}))
            if exist('psfilename','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilename,'-append');
            end
        end
    end
% end

%%get percent time running
figure
errorbar([1 2],[avgmvpre avgmvpost],[semvpre semvpost]);
ylabel('fraction running')
ylim([0 1]);
set(gca,'xtick',[1 2],'xticklabel',{'Pre','Post'})
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

% save(fullfile(ptsdir,filename),'alltrialcycavgpre','allpeakspre','alltracespre','allgauParamspre','allhalfMaxpre','allareapeakspre','allmvpre',...
%     'alltrialcycavgpost','allpeakspost','alltracespost','allgauParamspost','allhalfMaxpost','allareapeakspost','allmvpost','-v7.3');
    try
        dos(['ps2pdf ' 'c:\temp.ps "' fullfile(ptsdir,sprintf('%s.pdf',filename)) '"'] )

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