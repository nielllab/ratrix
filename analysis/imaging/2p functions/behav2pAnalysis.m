clear all

%%% load pts file (contains cell locations and dF, along with analysis results
    ptsfname = uigetfile('*.mat','pts file');
    load(ptsfname);

if ~exist('pixResp','var') | ~exist('dt','var')
    [f p ] = uigetfile('*.mat','session data')
    load(fullfile(p,f),'onsets','starts','trialRecs','pixResp','dt');
end

%%% get target location, orientation, phase
stim = [trialRecs.stimDetails];
for i = 1:length(trialRecs);
    orient(i) = pi/2 - trialRecs(i).stimDetails.subDetails.orientations;
    gratingPh(i) = trialRecs(i).stimDetails.subDetails.phases;
    location(i) =  sign(trialRecs(i).stimDetails.subDetails.xPosPcts - 0.5);
    targ(i) = sign(stim(i).target);
end

%%% get correct
s = [trialRecs.trialDetails];
f = find(arrayfun(@(x)isempty(x.correct),s),1,'first');
if ~isempty(f) && f~=length(s)
    error('bad corrects')
end
correct = [s.correct] == 1;

figure
imagesc(dF,[0 1])

cellCutoff = input('cell cutoff : ');
useCells= 1:cellCutoff;

dFdecon=spikes*10;
% for i = 1:size(dF,1);
%     dFdecon(i,:) = dFdecon(i,:)-prctile(dFdecon(i,:),1);
% end
% 
% figure
% imagesc(dFdecon(useCells,:),[0 1])
% 
% dFdecon=deconvg6s(dFdecon,0.25);

%dFdecon = dF*2;

figure
imagesc(dF(useCells,:),[0 1]); 

figure
imagesc(dFdecon(useCells,:),[0 1]);


for i = 1:size(dFdecon,2);
    dFnorm(:,i) = dFdecon(:,i)/max(dFdecon(:,i));
end

col = 'rgb';
[coeff score latent] = pca(dFnorm');

range = 3:3:size(score,1);

figure
plot(score(range,1),score(range,2)); hold on
mapColors(score(range,1),score(range,2),'.',jet(length(range)))
drawnow

figure
plot(score(range,1),score(range,3)); hold on
mapColors(score(range,1),score(range,3),'.',jet(length(range)));
drawnow;

figure
plot(score(range,2),score(range,3)); hold on
mapColors(score(range,2),score(range,3),'.',jet(length(range)))
drawnow

figure
hold on
for i = 1:5
    subplot(5,1,i)
    plot(score(:,i))
end


figure
plot(latent(1:10)/sum(latent))



figure
imagesc(dFdecon(useCells,:),[0 1])


timepts = -0.75:0.25:2;
dFalign = align2onsets(dFdecon,onsets,dt,timepts);
trialmean = mean(dFalign,3);
for i = 1:size(trialmean,1);
    trialmean(i,:) = trialmean(i,:)- min(trialmean(i,:));
end
figure
plot(trialmean');
title('mean for all units')

%%% get left/right traces
topmean = mean(dFalign(:,:,location==-1),3);
bottommean = mean(dFalign(:,:,location==1),3);
for i = 1:length(topmean)
    topmean(i,:) = topmean(i,:)-min(topmean(i,3:4));
end
for i = 1:length(topmean)
    bottommean(i,:) = bottommean(i,:)-min(bottommean(i,3:4));
end



figure
plot(topmean'); ylim([-1 2])
title('left targs')

figure
imagesc(squeeze(pixResp(:,:,7,1) - pixResp(:,:,4,1)),[-0.5 0.5]); colormap jet
title('left targs')

figure
draw2pSegs(usePts,topmean(:,6),jet,size(meanShiftImg,1),useCells,[-0.25 0.25])
title('left targs')

figure
plot(bottommean')
title('right targs'); ylim([-1 2])

figure
imagesc(squeeze(pixResp(:,:,7,2) - pixResp(:,:,4,2)),[-0.5 0.5]); colormap jet
title('right targs')

figure
draw2pSegs(usePts,bottommean(:,6),jet,size(meanShiftImg,1),useCells,[-0.25 0.25])
title('right targs')

figure
plot(topmean(:,7),bottommean(:,7),'o'); hold on
axis equal; axis square; plot([0 1],[0 1],'g');

title('performance')
results = [ sum(correct & location==-1)  sum(~correct&location==-1) sum(~correct & location==1)  sum(correct & location==1)];
results = results/sum(results(:))
figure
pie(results); legend('left correct','left error','right error','right correct');

correctmean = mean(dFalign(:,:,correct),3);
wrongmean = mean(dFalign(:,:,~correct),3);
figure
plot(timepts,correctmean'); ylim([0 5]);
figure
plot(timepts,wrongmean'); ylim([0 5])

%%% get start/stop time
resptime = starts(:,3)-starts(:,2);
figure
rtime = resptime; rtime(rtime>2)=2;
hist(rtime,0:0.1:2); xlabel('response time')
stoptime = starts(:,2)-starts(:,1);
figure
stime = stoptime; stime(stime>20)=20;
hist(stime,0.5:1:20); xlabel('stopping time')


save(ptsfname,'dt','onsets','starts','trialRecs','correct','targ','location','orient','gratingPh','dFalign','pixResp','dFdecon','resptime','stoptime','-append')

dFdecon(dFdecon<-0.1)=-0.1;
dFdecon(dFdecon>5)=5;
figure
imagesc(corrcoef(dFdecon(useCells,:)),[-0.5 0.5]); colormap jet

figure
imagesc(corrcoef(dFdecon(useCells,:)'),[-0.5 0.5]); colormap jet

figure
imagesc(dFdecon(useCells,:),[0 1])

startTimes = zeros(ceil(length(dFdecon)*dt),1);
startTimes(round(onsets))=1;
x = [-60:60];
filt = exp(-0.5*x.^2 / (20^2));
filt = 60*filt/sum(filt);
trialRate = conv(startTimes,filt,'same');

for i = 1:size(dFdecon,1)
    dFmin(i,:) = dFdecon(i,:) - min(abs(dFdecon(i,:)));
    dFstd(i,:) = dFmin(i,:)/std(dFdecon(i,:));
end


correctRate = conv(double(correct),ones(1,10),'same')/10;
figure
plot(correctRate);
resprate = conv(resptime,ones(3,1),'same')/3;
stoprate = conv(stoptime,ones(3,1),'same')/3;



dFlist= reshape(dFalign,size(dFalign,1),size(dFalign,2)*size(dFalign,3));
dFlist = dFlist(useCells,:);
for i = 1:size(dFlist,1)
    dFlist(i,:) = dFlist(i,:)/std(dFlist(i,:));
end


dist = pdist(dFlist,'correlation');
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);
figure
subplot(4,4,[5 9 13])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,1.5);
axis off
subplot(4,4,[6 7 8 10 11 12 14 15 16]);
imagesc(flipud(dFlist(perm,:)),[0 4]);
subplot(4,4,2:4)
plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)


dist = pdist(dFlist,'correlation');
[Y e] = mdscale(dist,1);
[y sortind] = sort(Y);
figure
subplot(6,6,7:36);
imagesc(dFlist(sortind,:),[0 2])
subplot(6,6,1:6)
plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)
title('mdscale')


figure
subplot(6,6,7:36);
dFlist= reshape(dFalign,size(dFalign,1),size(dFalign,2)*size(dFalign,3));
imagesc(corrcoef(dFlist(useCells,:)),[0 1]); xlabel('frame'); ylabel('frame')
subplot(6,6,1:6); plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)

nclust=4;
[idx] = kmeans(dFstd(useCells,:),nclust);
[y sortind] = sort(idx);

idxall = zeros(length(usePts),1);
idxall(useCells) = idx;


figure
subplot(6,6,7:36);
dFlist= reshape(dFalign,size(dFalign,1),size(dFalign,2)*size(dFalign,3));
imagesc(dFlist(useCells(sortind),:),[0 1]); xlabel('frame'); ylabel('frame')
subplot(6,6,1:6); plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)
subplot(6,6,7:36); hold on;
col = 'bcyr';
for i = 1:4
    m = max(find(y==i));
    plot([1 size(dFlist,2)],[m m],'Color',col(i),'LineWidth',2)
end
title('k-means')
    

figure
draw2pSegs(usePts,idxall,jet,size(meanShiftImg,1),useCells,[1 4])

orients = unique(orient);
vert = find(orient==orients(1));
horiz = find(orient==orients(2));
vertresp= mean(dFalign(:,:,vert),3);
horizresp = mean(dFalign(:,:,horiz),3);
for i = 1:size(vertresp,1);
    mn = min([vertresp(i,3:4) horizresp(i,3:4)]);
    vertresp(i,:) = vertresp(i,:) - mn;
    horizresp(i,:) = horizresp(i,:) - mn;
end

topmean = mean(dFalign(:,:,location==-1),3);
bottommean = mean(dFalign(:,:,location==1),3);


for i = 1:length(topmean)
    mn =min([ topmean(i,3:4) bottommean(i,3:4)]);
    topmean(i,:) =  topmean(i,:) - mn;
    bottommean(i,:) = bottommean(i,:)-mn;
end

figure
set(gcf,'Name','vert vs horizt')
for t = 1:6
    subplot(2,3,t)
    plot(vertresp(:,2*t),horizresp(:,2*t),'o'); axis([-1 1 -1 1]); axis square;  title(sprintf('t = %d',2*t))
end


figure
set(gcf,'Name','left vs right')
for t = 1:6
    subplot(2,3,t)
    plot(topmean(:,2*t),bottommean(:,2*t),'o'); axis([-1 1 -1 1]); axis square;  title(sprintf('t = %d',2*t))
end


t = find(timepts==0.5);
leftright = topmean(:,t)-bottommean(:,t) ;
verthoriz = vertresp(:,t)-horizresp(:,t);
figure
plot(leftright,verthoriz,'o')

figure
plot(topmean(:,t),bottommean(:,t),'o'); hold on; plot([0 2],[0 2],'g')
xlabel('top'); ylabel('bottom')


figure
plot(vertresp(:,t),horizresp(:,t),'o'); hold on; plot([0 2],[0 2],'g')
xlabel('vertical'); ylabel('horizontal');

dFalignfix = dFalign;
% for i=1:size(dFalign,1);
%     for j = 1:size(dFalign,3);
%         dFalignfix(i,:,j) = dFalignfix(i,:,j)-min(dFalignfix(i,3:5,j));
%     end
% end
% %dFalignfix(dFalignfix>5)=5;

clear allTrialData allTrialDataErr
for i = 1:size(dFalignfix,1);
    for j = 1:8
        if j==1
            use = location==-1 & orient==0 & correct==1;
        elseif j==2
            use = location==-1 & orient>0 & correct==1;
        elseif j ==3
            use = location==1 & orient==0 & correct==1;
        elseif j==4
            use = location==1 & orient>0 & correct==1;
        elseif j==5
            use = location==-1 & orient==0 & correct==0;
        elseif j==6
            use = location==-1 & orient>0 & correct==0;
        elseif j ==7
            use = location==1 & orient==0 & correct==0;
        elseif j==8
            use = location==1 & orient>0 & correct==0;
        end
        allTrialData(i,:,j) = mean(dFalignfix(i,:,use),3);
        allTrialDataErr(i,:,j) = std(dFalignfix(i,:,use),[],3)/sqrt(sum(use));
    end
end

goodTrialData = allTrialData(useCells,:,1:8);
goodTrialData = reshape(goodTrialData(:,:,1:4),size(goodTrialData(:,:,1:4),1),size(goodTrialData(:,:,1:4),2)*size(goodTrialData(:,:,1:4),3));
figure
imagesc(goodTrialData,[-1 1])

dist = pdist(imresize(goodTrialData, [size(goodTrialData,1),size(goodTrialData,2)*0.5]),'correlation');
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
goodTrialData(:,1:12:end)=NaN;
imagesc(flipud(goodTrialData(perm,:)),[0 2]);

figure
subplot(4,4,[5 9 13])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(4,4,[6 7 8 10 11 12 14 15 16]);
dFlistgood = dFlist(useCells,:);
imagesc(flipud(dFlistgood(perm,:)),[0 2]);
subplot(4,4,2:4)
plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)


[Y e] = mdscale(dist,1);
[y sortind] = sort(Y);
figure
imagesc(goodTrialData(sortind,:),[0 1])

figure
imagesc(dFlistgood(sortind,:),[0 1])

save(ptsfname,'timepts','allTrialData','allTrialDataErr','correctRate','resprate','stoprate','-append');



