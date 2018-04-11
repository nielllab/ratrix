%%
close all
clear all
dbstop if error

batchPhil2pSizeSelect22min

pathname = '\\langevin\backup\twophoton\Phil\Compiled2p\';
% savepath = '\\langevin\backup\twophoton\Phil\Compiled2p\eff analysis'
altpath = 'C:\Users\nlab\Box Sync\Phil Niell Lab\2pData'; savepath=altpath;

psfile = 'c:\tempPhil2pSize.ps';
if exist(psfile,'file')==2;delete(psfile);end

cd(pathname);
% cd(altpath);

group = input('which group? 1=saline naive, 2=saline trained, 3=DOI naive, 4=DOI trained, 5=saline, 6=DOI: ')

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
elseif group==5
    use = find(strcmp({files.inject},'saline')  & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'Saline2pSizeSelectEff'
elseif group==6
    use = find(strcmp({files.inject},'doi')  & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOI2pSizeSelectEff'
else
    sprintf('please restart and choose a number 1-6')
end


moviefname = 'C:\sizeselectBin22min';
load(moviefname)
dfWindow = 9:11;spWindow = {6:10,6:7,8:10};splabel={'all','early','late'};
stlb = {'sit','run'};
spthresh = 0.1;
dt = 0.1;cyclelength = 1/dt;
timepts = 1:(2*isi+duration)/dt; timepts = (timepts-1)*dt; timepts = timepts - isi;
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);thetaRange = unique(theta);radiusrange = unique(radius);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(radiusRange); sizes{i} = num2str(radiusRange(i)*2); end
numtrialtypes = length(sfrange)*length(contrastRange)*length(radiusRange)*length(thetaRange);
numAni = length(use)/2;

sprintf('loading data')
load(fullfile(savepath,grpfilename))

win=1; %which spikes window

%% SI for preferred SF and ori
SIcalc = squeeze(nanmean(grpspsize(:,spWindow{win},:,:,:),2));
SIani = nan(numAni,length(sizes),2,2);
for j = 1:numAni
    SIani(j,:,:,:) = squeeze(nanmean(SIcalc(sess==j,:,:,:),1));
end

SIdata = nan(numAni,2,2);SIfit=SIdata;
for i = 1:2
    for j = 1:2
        A = SIani(:,:,i,j);
        B = min(SIani(:,:,i,j),[],2);
        SIani(:,:,i,j) = bsxfun(@minus,A,B);
        [SIpks, SIinds] = max(squeeze(SIani(:,:,i,j)),[],2);
        SI50 = squeeze(SIani(:,end,i,j));
        SIdata(:,i,j) = (SIpks - SI50)./(SIpks + SI50);
    end
end

%% fits
grpdata = nan(numAni,length(sizes),2,2);
allparams = nan(numAni,2,2,2);allcc = nan(numAni,2,2);
allfit = cell(numAni,2,2);
for i = 1:2 %sit/run
    pre=nan(length(unique(sess)),length(sizes));post=pre;
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(sess==j,spWindow{win},:,i,1),2),1));
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(sess==j,spWindow{win},:,i,2),2),1));
    end

    %%%in case there are nans, throw out that ani's fit
    [Ipre,J]=ind2sub(size(pre),find(isnan(pre)));
    [Ipost,J]=ind2sub(size(post),find(isnan(post)));
    I = unique([Ipre Ipost]);
    fitani = 1:numAni;
    for j = 1:length(I)
        fitani = fitani(find(fitani~=I(j)));
    end
    pre=pre(fitani,:);post=post(fitani,:);
    grpdata(fitani,:,i,1) = pre;
    grpdata(fitani,:,i,2) = post;
    
    sprintf('doing %s fits...',stlb{i})

    [preRD preRS presigmaD presigmaS prem preresult] = sizeCurveFit(radiusRange,pre);
    [postRD postRS postsigmaD postsigmaS postm postresult] = sizeCurveFit(radiusRange,post);

    %%%constrain fit parameters to only fit Rd and Rs for stationary
    sprintf('doing %s constrained fits...',stlb{i})
    sigmaD = (presigmaD + postsigmaD)/2;sigmaS = (presigmaS + postsigmaS)/2;m = (prem + postm)/2;
    [preRD preRS preresult] = sizeCurveFitRdRs(radiusRange,pre,sigmaD,sigmaS,m);
    [postRD postRS postresult] = sizeCurveFitRdRs(radiusRange,post,sigmaD,sigmaS,m);

    %%%fit correlation w/data
    preR2=nan(1,length(preresult));postR2=preR2;
    for j = 1:length(preresult)
        preR2(j) = corr(pre(j,:)',preresult{j}(radiusRange));
        postR2(j) = corr(post(j,:)',postresult{j}(radiusRange));
    end
    
    allparams(fitani,1,i,1) = preRD;allparams(fitani,1,i,2) = postRD;
    allparams(fitani,2,i,1) = preRS;allparams(fitani,2,i,2) = postRS;
    allfit(fitani,i,1) = preresult;allfit(fitani,i,2) = postresult;
    allcc(fitani,i,1) = preR2;allcc(fitani,i,2) = postR2;
        
    %calculate SI from fits
    for j = 1:2 %pre/post
        for k = 1:length(fitani)
            scur = allfit{fitani(k),i,j}(radiusRange);
            try
                SIfit(fitani(k),i,j) = (max(scur)-scur(end))/(max(scur)+scur(end));
            catch
                SIfit(fitani(k),i,j) = 0;
            end
        end
    end

end

%% plot group data
figure
for i = 1:2 %sit/run
    subplot(2,2,i)
    hold on
    preSI = squeeze(SIdata(:,i,1));
    postSI = squeeze(SIdata(:,i,2));
    plot(preSI,postSI,'bo')
    errorbarxy(nanmean(preSI),nanmean(postSI),nanstd(preSI)/sqrt(numAni),nanstd(postSI)/sqrt(numAni))
    plot([0 1],[0 1],'k--')
    axis square
    axis([0 1 0 1])
    xlabel('pre raw SI')
    ylabel('post raw SI')
    [h p] = ttest(preSI,postSI);
    title(sprintf('%s raw SI p=%0.3f',stlb{i},p))
    set(gca,'xtick',0:0.25:1,'ytick',0:0.25:1)

    subplot(2,2,i+2)
    hold on
    preSI = squeeze(SIfit(:,i,1));
    postSI = squeeze(SIfit(:,i,2));
    plot(preSI,postSI,'bo')
    errorbarxy(nanmean(preSI),nanmean(postSI),nanstd(preSI)/sqrt(numAni),nanstd(postSI)/sqrt(numAni))
    plot([0 1],[0 1],'k--')
    axis square
    axis([0 1 0 1])
    xlabel('pre fit SI')
    ylabel('post fit SI')
    [h p] = ttest(preSI,postSI);
    title(sprintf('%s fit SI p=%0.3f',stlb{i},p))
    set(gca,'xtick',0:0.25:1,'ytick',0:0.25:1)
end

mtit(sprintf('SI %s',grpfilename(1:end-15)))
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

%% plot individual animal data
for i = 1:numAni
    figure;set(gcf,'color','w')
    for j = 1:2 %sit/run
        subplot(2,2,j)
        hold on
        plot(radiusRange,grpdata(i,:,j,1),'ko:')
        plot(radiusRange,grpdata(i,:,j,2),'ro:')
        plot(allfit{i,j,1},'k')
        plot(allfit{i,j,2},'r')
        legend off
        axis square;axis([0 radiusRange(end) -0.05 1])
        xlabel('Stim Size (deg)');ylabel(sprintf('%s dfof',stlb{j}));
        title(sprintf('R2 pre=%0.3f post=%0.3f',allcc(i,j,1),allcc(i,j,2)))
        set(gca,'xtick',radiusRange,'xticklabel',sizes,'ytick',0:0.25:1,...
            'LooseInset',get(gca,'TightInset'),'fontsize',10)
    end

    subplot(2,2,3)
    hold on
    plot([1 2],[SIdata(i,1,1) SIdata(i,2,1)],'ko')
    plot([1 2],[SIdata(i,1,2) SIdata(i,2,2)],'ro')
    plot([3 4],[SIfit(i,1,1) SIfit(i,2,1)],'ko')
    plot([3 4],[SIfit(i,1,2) SIfit(i,2,2)],'ro')
    axis square
    axis([0.5 4.5 0 1])
    ylabel('SI')
    set(gca,'xtick',1:4,'xticklabel',{'rawsit','rawrun','fitsit','fitrun'},'ytick',0:0.25:1,...
        'LooseInset',get(gca,'TightInset'),'fontsize',10)
    
    subplot(2,2,4)
    hold on
    yyaxis left
    plot([1 2],[allparams(i,1,1,1) allparams(i,1,2,1)],'ko')
    plot([1 2],[allparams(i,1,1,2) allparams(i,1,2,2)],'ro')
    ylabel('Rd')
    yyaxis right
    plot([3 4],[allparams(i,2,1,1) allparams(i,2,2,1)],'ko')
    plot([3 4],[allparams(i,2,1,2) allparams(i,2,2,2)],'ro')
    ylabel('Rs')
    axis square
    xlim([0.5 4.5])
    set(gca,'xtick',1:4,'xticklabel',{'Rd sit','Rd run','Rs sit','Rs run'},...
        'LooseInset',get(gca,'TightInset'),'fontsize',10)
    
    mtit(sprintf('%s %s %s %s',files(use(i*2)).subj,files(use(i*2)).expt,files(use(i*2)).inject,files(use(i*2)).training))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
end

%% save pdf
try
    dos(['ps2pdf ' psfile ' "' [fullfile(savepath,grpfilename(1:end-15)) 'SSfits.pdf'] '"'] )
catch
    display('couldnt generate pdf');
end

delete(psfile);