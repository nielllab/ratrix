%%% based on session data and generic points, does pointwise analysis
%%% for topo (periodic spatial) stimuli
clear all

dt = 0.1;
cyclelength = 2/0.1;


ptsfname = uigetfile('*.mat','pts file');
load(ptsfname);
% if ~exist('polarImg','var')
%     [f p] = uigetfile('*.mat','session data');
%     load(fullfile(p,f),'polarImg')
% end

figure
imagesc(dF,[0 1]); title('dF')

spikeBinned = imresize(spikes,[size(spikes,1) size(spikes,2)/10]);
figure
imagesc(spikeBinned,[ 0 0.1]); title('spikes binned')

figure
hold on
plot(mean(dF,1),'g')
plot(meandfofInterp,'b')
legend('dF','dfofInterp')
hold off

if exist('psfile','var')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfile,'-append');
end

% usenonzero = find(mean(spikes,2)~=0); %%% gets rid of generic points that were not identified in this session
usenonzero = 1:size(dF,1);
cellCutoff = input('cell cutoff : ');
usenonzero=usenonzero(usenonzero<cellCutoff);

figure
imagesc(dF(usenonzero,:),[0 1]); ylabel('cell #'); xlabel('frame'); title('dF');
figure
imagesc(spikeBinned(usenonzero,:),[0 0.1]); ylabel('cell #'); xlabel('frame'); title('spikes');
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
ntrials= min(dt*length(dF)/(isi+duration),length(sf))
onsets = dt + (0:ntrials-1)*(isi+duration);
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;
dFout = align2onsets(dF,onsets,dt,timepts);
timepts = timepts - isi;

clear tcourse
for i = 1:6
    tcourse(:,:,i) = median(dFout(:,:,find(radius==i)),3);
end
for i=1:size(tcourse,3);
    for n= 1:size(tcourse,1);
        tcourse(n,:,i) = tcourse(n,:,i)-tcourse(n,5,i);
    end
end

figure
for i = 1:size(tcourse,3)
    subplot(2,ceil(size(tcourse,3)/2),i)
    plot(timepts,squeeze(mean(tcourse(:,:,i),1)))
    axis([-1 2 -0.05 0.1])
end
figure
plot(timepts,squeeze(mean(mean(tcourse,1),3)))
axis([-1 2 -0.05 0.1])


for i = 1:12
    figure
    for j=1:6
        subplot(2,3,j)
        plot(squeeze(dFout(usenonzero(i),:,find(radius==j))))
    end
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
