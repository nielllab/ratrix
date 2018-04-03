%% prepostTopo

%%% this function takes topox/topoy widefield data and does a pre vs. post
%%% correlation on the signmap*amplitudes, then plots them across groups
close all; clear all;

batchPhilIntactSkull %select batch file
cd(pathname)

grpnames = {'saline naive'...
            'saline trained'...
            'doi naive'...
            'doi trained'};

%select subset of animals
use = find(strcmp({files.notes},'topo only')&strcmp({files.timing},'pre'));alluse=use;
allsubj = unique({files(alluse).subj}); %needed for doTopography
s=1:1;doTopography

for f = 1:length(use)
    xshift = allxshift(f);
    yshift = allyshift(f);
    tshift = allthetashift(f);
    save(files(use(f)).topox,'xshift','yshift','tshift','-append')
end

psfile = 'c:\tempPhilWF.ps';
if exist(psfile,'file')==2;delete(psfile);end

%% quantification
use = find(strcmp({files.notes},'topo only'));load(files(use(1)).topox,'map'); %first expt to initialize variables
resamp=2; %how much to downsample maps by
grpmaps = zeros(4,10,size(map{1},1)/resamp,size(map{1},2)/resamp,2);%grpamp=grpmaps;
grpcc = zeros(4,10); %correlation coefficients
zoom = 1;%260/size(dfof_bg,1); should be same as in doTopography
f1=figure;set(gcf,'color','w')
for grp=1:4
    if grp==1
        use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'naive') & strcmp({files.notes},'topo only')) 
        grpfilename = 'SalineNaive'
        numAni = length(use)/2;
    elseif grp==2
        use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.notes},'topo only')) 
        grpfilename = 'SalineTrained'
        numAni = length(use)/2;
    elseif grp==3
        use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.notes},'topo only')) 
        grpfilename = 'DOINaive'
        numAni = length(use)/2;
    elseif grp==4
        use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.notes},'topo only')) 
        grpfilename = 'DOITrained'
        numAni = length(use)/2;
    end

    for f = 1:2:length(use) %across animals
        ani = round(f/2);
        for pp = 0:1 %pre/post
            if pp==1
                load(files(use(f+pp)).topox,'map');
            else
                load(files(use(f+pp)).topox,'map','xshift','yshift','tshift');
            end
            clear data
            if length(map)==3
                img = imresize(map{3},1/resamp);
                img = shiftImageRotate(img,xshift+x0,yshift+y0,tshift,zoom,sz);
                data(:,:,1) = img;
            else
                img = imresize(map{1},1/resamp);
                img = shiftImageRotate(img,xshift+x0,yshift+y0,tshift,zoom,sz);
                data(:,:,1) = img;
            end
            load(files(use(f+pp)).topoy,'map');
            if length(map)==3
                img = imresize(map{3},1/resamp);
                img = shiftImageRotate(img,xshift+x0,yshift+y0,tshift,zoom,sz);
                data(:,:,2) = img;
            else
                img = imresize(map{1},1/resamp);
                img = shiftImageRotate(img,xshift+x0,yshift+y0,tshift,zoom,sz);
                data(:,:,2) = img;
            end

            ph = angle(data);
            ph(ph<0)= ph(ph<0)+2*pi;

            for i = 1:2;
                [x y] = gradient(ph(:,:,i));
                dx(:,:,i) = x;%imresize(x,[size(ph,1) size(ph,2)])
                dy(:,:,i)=y;%imresize(y,[size(ph,1) size(ph,2)]);
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
            [X,Y] = meshgrid(1:size(amp,2),1:size(amp,1));%Xp = X;
            dist = sqrt((X - size(amp,2)/2).^2 + (Y - size(amp,1)/2).^2);
            img = mapsign.*amp;
            img(dist>90) = NaN; %chose 90 pixels for circle just by eye, maybe height/2.88 or width/3.55?
%             img(dist>90&Xp|Xp>size(Xp,2)/2) = NaN; %chose 90 pixels for circle just by eye, maybe height/2.88 or width/3.55?

            grpmaps(grp,ani,:,:,pp+1) = img;
            
        end
        pre = squeeze(grpmaps(grp,ani,:,:,1));pre=pre(:);pre=pre(~isnan(pre));
        post = squeeze(grpmaps(grp,ani,:,:,2));post=post(:);post=post(~isnan(post));
        cc = corr(pre,post);
        grpcc(grp,ani) = cc;
        figure;set(gcf,'color','w')
        subplot(1,2,1)
        imagesc(squeeze(grpmaps(grp,ani,:,:,1)),[-0.01 0.05]);axis off;axis image;
        title('pre')
        set(gca,'LooseInset',get(gca,'TightInset'))
        subplot(1,2,2)
        imagesc(squeeze(grpmaps(grp,ani,:,:,2)),[-0.01 0.05]);axis off;axis image;
        title(sprintf('post cc=%0.3f',cc))
        set(gca,'LooseInset',get(gca,'TightInset'))
        mtit(sprintf('%s %s %s',files(use(f)).subj,files(use(f)).inject,files(use(f)).training))
        
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end
    end
    figure(f1)
    hold on
    plot(grp*ones(1,numAni),grpcc(grp,1:numAni),'ko','MarkerSize',15)
    errorbar(grp,nanmean(grpcc(grp,1:numAni)),nanstd(grpcc(grp,1:numAni))/sqrt(numAni),'k.','LineWidth',1,'MarkerSize',20)
    
end

axis([0 5 0 1]);axis square
set(gca,'xtick',1:4,'xticklabel',grpnames(1:4),'ytick',0:0.25:1,'fontsize',12,'tickdir','out')
ylabel('pre/post map correlation')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

%% stats

%%%non-parametric test
[p,tbl,stats] = kruskalwallis(grpcc')

%%%tukey kramer post-hoc
[c,m,h,gnames] = multcompare(stats)

%%%unpaired ttest
group1 = [1 1 1 2 2 3];
group2 = [2 3 4 3 4 4];
sprintf('alpha = %0.4f',0.05/4)
for i = 1:length(group1)
    grp1 = grpcc(group1(i),:);grp1 = grp1(~isnan(grp1));
    grp2 = grpcc(group2(i),:);grp2 = grp2(~isnan(grp2));
    [h,p] = ttest2(grp1,grp2,'alpha',0.05/4);
    sprintf('%s vs %s p = %0.4f',grpnames{group1(i)},grpnames{group2(i)},p)
end

%% save pdf

try
    dos(['ps2pdf ' psfile ' "' 'prepostTopo.pdf' '"'])
catch
    display('couldnt generate pdf');
end

delete(psfile);