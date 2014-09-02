%load(fname,'dfof_bg');
load('D:\gratingPatchesCloser');
imagerate=10;


imageT=(1:size(dfof_bg,3))/imagerate;
img = imresize(double(dfof_bg),0.5);

xpos=xpos(1:300); ypos=ypos(1:300); sf=sf(1:300); tf=tf(1:300);
trials = length(sf)-1;
% tic
% img=deconvg6s(dfof_bg,1/imagerate);
% toc
% trials=trials(1:end-1);

acqdurframes = (duration+isi)*imagerate;
figure
clear cycavg
for f=1:acqdurframes
    cycavg(:,:,f) = mean(img(:,:,f:acqdurframes:end),3);
    subplot(6,5,f)
    imagesc(squeeze(cycavg(:,:,f)),[-0.01 0.01])
    axis off
end

useframes = 6:8;
base = 1:3;
trialdata = zeros(size(img,1),size(img,2),trials+1);

for tr=1:trials;
    t0 = (tr-1)*duration*imagerate+tr*isi*imagerate+1;
    baseframes = base+t0; baseframes=baseframes(baseframes>0);
    trialdata(:,:,tr)=mean(img(:,:,useframes+t0),3) -mean(img(:,:,baseframes),3);
end

if length(unique(xpos))>1
[ph amp tuning] = getPixelTuning(trialdata,xpos,'X');
end
if length(unique(ypos))>1
[ph amp tuning] = getPixelTuning(trialdata,ypos,'Y');
end
if length(unique(sf))>1
    [ph amp tuning] = getPixelTuning(trialdata,sf,'SF');
end
if length(unique(tf))>1
[ph amp tuning] = getPixelTuning(trialdata,tf,'TF');
end