%load(fname,'dfof_bg');
%close all
load('D:\grating3x5_2sf10min');
imagerate=10;

% tf(tf==2)=1;
% sf(sf==0.02)=0.04;
% sf(sf==0.16)=0.32;
imageT=(1:size(dfof_bg,3))/imagerate;
img = imresize(double(dfof_bg),1,'method','box');

xpos=xpos(1:300); ypos=ypos(1:300); sf=sf(1:300); tf=tf(1:300);
trials = length(sf)-1;
% tic
% img=deconvg6s(dfof_bg,1/imagerate);
% toc
% trials=trials-1;

acqdurframes = (duration+isi)*imagerate;
figure
clear cycavg
nx=ceil(sqrt(acqdurframes));
for f=1:acqdurframes
    cycavg(:,:,f) = mean(img(:,:,f:acqdurframes:end),3);
    subplot(nx,nx,f)
    imagesc(squeeze(cycavg(:,:,f)),[-0.02 0.02])
    %axis off
end

useframes = 6:8;
base = 1:3;
% useframes =7:12;
% base = 1:3;

% useframes = 8:10;
% base = 1:2;
trialdata = zeros(size(img,1),size(img,2),trials+2);
trialspeed = zeros(trials+2,1);
for tr=1:trials;
    t0 = (tr-1)*duration*imagerate+tr*isi*imagerate+1;
    baseframes = base+t0; baseframes=baseframes(baseframes>0);
    trialdata(:,:,tr)=mean(img(:,:,useframes+t0),3) -mean(img(:,:,baseframes),3);
   try
       trialspeed(tr) = mean(sp(useframes+t0));
   catch
       trialspeed(tr)=500;
   end
end

if length(unique(xpos))>1
[xph xamp xtuning] = getPixelTuning(trialdata,xpos,'X',[2 4],hsv);
end
if length(unique(ypos))>1
[yph yamp ytuning] = getPixelTuning(trialdata,ypos,'Y',[1 3],hsv);
end
if length(unique(sf))>1
    [sfph sfamp sftuning] = getPixelTuning(trialdata,sf,'SF', [1 5],jet);
end
if length(unique(tf))>1
[tfph tfamp tftuning] = getPixelTuning(trialdata,tf,'TF',[1 4],jet);
end


spd = tf./sf;
spd(tf==0)=0;
spd(sf==0)=0;
unique(spd)
spd(spd==0)=1.6;
spd=log(spd);
if length(unique(spd))>1
[tfph tfamp tftuning] = getPixelTuning(trialdata,spd,'speed',[1 5],jet);
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
        imagesc(squeeze(tuning(:,:,1,1,i,j)),[ 0 0.05]);
        title(sprintf('%0.2fcpd %0.2fhz',sfrange(i),tfrange(j)))
        axis off
    end
end

figure
for i = 1:length(xrange)
    for j=1:length(yrange)
        subplot(length(xrange),length(yrange),length(yrange)*(i-1)+j)
        imagesc(squeeze(mean(tuning(:,:,i,j,:,1),5)),[ 0 0.05]);
        title(sprintf('%0.2fcpd %0.2fhz',i,j))
        axis off
    end
end


keyboard
for tr = 1:trials;
    data=zeros(length(sfrange),length(tfrange));
    data(find(sfrange==sf(tr)),find(tfrange==tf(tr)))=1;
    data=data(:);
    data(end+1)=trialspeed(tr)>500;
    alldata(tr,:)=data;
end

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

