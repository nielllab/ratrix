
filt = fspecial('gaussian',[10  10],2);
trialmeanfilt = imfilter(trialmean,filt);

x = ones(50,1);
y= ones(50,1);
onoff = ones(50,1);onoff(1:25)=0;

for xpos = 1:5;
    x(((xpos-1)*5+1):((xpos-1)*5+5))=xpos;
end
x(26:50)=x(1:25);
for ypos = 1:5;
    y(ypos:5:end)=ypos;
end

clear meanImg
for i = 1:50;
    meanImg(:,:,i) = nanmean(trialmeanfilt(:,:,stimOrder==i),3);
end
meanImg(meanImg<0.025)=0;
xmap = 0; ymap =0;
for i = 26:50
    xmap = xmap+meanImg(:,:,i)*x(i);
    ymap = ymap+meanImg(:,:,i)*y(i);
end
amp = sum(meanImg(:,:,26:50),3);
amp(amp<=0)=0.001;
ymap = ymap./amp;
xmap = xmap./amp;
amp = amp/0.3;
amp(amp>1)=1;

figure
imagesc(amp)
figure
imagesc(xmap,[1 5]);colormap hsv
figure
imagesc(ymap,[1 5]); colormap hsv

xpolar = mat2im(xmap,hsv,[1.5 4.5]);
xpolar = xpolar.*repmat(amp,[1 1 3]);
topox = figure;
imshow(imresize(xpolar,2));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


ypolar = mat2im(ymap,hsv,[1.5 4.5]);
ypolar = ypolar.*repmat(amp,[1 1 3]);
topoy = figure;
imshow(imresize(ypolar,2));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


% figure
% for i= 26:50;
%     subplot(5,5,i-25);
%     imagesc(meanImg(:,:,i),[0 0.1])
% end
% 
% figure
% imshow(xpolar);
% [y x] = ginput(2);
% [xgrid ygrid] = meshgrid(1:size(xpolar,2),1:size(xpolar,1));
% 
% vector = [x(2)-x(1) y(2)-y(1)];
% vector = vector/sqrt(vector(1)^2 + vector(2)^2);
% xgrid = xgrid-x(1);
% ygrid = ygrid-y(1);
% dist = xgrid*vector(1) + ygrid*vector(2);
% figure
% imagesc(dist)
% figure
% plot(dist(amp>0.75), xmap(amp>0.75),'.')
% 
% dvals = dist(amp>0.75); xvals = (xmap(amp>0.75)-2.4)*10;
% dvals = dvals(:); xvals = xvals(:);
% binx = -25:25:150;
% clear mapMean mapStd
% for i = 1:length(binx)-1
%     mapMean(i) = median(xvals(dvals>binx(i) & dvals<binx(i+1)));
%     mapStd(i) =std(xvals(dvals>binx(i) & dvals<binx(i+1)))/ sqrt(25);
% end
% figure
% errorbar((binx(1:end-1)+25)*400/256, mapMean,mapStd);
% xlim([-25 250]); xlabel('distance (um)');
% ylabel('RF azimuth (deg)')
% figure
% imshow(ypolar);
% [y x] = ginput(2);
% [xgrid ygrid] = meshgrid(1:size(xpolar,2),1:size(xpolar,1));
% 
% vector = [x(2)-x(1) y(2)-y(1)];
% vector = vector/sqrt(vector(1)^2 + vector(2)^2);
% xgrid = xgrid-x(1);
% ygrid = ygrid-y(1);
% dist = xgrid*vector(1) + ygrid*vector(2);
% figure
% imagesc(dist)
% figure
% plot(dist(amp>0.5), ymap(amp>0.5),'.')
