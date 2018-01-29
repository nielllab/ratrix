close all
clear all
dbstop if error

%%choose dataset
global S2P
S2P = 0; %S2P analysis = 1, other = 0
batchPhil2pSizeSelect22min
% batchPhil2pSizeSelect %this is the old movie (26min)

% S2P = 1; %S2P analysis = 1, other = 0
% batchPhil2pSizeSelect22minS2P

pathname = '\\langevin\backup\twophoton\Phil\Compiled2p\';
altpath = 'C:\Users\nlab\Box Sync\Phil Niell Lab\2pData'; savepath=altpath;

grpnames = {'SalineNaive2pDim','SalineTrained2pDim','DOINaive2pDim','DOITrained2pDim'};

psfile = 'c:\tempPhil2pSize.ps';
if exist(psfile,'file')==2;delete(psfile);end

cd(pathname);
% cd(altpath);

moviefname = 'C:\sizeselectBin22min';
load(moviefname)
dfWindow = 9:11;
spWindow = {6:10,6:7,8:10};splabel={'all','early','late'};
stlb = {'sit','run'};
spthresh = 0.1; %threshold for minimum response pre+post
dt = 0.1;
cyclelength = 1/0.1;
ntotframes = 13400;
dwnsmp = 5; %%%downsample data
timepts = 1:(2*isi+duration)/dt; timepts = (timepts-1)*dt; timepts = timepts - isi;
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);thetaRange = unique(theta);radiusrange = unique(radius);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(radiusRange); sizes{i} = num2str(radiusRange(i)*2); end
numtrialtypes = length(sfrange)*length(contrastRange)*length(radiusRange)*length(thetaRange);
trialtype = nan(numtrialtypes,length(sf)/numtrialtypes);
cnt=1;
for i = 1:length(sfrange)
    for j = 1:length(contrastRange)
        for k = 1:length(radiusrange)
            for l = 1:length(thetaRange)
                trialtype(cnt,:) = find(sf==sfrange(i)&contrasts==contrastRange(j)&...
                    radius==radiusrange(k)&theta==thetaRange(l));
                cnt=cnt+1;
            end
        end
    end
end

for grp=1:length(grpnames)
    if grp==1
        use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    elseif grp==2
        use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    elseif grp==3
        use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    elseif grp==4
        use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    end
    numAni = length(use)/2;

    dReps = 1000;
    dStim = nan(numAni,2,2,2); %ani, corr/cov, base/stim, pre/post for stimuli
    dStimCurve = nan(numAni,2,2,2,500,dReps); %ani, corr/cov, base/stim, pre/post, #cells, sample reps 
    dDark = nan(numAni,2,2); %ani, corr/cov, pre/post for darkness
    dStimCurve = nan(numAni,2,2,500,dReps); %ani, corr/cov, pre/post, # cells, sample reps
    anicnt = 1;
    tcells = {};
    for i = 1:2:length(use)
        
        sprintf('animal %d/%d',i,numAni)

        clear spikesprebase spikesprestim spikespostbase spikespoststim

        %%%pre
        aniFile = [files(use(i)).subj '_' files(use(i)).expt '_' files(use(i)).inject '_pre']; load(aniFile);
        cut=files(use(i)).cutoff;

    %         valpre = max(squeeze(nanmean(spsize(:,spWindow{1},:,1),2)),[],2); %center cells only
    %         
        valpre = max(squeeze(nanmean(spsizeall(:,spWindow{1},:,1),2)),[],2); %all cells

        load(fullfile(pathname,files(use(i)).sizepts),'spikes')
        spikespre = spikes(1:cut,1:ntotframes);

        %%%post
        aniFile = [files(use(i)).subj '_' files(use(i)).expt '_' files(use(i)).inject '_post']; load(aniFile);

        valpost = max(squeeze(nanmean(spsizeall(:,spWindow{1},:,1),2)),[],2);

        load(fullfile(pathname,files(use(i+1)).sizepts),'spikes')
        spikespost = spikes(1:cut,1:ntotframes);

        %%%threshold for only responsive cells
        tcells{anicnt} = find((valpre>spthresh)&(valpost>spthresh));
        spikespre = spikespre(tcells{anicnt},:);spikespost = spikespost(tcells{anicnt},:);

    %         spikespre = spikespre - repmat(mean(spikespre,2),1,size(spikespre,2)); %subtract mean
    %         spikespost = spikespost - repmat(mean(spikespost,2),1,size(spikespost,2));
    %         spikespre(spikespre>0) = 1;spikespost(spikespost>0) = 1; %binarize

        percnt = 1; %%%cycle through to separate out baseline vs. stim periods
        for per = 1:cyclelength:size(spikespre,2)
            spikesprebase(:,percnt:percnt+cyclelength/2-1) = spikespre(:,per:per+cyclelength/2-1);
            spikesprestim(:,percnt:percnt+cyclelength/2-1) = spikespre(:,per+cyclelength/2:per+cyclelength-1);
            spikespostbase(:,percnt:percnt+cyclelength/2-1) = spikespost(:,per:per+cyclelength/2-1);
            spikespoststim(:,percnt:percnt+cyclelength/2-1) = spikespost(:,per+cyclelength/2:per+cyclelength-1);
            percnt = percnt + cyclelength/2;
        end 

        
        spikesprebase = imresize(spikesprebase,[length(tcells{anicnt}) size(spikesprebase,2)/dwnsmp]);
        spikesprestim = imresize(spikesprestim,[length(tcells{anicnt}) size(spikesprestim,2)/dwnsmp]);
        spikespostbase = imresize(spikespostbase,[length(tcells{anicnt}) size(spikespostbase,2)/dwnsmp]);
        spikespoststim = imresize(spikespoststim,[length(tcells{anicnt}) size(spikespoststim,2)/dwnsmp]);

    %         %do dimensionality only on center responsive cells
    %         valpost = max(squeeze(nanmean(spsize(:,spWindow{1},:,1),2)),[],2);
    %         threshcells = (valpre>spthresh)&(valpost>spthresh);
    %         spikespre = spikespre(threshcells,:);spikespost = spikespost(threshcells,:);
    %         percnt = 1;
    %         for per = 1:cyclelength:size(spikespre,2)
    %             spikesprebase(:,percnt:percnt+cyclelength/2-1) = spikespre(:,per:per+cyclelength/2-1);
    %             spikesprestim(:,percnt:percnt+cyclelength/2-1) = spikespre(:,per+cyclelength/2:per+cyclelength-1);
    %             spikespostbase(:,percnt:percnt+cyclelength/2-1) = spikespost(:,per:per+cyclelength/2-1);
    %             spikespoststim(:,percnt:percnt+cyclelength/2-1) = spikespost(:,per+cyclelength/2:per+cyclelength-1);
    %             percnt = percnt + cyclelength/2;
    %         end 


        %%%get #cells X dimensionality curve evoked
        sprintf('doing evoked dimensionality curve')
        tic
        for rep = 1:dReps
            for cnum = 1:length(tcells{anicnt})
                dcells = randsample(length(tcells{anicnt}),cnum);

                cells = spikesprebase(dcells,:);
                R = corr(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dStimCurve(anicnt,1,1,1,cnum,rep) = d;

                cells = spikesprestim(dcells,:);
                R = corr(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dStimCurve(anicnt,1,2,1,cnum,rep) = d;

                cells = spikespostbase(dcells,:);
                R = corr(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dStimCurve(anicnt,1,1,2,cnum,rep) = d;

                cells = spikespoststim(dcells,:);
                R = corr(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dStimCurve(anicnt,1,2,2,cnum,rep) = d;
                
                cells = spikesprebase(dcells,:);
                R = cov(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dStimCurve(anicnt,2,1,1,cnum,rep) = d;

                cells = spikesprestim(dcells,:);
                R = cov(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dStimCurve(anicnt,2,2,1,cnum,rep) = d;

                cells = spikespostbase(dcells,:);
                R = cov(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dStimCurve(anicnt,2,1,2,cnum,rep) = d;

                cells = spikespoststim(dcells,:);
                R = cov(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dStimCurve(anicnt,2,2,2,cnum,rep) = d;
            end
            
        end
        toc
    
        %%%get dimensionality pre/post by trial
        R = corr(spikesprebase'); %correlation pre
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dStim(anicnt,1,1,1) = d;
        R = corr(spikesprestim'); %correlation pre
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dStim(anicnt,1,2,1) = d;

        R = corr(spikespostbase'); %correlation post
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dStim(anicnt,1,1,2) = d;
        R = corr(spikespoststim'); %correlation post
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dStim(anicnt,1,2,2) = d;

        R = cov(spikesprebase'); %covariance pre
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dStim(anicnt,2,1,1) = d;
        R = cov(spikesprestim'); %covariance pre
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dStim(anicnt,2,2,1) = d;

        R = cov(spikespostbase'); %covariance post
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dStim(anicnt,2,1,2) = d;
        R = cov(spikespoststim'); %covariance post
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dStim(anicnt,2,2,2) = d;
        
        
        %%%darkness data pre
        aniFile = files(use(i)).darknesspts; load(aniFile,'spikes');
        spikes = spikes(1:cut,end-2999:end);
        spikes = spikes(tcells{anicnt},:);
        spikespre = imresize(spikes,[length(tcells{anicnt}) size(spikes,2)/dwnsmp]);
        
        %%%darkness data post
        aniFile = files(use(i+1)).darknesspts; load(aniFile,'spikes');
        spikes = spikes(1:cut,end-2999:end);
        spikes = spikes(tcells{anicnt},:);
        spikespost = imresize(spikes,[length(tcells{anicnt}) size(spikes,2)/dwnsmp]);
        
        %%%get #cells X dimensionality curve evoked
        sprintf('doing darkness dimensionality curve')
        tic
        for rep = 1:dReps
            for cnum = 1:length(tcells{anicnt})
                dcells = randsample(length(tcells{anicnt}),cnum);

                cells = spikespre(dcells,:);
                R = corr(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dDarkCurve(anicnt,1,1,cnum,rep) = d;

                cells = spikespost(dcells,:);
                R = corr(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dDarkCurve(anicnt,1,2,cnum,rep) = d;
                
                cells = spikespre(dcells,:);
                R = cov(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dDarkCurve(anicnt,2,1,cnum,rep) = d;

                cells = spikespost(dcells,:);
                R = cov(cells'); %correlation pre
                [u,s,v] = svd(R);
                s = diag(s);
                s = s/sum(s);
                d = 1/sum(s.^2);
                dDarkCurve(anicnt,2,2,cnum,rep) = d;
                
            end
        end
        toc
        
        %%%get dimensionality pre/post
        R = corr(spikespre'); %correlation pre
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dDark(anicnt,1,1) = d;
        
        R = cov(spikespre'); %covariance pre
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dDark(anicnt,2,1) = d;
        
        R = corr(spikespost'); %correlation post
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dDark(anicnt,1,2) = d;
        
        R = cov(spikespost'); %covariance post
        [u,s,v] = svd(R);
        s = diag(s);
        s = s/sum(s);
        d = 1/sum(s.^2);
        dDark(anicnt,2,2) = d;    
        
        anicnt=anicnt+1;
        sprintf('%d/%d done',anicnt-1,numAni)
    end

    clear i j k l m

    sprintf('saving group file...')
    save(fullfile(savepath,grpnames{grp}))
    sprintf('done')
    
    %% stimulus dimensionality

    %%%plot individual animal dimensionality vs. # cells
    for ani = 1:numAni
        figure;
        prebase = squeeze(dStimCurve(ani,1,1,1,:,:));prestim = squeeze(dStimCurve(ani,1,2,1,:,:));
        postbase = squeeze(dStimCurve(ani,1,1,2,:,:));poststim = squeeze(dStimCurve(ani,1,2,2,:,:));
        subplot(2,2,1)
        hold on
        shadedErrorBar(1:500,nanmean(prebase,2),nanstd(prebase,2)/sqrt(dReps),'k',1)
        shadedErrorBar(1:500,nanmean(prestim,2),nanstd(prestim,2)/sqrt(dReps),'r',1)
        title('pre base vs. stim');xlabel('# cells');ylabel('dimensionality');
        axis square
        subplot(2,2,2)
        hold on
        shadedErrorBar(1:500,nanmean(postbase,2),nanstd(postbase,2)/sqrt(dReps),'k',1)
        shadedErrorBar(1:500,nanmean(poststim,2),nanstd(poststim,2)/sqrt(dReps),'r',1)
        title('post base vs. stim');xlabel('# cells');ylabel('dimensionality');
        axis square
        subplot(2,2,3)
        hold on
        shadedErrorBar(1:500,nanmean(prebase,2),nanstd(prebase,2)/sqrt(dReps),'k',1)
        shadedErrorBar(1:500,nanmean(postbase,2),nanstd(postbase,2)/sqrt(dReps),'r',1)
        title('pre vs. post base');xlabel('# cells');ylabel('dimensionality');
        axis square
        subplot(2,2,4)
        hold on
        shadedErrorBar(1:500,nanmean(prestim,2),nanstd(prestim,2)/sqrt(dReps),'k',1)
        shadedErrorBar(1:500,nanmean(poststim,2),nanstd(poststim,2)/sqrt(dReps),'r',1)
        title('pre vs. post stim');xlabel('# cells');ylabel('dimensionality');
        axis square
        
        mtit(sprintf('%s %s',files(use(ani)).subj,files(use(ani)).inject))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end
    end

    %%%plot group dimensionality curve across cells
    figure;
    prebase = squeeze(nanmean(dStimCurve(:,1,1,1,:,:),6));prestim = squeeze(nanmean(dStimCurve(:,1,2,1,:,:),6));
    postbase = squeeze(nanmean(dStimCurve(:,1,1,2,:,:),6));poststim = squeeze(nanmean(dStimCurve(:,1,2,2,:,:),6));
    subplot(2,2,1)
    hold on
    shadedErrorBar(1:500,nanmean(prebase,1),nanstd(prebase,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:500,nanmean(prestim,1),nanstd(prestim,1)/sqrt(numAni),'r',1)
    title('pre base vs. stim');xlabel('# cells');ylabel('dimensionality');
    axis square
    subplot(2,2,2)
    hold on
    shadedErrorBar(1:500,nanmean(postbase,1),nanstd(postbase,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:500,nanmean(poststim,1),nanstd(poststim,1)/sqrt(numAni),'r',1)
    title('post base vs. stim');xlabel('# cells');ylabel('dimensionality');
    axis square
    subplot(2,2,3)
    hold on
    shadedErrorBar(1:500,nanmean(prebase,1),nanstd(prebase,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:500,nanmean(postbase,1),nanstd(postbase,1)/sqrt(numAni),'r',1)
    title('pre vs. post base');xlabel('# cells');ylabel('dimensionality');
    axis square
    subplot(2,2,4)
    hold on
    shadedErrorBar(1:500,nanmean(prestim,1),nanstd(prestim,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:500,nanmean(poststim,1),nanstd(poststim,1)/sqrt(numAni),'r',1)
    title('pre vs. post stim');xlabel('# cells');ylabel('dimensionality');
    axis square

    mtit(sprintf('%s',grpnames{grp}))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end

    
    figure; %%%plot dimensionality across all cells
    subplot(1,2,1)
    hold on
    prebase = dStim(:,1,1,1);prestim = dStim(:,1,2,1);postbase = dStim(:,1,1,2);poststim = dStim(:,1,2,2);
    plot([1 2],[prebase prestim],'k.:')
    plot([1 2],[postbase poststim],'r.:')
    errorbar([1 2],[nanmean(prebase) nanmean(prestim)],[nanstd(prebase)/sqrt(numAni) nanstd(prestim)/sqrt(numAni)],'k')
    errorbar([1 2],[nanmean(postbase) nanmean(poststim)],[nanstd(postbase)/sqrt(numAni) nanstd(poststim)/sqrt(numAni)],'r')
    set(gca,'xtick',1:2,'xticklabel',{'base','stim'},'tickdir','out','fontsize',8)
    ylabel('corr dimensionality')
    axis([0 3 0 40])
    axis square
    [hvals pvalspre] = ttest(prebase,prestim,'alpha',0.05);
    [hvals pvalspost] = ttest(postbase,poststim,'alpha',0.05);
    [hvals pvalsppbase] = ttest(prebase,postbase,'alpha',0.05);
    [hvals pvalsppstim] = ttest(prestim,poststim,'alpha',0.05);
    title(sprintf('pre p=%0.3f, post p=%0.3f, base p=%0.3f, stim p=%0.3f',pvalspre,pvalspost,pvalsppbase,pvalsppstim))
    subplot(1,2,2)
    hold on
    prebase = dStim(:,2,1,1);prestim = dStim(:,2,2,1);postbase = dStim(:,2,1,2);poststim = dStim(:,2,2,2);
    plot([1 2],[prebase prestim],'k.:')
    plot([1 2],[postbase poststim],'r.:')
    errorbar([1 2],[nanmean(prebase) nanmean(prestim)],[nanstd(prebase)/sqrt(numAni) nanstd(prestim)/sqrt(numAni)],'k')
    errorbar([1 2],[nanmean(postbase) nanmean(poststim)],[nanstd(postbase)/sqrt(numAni) nanstd(poststim)/sqrt(numAni)],'r')
    set(gca,'xtick',1:2,'xticklabel',{'base','stim'},'tickdir','out','fontsize',8)
    ylabel('cov dimensionality')
    axis([0 3 0 40])
    axis square
    [hvals pvalspre] = ttest(prebase,prestim,'alpha',0.05);
    [hvals pvalspost] = ttest(postbase,poststim,'alpha',0.05);
    [hvals pvalsppbase] = ttest(prebase,postbase,'alpha',0.05);
    [hvals pvalsppstim] = ttest(prestim,poststim,'alpha',0.05);
    title(sprintf('pre p=%0.3f, post p=%0.3f, base p=%0.3f, stim p=%0.3f',pvalspre,pvalspost,pvalsppbase,pvalsppstim))
    
    mtit(sprintf('Stimulus %s',grpnames{grp}))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
    
    %% darkness dimensionality
    
    %%%plot individual animal dimensionality vs. # cells
    for ani = 1:numAni
        figure;
        pre = squeeze(dDarkCurve(ani,1,1,:,:));post = squeeze(dDarkCurve(ani,1,2,:,:));
        subplot(1,2,1)
        hold on
        shadedErrorBar(1:500,nanmean(pre,2),nanstd(pre,2)/sqrt(dReps),'k',1)
        shadedErrorBar(1:500,nanmean(post,2),nanstd(post,2)/sqrt(dReps),'r',1)
        title('pre vs. post');xlabel('# cells');ylabel('corr dim');
        axis square
        pre = squeeze(dDarkCurve(ani,2,1,:,:));post = squeeze(dDarkCurve(ani,2,2,:,:));
        subplot(1,2,2)
        hold on
        shadedErrorBar(1:500,nanmean(pre,2),nanstd(pre,2)/sqrt(dReps),'k',1)
        shadedErrorBar(1:500,nanmean(post,2),nanstd(post,2)/sqrt(dReps),'r',1)
        title('pre vs. post');xlabel('# cells');ylabel('cov dim');
        axis square
        
        mtit(sprintf('%s %s darkness',files(use(ani)).subj,files(use(ani)).inject))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end
    end

    %%%plot group dimensionality across cells
    figure;
    pre = squeeze(nanmean(dDarkCurve(:,1,1,:,:),5));post = squeeze(nanmean(dDarkCurve(:,1,2,:,:),5));
    subplot(1,2,1)
    hold on
    shadedErrorBar(1:500,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:500,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    title('pre base vs. stim');xlabel('# cells');ylabel('corr dim');
    axis square
    pre = squeeze(nanmean(dDarkCurve(:,1,1,:,:),5));post = squeeze(nanmean(dDarkCurve(:,1,2,:,:),5));
    subplot(1,2,2)
    hold on
    shadedErrorBar(1:500,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
    shadedErrorBar(1:500,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
    title('pre base vs. stim');xlabel('# cells');ylabel('cov dim');
    axis square

    mtit(sprintf('%s darkness',grpnames{grp}))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
    
    %plot average dimensionality using all cells
    figure;
    subplot(1,2,1)
    hold on
    pre = dDark(:,1,1);post = dDark(:,1,2);
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
    pre = dDark(:,2,1);post = dDark(:,2,2);
    plot([1 2],[pre post],'k.-')
    errorbar([1 2],[nanmean(pre) nanmean(post)],[nanstd(pre)/sqrt(numAni) nanstd(post)/sqrt(numAni)])
    set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'tickdir','out','fontsize',8)
    ylabel('cov dimensionality')
    axis([0 3 0 100])
    axis square
    [hvals pvals] = ttest(pre,post,'alpha',0.05);
    title(sprintf('p=%0.3f',pvals'))
    
    mtit(sprintf('%s darkness',grpnames{grp}))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end

    
    
    %%
    try
        dos(['ps2pdf ' psfile ' "' [fullfile(savepath,grpnames{grp}) '.pdf'] '"'] )
    catch
        display('couldnt generate pdf');
    end

    delete(psfile);
end


