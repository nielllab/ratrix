close all


batch2pBehaviorFix;

%%% select files to analyze
%alluse = find(strcmp({files.task},'GTS') & strcmp({files.notes},'good imaging session'))
alluse = find( strcmp({files.notes},'possible'))

%%% labels for each condition
gts = 1; naive=2; naiveTrained=5;  rand =3; hvv = 4;
condLabel{1} = ' GTS'; condLabel{2}=' naive'; condLabel{5}=' naive trained'; condLabel{3} = ' rand'; condLabel{4} = ' HvV';

%%% create empty variables for data appending
rfAmpAll =[]; rfAll = []; trialDataAll=[]; xAll = []; yAll = []; data3xAll=[]; data2sfAll= [];
n=0;


for i = 1:length(alluse);
%for i = 1:3
    i
    
    %%% load data
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).compileData],'rfAmp','rf','behavTrialData','passiveData3x','passiveData2sf','correctRate','resprate','stoprate','behavdF');
    figure; plot(resprate/2,'g'); hold on; plot(correctRate,'b');plot(stoprate/10,'r');ylim([0 1]); title([files(alluse(i)).subj files(alluse(i)).task]);legend('response','correct','stop')
    
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).compileData],'targ','correct','location');
    targAll{i} = targ; correctAll{i} = correct; locationAll{i} = location;
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).behavPts],'dF');
    
    behavDfAll{i} =dF;
    %%% store behavioral performance over time
    respRateAll{i} = resprate; correctRateAll{i} = correctRate; stopRateAll{i} = stoprate;
    %%%get depth info
    if ~isempty (files(alluse(i)).depth)    
    depth(i) = files(alluse(i)).depth;
    else
        depth(i) = 1;
    end
    
    %%% apply manual cutoff for cell numbers if included
    if ~isempty(files(alluse(i)).ncells)
        cutoff = files(alluse(i)).ncells;
    else
        cutoff = size(behavTrialData,1);
    end
    
    %%% append this session's data
    cellrange = (n+1):(n+cutoff);
    rfAmpAll = [rfAmpAll; rfAmp(1:cutoff,:)];
    rfAll = [rfAll; rf(1:cutoff,:)];
    trialDataAll = [trialDataAll; behavTrialData(1:cutoff,:,:)];
    data3xAll = [data3xAll; passiveData3x(1:cutoff,1:29,:)];
    data2sfAll = [data2sfAll; passiveData2sf(1:cutoff,:,:)];
    
    %%% get topography data
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).topoX],'map'); load([pathname files(alluse(i)).dir '\' files(alluse(i)).topoXpts],'cropx','cropy','usePts')
    mapx = getMapPhase(map,cropx,cropy,usePts); close(gcf); %%% get topography based on neuropil
    mapx = mapx*128/(2*pi) - (0.05*128);  %%% (0.05 = 500msec/10sec, lag of raw calcium signals)
    
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).topoY],'map')
    mapy = getMapPhase(map,cropx,cropy,usePts); close(gcf); %%% get topography based on neuropil
    mapy = mapy*72/(2*pi) - (0.05 *72);   %%% (0.05 = 500msec/10sec, lag of raw calcium signals)
    
    xAll = [xAll mapx(1:cutoff)]; yAll = [yAll mapy(1:cutoff)]; % append topography
    
    %%% get task condition
    allCond(cellrange)=NaN;
    if strcmp(files(alluse(i)).task,'GTS'), allCond(cellrange) = gts; end;
    if strcmp(files(alluse(i)).task,'Naive') & files(alluse(i)).learningDay<8, allCond(cellrange) = naive; end;
    if strcmp(files(alluse(i)).task,'Naive') & files(alluse(i)).learningDay>=8, allCond(cellrange) = naiveTrained; end;
    if strcmp(files(alluse(i)).task,'HvV'), allCond(cellrange) = hvv; end;
    if strcmp(files(alluse(i)).task, 'RandReward'), allCond(cellrange) = rand; end;
    
    %%% save out other session information
    sessionCond(i) = allCond(cellrange(1));
    sessionSubj{i} = files(alluse(i)).subj;
    sess(cellrange)=i;
    sessionDate{i} = files(alluse(i)).expt;

    
    %%% get eye data for behavior
    clear eyes
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).behavPts],'eyes','eyeAlign');
    if ~exist('eyes','var');    %%% if it's not already done, get extract eye position and align to data
        display('calculating eyes');
        load([pathname files(alluse(i)).dir '\' files(alluse(i)).behavPts],'onsets','dt');
        try
            eyes = get2pEyes([pathname files(alluse(i)).dir '\' files(alluse(i)).behavEyes],0,dt);
            figure
            plot(eyes); legend('x','y','r');
            
            timepts = -1:0.25:5;
            eyeAlign = align2onsets(eyes',onsets,dt,timepts);
            save([pathname files(alluse(i)).dir '\' files(alluse(i)).behavPts],'eyes','eyeAlign','-append');
        catch
            eyeAlign = NaN;
        end
    end
    %%% make eye movies
    %     load([pathname files(alluse(i)).dir '\' files(alluse(i)).behavEyes],'data');
    %     %     d= squeeze(data(:,:,1,50:50:end));
    %     %     range = [min(d(:)) max(d(:))];
    %     %     figure
    %     %     mx = max(eyes(:));
    %     %     for j = 1:100:size(data,4);
    %     %         subplot(2,2,2);
    %     %         imagesc(data(:,:,1,j),range);
    %     %         subplot(2,2,3:4);
    %     %         hold off; plot(eyes); hold on; plot([j/2 j/2], [1 mx]);
    %     %         drawnow;
    %     %     end
    %
    %     figure
    %     subplot(2,2,1); imagesc(data(:,:,1,50)); subplot(2,2,2); imagesc(data(:,:,1,round(end/3)));
    %     subplot(2,2,3); imagesc(data(:,:,1,round(2*end/3))); subplot(2,2,4); imagesc(data(:,:,1,end)); colormap gray
    %     behavRadius{i} = eyes(:,3);
    
    %%% load in speed data from passive 3x
    clear spd eyes
    load([pathname files(alluse(i)).dir '\' files(alluse(i)).passive3xPts],'spd','dFdecon','moviefname','eyes');
    if ~exist('spd','var')
        load([pathname files(alluse(i)).dir '\' files(alluse(i)).passive3xStimrec],'stimRec');
        spd = get2pSpeed(stimRec,0.1,size(dFdecon,2)); figure; hist(spd); xlabel('speed')
        save( [pathname files(alluse(i)).dir '\' files(alluse(i)).passive3xPts],'spd','-append');
    end
    
    %%% get eye data from passive 3x
    if ~exist('eyes','var');
        eyes = get2pEyes([pathname files(alluse(i)).dir '\' files(alluse(i)).passive3xEyes],1,0.1);
        save([pathname files(alluse(i)).dir '\' files(alluse(i)).passive3xPts],'eyes','-append');
    end
    
    filt = ones(1,5); filt = filt/sum(filt);
    r = conv(eyes(:,3),filt,'same');
    figure
    plot(eyes); title('passive 3x eyes');
    
    %     figure
    %     hold on; plot(spd(5:end-5),r(5:end-5),'o');  plot(spd(5:end-5),r(5:end-5));
    
    figure
    plot(spd/max(spd)); hold on; plot((r-min(r))/(max(r)-min(r))); title('passive 3x'); legend('speed','eyes');
    %%% correlate pupil radius with continous activity traces for passive 3x
    d = corrcoef([dFdecon; r']');
    eyeCorrAll(cellrange) = d(1:cutoff,end);
    passive3xRadius{i} = r;
    
    
    %%% get speed and dF on each trial, for isi and stim intervals
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
    
    %%% calculate change in dF with stationary/moving (delta)
    %%% and correlation between dF and speed
    d = corrcoef([spont; double(sp_spont>250)]');
    spontCorr = d(1:end-1,end); %figure; hist(spontCorr,[-0.95:0.1:1]); title('spont corr')
    deltaSpont = mean(spont(:,sp_spont>250),2)-mean(spont(:,sp_spont<250),2);
    % figure; hist(deltaSpont,[-0.95:0.1:1]); title('delta spont')
    d = corrcoef([ev; double(sp_ev>250)]');
    evCorr = d(1:end-1,end); % figure; hist(evCorr,[-0.95:0.1:1]); title('evoked correlation')
    spontCorrAll(cellrange) = spontCorr(1:cutoff);
    evCorrAll(cellrange) = evCorr(1:cutoff);
    deltaSpontAll(cellrange) =deltaSpont(1:cutoff);
    
    
    
    n=n+cutoff;
    
    drawnow
end


close all

figure
hist(spontCorrAll,[-0.95:0.1:1]); title('spont correlation');
figure
hist(evCorrAll,[-0.95:0.1:1]); title('evoked correlation');
figure
hist(deltaSpontAll,[-0.95:0.1:1]); title('evoked correlation');


behavTimepts = -1:0.1:5;

%%% get rf locations for all cells
%%% flip data so that centered on preferred location (top vs bottom)
d1 = sqrt((xAll-46).^2 + (yAll-34).^2);
d2 = sqrt((xAll-78).^2 + (yAll-34).^2);
centeredTrialData = zeros(size(trialDataAll))+NaN;
centered3x = zeros(size(data3xAll))+NaN;
centered2sf = zeros(size(data2sfAll))+NaN;
for i = 1:size(centeredTrialData,1);
    if d1(i)<12
        centeredTrialData(i,:,:) = trialDataAll(i,:,:);
        centered3x(i,:,:) = data3xAll(i,:,:);
        centered2sf(i,:,:) = data2sfAll(i,:,:);
    elseif d2(i)<12
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

%%% get rid of extreme values
centeredTrialData(centeredTrialData>1)=1;
centered3x(centeredTrialData>1)=1;
centered2sf(centeredTrialData>1)=1;

%%% choose the ones within 12 deg of center
centered = (d1<12| d2<12)';

%%% choose data for clustering! This section currently chooses only
%%% corrects and specific timepoints
%%% centeredTrialData(cells,time,condition)
%%% conditions are 1-4=correct, 5-8 = incorrect; preferred h/v, then non-pref h/v
%%% get rid of orientation (i.e. invariant) by averaging over both
clear invariant  %%% average over correct pref (2 orientation) then correct non-pref
invariant(:,:,2) = mean(centeredTrialData(:,:,3:4),3);
invariant(:,:,1) = mean(centeredTrialData(:,:,1:2),3);


%%% epoch data has cells by timepoints by top/bottom
clear epochData %%% choose time ranges to go into clustering
epochData(:,1,:) = squeeze(mean(invariant(:,5:10,:),2));
epochData(:,2,:) = squeeze(mean(invariant(:,12:15,:),2));
epochData(:,3,:) = squeeze(mean(invariant(:,20:30,:),2));
%epochData(:,4,:) = squeeze(mean(invariant(:,50:60,:),2));

%%% reshape the epochData to be cells by measurement
%clustData = reshape(invariant(centered,:,:),sum(centered),size(invariant,2)*size(invariant,3));
clustData = reshape(epochData,size(epochData,1),size(epochData,2)*size(epochData,3));
clustData= clustData(:,[1 2 3 ]);  %%% choose only preferred (1-3) not non-preferred (3-6)
%%% as long has you have clustdata (cells, measurements) you can cluster!


%%% choose active cells based on std
figure
hist(std(clustData'),0.005:0.01:1);
active = (std(clustData')>0.02)';

%%% only use cells that are centered and have activity in clustering (don't cluster noise!!!)
clustData = clustData(centered & active,:);
allData = reshape(centeredTrialData(centered & active,:,:),sum(centered & active),size(centeredTrialData,2)*size(centeredTrialData,3));


% clustData = clustData(active,:);
% allData = allData(active,:);

figure
imagesc(clustData,[0 0.5]); drawnow

%%% dendrogram/cluster plot for all data
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

%%% calculation orientation invariant (again) but for both correct and incorrect
clear orientInvariant
orientInvariant(:,:,4) = mean(centeredTrialData(:,1:42,7:8),3);
orientInvariant(:,:,2) = mean(centeredTrialData(:,1:42,5:6),3);
orientInvariant(:,:,3) = mean(centeredTrialData(:,1:42,3:4),3);
orientInvariant(:,:,1) = mean(centeredTrialData(:,1:42,1:2),3);
invariantAll = reshape(orientInvariant,size(orientInvariant,1),size(orientInvariant,2)*size(orientInvariant,3));

%%% choose N clusters (usually 3)
clust= zeros(1,size(orientInvariant,1));
c= cluster(Z,'maxclust',3);  %%% set number of clusters here
figure
h = hist(c,1:max(c)); h= h/sum(h); bar(h); xlabel('cluster');
for i = 1:max(c);   %%% get ride of tiny clusters
    if h(i)<0.05; c(c==i)=0; end;
end

clust(centered & active) =c;

[sortClust ind] = sort(clust);

%%% concatenate all 8 trial types for display
allData = reshape(centeredTrialData,size(centeredTrialData,1),size(centeredTrialData,2)*size(centeredTrialData,3));


%%% sort data based on cluster indices
allData = allData(ind,:); sortCond = allCond(ind); sortActive = active(ind); sortCentered = centered(ind); sortSess=sess(ind);
figure
imagesc(allData,[0 0.5])

%%% put all data (including non resp) back into matrix
mdInd(sortClust==0) = 1:sum(sortClust==0);  % put all non-clustered into one group
for i = 1:max(clust);
    i
    sum(clust==i)
    if sum(clust==i)>0
        data = allData(sortClust==i,:);
        start = min(find(sortClust==i));
        tic; dist = pdist(imresize(data(:,1:end/4), [size(data,1),size(data,2)/8]),'correlation'); toc
        dist = dist+randi(10^9,size(dist))/10^8;  %%% jitter points a bit to avoid errors in mdscale , can't use rand function though
        %tic; [Y e] = mdscale(dist,1); toc  %%% mdscale to make smooth progression within each cluster
        %[y sortind] = sort(Y);
        sortind = 1:size(data,1);
        mdInd(sortClust==i) = sortind+start-1;
    end
end

%%% full dataset, sorted!
allData = allData(mdInd,:); sortCond = sortCond(mdInd); sortActive = sortActive(mdInd); sortCentered = sortCentered(mdInd); sortSess=sortSess(mdInd);
%allData(sortClust==0,:) =0;


%%% show all the data
figure
imagesc(allData(sortCentered' ,:),[0 0.5]); %%% fix
hold on; for j= 1:8, plot([j*length(behavTimepts) j*length(behavTimepts)]+1,[1 sum(sortCentered' )],'g'); end
title('all conds')



for cond = 1:2
    figure
    imagesc(allData(sortCentered' & sortCond==cond,:),[0 0.5]); %%% fix
    hold on; for j= 1:8, plot([j*length(behavTimepts) j*length(behavTimepts)]+1,[1 sum(sortCentered' & sortCond==cond)],'g'); end
    title(condLabel{cond})
end

%%% plot cell summary for each session (redundant with below, but colors each cluster independently)
for i = 1:max(sess);
%     load([pathname files(alluse(i)).dir '\' files(alluse(i)).behavPts],'greenframe');
%     figure
%     imagesc(greenframe,[0 1.2*prctile(greenframe(:),99)]); colormap gray;
%     title(sprintf('%s %s %s ',files(alluse(i)).subj,files(alluse(i)).expt,files(alluse(i)).task));
%     
%     figure
%     subplot(1,3,1:2)
%     imagesc(allData(sortCentered' & sortSess==i,:),[0 0.5]);
%     hold on; for j= 1:8, plot([j*length(behavTimepts) j*length(behavTimepts)]+1,[1 sum(sortCentered' & sortSess==i)],'g'); end
%     
%     title(sprintf('%s %s %s total=%d gratings=%d exposures=%d',files(alluse(i)).subj,files(alluse(i)).expt,files(alluse(i)).task,files(alluse(i)).totalDays,files(alluse(i)).totalSinceGratings,files(alluse(i)).learningDay));
%     
%     subplot(1,3,3); hold on
%     %     plot(yAll(sess==i & ~active'),xAll(sess==i & ~active'),'k.');
%     %     plot(yAll(sess==i & clust==1 ),xAll(sess==i & clust==1),'b.');
%     %     plot(yAll(sess==i& clust==2),xAll(sess==i & clust==2),'r.');
%     %     plot(yAll(sess==i& clust==3),xAll(sess==i & clust ==3),'g.');
%      
%     plot(yAll(sess==i & ~centered'),xAll(sess==i & ~centered'),'k.');
%     plot(yAll(sess==i & centered' ),xAll(sess==i & centered'),'g.');
%     
%     axis equal;  axis([0 72 0 128]); hold on
%     circle(34,0.625*128-2,12);circle(34,0.375*128-2,12); set(gca,'Xtick',[]); set(gca,'Ytick',[]);
end

%%% where were each of the clusters? (plot them all)
figure
for c = 1:4
    subplot(1,4,c); hold on
    if c<=3
        plot(yAll(clust==c ),xAll(clust==c),'b.');
        
    else
        plot(yAll( ~active'),xAll(~active'),'k.');
    end
    
    axis equal;  axis([0 72 0 128]); hold on
    circle(36,0.66*128,17.5);circle(36,0.33*128,17.5);  set(gca,'Xtick',[]); set(gca,'Ytick',[]);
    
    for x = 1:128;
        for y = 1:72;
            these = xAll>x-1 & xAll<=x+1 & yAll>y-1 & yAll<=y+1;
            num(x,y) = sum(these); num(num<4)=0;
            if c<=3
                density(x,y,c) = sum(these & clust==c)/num(x,y);
            else
                density(x,y,c) = sum(these & ~active')/num(x,y);
            end
        end
    end
end

density(~isfinite(density))=-0.1;

figure
imagesc(num);  axis equal;  axis([0 72 0 128]); axis xy; hold on;  circle(34,0.625*128-2,12);circle(34,0.375*128-2,12);

%%% where are cells located? plot by density
figure
for i = 1:4
    subplot(1,4,i);
    imagesc(density(:,:,i));
    axis equal;  axis([0 72 0 128]); hold on;  axis xy; circle(34,0.625*128-2,12);circle(34,0.375*128-2,12);
end

c = clust;

%%% average across all conditions (trained, naive, etc)
trialType = {'correct pref','error pref','correct non-pref','error non-pref'};
figure
for t = 1:4
    subplot(2,2,t);
    for i = 1:max(c)
        d =nanmean(invariantAll(clust==i  ,:),1); plot(0.1*(0:41),(d((t-1)*42 + (1:42))-mean(d(6:10))));hold on; ylim([ -0.2 0.3]); xlim([0 4.15])
    end
    title([trialType{t} ]); xlabel('secs'); ylabel('response'); % set(gca,'Ytick',-0.25:0.25:0.75);
end

legend;
set(gcf,'Name','all conditions non-weighted');


%%% weighted mean (by fraction of cells)
clear clustBehav clustBehavErr
trialType = {'correct pref','error pref','correct non-pref','error non-pref'};
for cond = 1:4
    figure
    for t = 1:4 %%%  top/bottom, correct/incorrect
        subplot(2,2,t);
        for i = 1:max(c)
            n = sum(clust==i & allCond==cond)/sum(allCond==cond)
            d =nanmean(invariantAll(clust==i & allCond==cond ,:),1); plot(0.1*(0:41),n*(d((t-1)*42 + (1:42))-mean(d(6:10))));hold on; ylim([ -0.025 0.065]); xlim([0 4.15])
            
            clustBehav(i,t,cond,:) = n*(d((t-1)*42 + (1:42))-mean(d(6:10)));
            clustBehavErr(i,t,cond,:) = n*nanstd(invariantAll(clust==i & allCond==cond ,(t-1)*42 + (1:42)),[],1)/sqrt(sum(clust==i & allCond==cond));
        end
        title([trialType{t} ' weighted']); xlabel('secs'); ylabel('weighted response'); set(gca,'Ytick',-0.025:0.025:0.075);
    end
    
    legend;
    set(gcf,'Name',condLabel{cond});
end

%%% weighted mean (by fraction of cells) by session, and session plots
clear clustBehavS clustBehavErrS
trialType = {'correct pref','error pref','correct non-pref','error non-pref'};

close all

psfile = 'temp.ps';
if exist(psfile,'file')==2;delete(psfile);end

%%% plot data for clusters in each session, and neural responses
%%% generates the main figures for pdf
for s= 1:max(sess)
    s
    if strcmp(files(alluse(s)).task,'GTS'), sessCond(s) = gts; end;
    if strcmp(files(alluse(s)).task,'Naive') & files(alluse(s)).learningDay<8, sessCond(s)  = naive; end;
    if strcmp(files(alluse(s)).task,'Naive') & files(alluse(s)).learningDay>=8,sessCond(s)  = naiveTrained; end;
    if strcmp(files(alluse(s)).task,'HvV'), sessCond(s)  = hvv; end;
    if strcmp(files(alluse(s)).task, 'RandReward'), sessCond(s)  = rand; end;
    sessSubj{s} = files(alluse(s)).subj;

    %%% mean weighted timecourse of clusters
    figure
    set(gcf,'Name',sprintf('%s %s %s',files(alluse(s)).subj, files(alluse(s)).expt, condLabel{sessCond(s)}));
    for t = 1:4 %%%  top/bottom, correct/incorrect
        subplot(2,2,t);
        for i = 1:max(clust)
            n = sum(clust==i & sess==s)/sum(sess==s);
            d =nanmean(invariantAll(clust==i & sess==s ,:),1); plot(0.1*(0:41),n*(d((t-1)*42 + (1:42))-mean(d(6:10))));hold on; ylim([ -0.025 0.065]); xlim([0 4.15])
                   
            %%%mean activity for session, and each cluster (unweighted)
            %%% s = session, t = trial type (top/bottom,
            %%% correct/incorrect), clust = cluster
    ClustBehavTrialData(s,t,i,:) = d((t-1)*42 + (1:42))-mean(d(6:10));
    ClustBehavTrialDataErr(s,t,i,:) = nanstd(invariantAll(clust==i & sess==s ,(t-1)*42 + (1:42)),[],1)/sqrt(sum(clust==i & sess==s));
    
            %%% (weighted)
            clustBehavS(s,t,i,:) = n*(d((t-1)*42 + (1:42))-mean(d(6:10)));
            clustBehavErrS(s,t,i,:) = n*nanstd(invariantAll(clust==i & sess==s ,(t-1)*42 + (1:42)),[],1)/sqrt(sum(clust==i & sess==s));
        end
        title([trialType{t} ' weighted']); xlabel('secs'); ylabel('weighted response'); set(gca,'Ytick',-0.025:0.025:0.075);
    end
    legend;
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

    std(behavTrialData(1:cutoff,alluse(i),:));
    
    
    %%% performance (correct, stopping, etc)
    figure; plot(respRateAll{s}/2,'g'); hold on; plot(correctRateAll{s},'b');plot(stopRateAll{s}/10,'r');ylim([0 1]); title([files(alluse(s)).subj ' ' files(alluse(s)).task]);legend('response','correct','stop')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%% total fluorescence timecourse for all cells
    figure
    imagesc(behavDfAll{s},[0 0.5]);
    title(sprintf('cutoff = %d',sum(sess==s)));   
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    %%% raw fluorescence image
    load([pathname files(alluse(s)).dir '\' files(alluse(s)).behavPts],'greenframe');
    figure
    imagesc(greenframe,[0 1.2*prctile(greenframe(:),99)]); colormap gray;
    title(sprintf('%s %s %s depth %d',files(alluse(s)).subj,files(alluse(s)).expt,files(alluse(s)).task,files(alluse(s)).depth));
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %%%plot pixelwise activation on top of this fig? average activation at
    %%%certain timepoint during behavior
    
    %%% check for dependencies in behavior (bias, correction trial, etc)
    loc = locationAll{s}; targ = targAll{s}; correct = correctAll{s};
    resp = sign((correct-0.5).*targ);
    topleft = sum(loc>0 & resp>0)/sum(loc>0);
    topright = sum(loc>0 & resp<0)/sum(loc>0);
    bottomleft = sum(loc<0 & resp>0)/sum(loc<0);
    bottomright = sum(loc<0 & resp<0)/sum(loc<0);
    
    thisResp = resp(2:end); resp = resp(1:end-1); correct = correct(1:end-1); loc = loc(2:end);
    results = [mean(thisResp(loc>0 & resp>0 & correct>0)) mean(thisResp(loc>0 & resp<0 & correct>0)) mean(thisResp(loc>0 & resp>0 & correct==0)) mean(thisResp(loc>0 & resp<0 & correct==0)); ...
                mean(thisResp(loc<0 & resp<0 & correct>0)) mean(thisResp(loc<0 & resp>0 & correct>0)) mean(thisResp(loc<0 & resp<0 & correct==0)) mean(thisResp(loc<0 & resp>0 & correct==0))];
            
            figure
            bar(results)
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
    figure
    bar([topleft topright; bottomleft bottomright]);ylim([0 1]); set(gca,'Xticklabel',{'top?','bottom?'});

    
    %%% sorted responses
    figure
    subplot(1,3,1:2)
    imagesc(allData(sortCentered' & sortSess==s,:),[0 0.5]);
    hold on; for j= 1:8, plot([j*length(behavTimepts) j*length(behavTimepts)]+1,[1 sum(sortCentered' & sortSess==s)],'g'); end
    
    title(sprintf('%s %s %s total=%d gratings=%d exposures=%d',files(alluse(s)).subj,files(alluse(s)).expt,files(alluse(s)).task,files(alluse(s)).totalDays,files(alluse(s)).totalSinceGratings,files(alluse(s)).learningDay));
    
    %%% location of cells
    subplot(1,3,3); hold on
    %     plot(yAll(sess==i & ~active'),xAll(sess==i & ~active'),'k.');
    %     plot(yAll(sess==i & clust==1 ),xAll(sess==i & clust==1),'b.');
    %     plot(yAll(sess==i& clust==2),xAll(sess==i & clust==2),'r.');
    %     plot(yAll(sess==i& clust==3),xAll(sess==i & clust ==3),'g.');
    
    plot(yAll(sess==s & ~centered'),xAll(sess==s & ~centered'),'k.');
    plot(yAll(sess==s & centered' ),xAll(sess==s & centered'),'g.');
    
    axis equal;  axis([0 72 0 128]); hold on
    circle(34,0.625*128-2,12);circle(34,0.375*128-2,12); set(gca,'Xtick',[]); set(gca,'Ytick',[]);
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    close all
end

%keyboard

[f p] = uiputfile('*.pdf');
newpdfFile = fullfile(p,f)
try
    dos(['ps2pdf ' 'temp.ps "' newpdfFile '"'] )
    
catch
    display('couldnt generate pdf');
end

close all

subjs = unique(sessSubj)


%%% non-weighted (average of all units in this cluster)
trialType = {'correct pref','error pref','correct non-pref','error non-pref'};

for cond = 1:4
    figure
    for t = 1:4
        subplot(2,2,t);
        for i = 1:max(c)
            d =nanmean(invariantAll(clust==i & allCond==cond ,:),1); plot(d((t-1)*42 + (1:42))-min(d));hold on; ylim([ 0 0.3]); xlim([0.5 42.5])
        end
        title(trialType{t});
    end
    
    legend;
    set(gcf,'Name',condLabel{cond});
end
%% Joe 6/12/17
%%%mean activity for session, and each cluster (unweighted)
            %%% s = session, t = trial type (top/bottom,
            %%% correct/incorrect), cond = behavioral condition, timepoints 
            %%%c/i = cluster
for ss = 1:length(sessionDate)
     figure
    for t = 1:4
        subplot(2,2,t);        
        for i = 1:max(clust)
            d =nanmean(invariantAll(sess==ss & clust==i,:),1); 
            e =nanstd(invariantAll(sess==ss & clust==i,:),[],1)/sqrt(sum(sess==ss & clust==i)); 
          SessClustData(ss,t,i,:) =  d((t-1)*42 + (1:42))-mean(d(6:10));
          SessClustErr(ss,t,i,:) = e((t-1)*42 + (1:42));
            %plot(d((t-1)*42 + (1:42))-mean(d(6:10)));hold on; ylim([ 0 0.3]); xlim([0.5 42.5])
       errorbar(1:42,(d((t-1)*42 + (1:42))-mean(d(6:10))),e((t-1)*42 + (1:42)));hold on; ylim([-0.15 0.3]); xlim([0.5 42.5])
                                   
      
        end     
        title(trialType{t});
    legend;
    set(gcf,'Name',[sessSubj{ss} sessionDate{ss}]);
    end;
    drawnow
end;

  %%%weighted by number of cells get fraction for each session

for ss = 1:length(sessionDate)
     figure
    for t = 1:4
        subplot(2,2,t);        
        for i = 1:max(clust)
       n = sum(clust==i & sess==ss)/sum(sess==ss);
        d =nanmean(invariantAll(clust==i & sess==ss ,:),1);
            e =nanstd(invariantAll(sess==ss & clust==i,:),[],1)/sqrt(sum(sess==ss & clust==i)); 
          WeightedSessClustData(ss,t,i,:) =  n*(d((t-1)*42 + (1:42))-mean(d(6:10)));
          WeightedSessClustErr(ss,t,i,:) = n*(e((t-1)*42 + (1:42)));
          SessClustFraction(ss,i) = sum(clust==i & sess==ss)/sum(sess==ss);
        
       errorbar(1:42,n*(d((t-1)*42 + (1:42))-mean(d(6:10))),n*(e((t-1)*42 + (1:42))));hold on; ylim([-0.05 0.1]); xlim([0.5 42.5])
 end     
        title(trialType{t});
    legend;
    set(gcf,'Name',[ 'weighted response_' sessSubj{ss} sessionDate{ss}]);
    end;
    drawnow
end;

% if exist('psfilename','var')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfilename,'-append');
% end

% %%% sort by session condition
% gts = 1; naive=2; naiveTrained=3;  rand =4; hvv = 5;
% condLabel{1} = ' GTS'; condLabel{2}=' naive'; condLabel{3} = ' rand'; condLabel{4} = ' HvV'; condLabel{5}=' naive trained'; 

%%% mean weighted timecourse of clusters by training condition

for j = 1:5 %%%loop through training conditions 
  figure
    set(gcf,'Name',sprintf('session averaged response %s', condLabel{j}));
    for t = 1:4 %%%  top/bottom, correct/incorrect
        subplot(2,2,t);
    for i = 1:max(clust) 
        clear d
            d =squeeze(nanmean(WeightedSessClustData(sessCond==j,t,i,:),1)); 
         %redo this (e) based on animal
            e = squeeze(nanstd(WeightedSessClustData(sessCond==j,t,i,:),[],1)/sqrt(sum(sessCond==j))); 
            fraction(j,i) = mean(SessClustFraction(sessCond==j,i));
            
          ClustSessData(i,t,j,:) =  d(1:42)-mean(d(6:10));
          ClustSessErr(i,t,j,:) = e(1:42);
             %plot(0.1*(0:41),(d(1:42))-mean(d(6:10)));hold on; ylim([ -0.025 0.065]); xlim([0 4.15])
            errorbar(0.1*(0:41),(d(1:42)-mean(d(6:10))),e(1:42));hold on; ylim([ -0.025 0.065]); xlim([0 4.15])       


        title([trialType{t} ' weighted']); xlabel('secs'); ylabel('weighted response'); set(gca,'Ytick',-0.025:0.025:0.075);
    end;
    legend;
    drawnow;
    %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    end;
end;


%%%%%mean weighted timecourse of each training condition for each cluster
for i = 1:max(clust) %%%loop through clusters 
  figure
    set(gcf,'Name',sprintf('cluster %d session averaged response', i));
    for t = 1:4 %%%  top/bottom, correct/incorrect
        subplot(2,2,t);
    for j = 1:3 %1:5  %for each training condition 
        clear d
            d =squeeze(nanmean(WeightedSessClustData(sessCond==j,t,i,:),1)); 
         %redo this (e) based on animal
            e = squeeze(nanstd(WeightedSessClustData(sessCond==j,t,i,:),[],1)/sqrt(sum(sessCond==j))); 
            fraction(j,i) = mean(SessClustFraction(sessCond==j,i));
            
          ClustSessData(i,t,j,:) =  d(1:42)-mean(d(6:10));
          ClustSessErr(i,t,j,:) = e(1:42);
             %plot(0.1*(0:41),(d(1:42))-mean(d(6:10)));hold on; ylim([ -0.025 0.065]); xlim([0 4.15])
            errorbar(0.1*(0:41),(d(1:42)-mean(d(6:10))),e(1:42));hold on; ylim([ -0.025 0.065]); xlim([0 4.15])       

    
        title([trialType{t} ' weighted']); xlabel('secs'); ylabel('weighted response'); set(gca,'Ytick',-0.025:0.025:0.075);
    end;
   
    drawnow;
    %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    end;
     %legend(condLabel{1},condLabel{2},condLabel{3},condLabel{4},condLabel{5},'Location','Best');
    legend(condLabel{1},condLabel{2},condLabel{3});
end;


%%%%%%passives by session

%%3x
  orientInvariant3x(:,:,4) = mean(centered3x(:,:,[10 12]),3);
orientInvariant3x(:,:,3) = mean(centered3x(:,:,[9 11]),3);
orientInvariant3x(:,:,2) = mean(centered3x(:,:,[2 4]),3);
orientInvariant3x(:,:,1) = mean(centered3x(:,:,[1 3]),3);
invariantAll3x = reshape(orientInvariant3x,size(orientInvariant3x,1),size(orientInvariant3x,2)*size(orientInvariant3x,3));

  %%%3x response weighted by number of cells get fraction for each session 
  trialType = {'pref hv','pref oblique','non-pref hv','non-prev oblique'};
for ss = 1:length(sessionDate)
     figure
    for t = 1:4
        subplot(2,2,t);        
        for i = 1:max(clust)
       n = sum(clust==i & sess==ss)/sum(sess==ss);
        d =nanmean(invariantAll3x(clust==i & sess==ss ,:),1);
            e =nanstd(invariantAll3x(sess==ss & clust==i,:),[],1)/sqrt(sum(sess==ss & clust==i)); 
          WeightedSessClust3xData(ss,t,i,:) =  n*(d((t-1)*28 + (1:28))-mean(d(6:10)));
          WeightedSessClust3xErr(ss,t,i,:) = n*(e((t-1)*28 + (1:28)));
%           SessClustFraction3x(ss,i) = sum(clust==i & sess==ss)/sum(sess==ss);  %same as behav
        
       errorbar(1:28,n*(d((t-1)*28 + (1:28))-mean(d(6:10))),n*(e((t-1)*28 + (1:28))));hold on; ylim([-0.05 0.1]); xlim([0.5 41.5])
 end     
        title(trialType{t});
    legend;
    set(gcf,'Name',[ '3x weighted response_' sessSubj{ss} sessionDate{ss}]);
    end;
    drawnow
end;
%%% mean weighted timecourse of clusters by training condition

for j = 1:5 %%%loop through training conditions 
  figure
    set(gcf,'Name',sprintf('3x session averaged response %s', condLabel{j}));
    for t = 1:4 %%%  top/bottom, correct/incorrect
        subplot(2,2,t);
    for i = 1:max(clust) 
        clear d
            d =squeeze(nanmean(WeightedSessClust3xData(sessCond==j,t,i,:),1)); 
            e = squeeze(nanstd(WeightedSessClust3xData(sessCond==j,t,i,:),[],1)/sqrt(sum(sessCond==j))); 
            fraction(j,i) = mean(SessClustFraction(sessCond==j,i));
            
          clust3xSess(i,t,j,:) =  d(1:28)-mean(d(6:10));
          clust3xErrSess(i,t,j,:) = e(1:28);
            errorbar(0.1*(0:27),(d(1:28)-mean(d(6:10))),e(1:28));hold on; ylim([ -0.025 0.065]); xlim([0 4.15])       


        title([trialType{t} '3x weighted']); xlabel('secs'); ylabel('weighted response'); set(gca,'Ytick',-0.025:0.025:0.075);
    end;
    legend;
    drawnow;
    %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    end;
end;
%%%%%%%%2sf
orientInvariant2sf(:,:,4) = mean(centered2sf(:,:,[6 8]),3);
orientInvariant2sf(:,:,3) = mean(centered2sf(:,:,[5 7]),3);
orientInvariant2sf(:,:,2) = mean(centered2sf(:,:,[2 4]),3);
orientInvariant2sf(:,:,1) = mean(centered2sf(:,:,[1 3]),3);
invariantAll2sf = reshape(orientInvariant2sf,size(orientInvariant2sf,1),size(orientInvariant2sf,2)*size(orientInvariant2sf,3));
  
%%%2sf response weighted by number of cells get fraction for each session  
  trialType = {'pref ','pref hi sf','non pref','non pref hi sf'};  
for ss = 1:length(sessionDate)
     figure
    for t = 1:4
        subplot(2,2,t);        
        for i = 1:max(clust)
       n = sum(clust==i & sess==ss)/sum(sess==ss);
        d =nanmean(invariantAll2sf(clust==i & sess==ss ,:),1);
            e =nanstd(invariantAll2sf(sess==ss & clust==i,:),[],1)/sqrt(sum(sess==ss & clust==i)); 
          WeightedSessClust2sfData(ss,t,i,:) =   n*(d((t-1)*39 + (1:39))-mean(d(6:10)));
          WeightedSessClust2sfErr(ss,t,i,:) = n*(e((t-1)*39 + (1:39)));
%           SessClustFraction2sf(ss,i) = sum(clust==i &sess==ss)/sum(sess==ss);  %same as behav
        
       errorbar(1:39,n*(d((t-1)*39 + (1:39))-mean(d(6:10))),n*(e((t-1)*39 + (1:39))));hold on; ylim([-0.05 0.1]); xlim([0.5 41.5])
 end     
        title(trialType{t});
    legend;
    set(gcf,'Name',[ '2sf weighted response_' sessSubj{ss} sessionDate{ss}]);
    end;
    drawnow
end;
%%% mean weighted timecourse of clusters by training condition

for j = 1:5 %%%loop through training conditions 
  figure
    set(gcf,'Name',sprintf('2sf session averaged response %s', condLabel{j}));
    for t = 1:4 %%%  top/bottom, correct/incorrect
        subplot(2,2,t);
    for i = 1:max(clust) 
        clear d
            d =squeeze(nanmean(WeightedSessClust2sfData(sessCond==j,t,i,:),1)); 
            e = squeeze(nanstd(WeightedSessClust2sfData(sessCond==j,t,i,:),[],1)/sqrt(sum(sessCond==j))); 
            fraction(j,i) = mean(SessClustFraction(sessCond==j,i));   %calculate mean accross groups
            
          clust2sfSess(i,t,j,:) =  d(1:39)-mean(d(6:10));
          clust2sfErrSess(i,t,j,:) = e(1:39);
            errorbar(0.1*(0:38),(d(1:39)-mean(d(6:10))),e(1:39));hold on; ylim([ -0.025 0.065]); xlim([0 4.15])       


        title([trialType{t} '2sf weighted']); xlabel('secs'); ylabel('weighted response'); set(gca,'Ytick',-0.025:0.025:0.075);
    end;
    legend;
    drawnow;
    %if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    end;
end;

%%%ClustSessData(clust,stimtype, training cond, t)

%%% bar graphs of changes
%%% naive vs learned

    clear respSess
    clear respErrSess
for c =1:3
    if c==1
        range = 13:14;
    else
        range = 19:20;
    end
    respSess(c,:,:,1) = mean(ClustSessData(c,:,:,range),4);
    respErrSess(c,:,:,1) = mean(ClustSessErr(c,:,:,range),4);
    respSess(c,:,:,2) = mean(clust3xSess(c,:,:,range-1),4);
    respErrSess(c,:,:,2) = mean(clust3xErrSess(c,:,:,range-1),4);
    respSess(c,:,:,3) = mean(clust2sfSess(c,:,:,range-1),4);
    respErrSess(c,:,:,3) = mean(clust2sfErrSess(c,:,:,range-1),4);
end
figure
for c = 1:3
    subplot(2,2,c)
    plot(squeeze(ClustSessData(c,1,1:3,:))'); xlim([ 1 30])
end


figure; set(gcf,'Name','cardinal')
for c = 1:3
    subplot(2,2,c)
    plot(squeeze(clust3xSess(c,1,1:2,:))'); xlim([ 1 30]);ylim([-0.002 0.05])
end

figure
for c = 1:3
    subplot(2,2,c)
    plot(squeeze(clust2sfSess(c,1,1:2,:))'); xlim([ 1 30])
end

figure; set(gcf,'Name','oblique');
for c = 1:3
    subplot(2,2,c)
    plot(squeeze(clust3xSess(c,2,1:2,:))'); xlim([ 1 30]); ylim([-0.002 0.05])
end

figure
for c = 1:3
    subplot(2,2,c)
    plot(squeeze(clust2sfSess(c,2,1:2,:))'); xlim([ 1 30])
end


%%% resp(clust,stim, training cond, session)
%%%w/o hvv
figure
barweb(squeeze(respSess(:,1,[2 1 3],1)), squeeze(respErrSess(:,1,[2 1 3],1))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('naive','gts','rand'); ylabel('weighted response'); title('behavior - preferred')

figure
barweb(squeeze(respSess(:,1,[2 1 3],2)), squeeze(respErrSess(:,1,[2 1 3],2))); ylim([-0.01 0.04]); set(gca,'Ytick',-0.01:0.01:0.04);
legend('naive','gts','rand'); ylabel('weighted response'); title('passive 3x - cardinal')

figure
barweb(squeeze(respSess(:,2,[2 1 3],2)), squeeze(respErrSess(:,2,[2 1 3],2))); ylim([-0.01 0.04]); set(gca,'Ytick',-0.01:0.01:0.04);
legend('naive','gts','rand'); ylabel('weighted response'); title('passive 3x - oblique')

figure
barweb(squeeze(respSess(:,1,2,[1 2])), squeeze(respErrSess(:,1,1,[1 3]))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('task','passive 3x'); ylabel('weighted response'); title('active vs passive naive')

figure
barweb(squeeze(respSess(:,1,1,[1 2])), squeeze(respErrSess(:,1,1,[1 3]))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('task','passive 3x'); ylabel('weighted response'); title('active vs passive gts');

figure
barweb(squeeze(respSess(:,1,3,[1 2])), squeeze(respErrSess(:,1,1,[1 3]))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('task','passive 3x'); ylabel('weighted response'); title('active vs passive rand');


%%%w/ hvv
figure
barweb(squeeze(respSess(:,1,[2 1 3 4],1)), squeeze(respErrSess(:,1,[2 1 3 4],1))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('naive','gts','rand','hvv'); ylabel('weighted response'); title('behavior - preferred')

figure
barweb(squeeze(respSess(:,1,[2 1 3 4],2)), squeeze(respErrSess(:,1,[2 1 3 4],2))); ylim([-0.01 0.04]); set(gca,'Ytick',-0.01:0.01:0.04);
legend('naive','gts','rand', 'hvv'); ylabel('weighted response'); title('passive 3x - cardinal')

figure
barweb(squeeze(respSess(:,2,[2 1 3 4],2)), squeeze(respErrSess(:,2,[2 1 3 4],2))); ylim([-0.01 0.04]); set(gca,'Ytick',-0.01:0.01:0.04);
legend('naive','gts','rand', 'hvv'); ylabel('weighted response'); title('passive 3x - oblique')

figure
barweb(squeeze(respSess(:,1,2,[1 2])), squeeze(respErrSess(:,1,1,[1 3]))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('task','passive 3x'); ylabel('weighted response'); title('active vs passive naive')

figure
barweb(squeeze(respSess(:,1,1,[1 2])), squeeze(respErrSess(:,1,1,[1 3]))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('task','passive 3x'); ylabel('weighted response'); title('active vs passive gts');

figure
barweb(squeeze(respSess(:,1,3,[1 2])), squeeze(respErrSess(:,1,1,[1 3]))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('task','passive 3x'); ylabel('weighted response'); title('active vs passive rand');

figure
barweb(squeeze(respSess(:,1,4,[1 2])), squeeze(respErrSess(:,1,1,[1 3]))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('task','passive 3x'); ylabel('weighted response'); title('active vs passive hvv');

%%
%%%%%%%%%%%%%passive analysis for all cells, not by session
% trialType = {'pref hv','pref oblique','non-pref hv','non-prev oblique'};
% for cond = 1:2
%     figure
%     for t = 1:4
%         subplot(2,2,t);
%         for i = 1:max(c)
%             d =mean(invariantAll3x(clust==i & allCond==cond ,:),1); plot(d((t-1)*29 + (1:29))-min(d));hold on; ylim([ 0 0.3]); xlim([0.5 42.5])
%         end
%         title(trialType{t});
%     end
%
%     legend;
%     set(gcf,'Name',condLabel{cond});
% end

trialType = {'pref hv','pref oblique','non-pref hv','non-prev oblique'};
for cond = 1:4
    figure
    for t = 1:4
        subplot(2,2,t);
        for i = 1:max(c)
            n = sum(clust==i & allCond==cond)/sum(allCond==cond)
            d =nanmean(invariantAll3x(clust==i & allCond==cond ,:),1); plot(0.1*(0:28),n*(d((t-1)*29 + (1:29))-mean(d(6:10))));hold on; ylim([ -0.025 0.065]); xlim([0 4.15])
            clust3x(i,t,cond,:) = n*(d((t-1)*28 + (1:28))-mean(d(6:10)));
            clust3xErr(i,t,cond,:) = n*nanstd(invariantAll3x(clust==i & allCond==cond ,(t-1)*28 + (1:28)),[],1)/sqrt(sum(clust==i & allCond==cond));
        end
        title([trialType{t} ' weighted']); xlabel('secs'); ylabel('weighted response'); set(gca,'Ytick',-0.025:0.025:0.075);
    end
    
    legend;
    set(gcf,'Name',condLabel{cond});
end




% trialType = {'pref ','pref hi sf','non pref','non pref hi sf'};
% for cond = 1:2
%     figure
%     for t = 1:4
%         subplot(2,2,t);
%         for i = 1:max(c)
%             d =mean(invariantAll2sf(clust==i & allCond==cond,:),1); plot(d((t-1)*39 + (1:39))-min(d));hold on; ylim([ 0 0.3]); xlim([0.5 42.5])
%         end
%         title(trialType{t});
%     end
%
%     legend;
%     set(gcf,'Name',condLabel{cond});
% end

trialType = {'pref ','pref hi sf','non pref','non pref hi sf'};
for cond = 1:4
    figure
    for t = 1:4
        subplot(2,2,t);
        for i = 1:max(c)
            n = sum(clust==i & allCond==cond)/sum(allCond==cond)
            d =nanmean(invariantAll2sf(clust==i & allCond==cond ,:),1); plot(0.1*(0:38),n*(d((t-1)*39 + (1:39))-mean(d(6:10))));hold on; ylim([ -0.025 0.065]); xlim([0 4.15])
            
            clust2sf(i,t,cond,:) = n*(d((t-1)*39 + (1:39))-mean(d(6:10)));
            clust2sfErr(i,t,cond,:) = n*nanstd(invariantAll2sf(clust==i & allCond==cond ,(t-1)*39 + (1:39)),[],1)/sqrt(sum(clust==i & allCond==cond));
            
        end
        title([trialType{t} ' weighted']); xlabel('secs'); ylabel('weighted response'); set(gca,'Ytick',-0.025:0.025:0.075);
    end
    
    legend;
    set(gcf,'Name',condLabel{cond});
end


%%%clustBehav(clust,stimtype, training cond, t)

%%% bar graphs of changes
%%% naive vs learned
    clear resp
    clear respErr

for c =1:3
    if c==1
        range = 13:14
    else
        range = 19:20
    end

    resp(c,:,:,1) = mean(clustBehav(c,:,:,range),4);
    respErr(c,:,:,1) = mean(clustBehavErr(c,:,:,range),4);
    resp(c,:,:,2) = mean(clust3x(c,:,:,range-1),4);
    respErr(c,:,:,2) = mean(clust3xErr(c,:,:,range-1),4);
    resp(c,:,:,3) = mean(clust2sf(c,:,:,range-1),4);
    respErr(c,:,:,3) = mean(clust2sfErr(c,:,:,range-1),4);
end

figure
for c = 1:3
    subplot(2,2,c)
    plot(squeeze(clustBehav(c,1,1:2,:))'); xlim([ 1 30])
end

figure; set(gcf,'Name','cardinal')
for c = 1:3
    subplot(2,2,c)
    plot(squeeze(clust3x(c,1,1:2,:))'); xlim([ 1 30]);ylim([-0.002 0.05])
end

figure
for c = 1:3
    subplot(2,2,c)
    plot(squeeze(clust2sf(c,1,1:2,:))'); xlim([ 1 30])
end

figure; set(gcf,'Name','oblique');
for c = 1:3
    subplot(2,2,c)
    plot(squeeze(clust3x(c,2,1:2,:))'); xlim([ 1 30]); ylim([-0.002 0.05])
end

figure
for c = 1:3
    subplot(2,2,c)
    plot(squeeze(clust2sf(c,2,1:2,:))'); xlim([ 1 30])
end




%%% resp(clust,stim, training cond, session)

figure
barweb(squeeze(resp(:,1,[2 1],1)), squeeze(respErr(:,1,[2 1],1))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('naive','trained'); ylabel('weighted response'); title('behavior - preferred')

figure
barweb(squeeze(resp(:,1,[2 1],2)), squeeze(respErr(:,1,[2 1],2))); ylim([-0.01 0.04]); set(gca,'Ytick',-0.01:0.01:0.04);
legend('naive','trained'); ylabel('weighted response'); title('passive 3x - cardinal')

figure
barweb(squeeze(resp(:,2,[2 1],2)), squeeze(respErr(:,2,[2 1],2))); ylim([-0.01 0.04]); set(gca,'Ytick',-0.01:0.01:0.04);
legend('naive','trained'); ylabel('weighted response'); title('passive 3x - oblique')

figure
barweb(squeeze(resp(:,1,2,[1 2])), squeeze(respErr(:,1,1,[1 3]))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('task','passive 3x'); ylabel('weighted response'); title('active vs passive naive')

figure
barweb(squeeze(resp(:,1,1,[1 2])), squeeze(respErr(:,1,1,[1 3]))); ylim([-0.025 0.075]); set(gca,'Ytick',-0.025:0.025:0.075);
legend('task','passive 3x'); ylabel('weighted response'); title('active vs passive trained');

%%% plot modulation by running

for i= 1:max(c);
    figure
    [n b] =hist(deltaSpontAll(clust==i),[-0.5:0.1:0.5]); bar(b,n/sum(n)); title(sprintf('cluster %d',i)); xlim([-0.55 0.55]); ylim([0 0.85]); ylabel('fraction'); xlabel('running modulation (spont)');
    set(gca,'Xtick',-0.5:0.25:0.5); set(gca,'Ytick',0:0.2:0.8); set(gca,'Fontsize',16);
    spontMod(i) = nanmean(abs(deltaSpontAll(clust==i))); spontModErr(i) = nanstd(abs(deltaSpontAll(clust==i)))/sqrt(sum(clust==i));
end
figure
bar(spontMod); hold on; errorbar(1:3,spontMod,spontModErr,'k.','markersize',8,'Linewidth',2);
ylabel('mean absolute modulation'); set(gca,'FontSize',16); ylim([0 0.125]); set(gca,'Xtick',0:0.025:0.125);

osifig = figure;
%%% calculate response parameters (sustained, transient, OSI, running modulation) for each cluster; put each graph into one subpanel
for i = 1:max(clust)
    clustData = allData(sortClust==i ,:);
    clear transResp sustResp
    
    %%% calculate transient and sustained responses (relative to baseline)
    transResp(:,1) = mean(clustData(:,13:14),2) - mean(clustData(:,1:10),2);
    transResp(:,2) = mean(clustData(:,74:75),2) - mean(clustData(:,62:71),2);
    sustResp(:,1) = mean(clustData(:,20:40),2) - mean(clustData(:,1:10),2);
    sustResp(:,2) = mean(clustData(:,81:101),2) - mean(clustData(:,62:71),2);
    
    sprintf('cluster %d trans %0.3f sust %0.3f',i,mean(transResp(:,1)),mean(sustResp(:,1)))
    sprintf('cluster %d trans %0.3f sust %0.3f',i,mean(transResp(:,2)),mean(sustResp(:,2)))
    
    figure
    subplot(2,2,1);
    hist(transResp(:,1),-1:0.1:1); title([' trans resp ' num2str(i)]);  xlim([-1 1])
    
    subplot(2,2,2);
    hist(sustResp(:,1),-1:0.1:1); title([ 'sust resp ' num2str(i)]); xlim([-1 1])
    
    if i==3
        transResp = -transResp; sustResp = -sustResp;
    end
    transResp(transResp<0)=0; sustResp(sustResp<0)=0;
    
    transOSI = (transResp(:,2)- transResp(:,1))./(transResp(:,2) + transResp(:,1));
    sustOSI = (sustResp(:,2)- sustResp(:,1))./(sustResp(:,2) + sustResp(:,1));
    
    peak = max(transResp,[],2);
    subplot(2,2,3)
    [n b] = hist(abs(transOSI(peak>0.1))); bar(b,n/sum(n));title(['trans osi ' num2str(i)])
    
    peak = max(sustResp,[],2);
    subplot(2,2,4);
    [n b] = hist(abs(sustOSI(peak>0.1))); bar(b,n/sum(n)); title(['sust osi ' num2str(i)])
    
    if i ==1
        peak = max(transResp,[],2);
        clustOSI = abs(transOSI(peak>0.1));
    else
        clustOSI = abs(sustOSI(peak>0.1));
    end
    osi(i) = median(clustOSI); osi_err(i) = std(clustOSI)/sqrt(length(clustOSI));
    figure(osifig);
    subplot(2,2,i);
    [n b] = hist(clustOSI); bar(b,n/sum(n)); title(sprintf('OSI clust %d',i)); ylim([0 0.4]); xlabel('OSI'); ylabel('fraction');
    
end
figure
bar(osi); hold on; errorbar(1:3,osi,osi_err,'k.','markersize',8,'Linewidth',2); ylabel('osi'); xlabel('cluster'); ylim([0 1])
set(gca,'FontSize',16)

%%% calculate # of neurons in each cluster for each condition (pie chart)
clear clustDist
for cond =1:4
    for i = 1:max(clust); clustDist(cond,i) = sum(allCond==cond & clust==i )/sum(allCond==cond & centered'); end
    clustDist(cond,i+1) = sum(allCond'==cond & centered & ~active)/sum(allCond'==cond & centered);
    figure
    % pie(clustDist(cond,[4 1 2 3]),{'inactive','sustain','transient','suppresed'}); title(condLabel{cond});
    pie(clustDist(cond,:));title(condLabel{cond})
end
clustDist

%%% print out number of cells and subjects in each condition
for c = 1:4
    cells = find(allCond==c & centered');
    sessions = unique(sess(cells));
    subjs = unique({files(alluse(sessions)).subj});
    sprintf('%s %d cells %d subjs %d sessions',condLabel{c},length(cells), length(subjs),length(sessions))
end



%%%%% end of useful code



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




