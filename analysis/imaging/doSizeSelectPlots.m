%This code performs averaging over animals for size select stimulus
%It takes in the output files of analyzeSizeSelect
%PRLP 02/01/2016 Niell Lab
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

predir = '\\langevin\backup\widefield\DOI_experiments\PhilSizeSelect\PREdecon';
postdir = '\\langevin\backup\widefield\DOI_experiments\PhilSizeSelect\POSTdecon';

datafiles = {''};

psfilename = 'c:\temp.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

load('C:\mapoverlay.mat');
% xpts = xpts/4;
% ypts = ypts/4;
moviename = 'C:\sizeSelect2sf8sz26min.mat';
load(moviename);
pointsfile = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\GroupSizeSelectPoints';
load(pointsfile);
areas = {'V1','P','LM','AL','RL','AM','PM'};

alltrialcycavgpre = zeros(260,260,30,2,6,2,2,length(datafiles));
allpeakspre = zeros(2,6,2,2,length(areas),length(datafiles));
alltracespre = zeros(7,30,2,6,2,2,length(datafiles));
allgauParamspre = zeros(2,6,2,2,length(areas),5,length(datafiles));
allhalfMaxpre = zeros(2,6,2,2,length(areas),length(datafiles));
allareapeakspre = zeros(2,6,2,2,length(areas),length(datafiles));
for i= 1:length(datafiles) %collates all conditions (numbered above) 
    load(fullfile(predir,datafiles{i}),'trialcycavg','peaks','areapeaks','mv','gauParams','halfMax');%load data
    alltrialcycavgpre(:,:,:,:,:,:,:,i) = trialcycavg;
    allpeakspre(:,:,:,:,:,i) = peaks;
    allmvpre(:,i) = mv;
    allgauParamspre(:,:,:,:,:,:,i) = gauParams;
    allhalfMaxpre(:,:,:,:,:,i) = halfMax;
    allareapeakspre(:,:,:,:,:,i) = areapeaks;
    load(fullfile(predir,ptsfile{i}));
    for j=1:length(x)
        alltracespre(j,:,:,:,:,:,i) = squeeze(trialcycavg(y(j),x(j),:,:,:,:,:));
    end
end

avgtrialcycavgpre = mean(alltrialcycavgpre,8);%group mean frames by trial
setrialcycavgpre = std(alltrialcycavgpre,[],8)/sqrt(length(datafiles));%group standard error
avgpeakspre = mean(allpeakspre,6);
sepeakspre = std(allpeakspre,[],6)/sqrt(length(datafiles));
avgtracespre = mean(alltracespre,7);
setracespre = std(alltracespre,[],7)/sqrt(length(datafiles));
avgmvpre = mean(allmvpre,2);
semvpre = std(allmvpre,[],2)/sqrt(length(datafiles));
avggauParamspre = mean(allgauParamspre,7);
segauParamspre = std(allgauParamspre,[],7)/sqrt(length(datafiles));
avghalfMaxpre = mean(allhalfMaxpre,6);
sehalfMaxpre = std(allhalfMaxpre,[],6)/sqrt(length(datafiles));
avgareapeakspre = mean(allareapeakspre,6);
seareapeakspre = std(allareapeakspre,[],6)/sqrt(length(datafiles));

alltrialcycavgpost = zeros(260,260,30,2,6,2,2,length(datafiles));
allpeakspost = zeros(2,6,2,2,length(areas),length(datafiles));
alltracespost = zeros(7,30,2,6,2,2,length(datafiles));
allgauParamspost = zeros(2,6,2,2,length(areas),5,length(datafiles));
allhalfMaxpost = zeros(2,6,2,2,length(areas),length(datafiles));
allareapeakspost = zeros(2,6,2,2,length(areas),length(datafiles));
for i= 1:length(datafiles) %collates all conditions (numbered above) 
    load(fullfile(postdir,datafiles{i}),'trialcycavg','peaks','areapeaks','mv','gauParams','halfMax');%load data
    alltrialcycavgpost(:,:,:,:,:,:,:,i) = trialcycavg;
    allpeakspost(:,:,:,:,:,i) = peaks;
    allmvpost(:,i) = mv;
    allgauParamspost(:,:,:,:,:,:,i) = gauParams;
    allhalfMaxpost(:,:,:,:,:,i) = halfMax;
    allareapeakspost(:,:,:,:,:,i) = areapeaks;
    load(fullfile(predir,ptsfile{i}));
    for j=1:length(x)
        alltracespost(j,:,:,:,:,:,i) = squeeze(trialcycavg(y(j),x(j),:,:,:,:,:));
    end
end
load(fullfile(postdir,datafiles{i}),'xrange','radiusRange','sfrange','tfrange')

avgtrialcycavgpost = mean(alltrialcycavgpost,8);%group mean frames by trial
setrialcycavgpost = std(alltrialcycavgpost,[],8)/sqrt(length(datafiles));%group standard error
avgpeakspost = mean(allpeakspost,6);
sepeakspost = std(allpeakspost,[],6)/sqrt(length(datafiles));
avgtracespost = mean(alltracespost,7);
setracespost = std(alltracespost,[],7)/sqrt(length(datafiles));
avgmvpost = mean(allmvpost,2);
semvpost = std(allmvpost,[],2)/sqrt(length(datafiles));
avggauParamspost = mean(allgauParamspost,7);
segauParamspost = std(allgauParamspost,[],7)/sqrt(length(datafiles));
avghalfMaxpost = mean(allhalfMaxpost,6);
sehalfMaxpost = std(allhalfMaxpost,[],6)/sqrt(length(datafiles));
avgareapeakspost = mean(allareapeakspost,6);
seareapeakspost = std(allareapeakspost,[],6)/sqrt(length(datafiles));

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

%peaks from manual points
for m = 1:length(areas)
    figure
    cnt=0;
    for i = 1:length(sfrange)
        for j = 1:length(tfrange)
                cnt = cnt+1;
                subplot(2,2,cnt)
                hold on
                errorbar(1:length(radiusRange),avgpeakspre(1,:,i,j,m),sepeakspre(1,:,i,j,m),'ko')
                errorbar(1:length(radiusRange),avgpeakspost(1,:,i,j,m),sepeakspost(1,:,i,j,m),'ro')
                set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
                xlabel('radius')
                ylabel('dfof')
                axis square
                axis([1 6 0 0.5])
                legend(sprintf('%0.2fsf %0.0ftf',sfrange(i),tfrange(j)),'Location','northoutside')
        end
    end
    mtit(sprintf('%s Manual Peaks',areas{m}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end   
end

%peaks from autofind
for m = 1:length(areas)
    figure
    cnt=0;
    for i = 1:length(sfrange)
        for j = 1:length(tfrange)
                cnt = cnt+1;
                subplot(2,2,cnt)
                hold on
                errorbar(1:length(radiusRange),avgareapeakspre(1,:,i,j,m),seareapeakspre(1,:,i,j,m),'ko')
                errorbar(1:length(radiusRange),avgareapeakspost(1,:,i,j,m),seareapeakspost(1,:,i,j,m),'ro')
                set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
                xlabel('radius')
                ylabel('dfof')
                axis square
                axis([1 6 0 0.5])
                legend(sprintf('%0.2fsf %0.0ftf',sfrange(i),tfrange(j)),'Location','northoutside')
        end
    end
    mtit(sprintf('%s Autofind Peaks',areas{m}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end   
end

%spread of points above half max
for m = 1:length(areas)
    figure
    cnt=0;
    for i = 1:length(sfrange)
        for j = 1:length(tfrange)
                cnt = cnt+1;
                subplot(2,2,cnt)
                hold on
                errorbar(1:length(radiusRange),avghalfMaxpre(1,:,i,j,m),sehalfMaxpre(1,:,i,j,m),'ko')
                errorbar(1:length(radiusRange),avghalfMaxpost(1,:,i,j,m),sehalfMaxpost(1,:,i,j,m),'ro')
                set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
                xlabel('radius')
                axis square
                axis([1 6 0 5000])
                legend(sprintf('%0.2fsf %0.0ftf',sfrange(i),tfrange(j)),'Location','northoutside')
        end
        mtit(sprintf('%s Area Above Half Max',areas{m}))
    end
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end   
end


%average x/y sigma from gaussian
for m = 1:length(areas)
    figure
    cnt=0;
    for i = 1:length(sfrange)
        for j = 1:length(tfrange)
                cnt = cnt+1;
                subplot(2,2,cnt)
                hold on
                errorbar(1:length(radiusRange),(avggauParamspre(1,:,i,j,m,4)+avggauParamspre(1,:,i,j,m,5))/2,(segauParamspre(1,:,i,j,m,4)+segauParamspre(1,:,i,j,m,5))/2,'ko')
                errorbar(1:length(radiusRange),(avggauParamspost(1,:,i,j,m,4)+avggauParamspost(1,:,i,j,m,5))/2,(segauParamspost(1,:,i,j,m,4)+segauParamspost(1,:,i,j,m,5))/2,'ro')
                set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
                xlabel('radius')
                ylabel('Sigma')
                axis square
                axis([1 6 0 30])
                legend(sprintf('%0.2fsf %0.0ftf',sfrange(i),tfrange(j)),'Location','northoutside')
        end
    end
    mtit(sprintf('%s Sigma from Gaussian',areas{m}))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
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

 
    
filename = 'CALB25B5RTCompareSizeSelect';
save(fullfile(predir,filename),'alltrialcycavgpre','allpeakspre','alltracespre','allgauParamspre','allhalfMaxpre','allareapeakspre','allmvpre',...
    'alltrialcycavgpost','allpeakspost','alltracespost','allgauParamspost','allhalfMaxpost','allareapeakspost','allmvpost');
    try
        dos(['ps2pdf ' 'c:\temp.ps "' fullfile(p,sprintf('%s.pdf',filename)) '"'] )

    catch
        display('couldnt generate pdf');
    end



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