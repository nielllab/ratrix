close all;
clear all;
pixperumX=1.3;
pixperumY=1.1;
x = [0 569 1010 1629 722 -30 -690 -1016 -314 490 1278 1867 1867 1045 176 -488 -1252 -922 -135 650 1485 -307 631]; x = x-min(x); x= x/(2*pixperumX) +1;
y = -[-7 -7 -7 -598 -598 -598 -594 -1266 -1291 -1291 -1291 -1280 -1801 -1801 -1825 -1825 -1805 -2340 -2347 -2347 -2347 -2667 -2678]; y = y-min(y); y= y/(2*pixperumY) +1;

%do for topoX
mapX = zeros(400,400,3);
mapfigX = zeros(400*4,400*4,3,23)+NaN;
for i = 1:23
    load(sprintf('topoXsession%d.mat',i),'polarImg');
   polarImg = polarImg(16:end-16,16:end-16,:);
   mapfigX(y(i):y(i)+366,x(i):x(i)+366,:,i)=polarImg;
%     figure
%     imshow(polarImg);
end
meanfigX = nanmean(mapfigX,4);
figure
imshow(meanfigX);

%do for topoY
mapY = zeros(400,400,3);
mapfigY = zeros(400*4,400*4,3,23)+NaN;
for i = 1:23
    load(sprintf('topoYsession%d.mat',i),'polarImg');
   polarImg = polarImg(16:end-16,16:end-16,:);
   mapfigY(y(i):y(i)+366,x(i):x(i)+366,:,i)=polarImg;
%     figure
%     imshow(polarImg);
end
meanfigY = nanmean(mapfigY,4);
figure
imshow(meanfigY);
    