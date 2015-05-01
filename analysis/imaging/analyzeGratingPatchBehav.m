function [ tuning] = analyzeGratingPatch(dfof_bg,sp,moviename,useframes,base,xpts,ypts, label,stimRec);
%load(fname,'dfof_bg');
%close all
sf=0; tf=0; isi=0;


if exist('moviename','var')
    load(moviename)
else
    load('C:\resolutionTestClose5minRight.mat');
    %load('C:\grating3x5_2sf10min');
    %load('C:\grating5sf3tf_small_fast.mat')
    % load('D:\resolutionTestClose5min');
end
imagerate=10;

% tf(tf==2)=1;
% sf(sf==0.02)=0.04;
% sf(sf==0.16)=0.32;
imageT=(1:size(dfof_bg,3))/imagerate;
img = imresize(double(dfof_bg),1,'method','box');


trials = length(sf)-1;
trials = floor(min(trials,size(dfof_bg,3)/(imagerate*(duration+isi)))-1)
xpos=xpos(1:trials); ypos=ypos(1:trials); sf=sf(1:trials); tf=tf(1:trials); theta = theta(1:trials);
% tic
% img=deconvg6s(dfof_bg,1/imagerate);
% toc
% trials=trials-1;

acqdurframes = (duration+isi)*imagerate;


nx=ceil(sqrt(acqdurframes+1));

figure

map=0;
for f=1:acqdurframes
    cycavg(:,:,f) = mean(img(:,:,f:acqdurframes:end),3);
    subplot(nx,nx,f)
    imagesc(squeeze(cycavg(:,:,f)),[-0.05 0.05])
    axis off
    set(gca,'LooseInset',get(gca,'TightInset'))
    hold on; plot(ypts,xpts,'w.','Markersize',2)
    map = map+squeeze(cycavg(:,:,f))*exp(2*pi*sqrt(-1)*(0.5 +f/acqdurframes));
end

subplot(nx,nx,f+1)
plot(squeeze(mean(mean(cycavg,2),1)))
axis off


set(gca,'LooseInset',get(gca,'TightInset'))



% for lag = 1:9;
%     for f=1:acqdurframes
%     cycavglag(:,:,f,lag) = mean(img(:,:,f+(lag-1)*95*acqdurframes:acqdurframes:(lag)*95*acqdurframes),3);
% end
% end
% figure
% plot(squeeze(mean(mean(cycavglag,2),1)))

tcourse = squeeze(mean(mean(img,2),1));
fourier = tcourse'.*exp((1:length(tcourse))*2*pi*sqrt(-1)/(10*duration + 10*isi));

figure
plot((1:length(tcourse))/600,angle(conv(fourier,ones(1,600),'same')));
ylim([-pi pi])
ylabel('phase'); xlabel('mins')

% for i = 1:10
% figure
% imshow(imresize(polarMap(map/acqdurframes,98),4))
% hold on; plot(4*ypts,4*xpts,'w.','Markersize',2)
% [y x] = ginput(1);x= round(x/4);y= round(y/4);
% figure
% plot(squeeze(cycavg(x,y,:,:)))
% end


% [y x] = ginput(1);
% y= round(y); x= round(x);
% range = -2:2;
% figure
% plot(squeeze(mean(mean(img(x+range,y+range,:),2),1)))



meandf = squeeze(mean(mean(img,2),1));

if ~exist('useframes','var')
    useframes =24:27;
    base = 12:16;
    % useframes =7:12;
    % base = 1:3;
    
    % useframes = 8:10;
    % base = 1:2;
end

trialdata = zeros(size(img,1),size(img,2),trials+2);
trialspeed = zeros(trials+2,1);
for tr=1:trials;
    t0 = round((tr-1)*(duration+isi)*imagerate);
    baseframes = base+t0; baseframes=baseframes(baseframes>0);
    trialdata(:,:,tr)=mean(img(:,:,useframes+t0),3) -mean(img(:,:,baseframes),3);
    try
        trialspeed(tr) = mean(sp(useframes+t0));
    catch
        trialspeed(tr)=500;
    end
    
end

figure
set(gcf,'Name',label);
if length(unique(xpos))>1
    subplot(2,2,1)
    [ph(:,:,1) amp(:,:,1) xtuning] = getPixelTuning(trialdata,xpos,'X',[1 length(unique(xpos))],hsv);
end
if length(unique(ypos))>1
    subplot(2,2,2)
    [ph(:,:,2) amp(:,:,2) ytuning] = getPixelTuning(trialdata,ypos,'Y',[1 3],hsv);
end
if length(unique(sf))>1
    subplot(2,2,3)
    [ph(:,:,3) amp(:,:,3) sftuning] = getPixelTuning(trialdata,sf,'SF', [1 length(unique(sf))],jet);
end
if length(unique(tf))>1
    subplot(2,2,4)
    [ph(:,:,4) amp(:,:,4) tftuning] = getPixelTuning(trialdata,tf,'TF',[1 length(unique(tf))],jet);
end


spd = tf./sf;
spd(tf==0)=0;
spd(sf==0)=0;
unique(spd)
spd(spd==0)=1.6;
spd=log(spd);
if length(unique(spd))>1
    [ph(:,:,5) amp(:,:,5) tftuning] = getPixelTuning(trialdata,spd,'speed',[3 7],jet);
end


xrange = unique(xpos); yrange=unique(ypos); sfrange=unique(sf); tfrange=unique(tf); thetarange=unique(theta);
tuning=zeros(size(trialdata,1),size(trialdata,2),length(xrange),length(yrange),length(sfrange),length(thetarange));
cond = 0;


for i = 1:length(xrange)
    i
    for j= 1:length(yrange)
        for k = 1:length(sfrange)
            for l=1:length(thetarange)
                cond = cond+1;
                avgtrialdata(:,:,cond) = squeeze(median(trialdata(:,:,find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&theta==thetarange(l))),3));%  length(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l)))
                avgspeed(cond)=0;
                
                tuning(:,:,i,j,k,l) = avgtrialdata(:,:,cond);
                meanspd(i,j,k,l) = squeeze(mean(trialspeed(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&theta==thetarange(l)))>500));
            end
        end
    end
end

% for i = 1:3
%     for j= 1:4
%         use = find(xpos==xrange(i) & theta==thetarange(j));
%         figure
%         set(gcf,'Name',sprintf('x= %d theta= %d',i,j))
%         for k = 1:length(use)
%             subplot(3,4,k)
%             imagesc(trialdata(:,:,use(k)),[-0.2 0.2])
%         end
%
%     end
% end

range = [0 0.15];
figure
for i = 1:length(xrange)
    for j=1:length(yrange)
        subplot(length(yrange),length(xrange),length(xrange)*(j-1)+i)
        imagesc(squeeze(mean(mean(tuning(:,:,i,j,:,:),6),5)),range);
        
        axis off; axis equal
        hold on; plot(ypts,xpts,'w.','Markersize',2)
        set(gca,'LooseInset',get(gca,'TightInset'))
        title(sprintf('x = %d y = %d',i,j))
    end
end

if length(sfrange)==2
    for k = 1:2
        figure
        for i = 1:length(xrange)
            for j=1:length(yrange)
                subplot(length(yrange),length(xrange),length(xrange)*(j-1)+i)
                imagesc(squeeze(mean(mean(tuning(:,:,i,j,k,:),6),5)),range);
                title(sprintf('%0.2fcpd %0.2fhz',sfrange(i),tfrange(j)))
                axis off; axis equal
                hold on; plot(ypts,xpts,'w.','Markersize',2)
                set(gca,'LooseInset',get(gca,'TightInset'))
            end
        end
        title(sprintf('sf = %d',k));
    end
end

if length(xrange)==3
    figure
    for i = 1:length(xrange);
        for j = 1:length(thetarange)
            subplot(length(thetarange),length(xrange),length(xrange)*(j-1)+i)
            imagesc(squeeze(tuning(:,:,i,1,1,j)),range);
            title(sprintf('x= %d theta=%d',i,j))
            axis off; axis equal
            hold on; plot(ypts,xpts,'w.','Markersize',2)
            set(gca,'LooseInset',get(gca,'TightInset'))
        end
    end
end

tuning = squeeze(tuning);

