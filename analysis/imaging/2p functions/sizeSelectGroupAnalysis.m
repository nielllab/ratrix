%%%use this code to analyze the full contrast, 24 rep size select data

%%
close all
clear all
dbstop if error

global S2P

%%%set min resp required for cells
minresp = 0.1;

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

cd(pathname);
% cd(altpath);

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
    sizeSelect2pAnalysisNeuropilSelect
%     sizeSelect2pAnalysis
end

% % % keyboard

mycol = {'b','g','r','c','m','y','k','b','g','r','c','m','y','k'};
moviefname = 'C:\sizeselectBin22min';
load(moviefname)
dfWindow = 9:11;
spWindow = {6:10,6:7,8:10};splabel={'all','early','late'};
stlb = {'sit','run'};
spthresh = 0.1;
dt = 0.1;
cyclelength = 1/0.1;
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
numAni = length(use)/2;

if redogrp
    binwidth = 10;
    ntotframes = 13400;
    shufreps = 1000;
    grpdfsize = nan(10000,15,length(sizes),2,2);grpspsize=grpdfsize;
    grpsptuning = nan(10000,15,length(sfrange),length(thetaRange),length(sizes),2,2);
%     grprf=nan(10000,2);
    session = nan(10000,1);%%%make an array for animal #/session
    grpcells = nan(10000,1);
    grpSIsp = nan(10000,2,2);
    grpfrmdata = nan(numAni,398,398,length(sfrange),length(sizes),2,2);
    grpring = nan(numAni,80,length(sfrange),length(sizes),2,2);
    grpavgrad = nan(numAni,2);
    grphistrad = nan(numAni,11,2);
    grpfrmsim = nan(numAni,ntotframes);grpfrmsimcent=grpfrmsim;grpfrmsimtr = nan(numAni,numtrialtypes);
    anisig = nan(numAni,2);anisigtr = nan(numAni,1);
%     grpshufdist = nan(numAni,numtrialtypes);
    grpsimmtx = nan(numAni,shufreps,ntotframes);grpsimmtxcent = grpsimmtx;grpsimmtxtr = nan(numAni,shufreps,numtrialtypes);
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
%         sptuning = sptuning(usecells,:,:,:,:,:);
        grpsptuning(cellcnt:cellcnt+expcells,:,:,:,:,:,1) = sptuning;
        grpSIsp(cellcnt:cellcnt+expcells,:,1) = SIsp;
        grpfrmdata(anicnt,:,:,:,:,:,1) = frmdata;
        grpavgrad(anicnt,1) = avgrad;
        grphistrad(anicnt,:,1) = histrad;
        for j = 1:length(cellprint)
            cellprintpre{cellcnt+j-1} = cellprint{j};
        end
        
        X0(anicnt) = x0;Y0(anicnt) = y0;
        if size(dist,2)==398;dist=dist(:,25:375);end
        ring = nan(ceil(max(max(dist))/binwidth),size(frmdata,3),size(frmdata,4),size(frmdata,5));
        for j = 1:size(frmdata,3)
            for k = 1:size(frmdata,4)
                for l = 1:size(frmdata,5)
                    if size(frmdata,2)==398
                        resp = squeeze(frmdata(:,25:375,j,k,l));
                    else
                        resp = squeeze(frmdata(:,:,j,k,l));
                    end
                    for m = 1:ceil(max(max(dist)))/binwidth
                        ring(m,j,k,l) = nanmean(resp(dist>(binwidth*(m-1)) & dist<binwidth*m));
                    end
                end
            end
        end
        grpring(anicnt,1:size(ring,1),:,:,:,1) = ring;
        
% % %         load(fullfile(pathname,files(use(i)).sizepts),'spikes')
% % %         spikespre = spikes;
% % %         spikes1 = spikes(1:cut,1:ntotframes);
% % %         spikescent1 = spikes(usecells,1:ntotframes);
        
        
        %%%post
%         aniFile = files(use(i+1)).sizeanalysis; load(aniFile);
        aniFile = [files(use(i)).subj '_' files(use(i)).expt '_' files(use(i)).inject '_post']; load(aniFile);
        grpdfsize(cellcnt:cellcnt+expcells,:,:,:,2) = dfsize;
        grpspsize(cellcnt:cellcnt+expcells,:,:,:,2) = spsize;
%         sptuning = sptuning(usecells,:,:,:,:,:);
        grpsptuning(cellcnt:cellcnt+expcells,:,:,:,:,:,2) = sptuning;
        grpSIsp(cellcnt:cellcnt+expcells,:,2) = SIsp;
        grpfrmdata(anicnt,:,:,:,:,:,2) = frmdata;
        grpavgrad(anicnt,2) = avgrad;
        grphistrad(anicnt,:,2) = histrad;
%         grpring(anicnt,1:size(ring,1),:,:,:,2) = ring;
        for j = 1:length(cellprint)
            cellprintpost{cellcnt+j-1} = cellprint{j};
        end
        
        if size(dist,2)==398;dist=dist(:,25:375);end
        ring = nan(ceil(max(max(dist))/binwidth),size(frmdata,3),size(frmdata,4),size(frmdata,5));
        for j = 1:size(frmdata,3)
            for k = 1:size(frmdata,4)
                for l = 1:size(frmdata,5)
                    if size(frmdata,2)==398
                        resp = squeeze(frmdata(:,25:375,j,k,l));
                    else
                        resp = squeeze(frmdata(:,:,j,k,l));
                    end
                    for m = 1:ceil(max(max(dist)))/binwidth
                        ring(m,j,k,l) = nanmean(resp(dist>(binwidth*(m-1)) & dist<binwidth*m));
                    end
                end
            end
        end
        grpring(anicnt,1:size(ring,1),:,:,:,2) = ring;
        
% % %         load(fullfile(pathname,files(use(i+1)).sizepts),'spikes')
% % %         spikespost = spikes;
% % %         spikes2 = spikes(1:cut,1:ntotframes);
% % %         spikescent2 = spikes(usecells,1:ntotframes);
% % %         
% % %         sptrpre = imresize(spikespre(1:cut,:),[cut size(spikespre,2)/10]);
% % %         sptrpost = imresize(spikespost(1:cut,:),[cut size(spikespost,2)/10]);
% % %         pre = nan(cut,size(trialtype,1));post=pre;
% % %         for j = 1:size(trialtype,1)
% % %             pre(:,j) = nanmean(sptrpre(:,trialtype(j,trialtype(j,:)<size(sptrpre,2))),2);
% % %             post(:,j) = nanmean(sptrpost(:,trialtype(j,trialtype(j,:)<size(sptrpre,2))),2);
% % %         end
% % %             
% % %         
% % %         simmtx = nan(1,size(spikes1,2));simmtxcent=simmtx;simmtxtr=nan(1,size(pre,2));
% % %         for k = 1:size(spikes1,2)
% % %             Ca=spikes1(:,k)';Cb=spikes2(:,k)';
% % %             simmtx(1,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
% % %             Ca=spikescent1(:,k)';Cb=spikescent2(:,k)';
% % %             simmtxcent(1,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
% % %         end
% % %         grpfrmsim(anicnt,:) = simmtx;
% % %         grpfrmsimcent(anicnt,:) = simmtxcent;
% % %         for k = 1:size(pre,2)
% % %             Ca=pre(:,k)';Cb=post(:,k)';
% % %             simmtxtr(1,k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
% % %         end
% % %         grpfrmsimtr(anicnt,:) = simmtxtr;
% % %         
% % %         sprintf('doing shuffle ani %d/%d',anicnt,numAni)
% % %         tic
% % % %         shufsig = nan(1,shufreps);shufsigcent = shufsig;shufsigtr = shufsig;
% % % %         shufdist = zeros(1,numtrialtypes);
% % % %         simmtx = nan(shufreps,ntotframes);simmtxcent=simmtx;simmtxtr = nan(shufreps,numtrialtypes);
% % % %         simmtx=[];simmtxcent=[];simmtxtr=[];
% % %         %%%%fix this it takes forever, do something with simmtx
% % %         %%%%concatenation
% % %         parfor j=1:shufreps
% % %             shuf1 = spikespre;shuf2 = spikespost;shuftrpre = pre;shuftrpost = post;
% % %             for k = 1:size(shuf1,1)
% % %                 tshf = randi([1 size(shuf1,2)],1,1);
% % %                 shuf1(k,:) = circshift(shuf1(k,:),tshf,2);
% % %                 tshf = randi([1 size(shuf1,2)],1,1);
% % %                 shuf2(k,:) = circshift(shuf2(k,:),tshf,2);
% % %             end
% % %             shuf1cent = shuf1(usecells,:);shuf2cent = shuf2(usecells,:);
% % %             shuf1 = shuf1(1:cut,:);shuf2 = shuf2(1:cut,:);
% % %             
% % %             for k = 1:size(shuftrpre,1)
% % %                 tshf = randi([1 size(shuftrpre,2)],1,1);
% % %                 shuftrpre(k,:) = circshift(shuftrpre(k,:),tshf,2);
% % %                 tshf = randi([1 size(shuftrpost,2)],1,1);
% % %                 shuftrpost(k,:) = circshift(shuftrpost(k,:),tshf,2);
% % %             end
% % %                 
% % %             simmtx = nan(1,ntotframes);simmtxcent=simmtx;
% % %             for k = 1:ntotframes
% % %                 Ca=shuf1(:,k)';Cb=shuf2(:,k)';
% % %                 simmtx(k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
% % %                 Ca=shuf1cent(:,k)';Cb=shuf2cent(:,k)';
% % %                 simmtxcent(k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
% % %             end
% % %             grpsimmtx(anicnt,j,:) = simmtx;grpsimmtxcent(anicnt,j,:) = simmtxcent;
% % % %             shufsig(1,j) = prctile(simmtx,99);shufsigcent(1,j) = prctile(simmtxcent,99);
% % %             
% % %             simmtxtr = nan(1,numtrialtypes);
% % %             for k = 1:numtrialtypes
% % %                 Ca=shuftrpre(:,k)';Cb=shuftrpost(:,k)';
% % %                 simmtxtr(k) = (Ca.*Cb)/((Ca.^2 + Cb.^2)/2);
% % %             end
% % %             grpsimmtxtr(anicnt,j,:) = simmtxtr
% % % %             shufsigtr(1,j) = prctile(simmtxtr,99);
% % % %             shufdist = shufdist + simmtxtr;
% % %             
% % %         end
% % %         toc
% % % %         grpshufdist(anicnt,:) = shufdist/shufreps;
% % % %         anisig(anicnt,1) = nanmean(shufsig);anisig(anicnt,2) = nanmean(shufsigcent);
% % % %         anisigtr(anicnt) = nanmean(shufsigtr);
% % % %         grpsimmtx(anicnt,:) = simmtx;grpsimmtxcent(anicnt,:) = simmtxcent;grpsimmtxtr(anicnt,:) = simmtxtr;
% % %         simmtx = squeeze(grpsimmtx(anicnt,:,:));simmtxcent = squeeze(grpsimmtxcent(anicnt,:,:));
% % %         anisig(anicnt,1) = prctile(simmtx(:),99);anisig(anicnt,2) = prctile(simmtxcent(:),99);
% % %         simmtxtr = squeeze(grpsimmtxtr(anicnt,:,:));
% % %         anisigtr(anicnt) = prctile(simmtxtr(:),99);
        
        cellcnt = cellcnt+expcells;
        anicnt=anicnt+1;
    end

%     grprf = grprf(1:cellcnt,:);
    session = session(1:cellcnt);
    
    grpdfsize = grpdfsize(1:cellcnt,:,:,:,:,:); %cell#,t,contr,size,run,pre/post
    grpspsize = grpspsize(1:cellcnt,:,:,:,:,:);
    grpsptuning = grpsptuning(1:cellcnt,:,:,:,:,:,:);
    grpSIsp = grpSIsp(1:cellcnt,:,:);
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
    
    %%%pull out only cells w/response over predefined threshold
    valpre = max(squeeze(nanmean(grpspsize(:,spWindow{1},:,1,1),2)),[],2);
    valpost = max(squeeze(nanmean(grpspsize(:,spWindow{1},:,1,2),2)),[],2);
    threshcells = (valpre>spthresh)&(valpost>spthresh);
    grpspsize = grpspsize(threshcells,:,:,:,:);grpsptuning = grpsptuning(threshcells,:,:,:,:,:,:);
%     grpdfsize = grpdfsize(threshcells,:,:,:,:);grpdftuning = grpdftuning(threshcells,:,:,:,:,:,:);
    sess = session(threshcells);
    
% % %     prcanisig = nan(numAni,2);
% % %     for j = 1:numAni
% % %         prcanisig(j,1) = sum(grpfrmsim(j,:)>anisig(j,1))/ntotframes;
% % %         prcanisig(j,2) = sum(grpfrmsimcent(j,:)>anisig(j,2))/ntotframes;
% % %     end
% % %     
% % %     prcanisigtr = nan(numAni,1);
% % %     for j = 1:numAni
% % %         prcanisigtr(j) = sum(grpfrmsimtr(j,:)>anisigtr(j))/numtrialtypes;
% % %     end
    
    clear i j k l m

    sprintf('saving group file...')
    save(fullfile(savepath,grpfilename))
    sprintf('done')
else
    sprintf('loading data')
    load(fullfile(savepath,grpfilename))
end

%%

% % % 
% % % %%%see how similar responses are for pre and post across the population
% % % 
% % % figure;
% % % subplot(1,2,1)
% % % hold on
% % % for i = 1:numAni
% % %     plot(grpfrmsimtr(i,:),'o','MarkerSize',5,'color',mycol{i})
% % %     plot([0 numtrialtypes],[anisigtr(i) anisigtr(i)],':','LineWidth',2,'color',mycol{i})
% % % end
% % % axis([0 numtrialtypes 0 1])
% % % xlabel('unique stim number')
% % % ylabel('frame similarity index')
% % % axis square
% % % 
% % % subplot(1,2,2)
% % % hold on
% % % histo = nan(numAni,10);shufhist=histo;
% % % for i = 1:numAni
% % %     histo(i,:) = cumsum(hist(grpfrmsimtr(i,:),0.05:0.1:0.95))/size(grpfrmsimtr,2);
% % %     plot(histo(i,:),'-','LineWidth',2,'color',mycol{i})
% % % %     shufhist(i,:) = cumsum(hist(grpshufdist(i,:),10))/size(grpshufdist,2);
% % % %     plot(shufhist(i,:),':','LineWidth',2,'color',mycol{i})
% % %     plot([anisigtr(i)*10 anisigtr(i)*10],[0 1],'-.','LineWidth',1,'color',mycol{i})
% % % end
% % % plot(nanmean(histo),'-','LineWidth',4,'Color','k')
% % % plot(nanmean(shufhist),':','LineWidth',4,'Color','k')
% % % set(gca,'xtick',0:2:10,'xticklabel',0:0.2:1)
% % % axis([0 10 0 1])
% % % xlabel('similarity index')
% % % ylabel('cumulative frames')
% % % axis square
% % % 
% % % mtit(sprintf('unique stim similarity pre/post all cells mean=%0.2f +/- %0.2f',...
% % %     nanmean(nanmean(grpfrmsimtr,2),1),nanstd(nanmean(grpfrmsimtr,2),1)/sqrt(numAni)))
% % % if exist('psfile','var')
% % %     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %     print('-dpsc',psfile,'-append');
% % % end
% % % 
% % % %%plot shuffled vs. real data
% % % figure
% % % for i = 1:numAni
% % %     subplot(2,ceil(numAni/2),i)
% % %     simmtxtr = grpsimmtxtr(i,:,:);
% % %     histo = hist(simmtxtr(:),0:0.01:1);histo=histo/max(histo);
% % %     hold on
% % %     bar(0:0.01:1,histo,'k')
% % %     histo = hist(grpfrmsimtr(i,:),0:0.01:1);histo=histo/max(histo);
% % %     hold on
% % %     bar([0:0.01:1]+0.01,histo,'r')
% % %     plot([anisigtr(i) anisigtr(i)],[0 1],'g:')
% % %     legend('shuffle','data','sig','location','northwest')
% % %     axis([0 1 0 1])
% % %     axis square
% % %     xlabel('similarity index')
% % %     ylabel('normalized count')
% % %     title(sprintf('%s %s',files(use(i*2)).subj,files(use(i*2)).expt))
% % %     set(gca,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % % end
% % % mtit('sim of pop resp to each stim pre vs. post')
% % % if exist('psfile','var')
% % %     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %     print('-dpsc',psfile,'-append');
% % % end
% % % 
% % % 
% % % figure;
% % % subplot(1,2,1)
% % % hold on
% % % for i = 1:numAni
% % %     plot(grpfrmsim(i,:),'o','MarkerSize',3)
% % % end
% % % axis([0 ntotframes 0 1])
% % % xlabel('frame')
% % % ylabel('similarity index')
% % % axis square
% % % 
% % % subplot(1,2,2)
% % % hold on
% % % histo = nan(numAni,20);
% % % for i = 1:numAni
% % %     histo(i,:) = cumsum(hist(grpfrmsim(i,:),20))/size(grpfrmsim,2);
% % %     plot(histo(i,:),'-')
% % % end
% % % plot(nanmean(histo),'LineWidth',2,'Color','k')
% % % set(gca,'xtick',0:4:20,'xticklabel',0:0.2:1)
% % % axis([0 20 0 1])
% % % xlabel('similarity index')
% % % ylabel('cumulative frames')
% % % axis square
% % % 
% % % mtit(sprintf('frame similarity pre/post all cells mean=%0.2f +/- %0.2f',...
% % %     nanmean(nanmean(grpfrmsim,2),1),nanstd(nanmean(grpfrmsim,2),1)/sqrt(numAni)))
% % % if exist('psfile','var')
% % %     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %     print('-dpsc',psfile,'-append');
% % % end
% % % 
% % % 
% % % figure;
% % % subplot(1,2,1)
% % % hold on
% % % for i = 1:numAni
% % %     plot(grpfrmsimcent(i,:),'o','MarkerSize',3)
% % % end
% % % axis([0 ntotframes 0 1])
% % % xlabel('frame')
% % % ylabel('similarity index')
% % % axis square
% % % 
% % % subplot(1,2,2)
% % % hold on
% % % histo = nan(numAni,20);
% % % for i = 1:numAni
% % %     histo(i,:) = cumsum(hist(grpfrmsimcent(i,:),20))/size(grpfrmsimcent,2);
% % %     plot(histo(i,:),'-')
% % % end
% % % plot(nanmean(histo),'LineWidth',2,'Color','k')
% % % set(gca,'xtick',0:4:20,'xticklabel',0:0.2:1)
% % % axis([0 20 0 1])
% % % xlabel('similarity index')
% % % ylabel('cumulative frames')
% % % axis square
% % % 
% % % mtit(sprintf('frame similarity pre/post center cells mean=%0.2f +/- %0.2f',...
% % %     nanmean(nanmean(grpfrmsimcent,2),1),nanstd(nanmean(grpfrmsimcent,2),1)/sqrt(numAni)))
% % % if exist('psfile','var')
% % %     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %     print('-dpsc',psfile,'-append');
% % % end
% % % 
% % % % % % figure
% % % % % % hold on
% % % % % % plot([1 2 3],[prcanisigtr prcanisig],'k.')
% % % % % % errorbar([1 2 3],[nanmean(prcanisigtr) nanmean(prcanisig)],[nanstd(prcanisigtr)/sqrt(numAni) nanstd(prcanisig)/sqrt(numAni)],'LineStyle','none','Marker','o','Color','red')
% % % % % % axis([0.5 3.5 0 0.5])
% % % % % % set(gca,'xtick',1:3,'xticklabel',{'all unique' 'all frames','center frames'})
% % % % % % ylabel('fraction similar frames at p<0.01')
% % % % % % axis square
% % % % % % if exist('psfile','var')
% % % % % %     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % % % % %     print('-dpsc',psfile,'-append');
% % % % % % end


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
[h p] = ttest(pre,post);
title(sprintf('p = %0.3f',p))
subplot(1,2,2)
pre = grphistrad(:,:,1);post = grphistrad(:,:,2);
hold on
shadedErrorBar(1:11,nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
shadedErrorBar(1:11,nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
set(gca,'xtick',1:2:10,'xticklabel',[0:10:50],'ytick',0:2000:10000,'tickdir','out','fontsize',8)
xlabel('pupil diameter')
ylabel('number of frames')
legend('pre','post')
axis([0 11 0 10000])
axis square
mtit('pupil pre vs. post')
if exist('psfile','var')
    set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
    print('-dpsc',psfile,'-append');
end
%% 



% %%pixelwise analysis for each animal
% for z = 1:numAni
%     %%%plot sit dF
%     for h = 1:length(sfrange)
%         figure;
%         colormap jet
%         for i = 1:length(sizes)
%             subplot(4,length(sizes),i)
%             resp = squeeze(grpfrmdata(z,:,25:375,h,i,1,1)-grpfrmdata(z,:,25:375,h,1,1,1));
%             imagesc(imresize(resp,0.5),[-0.01 0.3])
%             set(gca,'ytick',[],'xtick',[],'FontSize',7)
%             xlabel(sprintf('sit %sdeg pre',sizes{i}))
%             axis square
%             subplot(4,length(sizes),i+length(sizes))
%             resp = squeeze(grpfrmdata(z,:,25:375,h,i,1,2)-grpfrmdata(z,:,25:375,h,1,1,2));
%             imagesc(imresize(resp,0.5),[-0.01 0.3])
%             set(gca,'ytick',[],'xtick',[],'FontSize',7)
%             xlabel(sprintf('sit %sdeg post',sizes{i}))
%             axis square
%         end
%         for i = 1:length(sizes)
%             subplot(4,length(sizes),i+2*length(sizes))
%             resp = squeeze(grpfrmdata(z,:,25:375,h,i,2,1)-grpfrmdata(z,:,25:375,h,1,2,1));
%             imagesc(imresize(resp,0.5),[-0.01 0.3])
%             set(gca,'ytick',[],'xtick',[],'FontSize',7)
%             xlabel(sprintf('run %sdeg pre',sizes{i}))
%             axis square
%             subplot(4,length(sizes),i+3*length(sizes))
%             resp = squeeze(grpfrmdata(z,:,25:375,h,i,2,2)-grpfrmdata(z,:,25:375,h,1,2,2));
%             imagesc(imresize(resp,0.5),[-0.01 0.3])
%             set(gca,'ytick',[],'xtick',[],'FontSize',7)
%             xlabel(sprintf('run %sdeg post',sizes{i}))
%             axis square
%         end
%         mtit(sprintf('dF/size %0.2fcpd %s',sfrange(h),files(use(z*2)).subj))
%         if exist('psfile','var')
%             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%             print('-dpsc',psfile,'-append');
%         end
%     end
%     
%     figure
%     subplot(2,2,1)
%     resp = squeeze(nanmean(grpfrmdata(z,:,:,:,1,1,1),4));
%     imagesc(resp,[-0.01 0.1])
%     set(gca,'ytick',[],'xtick',[])
%     xlabel('pre sit')
%     axis square
%     subplot(2,2,2)
%     resp = squeeze(nanmean(grpfrmdata(z,:,:,:,1,2,1),4));
%     imagesc(resp,[-0.01 0.1])
%     set(gca,'ytick',[],'xtick',[])
%     xlabel('pre run')
%     axis square
%     subplot(2,2,3)
%     resp = squeeze(nanmean(grpfrmdata(z,:,:,:,1,1,2),4));
%     imagesc(resp,[-0.01 0.1])
%     set(gca,'ytick',[],'xtick',[])
%     xlabel('post sit')
%     axis square
%     subplot(2,2,4)
%     resp = squeeze(nanmean(grpfrmdata(z,:,:,:,1,2,2),4));
%     imagesc(resp,[-0.01 0.1])
%     set(gca,'ytick',[],'xtick',[])
%     xlabel('post run')
%     axis square
%     mtit(sprintf('0deg responses %s',files(use(z*2)).subj))
%     if exist('psfile','var')
%         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%         print('-dpsc',psfile,'-append');
%     end
% end
% 
% 
% % % % %         %%%plot run dF
% % % % %         figure;
% % % % %         colormap jet
% % % % %         for i = 2:length(sizes)
% % % % %             subplot(2,floor(length(sizes)/2),i-1)
% % % % %             resp = nanmean(frmdata(:,:,h,i,2),3);
% % % % %             imagesc(resp,[-0.01 0.1])
% % % % %             set(gca,'ytick',[],'xtick',[])
% % % % %             xlabel(sprintf('%sdeg',sizes{i}))
% % % % %             axis square
% % % % %         end
% % % % %         mtit(sprintf('run dF/size %0.2fcpd',sfrange(h)))
% % % % %         if exist('psfile','var')
% % % % %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % % % %             print('-dpsc',psfile,'-append');
% % % % %         end
% 

%%
%analysis of spatial spread
sprmax = nanmean(nanmean(nanmean(nanmean(nanmean(grpring,1),3),4),5),6);
sprmax = length(sprmax(~isnan(sprmax)));
for j = 1:length(sfrange)
    for k = 1:2
        figure
        for i=2:length(sizes)
            subplot(2,floor(length(sizes)/2),i-1)
            pre=squeeze(grpring(:,1:sprmax,j,i,k,1)) - squeeze(grpring(:,1:sprmax,j,1,k,1));post=squeeze(grpring(:,1:sprmax,j,i,k,2))- squeeze(grpring(:,1:sprmax,j,1,k,2));
            hold on
            shadedErrorBar(0:(sprmax-1),nanmean(pre),nanstd(pre)/sqrt(numAni),'k',1)
            shadedErrorBar(0:(sprmax-1),nanmean(post),nanstd(post)/sqrt(numAni),'r',1)
            plot([0 sprmax-1],[0 0],'b:')
            axis square
            axis([0 sprmax-1 -0.05 0.3])
            xlabel('dist from cent (um)')
            ylabel(sprintf('%sdeg dfof',sizes{i}))
            set(gca,'xtick',[0:5:sprmax],'xticklabel',[0:5*binwidth:sprmax*binwidth])
        end
        mtit(sprintf('%s spread from center N=%d animals %0.2fcpd',stlb{k},numAni,sfrange(j)));
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end
    end
end

% % % 
% % % %%%plot zero size (unsubtracted)
% % % figure
% % % presit=squeeze(nanmean(grpring(:,:,:,1,1,1),3));postsit=squeeze(nanmean(grpring(:,:,:,1,1,2),3));
% % % prerun=squeeze(nanmean(grpring(:,:,:,1,2,1),3));postrun=squeeze(nanmean(grpring(:,:,:,1,2,2),3));
% % % subplot(1,2,1)
% % % hold on
% % % shadedErrorBar(0:79,nanmean(presit),nanstd(presit)/sqrt(numAni),'k',1)
% % % shadedErrorBar(0:79,nanmean(postsit),nanstd(postsit)/sqrt(numAni),'r',1)
% % % axis square
% % % plot([0 10],[0 0],'b:')
% % % axis([0 10 -0.15 0.1])
% % % xlabel('dist from cent (um)')
% % % set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
% % % ylabel('zero size sit')
% % % subplot(1,2,2)
% % % hold on
% % % shadedErrorBar(0:79,nanmean(prerun),nanstd(prerun)/sqrt(numAni),'k',1)
% % % shadedErrorBar(0:79,nanmean(postrun),nanstd(postrun)/sqrt(numAni),'r',1)
% % % plot([0 10],[0 0],'b:')
% % % axis square
% % % axis([0 10 -0.15 0.1])
% % % xlabel('dist from cent (um)')
% % % set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
% % % ylabel('zero size run')
% % % mtit(sprintf('spread from center zero size N=%d animals',numAni));
% % % if exist('psfile','var')
% % %     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %     print('-dpsc',psfile,'-append');
% % % end
% % % 
% % %%%same thing by animal
% % figure
% % for i=2:length(sizes)
% %     subplot(2,floor(length(sizes)/2),i-1)
% %     pre=squeeze(grpring(:,:,1,i,1,1))- squeeze(grpring(:,:,1,1,1,1));post=squeeze(grpring(:,:,1,i,1,2))- squeeze(grpring(:,:,1,1,1,2));
% %     hold on
% %     plot(0:79,pre,'k')
% %     plot(0:79,post,'r')
% %     plot([0 10],[0 0],'m:')
% %     axis square
% %     axis([0 10 -0.05 0.3])
% %     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
% %     
% %     %%%gaussian fit, removing animals with NaN values
% %     fitanipre = ~isnan(pre(1:numAni,1));
% %     fitanipost = ~isnan(post(1:numAni,1));
% %     fitani = fitanipre&fitanipost;
% %     [prea preb prec preresult] = gausFit(0:9,pre(fitani,1:10),[0.1 2 0.05]);
% %     [posta postb postc postresult] = gausFit(0:9,post(fitani,1:10),[0.1 2 0.05]);
% %     
% %     for j = 1:length(preresult)
% %         plot(preresult{j},'k:')
% %     end
% %     for j = 1:length(postresult)
% %         plot(postresult{j},'r:')
% %     end
% %     
% %     legend off
% %     
% %     [h pa] = ttest(prea,posta);
% %     [h pb] = ttest(preb,postb);
% %     [h pc] = ttest(prec,postc);
% %     
% %     xlabel('dist from cent (um)')
% %     ylabel(sprintf('%sdeg dfof',sizes{i}))
% %     title(sprintf('pa=%0.3f pb=%0.3f pc=%0.3f',pa,pb,pc))
% %     set(gca,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% %     
% % end
% % mtit(sprintf('Sit spread from center N=%d animals %0.2fcpd',numAni,sfrange(1)));
% % if exist('psfile','var')
% %     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i=2:length(sizes)
% %     subplot(2,floor(length(sizes)/2),i-1)
% %     pre=squeeze(grpring(:,:,2,i,1,1)) - squeeze(grpring(:,:,2,1,1,1));post=squeeze(grpring(:,:,2,i,1,2)) - squeeze(grpring(:,:,2,1,1,2));
% %     hold on
% %     plot(0:79,pre,'k')
% %     plot(0:79,post,'r')
% %     plot([0 10],[0 0],'b:')
% %     axis square
% %     axis([0 10 -0.05 0.3])
% %     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
% %     
% %     %%%gaussian fit, removing animals with NaN values
% %     fitanipre = ~isnan(pre(1:numAni,1));
% %     fitanipost = ~isnan(post(1:numAni,1));
% %     fitani = fitanipre&fitanipost;
% %     [prea preb prec preresult] = gausFit(0:9,pre(fitani,1:10),[0.1 2 0.05]);
% %     [posta postb postc postresult] = gausFit(0:9,post(fitani,1:10),[0.1 2 0.05]);
% %     
% %     for j = 1:length(preresult)
% %         plot(preresult{j},'k:')
% %     end
% %     for j = 1:length(postresult)
% %         plot(postresult{j},'r:')
% %     end
% %     
% %     legend off
% %     
% %     [h pa] = ttest(prea,posta);
% %     [h pb] = ttest(preb,postb);
% %     [h pc] = ttest(prec,postc);
% %     
% %     xlabel('dist from cent (um)')
% %     ylabel(sprintf('%sdeg dfof',sizes{i}))
% %     title(sprintf('pa=%0.3f pb=%0.3f pc=%0.3f',pa,pb,pc))
% %     set(gca,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % end
% % mtit(sprintf('Sit spread from center N=%d animals %0.2fcpd',numAni,sfrange(2)));
% % if exist('psfile','var')
% %     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i=2:length(sizes)
% %     subplot(2,floor(length(sizes)/2),i-1)
% %     pre=squeeze(grpring(:,:,1,i,2,1)) - squeeze(grpring(:,:,1,1,2,1));post=squeeze(grpring(:,:,1,i,2,2)) - squeeze(grpring(:,:,1,1,2,2));
% %     hold on
% %     plot(0:79,pre,'k')
% %     plot(0:79,post,'r')
% %     plot([0 10],[0 0],'b:')
% %     axis square
% %     axis([0 10 -0.05 0.3])
% %     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
% %     
% %     %%%gaussian fit, removing animals with NaN values
% %     fitanipre = ~isnan(pre(1:numAni,1));
% %     fitanipost = ~isnan(post(1:numAni,1));
% %     fitani = fitanipre&fitanipost;
% %     [prea preb prec preresult] = gausFit(0:9,pre(fitani,1:10),[0.1 2 0.05]);
% %     [posta postb postc postresult] = gausFit(0:9,post(fitani,1:10),[0.1 2 0.05]);
% %     
% %     for j = 1:length(preresult)
% %         plot(preresult{j},'k:')
% %     end
% %     for j = 1:length(postresult)
% %         plot(postresult{j},'r:')
% %     end
% %     
% %     legend off
% %     
% %     [h pa] = ttest(prea,posta);
% %     [h pb] = ttest(preb,postb);
% %     [h pc] = ttest(prec,postc);
% %     
% %     xlabel('dist from cent (um)')
% %     ylabel(sprintf('%sdeg dfof',sizes{i}))
% %     title(sprintf('pa=%0.3f pb=%0.3f pc=%0.3f',pa,pb,pc))
% %     set(gca,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % end
% % mtit(sprintf('Run spread from center N=%d animals %0.2fcpd',numAni,sfrange(1)));
% % if exist('psfile','var')
% %     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %     print('-dpsc',psfile,'-append');
% % end
% % 
% % figure
% % for i=2:length(sizes)
% %     subplot(2,floor(length(sizes)/2),i-1)
% %     pre=squeeze(grpring(:,:,2,i,2,1)) - squeeze(grpring(:,:,2,1,2,1));post=squeeze(grpring(:,:,2,i,2,2)) - squeeze(grpring(:,:,2,1,2,2));
% %     hold on
% %     plot(0:79,pre,'k')
% %     plot(0:79,post,'r')
% %     plot([0 10],[0 0],'b:')
% %     axis square
% %     axis([0 10 -0.05 0.3])
% %     set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
% %     
% %     %%%gaussian fit, removing animals with NaN values
% %     fitanipre = ~isnan(pre(1:numAni,1));
% %     fitanipost = ~isnan(post(1:numAni,1));
% %     fitani = fitanipre&fitanipost;
% %     [prea preb prec preresult] = gausFit(0:9,pre(fitani,1:10),[0.1 2 0.05]);
% %     [posta postb postc postresult] = gausFit(0:9,post(fitani,1:10),[0.1 2 0.05]);
% %     
% %     for j = 1:length(preresult)
% %         plot(preresult{j},'k:')
% %     end
% %     for j = 1:length(postresult)
% %         plot(postresult{j},'r:')
% %     end
% %     
% %     legend off
% %     
% %     [h pa] = ttest(prea,posta);
% %     [h pb] = ttest(preb,postb);
% %     [h pc] = ttest(prec,postc);
% %     
% %     xlabel('dist from cent (um)')
% %     ylabel(sprintf('%sdeg dfof',sizes{i}))
% %     title(sprintf('pa=%0.3f pb=%0.3f pc=%0.3f',pa,pb,pc))
% %     set(gca,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % end
% % mtit(sprintf('Run spread from center N=%d animals %0.2fcpd',numAni,sfrange(2)));
% % if exist('psfile','var')
% %     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% %     print('-dpsc',psfile,'-append');
% % end
% % % 
% % % %%%plot zero size (unsubtracted)
% % % figure
% % % presit=squeeze(nanmean(grpring(:,:,:,1,1,1),3));postsit=squeeze(nanmean(grpring(:,:,:,1,1,2),3));
% % % prerun=squeeze(nanmean(grpring(:,:,:,1,2,1),3));postrun=squeeze(nanmean(grpring(:,:,:,1,2,2),3));
% % % subplot(1,2,1)
% % % hold on
% % % plot(0:79,presit,'k')
% % % plot(0:79,postsit,'r')
% % % axis square
% % % plot([0 10],[0 0],'b:')
% % % axis([0 10 -0.15 0.1])
% % % xlabel('dist from cent (um)')
% % % set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
% % % ylabel('zero size sit')
% % % subplot(1,2,2)
% % % hold on
% % % plot(0:79,prerun,'k')
% % % plot(0:79,postrun,'r')
% % % axis square
% % % plot([0 10],[0 0],'b:')
% % % axis([0 10 -0.15 0.1])
% % % xlabel('dist from cent (um)')
% % % set(gca,'xtick',[0:5:10],'xticklabel',[0:5*binwidth:10*binwidth])
% % % ylabel('zero size sit')
% % % mtit(sprintf('spread from center zero size N=%d animals',numAni));
% % % if exist('psfile','var')
% % %     set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %     print('-dpsc',psfile,'-append');
% % % end
% % % 
% % % 
% % % %%comparison w/SF factored in
% % % % hmin = -0.25;hmax = 0.25;hedges = [-1,1];
% % % % for i = 1:numAni
% % % %     figure
% % % %     subplot(3,3,1)
% % % %     pre = squeeze(grpfrmdata(i,:,:,1,2,1,1)); post = squeeze(grpfrmdata(i,:,:,1,2,1,2));
% % % % %     diff = ((pre+min(min(pre)))-(post+min(min(post))))/(pre+min(min(pre)));
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % % %     xlabel(sprintf('%sdeg pre',sizes{2}))
% % % %     subplot(3,3,2)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % % %     xlabel(sprintf('%sdeg post',sizes{2}))
% % % %     subplot(3,3,3)
% % % % %     imagesc(diff, [-1 1]); axis equal
% % % %     hold on
% % % %     histogram(reshape(pre,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','k')
% % % %     histogram(reshape(post,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','r')
% % % %     axis square
% % % %     axis([hmin hmax 0 30000])
% % % %     xlabel(sprintf('%sdeg diff',sizes{2}))
% % % %     ylabel('pixel count')
% % % %     set(gca,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % % %     subplot(3,3,4)
% % % %     pre = squeeze(grpfrmdata(i,:,:,1,3,1,1)); post = squeeze(grpfrmdata(i,:,:,1,3,1,2));
% % % % %     diff = ((pre+min(min(pre)))-(post+min(min(post))))/(pre+min(min(pre)));
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % % %     xlabel(sprintf('%sdeg pre',sizes{3}))
% % % %     subplot(3,3,5)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % % %     xlabel(sprintf('%sdeg post',sizes{3}))
% % % %     subplot(3,3,6)
% % % % %     imagesc(diff, [-1 1]); axis equal
% % % %     hold on
% % % %     histogram(reshape(pre,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','k')
% % % %     histogram(reshape(post,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','r')
% % % %     axis square
% % % %     axis([hmin hmax 0 30000])
% % % %     xlabel(sprintf('%sdeg diff',sizes{3}))
% % % %     ylabel('pixel count')
% % % %     set(gca,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % % %     subplot(3,3,7)
% % % %     pre = squeeze(grpfrmdata(i,:,:,1,end,1,1)); post = squeeze(grpfrmdata(i,:,:,1,end,1,2));
% % % % %     diff = ((pre+min(min(pre)))-(post+min(min(post))))/(pre+min(min(pre)));
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % % %     xlabel(sprintf('%sdeg pre',sizes{end}))
% % % %     subplot(3,3,8)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[],'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % % %     xlabel(sprintf('%sdeg post',sizes{end}))
% % % %     subplot(3,3,9)
% % % % %     imagesc(diff, [-1 1]); axis equal
% % % %     hold on
% % % %     histogram(reshape(pre,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','k')
% % % %     histogram(reshape(post,[1,398*398]),100,'BinLimits',hedges,'EdgeAlpha',0.5,'FaceAlpha',0.5,'FaceColor','r')
% % % %     axis square
% % % %     axis([hmin hmax 0 30000])
% % % %     xlabel(sprintf('%sdeg diff',sizes{end}))
% % % %     ylabel('pixel count')
% % % %     set(gca,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
% % % %     mtit(sprintf('%s SF=0.04cpd sit',files(use(i*2)).subj))
% % % %     if exist('psfile','var')
% % % %         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % % %         print('-dpsc',psfile,'-append');
% % % %     end
% % % % end
% % % %     
% % % %     figure
% % % %     subplot(3,3,1)
% % % %     pre = squeeze(grpfrmdata(i,:,:,2,2,1,1)); post = squeeze(grpfrmdata(i,:,:,2,2,1,2)); diff = post-pre;
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg pre',sizes{2}))
% % % %     subplot(3,3,2)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg post',sizes{2}))
% % % %     subplot(3,3,3)
% % % %     imagesc(diff, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg diff',sizes{2}))
% % % %     subplot(3,3,4)
% % % %     pre = squeeze(grpfrmdata(i,:,:,2,3,1,1)); post = squeeze(grpfrmdata(i,:,:,2,3,1,2)); diff = post-pre;
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg pre',sizes{3}))
% % % %     subplot(3,3,5)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg post',sizes{3}))
% % % %     subplot(3,3,6)
% % % %     imagesc(diff, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg diff',sizes{3}))
% % % %     subplot(3,3,7)
% % % %     pre = squeeze(grpfrmdata(i,:,:,2,end,1,1)); post = squeeze(grpfrmdata(i,:,:,2,end,1,2)); diff = post-pre;
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg pre',sizes{end}))
% % % %     subplot(3,3,8)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg post',sizes{end}))
% % % %     subplot(3,3,9)
% % % %     imagesc(diff, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg diff',sizes{end}))
% % % %     mtit(sprintf('%s SF=0.16cpd sit',files(use(i*2)).subj))
% % % %     if exist('psfile','var')
% % % %         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % % %         print('-dpsc',psfile,'-append');
% % % %     end
% % % %     
% % % %     figure
% % % %     subplot(3,3,1)
% % % %     pre = squeeze(grpfrmdata(i,:,:,1,2,2,1)); post = squeeze(grpfrmdata(i,:,:,1,2,2,2)); diff = post-pre;
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg pre',sizes{2}))
% % % %     subplot(3,3,2)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg post',sizes{2}))
% % % %     subplot(3,3,3)
% % % %     imagesc(diff, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg diff',sizes{2}))
% % % %     subplot(3,3,4)
% % % %     pre = squeeze(grpfrmdata(i,:,:,1,3,2,1)); post = squeeze(grpfrmdata(i,:,:,1,3,2,2)); diff = post-pre;
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg pre',sizes{3}))
% % % %     subplot(3,3,5)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg post',sizes{3}))
% % % %     subplot(3,3,6)
% % % %     imagesc(diff, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg diff',sizes{3}))
% % % %     subplot(3,3,7)
% % % %     pre = squeeze(grpfrmdata(i,:,:,1,end,2,1)); post = squeeze(grpfrmdata(i,:,:,1,end,2,2)); diff = post-pre;
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg pre',sizes{end}))
% % % %     subplot(3,3,8)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg post',sizes{end}))
% % % %     subplot(3,3,9)
% % % %     imagesc(diff, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg diff',sizes{end}))
% % % %     mtit(sprintf('%s SF=0.04cpd run',files(use(i*2)).subj))
% % % %     if exist('psfile','var')
% % % %         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % % %         print('-dpsc',psfile,'-append');
% % % %     end
% % % %     
% % % %     figure
% % % %     subplot(3,3,1)
% % % %     pre = squeeze(grpfrmdata(i,:,:,2,2,2,1)); post = squeeze(grpfrmdata(i,:,:,2,2,2,2)); diff = post-pre;
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg pre',sizes{2}))
% % % %     subplot(3,3,2)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg post',sizes{2}))
% % % %     subplot(3,3,3)
% % % %     imagesc(diff, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg diff',sizes{2}))
% % % %     subplot(3,3,4)
% % % %     pre = squeeze(grpfrmdata(i,:,:,2,3,2,1)); post = squeeze(grpfrmdata(i,:,:,2,3,2,2)); diff = post-pre;
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg pre',sizes{3}))
% % % %     subplot(3,3,5)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg post',sizes{3}))
% % % %     subplot(3,3,6)
% % % %     imagesc(diff, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg diff',sizes{3}))
% % % %     subplot(3,3,7)
% % % %     pre = squeeze(grpfrmdata(i,:,:,2,end,2,1)); post = squeeze(grpfrmdata(i,:,:,2,end,2,2)); diff = post-pre;
% % % %     imagesc(pre, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg pre',sizes{end}))
% % % %     subplot(3,3,8)
% % % %     imagesc(post, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg post',sizes{end}))
% % % %     subplot(3,3,9)
% % % %     imagesc(diff, [-0.01 0.1]); axis equal
% % % %     set(gca,'ytick',[],'xtick',[])
% % % %     xlabel(sprintf('%sdeg diff',sizes{end}))
% % % %     mtit(sprintf('%s SF=0.16cpd run',files(use(i*2)).subj))
% % % %     if exist('psfile','var')
% % % %         set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % % %         print('-dpsc',psfile,'-append');
% % % %     end
% % % % end
%%
    

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

%     %%%%plot stationary size curves
%     figure
%     subplot(1,3,1)
%     hold on
%     pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},spWindow,:,1,1),2),1));
%     post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},spWindow,:,1,2),2),1));
%     plot(1:length(radiusRange),pre,'k-o','Markersize',5)
%     plot(1:length(radiusRange),post,'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
%     ylabel('entire spike window')
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
%     axis square
%     set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     subplot(1,3,2)
%     hold on
%     pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},6:7,:,1,1),2),1));
%     post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},6:7,:,1,2),2),1));
%     plot(1:length(radiusRange),pre,'k-o','Markersize',5)
%     plot(1:length(radiusRange),post,'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
%     ylabel('first half')
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
%     axis square
%     set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     subplot(1,3,3)
%     hold on
%     pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},8:10,:,1,1),2),1));
%     post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},8:10,:,1,2),2),1));
%     plot(1:length(radiusRange),pre,'k-o','Markersize',5)
%     plot(1:length(radiusRange),post,'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
%     ylabel('second half')
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
%     axis square
%     set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     mtit(sprintf('Mean cell (n=%d) size suppression curve (cc>%0.2f) sit',length(goodcc{z}),ccvals(z)))
%     if exist('psfile','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfile,'-append');
%     end
%     
%     
%     %%%%plot running size curves
%     figure
%     subplot(1,3,1)
%     hold on
%     pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},spWindow,:,2,1),2),1));
%     post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},spWindow,:,2,2),2),1));
%     plot(1:length(radiusRange),pre,'k-o','Markersize',5)
%     plot(1:length(radiusRange),post,'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
%     ylabel('entire spike window')
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
%     axis square
%     set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     subplot(1,3,2)
%     hold on
%     pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},6:7,:,2,1),2),1));
%     post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},6:7,:,2,2),2),1));
%     plot(1:length(radiusRange),pre,'k-o','Markersize',5)
%     plot(1:length(radiusRange),post,'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
%     ylabel('fist half')
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
%     axis square
%     set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     subplot(1,3,3)
%     hold on
%     pre = squeeze(nanmean(nanmean(grpspsize(goodcc{z},8:10,:,2,1),2),1));
%     post = squeeze(nanmean(nanmean(grpspsize(goodcc{z},8:10,:,2,2),2),1));
%     plot(1:length(radiusRange),pre,'k-o','Markersize',5)
%     plot(1:length(radiusRange),post,'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
%     ylabel('second half')
%     axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
%     axis square
%     set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'Fontsize',8)
%     mtit(sprintf('Mean cell (n=%d) size suppression curve (cc>%0.2f) run',length(goodcc{z}),ccvals(z)))
%     if exist('psfile','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfile,'-append');
%     end
%     
%     
%     %%%plot cycle averages
%     figure
%     plotmin = min(min([nanmean(grpspsize(goodcc{z},:,:,1,1),1) nanmean(grpspsize(goodcc{z},:,:,1,2),1)])) - 0.05;
%     plotmax = max(max([nanmean(grpspsize(goodcc{z},:,:,1,1),1) nanmean(grpspsize(goodcc{z},:,:,1,2),1)])) + 0.1;
%     for i = 2:length(sizes)
%         subplot(2,3,i-1)
%         pre = grpspsize(goodcc{z},:,i,1,1);
%         post = grpspsize(goodcc{z},:,i,1,2);
%         hold on
%         shadedErrorBar(timepts,squeeze(nanmean(pre,1)),...
%             squeeze(nanstd(pre,1))/sqrt(length(goodcc{z})),'k',1)
%         shadedErrorBar(timepts,squeeze(nanmean(post,1)),...
%             squeeze(nanstd(post,1))/sqrt(length(goodcc{z})),'r',1)
%         plot([0 0],[plotmin plotmax],'b-')
%         axis square
%         axis([timepts(1) timepts(end) plotmin plotmax])
%         set(gca,'LooseInset',get(gca,'TightInset'))
%     end
%     mtit('Mean cell cycle avg/size sit')
%     if exist('psfile','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfile,'-append');
%     end
% 
%     figure
%     plotmin = min(min([nanmean(grpspsize(goodcc{z},:,:,2,1),1) nanmean(grpspsize(goodcc{z},:,:,2,2),1)])) - 0.05;
%     plotmax = max(max([nanmean(grpspsize(goodcc{z},:,:,2,1),1) nanmean(grpspsize(goodcc{z},:,:,2,2),1)])) + 0.1;
%     for i = 2:length(sizes)
%         subplot(2,3,i-1)
%         pre = grpspsize(goodcc{z},:,i,2,1);
%         post = grpspsize(goodcc{z},:,i,2,2);
%         hold on
%         shadedErrorBar(timepts,squeeze(nanmean(pre,1)),...
%             squeeze(nanstd(pre,1))/sqrt(length(goodcc{z})),'k',1)
%         shadedErrorBar(timepts,squeeze(nanmean(post,1)),...
%             squeeze(nanstd(post,1))/sqrt(length(goodcc{z})),'r',1)
%         plot([0 0],[plotmin plotmax],'b-')
%         axis square
%         if i>1
%             axis([timepts(1) timepts(end) plotmin plotmax])
%         end
%         set(gca,'LooseInset',get(gca,'TightInset'))
%     end
%     mtit('Mean cell cycle avg/size run')
%     if exist('psfile','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfile,'-append');
%     end
% 
%     figure
%     subplot(1,2,1)
%     hold on
%     plot([0 1],[0 1],'k--')
%     plot(grpSI(goodcc{z},1,1),grpSI(goodcc{z},1,2),'k.','Markersize',20)
%     errorbarxy(nanmean(grpSI(goodcc{z},1,1)),nanmean(grpSI(goodcc{z},1,2)),...
%         nanstd(grpSI(goodcc{z},1,1))/sqrt(length(goodcc{z})),nanstd(grpSI(goodcc{z},1,2))/sqrt(length(goodcc{z})))
%     axis([0 1 0 1])
%     xlabel('sit pre SI')
%     ylabel('sit post SI')
%     axis square
%     subplot(1,2,2)
%     hold on
%     plot([0 1],[0 1],'k--')
%     plot(grpSI(goodcc{z},2,1),grpSI(goodcc{z},2,2),'k.','Markersize',20)
%     errorbarxy(nanmean(grpSI(goodcc{z},2,1)),nanmean(grpSI(goodcc{z},2,2)),...
%         nanstd(grpSI(goodcc{z},2,1))/sqrt(length(goodcc{z})),nanstd(grpSI(goodcc{z},2,2))/sqrt(length(goodcc{z})))
%     axis([0 1 0 1])
%     xlabel('run pre SI')
%     ylabel('run post SI')
%     axis square
%     mtit('Cell Suppression Index')
%     if exist('psfile','var')
%         set(gcf, 'PaperPositionMode', 'auto');
%         print('-dpsc',psfile,'-append');
%     end



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
    
    
%     %%%individual animal figures
%     for j = 1:length(unique(sess))
%         figure
%         pre = squeeze(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),:,:,1,1),1)); %pre(1)=0; %median of 0 = nan
%         post = squeeze(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),:,:,1,2),1)); %post(1)=0;
%         for i = 2:length(sizes)
%             subplot(5,6,i-1)
%             hold on
%             plot(timepts,pre(:,i),'k-')
%             plot(timepts,post(:,i),'r-')
%             xlabel(sprintf('%sdeg time (s)',sizes{i}))
%             ylabel('sit dfof')
%             axis([-0.5 1.0 -0.05 0.5])
%             axis square
%             set(gca,'LooseInset',get(gca,'TightInset'),'FontSize',7)
%         end
%         pre = squeeze(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),:,:,2,1),1)); %pre(1)=0; %median of 0 = nan
%         post = squeeze(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),:,:,2,2),1)); %post(1)=0;
%         for i = 2:length(sizes)
%             subplot(5,6,i-1+6)
%             hold on
%             plot(timepts,pre(:,i),'k-')
%             plot(timepts,post(:,i),'r-')
%             xlabel(sprintf('%sdeg time (s)',sizes{i}))
%             ylabel('run dfof')
%             axis([-0.5 1.0 -0.05 0.5])
%             axis square
%             set(gca,'LooseInset',get(gca,'TightInset'),'FontSize',7)
%         end
%         
%         for i = 2:length(sizes)
%             subplot(5,6,i-1+12)
%             resp = squeeze(nanmean(grpfrmdata(j,:,:,:,i,1,1),4)-nanmean(grpfrmdata(j,:,:,:,1,1,1),4));
%             imagesc(imresize(resp,0.25),[-0.01 0.3])
%             set(gca,'ytick',[],'xtick',[],'FontSize',7,'LooseInset',get(gca,'TightInset'))
%             xlabel(sprintf('%sdeg pre',sizes{i}))
%             axis square
%         end
%         for i = 2:length(sizes)
%             subplot(5,6,i-1+18)
%             resp = squeeze(nanmean(grpfrmdata(j,:,:,:,i,1,2),4)-nanmean(grpfrmdata(j,:,:,:,1,1,2),4));
%             imagesc(imresize(resp,0.25),[-0.01 0.3])
%             set(gca,'ytick',[],'xtick',[],'FontSize',7,'LooseInset',get(gca,'TightInset'))
%             xlabel(sprintf('%sdeg post',sizes{i}))
%             axis square
%         end
%         
%         subplot(5,6,25)
%         pre=nan(length(unique(sess)),length(sizes));post=pre;
%         pre = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{1},:,1,1),2),1));
%         post = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{1},:,1,2),2),1));
%         hold on
%         plot(1:length(radiusRange),pre,'k-')
%         plot(1:length(radiusRange),post,'r-')
%         xlabel('Stim Size (deg)')
%         ylabel('sit dfof')
%         axis([0 length(radiusRange)+1 -0.05 0.5])
%         axis square
%         set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'FontSize',7)
%         
%         subplot(5,6,26)
%         pre=nan(length(unique(sess)),length(sizes));post=pre;
%         pre = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{1},:,2,1),2),1));
%         post = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{1},:,2,2),2),1));
%         hold on
%         plot(1:length(radiusRange),pre,'k-')
%         plot(1:length(radiusRange),post,'r-')
%         xlabel('Stim Size (deg)')
%         ylabel('run dfof')
%         axis([0 length(radiusRange)+1 -0.05 0.5])
%         axis square
%         set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'FontSize',7)
%         
%         mtit(sprintf('%s %s %s',files(use(j*2)).subj,files(use(j*2)).training,files(use(j*2)).inject))
%         
%         if exist('psfile','var')
%             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
%             print('-dpsc',psfile,'-append');
%         end
%     end
 
%%
    %%%cycle averages
    figure
    for i = 2:length(sizes)
%         figure
        subplot(2,3,i-1)
        hold on
        pre=nan(length(unique(sess)),length(timepts));post=pre;
        for j = 1:length(unique(sess))
                pre(j,:) = nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),:,i,1,1),1);
                post(j,:) = nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),:,i,1,2),1);
        end
        if length(unique(sess))==1
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
    mtit('Animal response/size sit pref stim')
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end

    figure
    for i = 2:length(sizes)
        subplot(2,3,i-1)
        hold on
        pre=nan(length(unique(sess)),length(timepts));post=pre;
        for j = 1:length(unique(sess))
                pre(j,:) = nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),:,i,2,1),1);
                post(j,:) = nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),:,i,2,2),1);
        end
        if length(unique(sess))==1
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
    mtit('Animal response/size run pref stim')
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
    
    
    %%%cycle averages
    figure
    for i = 2:length(sizes)
%         figure
        subplot(2,3,i-1)
        hold on
        pre=nan(length(unique(sess)),length(timepts));post=pre;
        for j = 1:length(unique(sess))
                pre(j,:) = nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),:,:,:,i,1,1),4),3),1);
                post(j,:) = nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),:,:,:,i,1,2),4),3),1);
        end
        if length(unique(sess))==1
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
    mtit('Animal response/size sit all stim')
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end

    figure
    for i = 2:length(sizes)
        subplot(2,3,i-1)
        hold on
        pre=nan(length(unique(sess)),length(timepts));post=pre;
        for j = 1:length(unique(sess))
                pre(j,:) = nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),:,:,:,i,2,1),4),3),1);
                post(j,:) = nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),:,:,:,i,2,2),4),3),1);
        end
        if length(unique(sess))==1
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
    mtit('Animal response/size run all stim')
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
    
    
    
%% 
    %%%mean animal size curve sit
    figure
    subplot(3,3,1)
    hold on
    pre=nan(length(unique(sess)),length(sizes));post=pre;
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{1},:,1,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{1},:,1,2),2),1)); %post(1)=0;
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
    
    subplot(3,3,4)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('entire norm to pre')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    subplot(3,3,7)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    norm=max(post,[],2);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('entire norm to each')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))

    subplot(3,3,2)
    hold on
    pre=nan(length(unique(sess)),length(sizes));post=pre;
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{2},:,1,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{2},:,1,2),2),1)); %post(1)=0;
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
    
    subplot(3,3,5)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('first norm to pre')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    subplot(3,3,8)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    norm=max(post,[],2);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('first norm to each')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    subplot(3,3,3)
    hold on
    pre=nan(length(unique(sess)),length(sizes));post=pre;
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{3},:,1,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{3},:,1,2),2),1)); %post(1)=0;
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
    
    subplot(3,3,6)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('second norm to pre')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    subplot(3,3,9)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    norm=max(post,[],2);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('second norm to each')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    mtit(sprintf('Mean animal (n=%d ani, %d cells) size suppression curve (cc>%0.2f) sit',numAni,length(threshcells),ccvals(z)))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
    
    %%%animal average size curves running
    figure
    subplot(3,3,1)
    hold on
    pre=nan(length(unique(sess)),length(sizes));post=pre;
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{1},:,2,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{1},:,2,2),2),1)); %post(1)=0;
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
    
    subplot(3,3,4)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('entire norm to pre')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    subplot(3,3,7)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    norm=max(post,[],2);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('entire norm to each')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))

    subplot(3,3,2)
    hold on
    pre=nan(length(unique(sess)),length(sizes));post=pre;
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{2},:,2,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{2},:,2,2),2),1)); %post(1)=0;
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
    
    subplot(3,3,5)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('first norm to pre')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    subplot(3,3,8)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    norm=max(post,[],2);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('first norm to each')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    subplot(3,3,3)
    hold on
    pre=nan(length(unique(sess)),length(sizes));post=pre;
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{3},:,2,1),2),1)); %pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{3},:,2,2),2),1)); %post(1)=0;
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
    
    subplot(3,3,6)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('second norm to pre')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    subplot(3,3,9)
    hold on
    norm=max(pre,[],2);
    pren = bsxfun(@rdivide,pre,norm);
    norm=max(post,[],2);
    postn = bsxfun(@rdivide,post,norm);
    errorbar(1:length(radiusRange),nanmean(pren,1),nanstd(pren,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(postn,1),nanstd(postn,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('second norm to each')
    axis([0 length(radiusRange)+1 -0.05 1.05])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    
    mtit(sprintf('Mean animal (n=%d ani, %d cells) size suppression curve (cc>%0.2f) run',numAni,length(threshcells),ccvals(z)))
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
    
    
    %%%SF-dependent size curves by animal  
    figure
    subplot(3,2,1)
    pre=nan(numAni,length(sizes));post=pre;
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},1,:,:,1,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},1,:,:,1,2),4),2),1));
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
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},1,:,:,2,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},1,:,:,2,2),4),2),1));
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
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},2,:,:,1,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},2,:,:,1,2),4),2),1));
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
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},2,:,:,2,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},2,:,:,2,2),4),2),1));
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
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},:,:,:,1,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},:,:,:,1,2),4),3),2),1));
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
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},:,:,:,2,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},:,:,:,2,2),4),3),2),1));
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
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
    
    
    %%%normalized SF-dependent size curves by animal  
    figure
    subplot(3,2,1)
    pre=nan(numAni,length(sizes));post=pre;
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},1,:,:,1,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},1,:,:,1,2),4),2),1));
        pre(j,:) = pre(j,:)/max(pre(j,:));post(j,:) = post(j,:)/max(post(j,:));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
    ylabel('norm sit 0.04cpd dfof')
    axis([0 length(radiusRange)+1 -0.2 1])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(3,2,2)
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},1,:,:,2,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},1,:,:,2,2),4),2),1));
        pre(j,:) = pre(j,:)/max(pre(j,:));post(j,:) = post(j,:)/max(post(j,:));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
    ylabel('norm run 0.04cpd dfof')
    axis([0 length(radiusRange)+1 -0.2 1])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(3,2,3)
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},2,:,:,1,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},2,:,:,1,2),4),2),1));
        pre(j,:) = pre(j,:)/max(pre(j,:));post(j,:) = post(j,:)/max(post(j,:));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
    ylabel('norm sit 0.16cpd dfof')
    axis([0 length(radiusRange)+1 -0.2 1])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(3,2,4)
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},2,:,:,2,1),4),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},2,:,:,2,2),4),2),1));
        pre(j,:) = pre(j,:)/max(pre(j,:));post(j,:) = post(j,:)/max(post(j,:));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
%     xlabel('Stim Size (deg)')
    ylabel('norm run 0.16cpd dfof')
    axis([0 length(radiusRange)+1 -0.2 1])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(3,2,5)
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},:,:,:,1,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},:,:,:,1,2),4),3),2),1));
        pre(j,:) = pre(j,:)/max(pre(j,:));post(j,:) = post(j,:)/max(post(j,:));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('norm sit avg dfof')
    axis([0 length(radiusRange)+1 -0.2 1])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    subplot(3,2,6)
    for j = 1:length(unique(sess))
        pre(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},:,:,:,2,1),4),3),2),1));
        post(j,:) = squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuning(intersect(find(sess==j),goodcc{z}),spWindow{1},:,:,:,2,2),4),3),2),1));
        pre(j,:) = pre(j,:)/max(pre(j,:));post(j,:) = post(j,:)/max(post(j,:));
    end
    hold on
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('norm run avg dfof')
    axis([0 length(radiusRange)+1 -0.2 1])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    mtit('Normalized SF-dependent Size Curves')
    if exist('psfile','var')
        set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
        print('-dpsc',psfile,'-append');
    end
    
    
%%
    allparams = nan(numAni,2,2,2); %animal,Rd/Rs,sit/run,pre/post
    for win=1 %%%:length(spWindow)
        %%%fit size curves by animal
        %%%stationary
        sprintf('doing animal-wise stationary fits %s...',splabel{win})
        pre=nan(length(unique(sess)),length(sizes));post=pre;
        for j = 1:length(unique(sess))
            pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{win},:,1,1),2),1)); %pre(1)=0; %median of 0 = nan
            post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{win},:,1,2),2),1)); %post(1)=0;
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

        [preRD preRS presigmaD presigmaS prem preresult] = sizeCurveFit(radiusRange,pre);
        [postRD postRS postsigmaD postsigmaS postm postresult] = sizeCurveFit(radiusRange,post);

        %%%plot fits over data
        preR2=nan(1,length(preresult));postR2=preR2;
        for i = 1:length(preresult)
            preR2(i) = corr(pre(i,:)',preresult{i}(radiusRange));
            postR2(i) = corr(post(i,:)',postresult{i}(radiusRange));
        end

        figure;
        subplot(1,2,1)
        hold on
        for i=1:length(preresult)
            plot(radiusRange,pre(i,:),'o','color',mycol{i})
            plot(preresult{i},mycol{i})
            legend off
        end
        axis square
        axis([0 radiusRange(end) -0.05 0.5])
        xlabel('Stim Size (deg)')
        ylabel('pre dfof')
        title(sprintf('R2 = %0.3f',nanmean(preR2)))
        set(gca,'xtick',radiusRange,'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)

        subplot(1,2,2)
        hold on
        for i=1:length(postresult)
            plot(radiusRange,post(i,:),'o','color',mycol{i})
            plot(postresult{i},mycol{i})
            legend off
        end
        axis square
        axis([0 radiusRange(end) -0.05 0.5])
        xlabel('Stim Size (deg)')
        ylabel('post dfof')
        title(sprintf('R2 = %0.3f',nanmean(postR2)))
        set(gca,'xtick',radiusRange,'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)

        mtit(sprintf('stationary size curve fits %s',splabel{win}))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end

        %%%plot stationary fit parameters
        figure
        subplot(2,5,1)
        hold on
        plot([1 2],[preRD' postRD'],'k.-')
        errorbar([1 2],[nanmean(preRD) nanmean(postRD)],[nanstd(preRD)/sqrt(numAni) nanstd(postRD)/sqrt(numAni)])
        axis([0 3 0 3])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('RD')
        [h p] = ttest(preRD,postRD);
        title(sprintf('p=%0.3f',p))

        subplot(2,5,2)
        hold on
        plot([1 2],[preRS' postRS'],'k.-')
        errorbar([1 2],[nanmean(preRS) nanmean(postRS)],[nanstd(preRS)/sqrt(numAni) nanstd(postRS)/sqrt(numAni)])
        axis([0 3 0 80])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('RS')
        [h p] = ttest(preRS,postRS);
        title(sprintf('p=%0.3f',p))

        subplot(2,5,3)
        hold on
        plot([1 2],[presigmaD' postsigmaD'],'k.-')
        errorbar([1 2],[nanmean(presigmaD) nanmean(postsigmaD)],[nanstd(presigmaD)/sqrt(numAni) nanstd(postsigmaD)/sqrt(numAni)])
        axis([0 3 0 3])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('sigmaD')
        [h p] = ttest(presigmaD,postsigmaD);
        title(sprintf('p=%0.3f',p))

        subplot(2,5,4)
        hold on
        plot([1 2],[presigmaS' postsigmaS'],'k.-')
        errorbar([1 2],[nanmean(presigmaS) nanmean(postsigmaS)],[nanstd(presigmaS)/sqrt(numAni) nanstd(postsigmaS)/sqrt(numAni)])
        axis([0 3 0 10])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('sigmaS')
        [h p] = ttest(presigmaS,postsigmaS);
        title(sprintf('p=%0.3f',p))

        subplot(2,5,5)
        hold on
        plot([1 2],[prem' postm'],'k.-')
        errorbar([1 2],[nanmean(prem) nanmean(postm)],[nanstd(prem)/sqrt(numAni) nanstd(postm)/sqrt(numAni)])
        axis([0 3 0 6])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('m')
        [h p] = ttest(prem,postm);
        title(sprintf('p=%0.3f',p))

        subplot(2,5,6)
        hold on
        plot(preRD,postRD,'k.')
        errorbarxy(nanmean(preRD),nanmean(postRD),nanstd(preRD)/sqrt(numAni),nanstd(postRD)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 3 0 3])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('RD')

        subplot(2,5,7)
        hold on
        plot(preRS,postRS,'k.')
        errorbarxy(nanmean(preRS),nanmean(postRS),nanstd(preRS)/sqrt(numAni),nanstd(postRS)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 80 0 80])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('RS')

        subplot(2,5,8)
        hold on
        plot(presigmaD,postsigmaD,'k.')
        errorbarxy(nanmean(presigmaD),nanmean(postsigmaD),nanstd(presigmaD)/sqrt(numAni),nanstd(postsigmaD)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 3 0 3])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('sigmaD')

        subplot(2,5,9)
        hold on
        plot(presigmaS,postsigmaS,'k.')
        errorbarxy(nanmean(presigmaS),nanmean(postsigmaS),nanstd(presigmaS)/sqrt(numAni),nanstd(postsigmaS)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 10 0 10])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('sigmaS')

        subplot(2,5,10)
        hold on
        plot(prem,postm,'k.')
        errorbarxy(nanmean(prem),nanmean(postm),nanstd(prem)/sqrt(numAni),nanstd(postm)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 6 0 6])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('m')

        mtit(sprintf('stationary size curve fit params %s',splabel{win}))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end


        %%%constrain fit parameters to only fit Rd and Rs for stationary
        sprintf('doing animal-wise stationary fits with sigmas constrained %s...',splabel{win})
        sigmaD = (presigmaD + postsigmaD)/2;sigmaS = (presigmaS + postsigmaS)/2;m = (prem + postm)/2;
        [preRD preRS preresult] = sizeCurveFitRdRs(radiusRange,pre,sigmaD,sigmaS,m);
        [postRD postRS postresult] = sizeCurveFitRdRs(radiusRange,post,sigmaD,sigmaS,m);

        %%%plot fits over data
        preR2=nan(1,length(preresult));postR2=preR2;
        for i = 1:length(preresult)
            preR2(i) = corr(pre(i,:)',preresult{i}(radiusRange));
            postR2(i) = corr(post(i,:)',postresult{i}(radiusRange));
        end

        figure;
        subplot(1,2,1)
        hold on
        for i=1:length(preresult)
            plot(radiusRange,pre(i,:),'o','color',mycol{i})
            plot(preresult{i},mycol{i})
            legend off
        end
        axis square
        axis([0 radiusRange(end) -0.05 0.5])
        xlabel('Stim Size (deg)')
        ylabel('pre dfof')
        title(sprintf('R2 = %0.3f',nanmean(preR2)))
        set(gca,'xtick',radiusRange,'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)

        subplot(1,2,2)
        hold on
        for i=1:length(postresult)
            plot(radiusRange,post(i,:),'o','color',mycol{i})
            plot(postresult{i},mycol{i})
            legend off
        end
        axis square
        axis([0 radiusRange(end) -0.05 0.5])
        xlabel('Stim Size (deg)')
        ylabel('post dfof')
        title(sprintf('R2 = %0.3f',nanmean(postR2)))
        set(gca,'xtick',radiusRange,'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)

        mtit(sprintf('constrained stationary size curve fits %s',splabel{win}))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end

        %%%plot stationary fit parameters
        figure
        subplot(2,2,1)
        hold on
        plot([1 2],[preRD' postRD'],'k.-')
        errorbar([1 2],[nanmean(preRD) nanmean(postRD)],[nanstd(preRD)/sqrt(numAni) nanstd(postRD)/sqrt(numAni)])
        axis([0 3 0 3])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('RD')
        [h p] = ttest(preRD,postRD);
        title(sprintf('p=%0.3f',p))

        subplot(2,2,2)
        hold on
        plot([1 2],[preRS' postRS'],'k.-')
        errorbar([1 2],[nanmean(preRS) nanmean(postRS)],[nanstd(preRS)/sqrt(numAni) nanstd(postRS)/sqrt(numAni)])
        axis([0 3 0 80])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('RS')
        [h p] = ttest(preRS,postRS);
        title(sprintf('p=%0.3f',p))

        subplot(2,2,3)
        hold on
        plot(preRD,postRD,'k.')
        errorbarxy(nanmean(preRD),nanmean(postRD),nanstd(preRD)/sqrt(numAni),nanstd(postRD)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 3 0 3])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('RD')

        subplot(2,2,4)
        hold on
        plot(preRS,postRS,'k.')
        errorbarxy(nanmean(preRS),nanmean(postRS),nanstd(preRS)/sqrt(numAni),nanstd(postRS)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 80 0 80])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('RS')

        mtit(sprintf('constrained stationary size curve fits %s',splabel{win}))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end
        
        %%%save params into group variable for stationary
        allparams(:,1,1,1) = preRD;allparams(:,1,1,2) = postRD;
        allparams(:,2,1,1) = preRS;allparams(:,2,1,2) = postRS;

        %%%running
        sprintf('doing animal-wise running fits %s...',splabel{win})
        pre=nan(length(unique(sess)),length(sizes));post=pre;
        for j = 1:length(unique(sess))
            pre(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{win},:,2,1),2),1)); %pre(1)=0; %median of 0 = nan
            post(j,:) = squeeze(nanmean(nanmean(grpspsize(intersect(find(sess==j),goodcc{z}),spWindow{win},:,2,2),2),1)); %post(1)=0;
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

        [preRD preRS presigmaD presigmaS prem preresult] = sizeCurveFit(radiusRange,pre);
        [postRD postRS postsigmaD postsigmaS postm postresult] = sizeCurveFit(radiusRange,post);

        %%%plot fits over data
        preR2=nan(1,length(preresult));postR2=preR2;
        for i = 1:length(preresult)
            preR2(i) = corr(pre(i,:)',preresult{i}(radiusRange));
            postR2(i) = corr(post(i,:)',postresult{i}(radiusRange));
        end

        figure;
        subplot(1,2,1)
        hold on
        for i=1:length(preresult)
            plot(radiusRange,pre(i,:),'o','color',mycol{i})
            plot(preresult{i},mycol{i})
            legend off
        end
        axis square
        axis([0 radiusRange(end) -0.05 0.5])
        xlabel('Stim Size (deg)')
        ylabel('pre dfof')
        title(sprintf('R2 = %0.3f',nanmean(preR2)))
        set(gca,'xtick',radiusRange,'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)

        subplot(1,2,2)
        hold on
        for i=1:length(postresult)
            plot(radiusRange,post(i,:),'o','color',mycol{i})
            plot(postresult{i},mycol{i})
            legend off
        end
        axis square
        axis([0 radiusRange(end) -0.05 0.5])
        xlabel('Stim Size (deg)')
        ylabel('post dfof')
        title(sprintf('R2 = %0.3f',nanmean(postR2)))
        set(gca,'xtick',radiusRange,'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)

        mtit(sprintf('running size curve fits %s',splabel{win}))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end

        %%%plot fit params
        figure
        subplot(2,5,1)
        hold on
        plot([1 2],[preRD' postRD'],'k.-')
        errorbar([1 2],[nanmean(preRD) nanmean(postRD)],[nanstd(preRD)/sqrt(numAni) nanstd(postRD)/sqrt(numAni)])
        axis([0 3 0 3])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('RD')
        [h p] = ttest(preRD,postRD);
        title(sprintf('p=%0.3f',p))

        subplot(2,5,2)
        hold on
        plot([1 2],[preRS' postRS'],'k.-')
        errorbar([1 2],[nanmean(preRS) nanmean(postRS)],[nanstd(preRS)/sqrt(numAni) nanstd(postRS)/sqrt(numAni)])
        axis([0 3 0 80])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('RS')
        [h p] = ttest(preRS,postRS);
        title(sprintf('p=%0.3f',p))

        subplot(2,5,3)
        hold on
        plot([1 2],[presigmaD' postsigmaD'],'k.-')
        errorbar([1 2],[nanmean(presigmaD) nanmean(postsigmaD)],[nanstd(presigmaD)/sqrt(numAni) nanstd(postsigmaD)/sqrt(numAni)])
        axis([0 3 0 3])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('sigmaD')
        [h p] = ttest(presigmaD,postsigmaD);
        title(sprintf('p=%0.3f',p))

        subplot(2,5,4)
        hold on
        plot([1 2],[presigmaS' postsigmaS'],'k.-')
        errorbar([1 2],[nanmean(presigmaS) nanmean(postsigmaS)],[nanstd(presigmaS)/sqrt(numAni) nanstd(postsigmaS)/sqrt(numAni)])
        axis([0 3 0 10])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('sigmaS')
        [h p] = ttest(presigmaS,postsigmaS);
        title(sprintf('p=%0.3f',p))

        subplot(2,5,5)
        hold on
        plot([1 2],[prem' postm'],'k.-')
        errorbar([1 2],[nanmean(prem) nanmean(postm)],[nanstd(prem)/sqrt(numAni) nanstd(postm)/sqrt(numAni)])
        axis([0 3 0 6])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('m')
        [h p] = ttest(prem,postm);
        title(sprintf('p=%0.3f',p))

        subplot(2,5,6)
        hold on
        plot(preRD,postRD,'k.')
        errorbarxy(nanmean(preRD),nanmean(postRD),nanstd(preRD)/sqrt(numAni),nanstd(postRD)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 3 0 3])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('RD')

        subplot(2,5,7)
        hold on
        plot(preRS,postRS,'k.')
        errorbarxy(nanmean(preRS),nanmean(postRS),nanstd(preRS)/sqrt(numAni),nanstd(postRS)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 80 0 80])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('RS')

        subplot(2,5,8)
        hold on
        plot(presigmaD,postsigmaD,'k.')
        errorbarxy(nanmean(presigmaD),nanmean(postsigmaD),nanstd(presigmaD)/sqrt(numAni),nanstd(postsigmaD)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 3 0 3])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('sigmaD')

        subplot(2,5,9)
        hold on
        plot(presigmaS,postsigmaS,'k.')
        errorbarxy(nanmean(presigmaS),nanmean(postsigmaS),nanstd(presigmaS)/sqrt(numAni),nanstd(postsigmaS)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 10 0 10])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('sigmaS')

        subplot(2,5,10)
        hold on
        plot(prem,postm,'k.')
        errorbarxy(nanmean(prem),nanmean(postm),nanstd(prem)/sqrt(numAni),nanstd(postm)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 6 0 6])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('m')

        mtit(sprintf('running size curve fit params %s',splabel{win}))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end


        %%%constrain fit parameters to only fit Rd and Rs for running
        sprintf('doing animal-wise running fits with sigmas constrained %s...',splabel{win})
        sigmaD = (presigmaD + postsigmaD)/2;sigmaS = (presigmaS + postsigmaS)/2;m = (prem + postm)/2;
        [preRD preRS preresult] = sizeCurveFitRdRs(radiusRange,pre,sigmaD,sigmaS,m);
        [postRD postRS postresult] = sizeCurveFitRdRs(radiusRange,post,sigmaD,sigmaS,m);

        %%%plot fits over data
        preR2=nan(1,length(preresult));postR2=preR2;
        for i = 1:length(preresult)
            preR2(i) = corr(pre(i,:)',preresult{i}(radiusRange));
            postR2(i) = corr(post(i,:)',postresult{i}(radiusRange));
        end

        figure;
        subplot(1,2,1)
        hold on
        for i=1:length(preresult)
            plot(radiusRange,pre(i,:),'o','color',mycol{i})
            plot(preresult{i},mycol{i})
            legend off
        end
        axis square
        axis([0 radiusRange(end) -0.05 0.5])
        xlabel('Stim Size (deg)')
        ylabel('pre dfof')
        title(sprintf('R2 = %0.3f',nanmean(preR2)))
        set(gca,'xtick',radiusRange,'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)

        subplot(1,2,2)
        hold on
        for i=1:length(postresult)
            plot(radiusRange,post(i,:),'o','color',mycol{i})
            plot(postresult{i},mycol{i})
            legend off
        end
        axis square
        axis([0 radiusRange(end) -0.05 0.5])
        xlabel('Stim Size (deg)')
        ylabel('post dfof')
        title(sprintf('R2 = %0.3f',nanmean(postR2)))
        set(gca,'xtick',radiusRange,'xticklabel',sizes,'LooseInset',get(gca,'TightInset'),'fontsize',7)

        mtit(sprintf('constrained running size curve fits %s',splabel{win}))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end

        %%%plot running fit parameters
        figure
        subplot(2,2,1)
        hold on
        plot([1 2],[preRD' postRD'],'k.-')
        errorbar([1 2],[nanmean(preRD) nanmean(postRD)],[nanstd(preRD)/sqrt(numAni) nanstd(postRD)/sqrt(numAni)])
        axis([0 3 0 3])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('RD')
        [h p] = ttest(preRD,postRD);
        title(sprintf('p=%0.3f',p))

        subplot(2,2,2)
        hold on
        plot([1 2],[preRS' postRS'],'k.-')
        errorbar([1 2],[nanmean(preRS) nanmean(postRS)],[nanstd(preRS)/sqrt(numAni) nanstd(postRS)/sqrt(numAni)])
        axis([0 3 0 80])
        axis square
        set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
        ylabel('RS')
        [h p] = ttest(preRS,postRS);
        title(sprintf('p=%0.3f',p))

        subplot(2,2,3)
        hold on
        plot(preRD,postRD,'k.')
        errorbarxy(nanmean(preRD),nanmean(postRD),nanstd(preRD)/sqrt(numAni),nanstd(postRD)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 3 0 3])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('RD')

        subplot(2,2,4)
        hold on
        plot(preRS,postRS,'k.')
        errorbarxy(nanmean(preRS),nanmean(postRS),nanstd(preRS)/sqrt(numAni),nanstd(postRS)/sqrt(numAni))
        plot([0 100],[0 100],'m:')
        axis([0 80 0 80])
        axis square
        set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
        xlabel('pre');ylabel('post')
        title('RS')

        mtit(sprintf('constrained running size curve fits %s',splabel{win}))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end
        
        %%%save params into group variable for running
        allparams(:,1,2,1) = preRD;allparams(:,1,2,2) = postRD;
        allparams(:,2,2,1) = preRS;allparams(:,2,2,2) = postRS;
        
        figure
        subplot(1,2,1)
        hold on
        plot(allparams(:,1,1,1),allparams(:,1,2,1),'k.')
        plot(allparams(:,1,1,2),allparams(:,1,2,2),'r.')
        errorbarxy(nanmean(allparams(:,1,1,1)),nanmean(allparams(:,1,2,1)),...
            std(allparams(:,1,1,1))/sqrt(numAni),std(allparams(:,1,2,1))/sqrt(numAni),{'k','k','k'})
        errorbarxy(nanmean(allparams(:,1,1,2)),nanmean(allparams(:,1,2,2)),...
            std(allparams(:,1,1,2))/sqrt(numAni),std(allparams(:,1,2,2))/sqrt(numAni),{'r','r','r'})
        plot([0 100],[0 100],'m:')
        title('Rd');xlabel('sit Rd');ylabel('run Rd');
        axis([0 3 0 3]);axis square
        subplot(1,2,2)
        hold on
        plot(allparams(:,2,1,1),allparams(:,2,2,1),'k.')
        plot(allparams(:,2,1,2),allparams(:,2,2,2),'r.')
        errorbarxy(nanmean(allparams(:,2,1,1)),nanmean(allparams(:,2,2,1)),...
            std(allparams(:,2,1,1))/sqrt(numAni),std(allparams(:,2,2,1))/sqrt(numAni),{'k','k','k'})
        errorbarxy(nanmean(allparams(:,2,1,2)),nanmean(allparams(:,2,2,2)),...
            std(allparams(:,2,1,2))/sqrt(numAni),std(allparams(:,2,2,2))/sqrt(numAni),{'r','r','r'})
        plot([0 100],[0 100],'m:')
        title('Rs');xlabel('sit Rs');ylabel('run Rs');
        axis([0 80 0 80]);axis square
        mtit('sit vs. run params for pre/post')
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end





%%
% % %         %%%%%%%%%do size fits by cell
% % %         %%stationary
% % %         sprintf('doing cell-wise stationary fits %s...',splabel{win}')
% % %         pre = squeeze(nanmean(grpspsize(:,spWindow{win},:,1,1),2));
% % %         post = squeeze(nanmean(grpspsize(:,spWindow{win},:,1,2),2));
% % % 
% % %         %%%in case there are nans, throw out that ani's fit
% % %     %     [Ipre,J]=ind2sub(size(pre),find(isnan(pre)));
% % %     %     [Ipost,J]=ind2sub(size(post),find(isnan(post)));
% % %     %     I = unique([Ipre Ipost]);
% % %     %     fitani = 1:size(grpspsize,1);
% % %     %     for j = 1:length(I)
% % %     %         fitani = fitani(find(fitani~=I(j)));
% % %     %     end
% % %     %     pre=pre(fitani,:);post=post(fitani,:);sess=session(fitani);
% % % 
% % %         [preRD preRS presigmaD presigmaS prem preresult] = sizeCurveFit(radiusRange,pre);
% % %         [postRD postRS postsigmaD postsigmaS postm postresult] = sizeCurveFit(radiusRange,post);
% % % 
% % %         nofit = unique([find(isnan(preRD)) find(isnan(postRD))]); %%cells that wouldn't fit
% % %         fitani = 1:length(preRD);
% % %         for j = 1:length(nofit)
% % %             fitani = fitani(find(fitani~=nofit(j)));
% % %         end
% % %         preRD=preRD(fitani);preRS=preRS(fitani);presigmaD=presigmaD(fitani);presigmaS=presigmaS(fitani);prem=prem(fitani);preresult=preresult(fitani);
% % %         postRD=postRD(fitani);postRS=postRS(fitani);postsigmaD=postsigmaD(fitani);postsigmaS=postsigmaS(fitani);postm=postm(fitani);postresult=postresult(fitani);
% % %         sessfit=sess(fitani);pre=pre(fitani,:);post=post(fitani,:);
% % % 
% % %         %%%plot individual fits
% % %         preR2=nan(1,length(preresult));postR2=preR2;
% % %         for i = 1:length(preresult)
% % %             preR2(i) = corr(pre(i,:)',preresult{i}(radiusRange));
% % %             postR2(i) = corr(post(i,:)',postresult{i}(radiusRange));
% % %         end
% % % 
% % %     %     cnt=1;
% % %     %     for i = 1:ceil(length(sessfit)/15)
% % %     %         figure
% % %     %         for j = 1:15
% % %     %             if cnt<=length(sessfit)
% % %     %                 subplot(3,5,j)
% % %     %                 hold on
% % %     %                 plot(radiusRange,pre(cnt,:),'ko')
% % %     %                 plot(radiusRange,post(cnt,:),'ro')
% % %     %                 plot(preresult{cnt},'k')
% % %     %                 plot(postresult{cnt},'r')
% % %     %                 axis([0 radiusRange(end) min([pre(cnt,:) post(cnt,:)])-0.05 max([pre(cnt,:) post(cnt,:)])+0.05])
% % %     %                 axis square
% % %     %                 legend off
% % %     %                 xlabel('size (deg)')
% % %     %                 ylabel('dfof')
% % %     %                 title(sprintf('ani %d cell %d',sessfit(cnt),fitani(cnt)))
% % %     %                 set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',8,'xtick',radiusRange,'xticklabel',sizes)
% % %     %                 cnt=cnt+1;
% % %     %             else
% % %     %                 continue
% % %     %             end
% % %     %         end
% % %     %         mtit(sprintf('cell fits sit %d/%d preR2=%0.3f postR2=%0.3f %s',i,ceil(length(sessfit)/15),nanmean(preR2),nanmean(postR2),splabel{win}))
% % %     %         if exist('psfile','var')
% % %     %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %     %             print('-dpsc',psfile,'-append');
% % %     %         end
% % %     %     end
% % % 
% % %         %%%plot stationary fit parameters
% % %         figure
% % %         subplot(2,5,1)
% % %         hold on
% % %         plot([1 2],[preRD' postRD'],'k.:')
% % %         errorbar([1 2],[nanmean(preRD) nanmean(postRD)],[nanstd(preRD)/sqrt(numAni) nanstd(postRD)/sqrt(numAni)],'r')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('RD')
% % %         [h p] = ttest(preRD,postRD);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,5,2)
% % %         hold on
% % %         plot([1 2],[preRS' postRS'],'k.:')
% % %         errorbar([1 2],[nanmean(preRS) nanmean(postRS)],[nanstd(preRS)/sqrt(numAni) nanstd(postRS)/sqrt(numAni)],'r')
% % %         axis([0 3 0 80])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('RS')
% % %         [h p] = ttest(preRS,postRS);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,5,3)
% % %         hold on
% % %         plot([1 2],[presigmaD' postsigmaD'],'k.:')
% % %         errorbar([1 2],[nanmean(presigmaD) nanmean(postsigmaD)],[nanstd(presigmaD)/sqrt(numAni) nanstd(postsigmaD)/sqrt(numAni)],'r')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('sigmaD')
% % %         [h p] = ttest(presigmaD,postsigmaD);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,5,4)
% % %         hold on
% % %         plot([1 2],[presigmaS' postsigmaS'],'k.:')
% % %         errorbar([1 2],[nanmean(presigmaS) nanmean(postsigmaS)],[nanstd(presigmaS)/sqrt(numAni) nanstd(postsigmaS)/sqrt(numAni)],'r')
% % %         axis([0 3 0 10])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('sigmaS')
% % %         [h p] = ttest(presigmaS,postsigmaS);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,5,5)
% % %         hold on
% % %         plot([1 2],[prem' postm'],'k.:')
% % %         errorbar([1 2],[nanmean(prem) nanmean(postm)],[nanstd(prem)/sqrt(numAni) nanstd(postm)/sqrt(numAni)],'r')
% % %         axis([0 3 0 6])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('m')
% % %         [h p] = ttest(prem,postm);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,5,6)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(preRD(find(sessfit==j)));
% % %             anipost(j) = nanmean(postRD(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(preRD,postRD,'k.')
% % %         errorbarxy(nanmean(anipre),nanmean(anipost),nanstd(anipre)/sqrt(numAni),nanstd(anipost)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('RD p=%0.3f',p))
% % % 
% % %         subplot(2,5,7)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(preRS(find(sessfit==j)));
% % %             anipost(j) = nanmean(postRS(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(preRS,postRS,'k.')
% % %         errorbarxy(nanmean(preRS),nanmean(postRS),nanstd(preRS)/sqrt(numAni),nanstd(postRS)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 80 0 80])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('RS p=%0.3f',p))
% % % 
% % %         subplot(2,5,8)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(presigmaD(find(sessfit==j)));
% % %             anipost(j) = nanmean(postsigmaD(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(presigmaD,postsigmaD,'k.')
% % %         errorbarxy(nanmean(presigmaD),nanmean(postsigmaD),nanstd(presigmaD)/sqrt(numAni),nanstd(postsigmaD)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('sigmaD p=%0.3f',p))
% % % 
% % %         subplot(2,5,9)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(presigmaS(find(sessfit==j)));
% % %             anipost(j) = nanmean(postsigmaS(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(presigmaS,postsigmaS,'k.')
% % %         errorbarxy(nanmean(presigmaS),nanmean(postsigmaS),nanstd(presigmaS)/sqrt(numAni),nanstd(postsigmaS)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 10 0 10])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('sigmaS p=%0.3f',p))
% % % 
% % %         subplot(2,5,10)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(prem(find(sessfit==j)));
% % %             anipost(j) = nanmean(postm(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(prem,postm,'k.')
% % %         errorbarxy(nanmean(prem),nanmean(postm),nanstd(prem)/sqrt(numAni),nanstd(postm)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 6 0 6])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('m p=%0.3f',p))
% % % 
% % %         mtit(sprintf('stationary size curve fit params %s',splabel{win}))
% % %         if exist('psfile','var')
% % %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %             print('-dpsc',psfile,'-append');
% % %         end
% % % 
% % % 
% % %         %%%constrain fit parameters to only fit Rd and Rs for stationary
% % %         sprintf('doing cell-wise stationary fits with sigmas constrained %s...',splabel{win})
% % %         sigmaD = (presigmaD + postsigmaD)/2;sigmaS = (presigmaS + postsigmaS)/2;m = (prem + postm)/2;
% % %         [preRD preRS preresult] = sizeCurveFitRdRs(radiusRange,pre,sigmaD,sigmaS,m);
% % %         [postRD postRS postresult] = sizeCurveFitRdRs(radiusRange,post,sigmaD,sigmaS,m);
% % % 
% % %         %%%plot individual fits
% % %         preR2=nan(1,length(preresult));postR2=preR2;
% % %         for i = 1:length(preresult)
% % %             preR2(i) = corr(pre(i,:)',preresult{i}(radiusRange));
% % %             postR2(i) = corr(post(i,:)',postresult{i}(radiusRange));
% % %         end
% % % 
% % %     %     cnt=1;
% % %     %     for i = 1:ceil(length(sessfit)/15)
% % %     %         figure
% % %     %         for j = 1:15
% % %     %             if cnt<=length(sessfit)
% % %     %                 subplot(3,5,j)
% % %     %                 hold on
% % %     %                 plot(radiusRange,pre(cnt,:),'ko')
% % %     %                 plot(radiusRange,post(cnt,:),'ro')
% % %     %                 plot(preresult{cnt},'k')
% % %     %                 plot(postresult{cnt},'r')
% % %     %                 axis([0 radiusRange(end) min([pre(cnt,:) post(cnt,:)])-0.05 max([pre(cnt,:) post(cnt,:)])+0.05])
% % %     %                 axis square
% % %     %                 legend off
% % %     %                 xlabel('size (deg)')
% % %     %                 ylabel('dfof')
% % %     %                 title(sprintf('ani %d cell %d',sessfit(cnt),fitani(cnt)))
% % %     %                 set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',8,'xtick',radiusRange,'xticklabel',sizes)
% % %     %                 cnt=cnt+1;
% % %     %             else
% % %     %                 continue
% % %     %             end
% % %     %         end
% % %     %         mtit(sprintf('constrained cell fits sit %d/%d preR2=%0.3f postR2=%0.3f %s',i,ceil(length(sessfit)/15),nanmean(preR2),nanmean(postR2),splabel{win}))
% % %     %         if exist('psfile','var')
% % %     %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %     %             print('-dpsc',psfile,'-append');
% % %     %         end
% % %     %     end
% % % 
% % % 
% % %         figure
% % %         subplot(2,2,1)
% % %         hold on
% % %         plot([1 2],[preRD' postRD'],'k.:')
% % %         errorbar([1 2],[nanmean(preRD) nanmean(postRD)],[nanstd(preRD)/sqrt(numAni) nanstd(postRD)/sqrt(numAni)],'r')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('RD')
% % %         [h p] = ttest(preRD,postRD);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,2,2)
% % %         hold on
% % %         plot([1 2],[preRS' postRS'],'k.:')
% % %         errorbar([1 2],[nanmean(preRS) nanmean(postRS)],[nanstd(preRS)/sqrt(numAni) nanstd(postRS)/sqrt(numAni)],'r')
% % %         axis([0 3 0 80])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('RS')
% % %         [h p] = ttest(preRS,postRS);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,2,3)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(preRD(find(sessfit==j)));
% % %             anipost(j) = nanmean(postRD(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(preRD,postRD,'k.')
% % %         errorbarxy(nanmean(anipre),nanmean(anipost),nanstd(anipre)/sqrt(numAni),nanstd(anipost)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('RD p=%0.3f',p))
% % % 
% % %         subplot(2,2,4)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(preRS(find(sessfit==j)));
% % %             anipost(j) = nanmean(postRS(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(preRS,postRS,'k.')
% % %         errorbarxy(nanmean(preRS),nanmean(postRS),nanstd(preRS)/sqrt(numAni),nanstd(postRS)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 80 0 80])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('RS p=%0.3f',p))
% % % 
% % %         mtit(sprintf('constrained stationary size curve fit params %s',splabel{win}))
% % %         if exist('psfile','var')
% % %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %             print('-dpsc',psfile,'-append');
% % %         end
% % % 
% % % 
% % % 
% % %         %%%do size fits by cell
% % %         %%running
% % %         sprintf('doing cell-wise running fits %s...',splabel{win})
% % %         pre = squeeze(nanmean(grpspsize(:,spWindow{win},:,2,1),2));
% % %         post = squeeze(nanmean(grpspsize(:,spWindow{win},:,2,2),2));
% % % 
% % %         %%%in case there are nans, throw out that ani's fit
% % %     %     [Ipre,J]=ind2sub(size(pre),find(isnan(pre)));
% % %     %     [Ipost,J]=ind2sub(size(post),find(isnan(post)));
% % %     %     I = unique([Ipre Ipost]);
% % %     %     fitani = 1:size(grpspsize,1);
% % %     %     for j = 1:length(I)
% % %     %         fitani = fitani(find(fitani~=I(j)));
% % %     %     end
% % %     %     pre=pre(fitani,:);post=post(fitani,:);sess=session(fitani);
% % % 
% % %         [preRD preRS presigmaD presigmaS prem preresult] = sizeCurveFit(radiusRange,pre);
% % %         [postRD postRS postsigmaD postsigmaS postm postresult] = sizeCurveFit(radiusRange,post);
% % % 
% % %         nofit = unique([find(isnan(preRD)) find(isnan(postRD))]); %%cells that wouldn't fit
% % %         fitani = 1:length(preRD);
% % %         for j = 1:length(nofit)
% % %             fitani = fitani(find(fitani~=nofit(j)));
% % %         end
% % %         preRD=preRD(fitani);preRS=preRS(fitani);presigmaD=presigmaD(fitani);presigmaS=presigmaS(fitani);prem=prem(fitani);preresult=preresult(fitani);
% % %         postRD=postRD(fitani);postRS=postRS(fitani);postsigmaD=postsigmaD(fitani);postsigmaS=postsigmaS(fitani);postm=postm(fitani);postresult=postresult(fitani);
% % %         sessfit=sess(fitani);pre=pre(fitani,:);post=post(fitani,:);
% % % 
% % %         %%%plot individual fits
% % %         preR2=nan(1,length(preresult));postR2=preR2;
% % %         for i = 1:length(preresult)
% % %             preR2(i) = corr(pre(i,:)',preresult{i}(radiusRange));
% % %             postR2(i) = corr(post(i,:)',postresult{i}(radiusRange));
% % %         end
% % % 
% % %     %     cnt=1;
% % %     %     for i = 1:ceil(length(sessfit)/15)
% % %     %         figure
% % %     %         for j = 1:15
% % %     %             if cnt<=length(sessfit)
% % %     %                 subplot(3,5,j)
% % %     %                 hold on
% % %     %                 plot(radiusRange,pre(cnt,:),'ko')
% % %     %                 plot(radiusRange,post(cnt,:),'ro')
% % %     %                 plot(preresult{cnt},'k')
% % %     %                 plot(postresult{cnt},'r')
% % %     %                 axis([0 radiusRange(end) min([pre(cnt,:) post(cnt,:)])-0.05 max([pre(cnt,:) post(cnt,:)])+0.05])
% % %     %                 axis square
% % %     %                 legend off
% % %     %                 xlabel('size (deg)')
% % %     %                 ylabel('dfof')
% % %     %                 title(sprintf('ani %d cell %d',sessfit(cnt),fitani(cnt)))
% % %     %                 set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',8,'xtick',radiusRange,'xticklabel',sizes)
% % %     %                 cnt=cnt+1;
% % %     %             else
% % %     %                 continue
% % %     %             end
% % %     %         end
% % %     %         mtit(sprintf('cell fits run %d/%d preR2=%0.3f postR2=%0.3f %s',i,ceil(length(sessfit)/15),nanmean(preR2),nanmean(postR2),splabel{win}))
% % %     %         if exist('psfile','var')
% % %     %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %     %             print('-dpsc',psfile,'-append');
% % %     %         end
% % %     %     end
% % % 
% % %         %%%plot running fit parameters
% % %         figure
% % %         subplot(2,5,1)
% % %         hold on
% % %         plot([1 2],[preRD' postRD'],'k.:')
% % %         errorbar([1 2],[nanmean(preRD) nanmean(postRD)],[nanstd(preRD)/sqrt(numAni) nanstd(postRD)/sqrt(numAni)],'r')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('RD')
% % %         [h p] = ttest(preRD,postRD);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,5,2)
% % %         hold on
% % %         plot([1 2],[preRS' postRS'],'k.:')
% % %         errorbar([1 2],[nanmean(preRS) nanmean(postRS)],[nanstd(preRS)/sqrt(numAni) nanstd(postRS)/sqrt(numAni)],'r')
% % %         axis([0 3 0 80])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('RS')
% % %         [h p] = ttest(preRS,postRS);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,5,3)
% % %         hold on
% % %         plot([1 2],[presigmaD' postsigmaD'],'k.:')
% % %         errorbar([1 2],[nanmean(presigmaD) nanmean(postsigmaD)],[nanstd(presigmaD)/sqrt(numAni) nanstd(postsigmaD)/sqrt(numAni)],'r')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('sigmaD')
% % %         [h p] = ttest(presigmaD,postsigmaD);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,5,4)
% % %         hold on
% % %         plot([1 2],[presigmaS' postsigmaS'],'k.:')
% % %         errorbar([1 2],[nanmean(presigmaS) nanmean(postsigmaS)],[nanstd(presigmaS)/sqrt(numAni) nanstd(postsigmaS)/sqrt(numAni)],'r')
% % %         axis([0 3 0 10])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('sigmaS')
% % %         [h p] = ttest(presigmaS,postsigmaS);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,5,5)
% % %         hold on
% % %         plot([1 2],[prem' postm'],'k.:')
% % %         errorbar([1 2],[nanmean(prem) nanmean(postm)],[nanstd(prem)/sqrt(numAni) nanstd(postm)/sqrt(numAni)],'r')
% % %         axis([0 3 0 6])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('m')
% % %         [h p] = ttest(prem,postm);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,5,6)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(preRD(find(sessfit==j)));
% % %             anipost(j) = nanmean(postRD(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(preRD,postRD,'k.')
% % %         errorbarxy(nanmean(anipre),nanmean(anipost),nanstd(anipre)/sqrt(numAni),nanstd(anipost)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('RD p=%0.3f',p))
% % % 
% % %         subplot(2,5,7)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(preRS(find(sessfit==j)));
% % %             anipost(j) = nanmean(postRS(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(preRS,postRS,'k.')
% % %         errorbarxy(nanmean(preRS),nanmean(postRS),nanstd(preRS)/sqrt(numAni),nanstd(postRS)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 80 0 80])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('RS p=%0.3f',p))
% % % 
% % %         subplot(2,5,8)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(presigmaD(find(sessfit==j)));
% % %             anipost(j) = nanmean(postsigmaD(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(presigmaD,postsigmaD,'k.')
% % %         errorbarxy(nanmean(presigmaD),nanmean(postsigmaD),nanstd(presigmaD)/sqrt(numAni),nanstd(postsigmaD)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('sigmaD p=%0.3f',p))
% % % 
% % %         subplot(2,5,9)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(presigmaS(find(sessfit==j)));
% % %             anipost(j) = nanmean(postsigmaS(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(presigmaS,postsigmaS,'k.')
% % %         errorbarxy(nanmean(presigmaS),nanmean(postsigmaS),nanstd(presigmaS)/sqrt(numAni),nanstd(postsigmaS)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 10 0 10])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('sigmaS p=%0.3f',p))
% % % 
% % %         subplot(2,5,10)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(prem(find(sessfit==j)));
% % %             anipost(j) = nanmean(postm(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(prem,postm,'k.')
% % %         errorbarxy(nanmean(prem),nanmean(postm),nanstd(prem)/sqrt(numAni),nanstd(postm)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 6 0 6])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('m p=%0.3f',p))
% % % 
% % %         mtit(sprintf('running size curve fit params %s',splabel{win}))
% % %         if exist('psfile','var')
% % %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %             print('-dpsc',psfile,'-append');
% % %         end
% % % 
% % % 
% % %         %%%constrain fit parameters to only fit Rd and Rs for running
% % %         sprintf('doing cell-wise running fits with sigmas constrained %s...',splabel{win})
% % %         sigmaD = (presigmaD + postsigmaD)/2;sigmaS = (presigmaS + postsigmaS)/2;m = (prem + postm)/2;
% % %         [preRD preRS preresult] = sizeCurveFitRdRs(radiusRange,pre,sigmaD,sigmaS,m);
% % %         [postRD postRS postresult] = sizeCurveFitRdRs(radiusRange,post,sigmaD,sigmaS,m);
% % % 
% % %         %%%plot individual fits
% % %         preR2=nan(1,length(preresult));postR2=preR2;
% % %         for i = 1:length(preresult)
% % %             preR2(i) = corr(pre(i,:)',preresult{i}(radiusRange));
% % %             postR2(i) = corr(post(i,:)',postresult{i}(radiusRange));
% % %         end
% % % 
% % %     %     cnt=1;
% % %     %     for i = 1:ceil(length(sessfit)/15)
% % %     %         figure
% % %     %         for j = 1:15
% % %     %             if cnt<=length(sessfit)
% % %     %                 subplot(3,5,j)
% % %     %                 hold on
% % %     %                 plot(radiusRange,pre(cnt,:),'ko')
% % %     %                 plot(radiusRange,post(cnt,:),'ro')
% % %     %                 plot(preresult{cnt},'k')
% % %     %                 plot(postresult{cnt},'r')
% % %     %                 axis([0 radiusRange(end) min([pre(cnt,:) post(cnt,:)])-0.05 max([pre(cnt,:) post(cnt,:)])+0.05])
% % %     %                 axis square
% % %     %                 legend off
% % %     %                 xlabel('size (deg)')
% % %     %                 ylabel('dfof')
% % %     %                 title(sprintf('ani %d cell %d',sessfit(cnt),fitani(cnt)))
% % %     %                 set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',8,'xtick',radiusRange,'xticklabel',sizes)
% % %     %                 cnt=cnt+1;
% % %     %             else
% % %     %                 continue
% % %     %             end
% % %     %         end
% % %     %         mtit(sprintf('constrained cell fits run %d/%d preR2=%0.3f postR2=%0.3f %s',i,ceil(length(sessfit)/15),nanmean(preR2),nanmean(postR2),splabel{win}))
% % %     %         if exist('psfile','var')
% % %     %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %     %             print('-dpsc',psfile,'-append');
% % %     %         end
% % %     %     end
% % % 
% % % 
% % %         figure
% % %         subplot(2,2,1)
% % %         hold on
% % %         plot([1 2],[preRD' postRD'],'k.:')
% % %         errorbar([1 2],[nanmean(preRD) nanmean(postRD)],[nanstd(preRD)/sqrt(numAni) nanstd(postRD)/sqrt(numAni)],'r')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('RD')
% % %         [h p] = ttest(preRD,postRD);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,2,2)
% % %         hold on
% % %         plot([1 2],[preRS' postRS'],'k.:')
% % %         errorbar([1 2],[nanmean(preRS) nanmean(postRS)],[nanstd(preRS)/sqrt(numAni) nanstd(postRS)/sqrt(numAni)],'r')
% % %         axis([0 3 0 80])
% % %         axis square
% % %         set(gca,'xtick',1:2,'xticklabel',{'pre','post'},'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         ylabel('RS')
% % %         [h p] = ttest(preRS,postRS);
% % %         title(sprintf('p=%0.3f',p))
% % % 
% % %         subplot(2,2,3)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(preRD(find(sessfit==j)));
% % %             anipost(j) = nanmean(postRD(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(preRD,postRD,'k.')
% % %         errorbarxy(nanmean(anipre),nanmean(anipost),nanstd(anipre)/sqrt(numAni),nanstd(anipost)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 3 0 3])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('RD p=%0.3f',p))
% % % 
% % %         subplot(2,2,4)
% % %         for j = 1:length(unique(sessfit))
% % %             anipre(j) = nanmean(preRS(find(sessfit==j)));
% % %             anipost(j) = nanmean(postRS(find(sessfit==j)));
% % %         end
% % %         hold on
% % %         plot(preRS,postRS,'k.')
% % %         errorbarxy(nanmean(preRS),nanmean(postRS),nanstd(preRS)/sqrt(numAni),nanstd(postRS)/sqrt(numAni))
% % %         plot([0 100],[0 100],'m:')
% % %         axis([0 80 0 80])
% % %         axis square
% % %         set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',10)
% % %         xlabel('pre');ylabel('post')
% % %         [h p] = ttest(anipre,anipost);
% % %         title(sprintf('RS p=%0.3f',p))
% % % 
% % %         mtit(sprintf('constrained running size curve fit params %s',splabel{win}))
% % %         if exist('psfile','var')
% % %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %             print('-dpsc',psfile,'-append');
% % %         end


%%
        %%%%%%calculate two suppression indeces, one w/pref stim one avg across
        %%%%%%all stim where SI = (peak - 50deg)/(peak + 50deg)

        %%%avg across stim parameters
        SIcalc = squeeze(nanmean(nanmean(nanmean(grpsptuning(:,spWindow{win},:,:,:,:,:),2),3),4));
    %     indeces = (max(SIcalc(:,:,1,1),[],2)>minresp & max(SIcalc(:,:,1,2),[],2)>minresp);
    %     SIcalc = SIcalc(indeces,:,:,:);
    %     sess = sess(indeces);
        SIavg = nan(size(SIcalc,1),2,2);
        for i = 1:2
            for j = 1:2
                A = SIcalc(:,:,i,j);
                B = min(SIcalc(:,:,i,j),[],2);
                SIcalc(:,:,i,j) = bsxfun(@minus,A,B);
                [SIpks SIinds] = max(squeeze(SIcalc(:,:,i,j)),[],2);
                SI50 = squeeze(SIcalc(:,end,i,j));
                SIavg(:,i,j) = (SIpks - SI50)./(SIpks + SI50);
            end
        end

        figure
        subplot(1,2,1)
        hold on
        for j = 1:length(unique(sess))
            preSI(j) = nanmean(SIavg(find(sess==j),1,1));
            postSI(j) = nanmean(SIavg(find(sess==j),1,2));
        end
        plot(SIavg(:,1,1),SIavg(:,1,2),'color',[0.6 0.6 0.6],'marker','.','linestyle','none')
        plot(preSI,postSI,'bo')
        errorbarxy(nanmean(preSI),nanmean(postSI),nanstd(preSI)/sqrt(numAni),nanstd(postSI)/sqrt(numAni))
        plot([0 1],[0 1],'k--')
        axis square
        axis([0 1 0 1])
        xlabel('pre SI')
        ylabel('post SI')
        [h p] = ttest(preSI,postSI);
        title(sprintf('sit SI p=%0.3f',p))

        subplot(1,2,2)
        hold on
        for j = 1:length(unique(sess))
            preSI(j) = nanmean(SIavg(find(sess==j),2,1));
            postSI(j) = nanmean(SIavg(find(sess==j),2,2));
        end
        plot(SIavg(:,1,1),SIavg(:,1,2),'color',[0.6 0.6 0.6],'marker','.','linestyle','none')
        plot(preSI,postSI,'bo')
        errorbarxy(nanmean(preSI),nanmean(postSI),nanstd(preSI)/sqrt(numAni),nanstd(postSI)/sqrt(numAni))
        plot([0 1],[0 1],'k--')
        axis square
        axis([0 1 0 1])
        xlabel('pre SI')
        ylabel('post SI')
        [h p] = ttest(preSI,postSI);
        title(sprintf('run SI p=%0.3f',p))

        mtit(sprintf('suppresion index avg across stim %s',splabel{win}))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end


        %%%SI for preferred SF and ori
        SIcalc = squeeze(nanmean(grpspsize(:,spWindow{win},:,:,:),2));
    %     indeces = (max(SIcalc(:,:,1,1),[],2)>minresp & max(SIcalc(:,:,1,2),[],2)>minresp);
    %     SIcalc = SIcalc(indeces,:,:,:);
    %     sess = sess(indeces);
        SIavg = nan(size(SIcalc,1),2,2);
        for i = 1:2
            for j = 1:2
                A = SIcalc(:,:,i,j);
                B = min(SIcalc(:,:,i,j),[],2);
                SIcalc(:,:,i,j) = bsxfun(@minus,A,B);
                [SIpks SIinds] = max(squeeze(SIcalc(:,:,i,j)),[],2);
                SI50 = squeeze(SIcalc(:,end,i,j));
                SIavg(:,i,j) = (SIpks - SI50)./(SIpks + SI50);
            end
        end

        figure
        subplot(1,2,1)
        hold on
        for j = 1:length(unique(sess))
            preSI(j) = nanmean(SIavg(find(sess==j),1,1));
            postSI(j) = nanmean(SIavg(find(sess==j),1,2));
        end
        plot(SIavg(:,1,1),SIavg(:,1,2),'color',[0.6 0.6 0.6],'marker','.','linestyle','none')
        plot(preSI,postSI,'bo')
        errorbarxy(nanmean(preSI),nanmean(postSI),nanstd(preSI)/sqrt(numAni),nanstd(postSI)/sqrt(numAni))
        plot([0 1],[0 1],'k--')
        axis square
        axis([0 1 0 1])
        xlabel('pre SI')
        ylabel('post SI')
        [h p] = ttest(preSI,postSI);
        title(sprintf('sit SI p=%0.3f',p))

        subplot(1,2,2)
        hold on
        for j = 1:length(unique(sess))
            preSI(j) = nanmean(SIavg(find(sess==j),2,1));
            postSI(j) = nanmean(SIavg(find(sess==j),2,2));
        end
        plot(SIavg(:,1,1),SIavg(:,1,2),'color',[0.6 0.6 0.6],'marker','.','linestyle','none')
        plot(preSI,postSI,'bo')
        errorbarxy(nanmean(preSI),nanmean(postSI),nanstd(preSI)/sqrt(numAni),nanstd(postSI)/sqrt(numAni))
        plot([0 1],[0 1],'k--')
        axis square
        axis([0 1 0 1])
        xlabel('pre SI')
        ylabel('post SI')
        [h p] = ttest(preSI,postSI);
        title(sprintf('run SI p=%0.3f',p))

        mtit(sprintf('suppresion index pref stim %s',splabel{win}))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end
        

%%
        %%%pull out max response
        clear valpre valpost valpreani valpostani
        resp = squeeze(nanmean(grpspsize(:,spWindow{win},:,1,1),2));
        [valpre idxpre] = max(resp,[],2);
        resp = squeeze(nanmean(grpspsize(:,spWindow{win},:,1,2),2));
        [valpost idxpost] = max(resp,[],2);

        %%%threshold responses
    %     indeces = (valpre>minresp & valpost>minresp);
    %     valpre = valpre(indeces);valpost = valpost(indeces);sess = sess(indeces);
    %     idxpre = idxpre(indeces);idxpost = idxpost(indeces);

        %%%avg by animal
        for j = 1:length(unique(sess))
            valpreani(j,:) = nanmean(valpre(find(sess==j)));
            valpostani(j,:) = nanmean(valpost(find(sess==j)));
            idxpreani(j,:) = nanmean(idxpre(find(sess==j)));
            idxpostani(j,:) = nanmean(idxpost(find(sess==j)));
        end
        %%%plot max response pre vs. post
        [h p] = ttest(valpreani,valpostani);
        figure;
        subplot(1,3,1)
        hold on
        plot(valpre,valpost,'color',[0.6 0.6 0.6],'marker','.','linestyle','none')
        plot(valpreani,valpostani,'bo')
        errorbarxy(nanmean(valpreani),nanmean(valpostani),nanstd(valpreani)/sqrt(numAni),nanstd(valpostani)/sqrt(numAni))
        plot([0 3],[0 3],'k--')
        axis square
        axis([0 3 0 3])
        xlabel('pre dfof')
        ylabel('post dfof')
        title(sprintf('Max response p=%0.3f',p))
        %%%same zoomed in
        subplot(1,3,2)
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
        title('max resp zoomed in')

        %%%plot preferred size pre vs. post
        [h p] = ttest(idxpreani,idxpostani);
        subplot(1,3,3)
        hold on
        plot(idxpre+rand(size(idxpre))/10,idxpost+rand(size(idxpre))/10,'color',[0.6 0.6 0.6],'marker','o','linestyle','none')
        plot(idxpreani,idxpostani,'bo')
        errorbarxy(nanmean(idxpreani),nanmean(idxpostani),nanstd(idxpreani)/sqrt(numAni),nanstd(idxpostani)/sqrt(numAni))
        plot([0 6],[0 6],'k--')
        axis square
        axis([0 6 0 6])
        xlabel('pre pref size (deg)')
        ylabel('post pref size (deg)')
        legend('cells','ani','aniavg','location','northwest')
        set(gca,'xtick',0:6,'xticklabel',sizes,'ytick',0:6,'yticklabel',sizes)
        title(sprintf('Pref size pre vs. post p=%0.3f',p))
        
        mtit(sprintf('max resp/pref size %s',splabel{win}))
        if exist('psfile','var')
            set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
            print('-dpsc',psfile,'-append');
        end
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







   % % %     %%%plot suppression index
    % % %     figure
    % % %     subplot(1,2,1)
    % % %     hold on
    % % %     pre=nan(length(unique(session)),1,1);post=pre;
    % % %     for j = 1:length(unique(session))
    % % %         pre(j,:) = nanmean(grpSI(intersect(find(session==j),goodcc{z}),1,1),1);
    % % %         post(j,:) = nanmean(grpSI(intersect(find(session==j),goodcc{z}),1,2),1);
    % % %     end
    % % %     plot([0 1],[0 1],'k--')
    % % %     plot(pre,post,'k.','Markersize',20)
    % % %     errorbarxy(nanmean(pre,1),nanmean(post,1),nanstd(pre,1)/sqrt(numAni),nanstd(post,1)/sqrt(numAni))
    % % %     axis([0 1 0 1])
    % % %     xlabel('sit pre SI')
    % % %     ylabel('sit post SI')
    % % %     axis square
    % % %     subplot(1,2,2)
    % % %     hold on
    % % %     pre=nan(length(unique(session)),1,1);post=pre;
    % % %     for j = 1:length(unique(session))
    % % %         pre(j,:) = nanmean(grpSI(intersect(find(session==j),goodcc{z}),2,1),1);
    % % %         post(j,:) = nanmean(grpSI(intersect(find(session==j),goodcc{z}),2,2),1);
    % % %     end
    % % %     plot([0 1],[0 1],'k--')
    % % %     plot(pre,post,'k.','Markersize',20)
    % % %     errorbarxy(nanmean(pre,1),nanmean(post,1),nanstd(pre,1)/sqrt(numAni),nanstd(post,1)/sqrt(numAni))
    % % %     axis([0 1 0 1])
    % % %     xlabel('run pre SI')
    % % %     ylabel('run post SI')
    % % %     axis square
    % % %     mtit('Animal Suppression Index')
    % % %     if exist('psfile','var')
    % % %         set(gcf, 'PaperPositionMode', 'auto');
    % % %         print('-dpsc',psfile,'-append');
    % % %     end




        %%%%%pre vs. post scatter plots

% % %         %%%plot mean response and resp to largest size pre vs post
% % %         preresp = squeeze(nanmean(grpspsize(:,spWindow{win},:,1,1),2));
% % %         postresp = squeeze(nanmean(grpspsize(:,spWindow{win},:,1,2),2));
% % %         indeces = (max(preresp,[],2)>minresp & max(postresp,[],2)>minresp);
% % %         preresp = preresp(indeces,2:end);postresp = postresp(indeces,2:end);sess = sess(indeces);
% % %         for j = 1:length(unique(sess))
% % %             prerespani(j,:) = nanmean(nanmean(preresp(find(sess==j),:),2));
% % %             postrespani(j,:) = nanmean(nanmean(postresp(find(sess==j),:),2));
% % %         end

        
% % %         %%%mean response
% % %         figure
% % %         preresp = squeeze(nanmean(grpspsize(:,spWindow{win},:,1,1),2));
% % %         postresp = squeeze(nanmean(grpspsize(:,spWindow{win},:,1,2),2));
% % %         for j = 1:length(unique(sess))
% % %             prerespani(j,:) = nanmean(nanmean(preresp(find(sess==j),:),2));
% % %             postrespani(j,:) = nanmean(nanmean(postresp(find(sess==j),:),2));
% % %         end
% % %         subplot(1,2,1)
% % %         hold on
% % %         plot(nanmean(preresp,2),nanmean(postresp,2),'color',[0.6 0.6 0.6],'marker','.','linestyle','none')
% % %         plot(prerespani,postrespani,'bo')
% % %         errorbarxy(nanmean(prerespani),nanmean(postrespani),nanstd(prerespani)/sqrt(numAni),nanstd(postrespani)/sqrt(numAni))
% % %         plot([0 1],[0 1],'k--')
% % %         axis square
% % %         axis([0 1 0 1])
% % %         xlabel('mean pre dfof')
% % %         ylabel('mean post dfof')
% % %         [h p] = ttest(prerespani,postrespani);
% % %         title(sprintf('mean resp across sizes p=%0.3f',p))
% % % 
% % %         %%%response to largest size
% % %         preresp = preresp(:,end);postresp = postresp(:,end);
% % %         for j = 1:length(unique(sess))
% % %             prerespani(j,:) = nanmean(preresp(find(sess==j)));
% % %             postrespani(j,:) = nanmean(postresp(find(sess==j)));
% % %         end
% % %         subplot(1,2,2)
% % %         hold on
% % %         plot(preresp,postresp,'color',[0.6 0.6 0.6],'marker','.','linestyle','none')
% % %         plot(prerespani,postrespani,'bo')
% % %         errorbarxy(nanmean(prerespani),nanmean(postrespani),nanstd(prerespani)/sqrt(numAni),nanstd(postrespani)/sqrt(numAni))
% % %         plot([0 1],[0 1],'k--')
% % %         axis square
% % %         axis([0 1 0 1])
% % %         xlabel('50deg pre dfof')
% % %         ylabel('50deg post dfof')
% % %         [h p] = ttest(prerespani,postrespani);
% % %         title(sprintf('resp largest size p=%0.3f',p))
% % %         
% % %         mtit(sprintf('mean/largest size response %s',splabel{win}))
% % %         if exist('psfile','var')
% % %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %             print('-dpsc',psfile,'-append');
% % %         end



% % %         %%%%%%pull out response to best size
% % %         clear valpre valpost valpreani valpostani
% % %         resp = squeeze(nanmean(grpspsize(:,spWindow{win},:,1,1),2));
% % %         [valpre idxpre] = max(resp,[],2);
% % %         for i = 1:length(idxpre)
% % %             valpost(i) = squeeze(nanmean(grpspsize(i,spWindow{win},idxpre(i),1,2),2));
% % %         end
% % %         valpost = valpost';
% % %     %     indeces = (valpre>minresp & valpost>minresp);
% % %     %     valpre = valpre(indeces);valpost = valpost(indeces);sess = sess(indeces);
% % % 
% % %         %%%avg by animal
% % %         for j = 1:length(unique(sess))
% % %             valpreani(j,:) = nanmean(valpre(find(sess==j)));
% % %             valpostani(j,:) = nanmean(valpost(find(sess==j)));
% % %         end
% % % 
% % %         %%%plot response to best pre size pre vs. post
% % %         figure;
% % %         subplot(1,2,1)
% % %         hold on
% % %         plot(valpre,valpost,'color',[0.6 0.6 0.6],'marker','.','linestyle','none')
% % %         plot(valpreani,valpostani,'bo')
% % %         errorbarxy(nanmean(valpreani),nanmean(valpostani),nanstd(valpreani)/sqrt(numAni),nanstd(valpostani)/sqrt(numAni))
% % %         plot([0 1],[0 1],'k--')
% % %         axis square
% % %         axis([0 1 0 1])
% % %         xlabel('pre dfof')
% % %         ylabel('post dfof')
% % %         legend('cells','ani','aniavg','location','northwest')
% % %         [h p] = ttest(valpreani,valpostani);
% % %         title(sprintf('resp at pref pre size p=%0.3f',p))
% % % 
% % %         %%%plot response to best post size pre vs. post
% % %         clear valpre valpost valpreani valpostani
% % %         resp = squeeze(nanmean(grpspsize(:,spWindow{win},:,1,2),2));
% % %         [valpost idxpost] = max(resp,[],2);
% % %         for i = 1:length(idxpost)
% % %             valpre(i) = squeeze(nanmean(grpspsize(i,spWindow{win},idxpost(i),1,1),2));
% % %         end
% % %     %     indeces = (valpre>minresp & valpost>minresp);
% % %     %     valpre = valpre(indeces);valpost = valpost(indeces);sess = sess(indeces);
% % % 
% % %         %%%avg by animal
% % %         for j = 1:length(unique(sess))
% % %             valpreani(j,:) = nanmean(valpre(find(sess==j)));
% % %             valpostani(j,:) = nanmean(valpost(find(sess==j)));
% % %         end
% % % 
% % %         subplot(1,2,2)
% % %         hold on
% % %         plot(valpre,valpost,'color',[0.6 0.6 0.6],'marker','.','linestyle','none')
% % %         plot(valpreani,valpostani,'bo')
% % %         errorbarxy(nanmean(valpreani),nanmean(valpostani),nanstd(valpreani)/sqrt(numAni),nanstd(valpostani)/sqrt(numAni))
% % %         plot([0 1],[0 1],'k--')
% % %         axis square
% % %         axis([0 1 0 1])
% % %         xlabel('pre dfof')
% % %         ylabel('post dfof')
% % %         legend('cells','ani','aniavg','location','northwest')
% % %         [h p] = ttest(valpreani,valpostani);
% % %         title(sprintf('resp at pref post size p=%0.3f',p))
% % % 
% % %         mtit('Response to preferred size')
% % %         if exist('psfile','var')
% % %             set(gcf, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1], 'PaperOrientation', 'landscape');
% % %             print('-dpsc',psfile,'-append');
% % %         end