function [pts dF ptsfname icacorr cellImg usePts] = get2pPtsAuto(dfofInterp, greenframe, x,y,refFrame,w, showImg);
%%% automatically extracts fluorescence traces based on generic points


oldPts(:,1) = x; oldPts(:,2)=y;

greenframe = imresize(double(greenframe),size(refFrame));

im(:,:,1)=0.8*refFrame/prctile(refFrame(:),98);
im(:,:,2) = 0.8*greenframe/prctile(greenframe(:),98);
im(:,:,3)=0;
figure
imshow(im)
title('not aligned !!')

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

im(:,:,1)=0.8*refFrame/prctile(refFrame(:),98);
im(:,:,2) = 0.8*(circshift(greenframe,-[shiftx shifty]))/prctile(greenframe(:),98);
im(:,:,3)=0;
figure
imshow(im)
title('aligned')


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
cellImg = zeros(length(pts),2*w+1,2*w+1); 

tic
%%% can make this a parfor but need to fix assignment
% display('starting parpool')
% gcp

for p = 1:length(pts);
    if p/20 == round(p/20)
        sprintf('%d of %d = %0.2',p,length(pts),p/length(pts))
    end
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
    subplot(10,12,i);
    range = max([0.01 abs(min(min(cellImg(use(i),:,:)))) abs(max(max(cellImg(use(i),:,:))))]);
    imagesc(squeeze(cellImg(use(i),:,:)),[-range range]); colormap jet
    axis off
    set(gca,'LooseInset',get(gca,'TightInset'))
end

figure
hist(icacorr,[0.025:0.05:1])

figure
plot(icacorr,filling,'o')
xlabel('ica match corrcoef'); ylabel('filling fraction')

figure
imagesc(reshape(coverage,[size(dfofInterp,1) size(dfofInterp,2)]));

cc = corrcoef(dF');
d = dist(pts');
figure
plot(d(:),cc(:),'.');
xlabel('distance'); ylabel('correlation'); title('check for duplicates')
dups = find(cc>0.85 & d<10 & d>0);
length(dups)
[i j] = ind2sub(size(cc),dups);
uppers = max(i,j);
dF(uppers,:)=0;

% c = 'rgbcmk'
% figure
% hold on
% use = find(mean(dF,2)~=0);
% for i = 1:length(use);
%     plot(dF(use(i),50:end)/max(dF(use(i),:)) + i/2,c(mod(i,6)+1));
% end

sprintf('found %d cells out of %d = %0.2f',length(use),size(dF,1),length(use)/size(dF,1))

greenframe = refFrame;
ptsfname = []; %%% obsolete


