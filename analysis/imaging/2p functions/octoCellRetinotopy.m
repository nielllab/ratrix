figure
subplot(1,2,1);
green = meanGreenImg; green(:,:,1)=0;green(:,:,3)=0;
imshow(green*1.3); hold on
imshow(meanGreenImg*1.3); hold on
range = -2:2;
thresh = 0.075
greenThresh = 0.2

%% trim "cells" from lobe edge, that have artifact
[x y] = ginput(2);
m = (y(2)-y(1))/(x(2)-x(1));
b = y(1)-m*x(1);

n=0;
for i = 1:length(xpts)
    c = mean(mean(xpolarImg{2}(ypts(i)+range,xpts(i)+range,:),2),1);
    goodpos = ypts(i)>31 & ypts(i)<m*xpts(i)+b & ~(xpts(i)<20 & ypts(i)<45);
    if mean(c)>thresh &  goodpos& meanGreenImg(ypts(i),xpts(i),1)>greenThresh
     n=n+1;
     c = c/max(c);
        plot(xpts(i),ypts(i),'.','Color',c);
    end
end
plot([220 300],[350 350],'w','Linewidth',6)

subplot(1,2,2);
imshow(meanGreenImg); hold on
range = -2:2;
for i = 1:length(xpts)
    c = mean(mean(ypolarImg{2}(ypts(i)+range,xpts(i)+range,:),2),1);
    goodpos = ypts(i)>31 & ypts(i)<m*xpts(i)+b & ~(xpts(i)<20 & ypts(i)<45);
    if mean(c)>thresh &  goodpos& meanGreenImg(ypts(i),xpts(i),1)>greenThresh
        c = c/max(c);
        plot(xpts(i),ypts(i),'.','Color',c);
    end
end
plot([220 300],[350 350],'w','Linewidth',6)



figure
imshow(xpolar);
[y x] = ginput(2);
[xgrid ygrid] = meshgrid(1:size(xpolar,2),1:size(xpolar,1));

vector = [x(2)-x(1) y(2)-y(1)];
vector = vector/sqrt(vector(1)^2 + vector(2)^2);
xgrid = xgrid-x(1);
ygrid = ygrid-y(1);
dist = xgrid*vector(1) + ygrid*vector(2);
figure
imagesc(dist)

for i = 1:length(xpts);
    c = mean(mean(ypolarImg{2}(ypts(i)+range,xpts(i)+range,:),2),1);
    goodpos = ypts(i)>31 & ypts(i)<m*xpts(i)+b & ~(xpts(i)<20 & ypts(i)<45);
    if mean(c)>thresh &  goodpos& meanGreenImg(ypts(i),xpts(i),1)>greenThresh
      used(i)=1;
    else
        used(i)=0;
    end
    d(i) = dist(ypts(i),xpts(i));
    xval(i) =xphase{2}(ypts(i),xpts(i));
end

figure
plot(d(find(used)),xval(find(used))+(rand(size(find(used)))-0.5)*0.1,'.');

dvals = d;
binx = 75:50:400;
clear mapMean mapStd
for i = 1:length(binx)-1
    mapMean(i) = median(xval(dvals>binx(i) & dvals<binx(i+1)));
    mapStd(i) =std(xval(dvals>binx(i) & dvals<binx(i+1)))/ sqrt(25);
end
figure
hold on
plot((d(find(used))-binx(1))*2,(xval(find(used))+(rand(size(find(used)))-0.5)*0.1 -1)*10,'k.');

errorbar((binx(1:end-1)-binx(1))*2+50, (mapMean-1)*10,mapStd*10,'b','LineWidth',2);
 xlabel('distance (um)');
ylabel('RF azimuth (deg)')
axis([0 600 0 35])

figure
imshow(ypolar);
[y x] = ginput(2);
[xgrid ygrid] = meshgrid(1:size(xpolar,2),1:size(xpolar,1));

vector = [x(2)-x(1) y(2)-y(1)];
vector = vector/sqrt(vector(1)^2 + vector(2)^2);
xgrid = xgrid-x(1);
ygrid = ygrid-y(1);
dist = xgrid*vector(1) + ygrid*vector(2);
figure
imagesc(dist)
figure
plot(dist(amp>0.5), ymap(amp>0.5),'.')

