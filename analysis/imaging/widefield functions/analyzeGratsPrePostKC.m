%% analyzeGratsPrePostKC
close all
clear all
dbstop if error

[prefile p] = uigetfile('*.mat','select PRE file');
cd(p)
[postfile p] = uigetfile('*.mat','select POST file');
fnames = {prefile,postfile};
mycol = {'k','r'}; %colors for plotting
areas = {'V1','LM','AL','RL','AM','PM','MM'}; %labels for the different areas
pltrange = [0 0.01]; %colormap range for plotting images
pplabel = {'pre','post'}; %label for pre/post for graphing

load('F:\Kristen\CrisPts.mat') %selected points for looking at cycle averages for each area
load('C:\mapOverlay5mm.mat') %borders of visual areas for plotting
ptsrange = 2; %number of points to average over around points for each area
dt=0.1; %time between imaging frames
f1 = figure;f2 = figure; %initialize figures
cnt=1; %counter to plot pixel-wise responses
for f = 1:length(fnames)
    clear cycavg tuningall
    load(fullfile(p,fnames{f}),'cycavg','tuningall') %load in other variables here
    if length(size(cycavg))==4 %case with a group
        semcycavg = std(cycavg,[],4)/sqrt(size(cycavg,4));
        cycavg = mean(cycavg,4);
    else %case with an individual animal
        semcycavg = zeros(size(cycavg));
    end
    %cycavg = circshift(cycavg,5,3); %not sure why this was here...
    figure(f1)
    for i = 1:length(x) %loop through all the visual areas
        subplot(2,round(length(x)/2)+1,i)
        hold on
        im = cycavg(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:); %calculate trace for that vis area
        im = squeeze(mean(mean(im,2),1)); %average and squeeze it so it's 2D
        im = im-(mean(im(1:2)));
        sim = semcycavg(x(i)-ptsrange:x(i)+ptsrange,y(i)-ptsrange:y(i)+ptsrange,:);%calc standard error of the trace
        sim = squeeze(mean(mean(sim,2),1));
        sim = sim-(mean(sim(1:2)));
        shadedErrorBar(0:dt:length(im)*dt-dt,im,sim,mycol{f},1)%plot mean and sem
        axis([0 length(im)*dt-dt -0.005 0.03])
        ylabel(sprintf('%s dfof',areas{i})) %label which area it is
        xlabel('time (s)')
        axis square
    end
    subplot(2,round(length(x)/2)+1,length(x)+1)
    colormap jet
    im = mean(cycavg(:,:,6:8),3)-mean(cycavg(:,:,1:2),3);
    imagesc(im,pltrange)
    hold on; plot(ypts,xpts,'w.','Markersize',2);
    for i = 1:length(x)
        plot(y(i),x(i),'k.','MarkerSize',10)
    end
    axis image
    axis off
    
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
    
    figure
    for i = 1:length(size(tuningall,3))
        for j=1:length(size(tuningall,4))
            subplot(size(tuningall,3),size(tuningall,4),size(tuningall,3)*(j-1)+i)
            imagesc(squeeze(mean(mean(mean(tuningall(:,:,i,j,:,:,:),6),5),7)),range); colormap jet
%             title(sprintf('%0.2f %0.2f',xrange(i),yrange(j)))
            axis off; axis equal
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            set(gca,'LooseInset',get(gca,'TightInset'))
        end
    end
    mtit(sprintf('%s peak response/spatial location',pplabel{f}))
    
end
figure(f2)
mtit('pre (top) vs. post (bottom) cycle average')
figure(f1)
legend('pre','post')
mtit('cycle averages for each visual area')