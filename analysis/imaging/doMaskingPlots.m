%This code performs averaging over animals for masking stimulus
%It takes in the output files of analyzeMasking
%PRLP 02/01/2016 Niell Lab
psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

load('C:/mapoverlay.mat');
xpts = xpts/4;
ypts = ypts/4;
moviename = 'C:\metamask2sf2theta4soa15min';
load(moviename);

dir = '\\langevin\backup\widefield\DOI_experiments\Masking_SizeSelect';
datafiles = {'112315_G6BLIND3B12LT_RIG2_DOI_MaskingAnalysis',...
            '121815_G6BLIND3B12LT_RIG2_DOI_MaskingAnalysis',...
            '122115_G6BLIND3B12LT_RIG2_DOI_MaskingAnalysis'};
% datafiles = {'121815_G6BLIND3B1LT_RIG2_DOI_MaskingAnalysis',...
%             '122115_G6BLIND3B1LT_RIG2_DOI_MaskingAnalysis'};

alltrialcyc = zeros(65,65,10,864,length(datafiles));        
for i= 1:length(datafiles) %collates all conditions (numbered above) 
    load(fullfile(dir,datafiles{i}),'trialcyc');%load data
    alltrialcyc(:,:,:,:,i) = trialcyc;
end
load(fullfile(dir,datafiles{i}),'sfcombo','xrange','sfrange','lagrange','dOrirange','sfcomborange')

avgtrialcyc = mean(alltrialcyc,5); %group mean frames by trial
setrialcyc = std(alltrialcyc,[],5)/sqrt(length(datafiles)); %group standard error

%plot group average maps
%plots for dOri=0
 for i = 1:length(lagrange)
    figure        
    cnt = 1;
    for j = 1:length(sfcomborange)
        for k = 1:5
            subplot(9,5,cnt)
            imagesc(squeeze(mean(avgtrialcyc(:,:,k,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)),[0 0.2])
            colormap(jet)
            axis square
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            cnt=cnt+1;
        end
    end
    mtit(sprintf('Group Mean 0-dtheta %0.0flag',lagrange(i)))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end

%plots for dOri=pi/2
for i = 1:length(lagrange)
    figure
    cnt = 1;
    for j = 1:length(sfcomborange)
        for k = 1:5
            subplot(9,5,cnt)
            imagesc(squeeze(mean(avgtrialcyc(:,:,k,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(2))),4)),[0 0.2])
            colormap(jet)
            axis square
            axis off
            set(gca,'LooseInset',get(gca,'TightInset'))
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            cnt=cnt+1;
        end
    end
    mtit(sprintf('Group Mean pi/2-dtheta %0.0flag',lagrange(i)))
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
end

% load('\\langevin\backup\widefield\DOI_experiments\Matlab Widefield Analysis\SalinePoints.mat');
% x = floor(x/4); y = floor(y/4);
[fname pname] = uigetfile('*.mat','points file');
if fname~=0
    load(fullfile(pname, fname));
else
    figure
    imagesc(squeeze(mean(trialcyc(:,:,2,find(sfcombo~=1)),4)),[0 0.05])
%     imagesc(squeeze(mean(avgtrialcyc(:,:,2,find(sfcombo==7)),4)),[0 0.1])
    colormap(jet);
    hold on; plot(ypts,xpts,'w.','Markersize',2)
    axis square
    [x y] = ginput(7);
    x = round(x);y = round(y);
    close(gcf);
    [fname pname] = uiputfile('*.mat','save points?');
    if fname~=0
        save(fullfile(pname,fname),'x','y');
    end
end


sflist = [0 0; 0 0.04; 0 0.16; 0.04 0; 0.04 0.04; 0.04 0.16; 0.16 0; 0.16 0.04; 0.16 0.16];

 for i = 1:length(lagrange)
    figure  
    for j = 1:length(sfcomborange)
        subplot(3,3,j) 
        hold on
        for k = 1:length(x)
            shadedErrorBar(1:10,squeeze(mean(avgtrialcyc(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(1))),4)));
            axis([1 10 -0.05 0.1]);
        end
    end
    mtit(sprintf('Group Mean 0-dtheta %0.0flag',lagrange(i)))
    legend('V1','LM','AL','RL','A','AM','PM')
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
            plot(squeeze(mean(avgtrialcyc(y(k),x(k),:,find(xpos==xrange(1)&sfcombo==j&lag==lagrange(i)&dOri==dOrirange(2))),4)));
            axis([1 10 -0.05 0.1]);
        end
    end
    mtit(sprintf('Group Mean pi/2-dtheta %0.0flag',lagrange(i)))
    legend('V1','LM','AL','RL','A','AM','PM')
    if exist('psfilename','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfilename,'-append');
    end
 end
        
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
save(fullfile(dir,nam),'alltrialcyc');
ps2pdf('psfile', psfilename, 'pdffile', fullfile(dir,sprintf('%s.pdf',nam)));
