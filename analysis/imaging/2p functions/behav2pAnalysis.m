clear all

dt=0.25;

[f p ] = uigetfile('*.mat','session data')
load(fullfile(p,f),'onsets','starts','trialRecs','pixResp');

useOld = input('align to std points (1) or choose new points (2) or read in prev points (3) : ')
if useOld ==1
    getAnalysisPts;
elseif useOld==2
    [pts dF neuropil ptsfname] = get2pPts(dfofInterp,greenframe);
else
    ptsfname = uigetfile('*.mat','pts file');
    load(ptsfname);
end

%%% get target location, orientation, phase
stim = [trialRecs.stimDetails];
targ = sign([stim.target]);
for i = 1:length(trialRecs);
    orient(i) = trialRecs(i).stimDetails.subDetails.orientations;
    gratingPh(i) = trialRecs(i).stimDetails.subDetails.phases;
end

%%% get correct
s = [trialRecs.trialDetails];
f = find(arrayfun(@(x)isempty(x.correct),s),1,'first');
if ~isempty(f) && f~=length(s)
    error('bad corrects')
end
correct = [s.correct] == 1;


dF(dF<0)=0;
dF=deconvg6s(dF,0.25);


for i = 1:size(dF,2);
    dFnorm(:,i) = dF(:,i)/max(dF(:,i));
end

col = 'rgb';
[coeff score latent] = pca(dFnorm');
figure
plot(score(:,1),score(:,2),'k'); hold on
mapColors(score(:,1),score(:,2),'.',jet(length(score)))
figure
plot(score(:,1),score(:,3)); hold on
mapColors(score(:,1),score(:,3),'.',jet(length(score)))
figure
plot(score(:,2),score(:,3)); hold on
mapColors(score(:,2),score(:,3),'.',jet(length(score)))
figure
hold on
for i = 1:5
    subplot(5,1,i)
    plot(score(:,i))
end


figure
plot(latent(1:10)/sum(latent))

usenonzero= find(mean(dF,2)~=0 );

figure
imagesc(dF(usenonzero,:))

timepts = -1:0.25:2;
dFalign = align2onsets(dF,onsets,dt,timepts);
trialmean = mean(dFalign,3);
for i = 1:size(trialmean,1);
    trialmean(i,:) = trialmean(i,:)- min(trialmean(i,:));
end
figure
plot(trialmean');
title('mean for all units')

%%% get left/right traces
leftmean = mean(dFalign(:,:,targ==-1),3);
rightmean = mean(dFalign(:,:,targ==1),3);
for i = 1:length(leftmean)
    leftmean(i,:) = leftmean(i,:)-min(leftmean(i,3:4));
end
for i = 1:length(leftmean)
    rightmean(i,:) = rightmean(i,:)-min(rightmean(i,3:4));
end

figure
plot(leftmean'); ylim([-1 1])
title('left targs')

figure
imagesc(squeeze(pixResp(:,:,7,1) - pixResp(:,:,4,1)),[-0.5 0.5]); colormap jet
title('left targs')

figure
draw2pSegs(usePts,leftmean(:,7),jet,size(pixResp,1),usenonzero,[-0.5 0.5])
title('left targs')

figure
plot(rightmean')
title('right targs'); ylim([-1 1])

figure
imagesc(squeeze(pixResp(:,:,7,2) - pixResp(:,:,4,2)),[-0.5 0.5]); colormap jet
title('right targs')

figure
draw2pSegs(usePts,rightmean(:,7),jet,size(pixResp,1),usenonzero,[-0.5 0.5])
title('right targs')

figure
plot(leftmean(:,7),rightmean(:,7),'o'); hold on
axis equal; axis square; plot([0 1],[0 1],'g');

title('performance')
results = [ sum(correct & targ==-1)  sum(~correct&targ==-1) sum(~correct & targ==1)  sum(correct & targ==1)];
results = results/sum(results(:))
figure
pie(results); legend('left correct','left error','right error','right correct');

correctmean = mean(dFalign(:,:,correct),3);
wrongmean = mean(dFalign(:,:,~correct),3);
figure
plot(timepts,correctmean')
figure
plot(timepts,wrongmean');

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

save(ptsfname,'usenonzero','onsets','starts','trialRecs','correct','targ','orient','gratingPh','dFalign','pixResp','-append')

dF(dF<-0.1)=-0.1;
dF(dF>5)=5;
figure
imagesc(corrcoef(dF(usenonzero,:)),[0 1])

figure
imagesc(corrcoef(dF(usenonzero,:)'),[0 1])

figure
imagesc(dF(usenonzero,:),[-1 5])

startTimes = zeros(ceil(length(dF)*dt),1);
startTimes(round(onsets))=1;
x = [-60:60];
filt = exp(-0.5*x.^2 / (20^2));
filt = 60*filt/sum(filt);
trialRate = conv(startTimes,filt,'same');

for i = 1:size(dF,1)
    dFmin(i,:) = dF(i,:) - min(abs(dF(i,:)));
    dFstd(i,:) = dFmin(i,:)/std(dF(i,:));
end


correctRate = conv(double(correct),ones(1,10),'same')/10;
figure
plot(correctRate);
resprate = conv(resptime,ones(3,1),'same')/3;
stoprate = conv(stoptime,ones(3,1),'same')/3;



dFlist= reshape(dFalign,size(dFalign,1),size(dFalign,2)*size(dFalign,3));
dFlist = dFlist(usenonzero,:);
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
imagesc(corrcoef(dFlist(usenonzero,:)),[0 1]); xlabel('frame'); ylabel('frame')
subplot(6,6,1:6); plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)

nclust=4;
[idx] = kmeans(dFstd(usenonzero,:),nclust);
[y sortind] = sort(idx);

idxall = zeros(length(pts),1);
idxall(usenonzero) = idx;

figure
draw2pSegs(usePts,idxall,jet,size(pixResp,1),usenonzero,[1 4])

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

leftmean = mean(dFalign(:,:,targ==-1),3);
rightmean = mean(dFalign(:,:,targ==1),3);


for i = 1:length(leftmean)
    mn =min([ leftmean(i,3:4) rightmean(i,3:4)]);
    leftmean(i,:) =  leftmean(i,:) - mn;
    rightmean(i,:) = rightmean(i,:)-mn;
end


t = find(timepts==0.5);
leftright = leftmean(:,t)-rightmean(:,t) ;
verthoriz = vertresp(:,t)-horizresp(:,t);
figure
plot(leftright,verthoriz,'o')

figure
plot(leftmean(:,t),rightmean(:,t),'o'); hold on; plot([0 2],[0 2],'g')

figure
plot(vertresp(:,t),horizresp(:,t),'o'); hold on; plot([0 2],[0 2],'g')


dFalignfix = dFalign;
for i=1:size(dFalign,1);
    for j = 1:size(dFalign,3);
        dFalignfix(i,:,j) = dFalignfix(i,:,j)-min(dFalignfix(i,3:5,j));
    end
end
%dFalignfix(dFalignfix>5)=5;

clear allTrialData
for i = 1:size(dFalignfix,1);
    for j = 1:4
        if j==1
            use = targ==-1 & orient==0 & correct==1;
        elseif j==2
            use = targ==1 & orient==0 & correct==1;
        elseif j ==3
            use = targ==-1 & orient>0 & correct==1;
        elseif j==4
            use = targ==1 & orient>0 & correct==1;
        elseif j==5
                 use = targ==-1 & orient==0 & correct==0;
        elseif j==6
            use = targ==1 & orient==0 & correct==0;
        elseif j ==7
            use = targ==-1 & orient>0 & correct==0;
        elseif j==8
            use = targ==1 & orient>0 & correct==0;
        end
    allTrialData(i,:,j) = mean(dFalignfix(i,:,use),3);
    allTrialDataErr(i,:,j) = std(dFalignfix(i,:,use),[],3)/sqrt(sum(use));
    end
end

goodTrialData = allTrialData(usenonzero,:,:);
goodTrialData = reshape(goodTrialData,size(goodTrialData,1),size(goodTrialData,2)*size(goodTrialData,3));
figure
imagesc(goodTrialData,[0 2])

dist = pdist(goodTrialData,'correlation');
Z = linkage(dist,'ward');
leafOrder = optimalleaforder(Z,dist);
figure
subplot(3,4,[1 5 9 ])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
goodTrialData(:,14)=-1; goodTrialData(:,27)=-1; goodTrialData(:,40)=-1;
imagesc(flipud(goodTrialData(perm,:)),[-1 1]); 

figure
subplot(4,4,[5 9 13])
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5,'reorder',leafOrder);
axis off
subplot(4,4,[6 7 8 10 11 12 14 15 16]);
imagesc(flipud(dFlist(perm,:)),[0 4]); 
subplot(4,4,2:4)
plot(correctRate,'Linewidth',2); set(gca,'Xtick',[]); set(gca,'Ytick',[]); ylabel('correct'); ylim([0 1.1]); xlim([1 length(correctRate)])
hold on; %plot([1 length(correctRate)],[0.5 0.5],'r:');
plot(resprate/max(resprate),'g','Linewidth',2); plot(stoprate/max(stoprate),'r','Linewidth',2)




[Y e] = mdscale(dist,1);
[y sortind] = sort(Y);
figure
imagesc(goodTrialData(sortind,:),[-1 1])



        
usetrials = zeros(size(targ));
usetrials(80:end)=1;
usetrials=1;
clear data err
col = 'rmbc'
allTrials = zeros(size(dFalign,2),4,size(dFalign,1));
for i = 1:length(sortind)
    
    for j = 1:4
        if j==1
            use = targ==-1 & orient==0 & usetrials;
        elseif j==2
            use = targ==-1 & orient>0& usetrials;
        elseif j ==3
            use = targ==1 & orient==0& usetrials;
        else
            use = targ==1 & orient>0& usetrials;
        end
        d = mean(dFalignfix(usenonzero(sortind(i)),:,use),3);
        data(:,j) = d; %-mind(d);
        err(:,j) = std(dFalignfix(usenonzero(sortind(i)),:,use),[],3)/sqrt(sum(use));
        
    end
    data = data-min(data(:));
    allTrials(:,:,usenonzero(sortind(i))) = data;
    allTrialsErr(:,:,usenonzero(sortind(i))) = err;
    %           figure; hold on
    %           for j=1:4
    %             errorbar(timepts,data(:,j),err(:,j),col(j)); ylim([0 2])
    %         end
    %         title(sprintf('group %d cell %d',y(i),usenonzero(sortind(i))))
    %         legend('left vert','left horiz','right vert','right horiz')
end


save(ptsfname,'allTrials','allTrialsErr','vertresp','horizresp','leftmean', 'rightmean','timepts','allTrialData','allTrialDataErr','-append');

figure
set(gcf,'Name','vert vs horizt')
for t = 1:6
    subplot(2,3,t)
    plot(vertresp(:,2*t+1),horizresp(:,2*t+1),'o'); axis([-1 1 -1 1]); axis square;  title(sprintf('t = %d',2*t+1))
end


figure
set(gcf,'Name','left vs right')
for t = 1:6
    subplot(2,3,t)  
    plot(leftmean(:,2*t+1),rightmean(:,2*t+1),'o'); axis([-1 1 -1 1]); axis square;  title(sprintf('t = %d',2*t+1))
end



%%% plot each cluster
col='bcyr'
clear data
for i =1:nclust
    figure; hold on
    useidx = find(idx==i);
    for j=1:length(useidx)
        d = mean(dFalign(usenonzero(useidx(j)),:,:),3);
        plot(timepts,d-min(d),col(i)); ylim([0 1.5])
        data(j,:) = d-min(d);
    end
    plot(timepts,median(data,1),'k','Linewidth',2);
end
% 
% 
% %%% looks at stopping / resp times
% stoplength = 1.1;
% longstops = onsets(stoptime<stoplength);
% length(longstops)
% clear stopdF
% stopPts = -stoplength:0.25:2;
% stopalign = align2onsets(dF,longstops,dt,stopPts);
% for i = 1:size(dF,1);
%     stopdF(i,:) = mean(stopalign(i,:,:),3);
%     stopdF(i,:) = stopdF(i,:) - min(stopdF(i,:));
% end
% figure
% plot(stopPts,stopdF)
% hold on
% plot(stopPts,mean(stopdF,1),'g','Linewidth',2)
% 
% figure
% imagesc(stopdF(usenonzero(sortind),:),[0 1.5])
% 
% respDur = 0.5;
% longstops = onsets(correct) %+ resptime(resptime>respDur)';
% length(longstops)
% clear stopdF
% stopPts = -1:0.25:4;
% stopalign = align2onsets(dF,longstops,dt,stopPts);
% for i = 1:size(dF,1);
%     stopdF(i,:) = mean(stopalign(i,:,:),3);
%     stopdF(i,:) = stopdF(i,:) - min(stopdF(i,:));
% end
% figure
% plot(stopPts,stopdF)
% hold on
% plot(stopPts,mean(stopdF,1)*3,'g','Linewidth',2); ylim([0 2])
% 
% figure
% imagesc(stopdF(usenonzero(sortind),:),[0 1.5])

