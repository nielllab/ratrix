%% prepostTopo_KC
%%% this function takes topox/topoy widefield data and does a pre vs. post
%%% correlation on the signmap*amplitudes, then plots them across groups
close all; clear all;

batchNEW_KC % batchPatch_KC %select batch file %make a combined dreadds/caspase file
cd(pathname)

grpnames = {'pre','post'}; %set the group names here
pplb = {'pre','post'};
% pplb = {'dreadds','caspase'};

%select subset of animals
%use = find(strcmp({files.notes},'good data')&strcmp({files.timing},'pre'));
use = find(strcmp({files.inject},'CLOZ'));

alluse=use;
allsubj = unique({files(alluse).subj}); %needed for doTopography
s=1:1;doTopography

for f = 1:length(use)
    xshift = allxshift(f);
    yshift = allyshift(f);
    tshift = allthetashift(f);
    save(files(use(f)).topox,'xshift','yshift','tshift','x0','y0','sz','-append')
end

psfile = 'F:\Kristen\tempKrisWF.ps';
if exist(psfile,'file')==2;delete(psfile);end

%% quantification
load(files(use(1)).topox,'map'); %first expt to initialize variables
resamp=2; %how much to downsample maps by
ampthresh = 0.005; %threshold for phase correlation/display for topox/y
mrng = [-0.01 0.05]; %display range for imagesc of maps
grpmaps = zeros(2,10,size(map{1},1)/resamp,size(map{1},2)/resamp);grpamp=grpmaps; %(group,animal,mapx-dim,mapy-dim)
grptx = zeros(2,10,size(map{1},1)/resamp,size(map{1},2)/resamp);grpty=grptx;
grpcc = zeros(2,10);grpccx=grpcc;grpccy=grpcc;combcc=grpcc; %correlation coefficients
zoom = 1;%260/size(dfof_bg,1); should be same as in doTopography
f1=figure;set(gcf,'color','w');
for grp=1:2 %group loop (pre/post or hm4d vs. caspase)
    if grp==1
        use = find(strcmp({files.virus},'CAV-hM4Di')& strcmp({files.timing},'pre') & strcmp({files.inject},'CLOZ')); %make this dreadds (pre or post)
        grpfilename = 'pre'
        numAni = length(use);
    elseif grp==2
        use = find(strcmp({files.virus},'CAV-hM4Di') & strcmp({files.timing},'post') & strcmp({files.inject},'CLOZ')); %make this caspase
        grpfilename = 'post'
        numAni = length(use);
    end
    for animal = 1:length(use) %animal loop
        ani = animal;
%           figure;set(gcf,'color','w')
%           cnt=1;
        clear data

        load(files(use(grp)).topox,'map','xshift','yshift','tshift','x0','y0','sz');
        length(map)==3 %blue/green, take blue-green map
        img = imresize(map{3},1/resamp);
        img = shiftImageRotate(img,xshift+x0,yshift+y0,tshift,zoom,sz);
        data(:,:,1) = img;

        load(files(use(grp)).topoy,'map');
        img = imresize(map{3},1/resamp);
        img = shiftImageRotate(img,xshift+x0,yshift+y0,tshift,zoom,sz);
        data(:,:,2) = img;

        %sign map analysis
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

       %cut off heaplate ring
       [X,Y] = meshgrid(1:size(data,2),1:size(data,1));%Xp = X;
        dist = sqrt((X - size(data,2)/2).^2 + (Y - size(data,1)/2).^2);
        img = mapsign.*amp; %sign map analysis
%           img = real(squeeze(data(:,:,1))); %x/y only analysis
        img(dist>90) = NaN; %chose 90 pixels for circle just by eye, maybe height/2.88 or width/3.55?
%           img(dist>90&Xp|Xp>size(Xp,2)/2) = NaN; %chose 90 pixels for circle just by eye, maybe height/2.88 or width/3.55?

        grpmaps(grp,grp,:,:) = img; %sign map for correlation of visual area boundaries across groups
        grpamp(grp,grp,:,:) = amp; %amplitude map to look for changes across groups

        %get x/y phase and threshold only above min amp
        %correlate raw phase, also plot each one

        tx = squeeze(data(:,:,1));grptx(grp,:,:) = tx;%tx(dist>90) = NaN;
        xamp = abs(tx);tx=polarMap(tx);%tx(dist>90) = NaN;
        ty = squeeze(data(:,:,2));grpty(grp,:,:) = ty;%ty(dist>90) = NaN;
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

%         pre = squeeze(grpmaps(grp,ani,:,:,1));pre(dist>90) = NaN;pre=pre(:);pre=pre(~isnan(pre));
%         post = squeeze(grpmaps(grp,ani,:,:,2));post(dist>90) = NaN;post=post(:);post=post(~isnan(post));
%         cc = corr(pre,post);
%         grpcc(grp,ani) = cc;
%         
%         pre = squeeze(grptx(grp,ani,:,:,1));pre=pre(:);pre=pre(~isnan(pre));
%         post = squeeze(grptx(grp,ani,:,:,2));post=post(:);post=post(~isnan(post));
%         xcc = corr(pre,post);
%         grpccx(grp,ani) = abs(xcc);
%         
%         pre = squeeze(grpty(grp,ani,:,:,1));pre=pre(:);pre=pre(~isnan(pre));
%         post = squeeze(grpty(grp,ani,:,:,2));post=post(:);post=post(~isnan(post));
%         ycc = corr(pre,post);
%         grpccy(grp,ani) = abs(ycc);

%         mtit(sprintf('%s %s %s signcc=%0.3f xcc=%0.3f ycc=%0.3f',files(use(animal)).subj,files(use(animal)).inject,files(use(animal)).training,cc,xcc,ycc))

        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end
    end
    
    %%%group plot
    figure;set(gcf,'color','w')
    subplot(2,3,1)
    imshow(squeeze(nanmean(grpmaps(grp,:,:,:,1),2)),mrng);axis off;axis image;
    title('pre sign')
    set(gca,'LooseInset',get(gca,'TightInset'))
    subplot(2,3,4)
    imshow(squeeze(nanmean(grpmaps(grp,:,:,:,2),2)),mrng);axis off;axis image;
    title(sprintf('post sign cc=%0.3f',cc))
    set(gca,'LooseInset',get(gca,'TightInset'))
    subplot(2,3,2)
    tx = squeeze(nanmean(grptx(grp,:,:,:,1),2));tx=polarMap(tx);
    imshow(tx);axis off;axis image;
    title('pre topox')
    set(gca,'LooseInset',get(gca,'TightInset'))
    subplot(2,3,5)
    tx = squeeze(nanmean(grptx(grp,:,:,:,2),2));tx=polarMap(tx);
    imshow(tx);axis off;axis image;
    title(sprintf('post topox cc=%0.3f',nanmean(grpccx(grp,:))))
    set(gca,'LooseInset',get(gca,'TightInset'))
    subplot(2,3,3)
    ty = squeeze(nanmean(grpty(grp,:,:,:,1),2));ty=polarMap(ty);
    imshow(ty);axis off;axis image;
    title('pre topoy')
    set(gca,'LooseInset',get(gca,'TightInset'))
    subplot(2,3,6)
    ty = squeeze(nanmean(grpty(grp,:,:,:,2),2));ty=polarMap(ty);
    imshow(ty);axis off;axis image;
    title(sprintf('post topox cc=%0.3f',nanmean(grpccy(grp,:))))
    set(gca,'LooseInset',get(gca,'TightInset'))
    mtit(sprintf('%s',grpnames{grp}))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
    
    %%% amplitude differences
    figure; colormap jet
    amp_range = [0 0.02];
    delta_amp_range = [-0.01 0.01];
    subplot(2,4,1)
    tx = squeeze(nanmean(grptx(grp,:,:,:,1),2));tx1=abs(tx);
    imagesc(tx1,amp_range);axis off;axis image;
    title('pre topox')
    set(gca,'LooseInset',get(gca,'TightInset'))
    subplot(2,4,2)
    tx = squeeze(nanmean(grptx(grp,:,:,:,2),2));tx2=abs(tx);
    imagesc(tx2,amp_range);axis off;axis image;
    title(sprintf('post topox cc=%0.3f',nanmean(grpccx(grp,:))))
    set(gca,'LooseInset',get(gca,'TightInset'))
    
     subplot(2,4,3)
    imagesc(tx2 - tx1,delta_amp_range);axis off;axis image;
    title(sprintf('post - pre X'))
    set(gca,'LooseInset',get(gca,'TightInset')); hold on; plot(ypts,xpts,'k.','Markersize',1); 
    
       subplot(2,4,4)
    imagesc((tx2 - tx1)./(tx1 + tx2),[-.2 .2]);axis off;axis image;
    title(sprintf('post - pre index X'))
    set(gca,'LooseInset',get(gca,'TightInset')); hold on; plot(ypts,xpts,'k.','Markersize',1);
    
    subplot(2,4,5)
    ty = squeeze(nanmean(grpty(grp,:,:,:,1),2));ty1=abs(ty);
    imagesc(ty1,amp_range);axis off;axis image;
    title('pre topoy')
    set(gca,'LooseInset',get(gca,'TightInset'))
    subplot(2,4,6)
    ty = squeeze(nanmean(grpty(grp,:,:,:,2),2));ty2=abs(ty);
    imagesc(ty2,amp_range);axis off;axis image;
    title(sprintf('post topoy cc=%0.3f',nanmean(grpccy(grp,:))))
    set(gca,'LooseInset',get(gca,'TightInset'))
    mtit(sprintf('%s',grpnames{grp}))
    
         subplot(2,4,7)
    imagesc(ty2 - ty1,delta_amp_range);axis off;axis image;
    title(sprintf('post - pre Y'))
    set(gca,'LooseInset',get(gca,'TightInset')); hold on; plot(ypts,xpts,'k.','Markersize',1); 
    
           subplot(2,4,8)
    imagesc((ty2 - ty1)./(ty1 + ty2),[-.2 .2]);axis off;axis image;
    title(sprintf('post - pre  index Y'))
    set(gca,'LooseInset',get(gca,'TightInset')); hold on; plot(ypts,xpts,'k.','Markersize',1); 
    
    
    
    %%%group quanitification
    figure(f1)
    subplot(2,2,1)
    hold on
    plot(grp*ones(1,numAni),grpcc(grp,1:numAni),'ko','MarkerSize',15)
    errorbar(grp,nanmean(grpcc(grp,1:numAni)),nanstd(grpcc(grp,1:numAni))/sqrt(numAni),'k.','LineWidth',1,'MarkerSize',20)
    
    subplot(2,2,2)
    hold on
    plot(grp*ones(1,numAni),grpccx(grp,1:numAni),'ko','MarkerSize',15)
    errorbar(grp,nanmean(grpccx(grp,1:numAni)),nanstd(grpccx(grp,1:numAni))/sqrt(numAni),'k.','LineWidth',1,'MarkerSize',20)

    subplot(2,2,3)
    hold on
    plot(grp*ones(1,numAni),grpccy(grp,1:numAni),'ko','MarkerSize',15)
    errorbar(grp,nanmean(grpccy(grp,1:numAni)),nanstd(grpccy(grp,1:numAni))/sqrt(numAni),'k.','LineWidth',1,'MarkerSize',20)

    subplot(2,2,4)
    combcc(grp,1:numAni) = (grpccx(grp,1:numAni)+grpccy(grp,1:numAni))/2;
    hold on
    plot(grp*ones(1,numAni),combcc(grp,1:numAni),'ko','MarkerSize',15)
    errorbar(grp,nanmean(combcc(grp,1:numAni)),nanstd(combcc(grp,1:numAni))/sqrt(numAni),'k.','LineWidth',1,'MarkerSize',20)
  
    

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
    dos(['ps2pdf ' psfile ' "' 'cav_hM4Di_G6H203RTprepostTopo.pdf' '"'])
catch
    display('couldnt generate pdf');
end

delete(psfile);

%% individual panels for figures
% xh = 51:130;yh = 131:210;h=76:220;
% %saline
% tx = squeeze(nanmean(nanmean(grptx(1:2,:,xh,h,1),2),1));tx=polarMap(tx);
% imwrite(tx,'salXpre.tif','tif')
% 
% tx = squeeze(nanmean(nanmean(grptx(1:2,:,xh,h,2),2),1));tx=polarMap(tx);
% imwrite(tx,'salXpost.tif','tif')
% 
% ty = squeeze(nanmean(nanmean(grpty(1:2,:,yh,h,1),2),1));ty=polarMap(ty);
% imwrite(ty,'salYpre.tif','tif')
% 
% ty = squeeze(nanmean(nanmean(grpty(1:2,:,yh,h,2),2),1));ty=polarMap(ty);
% imwrite(ty,'salYpost.tif','tif')
% 
% %doi
% tx = squeeze(nanmean(nanmean(grptx(3:4,:,xh,h,1),2),1));tx=polarMap(tx);
% imwrite(tx,'doiXpre.tif','tif')
% 
% tx = squeeze(nanmean(nanmean(grptx(3:4,:,xh,h,2),2),1));tx=polarMap(tx);
% imwrite(tx,'doiXpost.tif','tif')
% 
% ty = squeeze(nanmean(nanmean(grpty(3:4,:,yh,h,1),2),1));ty=polarMap(ty);
% imwrite(ty,'doiYpre.tif','tif')
% 
% ty = squeeze(nanmean(nanmean(grpty(3:4,:,yh,h,2),2),1));ty=polarMap(ty);
% imwrite(ty,'doiYpost.tif','tif')
