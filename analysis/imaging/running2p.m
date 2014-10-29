%function running2p(fname,spname,label);
% fname ='running area - darkness stim - zoom1004.tif'
% spname = 'running area - darkness stim - zoom1004_stim_obj.mat';
close all
clear all
label = 'running';

[f p] = uigetfile('*.tif','tif file');
fname = fullfile(p,f)

[img, framerate] = readAlign2p(fname,1,1,.5);
nframes=size(img,3)
[f p] =uigetfile('*.mat','speed data');
spname = fullfile(p,f);

% m=mean(img,3);
% figure
% imagesc(m);
% colormap(gray)
m = prctile(img,10,3);
% figure
% imagesc(m);
% colormap(gray)


dfof=zeros(size(img));
for f = 1:nframes
    dfof(:,:,f)=(img(:,:,f)-m)./m;
end


interval = 1/framerate;
load(spname);

mouseT = stimRec.ts- stimRec.ts(1);
%     figure
%     plot(diff(mouseT));
%

mouseMax = max(mouseT)
frameMax = nframes/framerate
if max(mouseT)<(nframes/framerate)
    display('duration of mouse times is less than duration of 2p images')
    nframes = floor(mouseMax*framerate);
    dfof = dfof(:,:,1:nframes);
    img = img(:,:,1:nframes);
end

meanimg = squeeze(mean(mean(img,2),1));
meandf = squeeze(mean(mean(dfof,2),1));

dt = diff(mouseT);
use = [1>0; dt>0];
mouseT=mouseT(use);

posx = cumsum(stimRec.pos(use,1)-900);
posy = cumsum(stimRec.pos(use,2)-500);
frameT = interval:interval:max(mouseT);
vx = diff(interp1(mouseT,posx,frameT));
vy = diff(interp1(mouseT,posy,frameT));
vx(end+1)=0; vy(end+1)=0;
%
%     figure
%     plot(vx); hold on; plot(vy,'g');
sp = sqrt(vx.^2 + vy.^2);
%     figure
%     plot(sp)


sp = sp(1:length(meandf));
%spshift = circshift(spshift,25);


figure
plot((1:nframes)/framerate,meandf);
hold on
plot(frameT(1:length(sp)),sp/max(sp),'g');
xlabel('time');
legend('dfof','speed');
title(label);


figure

[xcc lag] = xcorr(sp-mean(sp),meandf-mean(meandf),'coeff');
plot(xcc);
[y ind] = max(abs(xcc(lag>0 & lag<240)));
lag = lag(lag>0 & lag<240);
title(sprintf('xc = %f lag = %d',xcc(ind),lag(ind)));

offset = lag(ind);

meandfshift = meandf(offset:end);
spshift = sp(1:end-offset+1);

spshift = sp;
meandfshift=circshift(meandf,offset);

figure
[xcc lag] = xcorr(spshift-mean(spshift),meandfshift-mean(meandfshift),'coeff');
plot(xcc);
[y ind] = max((xcc));
title(sprintf('xc = %f lag = %d',xcc(ind),lag(ind)));

%     figure
%     plot(xcorr(sp-mean(sp),meanimg-mean(meanimg)))

display('calculating xcorr')
tic
for x = 1:size(dfof,1);
    x
    for y = 1:size(dfof,2);
        xc(x,y) = xcorr(circshift(squeeze((dfof(x,y,:))),offset)-mean(dfof(x,y,:)),sp(1:size(dfof,3))'-mean(sp),0,'coeff');
        %  xc(x,y) = corr(squeeze(dfof(x,y,:)),sp(1:size(dfof,3))','type','spearman');
    end
end
toc
fig = figure;
imagesc(xc,[-0.5 0.5]); axis square
title([label 'speed xcorr']);
for i = 1:5;
    figure(fig)
    [y x] = ginput(1);
    figure
    df = circshift(squeeze(dfof(round(x),round(y),:)),offset);
    plot((1:nframes)/framerate,df/max(df),'g');
    
    hold on
    plot((1:nframes)/framerate, sp(1:size(dfof,3))/max(sp),'b');
    legend('fluorescence','speed');
    
    figure
    plot(xcorr(sp(1:size(dfof,3))-mean(sp(1:size(dfof,3))), df-mean(df),'coeff'));
    [xcc lag] = xcorr(sp(1:size(dfof,3))-mean(sp(1:size(dfof,3))), df-mean(df),'coeff');
    [y ind] = max(abs(xcc));
    title(sprintf('xc = %f lag = %d',xcc(ind),lag(ind)));
end




