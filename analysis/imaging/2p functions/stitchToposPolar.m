close all;
clear all;
pixperumX=1.1
pixperumY=1


hsvShort = hsv; hsvShort = hsvShort(1:end,:);
% %set for 4/19/16 mapping on g62dd2
% pixperumX=1.2;
% pixperumY=1.3;
% x = [0 569 1010 1629 722 -30 -690 -1016 -314 490 1278 1867 1867 1045 176 -488 -1252 -922 -135 650 1485 -307 631]; x = x-min(x); x= x/(2*pixperumX) +1;
% y = -[-7 -7 -7 -598 -598 -598 -594 -1266 -1291 -1291 -1291 -1280 -1801 -1801 -1825 -1825 -1805 -2340 -2347 -2347 -2347 -2667 -2678]; y = y-min(y); y= y/(2*pixperumY) +1;

%set with new params for 4/27/16
x = [0 683 1406 2398 1692 1049 291 -565 -830 -48 659 1433 2117 2845 2834 2111 1442 746 -5 -750 -750 -4 794 1553 2273 1803 1049 358 -388 -842]; 
x = x-min(x); x= x/(2*pixperumX) +1;
y = -[0 0 0 -605 -605 -605 -605 -605 -1348 -1348 -1348 -1348 -1347 -1347 -2048 -2048 -2048 -2048 -2048 -2048 -2773 -2775 -2775 -2776 -2776 -3324 -3324 -3324 -3329 -3145];
y = y-min(y); y= y/(2*pixperumY) +1;
x= round(x); y = round(y);

%do for topoX
mapX = zeros(400,400,3);
mapfigX = zeros(max(y)+400,max(x)+400,length(x))+NaN;
for i = 1:30
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
img = mat2im(ph,hsvShort,[pi/4 2*pi]);
%img = mat2im(ph,hsv,[3*pi/4  (2*pi -pi/2)]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(img)


%do for topoY
mapY = zeros(400,400,3);
mapfigY = zeros(max(y)+400,max(x)+400,length(x))+NaN;
for i = 1:30
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
imagesc(amp,[0 1]); colormap gray; axis equal
prctile(amp(:),95)
amp=amp/prctile(amp(:),90); amp(amp>1)=1;
ph = mod(angle(meanfigY),2*pi); ph(isnan(ph))=0; amp(isnan(amp))=0;
%img = mat2im(ph,hsv,[3*pi/4  (2*pi -pi/2)]);
img = mat2im(ph,hsvShort,[pi/4 2*pi]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(img)


    