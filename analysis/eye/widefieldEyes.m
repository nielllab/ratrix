% close all
% clear all
% 
%  load('D:\Angie_analysis\widefield_data\021717_g62ss4-lt_blue\g62ss4-lt_run6_detection_post\g62ss4-lt_run6_detectionmaps.mat')
% 

%%% crop and downsize dF data to make it run faster
dfof_bg= dfof_bg(15:160,50:190,:);
dfof_bg = imresize(dfof_bg,0.5);
contrast = contrast(1:end-5); %%% cut off last few in case imaging stopped early

%%% median filter eye and speed data to remove transients
x = medfilt1(xEye,5); y= medfilt1(yEye,5);
v = medfilt1(sp,9); r = medfilt1(rad,7);

Xfilt = medfilt1(X,5); Yfilt = medfilt1(Y,5);
%%% show raw and filtered data
figure
plot(xEye); hold on; plot(x); title('x'); legend('raw','filtered')
figure
plot(rad); hold on; plot(r); title('r'); legend('raw','filtered')
figure
plot(sp); hold on; plot(v); title('v'); legend('raw','filtered')

%%% normalize eye/speed data (custom function nrm)
x = nrm(x); y = nrm(y); r= nrm(r); v = nrm(v);
%X = nrm(Xfilt(:,60:180)); Y=nrm(Yfilt)
figure
hist(x,0.01:0.02:1); title('x position')
% figure
% hist(Xfilt,0.01:0.02:1)
%%% plot a lot of comparisons!

left=unique(xpos(3))
right=unique(xpos(1))
use01 = find(contrast==.01&xpos==right)
use04 = find(contrast==.04&xpos==right)

figure
set(gcf,'Name','contrast= 0.04, Right Position')
for i=1:length(use04)
subplot(2,8,i)
plot(R(use04(i),:)); axis square ; ylim([10 25]); xlim([0 180]); hold on;
plot([60 60],[10 25],'g');  plot ([75 75],[10 25],'g');
subplot(2,8,i+8)
plot(Xfilt(use04(i),:),Yfilt(use04(i),:));hold on; axis square
xlim([40 70]);ylim([105 120])
plot(Xfilt(use04(i),:),Yfilt(use04(i),:),'.r');
end

figure
set(gcf,'Name','contrast= 0.01, Right Position')
for i=1:length(use01)
subplot(2,8,i)
plot(R(use01(i),:)); axis square ; ylim([10 25]); xlim([0 180]); hold on;
plot([60 60],[10 25],'g');  plot ([75 75],[10 25],'g');
subplot(2,8,i+8)
plot(Xfilt(use01(i),:),Yfilt(use01(i),:));hold on; axis square
xlim([40 70]);ylim([105 120])
plot(Xfilt(use01(i),:),Yfilt(use01(i),:),'.r');
end


figure
plot(x,y); title('eye position'); hold on; plot(x,y,'r.')
figure
plot(Xfilt(contrast==0.01,:));hold on; plot(Y(contrast==0.01,:))
figure
plot(frameT(1:length(x)),x/max(x)); title('X')
hold on
plot(frameT,v/max(v))

figure
plot(frameT(1:length(y)),y/max(y)); title('Y')
hold on
plot(frameT,v/max(v))

figure
plot(frameT(1:length(r)),r/max(r)); title('radius')
hold on
plot(frameT,v/max(v))


dF = squeeze(mean(mean(dfof_bg,2),1));
dF = nrm(dF);
figure
plot(frameT,dF/max(dF)); title('dF')
hold on
plot(frameT,v/max(v))

figure
plot(frameT,dF); title('dF')
hold on
plot(frameT,r)

figure
plot(r,dF,'.'); xlabel('r'); ylabel('dF');

figure
plot(v,dF,'.'); xlabel('v'); ylabel('dF');

figure
plot(x,dF,'.');xlabel('x'); ylabel('dF');

figure
plot(x,y,'.'); xlabel('x'); ylabel('y')

figure
plot(x,r,'.'); xlabel('x'); ylabel('r')


%%% align data to stim onsets
stimT = stimRec.ts - stimRec.ts(1);
figure
plot(diff(stimT))

isiFrames = 20; durFrames = 5;
vis = zeros(size(r));
nstim=0;
for trial = 1:length(contrast);
   trial
   start=  (trial-1)*(durFrames+isiFrames) + isiFrames;
    stop = start + durFrames;
    vis(start:stop) = contrast(trial);
    range = (start-isiFrames+1):(stop + 30);
    trialR(trial,:) = r(range);
    trialV(trial,:) = v(range);
    trialX(trial,:) = x(range);
    trialY(trial,:) = y(range);
    trialDF(trial,:,:,:) = dfof_bg(:,:,(start-1):(stop+10));
    %%% add other variables here = position and orientation
end

%%% look at averages for contrast==1
figure
trials = find(contrast==1);
for i = 1:16
    subplot(4,4,i);
    plot(trialX(trials(i),:)); xlim([1 size(trialV,2)])
    hold on; plot(trialR(trials(i),:));
      plot(isiFrames,0.5,'*');
     xlim([1 size(trialV,2)]); ylim([0 1])
     legend('eyeX', 'eyeR')
end

vis = vis(1:length(r));

%%% calculate change in variables (maybe better than actual position)
dx = [0 ; diff(x)];
dy = [0 ;diff(y) ];
dr = [ 0 ; diff(r)];
dv = [0 ; diff(v)];
dvis = [0 ; diff(vis)];
dvis(dvis<0)=0;

figure
imagesc(mean(dfof_bg(:,:,vis==1),3)- mean(dfof_bg(:,:,vis==0),3))
title('mean visual activation')


%%% perform regression on behavioral variables at multiple lags, and covert
%%% to images
clear vfit xcorr mx
for lag = -20:2:10;
    dfShift = circshift(dfof_bg,[0 0 lag]);
    clear vfit vcorr
    for i = 1:size(dfof_bg,1);
        i
        for j = 1:size(dfof_bg,2);
            [vfit(i,j,:) nil resid]= regress(squeeze(dfShift(i,j,:)),[v r   dvis abs(dx) dx ones(size(r))]);
            vcorr(i,j,:) = partialcorri(squeeze(dfShift(i,j,:)),[v r   dvis abs(dx) dx]);
        end
    end
    
    figure
    for i = 1:5
        subplot(2,3,i);
        if i<4
            im = mat2im(vfit(:,:,i),jet,[0 0.1]);
        elseif i==4
            im = mat2im(vfit(:,:,i),jet,[0 0.25]); 
        elseif i==5
            im = mat2im(vfit(:,:,i),jet,[-0.1 0.1]);
        end
        vc = vcorr(:,:,i);
        range = max(0.05, prctile(abs(vc(:)),95));
        im = im.*repmat(abs(squeeze(vcorr(:,:,i))),[1 1 3])/range;
        timecourse(:,:,:,i,(lag+20)/2 +1) = im
        imshow(imresize(im,5))
        mx(i,(lag+20)/2 +1) = prctile(abs(vc(:)),95);
        title(sprintf('r2 %0.2f',prctile(abs(vc(:)),95)));
    end
    set(gcf,'Name',sprintf('lag %d',lag));
    drawnow
end

figure
plot(-1:0.2:2,mx(:,end:-1:1)'); xlabel('secs'); ylabel('partial correlation')
legend('v','r','vis','abs(dx)','dx')

titles = {'V','R','vis stim','abs(dx)','dx'};
for i = 1:5
    figure
    for j = 1:12
    subplot(3,4,j)
    imshow(imresize(squeeze(timecourse(:,:,:,i,16-j)),2))
    end
    set(gcf,'Name',titles{i});
end

