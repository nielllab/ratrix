%%% based on session data and generic points, does pointwise analysis
%%% for topo (periodic spatial) stimuli
clear all
close all

pre = 0; %1 if pre, 0 if post, saves cells to use
exclude = 0; %0 removes trials above threshold, 1 clips them to the threshold
peakWindow = 10:13;

[f p] = uiputfile('*.pdf','pdf file');
newpdfFile = fullfile(p,f);

psfile = 'c:\temp.ps';
if exist(psfile,'file')==2;delete(psfile);end

dt = 0.1;
cyclelength = 1/0.1;


% ptsfname = uigetfile('*.mat','pts file');
[f p] = uigetfile('*.mat','pts file');
ptsfname = fullfile(p,f);
load(ptsfname);
% load(ptsfname,'meandfofInterp'); %load meandfofInterp
% % if ~exist('polarImg','var')
% %     [f p] = uigetfile('*.mat','session data');
% %     load(fullfile(p,f),'polarImg')
% % end
% 
% figure
% hold on
% plot(meandfofInterp-median(meandfofInterp),'g')
% plot(mean(dF,1)-median(mean(dF,1)),'b')
% legend('dF','dfofInterp')
% hold off
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end

% [f p] = uigetfile('*.mat','stimObj file');
% stimobject = fullfile(p,f);
% load(stimobject);
% mouseT = stimRec.ts- stimRec.ts(2)+0.0001; %%% first is sometimes off
%     figure
%     plot(diff(mouseT));
%     
%     figure
%     plot(mouseT - stimRec.f/60)
%     ylim([-0.5 0.5])
%     
%     dt = diff(mouseT);
%     use = [1<0; dt>0];
%     mouseT=mouseT(use);
%     
%     posx = cumsum(stimRec.pos(use,1)-900);
%     posy = cumsum(stimRec.pos(use,2)-500);
%    if isnan(frameT)
%        frameT = 0.1*(1:size(dfof_bg,3))';
%    end
%    frameT = frameT - frameT(1)+0.02;
%     vx = diff(interp1(mouseT,posx,frameT));
%     vy = diff(interp1(mouseT,posy,frameT));
%     vx(end+1)=0; vy(end+1)=0;

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
moviefname = 'C:\sizeSelect2sf8sz26min.mat';
load(moviefname)
sizeVals = [0 5 10 20 30 40 50 60];
contrastRange = unique(contrasts); sfrange = unique(sf); phaserange = unique(phase);
for i = 1:length(contrastRange);contrastlist{i} = num2str(contrastRange(i));end
for i=1:length(sizeVals); sizes{i} = num2str(sizeVals(i)); end
% sf=[sf sf];phase=[phase phase];radius=[radius radius];tf=[tf tf];theta=[theta theta];xpos=[xpos xpos];ypos=[ypos ypos];
ntrials= min(dt*length(dF)/(isi+duration),length(sf))
onsets = dt + (0:ntrials-1)*(isi+duration);
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;
dFout = align2onsets(dF,onsets,dt,timepts);
dFout = dFout(usenonzero,:,:);
spikesOut = align2onsets(spikes*10,onsets,dt,timepts);
spikesOut = spikesOut(usenonzero,:,:);
timepts = timepts - isi;

if exclude
    %threshold big guys out
    sigthresh = 10;
    for i=1:size(dFout,1)
        for j=1:size(dFout,3)
            if squeeze(max(dFout(i,1:10,j),[],2))>sigthresh
                dFout(i,:,j) = nan(1,size(dFout,2));
            end
        end
    end 
else
    %re-size big guys down to a max threshold
    sigthresh = 10;
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

dftuning = zeros(size(dFout,1),size(dFout,2),length(sfrange),length(phaserange),length(contrastRange),length(radiusRange));
sptuning = zeros(size(spikesOut,1),size(spikesOut,2),length(sfrange),length(phaserange),length(contrastRange),length(radiusRange));
for h = 1:size(dFout,1)
    for i = 1:length(sfrange)
        for j = 1:length(phaserange)
            for k = 1:length(contrastRange)
                for l = 1:length(radiusRange)
                    dftuning(h,1:size(dFout,2),i,j,k,l) = mean(dFout(h,:,find(sf==sfrange(i)&phase==phaserange(j)&contrasts==contrastRange(k)&radius==l)),3);
                    sptuning(h,1:size(spikesOut,2),i,j,k,l) = mean(spikesOut(h,:,find(sf==sfrange(i)&phase==phaserange(j)&contrasts==contrastRange(k)&radius==l)),3);
                end
            end
        end
    end
end

figure
hold on
for i=1:length(contrastRange)
    plot(1:length(radiusRange),squeeze(mean(mean(mean(mean(dftuning(:,peakWindow,:,:,i,:),4),3),1),2))-squeeze(mean(mean(mean(dftuning(:,5,:,:,i,:),4),3),1)));
end
axis([0 length(radiusRange)+1 -0.01 0.05])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend(contrastlist)
xlabel('Stim Size (deg)')
ylabel('dfof')
title('Peak dF as func of contrast')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

figure
hold on
for i=1:length(contrastRange)
    plot(1:length(radiusRange),squeeze(mean(mean(mean(mean(sptuning(:,peakWindow,:,:,i,:),4),3),1),2))-squeeze(mean(mean(mean(sptuning(:,6,:,:,i,:),4),3),1)));
end
axis([0 length(radiusRange)+1 -0.01 0.2])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
legend(contrastlist)
xlabel('Stim Size (deg)')
ylabel('dfof')
title('Peak spikes as func of contrast')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
   
%cell-by-cell analysis
clear tcourse
clear spcourse
for i = 1:length(radiusRange)
    tcourse(:,:,i) = median(dFout(:,:,find(radius==i&contrasts==contrastRange(end))),3);
    spcourse(:,:,i) = mean(spikesOut(:,:,find(radius==i&contrasts==contrastRange(end))),3); %spikes/size average
end
stimper = size(tcourse,2)/3; %epoch duration

for i=1:size(tcourse,3);
    for n= 1:size(tcourse,1);
        tcourse(n,:,i) = tcourse(n,:,i)-squeeze(nanmean(tcourse(n,stimper+1,i),2));
    end
end

for i=1:size(spcourse,3);
    for n= 1:size(spcourse,1);
        spcourse(n,:,i) = spcourse(n,:,i)-squeeze(nanmean(spcourse(n,stimper+1,i),2));
    end
end

respPos = (mean(tcourse(:,stimper+1:2*stimper,3),2)-mean(tcourse(:,1:stimper,3),2)) > 0;
tcourse = tcourse(respPos,:,:);
spcourse = spcourse(respPos,:,:);
dFout = dFout(respPos,:,:);

figure
for i = 1:size(tcourse,3)
    subplot(2,ceil(size(tcourse,3)/2),i)
    plot(timepts,squeeze(nanmean(tcourse(:,:,i),1)))
    axis([timepts(1) timepts(end) -0.01 0.05])
end
mtit('Mean dfof per size')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end
figure
plot(timepts,squeeze(nanmean(nanmean(tcourse,1),3)))
axis([timepts(1) timepts(end) -0.01 0.05])
title('Total mean dfof')
xlabel('Time (s)')
ylabel('dfof')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end


for i = 1:floor(size(tcourse,1)/10):size(tcourse,1)
    figure
    for j=1:length(radiusRange)
        subplot(2,length(radiusRange)/2,j)
        hold on
        plot(timepts,squeeze(dFout(i,:,find(radius==j&contrasts==contrastRange(end)))))
        plot(timepts,squeeze(nanmean(dFout(i,:,find(radius==j&contrasts==contrastRange(end))),3)),'LineWidth',5,'Color','k')
        axis([timepts(1) timepts(end) 0 1])
    end
    mtit(sprintf('Cell #%d dfof',i))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
end

% peaks = max(dFout(:,1+stimper:stimper*2,:),[],2)-nanmean(dFout(:,1:stimper,:),2);
avgpeaks = squeeze(nanmean(nanmean(tcourse(:,peakWindow,:),2),1));%-tcourse(usenonzero,stimper,:),1));
sepeaks = squeeze(nanstd(nanmean(tcourse(:,peakWindow,:),2),1))/sqrt(length(usenonzero));%-tcourse(usenonzero,stimper,:),[],1));
avgspikes = squeeze(nanmean(nanmean(spcourse(:,peakWindow,:),2),1));
sespikes = squeeze(nanstd(nanmean(spcourse(:,peakWindow,:),2),1))/sqrt(length(usenonzero));


% figure
% errorbar(1:length(radiusRange),avgpeaks,sepeaks)
% xlabel('Stim Size (deg)')
% ylabel('dfof')
% axis([0 length(radiusRange)+1 -0.01 0.1])
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% title('Peak response')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end

% avgpeaks = avgpeaks - avgpeaks(1);

figure
errorbar(1:length(radiusRange),avgpeaks,sepeaks)
xlabel('Stim Size (deg)')
ylabel('dfof')
axis([0 length(radiusRange)+1 -0.01 0.1])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
title('Peak response');
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

figure
plot(timepts,squeeze(nanmean(tcourse,1)))
legend(sizes)
xlabel('Time (s)')
ylabel('dfof')
axis([timepts(1) timepts(end) -0.01 0.1])
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

grpavgpeaks = squeeze(nanmean(nanmean(tcourse(:,peakWindow,:),1),2));
figure
plot(1:length(radiusRange),grpavgpeaks)
xlabel('Stim Size (deg)')
ylabel('dfof')
axis([0 length(radiusRange)+1 0 0.1])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
title('Group avg peak resp');
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end


%spike stuff
figure
for i = 1:size(spcourse,3)
    subplot(2,ceil(size(spcourse,3)/2),i)
    plot(timepts,squeeze(nanmean(spcourse(:,:,i),1)))
    axis([timepts(1) timepts(end) -0.05 0.1])
end
mtit('Mean spikes per size')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

figure
plot(timepts,squeeze(nanmean(nanmean(spcourse,1),3)))
axis([timepts(1) timepts(end) -0.01 0.1])
xlabel('Time (s)')
ylabel('Total mean spikes')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

for i = 1:floor(size(tcourse,1)/10):size(tcourse,1)
    figure
    for j=1:length(radiusRange)
        subplot(2,length(radiusRange)/2,j)
        hold on
        plot(timepts,squeeze(spikesOut(i,:,find(radius==j&contrasts==contrastRange(end)))))
        plot(timepts,squeeze(nanmean(spikesOut(i,:,find(radius==j&contrasts==contrastRange(end))),3)),'LineWidth',5,'Color','k')
        axis([timepts(1) timepts(end) 0 5])
    end
    mtit(sprintf('Cell #%d Spikes',i))
    if exist('psfile','var')
        set(gcf, 'PaperPositionMode', 'auto');
        print('-dpsc',psfile,'-append');
    end
end

% figure
% errorbar(1:length(radiusRange),avgspikes,sespikes)
% xlabel('Stim Size (deg)')
% ylabel('Firing Rate')
% axis([0 length(radiusRange)+1 -0.1 0.5])
% set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
% title('Peak response')
% if exist('psfile','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfile,'-append');
% end

% avgspikes = avgspikes - avgspikes(1);

figure
errorbar(1:length(radiusRange),avgspikes,sespikes)
xlabel('Stim Size (deg)')
ylabel('Firing Rate')
axis([0 length(radiusRange)+1 -0.1 0.5])
set(gca,'xtick',1:length(sizeVals),'xticklabel',sizes)
title('Peak response')
if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

figure
plot(timepts,squeeze(nanmean(spcourse,1)))
legend(sizes)
xlabel('Time (s)')
ylabel('Firing Rate')
axis([timepts(1) timepts(end) -0.1 0.5])
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

%%%post analysis








try
    dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )

catch
    display('couldnt generate pdf');
end
