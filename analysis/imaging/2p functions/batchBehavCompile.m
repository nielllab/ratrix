close all

batch2pBehaviorSBX;


%alluse = find(strcmp({files.task},'GTS') & strcmp({files.notes},'good imaging session'))
alluse = find( strcmp({files.notes},'good imaging session'))

gts = 1; naive=2; naiveTrained=3;
condLabel{1} = ' GTS'; condLabel{2}=' naive'; condLabel{3}=' naive trained';

rfAmpAll =[]; rfAll = []; trialDataAll=[]; xAll = []; yAll = []; data3xAll=[]; data2sfAll= [];
n=0;


for i = 1:length(alluse);
    i
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).compileData],'rfAmp','rf','behavTrialData','passiveData3x','passiveData2sf','correctRate','resprate','stoprate');
    figure; plot(resprate/2,'g'); hold on; plot(correctRate,'b');plot(stoprate/10,'r');ylim([0 1]); title([files(alluse(i)).subj files(alluse(i)).task]);legend('response','correct','stop')
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
    
    if strcmp(files(alluse(i)).task,'GTS'), allCond(cellrange) = gts; end;
    if strcmp(files(alluse(i)).task,'Naive') & files(alluse(i)).learningDay<5, allCond(cellrange) = naive; end;
    if strcmp(files(alluse(i)).task,'Naive') & files(alluse(i)).learningDay>=5, allCond(cellrange) = naiveTrained; end;
    
    clear spd
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).passive3xPts],'spd','dFdecon','moviefname');
    if ~exist('spd','var')
        load([pathname files(alluse(i)).dir '\' files(alluse(i)).passive3xStimrec],'stimRec');
        spd = get2pSpeed(stimRec,0.1,size(dFdecon,2)); figure; hist(spd); xlabel('speed')
%         figure
%         plot(spd/max(spd)); hold on; plot(mean(dFdecon,1));
%         
        load(moviefname,'isi','duration');
        dFdecon(dFdecon>5)=5;
      clear sp_spont sp_ev spont ev
      if isi==2
            for tr = 1:floor(size(dFdecon,2)/30);
                 sp_spont(tr) = mean(spd((tr-1)*30 + (11:20)));
                 sp_ev(tr) = mean(spd((tr-1)*30 + (22:28)));
                spont(:,tr) = mean(dFdecon(:,(tr-1)*30 + (11:20)),2);
                ev(:,tr) = mean(dFdecon(:,(tr-1)*30 + (22:28)),2)- spont(:,tr);
            end
        else
            for tr = 1:floor(size(dFdecon,2)/20);
                sp_spont(tr) = mean(spd((tr-1)*20 + (6:10)));
                 sp_ev(tr) = mean(spd((tr-1)*20 + (12:18)));
                spont(:,tr) = mean(dFdecon(:,(tr-1)*20 + (6:10)),2);
                ev(:,tr) = mean(dFdecon(:,(tr-1)*20 + (12:18)),2)- spont(:,tr);
            end
        end   
        d = corrcoef([spont; double(sp_spont>500)]'); 
        spontCorr = d(1:end-1,end); %figure; hist(spontCorr,[-0.95:0.1:1]); title('spont corr')
        deltaSpont = mean(spont(:,sp_spont>500),2)-mean(spont(:,sp_spont<500),2);
        % figure; hist(deltaSpont,[-0.95:0.1:1]); title('delta spont')
        d = corrcoef([ev; double(sp_ev>500)]');
        evCorr = d(1:end-1,end); % figure; hist(evCorr,[-0.95:0.1:1]); title('evoked correlation')
        spontCorrAll(cellrange) = spontCorr(1:cutoff);
        evCorrAll(cellrange) = evCorr(1:cutoff);
        deltaSpontAll(cellrange) =deltaSpont(1:cutoff);
        
    end
    
    n=n+cutoff;
end

figure
hist(spontCorrAll,[-0.95:0.1:1]); title('spont correlation');
figure
hist(evCorrAll,[-0.95:0.1:1]); title('evoked correlation');
figure
hist(deltaSpontAll,[-0.95:0.1:1]); title('evoked correlation');

keyboard

    behavTimepts = -1:0.1:5;

d1 = sqrt((xAll-42).^2 + (yAll-36).^2);
d2 = sqrt((xAll-84).^2 + (yAll-36).^2);
centeredTrialData = zeros(size(trialDataAll))+NaN;
centered3x = zeros(size(data3xAll))+NaN;
centered2sf = zeros(size(data2sfAll))+NaN;
for i = 1:size(centeredTrialData,1);
    if d1(i)<17.5
        centeredTrialData(i,:,:) = trialDataAll(i,:,:);
        centered3x(i,:,:) = data3xAll(i,:,:);
        centered2sf(i,:,:) = data2sfAll(i,:,:);
    elseif d2(i)<17.5
        centeredTrialData(i,:,1:2) = trialDataAll(i,:,3:4);
        centeredTrialData(i,:,3:4) = trialDataAll(i,:,1:2);
        centeredTrialData(i,:,5:6) = trialDataAll(i,:,7:8);
        centeredTrialData(i,:,7:8) = trialDataAll(i,:,5:6);
        centered3x(i,:,1:4) = data3xAll(i,:,9:12);
        centered3x(i,:,5:8) = data3xAll(i,:,5:8);
        centered3x(i,:,9:12) = data3xAll(i,:,1:4);
        centered2sf(i,:,1:4) = data2sfAll(i,:,5:8);
        centered2sf(i,:,5:8) = data2sfAll(i,:,1:4);
        
    end
end

centered = (d1<17.5 | d2<17.5)';

clear invariant
invariant(:,:,2) = mean(centeredTrialData(:,:,3:4),3);
invariant(:,:,1) = mean(centeredTrialData(:,:,1:2),3);

clear epochData
epochData(:,1,:) = squeeze(mean(invariant(:,5:10,:),2));
epochData(:,2,:) = squeeze(mean(invariant(:,12:18,:),2));
epochData(:,3,:) = squeeze(mean(invariant(:,25:35,:),2));
%epochData(:,4,:) = squeeze(mean(invariant(:,50:60,:),2));


%clustData = reshape(invariant(centered,:,:),sum(centered),size(invariant,2)*size(invariant,3));
clustData = reshape(epochData,size(epochData,1),size(epochData,2)*size(epochData,3));
clustData= clustData(:,[1 2 3 ]);

figure
hist(std(clustData'),0.005:0.01:1);
active = (std(clustData')>0.02)';

clustData = clustData(centered & active,:);
allData = reshape(centeredTrialData(centered & active,:,:),sum(centered & active),size(centeredTrialData,2)*size(centeredTrialData,3));


% clustData = clustData(active,:);
% allData = allData(active,:);

figure
imagesc(clustData,[0 0.5]); drawnow

dist = pdist(clustData,'correlation');  %%% sort based on correct
display('doing cluster')
tic, Z = linkage(dist,'ward'); toc
% display('doing order')
% tic; leafOrder = optimalleaforder(Z,dist,'criteria','group'); toc
figure
subplot(3,4,[1 5 9 ])
display('doing dendrogram')
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc((allData(perm,:)),[0 0.5]); axis xy
hold on; for i= 1:8, plot([i*length(behavTimepts) i*length(behavTimepts)]+1,[1 size(allData,1)],'g'); end
title(['behav resp all']); drawnow

figure
subplot(3,4,[1 5 9 ])
display('doing dendrogram')
tic,[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5); toc
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc((clustData(perm,:)),[0 0.5]); axis xy
hold on; for i= 1:8, plot([i*length(behavTimepts) i*length(behavTimepts)]+1,[1 size(allData,1)],'g'); end
title(['behav resp all'])

clear orientInvariant
orientInvariant(:,:,4) = mean(centeredTrialData(:,1:42,7:8),3);
orientInvariant(:,:,2) = mean(centeredTrialData(:,1:42,5:6),3);
orientInvariant(:,:,3) = mean(centeredTrialData(:,1:42,3:4),3);
orientInvariant(:,:,1) = mean(centeredTrialData(:,1:42,1:2),3);
invariantAll = reshape(orientInvariant,n,size(orientInvariant,2)*size(orientInvariant,3));



clust= zeros(1,n);
c= cluster(Z,'maxclust',6);
figure
h = hist(c); h= h/sum(h); bar(h); xlabel('cluster');
for i = 1:max(c);
    if h(i)<0.05; c(i)=0; end;
end

clust(centered & active) =c;


trialType = {'correct pref','error pref','correct non-pref','error non-pref'};
for cond = 1:2
    figure
    for t = 1:4
        subplot(2,2,t);
        for i = 1:max(c)
            d =mean(invariantAll(clust==i & allCond==cond ,:),1); plot(d((t-1)*42 + (1:42))-min(d));hold on; ylim([ 0 0.3]); xlim([0.5 42.5])
        end
        title(trialType{t});
    end
    
    legend;
    set(gcf,'Name',condLabel{cond});
end

orientInvariant3x(:,:,4) = mean(centered3x(:,:,[10 12]),3);
orientInvariant3x(:,:,3) = mean(centered3x(:,:,[9 11]),3);
orientInvariant3x(:,:,2) = mean(centered3x(:,:,[2 4]),3);
orientInvariant3x(:,:,1) = mean(centered3x(:,:,[1 3]),3);
invariantAll3x = reshape(orientInvariant3x,n,size(orientInvariant3x,2)*size(orientInvariant3x,3));

trialType = {'pref hv','pref oblique','non-pref hv','non-prev oblique'};
for cond = 1:2
    figure
    for t = 1:4
        subplot(2,2,t);
        for i = 1:max(c)
            d =mean(invariantAll3x(clust==i & allCond==cond ,:),1); plot(d((t-1)*29 + (1:29))-min(d));hold on; ylim([ 0 0.3]); xlim([0.5 42.5])
        end
        title(trialType{t});
    end
    
    legend;
    set(gcf,'Name',condLabel{cond});
end



orientInvariant2sf(:,:,4) = mean(centered2sf(:,:,[6 8]),3);
orientInvariant2sf(:,:,3) = mean(centered2sf(:,:,[5 7]),3);
orientInvariant2sf(:,:,2) = mean(centered2sf(:,:,[2 4]),3);
orientInvariant2sf(:,:,1) = mean(centered2sf(:,:,[1 3]),3);
invariantAll2sf = reshape(orientInvariant2sf,n,size(orientInvariant2sf,2)*size(orientInvariant2sf,3));

trialType = {'pref ','pref hi sf','non pref','non pref hi sf'};
for cond = 1:2
    figure
    for t = 1:4
        subplot(2,2,t);
        for i = 1:max(c)
            d =mean(invariantAll2sf(clust==i & allCond==cond,:),1); plot(d((t-1)*39 + (1:39))-min(d));hold on; ylim([ 0 0.3]); xlim([0.5 42.5])
        end
        title(trialType{t});
    end
    
    legend;
    set(gcf,'Name',condLabel{cond});
end

for i= 1:max(c);
    figure
    hist(deltaSpontAll(clust==i),[-0.95:0.1:1]); title(sprintf('cluster %d',i));
    spontMod(i) = mean(deltaSpontAll(clust==i));
end
figure
bar(spontMod); ylabel('spontaneous modulation')

clear clustDist
for cond =1:2
    for i = 1:max(clust); clustDist(cond,i) = sum(allCond==cond & clust==i )/sum(allCond==cond & clust>0 ); end
    clustDist(cond,i+1) = sum(allCond'==cond & centered & ~active)/sum(allCond'==cond & centered);
    figure
   % pie(clustDist(cond,[4 1 2 3]),{'inactive','sustain','transient','suppresed'}); title(condLabel{cond});
   pie(clustDist(cond,:),{'','sustained','transient','transient behavior','','suppressed','inactive'});title(condLabel{cond})
end
clustDist


keyboard 

for cond=1:3;
    
    use = allCond'==cond;
    
    goodtopo = rfAmpAll(:,1)>0.025 & rfAmpAll(:,2)>0.025;
    
    % figure
    % plot(rfAll(goodtopo&use,2),rfAll(goodtopo&use,1),'.'); axis equal;  axis([0 72 0 128]); title('topo RFs');
    % figure
    % plot(rfAll(goodtopo&use,1),xAll(goodtopo&use),'.'); axis equal; axis([0 128 0 128]);hold on; plot([0 128],[0 128]); xlabel('rf position'); ylabel('cell body position')
    % figure
    % plot(rfAll(goodtopo&use,2),yAll(goodtopo&use),'.'); axis equal; axis([0 72 0 72]);hold on; plot([0 72],[0 72]);xlabel('rf position'); ylabel('cell body position')
    %
    % figure
    % plot(yAll(use),xAll(use),'.');  axis equal;  axis([0 72 0 128]); title(['neuropil-based RFs ' condLabel{cond}])
    
    baseline = mean(mean(trialDataAll(:,1:10,:),3),2);
    
    top = mean(mean(trialDataAll(:,13:16,1:2),3),2)-baseline;
    bottom = mean(mean(trialDataAll(:,13:16,3:4),3),2)-baseline;
    
    useCentered = use & (d1<17.5 | d2<17.5)';
    
    figure
    d = (mean(mean(centeredTrialData(useCentered,:,1:2),3),1)); plot(d-min(d),'Color',[0 1 0]); hold on;
    d = (mean(mean(centeredTrialData(useCentered,:,3:4),3),1)); plot(d-min(d),'Color',[0 0.5 0]);
    d = (mean(mean(centeredTrialData(useCentered,:,5:6),3),1)); plot(d-min(d),'Color',[1 0 0]);
    d = (mean(mean(centeredTrialData(useCentered,:,7:8),3),1)); plot(d-min(d),'Color',[0.5 0 0]);
    title(['mean' condLabel{cond}]); legend('pref correct','non-pref correct','pref error','non-pref error'); ylim([0 0.1])
    
    figure
    d = (mean(mean(centered3x(useCentered,:,[1 3]),3),1)); plot(d-min(d),'Color',[0 1 0]); hold on;
    d = (mean(mean(centered3x(useCentered,:,[5 7]),3),1)); plot(d-min(d),'Color',[1 0 0]); hold on;
    d = (mean(mean(centered3x(useCentered,:,[9 11]),3),1)); plot(d-min(d),'Color',[0 0 1]); hold on;
    d = (mean(mean(centered3x(useCentered,:,[2 4]),3),1)); plot(d-min(d),'Color',[0 0.5 0]); hold on;
    d = (mean(mean(centered3x(useCentered,:,[6 8]),3),1)); plot(d-min(d),'Color',[0.5 0 0]); hold on;
    d = (mean(mean(centered3x(useCentered,:,[10 12]),3),1)); plot(d-min(d),'Color',[0 0.5 1]); hold on;
    title(['passive 3x' condLabel{cond}]); legend('pref','middle','non-pref');ylim([0 0.1])
    
    figure
    d = (mean(mean(centered2sf(useCentered,:,[1 3]),3),1)); plot(d-min(d),'Color',[0 1 0]); hold on;
    d = (mean(mean(centered2sf(useCentered,:,[5 7]),3),1)); plot(d-min(d),'Color',[1 0 0]); hold on;
    d = (mean(mean(centered2sf(useCentered,:,[2 4]),3),1)); plot(d-min(d),'Color',[0 0.5 0]); hold on;
    d = (mean(mean(centered2sf(useCentered,:,[6 8]),3),1)); plot(d-min(d),'Color',[0.5 0 0]); hold on;
    title(['passive 2sf' condLabel{cond}]); legend('pref','non-pref','pref hi SF','non-pref hi SF');ylim([0 0.1])
    
    
    
    figure
    plot(top(useCentered),bottom(useCentered),'g.'); axis equal; hold on ; plot([0 1],[0 1]); xlabel('top'); ylabel('bottom');
    plot(top(use & ~useCentered),bottom(use & ~useCentered),'b.'); axis equal; hold on ; plot([0 1],[0 1]); xlabel('top'); ylabel('bottom');
    
    
    figure
    plot(yAll(use),xAll(use),'.'); axis equal;  axis([0 72 0 128]); hold on
    plot(yAll(use & top>0.25), xAll(use & top>0.25),'g*');
    plot(yAll(use & top<-0.25), xAll(use & top<-0.25),'r*');
    circle(36,0.66*128,17.5);circle(36,0.33*128,17.5); title(['top' condLabel{cond}]);
    
    figure
    plot(yAll(use),xAll(use),'.'); axis equal;  axis([0 72 0 128]); hold on
    plot(yAll(use & bottom>0.25), xAll(use & bottom>0.25),'g*');
    plot(yAll(use & bottom<-0.25), xAll(use &bottom<-0.25),'r*');
    circle(36,0.66*128,17.5);circle(36,0.33*128,17.5); title(['bottom' condLabel{cond}]);
    
    drawnow
    

    data = reshape(centeredTrialData(useCentered,:,:),size(trialDataAll(useCentered,:,:),1),size(trialDataAll,2)*size(trialDataAll,3));
    
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
    title(['behav resp' condLabel{cond}])
    
    data3x = reshape(centered3x(useCentered,:,:),size(data3xAll(useCentered,:,:),1),size(data3xAll,2)*size(data3xAll,3));
    figure
    subplot(3,4,[1 5 9 ])
    [h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5);
    axis off
    subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
    imagesc((data3x(perm,:)),[0 0.5]); axis xy
    hold on; for i= 1:12, plot([i*29 i*29]+1,[1 size(data,1)],'g'); end
    title(['passive 3x resp' condLabel{cond}])
    
    
    data2sf = reshape(centered2sf(useCentered,:,:),size(centered2sf(useCentered,:,:),1),size(data2sfAll,2)*size(data2sfAll,3));
    figure
    subplot(3,4,[1 5 9 ])
    [h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5);
    axis off
    subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
    imagesc((data2sf(perm,:)),[0 0.5]); axis xy
    hold on; for i= 1:12, plot([i*39 i*39]+1,[1 size(data,1)],'g'); end
    title(['passive 2sf resp' condLabel{cond}])
    
end




