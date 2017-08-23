%%%use this code to analyze the full contrast, 24 rep size select data

close all
clear all
dbstop if error

global S2P

%%choose dataset

S2P = 0; %S2P analysis = 1, other = 0
batchPhil2pSizeSelect22min
% batchPhil2pSizeSelect %this is the old movie (26min)

% S2P = 1; %S2P analysis = 1, other = 0
% batchPhil2pSizeSelect22minS2P




pathname = '\\langevin\backup\twophoton\Phil\Compiled2p\';
% savepath = '\\langevin\backup\twophoton\Phil\Compiled2p\eff analysis'
altpath = 'C:\Users\nlab\Box Sync\Phil Niell Lab\2pData'; savepath=altpath;

psfile = 'c:\tempPhil2pSize.ps';
if exist(psfile,'file')==2;delete(psfile);end

% cd(pathname);
cd(altpath);

group = input('which group? 1=saline naive, 2=saline trained, 3=DOI naive, 4=DOI trained: ')
redoani = input('reanalyze individual animal data? 0=no, 1=yes: ')
if redoani
    rerun = input('rerun entire analysis with stim align? 0=no, 1=yes: ')
    reselect = input('reselect cells in each experiment? 0=no, 1=yes: ')
end
redogrp = input('reanalyze group data? 0=no, 1=yes: ')

if group==1
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'SalineNaive2pSizeSelectEff'
elseif group==2
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'SalineTrained2pSizeSelectEff'
elseif group==3
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOINaive2pSizeSelectEff'
elseif group==4
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOITrained2pSizeSelectEff'
else
    sprintf('please restart and choose a number 1-4')
end

if isempty(use)
    sprintf('No animals in this group')
    return
end

if redoani==1
    sizeSelect2pAnalysis
end


moviefname = 'C:\sizeselectBin22min';
load(moviefname)
dfWindow = 9:11;
spWindow = 6:10;
dt = 0.1;
cyclelength = 1/0.1;
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(radiusRange); sizes{i} = num2str(radiusRange(i)*2); end
thetaRange = unique(theta);
timepts = 1:(2*isi+duration)/dt; timepts = (timepts-1)*dt; timepts = timepts - isi;
numAni = length(use)/2;

if redogrp
    binwidth = 20;
    ntotframes = 13400;
    shufreps = 100;
    grpdfsize = nan(10000,15,length(sizes),2,2);grpspsize=grpdfsize;
    grpsptuning = nan(10000,15,length(sfrange),length(thetaRange),length(sizes),2,2);
    grprf=nan(10000,2);
    session = nan(10000,1);%%%make an array for animal #/session
    grpcells = nan(10000,1);
    grpSI = nan(10000,2,2);
    grpfrmdata = nan(numAni,398,398,length(sfrange),length(sizes),2,2);
    grpring = nan(numAni,80,length(sfrange),length(sizes),2,2);
    grpavgrad = nan(numAni,2);
    grphistrad = nan(numAni,11,2);
    grpfrmsim = nan(numAni,ntotframes);grpfrmsimcent=grpfrmsim;
    anisig = nan(numAni,2);
    cellcnt=1;
    anicnt = 1;
    for i = 1:2:length(use)
        %%%pre
%         aniFile = files(use(i)).sizeanalysis; load(aniFile);
        aniFile = [files(use(i)).subj '_' files(use(i)).expt '_' files(use(i)).inject '_pre']; load(aniFile);
        cut=files(use(i)).cutoff;
        expcells = length(usecells)-1;
        grpcells(cellcnt:cellcnt+expcells) = usecells;
%         grprf(cellcnt:cellcnt+expcells,:) = userf;
        session(cellcnt:cellcnt+expcells) = (i+1)/2;
        grpdfsize(cellcnt:cellcnt+expcells,:,:,:,1) = dfsize;
        grpspsize(cellcnt:cellcnt+expcells,:,:,:,1) = spsize;
        sptuning = sptuning(usecells,:,:,:,:,:);
        grpsptuning(cellcnt:cellcnt+expcells,:,:,:,:,:,1) = sptuning;
        grpSI(cellcnt:cellcnt+expcells,:,1) = SI;
        grpfrmdata(anicnt,:,:,:,:,:,1) = frmdata;
        grpavgrad(anicnt,1) = avgrad;
        grphistrad(anicnt,:,1) = histrad;
        for j = 1:length(cellprint)
            cellprintpre{cellcnt+j-1} = cellprint{j};
        end
        
        X0(anicnt) = x0;Y0(anicnt) = y0;
        dist=dist(:,25:375);
        ring = nan(ceil(max(max(dist))/binwidth),size(frmdata,3),size(frmdata,4),size(frmdata,5));
        for j = 1:size(frmdata,3)
            for k = 1:size(frmdata,4)
                for l = 1:size(frmdata,5)
                    resp = squeeze(frmdata(:,25:375,j,k,l));
                    for m = 1:ceil(max(max(dist)))/binwidth
                        ring(m,j,k,l) = nanmean(resp(dist>(binwidth*(m-1)) & dist<binwidth*m));
                    end
                end
            end
        end
        grpring(anicnt,1:size(ring,1),:,:,:,1) = ring;
        
        load(fullfile(pathname,files(use(i)).sizepts),'spikes')
        spikespre = spikes;
        spikes1 = spikes(1:cut,1:ntotframes);
        spikescent1 = spikes(usecells,1:ntotframes);
        
        
        %%%post
%         aniFile = files(use(i+1)).sizeanalysis; load(aniFile);
        aniFile = [files(use(i)).subj '_' files(use(i)).expt '_' files(use(i)).inject '_post']; load(aniFile);
        grpdfsize(cellcnt:cellcnt+expcells,:,:,:,2) = dfsize;
        grpspsize(cellcnt:cellcnt+expcells,:,:,:,2) = spsize;
        sptuning = sptuning(usecells,:,:,:,:,:);
        grpsptuning(cellcnt:cellcnt+expcells,:,:,:,:,:,2) = sptuning;
        grpSI(cellcnt:cellcnt+expcells,:,2) = SI;
        grpfrmdata(anicnt,:,:,:,:,:,2) = frmdata;
        grpavgrad(anicnt,2) = avgrad;
        grphistrad(anicnt,:,2) = histrad;
%         grpring(anicnt,1:size(ring,1),:,:,:,2) = ring;
        for j = 1:length(cellprint)
            cellprintpost{cellcnt+j-1} = cellprint{j};
        end
        
        dist=dist(:,25:375);
        ring = nan(ceil(max(max(dist))/binwidth),size(frmdata,3),size(frmdata,4),size(frmdata,5));
        for j = 1:size(frmdata,3)
            for k = 1:size(frmdata,4)
                for l = 1:size(frmdata,5)
                    resp = squeeze(frmdata(:,25:375,j,k,l));
                    for m = 1:ceil(max(max(dist)))/binwidth
                        ring(m,j,k,l) = nanmean(resp(dist>(binwidth*(m-1)) & dist<binwidth*m));
                    end
                end
            end
        end
        grpring(anicnt,1:size(ring,1),:,:,:,2) = ring;
        
        load(fullfile(pathname,files(use(i+1)).sizepts),'spikes')
        spikespost = spikes;
        spikes2 = spikes(1:cut,1:ntotframes);
        spikescent2 = spikes(usecells,1:ntotframes);
        
        simmtx = nan(1,size(spikes1,2));simmtxcent=simmtx;
        for k = 1:size(spikes1,2)
            Ca=spikes1(:,k)';Cb=spikes2(:,k)';
            simmtx(1,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
            Ca=spikescent1(:,k)';Cb=spikescent2(:,k)';
            simmtxcent(1,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
        end
        grpfrmsim(anicnt,:) = simmtx;
        grpfrmsimcent(anicnt,:) = simmtxcent;
        
        shufsig = nan(1,shufreps);shufsigcent = shufsig;
        parfor j=1:shufreps
            shuf1 = spikespre;shuf2 = spikespost;
            for k = 1:size(shuf1,1)
                tshf = randi([1 size(shuf1,2)],1,1);
                shuf1(k,:) = circshift(shuf1(k,:),tshf,2);
                tshf = randi([1 size(shuf1,2)],1,1);
                shuf2(k,:) = circshift(shuf2(k,:),tshf,2);
            end
            shuf1cent = shuf1(usecells,:);shuf2cent = shuf2(usecells,:);
            shuf1 = shuf1(1:cut,:);shuf2 = shuf2(1:cut,:);
            simmtx = nan(1,ntotframes);simmtxcent=simmtx;
            for k = 1:ntotframes
                Ca=shuf1(:,k)';Cb=shuf2(:,k)';
                simmtx(1,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
                Ca=shuf1cent(:,k)';Cb=shuf2cent(:,k)';
                simmtxcent(1,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
            end
            shufsig(1,j) = prctile(simmtx,99);shufsigcent(1,j) = prctile(simmtxcent,99);
        end
        anisig(anicnt,1) = nanmean(shufsig);anisig(anicnt,2) = nanmean(shufsigcent);
        
        
        cellcnt = cellcnt+expcells;
        anicnt=anicnt+1;
    end

%     grprf = grprf(1:cellcnt,:);
    session = session(1:cellcnt);
    
    grpdfsize = grpdfsize(1:cellcnt,:,:,:,:,:); %cell#,t,contr,size,run,pre/post
    grpspsize = grpspsize(1:cellcnt,:,:,:,:,:);
    grpsptuning = grpsptuning(1:cellcnt,:,:,:,:,:,:);
    grpSI = grpSI(1:cellcnt,:,:);
    grpcells = grpcells(1:cellcnt);
%     grpfrmdata = grpfrmdata(1:numAni,:,25:375,:,:,:,:);
%     grpring = grpring(1:numAni,:,:,:,:,:);
%     grpavgrad = grpavgrad(1:numAni,:);
%     grphistrad = grphistrad(1:numAni,:,:);
%     grpfrmsim = grpfrmsim(1:numAni,:);
    
    rmsdiff = nan(cellcnt,1);
    footcc = nan(cellcnt,1);
    for i = 1:cellcnt
        rmsdiff(i) = sqrt(mean(mean((cellprintpre{i}-cellprintpost{i}).^2)));
        cc = corrcoef(cellprintpre{i},cellprintpost{i}); footcc(i)=cc(1,2);
    end
    
    prcanisig = nan(numAni,2);
    for j = 1:numAni
        prcanisig(j,1) = sum(grpfrmsim(j,:)>anisig(j,1))/ntotframes;
        prcanisig(j,2) = sum(grpfrmsimcent(j,:)>anisig(j,2))/ntotframes;
    end
    clear i j k l m

    sprintf('saving group file...')
    save(fullfile(savepath,grpfilename))
    sprintf('done')
else
    sprintf('loading data')
    load(fullfile(savepath,grpfilename))
end


%%%see how similar responses are for pre and post across the population
figure;
subplot(1,2,1)
hold on
for i = 1:numAni
    plot(grpfrmsim(i,:),'.','MarkerSize',3)
end
axis([0 ntotframes 0 1])
xlabel('frame')
ylabel('similarity index')
axis square

subplot(1,2,2)
hold on
histo = nan(numAni,20);
for i = 1:numAni
    histo(numAni,:) = cumsum(hist(grpfrmsim(i,:),20))/size(grpfrmsim,2);
    plot(histo(numAni,:),'-')
end
plot(nanmean(histo),'LineWidth',2,'Color','k')
set(gca,'xtick',0:4:20,'xticklabel',0:0.2:1)
axis([0 20 0 1])
xlabel('similarity index')
ylabel('cumulative frames')
axis square

mtit(sprintf('frame similarity pre/post all cells mean=%0.2f +/- %0.2f',...
    nanmean(nanmean(grpfrmsim,2),1),nanstd(nanmean(grpfrmsim,2),1)/sqrt(numAni)))
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end


figure;
subplot(1,2,1)
hold on
for i = 1:numAni
    plot(grpfrmsimcent(i,:),'.','MarkerSize',3)
end
axis([0 ntotframes 0 1])
xlabel('frame')
ylabel('similarity index')
axis square

subplot(1,2,2)
hold on
histo = nan(numAni,20);
for i = 1:numAni
    histo(numAni,:) = cumsum(hist(grpfrmsimcent(i,:),20))/size(grpfrmsimcent,2);
    plot(histo(numAni,:),'-')
end
plot(nanmean(histo),'LineWidth',2,'Color','k')
set(gca,'xtick',0:4:20,'xticklabel',0:0.2:1)
axis([0 20 0 1])
xlabel('similarity index')
ylabel('cumulative frames')
axis square

mtit(sprintf('frame similarity pre/post center cells mean=%0.2f +/- %0.2f',...
    nanmean(nanmean(grpfrmsimcent,2),1),nanstd(nanmean(grpfrmsimcent,2),1)/sqrt(numAni)))
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

figure
hold on
plot([1 2],prcanisig,'k.')
errorbar([1 2],nanmean(prcanisig),nanstd(prcanisig)/sqrt(numAni),'LineStyle','none','Marker','o','Color','red')
axis([0 3 0 0.2])
set(gca,'xtick',1:2,'xticklabel',{'all','center'})
ylabel('fraction similar frames at p<0.01')
axis square
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end


%%%eye analysis
figure
subplot(1,2,1)
pre = grpavgrad(:,1);post = grpavgrad(:,2);
hold on
errorbar([1 2],[nanmean(pre) nanmean(post)],[nanstd(pre)/sqrt(numAni) nanstd(post)/sqrt(numAni)],'ko-','linewidth',2)
plot([1 2],grpavgrad,'b.-')
axis([0 3 0 30])
set(gca,'xtick',[1 2],'xticklabel',{'pre','post'},'tickdir','out','fontsize',8)
ylabel('pupil diameter')
axis square
subplot(1,2,2)
pre = grphistrad(:,:,1);post = grphistrad(:,:,2);
hold on
shadedErrorBar(1:11,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
shadedErrorBar(1:11,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
set(gca,'xtick',1:2:10,'xticklabel',[0:10:50],'ytick',0:2000:8000,'tickdir','out','fontsize',8)
xlabel('pupil diameter')
ylabel('number of frames')
legend('pre','post')
axis([0 11 0 8000])
axis square
mtit('pupil pre vs. post')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end



%%%pixelwise analysis
for z = 1:numAni
    %%%plot sit dF
    for h = 1:length(sfrange)
        figure;
        colormap jet
        for i = 1:length(sizes)
            subplot(4,length(sizes),i)
            resp = squeeze(grpfrmdata(z,:,:,h,i,1,1)-grpfrmdata(z,:,:,h,1,1,1));
            imagesc(resp,[-0.01 0.1])
            set(gca,'ytick',[],'xtick',[],'FontSize',7)
            xlabel(sprintf('sit %sdeg pre',sizes{i}))
            axis square
            subplot(4,length(sizes),i+length(sizes))
            resp = squeeze(grpfrmdata(z,:,:,h,i,1,2)-grpfrmdata(z,:,:,h,1,1,2));
            imagesc(resp,[-0.01 0.1])
            set(gca,'ytick',[],'xtick',[],'FontSize',7)
            xlabel(sprintf('sit %sdeg post',sizes{i}))
            axis square
        end
        for i = 1:length(sizes)
            subplot(4,length(sizes),i+2*length(sizes))
            resp = squeeze(grpfrmdata(z,:,:,h,i,2,1)-grpfrmdata(z,:,:,h,1,2,1));
            imagesc(resp,[-0.01 0.1])
            set(gca,'ytick',[],'xtick',[],'FontSize',7)
            xlabel(sprintf('run %sdeg pre',sizes{i}))
            axis square
            subplot(4,length(sizes),i+3*length(sizes))
            resp = squeeze(grpfrmdata(z,:,:,h,i,2,2)-grpfrmdata(z,:,:,h,1,2,2));
            imagesc(resp,[-0.01 0.1])
            set(gca,'ytick',[],'xtick',[],'FontSize',7)
            xlabel(sprintf('run %sdeg post',sizes{i}))
            axis square
        end
        mtit(sprintf('dF/size %0.2fcpd %s',sfrange(h),files(use(z*2)).subj))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end
    end
    
    figure
    subplot(2,2,1)
    resp = squeeze(nanmean(grpfrmdata(z,:,:,:,1,1,1),4));
    imagesc(resp,[-0.01 0.1])
    set(gca,'ytick',[],'xtick',[])
    xlabel('pre sit')
    axis square
    subplot(2,2,2)
    resp = squeeze(nanmean(grpfrmdata(z,:,:,:,1,2,1),4));
    imagesc(resp,[-0.01 0.1])
    set(gca,'ytick',[],'xtick',[])
    xlabel('pre run')
    axis square
    subplot(2,2,3)
    resp = squeeze(nanmean(grpfrmdata(z,:,:,:,1,1,2),4));
    imagesc(resp,[-0.01 0.1])
    set(gca,'ytick',[],'xtick',[])
    xlabel('post sit')
    axis square
    subplot(2,2,4)
    resp = squeeze(nanmean(grpfrmdata(z,:,:,:,1,2,2),4));
    imagesc(resp,[-0.01 0.1])
    set(gca,'ytick',[],'xtick',[])
    xlabel('post run')
    axis square
    mtit(sprintf('0deg responses %s',files(use(z*2)).subj))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
end
%         %%%plot run dF
%         figure;
%         colormap jet
%         for i = 2:length(sizes)
%             subplot(2,floor(length(sizes)/2),i-1)
%             resp = nanmean(frmdata(:,:,h,i,2),3);
%             imagesc(resp,[-0.01 0.1])
%             set(gca,'ytick',[],'xtick',[])
%             xlabel(sprintf('%sdeg',sizes{i}))
%             axis square
%         end
%         mtit(sprintf('run dF/size %0.2fcpd',sfrange(h)))
%         if exist('psfile','var')
%             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%             print('-dpsc',psfile,'-append');
%         end

%%%analysis of spatial spread
figure
for i=2:length(sizes)
    subplot(2,floor(length(sizes)/2),i-1)
    pre=squeeze(grpring(:,:,1,i,1,1)) - squeeze(grpring(:,:,1,1,1,1));post=squeeze(grpring(:,:,1,i,1,2))- squeeze(grpring(:,:,1,1,1,2));
    hold on
    shadedErrorBar(1:80,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(1:80,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%sdeg dfof',sizes{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
end
mtit(sprintf('Sit spread from center N=%d animals %0.2fcpd',numAni,sfrange(1)));
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end
figure
for i=2:length(sizes)
    subplot(2,floor(length(sizes)/2),i-1)
    pre=squeeze(grpring(:,:,2,i,1,1)) - squeeze(grpring(:,:,2,1,1,1));post=squeeze(grpring(:,:,2,i,1,2)) - squeeze(grpring(:,:,2,1,1,2));
    hold on
    shadedErrorBar(1:80,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(1:80,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%sdeg dfof',sizes{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
end
mtit(sprintf('Sit spread from center N=%d animals %0.2fcpd',numAni,sfrange(2)));
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end
figure
for i=2:length(sizes)
    subplot(2,floor(length(sizes)/2),i-1)
    pre=squeeze(grpring(:,:,1,i,2,1)) - squeeze(grpring(:,:,1,1,2,1));post=squeeze(grpring(:,:,1,i,2,2)) - squeeze(grpring(:,:,1,1,2,2));
    hold on
    shadedErrorBar(1:80,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(1:80,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%sdeg dfof',sizes{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
end
mtit(sprintf('Run spread from center N=%d animals %0.2fcpd',numAni,sfrange(1)));
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end
figure
for i=2:length(sizes)
    subplot(2,floor(length(sizes)/2),i-1)
    pre=squeeze(grpring(:,:,2,i,2,1)) - squeeze(grpring(:,:,2,1,2,1));post=squeeze(grpring(:,:,2,i,2,2)) - squeeze(grpring(:,:,2,1,2,2));
    hold on
    shadedErrorBar(1:80,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
    shadedErrorBar(1:80,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%sdeg dfof',sizes{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
end
mtit(sprintf('Run spread from center N=%d animals %0.2fcpd',numAni,sfrange(2)));
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

%%%plot zero size (unsubtracted)
figure
presit=squeeze(nanmean(grpring(:,:,:,1,1,1),3));postsit=squeeze(nanmean(grpring(:,:,:,1,1,2),3));
prerun=squeeze(nanmean(grpring(:,:,:,1,2,1),3));postrun=squeeze(nanmean(grpring(:,:,:,1,2,2),3));
subplot(1,2,1)
hold on
shadedErrorBar(1:80,nanmean(presit),nanstd(presit)/sqrt(numAni),'k',1)
shadedErrorBar(1:80,nanmean(postsit),nanstd(postsit)/sqrt(numAni),'r',1)
axis square
plot([0 10],[0 0],'b:')
axis([0 10 -0.15 0.1])
xlabel('dist from cent (um)')
set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
ylabel('zero size sit')
subplot(1,2,2)
hold on
shadedErrorBar(1:80,nanmean(prerun),nanstd(prerun)/sqrt(numAni),'k',1)
shadedErrorBar(1:80,nanmean(postrun),nanstd(postrun)/sqrt(numAni),'r',1)
plot([0 10],[0 0],'b:')
axis square
axis([0 10 -0.15 0.1])
xlabel('dist from cent (um)')
set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
ylabel('zero size run')
mtit(sprintf('spread from center zero size N=%d animals',numAni));
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

%%%same thing by animal
figure
for i=2:length(sizes)
    subplot(2,floor(length(sizes)/2),i-1)
    pre=squeeze(grpring(:,:,1,i,1,1))- squeeze(grpring(:,:,1,1,1,1));post=squeeze(grpring(:,:,1,i,1,2))- squeeze(grpring(:,:,1,1,1,2));
    hold on
    plot(1:80,pre,'k')
    plot(1:80,post,'r')
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%sdeg dfof',sizes{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
end
mtit(sprintf('Sit spread from center N=%d animals %0.2fcpd',numAni,sfrange(1)));
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end
figure
for i=2:length(sizes)
    subplot(2,floor(length(sizes)/2),i-1)
    pre=squeeze(grpring(:,:,2,i,1,1)) - squeeze(grpring(:,:,2,1,1,1));post=squeeze(grpring(:,:,2,i,1,2)) - squeeze(grpring(:,:,2,1,1,2));
    hold on
    plot(1:80,pre,'k')
    plot(1:80,post,'r')
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%sdeg dfof',sizes{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
end
mtit(sprintf('Sit spread from center N=%d animals %0.2fcpd',numAni,sfrange(2)));
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end
figure
for i=2:length(sizes)
    subplot(2,floor(length(sizes)/2),i-1)
    pre=squeeze(grpring(:,:,1,i,2,1)) - squeeze(grpring(:,:,1,1,2,1));post=squeeze(grpring(:,:,1,i,2,2)) - squeeze(grpring(:,:,1,1,2,2));
    hold on
    plot(1:80,pre,'k')
    plot(1:80,post,'r')
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%sdeg dfof',sizes{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
end
mtit(sprintf('Run spread from center N=%d animals %0.2fcpd',numAni,sfrange(1)));
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end
figure
for i=2:length(sizes)
    subplot(2,floor(length(sizes)/2),i-1)
    pre=squeeze(grpring(:,:,2,i,2,1)) - squeeze(grpring(:,:,2,1,2,1));post=squeeze(grpring(:,:,2,i,2,2)) - squeeze(grpring(:,:,2,1,2,2));
    hold on
    plot(1:80,pre,'k')
    plot(1:80,post,'r')
    plot([0 10],[0 0],'b:')
    axis square
    axis([0 10 -0.05 0.3])
    xlabel('dist from cent (um)')
    ylabel(sprintf('%sdeg dfof',sizes{i}))
    set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
end
mtit(sprintf('Run spread from center N=%d animals %0.2fcpd',numAni,sfrange(2)));
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

%%%plot zero size (unsubtracted)
figure
presit=squeeze(nanmean(grpring(:,:,:,1,1,1),3));postsit=squeeze(nanmean(grpring(:,:,:,1,1,2),3));
prerun=squeeze(nanmean(grpring(:,:,:,1,2,1),3));postrun=squeeze(nanmean(grpring(:,:,:,1,2,2),3));
subplot(1,2,1)
hold on
plot(1:80,presit,'k')
plot(1:80,postsit,'r')
axis square
plot([0 10],[0 0],'b:')
axis([0 10 -0.15 0.1])
xlabel('dist from cent (um)')
set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
ylabel('zero size sit')
subplot(1,2,2)
hold on
plot(1:80,prerun,'k')
plot(1:80,postrun,'r')
axis square
plot([0 10],[0 0],'b:')
axis([0 10 -0.15 0.1])
xlabel('dist from cent (um)')
set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
ylabel('zero size sit')
mtit(sprintf('spread from center zero size N=%d animals',numAni));
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end


%%comparison w/SF factored in
% hmin = -0.25;hmax = 0.25;hedges = [-1,1];
% for i = 1:numAni
%     figure
%     subplot(3,3,1)
%     pre = squeeze(grpfrmdata(i,:,:,1,2,1,1)); post = squeeze(grpfrmdata(i,:,:,1,2,1,2));
% %     diff = ((pre+min(min(pre)))-(post+min(min(post))))/(pre+min(min(pre)));
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     xlabel(sprintf('%sdeg pre',sizes{2}))
%     subplot(3,3,2)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     xlabel(sprintf('%sdeg post',sizes{2}))
%     subplot(3,3,3)
% %     imagesc(diff, [-1 1]); axis equal
%     hold on
%     histogram(reshape(pre,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','k')
%     histogram(reshape(post,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','r')
%     axis square
%     axis([hmin hmax 0 30000])
%     xlabel(sprintf('%sdeg diff',sizes{2}))
%     ylabel('pixel count')
%     set(gca,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     subplot(3,3,4)
%     pre = squeeze(grpfrmdata(i,:,:,1,3,1,1)); post = squeeze(grpfrmdata(i,:,:,1,3,1,2));
% %     diff = ((pre+min(min(pre)))-(post+min(min(post))))/(pre+min(min(pre)));
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     xlabel(sprintf('%sdeg pre',sizes{3}))
%     subplot(3,3,5)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     xlabel(sprintf('%sdeg post',sizes{3}))
%     subplot(3,3,6)
% %     imagesc(diff, [-1 1]); axis equal
%     hold on
%     histogram(reshape(pre,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','k')
%     histogram(reshape(post,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','r')
%     axis square
%     axis([hmin hmax 0 30000])
%     xlabel(sprintf('%sdeg diff',sizes{3}))
%     ylabel('pixel count')
%     set(gca,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     subplot(3,3,7)
%     pre = squeeze(grpfrmdata(i,:,:,1,end,1,1)); post = squeeze(grpfrmdata(i,:,:,1,end,1,2));
% %     diff = ((pre+min(min(pre)))-(post+min(min(post))))/(pre+min(min(pre)));
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     xlabel(sprintf('%sdeg pre',sizes{end}))
%     subplot(3,3,8)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     xlabel(sprintf('%sdeg post',sizes{end}))
%     subplot(3,3,9)
% %     imagesc(diff, [-1 1]); axis equal
%     hold on
%     histogram(reshape(pre,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','k')
%     histogram(reshape(post,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','r')
%     axis square
%     axis([hmin hmax 0 30000])
%     xlabel(sprintf('%sdeg diff',sizes{end}))
%     ylabel('pixel count')
%     set(gca,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     mtit(sprintf('%s SF=0.04cpd sit',files(use(i*2)).subj))
%     if exist('psfile','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfile,'-append');
%     end
% end
%     
%     figure
%     subplot(3,3,1)
%     pre = squeeze(grpfrmdata(i,:,:,2,2,1,1)); post = squeeze(grpfrmdata(i,:,:,2,2,1,2)); diff = post-pre;
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg pre',sizes{2}))
%     subplot(3,3,2)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg post',sizes{2}))
%     subplot(3,3,3)
%     imagesc(diff, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg diff',sizes{2}))
%     subplot(3,3,4)
%     pre = squeeze(grpfrmdata(i,:,:,2,3,1,1)); post = squeeze(grpfrmdata(i,:,:,2,3,1,2)); diff = post-pre;
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg pre',sizes{3}))
%     subplot(3,3,5)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg post',sizes{3}))
%     subplot(3,3,6)
%     imagesc(diff, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg diff',sizes{3}))
%     subplot(3,3,7)
%     pre = squeeze(grpfrmdata(i,:,:,2,end,1,1)); post = squeeze(grpfrmdata(i,:,:,2,end,1,2)); diff = post-pre;
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg pre',sizes{end}))
%     subplot(3,3,8)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg post',sizes{end}))
%     subplot(3,3,9)
%     imagesc(diff, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg diff',sizes{end}))
%     mtit(sprintf('%s SF=0.16cpd sit',files(use(i*2)).subj))
%     if exist('psfile','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfile,'-append');
%     end
%     
%     figure
%     subplot(3,3,1)
%     pre = squeeze(grpfrmdata(i,:,:,1,2,2,1)); post = squeeze(grpfrmdata(i,:,:,1,2,2,2)); diff = post-pre;
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg pre',sizes{2}))
%     subplot(3,3,2)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg post',sizes{2}))
%     subplot(3,3,3)
%     imagesc(diff, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg diff',sizes{2}))
%     subplot(3,3,4)
%     pre = squeeze(grpfrmdata(i,:,:,1,3,2,1)); post = squeeze(grpfrmdata(i,:,:,1,3,2,2)); diff = post-pre;
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg pre',sizes{3}))
%     subplot(3,3,5)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg post',sizes{3}))
%     subplot(3,3,6)
%     imagesc(diff, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg diff',sizes{3}))
%     subplot(3,3,7)
%     pre = squeeze(grpfrmdata(i,:,:,1,end,2,1)); post = squeeze(grpfrmdata(i,:,:,1,end,2,2)); diff = post-pre;
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg pre',sizes{end}))
%     subplot(3,3,8)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg post',sizes{end}))
%     subplot(3,3,9)
%     imagesc(diff, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg diff',sizes{end}))
%     mtit(sprintf('%s SF=0.04cpd run',files(use(i*2)).subj))
%     if exist('psfile','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfile,'-append');
%     end
%     
%     figure
%     subplot(3,3,1)
%     pre = squeeze(grpfrmdata(i,:,:,2,2,2,1)); post = squeeze(grpfrmdata(i,:,:,2,2,2,2)); diff = post-pre;
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg pre',sizes{2}))
%     subplot(3,3,2)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg post',sizes{2}))
%     subplot(3,3,3)
%     imagesc(diff, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg diff',sizes{2}))
%     subplot(3,3,4)
%     pre = squeeze(grpfrmdata(i,:,:,2,3,2,1)); post = squeeze(grpfrmdata(i,:,:,2,3,2,2)); diff = post-pre;
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg pre',sizes{3}))
%     subplot(3,3,5)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg post',sizes{3}))
%     subplot(3,3,6)
%     imagesc(diff, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg diff',sizes{3}))
%     subplot(3,3,7)
%     pre = squeeze(grpfrmdata(i,:,:,2,end,2,1)); post = squeeze(grpfrmdata(i,:,:,2,end,2,2)); diff = post-pre;
%     imagesc(pre, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg pre',sizes{end}))
%     subplot(3,3,8)
%     imagesc(post, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg post',sizes{end}))
%     subplot(3,3,9)
%     imagesc(diff, [-0.01 0.1]); axis equal
%     set(gca,'ytick',[],'xtick',[])
%     xlabel(sprintf('%sdeg diff',sizes{end}))
%     mtit(sprintf('%s SF=0.16cpd run',files(use(i*2)).subj))
%     if exist('psfile','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfile,'-append');
%     end
% end
    

%%%plot group data for size select averaging over cells

% ccvals = [0.7 0.8 0.9];
ccvals = [0];
for i = 1:length(ccvals)
    goodcc{i} = find(footcc>ccvals(i));
end

for z=1%:length(ccvals)
%     figure
%     subplot(1,2,1)
%     hold on
%     pre = squeeze(nanmean(grpspsize(goodcc{z},spWindow,:,1,1),2));
%     post = squeeze(nanmean(grpspsize(goodcc{z},spWindow,:,1,2),2));
%     errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(length(goodcc{z})),'k-o','Markersize',5)
%     errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(length(goodcc{z})),'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
%     ylabel('sit spikes')
%     axis([0 length(radiusRange)+1 0 0.3])
%     axis square
%     set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% 
%     subplot(1,2,2)
%     hold on
%     pre = squeeze(nanmean(grpspsize(goodcc{z},spWindow,:,2,1),2));
%     post = squeeze(nanmean(grpspsize(goodcc{z},spWindow,:,2,2),2));
%     errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(length(goodcc{z})),'k-o','Markersize',5)
%     errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(length(goodcc{z})),'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
%     ylabel('run spikes')
%     axis([0 length(radiusRange)+1 0 0.3])
%     axis square
%     set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
%     mtit(sprintf('Mean cell (n=%d) size suppression curve (cc>%0.2f)',length(goodcc{z}),ccvals(z)))
%     if exist('psfile','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfile,'-append');
%     end

    %%%%plot stationary size curves
    figure
    subplot(1,3,1)
    hold on
    pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},spWindow,:,1,1),2),1));
    post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},spWindow,:,1,2),2),1));
    plot(1:length(radiusRange),pre,'k-o','Markersize',5)
    plot(1:length(radiusRange),post,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('entire spike window')
    axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
    subplot(1,3,2)
    hold on
    pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},6:7,:,1,1),2),1));
    post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},6:7,:,1,2),2),1));
    plot(1:length(radiusRange),pre,'k-o','Markersize',5)
    plot(1:length(radiusRange),post,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('first half')
    axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
    subplot(1,3,3)
    hold on
    pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},8:10,:,1,1),2),1));
    post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},8:10,:,1,2),2),1));
    plot(1:length(radiusRange),pre,'k-o','Markersize',5)
    plot(1:length(radiusRange),post,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('second half')
    axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
    mtit(sprintf('Mean cell (n=%d) size suppression curve (cc>%0.2f) sit',length(goodcc{z}),ccvals(z)))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
    
    
    %%%%plot running size curves
    figure
    subplot(1,3,1)
    hold on
    pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},spWindow,:,2,1),2),1));
    post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},spWindow,:,2,2),2),1));
    plot(1:length(radiusRange),pre,'k-o','Markersize',5)
    plot(1:length(radiusRange),post,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('entire spike window')
    axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
    subplot(1,3,2)
    hold on
    pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},6:7,:,2,1),2),1));
    post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},6:7,:,2,2),2),1));
    plot(1:length(radiusRange),pre,'k-o','Markersize',5)
    plot(1:length(radiusRange),post,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('fist half')
    axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
    subplot(1,3,3)
    hold on
    pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},8:10,:,2,1),2),1));
    post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},8:10,:,2,2),2),1));
    plot(1:length(radiusRange),pre,'k-o','Markersize',5)
    plot(1:length(radiusRange),post,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('second half')
    axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
    mtit(sprintf('Mean cell (n=%d) size suppression curve (cc>%0.2f) run',length(goodcc{z}),ccvals(z)))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
    
    
    %%%plot cycle averages
    figure
    plotmin = min(min([nanmean(grpspsize(goodcc{z},:,:,1,1),1) nanmean(grpspsize(goodcc{z},:,:,1,2),1)])) - 0.05;
    plotmax = max(max([nanmean(grpspsize(goodcc{z},:,:,1,1),1) nanmean(grpspsize(goodcc{z},:,:,1,2),1)])) + 0.1;
    for i = 2:length(sizes)
        subplot(2,3,i-1)
        pre = grpspsize(goodcc{z},:,i,1,1);
        post = grpspsize(goodcc{z},:,i,1,2);
        hold on
        shadedErrorBar(timepts,squeeze(nanmean(pre,1)),...
            squeeze(nanstd(pre,1))/sqrt(length(goodcc{z})),'k',1)
        shadedErrorBar(timepts,squeeze(nanmean(post,1)),...
            squeeze(nanstd(post,1))/sqrt(length(goodcc{z})),'r',1)
        plot([0 0],[plotmin plotmax],'b-')
        axis square
        axis([timepts(1) timepts(end) plotmin plotmax])
        set(gca,'LooseInset',get(gca,'TightInset'))
    end
    mtit('Mean cell cycle avg/size sit')
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end

    figure
    plotmin = min(min([nanmean(grpspsize(goodcc{z},:,:,2,1),1) nanmean(grpspsize(goodcc{z},:,:,2,2),1)])) - 0.05;
    plotmax = max(max([nanmean(grpspsize(goodcc{z},:,:,2,1),1) nanmean(grpspsize(goodcc{z},:,:,2,2),1)])) + 0.1;
    for i = 2:length(sizes)
        subplot(2,3,i-1)
        pre = grpspsize(goodcc{z},:,i,2,1);
        post = grpspsize(goodcc{z},:,i,2,2);
        hold on
        shadedErrorBar(timepts,squeeze(nanmean(pre,1)),...
            squeeze(nanstd(pre,1))/sqrt(length(goodcc{z})),'k',1)
        shadedErrorBar(timepts,squeeze(nanmean(post,1)),...
            squeeze(nanstd(post,1))/sqrt(length(goodcc{z})),'r',1)
        plot([0 0],[plotmin plotmax],'b-')
        axis square
        if i>1
            axis([timepts(1) timepts(end) plotmin plotmax])
        end
        set(gca,'LooseInset',get(gca,'TightInset'))
    end
    mtit('Mean cell cycle avg/size run')
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end

    figure
    subplot(1,2,1)
    hold on
    plot([0 1],[0 1],'k--')
    plot(grpSI(goodcc{z},1,1),grpSI(goodcc{z},1,2),'k.','Markersize',20)
    errorbarxy(nanmean(grpSI(goodcc{z},1,1)),nanmean(grpSI(goodcc{z},1,2)),...
        nanstd(grpSI(goodcc{z},1,1))/sqrt(length(goodcc{z})),nanstd(grpSI(goodcc{z},1,2))/sqrt(length(goodcc{z})))
    axis([0 1 0 1])
    xlabel('sit pre SI')
    ylabel('sit post SI')
    axis square
    subplot(1,2,2)
    hold on
    plot([0 1],[0 1],'k--')
    plot(grpSI(goodcc{z},2,1),grpSI(goodcc{z},2,2),'k.','Markersize',20)
    errorbarxy(nanmean(grpSI(goodcc{z},2,1)),nanmean(grpSI(goodcc{z},2,2)),...
        nanstd(grpSI(goodcc{z},2,1))/sqrt(length(goodcc{z})),nanstd(grpSI(goodcc{z},2,2))/sqrt(length(goodcc{z})))
    axis([0 1 0 1])
    xlabel('run pre SI')
    ylabel('run post SI')
    axis square
    mtit('Cell Suppression Index')
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end



    %%%%%%plot group data for size select averaging over animals
    
    %%size suppression curves
%     figure
%     subplot(1,2,1)
%     hold on
%     pre=nan(length(unique(session)),length(sizes));post=pre;
%     for j = 1:length(unique(session))
%         pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),spWindow,:,1,1),2),1)); pre(1)=0; %median of 0 = nan
%         post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),spWindow,:,1,2),2),1)); post(1)=0;
%     end
%     errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
%     errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     % plot(1:length(radiusRange),pre,'k--.')
%     % plot(1:length(radiusRange),post,'r--.')
%     xlabel('Stim Size (deg)')
%     ylabel('sit spikes')
%     axis([0 length(radiusRange)+1 0 0.3])
%     axis square
%     set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
% 
%     subplot(1,2,2)
%     hold on
%     pre=nan(length(unique(session)),length(sizes));post=pre;
%     for j = 1:length(unique(session))
%         pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),spWindow,:,2,1),2),1)); pre(1)=0; %median of 0 = nan
%         post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),spWindow,:,2,2),2),1)); post(1)=0;
%     end
%     errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
%     errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     % plot(1:length(radiusRange),pre,'k--.')
%     % plot(1:length(radiusRange),post,'r--.')
%     xlabel('Stim Size (deg)')
%     ylabel('run spikes')
%     axis([0 length(radiusRange)+1 0 0.3])
%     axis square
%     set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
%     mtit(sprintf('Mean animal (n=%d) size suppression curve (cc>%0.2f)',numAni,ccvals(z)))
%     if exist('psfile','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfile,'-append');
%     end
    
    %%%mean animal size curve sit
    figure
    subplot(1,3,1)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),spWindow,:,1,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),spWindow,:,1,2),2),1)); %post(1)=0;
    end
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('entire spike window')
    axis([0 length(radiusRange)+1 -0.05 0.5])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))

    subplot(1,3,2)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),6:7,:,1,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),6:7,:,1,2),2),1)); %post(1)=0;
    end
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('first half')
    axis([0 length(radiusRange)+1 -0.05 0.5])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    subplot(1,3,3)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),8:10,:,1,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),8:10,:,1,2),2),1)); %post(1)=0;
    end
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('second half')
    axis([0 length(radiusRange)+1 -0.05 0.5])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    mtit(sprintf('Mean animal (n=%d) size suppression curve (cc>%0.2f) sit',numAni,ccvals(z)))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
    
    %%%animal average size curves running
    figure
    subplot(1,3,1)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),spWindow,:,2,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),spWindow,:,2,2),2),1)); %post(1)=0;
    end
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('entire spike window')
    axis([0 length(radiusRange)+1 -0.05 0.5])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))

    subplot(1,3,2)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),6:7,:,2,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),6:7,:,2,2),2),1)); %post(1)=0;
    end
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('first half')
    axis([0 length(radiusRange)+1 -0.05 0.5])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    subplot(1,3,3)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),8:10,:,2,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(session==j),goodcc{z}),8:10,:,2,2),2),1)); %post(1)=0;
    end
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('second half')
    axis([0 length(radiusRange)+1 -0.05 0.5])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    mtit(sprintf('Mean animal (n=%d) size suppression curve (cc>%0.2f) run',numAni,ccvals(z)))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
    
    
    %%%SF-dependent size curves by animal  
    figure
    subplot(3,2,1)
    pre=nan(numAni,length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,1,:,:,1,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,1,:,:,1,2),4),2),1));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
    ylabel('sit 0.04cpd dfof')
    axis([0 length(radiusRange)+1 -0.05 0.3])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(3,2,2)
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,1,:,:,2,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,1,:,:,2,2),4),2),1));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
    ylabel('run 0.04cpd dfof')
    axis([0 length(radiusRange)+1 -0.05 0.3])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(3,2,3)
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,2,:,:,1,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,2,:,:,1,2),4),2),1));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
    ylabel('sit 0.16cpd dfof')
    axis([0 length(radiusRange)+1 -0.05 0.3])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(3,2,4)
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,2,:,:,2,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,2,:,:,2,2),4),2),1));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
    ylabel('run 0.16cpd dfof')
    axis([0 length(radiusRange)+1 -0.05 0.3])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(3,2,5)
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,:,:,:,1,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,:,:,:,1,2),4),3),2),1));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('sit avg dfof')
    axis([0 length(radiusRange)+1 -0.05 0.3])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(3,2,6)
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,:,:,:,2,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(session==j),goodcc{z}),spWindow,:,:,:,2,2),4),3),2),1));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('run avg dfof')
    axis([0 length(radiusRange)+1 -0.05 0.3])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    mtit('SF-dependent Size Curves')
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
    
    %%%cycle averages
    figure
    for i = 2:length(sizes)
%         figure
        subplot(2,3,i-1)
        hold on
        pre=nan(length(unique(session)),15);post=pre;
        for j = 1:length(unique(session))
                pre(j,:) = nanmean(grpspsize(intersect(find(session==j),goodcc{z}),:,i,1,1),1);
                post(j,:) = nanmean(grpspsize(intersect(find(session==j),goodcc{z}),:,i,1,2),1);
        end
        if length(unique(session))==1
            plot(timepts,pre,'k')
            plot(timepts,post,'r')
        else
            shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
            shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
        end
        axis square
        axis([timepts(1) timepts(end) -0.02 0.5])
%         axis off
        set(gca,'LooseInset',get(gca,'TightInset'))
    end
    mtit('Animal response/size sit')
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end

    figure
    for i = 2:length(sizes)
        subplot(2,3,i-1)
        hold on
        pre=nan(length(unique(session)),15);post=pre;
        for j = 1:length(unique(session))
                pre(j,:) = nanmean(grpspsize(intersect(find(session==j),goodcc{z}),:,i,2,1),1);
                post(j,:) = nanmean(grpspsize(intersect(find(session==j),goodcc{z}),:,i,2,2),1);
        end
        if length(unique(session))==1
            plot(timepts,pre,'k')
            plot(timepts,post,'r')
        else
            shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
            shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
        end
        axis square
        axis([timepts(1) timepts(end) -0.02 0.5])
        set(gca,'LooseInset',get(gca,'TightInset'))
    end
    mtit('Animal response/size run')
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end

    %%%plot suppression index
    figure
    subplot(1,2,1)
    hold on
    pre=nan(length(unique(session)),1,1);post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = nanmean(grpSI(intersect(find(session==j),goodcc{z}),1,1),1);
        post(j,:) = nanmean(grpSI(intersect(find(session==j),goodcc{z}),1,2),1);
    end
    plot([0 1],[0 1],'k--')
    plot(pre,post,'k.','Markersize',20)
    errorbarxy(nanmean(pre,1),nanmean(post,1),nanstd(pre,1)/sqrt(numAni),nanstd(post,1)/sqrt(numAni))
    axis([0 1 0 1])
    xlabel('sit pre SI')
    ylabel('sit post SI')
    axis square
    subplot(1,2,2)
    hold on
    pre=nan(length(unique(session)),1,1);post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = nanmean(grpSI(intersect(find(session==j),goodcc{z}),2,1),1);
        post(j,:) = nanmean(grpSI(intersect(find(session==j),goodcc{z}),2,2),1);
    end
    plot([0 1],[0 1],'k--')
    plot(pre,post,'k.','Markersize',20)
    errorbarxy(nanmean(pre,1),nanmean(post,1),nanstd(pre,1)/sqrt(numAni),nanstd(post,1)/sqrt(numAni))
    axis([0 1 0 1])
    xlabel('run pre SI')
    ylabel('run post SI')
    axis square
    mtit('Animal Suppression Index')
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
    
    
    %%%pull out response to best size
    resp = squeeze(nanmean(grpspsize(:,spWindow,:,1,1),2));
    [valpre idxpre] = max(resp,[],2);
    for i = 1:length(idxpre)
        valpost(i) = squeeze(nanmean(grpspsize(i,spWindow,idxpre(i),1,2),2));
    end
% %     resp = squeeze(nanmean(grpspsize(:,spWindow,:,1,2),2));
% %     [valpost idxpost] = max(resp,[],2);
% %     for i = 1:length(idxpost)
% %         valpre(i) = squeeze(nanmean(grpspsize(i,spWindow,idxpost(i),1,1),2));
% %     end
    
    minresp = 0.1;
    valpost = valpost';
    indeces = (valpre>minresp & valpost>minresp);
    valpre = valpre(indeces);valpost = valpost(indeces);sess = session(indeces);
    
    %%%avg by animal
    for j = 1:length(unique(sess))
        valpreani(j,:) = nanmean(valpre(find(sess==j)));
        valpostani(j,:) = nanmean(valpost(find(sess==j)));
    end

    %%%plot best size pre vs. post
    figure;
    subplot(1,2,1)
    hold on
    plot(valpre,valpost,'color',[0.6 0.6 0.6],'marker','.','linestyle','none')
    plot(valpreani,valpostani,'bo')
    errorbarxy(nanmean(valpreani),nanmean(valpostani),nanstd(valpreani)/sqrt(numAni),nanstd(valpostani)/sqrt(numAni))
    plot([0 3],[0 3],'k--')
    axis square
    axis([0 3 0 3])
    xlabel('pre dfof')
    ylabel('post dfof')
    %%%same zoomed in
    subplot(1,2,2)
    hold on
    plot(valpre,valpost,'color',[0.6 0.6 0.6],'marker','.','linestyle','none')
    plot(valpreani,valpostani,'bo')
    errorbarxy(nanmean(valpreani),nanmean(valpostani),nanstd(valpreani)/sqrt(numAni),nanstd(valpostani)/sqrt(numAni))
    plot([0 1],[0 1],'k--')
    axis square
    axis([0 1 0 1])
    xlabel('pre dfof')
    ylabel('post dfof')
    legend('cells','ani','aniavg','location','northwest')
    
    [h p] = ttest(valpreani,valpostani);

    mtit(sprintf('Response to best size pre vs. post p=%0.3f',p))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end

end


% %%%individual cell plotting
% for i=1:length(goodcc{end})
%     figure
% 
%     %%%avg resp to best stim for each size stationary
%     subplot(2,3,1)
%     hold on
%     traces = squeeze(grpspsize(goodcc{end}(i),:,:,1,1));
%     plot(timepts,traces)
%     xlabel('Time(s)')
%     ylabel('pre spikes')
%     if isnan(min(min(traces)))
%         axis([0 1 0 1])
%     else
%         axis([timepts(1) timepts(end) min(min(traces))-0.01 max(max(traces))+0.01])
%     end
%     axis square
%     set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
% 
%     %%%avg resp to best stim for each size running
%     subplot(2,3,2)
%     hold on
%     traces = squeeze(grpspsize(goodcc{end}(i),:,:,1,2));
%     plot(timepts,traces)
%     xlabel('Time(s)')
%     ylabel('post spikes')
%     if isnan(min(min(traces)))
%         axis([0 1 0 1])
%     else
%         axis([timepts(1) timepts(end) min(min(traces))-0.01 max(max(traces))+0.01])
%     end
%     axis square
%     set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
% 
%     %%%size curve based on gratings parameters
%     subplot(2,3,3)
%     hold on
%     splotsit = squeeze(nanmean(grpspsize(goodcc{end}(i),spWindow,:,1,1),2));
%     splotrun = squeeze(nanmean(grpspsize(goodcc{end}(i),spWindow,:,1,2),2));
%     plot(1:length(radiusRange),splotsit,'k-o','Markersize',5)
%     plot(1:length(radiusRange),splotrun,'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
%     ylabel('spikes')
%     axis([0 length(radiusRange)+1 min(min([splotsit splotrun]))-0.01 max(max([splotsit splotrun]))+0.01])
%     set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes)
%     axis square
%     set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
%     
%     subplot(2,3,4)
%     imagesc(cellprintpre{goodcc{end}(i)},[0.5 1]);
%     axis square
%     axis off
%     title('pre')
%     
%     subplot(2,3,5)
%     imagesc(cellprintpost{goodcc{end}(i)},[0.5 1]);
%     axis square
%     axis off
%     title('post')
%     
%     subplot(2,3,6)
%     imagesc(cellprintpost{i} - cellprintpre{i},[-0.5 0.5]);
%     axis square
%     axis off
%     title(sprintf('rms %0.3f cc %0.3f',rmsdiff(goodcc{end}(i)),footcc(goodcc{end}(i))))
% 
%     mtit(sprintf('session #%d cell #%d tuning',session(goodcc{1}(i)),grpcells(goodcc{1}(i))))
%     if exist('psfile','var')
%         set(gcf, 'PaperPositionMode', 'auto'); %%%figure out how to make this full page landscape
%         print('-dpsc',psfile,'-append');
%     end
% end

try
    dos(['ps2pdf ' psfile ' "' [fullfile(savepath,grpfilename) '.pdf'] '"'] )
catch
    display('couldnt generate pdf');
end

delete(psfile);