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

% %load in stimulus parameters from movie file
% clear sf radius theta
% load('C:\sizeSelect2sf1tf5sz14min','sf','radius','theta')
% clear radiusRange
% sfrange=unique(sf);radiusrange=unique(radius);thetarange=unique(theta);
% 
% %create tuning(cell,timept,sf,radius,theta,pre/post doi)
% tuning = zeros(size(tuningAll,1),size(tuningAll,2),length(sfrange),length(radiusrange),length(thetarange),2);
% for i = 1:length(sfrange)
%     for j = 1:length(radiusrange)
%         for k = 1:length(thetarange)
%             for l = 1:2
%                 tuning(:,:,i,j,k,l) = squeeze(mean(tuningAll(:,:,find(sf==sfrange(i)&radius==radiusrange(j)&theta==thetarange(k)),l),3));
%             end
%         end
%     end
% end
% 
% %find the maximum response for each cell to any sf/orientation combo
% usetuning = tuning(use,:,:,:,:,:);
% sizeresp = zeros(size(usetuning,1),size(usetuning,2),length(radiusrange),2);
% for i = 1:size(usetuning,1)
%     for l = 1:size(usetuning,6)
%         maxresp = 0;
%         for j = 1:length(sfrange)
%             for k = 1:length(thetarange)
%                 resp = usetuning(i,8,j,2,k,l);
%                 if resp > maxresp
%                     maxresp = resp;
%                     ideal = [j k];
%                 end
%             end
%         end
%         for m = 1:length(radiusrange)
%             sizeresp(i,:,m,l) = usetuning(i,:,ideal(1),m,ideal(2),l);
%         end
%     end
% end
% 
%% get average and se across cells for pre and post doi responses across sizes
% avgPreSize = squeeze(mean(sizeresp(:,8,:,1),1));
% sePreSize = squeeze(std(sizeresp(:,8,:,1),1)/sqrt(size(sizeresp,1)));
% avgPostSize = squeeze(mean(sizeresp(:,8,:,2),1));
% sePostSize = squeeze(std(sizeresp(:,8,:,2),1)/sqrt(size(sizeresp,1)));
% 
% figure
% hold on
% errorbar(1:length(radiusrange),avgPreSize,sePreSize)
% errorbar(1:length(radiusrange),avgPostSize,sePostSize)
