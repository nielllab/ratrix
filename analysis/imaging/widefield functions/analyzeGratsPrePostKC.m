%% analyzeGratsPrePostKC
close all
clear all
dbstop if error

[prefile p] = uigetfile('*.mat','select PRE file');
cd(p)
[postfile p] = uigetfile('*.mat','select POST file');
fnames = {prefile,postfile};
mycol = {'k','r'};
areas = {'V1','LM','AL','RL','AM','PM','MM'};
pltrange = [0 0.01];

load('F:\Widefield_Analysis\Kristen\CrisPts.mat')
load('C:\mapOverlay5mm.mat')
ptsrange = 2;
dt=0.1;
f1 = figure;f2 = figure;
cnt=1;
for f = 1:length(fnames)
    clear cycavg
    load(fullfile(p,fnames{f}),'cycavg')
    if length(size(cycavg))==4
        semcycavg = std(cycavg,[],4)/sqrt(size(cycavg,4));
        cycavg = mean(cycavg,4);
    else
        semcycavg = zeros(size(cycavg));
    end
    cycavg = circshift(cycavg,5,3);
    figure(f1)
    for i = 1:length(x)
        subplot(2,round(length(x)/2),i)
        hold on
        im = cycavg(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:);
        im = squeeze(mean(mean(im,2),1));
        im = im-(mean(im(1:2)));
        sim = semcycavg(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:);
        sim = squeeze(mean(mean(sim,2),1));
        sim = sim-(mean(sim(1:2)));
        shadedErrorBar(0:dt:length(im)*dt-dt,im,sim,mycol{f},1)
        axis([0 length(im)*dt-dt -0.005 0.03])
        ylabel(sprintf('%s dfof',areas{i}))
        xlabel('time (s)')
        axis square
    end
    
    figure(f2)
    colormap jet
    for i = 4:10
        subplot(2,7,cnt)
        im = squeeze(cycavg(:,:,i));
        imagesc(im,pltrange)
        hold on; plot(ypts,xpts,'w.','Markersize',2);
        axis image
        axis off
        cnt=cnt+1;
    end
    
end
figure(f2)
mtit('pre (top) vs. post (bottom) cycle average')
figure(f1)
legend('pre','post')
subplot(2,round(length(x)/2),length(x)+1)
colormap jet
im = mean(cycavg(:,:,6:8),3)-mean(cycavg(:,:,1:2),3);
imagesc(im,pltrange)
hold on; plot(ypts,xpts,'w.','Markersize',2);
for i = 1:length(x)
    plot(y(i),x(i),'k.','MarkerSize',10)
end
axis image
axis off
mtit('cycle averages for each visual area')