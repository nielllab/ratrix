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

alltrialcycpre = zeros(65,65,20,384,length(datafiles));
alltrialcycavgpre = zeros(65,65,20,2,6,2,2,length(datafiles));
for i= 1:length(datafiles) %collates all conditions (numbered above) 
    load(fullfile(predir,datafiles{i}),'trialcyc','trialcycavg');%load data
    alltrialcycpre(:,:,:,:,i) = trialcyc;
    alltrialcycavgpre(:,:,:,:,:,:,:,i) = trialcycavg;
end

avgtrialcycpre = mean(alltrialcycpre,5); %group mean frames by trial
setrialcycpre = std(alltrialcycpre,[],5)/sqrt(length(datafiles)); %group standard error
avgtrialcycavgpre = mean(alltrialcycavgpre,7);
setrialcycavgpre = std(alltrialcycavgpre,[],7)/sqrt(length(datafiles));

alltrialcycpost = zeros(65,65,20,384,length(datafiles));
alltrialcycavgpost = zeros(65,65,20,2,6,2,2,length(datafiles));
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

%plot activity maps for the different tf/sf combinations, with rows=radius
    for i=1:length(sfrange)
        for j=1:length(tfrange)
            figure
            cnt=1;
            for k=1:length(radiusRange)
                for l=10:19
                    subplot(6,10,cnt)
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
                for l=10:19
                    subplot(6,10,cnt)
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

    xstim = [2 2];
    ystim = [-0.1 0.4];

    for i=1:length(sfrange)
        for j=1:length(tfrange)
            figure
            cnt=1;
            for k=1:length(radiusRange)
                subplot(2,3,cnt)
                hold on
                shadedErrorBar([1:10]',squeeze(mean(avgtrialcycpre(y(1),x(1),10:19,find(xpos==xrange(1)&radius==radius(k)&sf==sfrange(i)&tf==tfrange(j))),4)),...
                    squeeze(mean(setrialcycpre(y(1),x(1),10:19,find(xpos==xrange(1)&radius==radius(k)&sf==sfrange(i)&tf==tfrange(j))),4))/...
                    sqrt(length(find(xpos==xrange(1)&radius==radius(k)&sf==sfrange(i)&tf==tfrange(j)))),'-k',1)
                shadedErrorBar([1:10]',squeeze(mean(avgtrialcycpost(y(1),x(1),10:19,find(xpos==xrange(1)&radius==radius(k)&sf==sfrange(i)&tf==tfrange(j))),4)),...
                    squeeze(mean(setrialcycpost(y(1),x(1),10:19,find(xpos==xrange(1)&radius==radius(k)&sf==sfrange(i)&tf==tfrange(j))),4))/...
                    sqrt(length(find(xpos==xrange(1)&radius==radius(k)&sf==sfrange(i)&tf==tfrange(j)))),'-r',1)
                plot(xstim,ystim,'g-')
                set(gca,'LooseInset',get(gca,'TightInset'))
                cnt=cnt+1;
                axis([1 10 -0.05 0.4])
                legend(sprintf('%0.0frad',radiusRange(k)))
                hold off
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
