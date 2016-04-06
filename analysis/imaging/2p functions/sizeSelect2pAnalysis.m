%%% based on session data and generic points, does pointwise analysis
%%% for topo (periodic spatial) stimuli
clear all

dt = 0.25;

useOld = input('auto select based on generic pts (1) or manually select points (2) or read in prev points (3) : ')
if useOld ==1

    getAnalysisPts;
    
elseif useOld==2
    [pts dF neuropil ptsfname] = get2pPtsManual(dfofInterp,greenframe);
else
    ptsfname = uigetfile('*.mat','pts file');
    load(ptsfname);
end

usenonzero = find(mean(dF,2)~=0); %%% gets rid of generic points that were not identified in this session

figure
imagesc(dF(usenonzero,:),[0 1]); ylabel('cell #'); xlabel('frame'); colormap jet


xpos=0;
sf=0; isi=0; duration=0; theta=0; phase=0; radius=0;
moviefname = 'C:\sizeSelect2sf5sz14min.mat';
moviefname = 'C:\sizeSelect2sf1tf5sz14min.mat';
load (moviefname)
ntrials= min(dt*length(dF)/(isi+duration),length(sf))
onsets = dt + (0:ntrials-1)*(isi+duration);
timepts = 1:(2*isi+duration)/dt;
timepts = (timepts-1)*dt;
dFout = align2onsets(dF,onsets,dt,timepts);
timepts = timepts - isi;

clear tcourse
for s = 1:6
    tcourse(:,:,s) = median(dFout(:,:,find(radius==s)),3);
end
for s=1:size(tcourse,3);
    for n= 1:size(tcourse,1);
        tcourse(n,:,s) = tcourse(n,:,s)-tcourse(n,5,s);
    end
end


for i = 1:12
    figure
    for s=1:6
        subplot(2,3,s)
        plot(squeeze(dFout(usenonzero(i),:,find(radius==s))))
    end
end
% 

save(ptsfname,'tcourse','dF','dFout','radius','sf','xpos','theta','-append')
%%% dF = raw dF/F trace for each cell
%%% dFout = aligned to onset of each stim
%%% tcourse = timecourse averaged across orient/sf for each size

for n = 1:length(usenonzero)
    panel = mod(n-1,6)+1;
    if panel==1
        figure
    end
    subplot(2,3,panel)
    plot(squeeze(tcourse(usenonzero(n),:,:))); axis([1 12 -0.25 0.5])
end

for i = 1:size(dF,2);
    dFnorm(:,i) = dF(:,i)/max(dF(:,i));
end

col = 'rgb';
[coeff score latent] = pca(dFnorm');
figure
plot(score(:,1),score(:,2))
figure
hold on
for i = 1:5
    subplot(5,1,i)
    plot(score(:,i))
end

figure
plot(latent(1:10)/sum(latent))
