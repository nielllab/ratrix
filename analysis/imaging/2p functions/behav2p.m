clear all

dt = 0.25;
framerate=1/dt;
twocolor = input('# of channels : ')
twocolor= (twocolor==2);
get2pSession;
if ~exist('onsets','var')
    if ~exist('ttlFname','var')
    [tf tp] = uigetfile('*.mat','ttl file');
ttlFname = fullfile(tp,tf);
end
[bf bp] = uigetfile('*.mat','behav permanent trial record');
[onsets starts trialRecs] = sync2pBehavior(fullfile(bp,bf) ,ttlFname);
save(sessionName,'onsets','starts','trialRecs','-append');
end

if ~exist('mapalign','var')
timepts = -1:0.25:2;
mapalign = align2onsets(dfofInterp,onsets,dt,timepts);
save(sessionName,'timepts','mapalign','-append')
end

%%% get target
stim = [trialRecs.stimDetails];
targ = sign([stim.target]);

%%% get correct
s = [trialRecs.trialDetails];
f = find(arrayfun(@(x)isempty(x.correct),s),1,'first');
if ~isempty(f) && f~=length(s)
    error('bad corrects')
end
correct = [s.correct] == 1; 

figure
for t = 1:2
    if t==1
        dfmean = mean(mapalign(:,:,:,targ==-1),4);
    else
        dfmean = mean(mapalign(:,:,:,targ==1),4); 
    end
%mn = mean(dfmean,3);
mn = min(dfmean,[],3);
for i = 1:4;
    subplot(2,4,i+4*(t-1));
    imagesc(dfmean(:,:,2*i+3)-mn,[0 0.5]);
    axis equal; axis off
end

end


selectPts = input('select points for further analysis? 0/1 ')
if selectPts==1
    
    useOld = input('align to std points (1) or choose new points (2) or read in prev points (3) : ')
    if useOld ==1
        [pts dF ptsfname icacorr cellImg usePts] = align2pPts(dfofInterp,greenframe);
    elseif useOld==2
        [pts dF neuropil ptsfname] = get2pPts(dfofInterp,greenframe);
    else
        ptsfname = uigetfile('*.mat','pts file');
        load(ptsfname);
    end
end

edgepts = (pts(:,1)<18 | pts(:,1)>237 | pts(:,2)<18 | pts(:,2)>237);
usenonzero= find(mean(dF,2)~=0 & ~edgepts);

timepts = -1:0.25:2;
dFalign = align2onsets(dF,onsets,dt,timepts);
trialmean = mean(dFalign,3);
for i = 1:size(trialmean,1);
    trialmean(i,:) = trialmean(i,:)- min(trialmean(i,:));
end
figure
plot(trialmean');

figure
plot(timepts,mean(trialmean,1))



%%% get left/right traces
leftmean = mean(dFalign(:,:,targ==-1),3);
rightmean = mean(dFalign(:,:,targ==1),3);
for i = 1:length(leftmean)
  leftmean(i,:) = leftmean(i,:)-min(leftmean(i,:));
end
for i = 1:length(leftmean)
    rightmean(i,:) = rightmean(i,:)-min(rightmean(i,:));
end


       
       figure
       draw2pSegs(usePts,leftmean(:,9),jet,256,usenonzero,[0 0.5])

        figure
       draw2pSegs(usePts,rightmean(:,9),jet,256,usenonzero,[0 0.5])

figure
plot(leftmean(:,9),rightmean(:,9),'o'); hold on
axis equal; axis square; plot([0 1],[0 1],'g');

results = [ sum(correct & targ==-1)  sum(~correct&targ==-1) sum(~correct & targ==1)  sum(correct & targ==1)];
results = results/sum(results(:))
figure
pie(results); legend('left correct','left error','right error','right correct');

correctmean = mean(dFalign(:,:,correct),3);
wrongmean = mean(dFalign(:,:,~correct),3);
trialmean = correctmean-wrongmean;
figure
plot(trialmean');

%%% get start/stop time
resptime = starts(:,3)-starts(:,2); resptime = resptime*10^4;
figure
hist(resptime,0:0.1:5)
stoptime = starts(:,2)-starts(:,1); stoptime  = stoptime*10^4;
figure
hist(stoptime);

c = 'rgbcmk'
figure
hold on
for i = 1:size(dF,1);
    plot(dF(i,:)/max(dF(i,:)) + i/2,c(mod(i,6)+1));
end
for i = 1:length(onsets);
    plot([onsets(i)/dt onsets(i)/dt],[1 size(dF,1)/2]);
end

dF(dF<-0.1)=-0.1;
dF(dF>5)=5;
figure
imagesc(corrcoef(dF(usenonzero,:)),[0 1])

figure
imagesc(corrcoef(dF(usenonzero,:)'),[0 1])

figure
imagesc(dF(usenonzero,:),[-1 5])

for i = 1:size(dF,1)
    dFmin(i,:) = dF(i,:) - min(abs(dF(i,:)));
    dFstd(i,:) = dFmin(i,:)/std(dF(i,:));
end



figure
imagesc(dFstd(usenonzero,:),[-1 5])

figure
imagesc(dFmin(usenonzero,:),[-1 5])

figure
imagesc(corrcoef(dFstd(usenonzero,:)),[0 0.5])

[idx] = kmeans(dFstd(usenonzero,:),8);
[y sortind] = sort(idx);
figure
imagesc(dF(usenonzero(sortind),:),[-1 5])

dist = 1-corrcoef(dF(usenonzero,:)');


startTimes = zeros(ceil(length(dF)*dt),1);
startTimes(round(onsets))=1;
x = [-60:60];
filt = exp(-0.5*x.^2 / (20^2));
filt = 60*filt/sum(filt);
trialRate = conv(startTimes,filt,'same');

[Y e] = mdscale(dist,1);
[y sortind] = sort(Y);
figure
imagesc(dF(usenonzero(sortind),:),[-1 5])


figure
subplot(6,6,7:36)
imagesc(dF(usenonzero(sortind),:),[-1 5]); ylabel('cell'); xlabel('frames')
subplot(6,6,1:6)
plot((1:length(trialRate))/dt,trialRate); xlim([1 length(trialRate)/dt]); hold on
plot([1 length(trialRate)/dt],[0 0],'k:')
set(gca,'Xtick',[]);
set(gca,'Ytick',[]);
ylabel('trial rate')
idxall = zeros(length(pts));
idx(usenonzero) = idx;
idxall = zeros(length(pts),1);
idxall(usenonzero) = Y;
        figure
       draw2pSegs(usePts,idxall,jet,256,usenonzero,[-1 1])

       

[idx] = kmeans(dFstd(usenonzero,:),4);
[y sortind] = sort(idx);
figure
imagesc(dF(usenonzero(sortind),:),[-1 5])
figure
subplot(6,6,7:36)
imagesc(dF(usenonzero(sortind),:),[-1 5]); ylabel('cell'); xlabel('frames')
subplot(6,6,1:6)
plot((1:length(trialRate))/dt,trialRate); xlim([1 length(trialRate)/dt]); hold on
plot([1 length(trialRate)/dt],[0 0],'k:')
set(gca,'Xtick',[]);
set(gca,'Ytick',[]);
ylabel('trial rate')

idxall = zeros(length(pts),1);
idxall(usenonzero) = idx;

        figure
       draw2pSegs(usePts,idxall,jet,256,usenonzero,[1 4])


figure
subplot(6,6,7:36)
imagesc(corrcoef(dF(usenonzero,:)),[0 1]); xlabel('frames'); ylabel('frames')
subplot(6,6,1:6)
plot((1:length(trialRate))/dt,trialRate); xlim([1 length(trialRate)/dt]); hold on
plot([1 length(trialRate)/dt],[0 0],'k:')
set(gca,'Xtick',[]);
set(gca,'Ytick',[]);
ylabel('trial rate')