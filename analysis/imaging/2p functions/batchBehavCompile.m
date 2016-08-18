batch2pBehaviorSBX;


%alluse = find(strcmp({files.task},'GTS') & strcmp({files.notes},'good imaging session'))
alluse = find( strcmp({files.notes},'good imaging session'))

gts = 1; naive=2;
condLabel{1} = 'GTS'; condLabel{2}='naive'; condLabel{3}='naive experienced';
rfAmpAll =[]; rfAll = []; trialDataAll=[]; xAll = []; yAll = []; data3xAll=[]; data2sfAll= [];
n=0;
for i = 1:length(alluse);
    i
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).compileData],'rfAmp','rf','behavTrialData','passiveData3x','passiveData2sf');
    cutoff = size(behavTrialData,1);
    cellrange = (n+1):(n+cutoff);
    rfAmpAll = [rfAmpAll; rfAmp(1:cutoff,:)];
    rfAll = [rfAll; rf(1:cutoff,:)];
    trialDataAll = [trialDataAll; behavTrialData];
    data3xAll = [data3xAll; passiveData3x(1:cutoff,1:29,:)];
    data2sfAll = [data2sfAll; passiveData2sf(1:cutoff,:,:)];
    
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).topoX],'map'); load([pathname files(alluse(i)).dir '\' files(alluse(i)).topoXpts],'cropx','cropy','usePts')
    mapx = getMapPhase(map,cropx,cropy,usePts); close(gcf);
    mapx = mapx*128/(2*pi) - (0.05*128);  %%% (0.05 = 500msec/10sec, lag of raw calcium signals)
    
     load([pathname files(alluse(i)).dir '\' files(alluse(i)).topoY],'map')
    mapy = getMapPhase(map,cropx,cropy,usePts); close(gcf);
    mapy = mapy*72/(2*pi) - (0.05 *72);   %%% (0.05 = 500msec/10sec, lag of raw calcium signals)
    
    xAll = [xAll mapx(1:cutoff)]; yAll = [yAll mapy(1:cutoff)];
    
    if strcmp(files(alluse(i)).task,'GTS'), allCond(cellrange) = gts, end;        
     if strcmp(files(alluse(i)).task,'Naive'), allCond(cellrange) = naive, end;
    
end


goodtopo = rfAmpAll(:,1)>0.025 & rfAmpAll(:,2)>0.025;
figure
plot(rfAll(goodtopo,2),rfAll(goodtopo,1),'.'); axis equal;  axis([0 72 0 128]); title('topo RFs');

figure
plot(rfAll(goodtopo,1),xAll(goodtopo),'.'); axis equal; axis([0 128 0 128]);hold on; plot([0 128],[0 128]); xlabel('rf position'); ylabel('cell body position')

figure
plot(rfAll(goodtopo,2),yAll(goodtopo),'.'); axis equal; axis([0 72 0 72]);hold on; plot([0 72],[0 72]);xlabel('rf position'); ylabel('cell body position')

figure
plot(yAll,xAll,'.');  axis equal;  axis([0 72 0 128]); title('neuropil-based RFs')

d1 = sqrt((rfAll(:,1)-64).^2 + (rfAll(:,2)-36).^2);
d2 = sqrt((mod(rfAll(:,1)+64,128)-64).^2 + (mod(rfAll(:,2)+36,72)-36).^2);
sbc = d2<d1;

% figure
% plot(rfAll(goodtopo & ~sbc,2),rfAll(goodtopo& ~sbc,1),'.'); axis equal;  axis([0 72 0 128]);
% hold on
% plot(rfAll(goodtopo & sbc,2),rfAll(goodtopo& sbc,1),'r.'); axis equal;  axis([0 72 0 128]);

figure
plot(mean(mean(trialDataAll,3),1))

baseline = mean(mean(trialDataAll(:,1:10,:),3),2);
% figure
% hist(baseline)

top = mean(mean(trialDataAll(:,13:16,1:2),3),2)-baseline;
bottom = mean(mean(trialDataAll(:,13:16,3:4),3),2)-baseline;

figure
plot(top,bottom,'o'); axis equal; hold on ; plot([0 1],[0 1])

figure
plot(rfAll(goodtopo ,2),rfAll(goodtopo,1),'.'); axis equal;  axis([0 72 0 128]); hold on
plot(rfAll(goodtopo & top>0.25,2), rfAll(goodtopo&top>0.25,1),'g*');
plot(rfAll(goodtopo & top<-0.25,2), rfAll(goodtopo&top<-0.25,1),'r*');

figure
plot(rfAll(goodtopo ,2),rfAll(goodtopo,1),'.'); axis equal;  axis([0 72 0 128]); hold on
plot(rfAll(goodtopo & bottom>0.25,2), rfAll(goodtopo&bottom>0.25,1),'g*');
plot(rfAll(goodtopo & top<-0.25,2), rfAll(goodtopo&top<-0.25,1),'r*');


figure
plot(yAll,xAll,'.'); axis equal;  axis([0 72 0 128]); hold on
plot(yAll(top>0.25), xAll(top>0.25),'g*');
plot(yAll( top<-0.25), xAll(top<-0.25),'r*');
circle(36,0.66*128,17.5);circle(36,0.33*128,17.5);


figure
plot(yAll,xAll,'.'); axis equal;  axis([0 72 0 128]); hold on
plot(yAll(bottom>0.25), xAll(bottom>0.25),'g*');
plot(yAll( bottom<-0.25), xAll(bottom<-0.25),'r*');
circle(36,0.66*128,17.5);circle(36,0.33*128,17.5);


behavTimepts = -1:0.1:5;
data = reshape(trialDataAll,size(trialDataAll,1),size(trialDataAll,2)*size(trialDataAll,3));
figure
imagesc(data,[0 0.5]); hold on; for i = 1:7; plot([i*61 i*61],[1 size(data,1)],'g'); end

correctData = reshape(trialDataAll(:,:,1:4),size(trialDataAll,1),size(trialDataAll,2)*size(trialDataAll,3)/2);
% figure
% imagesc(correctData,[0 0.5]); hold on; for i = 1:3; plot([i*61 i*61],[1 size(data,1)],'g'); end

dist = pdist(data(:,1:end/2),'correlation');  %%% sort based on correct
display('doing cluster')
Z = linkage(dist,'ward');
% display('doing order')
% tic; leafOrder = optimalleaforder(Z,dist,'criteria','group'); toc
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc((data(perm,:)),[0 0.5]); axis xy
hold on; for i= 1:8, plot([i*length(behavTimepts) i*length(behavTimepts)]+1,[1 size(data,1)],'g'); end
title('behav resp')

data3x = reshape(data3xAll,size(data3xAll,1),size(data3xAll,2)*size(data3xAll,3));
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc((data3x(perm,:)),[0 0.5]); axis xy
hold on; for i= 1:12, plot([i*29 i*29]+1,[1 size(data,1)],'g'); end
title('passive 3x resp')


data2sf = reshape(data2sfAll,size(data2sfAll,1),size(data2sfAll,2)*size(data2sfAll,3));
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc((data2sf(perm,:)),[0 0.5]); axis xy
hold on; for i= 1:12, plot([i*39 i*39]+1,[1 size(data,1)],'g'); end
title('passive 2sf resp')


