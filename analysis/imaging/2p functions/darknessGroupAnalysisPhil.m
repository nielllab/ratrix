%%%darknessGroupAnalysisPhil
%%%loads in darkness data and incorporates either grating data or topo data

close all
clear all
dbstop if error

%%choose dataset
% batchPhil2pSizeSelect
batchPhil2pSizeSelect22min

path = '\\langevin\backup\twophoton\Phil\Compiled2p\'

psfile = 'c:\tempPhil2p.ps';
if exist(psfile,'file')==2;delete(psfile);end

cd(path);

group = input('which group? 1=saline naive, 2=saline trained, 3=DOI naive, 4=DOI trained: ')
redogrp = input('reanalyze group data? 0=no, 1=yes: ')

if group==1
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'SalineNaive2pDarkness'
elseif group==2
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'SalineTrained2pDarkness'
elseif group==3
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOINaive2pDarkness'
elseif group==4
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOITrained2pDarkness'
else
    sprintf('please restart and choose a number 1-4')
end

if isempty(use)
    sprintf('No animals in this group')
    return
end

grpsizep = 'C:\Users\nlab\Box Sync\Phil Niell Lab\2pData';
grpsizef = {'SalineNaive2pSizeSelectEff','SalineTrained2pSizeSelectEff',...
    'DOINaive2pSizeSelectEff','DOITrained2pSizeSelectEff'};

if redogrp
    reps=10;
    numAni = length(use)/2;
    grpcoamtx = nan(numAni,500,500,2); %%ani, cell, cell, pre/post
    grpsimIdx = nan(numAni,500,500,2);
    cut=nan(1,numAni);
    sig = nan(numAni,5);
    ensshuf = nan(numAni,reps,2);
    grpensmtx = nan(numAni,500,500,2);
    enspks = nan(numAni,500,2);
    enslocs = nan(numAni,500,2);
    grpenssimIdx = nan(numAni,500,500,2);
    anicnt = 1;
    grpd = nan(numAni,2,2);
    load(fullfile(grpsizep,grpsizef{group}),'threshcellsall');
    
    for i = 1:2:length(use)
        
        filename = sprintf('%s_%s_%s_%s_darkness',files(use(i)).expt,files(use(i)).subj,files(use(i)).timing,files(use(i)).inject);
        anipsfile = 'c:\tempPhil2p.ps';
        if exist(anipsfile,'file')==2;delete(anipsfile);end
        
        ncells = sum(threshcellsall{anicnt});

        %%%darkness data pre
        aniFile = files(use(i)).darknesspts; load(aniFile,'spikes');
        cut(anicnt) = files(use(i)).cutoff;
        spikes = spikes(1:cut(anicnt),end-2999:end);
        spikes = spikes(threshcellsall{anicnt},:);
        spikespre = spikes;
        
        %%%plot pre spikes
        j=0;
        f1 = figure
        while j<ncells
            subplot(3,ceil(ncells/(3*10)),j/10+1)
            hold on
            for k = 1:10
                try
                    plot(spikes(j+k,:)+0.5*k,'k')
                catch
                    continue
                end
            end
            axis([0 3000 0 6])
            j=j+10;
        end
        premn = sum(spikes>0,2)./size(spikes,2);
        
        %%%pairwise coactivity
        coamtx = nan(size(spikes,1),size(spikes,1));
        for j = 1:size(spikes,1)
            for k = 1:size(spikes,1)
                Ca=spikes(j,:);Cb=spikes(k,:);
                coamtx(j,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
            end
        end
        grpcoamtx(anicnt,1:ncells,1:ncells,1) = coamtx;
        

        %%%bootstrap to get significance threshold for each cell pair
        simind = nan(size(spikes,1),size(spikes,1),reps);
        tic
        parfor h = 1:reps
            shufmtx = nan(size(spikes,1));
            shuf = nan(size(spikes));
            normshuf = nan(size(spikes));
            for j = 1:size(spikes,1)
                tshf = randi([1 size(spikes,2)],1,1);
                shuf(j,:) = circshift(spikes(j,:),tshf,2);
                normshuf(j,:) = shuf(j,:)/max(shuf(j,:));
            end
            normshuf = nanmean(normshuf,1);
            ensshuf(anicnt,h,1) = prctile(normshuf,99);
            
            
            for j=1:size(spikes,1)
                for k=1:size(spikes,1)
                    Ca=shuf(j,:);Cb=shuf(k,:);
                    shufmtx(j,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
                end
            end
            simind(:,:,h) = shufmtx;
        end
        toc
        
        
        simIdx = nan(size(simind,1),size(simind,2));
        for j = 1:size(simind,1)
            for k = 1:size(simind,2)
                simIdx(j,k) = prctile(squeeze(simind(j,k,:)),99);
            end
        end
        sigmtx = coamtx>simIdx;
        pre=sigmtx;
        grpsimIdx(anicnt,1:ncells,1:ncells,1) = simIdx;
        
        
        %%%ensemble analysis
        normspikes = spikes;
        for h = 1:size(normspikes,1)
            normspikes(h,:) = normspikes(h,:)/max(normspikes(h,:));
        end
        allspikes = nanmean(normspikes,1);
        [pks locs] = findpeaks(allspikes);
        sigpks = find(pks>nanmean(ensshuf(anicnt,:,1)));
        pks = pks(sigpks);locs = locs(sigpks);
        ensmtx = nan(length(pks));
        for j = 1:length(locs)
            for k = 1:length(locs)
                Ca=spikes(:,locs(j))';Cb=spikes(:,locs(k))';
                ensmtx(j,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
            end
        end
        enspks(anicnt,1:length(pks),1) = pks;enslocs(anicnt,1:length(locs),1) = locs;
        grpensmtx(anicnt,1:length(pks),1:length(pks),1) = ensmtx;
        
        simind = nan(length(locs),length(locs),reps);
        tic
        parfor h = 1:reps
            shufmtx = nan(length(locs));
            shuf = nan(size(normspikes));
            for j = 1:size(normspikes,1)
                tshf = randi([1 size(normspikes,2)],1,1);
                shuf(j,:) = circshift(normspikes(j,:),tshf,2);
            end

            for j = 1:length(locs)
                for k = 1:length(locs)
                    Ca=shuf(:,locs(j))';Cb=shuf(:,locs(k))';
                    shufmtx(j,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
                end
            end
            simind(:,:,h) = shufmtx;
        end
        toc
        
        simIdx = nan(size(simind,1),size(simind,2));
        for j = 1:size(simind,1)
            for k = 1:size(simind,2)
                simIdx(j,k) = prctile(squeeze(simind(j,k,:)),99);
            end
        end
        sigmtx = ensmtx>simIdx;
        grpenssimIdx(anicnt,1:length(locs),1:length(locs),1) = simIdx;
        
        %%%darkness data post
        aniFile = files(use(i+1)).darknesspts; load(aniFile,'spikes');
        spikes = spikes(1:cut(anicnt),end-2999:end);
        spikes = spikes(threshcellsall{anicnt},:);
        spikespost = spikes;

        %%%plot post spikes
        j=0;
        figure(f1)
        while j<ncells
            subplot(3,ceil(ncells/(3*10)),j/10+1)
            hold on
            for k = 1:10
                try
                    plot(spikes(j+k,:)+0.5*k,'r')
                catch
                    continue
                end
            end
            axis([0 3000 0 6])
            j=j+10;
        end
        mtit('spikes pre (black) post (red)')
        postmn = sum(spikes>0,2)./size(spikes,2);
        if exist('anipsfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',anipsfile,'-append');
        end

        %%% percent active frames
        figure
        hold on
        for k = 1:length(premn)
            if premn(k)>nanmean(premn)
                plot([1 2],[premn(k) postmn(k)],'b.-')
            else
                plot([1 2],[premn(k) postmn(k)],'k.-')
            end
        end
        errorbar([1 2],[nanmean(premn) nanmean(postmn)],[nanstd(premn) nanstd(postmn)],'r')
        [h p] = ttest(premn,postmn);
        title(sprintf('percent active frames p=%0.4f',p))
        set(gca,'xtick',[1 2],'xticklabel',{'pre','post'})
        if exist('anipsfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',anipsfile,'-append');
        end
    
        %%%pairwise coactivity
        coamtx = nan(size(spikes,1),size(spikes,1));
        for j = 1:size(spikes,1)
            for k = 1:size(spikes,1)
                Ca=spikes(j,:);Cb=spikes(k,:);
                coamtx(j,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
            end
        end
        grpcoamtx(anicnt,1:ncells,1:ncells,2) = coamtx;

        %%%bootstrap to get significance threshold for each cell pair
        simind = nan(size(spikes,1),size(spikes,1),reps);
        tic
        parfor h = 1:reps
            shufmtx = nan(size(spikes,1));
            shuf = nan(size(spikes));
            for j = 1:size(spikes,1)
                tshf = randi([1 size(spikes,2)],1,1);
                shuf(j,:) = circshift(spikes(j,:),tshf,2);
            end
            for j=1:size(spikes,1)
                for k=1:size(spikes,1)
                    Ca=shuf(j,:);Cb=shuf(k,:);
                    shufmtx(j,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
                end
            end
            simind(:,:,h) = shufmtx;
        end
        toc
        
        simIdx = nan(size(simind,1),size(simind,2));
        for j = 1:size(simind,1)
            for k = 1:size(simind,2)
                simIdx(j,k) = prctile(squeeze(simind(j,k,:)),99);
            end
        end
        sigmtx = coamtx>simIdx;
        post=sigmtx;
        grpsimIdx(anicnt,1:ncells,1:ncells,2) = simIdx;
        
        sig(anicnt,1) = sum(pre(:))/(ncells^2);sprintf('percent coactive pre: %0.2f',sig(anicnt,1))
        sig(anicnt,2) = sum(post(:))/(ncells^2);sprintf('percent coactive post: %0.2f',sig(anicnt,2))
        sig(anicnt,3) = sum(pre(:)&post(:))/(ncells^2);sprintf('percent coactive pre and post: %0.2f',sig(anicnt,3))
        sig(anicnt,4) = sum(pre(:)&~post(:))/(ncells^2);sprintf('percent coactive pre and not post: %0.2f',sig(anicnt,4))
        sig(anicnt,5) = sum(~pre(:)&post(:))/(ncells^2);sprintf('percent coactive not pre and post: %0.2f',sig(anicnt,5))
        
        
        %%%get dimensionality pre/post
        R = corr(spikespre'); %correlation pre
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        grpd(anicnt,1,1) = d;
        
        R = cov(spikespre'); %covariance pre
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        grpd(anicnt,2,1) = d;
        
        R = corr(spikespost'); %correlation post
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        grpd(anicnt,1,2) = d;
        
        R = cov(spikespost'); %covariance post
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        grpd(anicnt,2,2) = d;    
        
        
        anicnt=anicnt+1;
        sprintf('%0.0f/%0.0f done',anicnt-1,numAni)
        
        try
            dos(['ps2pdf ' anipsfile ' "' [fullfile(pathname,filename) '.pdf'] '"'] )
        catch
            display('couldnt generate pdf');
        end
        delete(anipsfile);
        close all
    end
    

    save(fullfile(pathname,grpfilename));
    sprintf('done')
else
    sprintf('loading data')
    load(grpfilename)
end

%%%plotting
for i = 1:numAni
    ncells = sum(threshcellsall{i});
    figure
	subplot(2,2,1);imagesc(squeeze(grpcoamtx(i,1:ncells,1:ncells,1)),[-0.01 0.5]);colormap jet;colorbar
    xlabel(sprintf('coact matrix %s',[files(use(i*2-1)).timing]))
    ylabel('cell #')
    set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',6)
    axis equal
    
    subplot(2,2,2);imagesc(squeeze(grpsimIdx(i,1:ncells,1:ncells,1)),[0 1]);colormap jet;colorbar
    xlabel(sprintf('coact sig %s',[files(use(i*2-1)).timing]))
    ylabel('cell #')
    set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',6)
    axis equal
    
    subplot(2,2,3);imagesc(squeeze(grpcoamtx(i,1:ncells,1:ncells,2)),[-0.01 0.5]);colormap jet;colorbar
    xlabel(sprintf('coact matrix %s',[files(use(i*2)).timing]))
    ylabel('cell #')
    set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',6)
    axis equal
    
    subplot(2,2,4);imagesc(squeeze(grpsimIdx(i,1:ncells,1:ncells,2)),[0 1]);colormap jet;colorbar
    xlabel(sprintf('coact sig %s',[files(use(i*2)).timing]))
    ylabel('cell #')
    set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',6)
    axis equal

    mtit(sprintf('%s',[files(use(i*2)).subj ' ' files(use(i*2)).inject]))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
end

figure;
hold on
errorbar(1:5,nanmean(sig,1),nanstd(sig,1)/sqrt(numAni),'ro')
plot(1:5,sig','b.-','MarkerSize',5)
% for i = 1:size(sig,1)
%     plot(1:5,sig(i,:),'b.-')
% end
axis square
axis([0 6 0 0.5])
ylabel('percent of cell pairs')
set(gca,'xtick',1:5,'xticklabel',{'pre','post','pre&post','pre~post','~prepost'},'fontsize',6)
title('percent of cells coactive')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

%%%dimensionality
figure;
subplot(1,2,1)
hold on
pre = grpd(:,1,1);post = grpd(:,1,2);
plot([1 2],[pre post],'k.-')
errorbar([1 2],[nanmean(pre) nanmean(post)],[nanstd(pre)/sqrt(numAni) nanstd(post)/sqrt(numAni)])
set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'tickdir','out','fontsize',8)
ylabel('corr dimensionality')
axis([0 3 0 100])
axis square
[hvals pvals] = ttest(pre,post,'alpha',0.05);
title(sprintf('p=%0.3f',pvals'))
subplot(1,2,2)
hold on
pre = grpd(:,2,1);post = grpd(:,2,2);
plot([1 2],[pre post],'k.-')
errorbar([1 2],[nanmean(pre) nanmean(post)],[nanstd(pre)/sqrt(numAni) nanstd(post)/sqrt(numAni)])
set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'tickdir','out','fontsize',8)
ylabel('cov dimensionality')
axis([0 3 0 100])
axis square
[hvals pvals] = ttest(pre,post,'alpha',0.05);
title(sprintf('p=%0.3f',pvals'))
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end
   
%%%saving pdf
try
    dos(['ps2pdf ' psfile ' "' [fullfile(pathname,grpfilename) '.pdf'] '"'] )
catch
    display('couldnt generate pdf');
end

delete(psfile);
