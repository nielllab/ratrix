%This code performs averaging over animals for masking stimulus
%It takes in the output files of analyzeMasking
%PRLP 02/01/2016 Niell Lab

predir = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\Trained Pre';
postdir = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\Trained Post';
datafiles = {'021316_G62R9TT_RIG2_DOI_MaskingAnalysis.mat',...
            '021316_G62TX2.6LT_RIG2_DOI_MaskingAnalysis.mat',...
            '021316_G62TX2.6RT_RIG2_DOI_MaskingAnalysis.mat',...
            '021515_G62BB2RT_RIG2_DOI_MaskingAnalysis.mat',...
            '021516_G62T6LT_RIG2_DOI_MaskingAnalysis.mat',...
            '021716_G62W7LN_RIG2_DOI_MaskingAnalysis.mat',...
            '021716_G62W7TT_RIG2_DOI_MaskingAnalysis.mat'};
ptsfile = {'G62R9TT_MaskingPoints.mat',...
          'G62TX2.6LT_MaskingPoints.mat',...
          'G62TX2.6RT_MaskingPoints.mat',...
          'G62BB2RT_MaskingPoints.mat',...
          'G62T6LT_MaskingPoints.mat',...
          'G62W7LN_MaskingPoints.mat',...
          'G62W7TT_MaskingPoints.mat'};            

psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

load('C:/mapoverlay.mat');
xpts = xpts/4;
ypts = ypts/4;
moviename = 'C:\metamask2sf2theta4soa15min';
load(moviename);
xpos=xpos(:,2:end); sf=sf(2:end,:); lag=lag(:,2:end); dOri=dOri(:,2:end);
areas = {'V1','P','LM','AL','RL','AM','PM'};

%load pre data
alltrialcycavgpre = zeros(65,65,15,2,9,4,2,length(datafiles));
allpeakspre = zeros(2,9,4,2,length(datafiles));
alltracespre = zeros(7,15,2,9,4,2,length(datafiles));
allgauSigmapre = zeros(2,9,4,2,length(areas),2,length(datafiles));
allhalfMaxpre = zeros(2,9,4,2,length(areas),length(datafiles));
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


%load post data
alltrialcycavgpost = zeros(65,65,15,2,9,4,2,length(datafiles));
allpeakspost = zeros(2,9,4,2,length(datafiles));
alltracespost = zeros(7,15,2,9,4,2,length(datafiles));
allgauSigmapost = zeros(2,9,4,2,length(areas),2,length(datafiles));
allhalfMaxpost = zeros(2,9,4,2,length(areas),length(datafiles));
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

avgtrialcycavgpost = mean(alltrialcycavgpost,8);%group mean frames by trial
setrialcycavgpost = std(alltrialcycavgpost,[],8)/sqrt(length(datafiles));%group standard error
avgpeakspost = mean(allpeakspost,4);
sepeakspost = std(allpeakspost,[],4)/sqrt(length(datafiles));
avgtracespost = mean(alltracespost,7);
setracespost = std(alltracespost,[],7)/sqrt(length(datafiles));
avgmvpre = mean(allmvpre,2);
semvpre = std(allmvpost,[],2)/sqrt(length(datafiles));
avggauSigmapost = mean(allgauSigmapost,7);
segauSigmapost = std(allgauSigmapost,[],7)/sqrt(length(datafiles));
avghalfMaxpost = mean(allhalfMaxpost,6);
sehalfMaxpost = std(allhalfMaxpost,[],6)/sqrt(length(datafiles));

load(fullfile(postdir,datafiles{i}),'sfcombo','xrange','sfrange','lagrange','dOrirange','sfcomborange')
sflist = [0 0; 0 0.04; 0 0.16; 0.04 0; 0.04 0.04; 0.04 0.16; 0.16 0; 0.16 0.04; 0.16 0.16];

load('\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect\GroupMaskingPoints.mat');

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

%     %get peak values for all 7 visual areas, separate out by sfcombo, lag and dOri
%     avgareapeakspre = zeros(size(avgtracespre,1),length(sfcomborange),length(lagrange),length(dOrirange));
%     seareapeakspre = zeros(size(avgtracespre,1),length(sfcomborange),length(lagrange),length(dOrirange));
%     avgareapeakspost = zeros(size(avgtracespre,1),length(sfcomborange),length(lagrange),length(dOrirange));
%     seareapeakspost = zeros(size(avgtracespre,1),length(sfcomborange),length(lagrange),length(dOrirange));
%     for i = 1:length(sfcomborange)
%         for j = 1:length(lagrange)
%             for k = 1:length(dOrirange)
%                 for l = 1:size(avgtracespre,1)
%                     avgareapeakspre(l,i,j,k) = avgtracespre(l,6,1,i,j,k);
%                     seareapeakspre(l,i,j,k) = setracespre(l,6,1,i,j,k);
%                     avgareapeakspost(l,i,j,k) = avgtracespost(l,6,1,i,j,k);
%                     seareapeakspost(l,i,j,k) = setracespost(l,6,1,i,j,k);
%                 end
%             end
%         end
%     end
  
targetmask = zeros(size(avgtrialcycpre,1),size(avgtrialcycpre,2),3);
targetmask(:,:,1) = squeeze(mean(mean(avgtrialcycavgpre(:,:,6,1,4,:,:),6),7)); %target only
targetmask(:,:,2) = squeeze(mean(mean(avgtrialcycavgpre(:,:,6,1,2,:,:),6),7)); %mask only
targetmask(:,:,1)=targetmask(:,:,1)/max(max(targetmask(:,:,1))); %normalize to 1
targetmask(:,:,2)=targetmask(:,:,2)/max(max(targetmask(:,:,2)));

figure
subplot(1,3,1)
imshow(targetmask(:,:,1),'InitialMagnification','fit')
hold on; plot(ypts,xpts,'w.','Markersize',2)
% plot(x,y,'ro')
axis square
title('target only (red)')
subplot(1,3,2)
imshow(targetmask(:,:,2),'InitialMagnification','fit')
hold on; plot(ypts,xpts,'w.','Markersize',2)
% plot(x,y,'ro')
axis square
title('mask only (green)')
subplot(1,3,3)
imshow(targetmask,'InitialMagnification','fit')
hold on; plot(ypts,xpts,'w.','Markersize',2)
% plot(x,y,'ro')
axis square
title('overlay')
mtit('PRE DOI')
set(gca,'LooseInset',get(gca,'TightInset'))
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

targetmask = zeros(size(avgtrialcycpre,1),size(avgtrialcycpre,2),3);
targetmask(:,:,1) = squeeze(mean(mean(avgtrialcycavgpost(:,:,6,1,4,:,:),6),7)); %target only
targetmask(:,:,2) = squeeze(mean(mean(avgtrialcycavgpost(:,:,6,1,2,:,:),6),7)); %mask only
targetmask(:,:,1)=targetmask(:,:,1)/max(max(targetmask(:,:,1))); %normalize to 1
targetmask(:,:,2)=targetmask(:,:,2)/max(max(targetmask(:,:,2)));

figure
subplot(1,3,1)
imshow(targetmask(:,:,1),'InitialMagnification','fit')
hold on; plot(ypts,xpts,'w.','Markersize',2)
% plot(x,y,'ro')
axis square
title('target only (red)')
subplot(1,3,2)
imshow(targetmask(:,:,2),'InitialMagnification','fit')
hold on; plot(ypts,xpts,'w.','Markersize',2)
% plot(x,y,'ro')
axis square
title('mask only (green)')
subplot(1,3,3)
imshow(targetmask,'InitialMagnification','fit')
hold on; plot(ypts,xpts,'w.','Markersize',2)
% plot(x,y,'ro')
axis square
title('overlay')
mtit('POST DOI')
if exist('psfilename','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
end

    %plot peak values pre/post doi
    for h = 1:length(areas)
        figure
        for i = 1:length(sfcomborange)
                subplot(3,3,i)
                hold on
                errorbar(avgpeakspre(h,i,:,1),sepeakspre(h,i,:,1),'k.')
                errorbar(avgpeakspost(h,i,:,1),sepeakspost(h,i,:,1),'r.')
                set(gca,'Xtick',1:4,'Xticklabel',[0 32 64 96])
                xlabel('SOA (ms)')
                ylabel(sprintf('%0.2fT %0.2fM',sflist(i,1),sflist(i,2)))
                axis square
                axis([1 4 -0.05 0.2])
        end
        mtit(sprintf('%s peak pre vs. post 9 sf combos dOri=0',areas{h}))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
        figure
        for i = 1:length(sfcomborange)
                subplot(3,3,i)
                hold on
                errorbar(avgpeakspre(h,i,:,2),sepeakspre(h,i,:,2),'k.')
                errorbar(avgpeakspost(h,i,:,2),sepeakspost(h,i,:,2),'r.')
                set(gca,'Xtick',1:4,'Xticklabel',[0 32 64 96])
                xlabel('SOA (ms)')
                ylabel(sprintf('%0.2fT %0.2fM',sflist(i,1),sflist(i,2)))
                axis square
                axis([1 4 -0.05 0.2])
        end
        mtit(sprintf('%s peak pre vs. post 9 sf combos dOri=pi/2',areas{h}))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
    end

%plot group average maps pre
 for i = 1:length(sfcomborange)
    figure        
    cnt = 1;
    %plots for dOri=0
    for j = 1:length(lagrange)
        for k = 5:9
            subplot(8,5,cnt)
            imagesc(avgtrialcycavgpre(:,:,k,1,i,j,1),[0 0.2])
            colormap(jet)
            axis square
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            cnt=cnt+1;
        end
    end
    %plots for dOri=pi/2
    for j = 1:length(lagrange)
        for k = 5:9
            subplot(8,5,cnt)
            imagesc(avgtrialcycavgpre(:,:,k,1,i,j,2),[0 0.2])
            colormap(jet)
            axis square
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            cnt=cnt+1;
        end
    end
    mtit(sprintf('PRE Row=Lag,Top4=0Bot4=pi/2 %0.2ftarget %0.2fmask',sflist(i,1),sflist(i,2)))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
 end
 
 %plot group average maps post
 for i = 1:length(sfcomborange)
    figure        
    cnt = 1;
    %plots for dOri=0
    for j = 1:length(lagrange)
        for k = 5:9
            subplot(8,5,cnt)
            imagesc(avgtrialcycavgpost(:,:,k,1,i,j,1),[0 0.2])
            colormap(jet)
            axis square
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            cnt=cnt+1;
        end
    end
    %plots for dOri=pi/2
    for j = 1:length(lagrange)
        for k = 5:9
            subplot(8,5,cnt)
            imagesc(avgtrialcycavgpost(:,:,k,1,i,j,2),[0 0.2])
            colormap(jet)
            axis square
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            cnt=cnt+1;
        end
    end
    mtit(sprintf('POST Row=Lag,Top4=0Bot4=pi/2 %0.2ftarget %0.2fmask',sflist(i,1),sflist(i,2)))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
 end

%plot average V1 response 
for i = 1:length(sfcomborange)
    figure
    cnt = 1;
    %plots for dOri=0
    for j = 1:length(lagrange)
        subplot(2,4,cnt)
        hold on
        shadedErrorBar(1:15,avgtracespre(1,:,1,i,j,1),setracespre(1,:,1,i,j,1),'-k',1);
        shadedErrorBar(1:15,avgtracespost(1,:,1,i,j,1),setracespost(1,:,1,i,j,1),'-r',1);
        axis([1 15 -0.05 0.3]);
        legend(sprintf('%0.0flag',lagrange(j)),'Location','north')
        set(gca,'LooseInset',get(gca,'TightInset'))
        hold off
        cnt=cnt+1;
    end
    %plots for dOri=pi/2
    for j = 1:length(lagrange)
        subplot(2,4,cnt)
        hold on
        shadedErrorBar(1:15,avgtracespre(1,:,1,i,j,2),setracespre(1,:,1,i,j,2),'-k',1);
        shadedErrorBar(1:15,avgtracespost(1,:,1,i,j,2),setracespost(1,:,1,i,j,2),'-r',1);
        axis([1 15 -0.05 0.3]);
        legend(sprintf('%0.0flag',lagrange(j)),'Location','north')
        set(gca,'LooseInset',get(gca,'TightInset'))
        hold off
        cnt=cnt+1;
    end
    mtit(sprintf('Top4=0Bot4=pi/2 %0.2ftarget %0.2fmask',sflist(i,1),sflist(i,2)))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end

%plot average response for each visual area
for i = 1:length(lagrange)
    for j = 1:length(sfcomborange)
        figure  
        for k = 1:length(x)
            subplot(2,4,k) 
            hold on
            shadedErrorBar(1:15,avgtracespre(k,:,1,j,i,1),setracespre(k,:,1,j,i,1),'-k',1);
            shadedErrorBar(1:15,avgtracespost(k,:,1,j,i,1),setracespost(k,:,1,j,i,1),'-r',1);
            axis([1 15 -0.1 0.3]);
            legend(areas(k))
        end
        mtit(sprintf('Pre/PostDOI dOri=0 %0.2ftarget %0.2fmask %0.0flag',sflist(j,1),sflist(j,2),lagrange(i)))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
    end
end
%same for pi/2
areas = {'V1','P','LM','AL','RL','AM','PM'};
for i = 1:length(lagrange)
    for j = 1:length(sfcomborange)
        figure  
        for k = 1:length(x)
            subplot(2,4,k) 
            hold on
            shadedErrorBar(1:15,avgtracespre(k,:,1,j,i,2),setracespre(k,:,1,j,i,2),'-k',1);
            shadedErrorBar(1:15,avgtracespost(k,:,1,j,i,2),setracespost(k,:,1,j,i,2),'-r',1);
            axis([1 15 -0.1 0.3]);
            legend(areas(k))
        end
        mtit(sprintf('Pre/PostDOI dOri=pi/2 %0.2ftarget %0.2fmask %0.0flag',sflist(j,1),sflist(j,2),lagrange(i)))
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

% %%%plot responses in 7 visual areas
% for i = 1:length(lagrange)
%     figure  
%     for j = 1:length(sfcomborange)
%         subplot(3,3,j) 
%         hold on
%         for k = 1:length(x)
%             plot(squeeze(mean(avgtrialcycpre(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)));
%             axis([1 15 -0.1 0.3]);
%         end
%     end
%     mtit(sprintf('PRE 0-dtheta %0.0flag',lagrange(i)))
%     legend('V1','P','LM','AL','RL','AM','PM')
%     if exist('psfilename','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfilename,'-append');
%     end
% end
% 
% for i = 1:length(lagrange)
%     figure  
%     for j = 1:length(sfcomborange)
%         subplot(3,3,j) 
%         hold on
%         for k = 1:length(x)
%             plot(squeeze(mean(avgtrialcycpre(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(2))),4)));
%             axis([1 15 -0.1 0.3]);
%         end
%     end
%     mtit(sprintf('PRE pi/2-dtheta %0.0flag',lagrange(i)))
%     legend('V1','P','LM','AL','RL','AM','PM')
%     if exist('psfilename','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfilename,'-append');
%     end
% end
% 
% for i = 1:length(lagrange)
%     figure  
%     for j = 1:length(sfcomborange)
%         subplot(3,3,j) 
%         hold on
%         for k = 1:length(x)
%             plot(squeeze(mean(avgtrialcycpost(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)));
%             axis([1 15 -0.1 0.3]);
%         end
%     end
%     mtit(sprintf('POST 0-dtheta %0.0flag',lagrange(i)))
%     legend('V1','P','LM','AL','RL','AM','PM')
%     if exist('psfilename','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfilename,'-append');
%     end
% end
% 
% for i = 1:length(lagrange)
%     figure  
%     for j = 1:length(sfcomborange)
%         subplot(3,3,j) 
%         hold on
%         for k = 1:length(x)
%             plot(squeeze(mean(avgtrialcycpost(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(2))),4)));
%             axis([1 15 -0.1 0.3]);
%         end
%     end
%     mtit(sprintf('POST pi/2-dtheta %0.0flag',lagrange(i)))
%     legend('V1','P','LM','AL','RL','AM','PM')
%     if exist('psfilename','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfilename,'-append');
%     end
% end

% 
% %plots for dOri=pi/2
% for i = 1:length(lagrange)
%     figure
%     cnt = 1;
%     for j = 1:length(sfcomborange)
%         for k = 1:5
%             subplot(9,5,cnt)
%             imagesc(squeeze(mean(avgtrialcyc(:,:,k,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(2))),4)),[0 0.2])
%             colormap(jet)
%             axis square
%             axis off
%             set(gca,'LooseInset',get(gca,'TightInset'))
%             hold on; plot(ypts,xpts,'w.','Markersize',2)
%             cnt=cnt+1;
%         end
%     end
%     mtit(sprintf('Group Mean pi/2-dtheta %0.0flag',lagrange(i)))
%     if exist('psfilename','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfilename,'-append');
%     end
% end




%plot V1 responses with standard error
%  for i = 1:length(lagrange)
%     figure  
%     for j = 1:length(sfcomborange)
%         subplot(3,3,j) 
%         hold on
%         for k = 1:length(x)
%             shadedErrorBar(1:10,squeeze(mean(avgtrialcyc(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)),...
%                 squeeze(mean(setrialcyc(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)));
%             axis([1 10 -0.05 0.1]);
%         end
%     end
%     mtit(sprintf('Group Mean 0-dtheta %0.0flag',lagrange(i)))
%     legend('V1','LM','AL','RL','A','AM','PM')
%     if exist('psfilename','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfilename,'-append');
%     end
%  end
%  
%   for i = 1:length(lagrange)
%     figure  
%     for j = 1:length(sfcomborange)
%         subplot(3,3,j) 
%         hold on
%         for k = 1:length(x)
%             plot(squeeze(mean(avgtrialcyc(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(2))),4)));
%             axis([1 10 -0.05 0.1]);
%         end
%     end
%     mtit(sprintf('Group Mean pi/2-dtheta %0.0flag',lagrange(i)))
%     legend('V1','LM','AL','RL','A','AM','PM')
%     if exist('psfilename','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfilename,'-append');
%     end
%  end
        
% %plot V1 point all traces too look for outliers
%  for i = 1:length(lagrange)
%     figure  
%     for j = 1:length(sfcomborange)
%         subplot(3,3,j) 
%         hold on
%         for k = 1:length(x)
%             plot(squeeze(avgtrialcyc(y(1),x(1),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1)))));
%             axis([1 10 -0.05 0.1]);
%         end
%     end
%     mtit(sprintf('Group Mean 0-dtheta %0.0flag',lagrange(i)))
%     legend('V1','LM','AL','RL','A','AM','PM')
%     if exist('psfilename','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfilename,'-append');
%     end
%  end
 
    
nam = 'CompareMasking';
save(fullfile(predir,nam),'alltrialcycpre','alltrialcycpost');
ps2pdf('psfile', psfilename, 'pdffile', fullfile(predir,sprintf('%s.pdf',nam)));
