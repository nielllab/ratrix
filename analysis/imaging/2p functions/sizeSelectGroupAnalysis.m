%%%loads in individual animal 2p size select data and performs group
%%%analysis
close all
clear all

dfWindow = 9:11;
spWindow = 6:10;
spWindows = {6:8;8:10;6:10};
spWindowsNames = {'First Half','Second Half','Stim Window'};
dt = 0.1;
cyclelength = 1/0.1;

%where are the files
% dirs = {'\\langevin\backup\twophoton\Phil\Compiled2p\071416 G62TX210TT size select2\G62TX210TT'...
%     '\\langevin\backup\twophoton\Phil\Compiled2p\071016 G62EE8TT sizeselect\G62EE8TT'...
%     '\\langevin\backup\twophoton\Phil\Compiled2p\070816 G62BB8RT sizeselect\G62BB8RT'...
%     '\\langevin\backup\twophoton\Phil\Compiled2p\070516 G62Y9RT sizeselect\G62Y9RT'...
%     '\\langevin\backup\twophoton\Phil\Compiled2p\062416 G62TX19LT size select\G62TX19LT'};

dirs = {'\\langevin\backup\twophoton\Phil\Compiled2p\091016 G62Y9RT sizeselect saline\G62Y9RT'...
    '\\langevin\backup\twophoton\Phil\Compiled2p\091216 G62TX19LT sizeselect saline\G62TX19LT'...
    '\\langevin\backup\twophoton\Phil\Compiled2p\101516 G62BB2RT sizeselect saline\G62BB2RT'...
    '\\langevin\backup\twophoton\Phil\Compiled2p\102816 G62MM3RN sizeselect saline\G62MM3RN'};

%stimulus file
moviename = 'C:\sizeSelect2sf8sz26min.mat';
load(moviename);
sizeVals = [0 5 10 20 30 40 50 60];
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end
% sf=[sf sf];phase=[phase phase];radius=[radius radius];tf=[tf tf];theta=[theta theta];xpos=[xpos xpos];ypos=[ypos ypos];
ntrials= length(contrasts);
onsets = dt + (0:ntrials-1)*(isi+duration);
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end

%load pre data
cellcnt = 1;
grpdftuningPRE = nan(10000,15,2,6,4,8,2);
grpsptuningPRE = nan(10000,15,2,6,4,8,2);
% grppeaksPRE = nan(length(dirs),8,2);
for i = 1:length(dirs)
    load(fullfile(dirs{i},'ssSummaryPRE.mat'))
    numcells = size(dftuning,1);
    grpdftuningPRE(cellcnt:cellcnt+numcells-1,:,:,:,:,:,:) = dftuning;
    grpsptuningPRE(cellcnt:cellcnt+numcells-1,:,:,:,:,:,:) = sptuning;
%     grppeaksPRE(i,:,:) = avgpeaks;
    cellcnt = cellcnt + numcells;
end

%load post data
cellcnt = 1;
grpdftuningPOST = nan(1000,15,2,6,4,8,2);
grpsptuningPOST = nan(1000,15,2,6,4,8,2);
% grppeaksPOST = nan(length(dirs),8,2);
for i = 1:length(dirs)
    load(fullfile(dirs{i},'ssSummaryPOST.mat'))
    numcells = size(dftuning,1);
    grpdftuningPOST(cellcnt:cellcnt+numcells-1,:,:,:,:,:,:) = dftuning;
    grpsptuningPOST(cellcnt:cellcnt+numcells-1,:,:,:,:,:,:) = sptuning;
%     grppeaksPOST(i,:,:) = avgpeaks;
    cellcnt = cellcnt + numcells;
end

%baseline all traces
for h = 1:cellcnt
    for i = 1:length(sfrange)
        for j = 1:length(phaserange)
            for k = 1:length(contrastRange)
                for l = 1:length(radiusRange)
                    grpdftuningPRE(h,:,i,j,k,l,1) = grpdftuningPRE(h,:,i,j,k,l,1)-grpdftuningPRE(h,5,i,j,k,l,1);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(h,:,i,j,k,1,1),1),3),4),5));
                    grpdftuningPRE(h,:,i,j,k,l,2) = grpdftuningPRE(h,:,i,j,k,l,2)-grpdftuningPRE(h,5,i,j,k,l,2);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(h,:,i,j,k,1,2),1),3),4),5));
                    grpsptuningPRE(h,:,i,j,k,l,1) = grpsptuningPRE(h,:,i,j,k,l,1)-grpsptuningPRE(h,5,i,j,k,l,1);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(h,:,i,j,k,1,1),1),3),4),5));
                    grpsptuningPRE(h,:,i,j,k,l,2) = grpsptuningPRE(h,:,i,j,k,l,2)-grpsptuningPRE(h,5,i,j,k,l,2);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(h,:,i,j,k,1,2),1),3),4),5));
                    grpdftuningPOST(h,:,i,j,k,l,1) = grpdftuningPOST(h,:,i,j,k,l,1)-grpdftuningPOST(h,5,i,j,k,l,1);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(h,:,i,j,k,1,1),1),3),4),5));
                    grpdftuningPOST(h,:,i,j,k,l,2) = grpdftuningPOST(h,:,i,j,k,l,2)-grpdftuningPOST(h,5,i,j,k,l,2);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(h,:,i,j,k,1,2),1),3),4),5));
                    grpsptuningPOST(h,:,i,j,k,l,1) = grpsptuningPOST(h,:,i,j,k,l,1)-grpsptuningPOST(h,5,i,j,k,l,1);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(h,:,i,j,k,1,1),1),3),4),5));
                    grpsptuningPOST(h,:,i,j,k,l,2) = grpsptuningPOST(h,:,i,j,k,l,2)-grpsptuningPOST(h,5,i,j,k,l,2);%-squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(h,:,i,j,k,1,2),1),3),4),5));                    
                end
            end
        end
    end
end

%subtract off zero size, separately for stationary/running trials
for h = 1:cellcnt
    dfZeroPreSta = squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(h,:,:,:,:,1,1),3),4),5));
    dfZeroPreRun = squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(h,:,:,:,:,1,2),3),4),5));
    spZeroPreSta = squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(h,:,:,:,:,1,1),3),4),5));
    spZeroPreRun = squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(h,:,:,:,:,1,2),3),4),5));
    dfZeroPostSta = squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(h,:,:,:,:,1,1),3),4),5));
    dfZeroPostRun = squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(h,:,:,:,:,1,2),3),4),5));
    spZeroPostSta = squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(h,:,:,:,:,1,1),3),4),5));
    spZeroPostRun = squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(h,:,:,:,:,1,2),3),4),5));
    for i = 1:length(sfrange)
        for j = 1:length(phaserange)
            for k = 1:length(contrastRange)
                for l = 1:length(radiusRange)
                    grpdftuningPRE(h,:,i,j,k,l,1) = grpdftuningPRE(h,:,i,j,k,l,1)-dfZeroPreSta;
                    grpdftuningPRE(h,:,i,j,k,l,2) = grpdftuningPRE(h,:,i,j,k,l,2)-dfZeroPreRun;
                    grpsptuningPRE(h,:,i,j,k,l,1) = grpsptuningPRE(h,:,i,j,k,l,1)-spZeroPreSta;
                    grpsptuningPRE(h,:,i,j,k,l,2) = grpsptuningPRE(h,:,i,j,k,l,2)-spZeroPreRun;
                    grpdftuningPOST(h,:,i,j,k,l,1) = grpdftuningPOST(h,:,i,j,k,l,1)-dfZeroPostSta;
                    grpdftuningPOST(h,:,i,j,k,l,2) = grpdftuningPOST(h,:,i,j,k,l,2)-dfZeroPostRun;
                    grpsptuningPOST(h,:,i,j,k,l,1) = grpsptuningPOST(h,:,i,j,k,l,1)-spZeroPostSta;
                    grpsptuningPOST(h,:,i,j,k,l,2) = grpsptuningPOST(h,:,i,j,k,l,2)-spZeroPostRun;                    
                end
            end
        end
    end
end


%%%dfof plotting
%plot responses as a function of contrast/size
figure
subplot(2,2,1)
hold on
for i=1:length(contrastRange)
    plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,i,:,1),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,i,:,1),4),3),1)));
end
axis([0 length(radiusRange)+1 -0.01 0.1])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend(contrastlist,'location','northwest')
xlabel('Stim Size (deg)')
ylabel('PRE stationary dfof')
subplot(2,2,2)
hold on
for i=1:length(contrastRange)
    plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,i,:,2),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,i,:,2),4),3),1)));
end
axis([0 length(radiusRange)+1 -0.01 0.1])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend(contrastlist,'location','northwest')
xlabel('Stim Size (deg)')
ylabel('PRE running dfof')
subplot(2,2,3)
hold on
for i=1:length(contrastRange)
    plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,i,:,1),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,5,:,:,i,:,1),4),3),1)));
end
axis([0 length(radiusRange)+1 -0.01 0.1])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend(contrastlist,'location','northwest')
xlabel('Stim Size (deg)')
ylabel('POST stationary dfof')
subplot(2,2,4)
hold on
for i=1:length(contrastRange)
    plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,i,:,2),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,5,:,:,i,:,2),4),3),1)));
end
axis([0 length(radiusRange)+1 -0.01 0.1])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend(contrastlist,'location','northwest')
xlabel('Stim Size (deg)')
ylabel('POST running dfof')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

%plot full contrast response peaks across sizes 
figure
subplot(1,2,1)
hold on
plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,end,:,1),4),3),1),2)),'k');%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,:,1),4),3),1)),'k');
plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,end,:,1),4),3),1),2)),'r');%-squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,5,:,:,end,:,1),4),3),1)),'r');
axis([0 length(radiusRange)+1 -0.01 0.1])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend('PRE','POST','location','northwest')
xlabel('Stim Size (deg)')
ylabel('stationary dfof')
subplot(1,2,2)
hold on
plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPRE(:,dfWindow,:,:,end,:,2),4),3),1),2)),'k');%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,:,2),4),3),1)),'k');
plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpdftuningPOST(:,dfWindow,:,:,end,:,2),4),3),1),2)),'r');%-squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,5,:,:,end,:,2),4),3),1)),'r');
axis([0 length(radiusRange)+1 -0.01 0.1])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend('PRE','POST','location','northwest')
xlabel('Stim Size (deg)')
ylabel('running dfof')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

%plot cycle averages for all sizes
figure
for i = 1:length(sizes)
    subplot(2,ceil(length(sizes)/2),i)
    hold on
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,:,:,:,end,i,1),4),3),1)),'k');%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,i,1),4),3),1)),'k')
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,:,:,:,end,i,1),4),3),1)),'r');%-squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,5,:,:,end,i,1),4),3),1)),'r')
    axis([timepts(1) timepts(end) -0.01 0.1])
end
mtit('Stationary dfof per size')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
figure
for i = 1:length(sizes)
    subplot(2,ceil(length(sizes)/2),i)
    hold on
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,:,:,:,end,i,2),4),3),1)),'k');%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,i,2),4),3),1)),'k')
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,:,:,:,end,i,2),4),3),1)),'r');%-squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,5,:,:,end,i,2),4),3),1)),'r')
    axis([timepts(1) timepts(end) -0.01 0.1])
end
mtit('Running dfof per size')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

%plot cycle averages with sizes on same plot
figure
subplot(1,2,1)
hold on
for i = 1:length(sizes)
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,:,:,:,end,i,1),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,i,1),4),3),1)))
end
legend(sizes,'location','northwest')
xlabel('Time (s)')
ylabel('Stationary dfof')
axis([timepts(1) timepts(end) -0.01 0.1])
subplot(1,2,2)
hold on
for i = 1:length(sizes)
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,:,:,:,end,i,2),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,i,2),4),3),1)))
end
legend(sizes,'location','northwest')
xlabel('Time (s)')
ylabel('Running dfof')
axis([timepts(1) timepts(end) -0.01 0.1])
mtit('PRE')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

figure
subplot(1,2,1)
hold on
for i = 1:length(sizes)
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,:,:,:,end,i,1),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,i,1),4),3),1)))
end
legend(sizes,'location','northwest')
xlabel('Time (s)')
ylabel('Stationary dfof')
axis([timepts(1) timepts(end) -0.01 0.1])
subplot(1,2,2)
hold on
for i = 1:length(sizes)
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpdftuningPOST(:,:,:,:,end,i,2),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpdftuningPRE(:,5,:,:,end,i,2),4),3),1)))
end
legend(sizes,'location','northwest')
xlabel('Time (s)')
ylabel('Running dfof')
axis([timepts(1) timepts(end) -0.01 0.1])
mtit('POST')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

%%%same plotting for spikes
%plot responses as a function of contrast/size
figure
subplot(2,2,1)
hold on
for i=1:length(contrastRange)
    plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,i,:,1),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,i,:,1),4),3),1)));
end
axis([0 length(radiusRange)+1 -0.01 0.3])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend(contrastlist,'location','northwest')
xlabel('Stim Size (deg)')
ylabel('PRE stationary spikes')
subplot(2,2,2)
hold on
for i=1:length(contrastRange)
    plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,i,:,2),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,i,:,2),4),3),1)));
end
axis([0 length(radiusRange)+1 -0.01 0.3])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend(contrastlist,'location','northwest')
xlabel('Stim Size (deg)')
ylabel('PRE running spikes')
subplot(2,2,3)
hold on
for i=1:length(contrastRange)
    plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,i,:,1),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,i,:,1),4),3),1)));
end
axis([0 length(radiusRange)+1 -0.01 0.3])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend(contrastlist,'location','northwest')
xlabel('Stim Size (deg)')
ylabel('POST stationary spikes')
subplot(2,2,4)
hold on
for i=1:length(contrastRange)
    plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,i,:,2),4),3),1),2)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,i,:,2),4),3),1)));
end
axis([0 length(radiusRange)+1 -0.01 0.3])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend(contrastlist,'location','northwest')
xlabel('Stim Size (deg)')
ylabel('POST running spikes')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

%plot full contrast response peaks across sizes 
figure
subplot(1,2,1)
hold on
% plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,end,:,1),4),3),1),2)),'k');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,:,1),4),3),1)),'k');
% plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,end,:,1),4),3),1),2)),'r');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,end,:,1),4),3),1)),'r');
errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,end,:,1),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPRE(:,spWindow,:,:,end,:,1),4),3),1),2))/sqrt(cellcnt),'k');
errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,end,:,1),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPOST(:,spWindow,:,:,end,:,1),4),3),1),2))/sqrt(cellcnt),'r');
axis([0 length(radiusRange)+1 -0.01 0.2])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend('PRE','POST','location','northwest')
xlabel('Stim Size (deg)')
ylabel('stationary spikes')
subplot(1,2,2)
hold on
% plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,end,:,2),4),3),1),2)),'k');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,:,2),4),3),1)),'k');
% plot(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,end,:,2),4),3),1),2)),'r');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,end,:,2),4),3),1)),'r');
errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindow,:,:,end,:,2),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPRE(:,spWindow,:,:,end,:,2),4),3),1),2))/sqrt(cellcnt),'k');
errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindow,:,:,end,:,2),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPOST(:,spWindow,:,:,end,:,2),4),3),1),2))/sqrt(cellcnt),'r');
axis([0 length(radiusRange)+1 -0.01 0.2])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend('PRE','POST','location','northwest')
xlabel('Stim Size (deg)')
ylabel('running spikes')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

%plot full contrast response peaks across sizes for stationary using
%different windows
figure
for i = 1:size(spWindows,1)
    subplot(1,size(spWindows,1),i)
    hold on
    errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPRE(:,spWindows{i},:,:,end,:,1),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPRE(:,spWindows{i},:,:,end,:,1),4),3),1),2))/sqrt(cellcnt),'k');
    errorbar(1:length(radiusRange),squeeze(nanmean(nanmean(nanmean(nanmean(grpsptuningPOST(:,spWindows{i},:,:,end,:,1),4),3),1),2)),squeeze(nanstd(nanstd(nanstd(nanstd(grpsptuningPOST(:,spWindows{i},:,:,end,:,1),4),3),1),2))/sqrt(cellcnt),'r');
    axis([0 length(radiusRange)+1 -0.01 0.2])
    set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
    legend('PRE','POST','location','northwest')
    xlabel('Stim Size (deg)')
    ylabel(sprintf('stationary spikes %s', spWindowsNames{i}))
end
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

%plot cycle averages for all sizes
figure
for i = 1:length(sizes)
    subplot(2,ceil(length(sizes)/2),i)
    hold on
%     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,1),4),3),1)),'k');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,1),4),3),1)),'k')
%     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,1),4),3),1)),'r');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,end,i,1),4),3),1)),'r')
    shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,1),4),3),1)),squeeze(nanstd(nanstd(nanstd(grpsptuningPRE(:,:,:,:,end,i,1),4),3),1))/sqrt(cellcnt),'k');
    shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,1),4),3),1)),squeeze(nanstd(nanstd(nanstd(grpsptuningPOST(:,:,:,:,end,i,1),4),3),1))/sqrt(cellcnt),'r');
    axis([timepts(1) timepts(end) -0.01 0.25])
end
mtit('Stationary spikes per size')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
figure
for i = 1:length(sizes)
    subplot(2,ceil(length(sizes)/2),i)
    hold on
%     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,2),4),3),1)),'k');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,2),4),3),1)),'k')
%     plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,2),4),3),1)),'r');%-squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,5,:,:,end,i,2),4),3),1)),'r')
    shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,2),4),3),1)),squeeze(nanstd(nanstd(nanstd(grpsptuningPRE(:,:,:,:,end,i,2),4),3),1))/sqrt(cellcnt),'k');
    shadedErrorBar(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,2),4),3),1)),squeeze(nanstd(nanstd(nanstd(grpsptuningPOST(:,:,:,:,end,i,2),4),3),1))/sqrt(cellcnt),'r');
    axis([timepts(1) timepts(end) -0.01 0.3])
end
mtit('Running spikes per size')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

%plot cycle averages with sizes on same plot
figure
subplot(1,2,1)
hold on
for i = 1:length(sizes)
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,1),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,1),4),3),1)))
end
legend(sizes,'location','northwest')
xlabel('Time (s)')
ylabel('Stationary spikes')
axis([timepts(1) timepts(end) -0.01 0.3])
subplot(1,2,2)
hold on
for i = 1:length(sizes)
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,:,:,:,end,i,2),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,2),4),3),1)))
end
legend(sizes,'location','northwest')
xlabel('Time (s)')
ylabel('Running spikes')
axis([timepts(1) timepts(end) -0.01 0.3])
mtit('PRE')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

figure
subplot(1,2,1)
hold on
for i = 1:length(sizes)
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,1),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,1),4),3),1)))
end
legend(sizes,'location','northwest')
xlabel('Time (s)')
ylabel('Stationary spikes')
axis([timepts(1) timepts(end) -0.01 0.3])
subplot(1,2,2)
hold on
for i = 1:length(sizes)
    plot(timepts,squeeze(nanmean(nanmean(nanmean(grpsptuningPOST(:,:,:,:,end,i,2),4),3),1)));%-squeeze(nanmean(nanmean(nanmean(grpsptuningPRE(:,5,:,:,end,i,2),4),3),1)))
end
legend(sizes,'location','northwest')
xlabel('Time (s)')
ylabel('Running spikes')
axis([timepts(1) timepts(end) -0.01 0.3])
mtit('POST')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

save(newpdfFile,'grpdftuningPRE','grpdftuningPOST','grpsptuningPRE','grpsptuningPOST')%,'grppeaksPRE','grppeaksPOST')

try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end

