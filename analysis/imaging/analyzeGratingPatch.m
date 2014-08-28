load(fname,'dfof_bg');
load(moviefname);
imagerate=10;


imageT=(1:size(dfof_bg,3))/imagerate;
img=deconvg6s(dfof_bg,1/imagerate);
trials=trials(1:end-1);

acqdurframes = (duration+isi)*imagerate;
figure
for f=1:acqdurframes
    cycavg(:,:,f) = median(img(:,:,f:acqdurframes:end),3);
    subplot(4,3,f)
    imagesc(squeeze(cycavg(:,:,f)),[0 0.1])
end

useframes = 2:6;
base = -2:0;
for tr=1:trials;
    t0 = (t-1)*duration*imagerate+t*isi*imagerate+1;
    baseframes = base+t0; baseframes=baseframes(baseframes>0);
    trialdata(:,:,tr)=mean(img(:,:,useframes+t0),3) -mean(img(:,:,baseframes),3);
end

[ph amp tuning] = getPixelTuning(trialdata,xpos,'X');
[ph amp tuning] = getPixelTuning(trialdata,ypos,'Y');
[ph amp tuning] = getPixelTuning(trialdata,sf,'SF');
[ph amp tuning] = getPixelTuning(trialdata,tf,'TF');

