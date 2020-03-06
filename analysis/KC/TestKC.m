close all
clear all
warning off

batchNEW_KC
cd(pathname)

grpnames = {'pre','post'}; %set the group names here
pplb = {'pre','post'}; % plot labels

use = find(strcmp({files.subj},'CALB2CK2G6H83LN') & strcmp({files.expt},'022120')); % use = 1 b/c find returns index
allsubj = {files(use).subj}

s=1:1;
doTopography

xshift = allxshift(use);
yshift = allyshift(use);
tshift = allthetashift(use);

save(files(use).topox,'xshift','yshift','tshift','x0','y0','sz','-append')

psfile = 'F:\Kristen\tempKrisWF.ps';
if exist(psfile,'file')==2;delete(psfile);end

%% Quantification

load(files(use).topox,'map'); 

resamp=2; %how much to downsample maps by
ampthresh = 0.005; %threshold for phase correlation/display for topox/y
mrng = [-0.01 0.05]; %display range for imagesc of maps

grpmaps = zeros(2,10,size(map{1},1)/resamp,size(map{1},2)/resamp);grpamp=grpmaps; %(group,animal,mapx-dim,mapy-dim)
grptx = zeros(2,10,size(map{1},1)/resamp,size(map{1},2)/resamp);grpty=grptx;
grpcc = zeros(2,10);grpccx=grpcc;grpccy=grpcc;combcc=grpcc; %correlation coefficients

zoom = 1;%260/size(dfof_bg,1); should be same as in doTopography
f1=figure;set(gcf,'color','w');

%% where loop would start?

cnt=1;

load(files(use).topox,'map','xshift','yshift','tshift','x0','y0','sz'); % variables defined above
length(map)==3 % why defining the length of the map? Or does this say find which column in map = 3? (each cell contains a double)

img = imresize(map{3},1/resamp);
img = shiftImageRotate(img,xshift+x0,yshift+y0,tshift,zoom,sz);
data(:,:,1) = img;

load(files(use).topoy,'map');
img = imresize(map{3},1/resamp);
img = shiftImageRotate(img,xshift+x0,yshift+y0,tshift,zoom,sz);
data(:,:,2) = img;

% sign map analysis
ph = angle(data);
ph(ph<0)= ph(ph<0)+2*pi;

        for i = 1:2;
            [x y] = gradient(ph(:,:,i));
            dx(:,:,i) = x; %imresize(x,[size(ph,1) size(ph,2)])
            dy(:,:,i)= y; %imresize(y,[size(ph,1) size(ph,2)]);
        end

mapsign = dx(:,:,1).*dy(:,:,2) - dy(:,:,1).*dx(:,:,2);
mapsign(isnan(mapsign))=0;

mag = sqrt(dx.^2 + dy.^2);
dx = dx./mag; dy = dy./mag;
gradamp = sqrt(mag(:,:,1).*mag(:,:,2));
mapsign = mapsign./(gradamp.^2);

amp = sqrt(abs(data(:,:,1)).*abs(data(:,:,2)));
amp = amp/prctile(amp(:),99);
amp(amp>1)=1;
        
% cut off heaplate ring
[X,Y] = meshgrid(1:size(data,2),1:size(data,1));%Xp = X;
dist = sqrt((X - size(data,2)/2).^2 + (Y - size(data,1)/2).^2);
img = mapsign.*amp; %sign map analysis
% img = real(squeeze(data(:,:,1))); %x/y only analysis
img(dist>90) = NaN; %chose 90 pixels for circle just by eye, maybe height/2.88 or width/3.55?
% img(dist>90&Xp|Xp>size(Xp,2)/2) = NaN; %chose 90 pixels for circle just by eye, maybe height/2.88 or width/3.55?

grpmaps(use,use,:,:) = img; %sign map for correlation of visual area boundaries across groups
grpamp(use,use,:,:) = amp; %amplitude map to look for changes across groups

% get x/y phase and threshold only above min amp
% correlate raw phase, also plot each one

tx = squeeze(data(:,:,1));grptx(use,use,:,:) = tx; %tx(dist>90) = NaN; %% should be group #, animal #
xamp = abs(tx);tx=polarMap(tx);%tx(dist>90) = NaN;
ty = squeeze(data(:,:,2));grpty(use,use,:,:) = ty;%ty(dist>90) = NaN;
yamp = abs(ty);ty=polarMap(ty);%ty(dist>90) = NaN;     
        
subplot(2,3,cnt)
imshow(img);axis off;axis image;
title('sign')
set(gca,'LooseInset',get(gca,'TightInset'))
cnt=cnt+1;
subplot(2,3,cnt)
imshow(tx);axis off;axis image;
title('topox')
set(gca,'LooseInset',get(gca,'TightInset'))
cnt=cnt+1;
subplot(2,3,cnt)
imshow(ty);axis off;axis image;
title('topoy')
set(gca,'LooseInset',get(gca,'TightInset'))
cnt=cnt+1;
        
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end

%%% amplitude differences
figure; colormap jet
amp_range = [0 0.02];
delta_amp_range = [-0.01 0.01];
subplot(2,4,1)
tx = squeeze(nanmean(grptx(use,:,:,1),2));tx1=abs(tx);
imagesc(tx1,amp_range);axis off;axis image;
title('pre topox')
set(gca,'LooseInset',get(gca,'TightInset'))
subplot(2,4,2)
tx = squeeze(nanmean(grptx(use,:,:,2),2));tx2=abs(tx);
imagesc(tx2,amp_range);axis off;axis image;
title(sprintf('post topox cc=%0.3f',nanmean(grpccx(use,:))))
set(gca,'LooseInset',get(gca,'TightInset'))

subplot(2,4,3)
imagesc(tx2 - tx1,delta_amp_range);axis off;axis image; % IS THIS where the subtrraction post - pre is taking place?
title(sprintf('post - pre X'))
set(gca,'LooseInset',get(gca,'TightInset')); hold on; plot(ypts,xpts,'k.','Markersize',1); 
    
subplot(2,4,4)
imagesc((tx2 - tx1)./(tx1 + tx2),[-.2 .2]);axis off;axis image;
title(sprintf('post - pre index X'))
set(gca,'LooseInset',get(gca,'TightInset')); hold on; plot(ypts,xpts,'k.','Markersize',1);
    
subplot(2,4,5)
ty = squeeze(nanmean(grpty(use,:,:,1),2));ty1=abs(ty); % IVE BEEN deleting one ':' in grptx/y ...
imagesc(ty1,amp_range);axis off;axis image;
title('pre topoy')
set(gca,'LooseInset',get(gca,'TightInset'))
subplot(2,4,6)
ty = squeeze(nanmean(grpty(use,:,:,2),2));ty2=abs(ty);
imagesc(ty2,amp_range);axis off;axis image;
title(sprintf('post topoy cc=%0.3f',nanmean(grpccy(use,:))))
set(gca,'LooseInset',get(gca,'TightInset'))
mtit(sprintf('%s',grpnames{use}))
    
subplot(2,4,7)
imagesc(ty2 - ty1,delta_amp_range);axis off;axis image;
title(sprintf('post - pre Y'))
set(gca,'LooseInset',get(gca,'TightInset')); hold on; plot(ypts,xpts,'k.','Markersize',1); 
    
subplot(2,4,8)
imagesc((ty2 - ty1)./(ty1 + ty2),[-.2 .2]);axis off;axis image;
title(sprintf('post - pre  index Y'))
set(gca,'LooseInset',get(gca,'TightInset')); hold on; plot(ypts,xpts,'k.','Markersize',1); 

%%% group quanitification
figure(f1)
subplot(2,2,1)
hold on
plot(use*ones(1,1),grpcc(use,1:1),'ko','MarkerSize',15) % BOTH WERE 1:numAni before
errorbar(use,nanmean(grpcc(use,1:1)),nanstd(grpcc(use,1:1))/sqrt(1),'k.','LineWidth',1,'MarkerSize',20)
    
subplot(2,2,2)
hold on
plot(use*ones(1,1),grpccx(use,1:1),'ko','MarkerSize',15)   % WERE numAni before
errorbar(use,nanmean(grpccx(use,1:1)),nanstd(grpccx(use,1:1))/sqrt(1),'k.','LineWidth',1,'MarkerSize',20)

subplot(2,2,3)
hold on
plot(use*ones(1,1),grpccy(use,1:1),'ko','MarkerSize',15)
errorbar(use,nanmean(grpccy(use,1:1)),nanstd(grpccy(use,1:1))/sqrt(1),'k.','LineWidth',1,'MarkerSize',20)

subplot(2,2,4)
combcc(use,1:1) = (grpccx(use,1:1)+grpccy(use,1:1))/2;
hold on
plot(use*ones(1,1),combcc(use,1:1),'ko','MarkerSize',15)
errorbar(use,nanmean(combcc(use,1:1)),nanstd(combcc(use,1:1))/sqrt(1),'k.','LineWidth',1,'MarkerSize',20)

figure(f1)
subplot(2,2,1)
title('sign cc')
axis([0 5 0 1]);axis square
set(gca,'xtick',1:length(grpnames),'xticklabel',grpnames,'ytick',0:0.25:1,'fontsize',12,'tickdir','out')
ylabel('pre/post map correlation')
subplot(2,2,2)
title('ccx')
axis([0 5 0 1]);axis square
set(gca,'xtick',1:length(grpnames),'xticklabel',grpnames,'ytick',0:0.25:1,'fontsize',12,'tickdir','out')
ylabel('pre/post map correlation')
subplot(2,2,3)
title('ccy')
axis([0 5 0 1]);axis square
set(gca,'xtick',1:length(grpnames),'xticklabel',grpnames,'ytick',0:0.25:1,'fontsize',12,'tickdir','out')
ylabel('pre/post map correlation')
subplot(2,2,4)
title('x/y cc')
axis([0 5 0 1]);axis square
set(gca,'xtick',1:length(grpnames),'xticklabel',grpnames,'ytick',0:0.25:1,'fontsize',12,'tickdir','out')
ylabel('pre/post map correlation')

if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end


%% stats

%%%non-parametric test
[p,tbl,stats] = kruskalwallis(combcc')

%%%tukey kramer post-hoc
[c,m,h,gnames] = multcompare(stats)

%%%unpaired ttest
% group1 = [1];
%  group2 = [2];
% sprintf('alpha = %0.4f',0.05/4)
% for i = 1:length(group1)
%     grp1 = combcc(group1(i),:);grp1 = grp1(~isnan(grp1));
% %     grp2 = combcc(group2(i),:);grp2 = grp2(~isnan(grp2));
%     [h,p] = ttest2(grp1,grp2,'alpha',0.05/4);
%     sprintf('%s vs %s p = %0.4f',grpnames{group1(i)},grpnames{group2(i)},p)
% end

%% save pdf

try
    dos(['ps2pdf ' psfile ' "' 'TESTprepostTopo.pdf' '"'])
catch
    display('couldnt generate pdf');
end

delete(psfile);
    
