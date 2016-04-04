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


[f p] = uigetfile('*.mat','topox session');
load(fullfile(p,f),'dfofInterp');
stdX = std(dfofInterp(:,:,4:4:end),[],3);
[f p] = uigetfile('*.mat','topoy session');
load(fullfile(p,f),'dfofInterp');
stdY = std(dfofInterp(:,:,4:4:end),[],3);
stdX = stdX/0.5; stdX(stdX>1)=1;
stdY = stdY/0.5; stdY(stdY>1)=1;

im = zeros(size(stdX,1),size(stdX,2),3);
im(:,:,1) = stdX;
im(:,:,2) = stdY;
figure
imshow(im)


