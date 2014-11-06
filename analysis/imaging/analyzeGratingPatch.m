function [ph amp] = analyzeGratingPatch(dataname,moviename,useframes,base);
%load(fname,'dfof_bg');
%close all

if exist('dataname','var')
    load(dataname,'dfof_bg');
end

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
trials = min(trials,size(dfof_bg,3)/(imagerate*(duration+isi)))-1
xpos=xpos(1:trials); ypos=ypos(1:trials); sf=sf(1:trials); tf=tf(1:trials);
% tic
% img=deconvg6s(dfof_bg,1/imagerate);
% toc
% trials=trials-1;

acqdurframes = (duration+isi)*imagerate;
figure
clear cycavg
nx=ceil(sqrt(acqdurframes));

figure
for f=1:acqdurframes
    cycavg(:,:,f) = mean(img(:,:,f:acqdurframes:end),3);
    subplot(nx,nx,f)
    imagesc(squeeze(cycavg(:,:,f)),[-0.02 0.02])
    %axis off
end

figure
for f=1:acqdurframes
    cycavgstart(:,:,f) = mean(img(:,:,f:acqdurframes:round(end/4)),3);
    subplot(nx,nx,f)
    imagesc(squeeze(cycavgstart(:,:,f)),[-0.02 0.02])
    %axis off
end


for f=1:acqdurframes
    cycavgend(:,:,f) = mean(img(:,:,round(3*end/4)+f:acqdurframes:end),3);
    subplot(nx,nx,f)
    imagesc(squeeze(cycavgend(:,:,f)),[-0.02 0.02])
    %axis off
end



[y x] = ginput(1);
y= round(y); x= round(x);
range = -2:2;
figure
plot(squeeze(mean(mean(img(x+range,y+range,:),2),1)))

figure
plot(squeeze(mean(mean(cycAvg,2),1)))
hold on
plot(squeeze(mean(mean(cycavgstart,2),1)),'g')
plot(squeeze(mean(mean(cycavgend,2),1)),'r')

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
    t0 = (tr-1)*(duration+isi)*imagerate;
    baseframes = base+t0; baseframes=baseframes(baseframes>0);
    trialdata(:,:,tr)=mean(img(:,:,useframes+t0),3) -mean(img(:,:,baseframes),3);
   try
       trialspeed(tr) = mean(sp(useframes+t0));
   catch
       trialspeed(tr)=500;
   end
 
end

if length(unique(xpos))>1
[ph(:,:,1) amp(:,:,1) xtuning] = getPixelTuning(trialdata,xpos,'X',[1 length(unique(xpos))],hsv);
end
if length(unique(ypos))>1
[ph(:,:,2) amp(:,:,2) ytuning] = getPixelTuning(trialdata,ypos,'Y',[1 3],hsv);
end
if length(unique(sf))>1
    [ph(:,:,3) amp(:,:,3) sftuning] = getPixelTuning(trialdata,sf,'SF', [1 length(unique(sf))],jet);
end
if length(unique(tf))>1
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


xrange = unique(xpos); yrange=unique(ypos); sfrange=unique(sf); tfrange=unique(tf);
tuning=zeros(size(trialdata,1),size(trialdata,2),length(xrange),length(yrange),length(sfrange),length(tfrange));
for i = 1:length(xrange)
    for j= 1:length(yrange)
        for k = 1:length(sfrange)
            for l=1:length(tfrange)
              %  length(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l)))
                tuning(:,:,i,j,k,l) = squeeze(mean(trialdata(:,:,find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l))),3));
            meanspd(i,j,k,l) = squeeze(mean(trialspeed(find(xpos==xrange(i)&ypos==yrange(j)&sf==sfrange(k)&tf==tfrange(l)))>500));
            end
        end
    end
end

figure
for i = 1:length(sfrange)
    for j=1:length(tfrange)
        subplot(length(sfrange),length(tfrange),length(tfrange)*(i-1)+j)
        imagesc(squeeze(mean(mean(tuning(:,:,:,:,i,j),4),3)),[ 0 0.05]);
        title(sprintf('%0.2fcpd %0.2fhz',sfrange(i),tfrange(j)))
        axis off; axis equal
    end
end

if length(xrange)<=3
merge = zeros(size(tuning,1),size(tuning,2),3);
figure
for i = 1:length(xrange)
    for j=1:length(yrange)
        subplot(length(xrange),length(yrange),length(yrange)*(i-1)+j)
        imagesc(squeeze(mean(tuning(:,:,i,j,:,1),5)),[ 0 0.05]);
        merge(:,:,i) = squeeze(mean(tuning(:,:,i,j,:,1),5))/0.03;
        title(sprintf('%0.2fx %0.2fy',xrange(i),xrange(j)))
        axis off; axis equal
    end
end

merge(merge<0)=0; merge(merge>1)=1;
figure
imshow(merge);
end

for doResolutionTest=1:0
figure
for i = 2:2
    for j=1:length(yrange)
        
        spotimg = squeeze(mean(tuning(:,:,i,j,:,1),5));
        imagesc(spotimg,[0 0.03]);
        title(sprintf('%0.2fx %0.2fy',i,j))
        axis off; axis equal
    end
end



[y x] = ginput(1);
crossSection = spotimg(:,round(y));
figure
plot(crossSection);
crossSection = mean(spotimg(round(x)+(-1:1),:),1);
figure
plot(crossSection);
crossSection = crossSection(100:199);
baseline_est=median(crossSection);
[peak_est x0_est] = max(crossSection);
sigma_est=5;
x=1:length(crossSection);
y=crossSection;
fit_coeff = nlinfit(x,y,@gauss_fit,[ baseline_est peak_est x0_est sigma_est])

%%% parse out results
baseline = fit_coeff(1)
peak = fit_coeff(2)
x0=fit_coeff(3)
sigma_est=fit_coeff(4)

%%% plot raw data and fit
figure
plot(x,y)
hold on
plot(x,gauss_fit(fit_coeff,x),'g')

fwhm = 2*sigma_est*1.17*32.5

keyboard
end

keyboard
for tr = 1:trials;
    data=zeros(length(sfrange),length(tfrange));
    data(find(sfrange==sf(tr)),find(tfrange==tf(tr)))=1;
    data=data(:);
    data(end+1)=trialspeed(tr)>500;
    alldata(tr,:)=data;
end

keyboard
%alldata(alldata<0)=0;
clear p0
for i = 1:size(img,1);
    i
    for j=1:size(img,2);
        d= squeeze(tuning(i,j,1,1,:,:));
      p0= d(:); 
      p0(end+1)=1;
      p = nlinfit(alldata,squeeze(trialdata(i,j,1:length(alldata))),@visualGain,p0);
      fittuning(i,j,:,:) = reshape(p(1:end-1),length(sfrange),length(tfrange));
      gain(i,j)=p(end);
    end
    
end

figure
imagesc(gain,[-1 1])

figure
for i = 1:length(sfrange)
    for j=1:length(tfrange)
        subplot(length(sfrange),length(tfrange),length(tfrange)*(i-1)+j)
        imagesc(squeeze(fittuning(:,:,i,j)),[ 0 0.05]);
        title(sprintf('%0.2fcpd %0.2fhz',sfrange(i),tfrange(j)))
        axis off
    end
end

sftuning = squeeze(mean(fittuning,4)); tftuning=squeeze(mean(fittuning,3));

showTuning(sftuning,[1 5],jet,'SF');
showTuning(tftuning,[1 4],jet,'TF');


% 
% 
% for i = 1:size(trialdata,1)
%     for j=1:size(trialdata,2)
%         [data xmax] = max(xtuning(i,j,:));
%         [data ymax] = max(ytuning(i,j,:));
%         
%         freqtuning(i,j,:,:)=squeeze(tuning(i,j,xmax,ymax,:,:));
%     end
% end
% 
% tic
% for x=1:size(img,1);
%     x
%     for y= 1:size(img,2);
%         curve= squeeze(tuning(x,y,:,:,:,:));
%             curve = reshape(curve,size(curve,1)*size(curve,2),size(curve,3)*size(curve,4));
%        curve(curve<0)=0;
%        [u v] = nnmf(curve,1);
%         spatial = reshape(u(:,1),size(tuning,3),size(tuning,4));
%         freq = reshape(v(1,:),size(tuning,5),size(tuning,6));
%         xtuning(x,y,:) = mean(spatial,2);
%         ytuning(x,y,:) = mean(spatial,1);
%         sftuning(x,y,:) = mean(freq,2);
%         tftuning(x,y,:) = mean(freq,1);
%     end
% end
% toc
% 
% showTuning(xtuning,[2 4],hsv,'X')
% showTuning(ytuning,[1.5 2.5],hsv,'Y');

% 
% 
% map=figure
% imagesc(mean(mean(mean(mean(tuning,3),4),5),6))
% for i =1:100;
%     figure(map);
% 
% [y x] = ginput(1); x= round(x);y=round(y);
%     figure
%     imagesc(squeeze(tuning(x,y,:,:,:,:)));
%     axis xy
% %     subplot(2,3,1)
% %     imagesc(squeeze(mean(mean(tuning(x,y,:,:,:,:),6),5))); axis equal; axis xy
% %     subplot(2,3,4);
% %     imagesc(squeeze(mean(mean(tuning(x,y,:,:,:,:),4),3))); axis equal; axis xy
% %     curve = squeeze(tuning(x,y,:,:,:,:));
% %     curve = reshape(curve,size(curve,1)*size(curve,2),size(curve,3)*size(curve,4));
% %     curve(curve<0)=0;
% %     [u v] = nnmf(curve,1);
% %   
% %     subplot(2,3,6)
% %     plot(s(1:5));
% %     subplot(2,3,2)
% %     imagesc(reshape(u(:,1),5,3)); axis xy
% %     subplot(2,3,5);
% %     imagesc(reshape(v(1,:),3,3)); axis xy
% %     weights = mean(curve,2);
% %     weights(weights<0)=0;
% %    weighted = curve.*repmat(weights,[1 size(curve,2)]);
% %    freq = mean(weighted,1);
% %    subplot(2,3,3)
% %    imagesc(reshape(freq,3,3)); axis xy

% %end

