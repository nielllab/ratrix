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
imagesc(dF(usenonzero,:),[-0.5 1]); ylabel('cell #'); xlabel('frame')


%%% get Fourier component and cycle averages
phaseVal = 0;
for i= 1:size(dfofInterp,3);
    phaseVal = phaseVal+dF(:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
phaseVal = phaseVal/size(dfofInterp,3);

clear cycAvg
for i = 1:cycLength;
    cycAvg(:,i) = mean(dF(:,i:cycLength:end),2);
end
for i = 1:size(cycAvg,1);
    cycAvg(i,:) = cycAvg(i,:) - min(cycAvg(i,:));
end
save(ptsfname,'phaseVal','cycAvg','-append');

figure
plot(cycAvg')
ph = angle(phaseVal);
ph = mod(ph,2*pi);
figure
hist(ph(usenonzero)); xlabel('phase')

figure
hist(abs(phaseVal(usenonzero)),0:0.05:1); xlabel('amplitude');

map = 0;
for i= 1:size(dfofInterp,3);
    map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
amp = abs(map);
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[0 2*pi]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(img)
colormap(hsv); colorbar

figure
draw2pSegs(usePts,ph,hsv,size(dfofInterp,1),intersect(usenonzero,find(abs(phaseVal)>0.05)),[0 2*pi]);

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
