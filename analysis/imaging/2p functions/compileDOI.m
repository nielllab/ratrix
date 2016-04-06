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

tuningAll(:,:,:,1) = dFout;

%%% load post size
[f p ] = uigetfile('*.mat','post size pts');
load(fullfile(p,f));
postT = tcourse; postdF = dF;
postTuning = squeeze(tcourse(:,8,:));
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
errorbar(preSz(1:5)-preSz(1),preSzSE(1:5));
hold on
errorbar(postSz(1:5)-postSz(1),postSzSE(1:5));



figure
plot(rfpts(goodTopo  ,1),rfpts(goodTopo ,2),'o')
hold on
plot(rfpts(goodTopo & activeDOI ,1),rfpts(goodTopo & activeDOI,2),'go')
axis equal; axis([0 72 0 128]); legend('not doi','active doi')




%%% find pref sf & orient
%%% i.e. get response(sf,orient,sz,cond);  average over alll but sf to get
%%% sf pref, all but orient to get orient pref