[f p] = uigetfile('*.mat','topox pts')
load(fullfile(p,f));
xPhase = phaseVal;
xdF = dF;
sprintf('%d topox pts',sum(mean(xdF,2)~=0));


[f p] = uigetfile('*.mat','topoy pts')
load(fullfile(p,f));
yPhase = phaseVal;
ydF = dF;
sprintf('%d topoy pts',sum(mean(ydF,2)~=0));

[f p] = uigetfile('*.mat','behav pts')
load(fullfile(p,f));
sprintf('%d behav pts',sum(mean(dF,2)~=0));

activePts = find(mean(dF,2)~=0 & mean(xdF,2)~=0 & mean(ydF,2)~=0);
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

figure
imagesc(squeeze(mean(allTrials,2))',[0 1])


leftResp = max(allTrials(6,1:2,:),[],2);
leftResp = squeeze(leftResp-mean(allTrials(4,1:2,:),2));
leftRespAll = zeros(1,length(goodTopo));
leftRespAll(usenonzero) = leftResp;

rightResp = max(allTrials(6,3:4,:),[],2);
rightResp = squeeze(rightResp-mean(allTrials(4,3:4,:),2));
rightRespAll = zeros(1,length(goodTopo));
rightRespAll(usenonzero) = rightResp;
figure
plot(leftRespAll,rightRespAll,'o')

figure; hold on
for i = 1:length(activePts)
    if goodTopo(activePts(i))
        plot(rfpts(activePts(i),1),rfpts(activePts(i),2),'o','Color',cmapVar(leftRespAll(activePts(i)),0,1,jet))
    end
end
axis equal; axis([0 72 0 128])

figure; hold on
for i = 1:length(activePts)
    if goodTopo(activePts(i))
        plot(rfpts(activePts(i),1),rfpts(activePts(i),2),'o','Color',cmapVar(rightRespAll(activePts(i)),0,1,jet))
    end
end
axis equal; axis([0 72 0 128])

figure; hold on
for i = 1:length(activePts)
    if goodTopo(activePts(i))
        plot(rfpts(activePts(i),1),rfpts(activePts(i),2),'o','Color',cmapVar(rightRespAll(activePts(i))-leftRespAll(activePts(i)),-1,1,jet))
    end
end
axis equal; axis([0 72 0 128])

        
        figure
        plot(rfpts(activePts,2),rightRespAll(activePts),'o')
        
         figure
        plot(rfpts(activePts,2),leftRespAll(activePts),'o')
        figure
        plot(rfpts(activePts,2),rightRespAll(activePts)-leftRespAll(activePts),'o')
        