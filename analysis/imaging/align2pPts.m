function [pts dF ptsfname icacorr cellImg] = align2pPts(dfofInterp, greenframe);

[f p] = uigetfile('*.mat','previous points file');
load(fullfile(p,f),'x','y','refFrame');
oldPts(:,1) = x; oldPts(:,2)=y;

im(:,:,1)=refFrame/prctile(refFrame(:),95);
im(:,:,2) = greenframe/prctile(greenframe(:),95);
im(:,:,3)=0;
figure
imshow(im)

ref = refFrame-mean(refFrame(:));
gr = greenframe-mean(greenframe(:));
for dx=-20:20;
    for dy = -20:20;
        xc(dx+21,dy+21)=sum(sum(circshift(ref,[dx dy]).*gr));
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

figure
imagesc(sigma,[0 prctile(sigma(:),95)]);
hold on
plot(pts(:,2),pts(:,1),'g*')

dfReshape = reshape(dfofInterp,[size(dfofInterp,1)*size(dfofInterp,2) size(dfofInterp,3)]);
clear usePts dF
coverage=zeros(size(dfofInterp,1)*size(dfofInterp,2),1);
dF = zeros(length(pts),size(dfofInterp,3));
gcp
    w=4; %w=5 for cells
  showImg = input('show images? 0/1 ');
  tic
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

figure
nx = ceil(sqrt(length(use)));
for i = 1:length(use)
    i
    subplot(nx,nx,i);
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
    save(fullfile(p,f),'pts','dF','coverage','greenframe');
end
ptsfname = fullfile(p,f);


