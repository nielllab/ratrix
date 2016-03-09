%This code performs averaging over animals for size select stimulus
%It takes in the output files of analyzeSizeSelect
%PRLP 02/01/2016 Niell Lab
predir = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\Trained Pre';
postdir = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\Trained Post';
datafiles = {'021316_G62TX2.6LT_RIG2_DOI_SizeSelectAnalysis.mat',...
            '021316_G62TX2.6RT_RIG2_DOI_SizeSelectAnalysis.mat',...
            '021515_G62BB2RT_RIG2_DOI_SizeSelectAnalysis.mat',...
            '021516_G62T6LT_RIG2_DOI_SizeSelectAnalysis.mat',...
            '021716_G62W7LN_RIG2_DOI_SizeSelectAnalysis.mat',...
            '021716_G62W7TT_RIG2_DOI_SizeSelectAnalysis.mat'};
ptsfile = {'G62TX2.6LT_SizeSelectPoints.mat',...
          'G62TX2.6RT_SizeSelectPoints.mat',...
          'G62BB2RT_SizeSelectPoints.mat',...
          'G62T6LT_SizeSelectPoints.mat',...
          'G62W7LN_SizeSelectPoints.mat',...
          'G62W7TT_SizeSelectPoints.mat'};

psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

load('C:/mapoverlay.mat');
% xpts = xpts/4;
% ypts = ypts/4;
moviename = 'C:\sizeSelect2sf5sz14min';
load(moviename);
pointsfile = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\GroupSizeSelectPoints';
load(pointsfile);
areas = {'V1','P','LM','AL','RL','AM','PM'};

alltrialcycavgpre = zeros(260,260,30,2,6,2,2,length(datafiles));
allpeakspre = zeros(2,6,2,2,length(datafiles));
alltracespre = zeros(7,30,2,6,2,2,length(datafiles));
allgauSigmapre = zeros(2,6,2,2,length(areas),2,length(datafiles));
allhalfMaxpre = zeros(2,6,2,2,length(areas),length(datafiles));
for i= 1:length(datafiles) %collates all conditions (numbered above) 
    load(fullfile(predir,datafiles{i}),'trialcycavg','peaks','mv','gauSigma','halfMax');%load data
    alltrialcycavgpre(:,:,:,:,:,:,:,i) = trialcycavg;
    allpeakspre(:,:,:,:,i) = peaks;
    allmvpre(:,i) = mv;
    allgauSigmapre(:,:,:,:,:,:,i) = gauSigma;
    allhalfMaxpre(:,:,:,:,:,i) = halfMax;
    load(fullfile(predir,ptsfile{i}));
    for j=1:length(x)
        alltracespre(j,:,:,:,:,:,i) = squeeze(trialcycavg(y(j),x(j),:,:,:,:,:));
    end
end

avgtrialcycavgpre = mean(alltrialcycavgpre,8);%group mean frames by trial
setrialcycavgpre = std(alltrialcycavgpre,[],8)/sqrt(length(datafiles));%group standard error
avgpeakspre = mean(allpeakspre,5);
sepeakspre = std(allpeakspre,[],5)/sqrt(length(datafiles));
avgtracespre = mean(alltracespre,7);
setracespre = std(alltracespre,[],7)/sqrt(length(datafiles));
avgmvpre = mean(allmvpre,2);
semvpre = std(allmvpre,[],2)/sqrt(length(datafiles));
avggauSigmapre = mean(allgauSigmapre,7);
segauSigmapre = std(allgauSigmapre,[],7)/sqrt(length(datafiles));
avghalfMaxpre = mean(allhalfMaxpre,6);
sehalfMaxpre = std(allhalfMaxpre,[],6)/sqrt(length(datafiles));

alltrialcycavgpost = zeros(260,260,30,2,6,2,2,length(datafiles));
allpeakspost = zeros(2,6,2,2,length(datafiles));
alltracespost = zeros(7,30,2,6,2,2,length(datafiles));
allgauSigmapost = zeros(2,6,2,2,length(areas),2,length(datafiles));
allhalfMaxpost = zeros(2,6,2,2,length(areas),length(datafiles));
for i= 1:length(datafiles) %collates all conditions (numbered above) 
    load(fullfile(postdir,datafiles{i}),'trialcycavg','peaks','mv','gauSigma','halfMax');%load data
    alltrialcycavgpost(:,:,:,:,:,:,:,i) = trialcycavg;
    allpeakspost(:,:,:,:,i) = peaks;
    allmvpost(:,i) = mv;
    allgauSigmapost(:,:,:,:,:,:,i) = gauSigma;
    allhalfMaxpost(:,:,:,:,:,i) = halfMax;
    load(fullfile(predir,ptsfile{i}));
    for j=1:length(x)
        alltracespost(j,:,:,:,:,:,i) = squeeze(trialcycavg(y(j),x(j),:,:,:,:,:));
    end
end
load(fullfile(postdir,datafiles{i}),'xrange','radiusRange','sfrange','tfrange')

avgtrialcycavgpost = mean(alltrialcycavgpost,8);%group mean frames by trial
setrialcycavgpost = std(alltrialcycavgpost,[],8)/sqrt(length(datafiles));%group standard error
avgpeakspost = mean(allpeakspost,5);
sepeakspost = std(allpeakspost,[],5)/sqrt(length(datafiles));
avgtracespost = mean(alltracespost,7);
setracespost = std(alltracespost,[],7)/sqrt(length(datafiles));
avgmvpost = mean(allmvpre,2);
semvpost = std(allmvpost,[],2)/sqrt(length(datafiles));
avggauSigmapost = mean(allgauSigmapost,7);
segauSigmapost = std(allgauSigmapost,[],7)/sqrt(length(datafiles));
avghalfMaxpost = mean(allhalfMaxpost,6);
sehalfMaxpost = std(allhalfMaxpost,[],6)/sqrt(length(datafiles));

for i = 1:length(xrange)
    for j = 1:length(radiusRange)
        for k = 1:length(sfrange)
            for l = 1:length(tfrange)
                for fr=1:size(avgtrialcycavgpre,3)
                    avgtrialcycavgpre(:,:,fr,i,j,k,l) = avgtrialcycavgpre(:,:,fr,i,j,k,l) - mean(avgtrialcycavgpre(:,:,1:9,i,j,k,l),3);
                    avgtrialcycavgpost(:,:,fr,i,j,k,l) = avgtrialcycavgpost(:,:,fr,i,j,k,l) - mean(avgtrialcycavgpost(:,:,1:9,i,j,k,l),3);
                end
            end
        end
    end
end
 
cnt=0;
figure
for i = 1:length(sfrange)
    for j = 1:length(tfrange)
            cnt = cnt+1;
            subplot(2,2,cnt)
            hold on
            errorbar(1:length(radiusRange),avgpeakspre(1,:,i,j),sepeakspre(1,:,i,j),'ko')
            errorbar(1:length(radiusRange),avgpeakspost(1,:,i,j),sepeakspost(1,:,i,j),'ro')
            set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
            xlabel('radius')
            ylabel('dfof')
            axis square
            axis([1 6 -0.05 0.5])
            legend(sprintf('%0.2fsf %0.0ftf',sfrange(i),tfrange(j)),'Location','northoutside')
    end
end
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end   

cnt=0;
figure
for i = 1:length(sfrange)
    for j = 1:length(tfrange)
            cnt = cnt+1;
            subplot(2,2,cnt)
            hold on
            errorbar(1:length(radiusRange),avghalfMaxpre(1,:,i,j,1),sehalfMaxpre(1,:,i,j,1),'ko')
            errorbar(1:length(radiusRange),avghalfMaxpost(1,:,i,j,1),sehalfMaxpost(1,:,i,j,1),'ro')
            set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
            xlabel('radius')
            ylabel('Area Above Half Max')
            axis square
            axis([1 6 0 4000])
            legend(sprintf('%0.2fsf %0.0ftf',sfrange(i),tfrange(j)),'Location','northoutside')
    end
end
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end   

cnt=0;
figure
for i = 1:length(sfrange)
    for j = 1:length(tfrange)
            cnt = cnt+1;
            subplot(2,2,cnt)
            hold on
            errorbar(1:length(radiusRange),squeeze(mean(avggauSigmapre(1,:,i,j,1,:),6)),squeeze(mean(segauSigmapre(1,:,i,j,1,:),6)),'ko')
            errorbar(1:length(radiusRange),squeeze(mean(avggauSigmapost(1,:,i,j,1,:),6)),squeeze(mean(segauSigmapost(1,:,i,j,1,:),6)),'ro')
            set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
            xlabel('radius')
            ylabel('Sigma')
            axis square
            axis([1 6 0 10])
            legend(sprintf('%0.2fsf %0.0ftf',sfrange(i),tfrange(j)),'Location','northoutside')
    end
end
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end 


%plot activity maps for the different tf/sf combinations, with rows=radius
    for i=1:length(sfrange)
        for j=1:length(tfrange)
            figure
            cnt=1;
            for k=1:length(radiusRange)
                for l=10:14
                    subplot(6,5,cnt)
                        imagesc(avgtrialcycavgpre(:,:,l,1,k,i,j),[0 0.15])
                        colormap(jet)
                        axis square
                        axis off
                        set(gca,'LooseInset',get(gca,'TightInset'))
                        hold on; plot(ypts,xpts,'w.','Markersize',2)
                        cnt=cnt+1;
                end
            end
            mtit(sprintf('PRE %0.2fsf %0.0ftf row=size',sfrange(i),tfrange(j)))
            if exist('psfilename','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilename,'-append');
            end
        end
    end
    
    for i=1:length(sfrange)
        for j=1:length(tfrange)
            figure
            cnt=1;
            for k=1:length(radiusRange)
                for l=10:14
                    subplot(6,5,cnt)
                        imagesc(avgtrialcycavgpost(:,:,l,1,k,i,j),[0 0.15])
                        colormap(jet)
                        axis square
                        axis off
                        set(gca,'LooseInset',get(gca,'TightInset'))
                        hold on; plot(ypts,xpts,'w.','Markersize',2)
                        cnt=cnt+1;
                end
            end
            mtit(sprintf('POST %0.2fsf %0.0ftf row=size',sfrange(i),tfrange(j)))
            if exist('psfilename','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilename,'-append');
            end
        end
    end

    xstim = [11 11];
    ystim = [-0.1 0.5];

    for i=1:length(sfrange)
        for j=1:length(tfrange)
            figure
            cnt=1;
            for k=1:length(radiusRange)
                subplot(2,3,cnt)
                hold on
                shadedErrorBar([1:30]',avgtracespre(1,:,1,k,i,j),setracespre(1,:,1,k,i,j),'-k',1)
                shadedErrorBar([1:30]',avgtracespost(1,:,1,k,i,j),setracespost(1,:,1,k,i,j),'-r',1)
                plot(xstim,ystim,'g-')
                set(gca,'LooseInset',get(gca,'TightInset'))
                axis([1 30 -0.05 0.5])
                legend(sprintf('%0.0frad',radiusRange(k)))
                hold off
                cnt=cnt+1;
             end
            mtit(sprintf('group %0.2fsf %0.0ftf',sfrange(i),tfrange(j)))
            if exist('psfilename','var')
                set(gcf, 'PaperPositionMode', 'auto');
                print('-dpsc',psfilename,'-append');
            end
        end
    end
    
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

 
    
nam = 'CompareSizeSelect';
save(fullfile(predir,nam),'avgtrialcycavgpre','setrialcycavgpre','avgpeakspre','sepeakspre','avgtracespre','setracespre','avgtrialcycavgpost','setrialcycavgpost','avgpeakspost','sepeakspost','avgtracespost','setracespost');
ps2pdf('psfile', psfilename, 'pdffile', fullfile(predir,sprintf('%s.pdf',nam)));



%%old code
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
%     imagesc(squeeze(mean(trialcyc(:,:,2,find(sfcombo~=1)),4)),[0 0.05])
% %     imagesc(squeeze(mean(avgtrialcyc(:,:,2,find(sfcombo==7)),4)),[0 0.1])
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