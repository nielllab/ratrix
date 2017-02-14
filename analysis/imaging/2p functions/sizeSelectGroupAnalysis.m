%%%use this code to analyze the full contrast, 24 rep size select data

close all
clear all

%%choose dataset
batchPhil2pSizeSelect

path = '\\langevin\backup\twophoton\Phil\Compiled2p\'

psfile = 'c:\tempPhil2p.ps';
if exist(psfile,'file')==2;delete(psfile);end

cd(path);

group = input('which group? 1=saline naive, 2=saline trained, 3=DOI naive, 4=DOI trained: ')
redoani = input('reanalyze individual animal data? 0=no, 1=yes: ')
redogrp = input('reanalyze group data? 0=no, 1=yes: ')

if group==1
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'SalineNaive2pSizeSelect'
elseif group==2
    use = find(strcmp({files.inject},'saline')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session test')  ) 
    grpfilename = 'SalineTrained2pSizeSelectTest'
elseif group==3
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'naive') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOINaive2pSizeSelect'
elseif group==4
    use = find(strcmp({files.inject},'doi')  & strcmp({files.training},'trained') & strcmp({files.label},'camk2 gc6') & strcmp({files.notes},'good imaging session')  ) 
    grpfilename = 'DOITrained2pSizeSelect'
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

moviefname = 'C:\sizeselectBinFullCntr19min';
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
    cellcnt=1;
    for i = 1:2:length(use)
        aniFile = files(use(i)).sizeanalysis; load(aniFile);
        expcells = size(userf,1)-1;
        grprf(cellcnt:cellcnt+expcells,:) = userf;
        session(cellcnt:cellcnt+expcells) = (i+1)/2;
        grpdfsize(cellcnt:cellcnt+expcells,:,:,:,1) = dfsize;
        aniFile = files(use(i+1)).sizeanalysis; load(aniFile);
        grpdfsize(cellcnt:cellcnt+expcells,:,:,:,2) = dfsize;
        cellcnt = cellcnt+expcells;
    end

    grprf = grprf(1:cellcnt,:);
    session = session(1:cellcnt);
    grpdfsize = grpdfsize(1:cellcnt,:,:,:,:,:); %cell#,t,contr,size,run,pre/post

    sprintf('saving group file...')
    save(grpfilename,'grprf','session','grpdfsize')
    sprintf('done')
else
    sprintf('loading data')
    load(grpfilename)
end

%%%%%%plotting code
SI = nan(size(grpdfsize,1),2,2);
for i = 1:size(grpsizedf,1)
    for j = 1:2
        for k = 1:2
            [val ind] = max(nanmean(grpdfsize(i,dfWindow,:,j,k)));
            if ind==length(sizes)
                SI(i,j,k) = 0;
            else
                SI(i,j,k) = val; %%%calc suppression index
            end
        end
    end
end

%%%plot group data for size select
numAni = unique(session);

figure
subplot(1,2,1)
hold on
pre = squeeze(nanmedian(nanmean(grpdfsize(:,dfWindow,:,1,1),2),1)); pre(1)=0; %median of 0 = nan
post = squeeze(nanmedian(nanmean(grpdfsize(:,dfWindow,:,1,2),2),1)); post(1)=0;
plot(1:length(radiusRange),pre,'k-o','Markersize',5)
plot(1:length(radiusRange),post,'r-o','Markersize',5)
xlabel('Stim Size (deg)')
ylabel('sit dfof')
axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
axis square
set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))

subplot(1,2,2)
hold on
pre = squeeze(nanmedian(nanmean(grpdfsize(:,dfWindow,:,2,1),2),1)); pre(1)=0; %median of 0 = nan
post = squeeze(nanmedian(nanmean(grpdfsize(:,dfWindow,:,2,2),2),1)); post(1)=0;
plot(1:length(radiusRange),pre,'k-o','Markersize',5)
plot(1:length(radiusRange),post,'r-o','Markersize',5)
xlabel('Stim Size (deg)')
ylabel('run dfof')
axis([0 length(radiusRange)+1 min(min([pre post]))-0.01 max(max([pre post]))+0.01])
axis square
set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes,'LooseInset',get(gca,'TightInset'))
mtit('Median size suppression curve')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

%%%plot cycle averages
figure
for i = 1:length(sizes)
    subplot(2,length(sizes)/2,i)
    pre = grpdfsize(:,:,i,1,1);
    post = grpdfsize(:,:,i,1,2);
    hold on
    shadedErrorBar(timepts,squeeze(nanmedian(pre,1)),...
        squeeze(nanstd(pre,1))/sqrt(length(usecells)),'k',1)
    shadedErrorBar(timepts,squeeze(nanmedian(post,1)),...
        squeeze(nanstd(post,1))/sqrt(length(usecells)),'r',1)
    plot([0 0],[-0.05 0.2],'b-')
    axis square
    axis([timepts(1) timepts(end) -0.05 0.2])
    set(gca,'LooseInset',get(gca,'TightInset'))
end
mtit('Median cycle avg/size sit')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

figure
for i = 1:length(sizes)
    subplot(2,length(sizes)/2,i)
    pre = grpdfsize(:,:,i,2,1);
    post = grpdfsize(:,:,i,2,2);
    hold on
    shadedErrorBar(timepts,squeeze(nanmedian(pre,1)),...
        squeeze(nanstd(pre,1))/sqrt(length(usecells)),'k',1)
    shadedErrorBar(timepts,squeeze(nanmedian(post,1)),...
        squeeze(nanstd(post,1))/sqrt(length(usecells)),'r',1)
    plot([0 0],[-0.05 0.2],'b-')
    axis square
    axis([timepts(1) timepts(end) -0.05 0.2])
    set(gca,'LooseInset',get(gca,'TightInset'))
end
mtit('Median cycle avg/size run')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

%%%individual cell plotting
for i=1:length(usecells)
    figure

    %%%avg resp to best stim for each size stationary
    subplot(1,3,1)
    hold on
    traces = squeeze(grpdfsize(i,:,:,1,1));
    plot(timepts,traces)
    xlabel('Time(s)')
    ylabel('pre dfof')
    if isnan(min(min(traces)))
        axis([0 1 0 1])
    else
        axis([timepts(1) timepts(end) min(min(traces))-0.01 max(max(traces))+0.01])
    end
    axis square
    set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)

    %%%avg resp to best stim for each size running
    subplot(1,3,2)
    hold on
    traces = squeeze(grpdfsize(i,:,:,1,2));
    plot(timepts,traces)
    xlabel('Time(s)')
    ylabel('post dfof')
    if isnan(min(min(traces)))
        axis([0 1 0 1])
    else
        axis([timepts(1) timepts(end) min(min(traces))-0.01 max(max(traces))+0.01])
    end
    axis square
    set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)

    %%%size curve based on gratings parameters
    subplot(1,3,3)
    hold on
    splotsit = squeeze(nanmean(grpdfsize(i,dfWindow,:,1,1),2));
    splotrun = squeeze(nanmean(grpdfsize(i,dfWindow,:,1,2),2));
    plot(1:length(radiusRange),splotsit,'k-o','Markersize',5)
    plot(1:length(radiusRange),splotrun,'r-o','Markersize',5)
    xlabel('Stim Size (deg)')
    ylabel('dfof')
    axis([0 length(radiusRange)+1 min(min([splotsit splotrun]))-0.01 max(max([splotsit splotrun]))+0.01])
    set(gca,'xtick',1:length(radiusRange),'xticklabel',sizes)
    axis square
    set(gca,'LooseInset',get(gca,'TightInset'),'fontsize',7)

    mtit(sprintf('Cell #%d tuning',usecells(i)))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto'); %%%figure out how to make this full page landscape
        print('-dpsc',psfile,'-append');
    end
end

try
    dos(['ps2pdf ' psfile ' "' [fullfile(path,grpfilename) '.pdf'] '"'] )
catch
    display('couldnt generate pdf');
end

delete(psfile);