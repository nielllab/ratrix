%%% generic sutter 2p analysis

clear all
close all

%%% frame rate for resampling
dt = 0.25;
framerate=1/dt;
twocolor = 0;

%%% get sutter data
%%% will ask for tif file - performs image registration and resamples at requested framerate
%%% will ask for ttl .mat file - uses this to find first frame of imaging after stim comes on
%%% returns dfofInterp(x,y,t) = timeseries at requested framerate, with pre-stim frames clipped off
%%% greenframe = mean fluorescence image
get2pSession;


%%% generate periodic map 
cycLength = cycLength/dt;
map = 0;
for i= 1:size(dfofInterp,3);
    map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
map = map/size(dfofInterp,3); map(isnan(map))=0;
amp = abs(map);
prctile(amp(:),98)
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[pi/2  (2*pi -pi/4)]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(imresize(img,0.5))
colormap(hsv); colorbar
title(sprintf('fourier map at %d frame cycle',cycLength));

%%% select points based on peaks in brightness
img = greenframe;
filt = fspecial('gaussian',5,0.75);
stdImg = imfilter(img,filt);

%%% compare each point to the dilation of the region around it - if greater, it's a peak
region = ones(3,3); region(2,2)=0;
maxStd = stdImg > imdilate(stdImg,region);
maxStd(1:3,:) = 0; maxStd(end-2:end,:)=0; maxStd(:,1:3)=0; maxStd(:,end-2:end)=0; %%% no points on border
pts = find(maxStd);

%%% show max points
[x y] = ind2sub(size(maxStd),pts);
figure
imagesc(stdImg,[0 500]); hold on; colormap gray
plot(y,x,'o');

%%% select the top N points in brightness
[brightness order] = sort(img(pts),1,'descend');
figure
plot(brightness); xlabel('N'); ylabel('brightness');
n= input('# of points : ');
range = -1:1;
clear dF
for i = 1:n
    dF(i,:) = mean(mean(dfofInterp(x(order(i))+range,y(order(i))+range,:),2),1);
end

%%% show selected points
figure
imagesc(stdImg,[0 500]); hold on; colormap gray
plot(y(order(1:n)),x(order(1:n)),'o');

%%% plot all fluorescence traces
figure
plot((1:size(dF,2))*dt,dF');
hold on
plot((1:size(dF,2))*dt,mean(dF,1),'g','Linewidth',2);
xlabel('secs'); xlim([0 size(dF,2)*dt]);

%%% heatmap of fluorescence traces
figure
imagesc(dF);

%%% cluster responses
dist = pdist(dF,'correlation');  %%% sort based on correlation coefficient
display('doing cluster')
tic, Z = linkage(dist,'ward'); toc
figure
subplot(3,4,[1 5 9 ])
display('doing dendrogram')
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,5);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc((dF(perm,:)),[-0.5 0.5]); axis xy   %%% show sorted data

%%% plot correlation coefficients
figure
imagesc(corrcoef(dF'));

[f p] = uiputfile('*.mat','save results');
save(fullfile(p,f),'dF','greenframe','x','y');
