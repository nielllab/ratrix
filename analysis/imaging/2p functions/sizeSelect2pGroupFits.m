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

grpnames = {'SalineNaive',...
            'SalineTrained',...
            'DOINaive',...
            'DOITrained',...
            'Saline',...
            'DOI'};

group = input('which group? 1=saline naive, 2=saline trained, 3=DOI naive, 4=DOI trained, 5=saline, 6=DOI: ')
redo = input('redo group analysis? 0=no, 1=yes: ')
if group==1
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = grpnames{1}
elseif group==2
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = grpnames{2}
elseif group==3
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = grpnames{3}
elseif group==4
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = grpnames{4}
elseif group==5
    use = find(strcmp({files.inject},'saline')  & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = grpnames{5}
elseif group==6
    use = find(strcmp({files.inject},'doi')  & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = grpnames{6}
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

win=1; %which spikes window

%% analysis
if redo
    
    sprintf('loading data') %load the size data
    load([fullfile(savepath,grpfilename) '2pSizeSelectEff'])
    ncells = size(grpspsize,1);
    
    %%%SI for preferred SF and ori
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

    %%% fits
    grpdata = nan(numAni,length(sizes),2,2);
    allparams = nan(numAni,2,2,2);allcc = nan(numAni,2,2);
    allfit = cell(numAni,2,2);grpfitcurve = nan(numAni,1001,2,2,2);nfit = zeros(2,2);
    prefsz=nan(numAni,2,2);
    for i = 1:2 %sit/run
        pre=nan(length(unique(sess)),length(sizes));post=pre;
        for j = 1:length(unique(sess))
            %normalized
%             tmpre = squeeze(nanmean(grpspsize(sess==j,spWindow{win},:,i,1),2));
%             tmpre = bsxfun(@minus,tmpre,min(tmpre,[],2));
%             tmp = bsxfun(@rdivide,tmpre,max(tmpre,[],2));
%             tmp(~isfinite(tmp))=0;
%             pre(j,:) = squeeze(nanmean(tmp,1));
%             tmpost = squeeze(nanmean(grpspsize(sess==j,spWindow{win},:,i,2),2));
%             tmpost = bsxfun(@minus,tmpost,min(tmpost,[],2));
%             tmp = bsxfun(@rdivide,tmpost,max(tmpre,[],2));
%             tmp(~isfinite(tmp))=0;
%             post(j,:) = squeeze(nanmean(tmp,1));
            
            %non-normalized
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
            cnt=0;
            for k = 1:length(fitani)
                h1=figure;
                ft = plot(allfit{fitani(k),i,j});%(radiusRange);
                xdata = ft.XData;ydata = ft.YData;
                close(h1)
                try
                    SIfit(fitani(k),i,j) = (max(ydata)-ydata(end))/(max(ydata)+ydata(end));
                    grpfitcurve(fitani(k),:,1,i,j) = xdata;
                    grpfitcurve(fitani(k),:,2,i,j) = ydata;
                    [tmp, tmpmax] = max(ydata);
                    prefsz(k,i,j) = xdata(tmpmax);%pref radius in degrees
                    cnt=cnt+1;
                catch
                    SIfit(fitani(k),i,j) = 0;
                end
            end
            nfit(i,j) = cnt;
        end
    end
    
else
    load([fullfile(savepath,grpfilename) 'SSfits']);
end

%% plot group fit data   
figure;set(gcf,'color','w')
for j = 1:2 %sit/run
    subplot(2,2,j)
    hold on
    pre=squeeze(grpdata(:,:,j,1));post=squeeze(grpdata(:,:,j,2));
%     for i = 1:size(pre,1) %normalize
%         pretmp=max(pre(i,:));posttmp=max(post(i,:));
%         pre(i,:) = pre(i,:)/pretmp;
%         post(i,:) = post(i,:)/posttmp;
%     end
    A=errorbar(radiusRange,nanmean(pre,1),nanstd(pre,[],1)/sqrt(numAni),'ko');
    B=errorbar(radiusRange,nanmean(post,1),nanstd(post,[],1)/sqrt(numAni),'ro');
    x=nanmean(grpfitcurve(:,:,1,j,1),1);pre=grpfitcurve(:,:,2,j,1);post=grpfitcurve(:,:,2,j,2);
%     for i = 1:size(pre,1)
%         pre(i,:) = pre(i,:)/premax(i);%normalize to pre
%         post(i,:) = post(i,:)/postmax(i);
%     end
    presz=prefsz(:,j,1);postsz=prefsz(:,j,2);
    [h p] = ttest(prefsz(:,j,1),prefsz(:,j,2));
    sprintf('%s pref size(deg) pre=%0.2f+-%0.2f post=%0.2f+-%0.2f p=%0.3f',...
        stlb{j},nanmean(presz),nanstd(presz)/sqrt(nfit(j,1)),nanmean(postsz),nanstd(postsz)/sqrt(nfit(j,1)),p)
    C=shadedErrorBar(x,nanmean(pre,1),nanstd(pre,[],1)/sqrt(nfit(j,1)),'k',1);   
    D=shadedErrorBar(x,nanmean(post),nanstd(post,[],1)/sqrt(nfit(j,2)),'r',1);
    errorbar(nanmean(presz),0.75,[],[],nanstd(presz)/sqrt(nfit(j,1)),nanstd(presz)/sqrt(nfit(j,1)),'k.')
    errorbar(nanmean(postsz),0.75,[],[],nanstd(postsz)/sqrt(nfit(j,1)),nanstd(postsz)/sqrt(nfit(j,2)),'r.')
    axis square;axis([0 radiusRange(end) -0.05 0.75])
    xlabel('Stim Size (deg)');ylabel(sprintf('%s dfof',stlb{j}));
    title(sprintf('%s Data vs. Fits',stlb{j}))
    legend([A,B,C.mainLine,D.mainLine],'predata','postdata','prefit','postfit')
    set(gca,'xtick',radiusRange,'xticklabel',sizes,'ytick',0:0.25:0.75,...
        'LooseInset',get(gca,'TightInset'),'fontsize',10)
    
    sprintf('%s Rsquared pre=%0.3f post=%0.3f',stlb{j},nanmean(allcc(:,j,1),1),nanmean(allcc(:,j,2),1))
end

for j = 1:2 %sit/run
    subplot(2,2,j+2)
    hold on
    pre=squeeze(allparams(:,1,j,1));post=squeeze(allparams(:,1,j,2));
    plot(pre,post,'bo')
    errorbarxy(nanmean(pre,1),nanmean(post,1),nanstd(pre,[],1)/sqrt(nfit(j,1)),nanstd(post,[],1)/sqrt(nfit(j,2)),{'b','b','b'})
    plot([0 max([pre' post'])],[0 max([pre' post'])],'k:')
    axis([0 max([pre' post']) 0 max([pre' post'])])
    ax1 = gca;ax1.XColor = 'b';ax1.YColor = 'b';ax1_pos = ax1.Position; % position of first axes
    axis square
    xlabel(sprintf('%s Rd pre',stlb{j}));ylabel(sprintf('%s Rd post',stlb{j}));
    hold off
    ax2 = axes('Position',ax1_pos,'XAxisLocation','top','YAxisLocation','right','Color','none');
    ax2.XColor = 'k';ax2.YColor = 'k';
    
    [h p] = ttest(pre,post);
    sprintf('%s Rd pre=%0.2f+-%0.2f post=%0.2f+-%0.2f p=%0.3f',...
        stlb{j},nanmean(pre),nanstd(pre)/sqrt(nfit(j,1)),nanmean(post),nanstd(post)/sqrt(nfit(j,1)),p)
    
    axes(ax2)
    pre=squeeze(allparams(:,2,j,1));post=squeeze(allparams(:,2,j,2));
    hold on
    plot(pre,post,'ko')
    errorbarxy(nanmean(pre,1),nanmean(post,1),nanstd(pre,[],1)/sqrt(nfit(j,1)),nanstd(post,[],1)/sqrt(nfit(j,2)),{'k','k','k'})
    plot([0 max([pre' post'])],[0 max([pre' post'])],'k:')
    axis([0 max([pre' post']) 0 max([pre' post'])])
    axis square
    xlabel(sprintf('%s Rs pre',stlb{j}));ylabel(sprintf('%s Rs post',stlb{j}));
    
    [h p] = ttest(pre,post);
    sprintf('%s Rs pre=%0.2f+-%0.2f post=%0.2f+-%0.2f p=%0.3f',...
        stlb{j},nanmean(pre),nanstd(pre)/sqrt(nfit(j,1)),nanmean(post),nanstd(post)/sqrt(nfit(j,1)),p)
end

mtit(sprintf('Fits %s',grpfilename))
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end

%% plot group SI data
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
    
    sprintf('%s SIraw pre=%0.2f+-%0.2f post=%0.2f+-%0.2f p=%0.3f',...
        stlb{i},nanmean(preSI),nanstd(preSI)/sqrt(numAni),nanmean(postSI),nanstd(preSI)/sqrt(numAni),p)

    subplot(2,2,i+2)
    hold on
    preSI = squeeze(SIfit(:,i,1));
    postSI = squeeze(SIfit(:,i,2));
    plot(preSI,postSI,'bo')
    errorbarxy(nanmean(preSI),nanmean(postSI),nanstd(preSI)/sqrt(nfit(i,1)),nanstd(postSI)/sqrt(nfit(i,2)))
    plot([0 1],[0 1],'k--')
    axis square
    axis([0 1 0 1])
    xlabel('pre fit SI')
    ylabel('post fit SI')
    [h p] = ttest(preSI,postSI);
    title(sprintf('%s fit SI p=%0.3f',stlb{i},p))
    set(gca,'xtick',0:0.25:1,'ytick',0:0.25:1)
    
    sprintf('%s SIfit pre=%0.2f+-%0.2f post=%0.2f+-%0.2f p=%0.3f',...
        stlb{i},nanmean(preSI),nanstd(preSI)/sqrt(nfit(i,1)),nanmean(postSI),nanstd(preSI)/sqrt(nfit(i,2)),p)
end

mtit(sprintf('SI %s',grpfilename))
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

%% save data and pdf

save([fullfile(savepath,grpnames{group}) 'SSfits'],'grpdata','grpfitcurve','allparams','allcc','allfit','nfit','SIdata','SIfit','numAni','ncells','prefsz')

try
    dos(['ps2pdf ' psfile ' "' [fullfile(savepath,grpnames{group}) 'SSfits.pdf'] '"'] )
catch
    display('couldnt generate pdf');
end

delete(psfile);
