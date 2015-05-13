function [pts dF ptsfname] = align2pPts(dfofInterp, greenframe);

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
for p = 1:length(pts);
    x=pts(p,1); y= pts(p,2); npts=p;
    w=12; corrThresh=0.75; neuropilThresh=0.5;
    xmin=max(1,x-w); ymin=max(1,y-w);
    xmax = min(size(dfofInterp,1),x+w); ymax = min(size(dfofInterp,2),y+w);
    
    cc=0;
    for f= 1:size(dfofInterp,3);
        cc = cc+(dfofInterp(x,y,f)-mn(x,y))*(dfofInterp(xmin:xmax,ymin:ymax,f)-mn(xmin:xmax,ymin:ymax));
    end
    cc = cc./(size(dfofInterp,3)*sigma(x,y)*sigma(xmin:xmax,ymin:ymax));
    
    
    roi = zeros(size(sigma));
    roi(xmin:xmax,ymin:ymax) =cc;
    
    subplot(2,2,1);
    imagesc(roi,[0 1]);
    axis equal
    
    subplot(2,2,2);
    imagesc(roi>corrThresh); axis equal
    usePts{npts} = find(roi>corrThresh);
    if length(usePts{npts})<=6
        dF(npts,:) = 0;
        coverage(usePts{npts})=-20;
    else
    dF(npts,:) = squeeze(mean(dfReshape(usePts{npts},:),1));
    coverage(usePts{npts})=npts;
    end
    
    
    subplot(2,2,3);
    imagesc(cc,[0 1]);
    
end

figure
imagesc(reshape(coverage,[size(dfofInterp,1) size(dfofInterp,2)]));


c = 'rgbcmk'
figure
hold on
for i = 1:npts;
    plot(dF(i,50:1250)/max(dF(i,:)) + i/2,c(mod(i,6)+1));
end




greenframe = refFrame;
[f p] = uiputfile('*.mat','save points data');
save(fullfile(p,f),'pts','dF','coverage','greenframe');
ptsfname = fullfile(p,f);


