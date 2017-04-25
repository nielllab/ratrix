%%%use this code to analyze the full contrast, 24 rep size select data

close all
clear all

%%choose dataset
% batchPhil2pSizeSelect
% batchPhil2pSizeSelect22min
batchPhil2pSizeSelect22minS2P

path = '\\langevin\backup\twophoton\Phil\Compiled2p\'
savepath = '\\langevin\backup\twophoton\Phil\Compiled2p\S2P analysis'

psfile = 'c:\tempPhil2pSize.ps';
if exist(psfile,'file')==2;delete(psfile);end

cd(path);

group = input('which group? 1=saline naive, 2=saline trained, 3=DOI naive, 4=DOI trained: ')
redoani = input('reanalyze individual animal data? 0=no, 1=yes: ')
redogrp = input('reanalyze group data? 0=no, 1=yes: ')

if group==1
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'SalineNaive2pSizeSelectS2P'
elseif group==2
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'SalineTrained2pSizeSelectS2P'
elseif group==3
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOINaive2pSizeSelectS2P'
elseif group==4
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOITrained2pSizeSelectS2P'
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

if redogrp
    grpdfsize = nan(10000,15,length(sizes),2,2);
    grprf=nan(10000,2);
    session = nan(10000,1);%%%make an array for animal #/session
    grpcells = nan(10000,1);
    grpSI = nan(10000,2,2);
    cellcnt=1;
    for i = 1:2:length(use)
        aniFile = files(use(i)).sizeanalysis; load(aniFile);
        expcells = size(userf,1)-1;
        grpcells(cellcnt:cellcnt+expcells) = usecells;
        grprf(cellcnt:cellcnt+expcells,:) = userf;
        session(cellcnt:cellcnt+expcells) = (i+1)/2;
        grpdfsize(cellcnt:cellcnt+expcells,:,:,:,1) = dfsize;
        grpSI(cellcnt:cellcnt+expcells,:,1) = SI;
        for j = 1:length(cellprint)
            cellprintpre{cellcnt+j-1} = cellprint{j};
        end
        aniFile = files(use(i+1)).sizeanalysis; load(aniFile);
        grpdfsize(cellcnt:cellcnt+expcells,:,:,:,2) = dfsize;
        grpSI(cellcnt:cellcnt+expcells,:,2) = SI;
        for j = 1:length(cellprint)
            cellprintpost{cellcnt+j-1} = cellprint{j};
        end
        cellcnt = cellcnt+expcells;
    end

    grprf = grprf(1:cellcnt,:);
    session = session(1:cellcnt);
    grpdfsize = grpdfsize(1:cellcnt,:,:,:,:,:); %cell#,t,contr,size,run,pre/post
    grpSI = grpSI(1:cellcnt,:,:);
    grpcells = grpcells(1:cellcnt);
    
    rmsdiff = nan(cellcnt,1);
    footcc = nan(cellcnt,1);
    for i = 1:cellcnt
        rmsdiff(i) = sqrt(mean(mean((cellprintpre{i}-cellprintpost{i}).^2)));
        cc = corrcoef(cellprintpre{i},cellprintpost{i}); footcc(i)=cc(1,2);
    end

    sprintf('saving group file...')
    save(fullfile(savepath,grpfilename),'grprf','session','grpdfsize','grpcells','cellprintpre','cellprintpost','grpSI','rmsdiff','footcc','cellcnt')
    sprintf('done')
else
    sprintf('loading data')
    load(fullfile(savepath,grpfilename))
end

%%%%%%plotting code
% SI = nan(size(grpdfsize,1),2,2);
% for i = 1:size(grpdfsize,1)
%     for j = 1:2
%         for k = 1:2
%             [val ind] = max(nanmean(grpdfsize(i,dfWindow,:,j,k)));
%             if ind==length(sizes)
%                 SI(i,j,k) = 0;
%             else
%                 SI(i,j,k) = val; %%%calc suppression index
%             end
%         end
%     end
% end




%%%plot group data for size select averaging over cells
numAni = length(unique(session));
% ccvals = [0.7 0.8 0.9];
ccvals = [0];
for i = 1:length(ccvals)
    goodcc{i} = find(footcc>ccvals(i));
end

for z=1%:length(ccvals)
    figure
    subplot(1,2,1)
    hold on
    pre = squeeze(nanmean(grpdfsize(goodcc{z},dfWindow,:,1,1),2));
    post = squeeze(nanmean(grpdfsize(goodcc{z},dfWindow,:,1,2),2));
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(length(goodcc{z})),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(length(goodcc{z})),'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('sit spikes')
    axis([0 length(radiusRange)+1 0 10])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))

    subplot(1,2,2)
    hold on
    pre = squeeze(nanmean(grpdfsize(goodcc{z},dfWindow,:,2,1),2));
    post = squeeze(nanmean(grpdfsize(goodcc{z},dfWindow,:,2,2),2));
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(length(goodcc{z})),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(length(goodcc{z})),'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('run spikes')
    axis([0 length(radiusRange)+1 0 10])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    mtit(sprintf('Mean cell (n=%d) size suppression curve (cc>%0.2f)',length(goodcc{z}),ccvals(z)))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end

    %%%plot cycle averages
    figure
    plotmin = min(min([nanmean(grpdfsize(goodcc{z},:,:,1,1),1) nanmean(grpdfsize(goodcc{z},:,:,1,2),1)])) - 0.05;
    plotmax = max(max([nanmean(grpdfsize(goodcc{z},:,:,1,1),1) nanmean(grpdfsize(goodcc{z},:,:,1,2),1)])) + 0.1;
    for i = 2:length(sizes)
        subplot(2,3,i-1)
        pre = grpdfsize(goodcc{z},:,i,1,1);
        post = grpdfsize(goodcc{z},:,i,1,2);
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
    plotmin = min(min([nanmean(grpdfsize(goodcc{z},:,:,2,1),1) nanmean(grpdfsize(goodcc{z},:,:,2,2),1)])) - 0.05;
    plotmax = max(max([nanmean(grpdfsize(goodcc{z},:,:,2,1),1) nanmean(grpdfsize(goodcc{z},:,:,2,2),1)])) + 0.1;
    for i = 2:length(sizes)
        subplot(2,3,i-1)
        pre = grpdfsize(goodcc{z},:,i,2,1);
        post = grpdfsize(goodcc{z},:,i,2,2);
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
    xlabel('sit pre SI')
    ylabel('sit post SI')
    axis square
    mtit('Cell Suppression Index')
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end



    %%%plot group data for size select averaging over animals
    %%size suppression curves
    figure
    subplot(1,2,1)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpdfsize(intersect(find(session==j),goodcc{z}),dfWindow,:,1,1),2),1)); pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpdfsize(intersect(find(session==j),goodcc{z}),dfWindow,:,1,2),2),1)); post(1)=0;
    end
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('sit spikes')
    axis([0 length(radiusRange)+1 0 10])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))

    subplot(1,2,2)
    hold on
    pre=nan(length(unique(session)),length(sizes));post=pre;
    for j = 1:length(unique(session))
        pre(j,:) = squeeze(nanmean(nanmean(grpdfsize(intersect(find(session==j),goodcc{z}),dfWindow,:,2,1),2),1)); pre(1)=0; %median of 0 = nan
        post(j,:) = squeeze(nanmean(nanmean(grpdfsize(intersect(find(session==j),goodcc{z}),dfWindow,:,2,2),2),1)); post(1)=0;
    end
    errorbar(1:length(radiusRange),nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k-o','Markersize',5)
    errorbar(1:length(radiusRange),nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r-o','Markersize',5)
    % plot(1:length(radiusRange),pre,'k--.')
    % plot(1:length(radiusRange),post,'r--.')
    xlabel('Stim Size (deg)')
    ylabel('run spikes')
    axis([0 length(radiusRange)+1 0 10])
    axis square
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
    mtit(sprintf('Mean animal (n=%d) size suppression curve (cc>%0.2f)',numAni,ccvals(z)))
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
                pre(j,:) = nanmean(grpdfsize(intersect(find(session==j),goodcc{z}),:,i,1,1),1);
                post(j,:) = nanmean(grpdfsize(intersect(find(session==j),goodcc{z}),:,i,1,2),1);
        end
        if length(unique(session))==1
            plot(timepts,pre,'k')
            plot(timepts,post,'r')
        else
            shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
            shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
        end
        axis square
        axis([timepts(1) timepts(end) 0 10])
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
                pre(j,:) = nanmean(grpdfsize(intersect(find(session==j),goodcc{z}),:,i,2,1),1);
                post(j,:) = nanmean(grpdfsize(intersect(find(session==j),goodcc{z}),:,i,2,2),1);
        end
        if length(unique(session))==1
            plot(timepts,pre,'k')
            plot(timepts,post,'r')
        else
            shadedErrorBar(timepts,nanmean(pre,1),nanstd(pre,1)/sqrt(numAni),'k',1)
            shadedErrorBar(timepts,nanmean(post,1),nanstd(post,1)/sqrt(numAni),'r',1)
        end
        axis square
        axis([timepts(1) timepts(end) 0 10])
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
    xlabel('sit pre SI')
    ylabel('sit post SI')
    axis square
    mtit('Animal Suppression Index')
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
end


%%%individual cell plotting
for i=1:length(goodcc{end})
    figure

    %%%avg resp to best stim for each size stationary
    subplot(2,3,1)
    hold on
    traces = squeeze(grpdfsize(goodcc{end}(i),:,:,1,1));
    plot(timepts,traces)
    xlabel('Time(s)')
    ylabel('pre spikes')
    if isnan(min(min(traces)))
        axis([0 1 0 1])
    else
        axis([timepts(1) timepts(end) min(min(traces))-0.01 max(max(traces))+0.01])
    end
    axis square
    set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)

    %%%avg resp to best stim for each size running
    subplot(2,3,2)
    hold on
    traces = squeeze(grpdfsize(goodcc{end}(i),:,:,1,2));
    plot(timepts,traces)
    xlabel('Time(s)')
    ylabel('post spikes')
    if isnan(min(min(traces)))
        axis([0 1 0 1])
    else
        axis([timepts(1) timepts(end) min(min(traces))-0.01 max(max(traces))+0.01])
    end
    axis square
    set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)

    %%%size curve based on gratings parameters
    subplot(2,3,3)
    hold on
    splotsit = squeeze(nanmean(grpdfsize(goodcc{end}(i),dfWindow,:,1,1),2));
    splotrun = squeeze(nanmean(grpdfsize(goodcc{end}(i),dfWindow,:,1,2),2));
    plot(1:length(radiusRange),splotsit,'k-o','Markersize',5)
    plot(1:length(radiusRange),splotrun,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('spikes')
    axis([0 length(radiusRange)+1 min(min([splotsit splotrun]))-0.01 max(max([splotsit splotrun]))+0.01])
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes)
    axis square
    set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)
    
    subplot(2,3,4)
    imagesc(cellprintpre{goodcc{end}(i)},[0.5 1]);
    axis square
    axis off
    title('pre')
    
    subplot(2,3,5)
    imagesc(cellprintpost{goodcc{end}(i)},[0.5 1]);
    axis square
    axis off
    title('post')
    
    subplot(2,3,6)
    imagesc(cellprintpost{i} - cellprintpre{i},[-0.5 0.5]);
    axis square
    axis off
    title(sprintf('rms %0.3f cc %0.3f',rmsdiff(goodcc{end}(i)),footcc(goodcc{end}(i))))

    mtit(sprintf('session #%d cell #%d tuning',session(goodcc{1}(i)),grpcells(goodcc{1}(i))))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto'); %%%figure out how to make this full page landscape
        print('-dpsc',psfile,'-append');
    end
end

try
    dos(['ps2pdf ' psfile ' "' [fullfile(savepath,grpfilename) '.pdf'] '"'] )
catch
    display('couldnt generate pdf');
end

delete(psfile);