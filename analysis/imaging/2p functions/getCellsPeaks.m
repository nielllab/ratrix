function [dF xpts ypts minF xrange yrange ] =  getCellsPeaks(fname,psfile,pixWin,minF,xrange,yrange)
%%% selects "cells" based on peak of mean image
%%% allows criterea based on intensity and cropping; 
%%% if these aren't passed, then they get set manually
%%%
%%% inputs :
%%% fname = .mat file from session analysis
%%% pixWin = window to average over around each "cell", +/-pixWin
%%% minF = minimum fluorescence intensity to be include
%%% x/yrange = range for cropping image (to avoid boundary, or non-expressing areas
%%% psfile = postscript file to write figures to
%%%
%%% outputs : 
%%% dF = traces from all cells selected
%%% x/ypts = location of selected "cells"
%%% x/yrange, minF = results of selection criteria

if ~exist('xrange','var')
    manualCrop=1; %%% option to crop points manually
else 
    manualCrop=0;
end

if ~exist('minF','var')
    chooseMin=1;  %%% option to manually select a minimum intensity for points
else
    chooseMin=0;
end

if ~exist('pixWin','var');
    pixWin = 2; %%% window to average over around each "cell", +/-pixWin
end

display('loading data')
load(fname,'meanImg','dfofInterp')
%%% set image to select points from and clean it up a bit
img = meanImg;  
img(isnan(img(:))) = 0;
img(isinf(img(:))) = 0;
filt = fspecial('gaussian',5,1);
stdImg = imfilter(img,filt);   %%% this is the "standard" image we'll chhose points on
figure
imagesc(stdImg); colormap gray

%%% find peaks in stdImg
%%% compare each point to the dilation of the region around it - if greater, it's a peak
region = ones(3,3); region(2,2)=0;
maxStd = stdImg > imdilate(stdImg,region);
maxStd(1:3,:) = 0; maxStd(end-2:end,:)=0; maxStd(:,1:3)=0; maxStd(:,end-2:end)=0; %%% no points on border
pts = find(maxStd);
sprintf('%d max points\n', length(pts))

%%% show max points
[y, x] = ind2sub(size(maxStd),pts);
figure
imagesc(stdImg,[0 prctile(stdImg(:),98)]);hold on; colormap gray
plot(x,y,'o');

%%% crop image to avoid points near border that may have artifact
if manualCrop
    disp('Select area in figure to include in the analysis');
    [xrange, yrange] = ginput(2);
end
pts= pts(x>xrange(1) & x<xrange(2) & y>yrange(1) & y<yrange(2));

close(gcf);

%%% sort points based on their value (max df/f)
[brightness, order] = sort(img(pts),1,'descend');
figure
plot(brightness); xlabel('N'); ylabel('brightness');
fprintf('%d points in ROI\n',length(pts))

%%% choose points over a cutoff, to eliminate noise / nonresponsive
if chooseMin
    minF= input('intensity cutoff : ');
end
pts = pts(img(pts)>minF);
fprintf('%d points in ROI over cutoff\n',length(pts))


%%% plot selected points
[y, x] = ind2sub(size(maxStd),pts);
figure
imagesc(stdImg,[0 prctile(stdImg(:),98)]); hold on; colormap gray; colorbar
plot(x,y,'.');
title(fname);
if exist('psfile','var'), set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% average df/f in a box around each selected point
range = -pixWin:pixWin;
clear dF
for i = 1:length(x)
    dF(i,:) = mean(mean(dfofInterp(y(i)+range,x(i)+range,:),2),1);
end
xpts = x; ypts = y; %%% new names so they don't get overwritten
npts = length(xpts);

figure 
imagesc(dF,[-1 1]); colorbar
title('all traces from selected points');

figure
plot(mean(dF,1)); title('mean of selected points')
xlabel('frame'); ylabel('dfof')

c= corrcoef(dF');
figure
hist(c(:),-1:0.1:1); xlim([-1.05 1.05])
title('correlation of cells')
xlabel('correlation'); ylabel('# of cells')

display('doing mds');
dist = pdist(dF,'correlation');
tic
[Y e] = mdscale(dist,1);
toc
[y sortind] = sort(Y);
figure
imagesc(dF(sortind,:),[-1 1]);
title('responses sorted by mds')
colorbar
if exist('psfile','var'), set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

xyDist = pdist([xpts ypts],'euclidean');
figure
plot(xyDist,1-dist,'.');
xlabel('distance (pix)');
ylabel('correlation');
if exist('psfile','var'), set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

save(fname,'dF','xpts','ypts','xrange','yrange','minF','-append');

clear cycAvg
for i = 1:100;
    cycAvg(:,i) = mean(dF(:,i:100:end),2);
end
figure
imagesc(cycAvg);


display('doing mds');
dist = pdist(cycAvg,'correlation');
tic
[Y e] = mdscale(dist,1);
toc
[y sortind] = sort(Y);
figure
imagesc(cycAvg(sortind,:),[-1 1]);
title('responses sorted by mds')
colorbar

figure
plot(mean(cycAvg,1)); title('cycle average')
