function [pts dF ptsfname icacorr cellImg usePts] = get2pPtsAuto(dfofInterp, greenframe);
%%% automatically extracts fluorescence traces based on generic points

[f p] = uigetfile('*.mat','generic points file');
load(fullfile(p,f),'x','y','refFrame');
oldPts(:,1) = x; oldPts(:,2)=y;

greenframe = imresize(greenframe,size(refFrame));

im(:,:,1)=refFrame/prctile(refFrame(:),95);
im(:,:,2) = greenframe/prctile(greenframe(:),95);
im(:,:,3)=0;
figure
imshow(im)

ref = refFrame-mean(refFrame(:));
gr = greenframe-mean(greenframe(:));
for dx=-20:20;
    for dy = -20:20;
               cs = circshift(ref,[dx dy]);
        xc(dx+21,dy+21)=sum(sum(cs(20:end-20,20:end-20).*gr(20:end-20,20:end-20)));
    end
end
figure
imagesc(xc);
[m ind] = max(xc(:));
[shiftx shifty] = ind2sub([41 41],ind);
shiftx=shiftx-21
shifty=shifty-21

pts(:,1) = oldPts(:,1)+shiftx;
pts(:,2) = oldPts(:,2)  +shifty;

mn = mean(dfofInterp,3);
sigma = std(dfofInterp,[],3);

sigmafig = figure
imagesc(sigma,[0 prctile(sigma(:),99)]);
hold on
plot(pts(:,2),pts(:,1),'k.')

dfReshape = reshape(dfofInterp,[size(dfofInterp,1)*size(dfofInterp,2) size(dfofInterp,3)]);
clear usePts dF
coverage=zeros(size(dfofInterp,1)*size(dfofInterp,2),1);
dF = zeros(length(pts),size(dfofInterp,3));

sprintf('enter width of window for cell body extraction')
sprintf('typical = 4 for puncta, 6 for cell body, but depends of fov and zoom')
w = input('width : ');
showImg = input('show images? 0/1 ');
tic
%%% can make this a parfor
%%% gcp
for p = 1:length(pts);
    p  
    [dF(p,:) icacorr(p) filling(p) cellImg(p,:,:) usePts{p}] = getPtsParallel(dfofInterp,pts,w,p,mn,sigma,showImg);
end
toc

coverage = zeros(size(dfofInterp,1),size(dfofInterp,2));
for p = 1:length(pts);
    coverage(usePts{p})=p;
end

use = find(mean(dF,2)~=0);

figure(sigmafig)
plot(pts(use,2),pts(use,1),'ko');

figure
nx = ceil(sqrt(length(use)));
for i = 1:min(length(use),120)
    i
    subplot(10,12,i);
    range = max([0.01 abs(min(min(cellImg(use(i),:,:)))) abs(max(max(cellImg(use(i),:,:))))]);
    imagesc(squeeze(cellImg(use(i),:,:)),[-range range])
    axis off
    set(gca,'LooseInset',get(gca,'TightInset'))
end

figure
hist(icacorr,[0.025:0.05:1])

figure
plot(icacorr,filling,'o')

figure
imagesc(reshape(coverage,[size(dfofInterp,1) size(dfofInterp,2)]));

cc = corrcoef(dF');
d = dist(pts');
figure
plot(d(:),cc(:),'.');
dups = find(cc>0.85 & d<10 & d>0);
length(dups)
[i j] = ind2sub(size(cc),dups);
uppers = max(i,j);
dF(uppers,:)=0;

c = 'rgbcmk'
figure
hold on
use = find(mean(dF,2)~=0);
for i = 1:length(use);
    plot(dF(use(i),50:1250)/max(dF(use(i),:)) + i/2,c(mod(i,6)+1));
end

greenframe = refFrame;
[f p] = uiputfile('*.mat','save points data');
if f~=0
    save(fullfile(p,f),'pts','dF','coverage','greenframe','usePts');
end
ptsfname = fullfile(p,f);


