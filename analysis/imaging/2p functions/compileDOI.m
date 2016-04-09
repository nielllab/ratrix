%if you want to cut out huge responses
thresh=1;
threshval = 0.5;

[f p] = uigetfile('*.mat','topox pts');
load(fullfile(p,f));
xPhase = phaseVal;
xdF = dF;
sprintf('%d topox pts',sum(mean(xdF,2)~=0))


[f p] = uigetfile('*.mat','topoy pts');
load(fullfile(p,f));
yPhase = phaseVal;
ydF = dF;
sprintf('%d topoy pts',sum(mean(ydF,2)~=0))

activePts = find( mean(xdF,2)~=0 & mean(ydF,2)~=0);
sprintf('%d total pts',length(activePts))

edgepts = (pts(:,1)<18 | pts(:,1)>237 | pts(:,2)<18 | pts(:,2)>237);
usenonzero= find(mean(dF,2)~=0 & ~edgepts);
clear rfpts

rfpts(:,2) = mod(angle(xPhase),2*pi)*128/(2*pi);
rfpts(:,1) = mod(angle(yPhase),2*pi)*72/(2*pi);
goodTopo = abs(xPhase)>0.05 & abs(yPhase)>0.05;

figure
plot(rfpts(goodTopo,1),rfpts(goodTopo,2),'o')
axis equal; axis([0 72 0 128])

%%% load pre size
[f p ] = uigetfile('*.mat','pre size pts');
load(fullfile(p,f));
preT = tcourse; predF = dF;
preTuning = squeeze(tcourse(:,8,:));

%remove traces with values that go above or below 1
if thresh==1
    for i = 1:size(dFout,1)
        for j = 1:size(dFout,3)
            if max(dFout(i,:,j))<threshval&min(dFout(i,:,j))>-threshval;
                dFout(i,:,j) = dFout(i,:,j)-dFout(i,5,j);
            else
                dFout(i,:,j) = nan(1,12);
            end
        end
    end
end
tuningAll(:,:,:,1) = dFout;

%%% load post size
[f p ] = uigetfile('*.mat','post size pts');
load(fullfile(p,f));
postT = tcourse; postdF = dF;
postTuning = squeeze(tcourse(:,8,:));

%remove traces with values that go above or below 1
if thresh==1
    for i = 1:size(dFout,1)
        for j = 1:size(dFout,3)
            if max(dFout(i,:,j))<threshval&min(dFout(i,:,j))>-threshval;
                dFout(i,:,j) = dFout(i,:,j)-dFout(i,5,j);
            else
                dFout(i,:,j) = nan(1,12);
            end
        end
    end
end
tuningAll(:,:,:,2) = dFout;

% sfs = unique(sf);
% thetas = unique(theta);
% 
% for sz = 1:6;
%     for f=1:2
%         for ori = 1:8;
%             for rep = 1:2;
%                 tuning(:,:,sz,f,ori,rep) = squeeze(mean(tuningAll(:,:,sf == sfs(f) & radius==sz & theta==thetas(ori),rep),3));
%             end
%         end
%     end
% end

%%% find cells active during doi
activeDOI = ( mean(predF,2)~=0 & mean(postdF,2)~=0);
sprintf('%d active doi',sum(activeDOI))

%%% find cells with RF in middle of screen
rfcenter = rfpts(:,1)>10 & rfpts(:,1)<60 & rfpts(:,2)>40 & rfpts(:,2)<90;
sprintf('%d active doi and center',sum(activeDOI & rfcenter))

figure
plot(squeeze(mean(preT(activeDOI & rfcenter,:,:),1)))
title('timecourse active and center pre')

figure
plot(squeeze(mean(postT(activeDOI & rfcenter,:,:),1)))
title('timecourse active and center post')

use = activeDOI & rfcenter;

figure
for s = 1:6
    subplot(2,3,s)
    plot(preTuning(use,s), postTuning(use,s),'.');
    axis square; axis([-0.2 0.5 -0.2 0.5])
end

preSz = mean(preTuning(use,:),1);
postSz = mean(postTuning(use,:),1);
preSzSE = std(preTuning(use,:),1)/sqrt(size(preTuning(use,:),1));
postSzSE = std(postTuning(use,:),1)/sqrt(size(postTuning(use,:),1));

figure
errorbar(preSz(1:5)-preSz(1),preSzSE(1:5),'k');
hold on
errorbar(postSz(1:5)-postSz(1),postSzSE(1:5),'r');
axis([0.5 5.5 -0.02 0.1])
axis square
set(gca,'tickDir','out')
legend('Pre','Post','location','southeast')
title('Size responses all traces')
xlabel('size')
ylabel('dF/F')

figure
plot(rfpts(goodTopo  ,1),rfpts(goodTopo ,2),'o')
hold on
plot(rfpts(goodTopo & activeDOI ,1),rfpts(goodTopo & activeDOI,2),'go')
axis equal; axis([0 72 0 128]); legend('not doi','active doi')




%%% find pref sf & orient
%%% i.e. get response(sf,orient,sz,cond);  average over alll but sf to get
%%% sf pref, all but orient to get orient pref

%load in stimulus parameters from movie file
clear sf radius theta
load('C:\sizeSelect2sf1tf5sz14min','sf','radius','theta')
clear radiusRange
sfrange=unique(sf);radiusrange=unique(radius);thetarange=unique(theta);

%create usetuning(cell,timept,sf,radius,theta,pre/post doi)
usetuningAll = tuningAll(use,:,:,:);
for i = 1:sum(use)
    for j=1:size(usetuningAll,3)
        for k = 1:size(usetuningAll,4)
            usetuningAll(i,:,j,k) = usetuningAll(i,:,j,k);% - usetuningAll(i,5,j,k);
        end
    end
end
usetuning = zeros(size(usetuningAll,1),size(usetuningAll,2),length(sfrange),length(radiusrange),length(thetarange),2);
for i = 1:length(sfrange)
    for j = 1:length(radiusrange)
        for k = 1:length(thetarange)
            for l = 1:2
                usetuning(:,:,i,j,k,l) = squeeze(nanmean(usetuningAll(:,:,find(sf==sfrange(i)&radius==radiusrange(j)&theta==thetarange(k)),l),3));
            end
        end
    end
end

%plot cycle averages for each size, averaged across sf/ori
figure
subplot(1,2,1)
plot(1:12,squeeze(nanmean(nanmean(nanmean(usetuning(:,:,:,:,:,1),5),3),1)))
legend({'0','5','10','20','45','50'},'location','northwest')
title('Pre All Traces')
axis([1 12 -.1 .2])
subplot(1,2,2)
plot(1:12,squeeze(nanmean(nanmean(nanmean(usetuning(:,:,:,:,:,2),5),3),1)))
legend({'0','5','10','20','45','50'},'location','northwest')
title('Post All Traces')
axis([1 12 -.1 .2])

%find ideal sf and ori for each cell
ideal = zeros(sum(use),2);
for i = 1:sum(use)
    [val ind] = max(squeeze(nanmean(nanmean(nanmean(usetuning(i,6:12,:,:,:,2),5),4),2)));
    ideal(i,1) = ind;
    [val ind] = max(squeeze(nanmean(nanmean(nanmean(usetuning(i,6:12,:,:,:,2),4),3),2)));
    ideal(i,2) = ind;
end

%pull out traces only for ideal stimuli for each cell
PreSize = zeros(sum(use),size(usetuning,2),length(radiusrange));
PostSize = PreSize;
for i = 1:sum(use)
    for j = 1:size(usetuning,2)
        PreSize(i,j,:) = squeeze(usetuning(i,j,ideal(i,1),:,ideal(i,2),1));
        PostSize(i,j,:) = squeeze(usetuning(i,j,ideal(i,1),:,ideal(i,2),2));
    end
end

%get average peak responses to the size stimuli for ideal stimuli
avgPreSize = squeeze(nanmean(PreSize(:,8,:),1));
avgPostSize = squeeze(nanmean(PostSize(:,8,:),1));
sePreSize = squeeze(nanstd(PreSize(:,8,:),1)/sqrt(sum(use)));
sePostSize = squeeze(nanstd(PostSize(:,8,:),1)/sqrt(sum(use)));
%plot peak size responses pre and post doi w/ideal stimuli
figure
hold on
errorbar(1:5,avgPreSize(1:5),sePreSize(1:5),'k')
errorbar(1:5,avgPostSize(1:5),sePostSize(1:5),'r')
axis([0.5 5.5 -0.02 0.1])
axis square
set(gca,'tickDir','out')
legend('Pre','Post','location','southeast')
title('Size responses ideal stim')
xlabel('size')
ylabel('dF/F')

%plot cycle averages with ideal stimuli
avgPreTrace = squeeze(nanmean(PreSize,1));
avgPostTrace = squeeze(nanmean(PostSize,1));

figure
subplot(1,2,1)
plot(1:12,avgPreTrace)
legend({'0','5','10','20','45','50'},'location','northwest')
title('Pre Ideal Traces')
axis([1 12 -.05 .2])
subplot(1,2,2)
plot(1:12,avgPostTrace)
legend({'0','5','10','20','45','50'},'location','northwest')
title('Post Ideal Traces')
axis([1 12 -.05 .2])



% for i = 1:sum(use)
%     figure
%     hold on
%     plot(1:12,squeeze(usetuningAll(i,:,:,1)),'k')
%     plot(1:12,squeeze(usetuningAll(i,:,:,2)),'r')
% end