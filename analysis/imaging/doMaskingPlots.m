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
            

psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

load('C:/mapoverlay.mat');
xpts = xpts/4;
ypts = ypts/4;
moviename = 'C:\metamask2sf2theta4soa15min';
load(moviename);
xpos=xpos(:,2:end); sf=sf(2:end,:); lag=lag(:,2:end); dOri=dOri(:,2:end);

%load pre data
alltrialcycpre = zeros(65,65,10,863,length(datafiles));        
for i= 1:length(datafiles) %collates all conditions (numbered above) 
    load(fullfile(predir,datafiles{i}),'trialcyc');%load data
    alltrialcycpre(:,:,:,:,i) = trialcyc;
end

avgtrialcycpre = mean(alltrialcycpre,5); %group mean frames by trial
setrialcycpre = std(alltrialcycpre,[],5)/sqrt(length(datafiles)); %group standard error

%load post data
alltrialcycpost = zeros(65,65,10,863,length(datafiles));        
for i= 1:length(datafiles) %collates all conditions (numbered above) 
    load(fullfile(postdir,datafiles{i}),'trialcyc');%load data
    alltrialcycpost(:,:,:,:,i) = trialcyc;
end
load(fullfile(postdir,datafiles{i}),'sfcombo','xrange','sfrange','lagrange','dOrirange','sfcomborange')

avgtrialcycpost = mean(alltrialcycpost,5); %group mean frames by trial
setrialcycpost = std(alltrialcycpost,[],5)/sqrt(length(datafiles)); %group standard error

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

sflist = [0 0; 0 0.04; 0 0.16; 0.04 0; 0.04 0.04; 0.04 0.16; 0.16 0; 0.16 0.04; 0.16 0.16];
%plot group average maps pre
 for i = 1:length(sfcomborange)
    figure        
    cnt = 1;
    %plots for dOri=0
    for j = 1:length(lagrange)
        for k = 1:5
            subplot(8,5,cnt)
            imagesc(squeeze(mean(avgtrialcycpre(:,:,k,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(1))),4)),[0 0.2])
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
        for k = 1:5
            subplot(8,5,cnt)
            imagesc(squeeze(mean(avgtrialcycpre(:,:,k,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(2))),4)),[0 0.2])
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
        for k = 1:5
            subplot(8,5,cnt)
            imagesc(squeeze(mean(avgtrialcycpost(:,:,k,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(1))),4)),[0 0.2])
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
        for k = 1:5
            subplot(8,5,cnt)
            imagesc(squeeze(mean(avgtrialcycpost(:,:,k,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(2))),4)),[0 0.2])
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
        shadedErrorBar(1:10,squeeze(mean(avgtrialcycpre(y(1),x(1),:,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(1))),4)),...
        squeeze(mean(setrialcycpre(y(1),x(1),:,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(1))),4)),'-k',1);
        axis([1 10 -0.05 0.2]);
        shadedErrorBar(1:10,squeeze(mean(avgtrialcycpost(y(1),x(1),:,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(1))),4)),...
        squeeze(mean(setrialcycpost(y(1),x(1),:,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(1))),4)),'-r',1);
        axis([1 10 -0.05 0.2]);
        legend(sprintf('%0.0flag',lagrange(j)),'Location','north')
        set(gca,'LooseInset',get(gca,'TightInset'))
        hold off
        cnt=cnt+1;
    end
    %plots for dOri=pi/2
    for j = 1:length(lagrange)
        subplot(2,4,cnt)
        hold on
        shadedErrorBar(1:10,squeeze(mean(avgtrialcycpre(y(1),x(1),:,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(2))),4)),...
        squeeze(mean(setrialcycpre(y(1),x(1),:,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(2))),4)),'-k',1);
        shadedErrorBar(1:10,squeeze(mean(avgtrialcycpost(y(1),x(1),:,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(2))),4)),...
        squeeze(mean(setrialcycpost(y(1),x(1),:,find(xpos==xrange(1)&sfcombo==i&lag==lagrange(j)&dOri==dOrirange(2))),4)),'-r',1);
        axis([1 10 -0.05 0.2]);
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


%%%plot responses in 7 visual areas
for i = 1:length(lagrange)
    figure  
    for j = 1:length(sfcomborange)
        subplot(3,3,j) 
        hold on
        for k = 1:length(x)
            plot(squeeze(mean(avgtrialcycpre(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)));
            axis([1 10 -0.1 0.2]);
        end
    end
    mtit(sprintf('PRE 0-dtheta %0.0flag',lagrange(i)))
    legend('V1','P','LM','AL','RL','AM','PM')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end

for i = 1:length(lagrange)
    figure  
    for j = 1:length(sfcomborange)
        subplot(3,3,j) 
        hold on
        for k = 1:length(x)
            plot(squeeze(mean(avgtrialcycpre(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(2))),4)));
            axis([1 10 -0.1 0.2]);
        end
    end
    mtit(sprintf('PRE pi/2-dtheta %0.0flag',lagrange(i)))
    legend('V1','P','LM','AL','RL','AM','PM')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end

for i = 1:length(lagrange)
    figure  
    for j = 1:length(sfcomborange)
        subplot(3,3,j) 
        hold on
        for k = 1:length(x)
            plot(squeeze(mean(avgtrialcycpost(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)));
            axis([1 10 -0.1 0.2]);
        end
    end
    mtit(sprintf('POST 0-dtheta %0.0flag',lagrange(i)))
    legend('V1','P','LM','AL','RL','AM','PM')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end

for i = 1:length(lagrange)
    figure  
    for j = 1:length(sfcomborange)
        subplot(3,3,j) 
        hold on
        for k = 1:length(x)
            plot(squeeze(mean(avgtrialcycpost(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(2))),4)));
            axis([1 10 -0.1 0.2]);
        end
    end
    mtit(sprintf('POST pi/2-dtheta %0.0flag',lagrange(i)))
    legend('V1','P','LM','AL','RL','AM','PM')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end

areas = {'V1','P','LM','AL','RL','AM','PM'};
for i = 1:length(lagrange)
    for j = 1:length(sfcomborange)
        figure  
        for k = 1:length(x)
            subplot(2,4,k) 
            hold on
            shadedErrorBar(1:10,squeeze(mean(avgtrialcycpre(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)),...
                squeeze(mean(setrialcycpre(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)),'-k',1);
                shadedErrorBar(1:10,squeeze(mean(avgtrialcycpost(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)),...
                squeeze(mean(setrialcycpost(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)),'-r',1);
            axis([1 10 -0.1 0.2]);
            legend(areas(k))
        end
        mtit(sprintf('Pre/PostDOI %0.2ftarget %0.2fmask %0.0flag',sflist(j,1),sflist(j,2),lagrange(i)))
        if exist('psfilename','var')
            set(gcf, 'PaperPositionMode', 'auto');
            print('-dpsc',psfilename,'-append');
        end
    end
end
     
    
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
% save(fullfile(predir,nam),'alltrialcycpre','alltrialcycpost');
ps2pdf('psfile', psfilename, 'pdffile', fullfile(predir,sprintf('%s.pdf',nam)));
