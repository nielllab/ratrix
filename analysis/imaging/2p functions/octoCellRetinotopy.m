figure
subplot(1,2,1);
green = meanGreenImg; green(:,:,1)=0;green(:,:,3)=0;
imshow(green*1.3); hold on
imshow(meanGreenImg*1.3); hold on
range = -2:2;
thresh = 0.075
greenThresh = 0.2

%%% trim "cells" from lobe edge, that have artifact
% [x y] = ginput(2);
% m = (y(2)-y(1))/(x(2)-x(1));
% b = y(1)-m*x(1);

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