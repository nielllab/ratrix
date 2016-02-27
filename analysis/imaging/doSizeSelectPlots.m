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

psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

load('C:/mapoverlay.mat');
xpts = xpts/4;
ypts = ypts/4;
moviename = 'C:\sizeSelect2sf5sz14min';
load(moviename);

alltrialcycpre = zeros(65,65,30,384,length(datafiles));
alltrialcycavgpre = zeros(65,65,30,2,6,2,2,length(datafiles));
for i= 1:length(datafiles) %collates all conditions (numbered above) 
    load(fullfile(predir,datafiles{i}),'trialcyc','trialcycavg');%load data
    alltrialcycpre(:,:,:,:,i) = trialcyc;
    alltrialcycavgpre(:,:,:,:,:,:,:,i) = trialcycavg;
end

avgtrialcycpre = mean(alltrialcycpre,5); %group mean frames by trial
setrialcycpre = std(alltrialcycpre,[],5)/sqrt(length(datafiles)); %group standard error
avgtrialcycavgpre = mean(alltrialcycavgpre,7);
setrialcycavgpre = std(alltrialcycavgpre,[],7)/sqrt(length(datafiles));

alltrialcycpost = zeros(65,65,30,384,length(datafiles));
alltrialcycavgpost = zeros(65,65,30,2,6,2,2,length(datafiles));
for i= 1:length(datafiles) %collates all conditions (numbered above) 
    load(fullfile(postdir,datafiles{i}),'trialcyc','trialcycavg');%load data
    alltrialcycpost(:,:,:,:,i) = trialcyc;
    alltrialcycavgpost(:,:,:,:,:,:,:,i) = trialcycavg;
end
load(fullfile(postdir,datafiles{i}),'trialcyc','trialcycavg','tuning','xrange','radiusRange','sfrange','tfrange')

avgtrialcycpost = mean(alltrialcycpost,5); %group mean frames by trial
setrialcycpost = std(alltrialcycpost,[],5)/sqrt(length(datafiles)); %group standard error
avgtrialcycavgpost = mean(alltrialcycavgpost,7);
setrialcycavgpost = std(alltrialcycavgpost,[],7)/sqrt(length(datafiles));

for  i = 1:length(avgtrialcycpre)
    for fr=1:30
    avgtrialcycpre(:,:,fr,i) = avgtrialcycpre(:,:,fr,i) - mean(avgtrialcycpre(:,:,1:9,i),3);
    avgtrialcycpost(:,:,fr,i) = avgtrialcycpost(:,:,fr,i) - mean(avgtrialcycpost(:,:,1:9,i),3);
    end
end

load('\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\SizeSelectPointsG6BLIND3B12LT.mat');
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
% x = floor(x/4); y = floor(y/4);

%%get peak response - baseline for all conditions
    peakspre = nan(length(xrange),length(radiusRange),length(sfrange),length(tfrange));
    peakspost = nan(length(xrange),length(radiusRange),length(sfrange),length(tfrange));
    for i = 1:length(xrange)
        for j = 1:length(radiusRange)
            for k = 1:length(sfrange)
                for l = 1:length(tfrange)
                    peakspre(i,j,k,l) = mean(avgtrialcycpre(y(1),x(1),12,find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l))),4);%-...
                        %mean(avgtrialcycpre(y(1),x(1),5,find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l))),4);
                    peakspost(i,j,k,l) = mean(avgtrialcycpost(y(1),x(1),12,find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l))),4);%-...
                        %mean(avgtrialcycpost(y(1),x(1),5,find(xpos==xrange(i)&radius==j&sf==sfrange(k)&tf==tfrange(l))),4);
                end
            end
        end
    end
    
    cnt=0;
    figure
    for k = 1:length(sfrange)
        for l = 1:length(tfrange)
            cnt = cnt+1;
            subplot(2,2,cnt)
            hold on
            plot(peakspre(1,:,k,l),'ko')
            plot(peakspost(1,:,k,l),'ro')
            set(gca,'Xtick',1:6,'Xticklabel',[0 1 2 4 8 1000])
            xlabel('radius')
            ylabel('dfof')
            axis square
            axis([1 6 -0.05 0.5])
            legend(sprintf('%0.2fsf %0.0ftf',sfrange(k),tfrange(l)),'Location','northoutside')
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
                shadedErrorBar([1:30]',squeeze(mean(avgtrialcycpre(y(1),x(1),:,find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j))),4)),...
                    squeeze(mean(setrialcycpre(y(1),x(1),:,find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j))),4))/...
                    sqrt(length(find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j)))),'-k',1)
                shadedErrorBar([1:30]',squeeze(mean(avgtrialcycpost(y(1),x(1),:,find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j))),4)),...
                    squeeze(mean(setrialcycpost(y(1),x(1),:,find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j))),4))/...
                    sqrt(length(find(xpos==xrange(1)&radius==k&sf==sfrange(i)&tf==tfrange(j)))),'-r',1)
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
 
    
nam = 'CompareSizeSelect';
% save(fullfile(dir,nam),'avgtrialcyc','setrialcyc','avgtrialcycavg','setrialcycavg');
ps2pdf('psfile', psfilename, 'pdffile', fullfile(predir,sprintf('%s.pdf',nam)));
