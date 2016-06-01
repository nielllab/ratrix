%%% based on session data and generic points, does pointwise analysis
%%% for topo (periodic spatial) stimuli
clear all
close all

exclude = 0; %0 removes trials above threshold, 1 clips them to the threshold

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end

dt = 0.1;
cyclelength = 2/0.1;


ptsfname = uigetfile('*.mat','pts file');
load(ptsfname);
load(ptsfname(1:end-21),'meandfofInterp'); %load meandfofInterp
stimsizes = [0,5.6,11.3,22.5,45,50.6];
% if ~exist('polarImg','var')
%     [f p] = uigetfile('*.mat','session data');
%     load(fullfile(p,f),'polarImg')
% end

figure
hold on
plot(meandfofInterp-median(meandfofInterp),'g')
plot(mean(dF,1)-median(mean(dF,1)),'b')
legend('dF','dfofInterp')
hold off
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

figure
imagesc(dF,[0 1]); title('dF')

spikeBinned = imresize(spikes,[size(spikes,1) size(spikes,2)/10]);
figure
imagesc(spikeBinned,[ 0 0.1]); title('spikes binned')


% usenonzero = find(mean(spikes,2)~=0); %%% gets rid of generic points that were not identified in this session
usenonzero = 1:size(dF,1);
cellCutoff = input('cell cutoff : ');
usenonzero=usenonzero(usenonzero<cellCutoff);

figure
imagesc(dF(usenonzero,:),[0 1]); ylabel('cell #'); xlabel('frame'); title('dF');
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
figure
imagesc(spikeBinned(usenonzero,:),[0 0.1]); ylabel('cell #'); xlabel('frame'); title('spikes');
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
% 
% 
% useOld = input('auto select based on generic pts (1) or manually select points (2) or read in prev points (3) : ')
% if useOld ==1
% 
%     getAnalysisPts;
%     
% elseif useOld==2
%     [pts dF neuropil ptsfname] = get2pPtsManual(dfofInterp,greenframe);
% else
%     ptsfname = uigetfile('*.mat','pts file');
%     load(ptsfname);
% end
% 
% % usenonzero = find(mean(dF,2)~=0); %%% gets rid of generic points that were not identified in this session
% usenonzero = 1:size(dF,1);
% 
% figure
% % imagesc(dF(usenonzero,:),[0 1]); ylabel('cell #'); xlabel('frame'); colormap jet
% imagesc(dF(usenonzero,:),[0 1]); ylabel('cell #'); xlabel('frame'); colormap jet

xpos=0;
sf=0; isi=0; duration=0; theta=0; phase=0; radius=0;
% moviefname = 'C:\sizeSelect2sf5sz14min.mat';
moviefname = 'C:\sizeSelect2sf1tf5sz14min.mat';
load (moviefname)
sf=[sf sf];phase=[phase phase];radius=[radius radius];tf=[tf tf];theta=[theta theta];xpos=[xpos xpos];ypos=[ypos ypos];
ntrials= min(dt*length(dF)/(isi+duration),length(sf))
onsets = dt + (0:ntrials-1)*(isi+duration);
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;
dFout = align2onsets(dF,onsets,dt,timepts);
spikesOut = align2onsets(spikes*10,onsets,dt,timepts);
timepts = timepts - isi;

if exclude
    %threshold big guys out
    sigthresh = 1;
    for i=1:size(dFout,1)
        for j=1:size(dFout,3)
            if squeeze(max(dFout(i,1:10,j),[],2))>sigthresh
                dFout(i,:,j) = nan(1,size(dFout,2));
            end
        end
    end
else
    %re-size big guys down to a max threshold
    sigthresh = 1;
    for i=1:size(dFout,1)
        for j=1:size(dFout,3)
            if squeeze(max(dFout(i,1:10,j),[],2))>sigthresh
                vals = dFout(i,:,j);
                vals(vals>sigthresh) = sigthresh;
                dFout(i,:,j) = vals;
            end
        end
    end
end
            
clear tcourse
for i = 1:length(radiusRange)
    tcourse(:,:,i) = median(dFout(:,:,find(radius==i)),3);
    spcourse(:,:,i) = mean(spikesOut(:,:,find(radius==i)),3); %spikes/size average
end
for i=1:size(tcourse,3);
    for n= 1:size(tcourse,1);
        tcourse(n,:,i) = tcourse(n,:,i)-squeeze(nanmean(tcourse(n,5:10,i),2));
    end
end

for i=1:size(spcourse,3);
    for n= 1:size(spcourse,1);
        spcourse(n,:,i) = spcourse(n,:,i)-squeeze(nanmean(spcourse(n,5:10,i),2));
    end
end

figure
for i = 1:size(tcourse,3)
    subplot(2,ceil(size(tcourse,3)/2),i)
    plot(timepts,squeeze(nanmean(tcourse(:,:,i),1)))
    axis([-1 2 -0.01 0.05])
end
mtit('Mean dfof per size')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
figure
plot(timepts,squeeze(nanmean(nanmean(tcourse,1),3)))
axis([-1 2 -0.01 0.05])
title('Total mean dfof')
xlabel('Time (s)')
ylabel('dfof')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end


for i = 1:floor(cellCutoff/10):cellCutoff
    figure
    for j=1:length(radiusRange)
        subplot(2,3,j)
        hold on
        plot(timepts,squeeze(dFout(usenonzero(i),:,find(radius==j))))
        plot(timepts,squeeze(nanmean(dFout(usenonzero(i),:,find(radius==j)),3)),'LineWidth',5,'Color','k')
        axis([timepts(1) timepts(end)+dt 0 1])
    end
    mtit(sprintf('Cell #%d dfof',i))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
end

stimper = size(tcourse,2)/3;
% peaks = max(dFout(:,1+stimper:stimper*2,:),[],2)-nanmean(dFout(:,1:stimper,:),2);
avgpeaks = squeeze(nanmean(max(tcourse(usenonzero,1+stimper:stimper*2,:),[],2)));%-tcourse(usenonzero,stimper,:),1));
sepeaks = squeeze(nanstd(max(tcourse(usenonzero,1+stimper:stimper*2,:),[],2)))/sqrt(length(usenonzero));%-tcourse(usenonzero,stimper,:),[],1));
avgspikes = squeeze(nanmean(max(spcourse(usenonzero,1+stimper:stimper*2,:),[],2)));
sespikes = squeeze(nanstd(max(spcourse(usenonzero,1+stimper:stimper*2,:),[],2)))/sqrt(length(usenonzero));


figure
errorbar(1:length(radiusRange),avgpeaks,sepeaks)
xlabel('Stim Size (deg)')
ylabel('dfof')
axis([0 length(radiusRange)+1 0 0.02])
set(gca,'xtick',1:6,'xticklabel',stimsizes)
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
% axis([0 length(radiusRange)+1 0 0.05])

figure
plot(timepts,squeeze(nanmean(tcourse,1)))
legend('0deg','5.6','11.3','22.5','45','50.6')
xlabel('Time (s)')
ylabel('dfof')
axis([timepts(1) timepts(end)+dt -0.01 0.02])
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

figure
for i = 1:size(spcourse,3)
    subplot(2,ceil(size(spcourse,3)/2),i)
    plot(timepts,squeeze(nanmean(spcourse(:,:,i),1)))
    axis([-1 2 -0.05 0.1])
end
mtit('Mean spikes per size')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
figure
plot(timepts,squeeze(nanmean(nanmean(spcourse,1),3)))
axis([-1 2 -0.01 0.05])
xlabel('Time (s)')
ylabel('Total mean spikes')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

for i = 1:floor(cellCutoff/10):cellCutoff
    figure
    for j=1:length(radiusRange)
        subplot(2,3,j)
        hold on
        plot(timepts,squeeze(spikesOut(usenonzero(i),:,find(radius==j))))
        plot(timepts,squeeze(nanmean(spikesOut(usenonzero(i),:,find(radius==j)),3)),'LineWidth',5,'Color','k')
        axis([timepts(1) timepts(end)+dt 0 5])
    end
    mtit(sprintf('Cell #%d Spikes',i))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
end

figure
errorbar(1:length(radiusRange),avgspikes,sespikes)
xlabel('Stim Size (deg)')
ylabel('Firing Rate')
axis([0 length(radiusRange)+1 0 0.2])
set(gca,'xtick',1:6,'xticklabel',stimsizes)
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
% axis([0 length(radiusRange)+1 0 0.05])

figure
plot(timepts,squeeze(nanmean(spcourse,1)))
legend('0deg','5.6','11.3','22.5','45','50.6')
xlabel('Time (s)')
ylabel('Firing Rate')
axis([timepts(1) timepts(end)+dt -0.05 0.1])
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

% 
% 
% save(ptsfname,'tcourse','dFout','radius','sf','xpos','theta','-append')
% %%% dF = raw dF/F trace for each cell
% %%% dFout = aligned to onset of each stim
% %%% tcourse = timecourse averaged across orient/sf for each size
% 
% for n = 1:length(usenonzero)
%     panel = mod(n-1,6)+1;
%     if panel==1
%         figure
%     end
%     subplot(2,3,panel)
%     plot(squeeze(tcourse(usenonzero(n),:,:))); axis([1 12 -0.25 0.5])
% end
% 
% for i = 1:size(dF,2);
%     dFnorm(:,i) = dF(:,i)/max(dF(:,i));
% end
% 
% col = 'rgb';
% [coeff score latent] = pca(dFnorm');
% figure
% plot(score(:,1),score(:,2))
% figure
% hold on
% for i = 1:5
%     subplot(5,1,i)
%     plot(score(:,i))
% end
% 
% figure
% plot(latent(1:10)/sum(latent))



try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end
