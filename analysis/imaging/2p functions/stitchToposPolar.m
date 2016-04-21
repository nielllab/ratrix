close all;
clear all;
pixperumX=1.3;
pixperumY=1.1;
x = [0 569 1010 1629 722 -30 -690 -1016 -314 490 1278 1867 1867 1045 176 -488 -1252 -922 -135 650 1485 -307 631]; x = x-min(x); x= x/(2*pixperumX) +1;
y = -[-7 -7 -7 -598 -598 -598 -594 -1266 -1291 -1291 -1291 -1280 -1801 -1801 -1825 -1825 -1805 -2340 -2347 -2347 -2347 -2667 -2678]; y = y-min(y); y= y/(2*pixperumY) +1;

%do for topoX
mapX = zeros(400,400,3);
mapfigX = zeros(400*4,400*4,23)+NaN;
for i = 1:23
   i
   load(sprintf('topoXsession%d.mat',i),'map');
   polarImg = map(16:end-16,16:end-16,:);
   mapfigX(y(i):y(i)+366,x(i):x(i)+366,i)=polarImg;
%     figure
%     imshow(polarImg);
end
meanfigX = nanmean(mapfigX,3);
amp = abs(meanfigX);
figure
imagesc(amp); colormap gray; axis equal
prctile(amp(:),95)
amp=amp/prctile(amp(:),90); amp(amp>1)=1;
ph = mod(angle(meanfigX),2*pi); ph(isnan(ph))=0; amp(isnan(amp))=0;
img = mat2im(ph,hsv,[3*pi/4  (2*pi -pi/2)]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(img)

figure
imshow(meanfigX);

%do for topoY
mapY = zeros(400,400,3);
mapfigY = zeros(400*4,400*4,23)+NaN;
for i = 1:23
    i
    load(sprintf('topoYsession%d.mat',i),'map');
   polarImg = map(16:end-16,16:end-16);
   mapfigY(y(i):y(i)+366,x(i):x(i)+366,i)=polarImg;
%     figure
%     imshow(polarImg);
end
meanfigY = nanmean(mapfigY,3);
amp = abs(meanfigY);
figure
imagesc(amp); colormap gray; axis equal
prctile(amp(:),95)
amp=amp/prctile(amp(:),90); amp(amp>1)=1;
ph = mod(angle(meanfigY),2*pi); ph(isnan(ph))=0; amp(isnan(amp))=0;
img = mat2im(ph,hsv,[3*pi/8  (2*pi -pi/2)]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(img)

figure
imshow(meanfigY);
    