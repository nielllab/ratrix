%%% generic sutter 2p analysis

clear all
close all

%%% frame rate for resampling
dt = 0.5;
framerate=1/dt;
twocolor = input('how many colors? 1 / 2 : ')-1;

%%% get sutter data
%%% will ask for tif file - performs image registration and resamples at requested framerate
%%% will ask for ttl .mat file - uses this to find first frame of imaging after stim comes on
%%% returns dfofInterp(x,y,t) = timeseries at requested framerate, with pre-stim frames clipped off
%%% greenframe = mean fluorescence image
get2pSession
dfofInterp = dfofInterp(49:end-32,37:end-36,:);
cycLength = cycLength/dt;

%%% generate periodic map

map = 0;
for i= 1:size(dfofInterp,3);
    map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
map = map/size(dfofInterp,3); map(isnan(map))=0;
amp = abs(map);
prctile(amp(:),99)
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[pi/2  (2*pi -pi/4)]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(imresize(img,0.5))
colormap(hsv); colorbar
title(sprintf('fourier map at %d frame cycle',cycLength));

stdFig = figure
stdImg = std(dfofInterp,[],3);
imagesc(stdImg,[0 0.5]); hold on;
greenFig = figure;
stdImg = greenframe(49:end-32,37:end-36);
imagesc(stdImg,[0 prctile(stdImg(:),99)*1.2]); hold on; axis equal; colormap gray

selectPts = input('select points by hand (1) or automatic (0) : ');
if selectPts
  range = -1:1
  clear x y npts
   npts = input('how many points ? ');
    for i =1:npts
        figure(greenFig);
        [x(i) y(i)] = ginput(1); x=round(x); y = round(y);
        plot(x(i),y(i),'r*');
        dF(i,:) = squeeze(mean(mean(dfofInterp(y(i)+range,x(i)+range,:),2),1));
    end
    
else
    
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
    
    % %%% select the top N points in brightness, changed to select range.
    % %%% need to fix na nb discrepencies farther down the pipeline
    % [brightness order] = sort(img(pts),1,'descend');
    % figure
    % plot(brightness); xlabel('N'); ylabel('brightness');
    % na= input('# of points above: ');
    % nb= input('# of points below: ');
    %
    % range = -1:1;
    % clear dF
    %
    % for i = na:nb
    %     dF(i,:) = mean(mean(dfofInterp(x(order(i))+range,y(order(i))+range,:),2),1);
    % end
    %
    % %%% show selected points
    % figure
    % imagesc(stdImg,[0 500]); hold on; colormap gray
    % plot(y(order(na:nb)),x(order(na:nb)),'o');
    
    
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
    
end
%%% plot all fluorescence traces
figure
plot((1:size(dF,2))*dt,dF');
hold on
plot((1:size(dF,2))*dt,mean(dF,1),'g','Linewidth',2);
xlabel('secs'); xlim([0 size(dF,2)*dt]);

if exist('mv','var')
    figure
    plot(mv);
    title('alignement')
end

%%% heatmap of fluorescence traces
figure
imagesc(dF);

%%% ID cells with greatest change over recording
if ~selectPts
for i =1:n
    
    delta = max(dF(i,:)) - min(dF(i,:));
    diffs(i,:) =  delta;
    
end

%%% sort based on dF and graph dF, keeping cell ID's with the change in
%%% their dF

seq=(1:n);
permed = permute(seq,[2 1]);
diffsnum = [permed diffs];



sortdiffs = sortrows(diffsnum,-2);
figure
plot(sortdiffs(:,2)); xlabel('N'); ylabel('change in dF');

%%% create a matrix of only cells above a user chosen threshold of dF

n= input('# of points : ');

for i =1:n;
    selectdiffs(i,1) = sortdiffs(i,1);
    selectdiffs(i,2)=sortdiffs(i,2);
    
end

sizeselectdiffs = size (selectdiffs);
sizecolselectdiffs=sizeselectdiffs(1,1);

for i =1:sizecolselectdiffs;
    
    tracenum=selectdiffs(i,1);
    trace=dF(tracenum,:);
    selecttrace(i,:) = trace;
    clear trace;
    
end

[brightnessdf orderdf] = sort(selecttrace(pts),1,'descend');
else
    selecttrace = dF;
end


%%% cluster responses from selected traces
dist = pdist(selecttrace,'correlation');  %%% sort based on correlation coefficient
display('doing cluster')
tic, Z = linkage(dist,'ward'); toc
figure
subplot(3,4,[1 5 9 ])
display('doing dendrogram')
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,3);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc((selecttrace(perm,:)),[-0.1 1]); axis xy ; xlabel('selected traces based on dF'); colormap jet ;   %%% show sorted data
hold on;
totalT = size(dF,2);
ncyc = floor(totalT/cycLength);
for i = 1:ncyc
    plot([i*cycLength i*cycLength],[1 length(perm)],'k');
end




%%% cluster responses

%%%comment back?

%
% dist = pdist(dF,'correlation');  %%% sort based on correlation coefficient
% display('doing cluster')
% tic, Z = linkage(dist,'ward'); toc
% figure
% subplot(3,4,[1 5 9 ])
% display('doing dendrogram')
% [h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,3); %%% cris had 5 as the last value, created fewer clusters in dendrogram
% axis off
% subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
% imagesc((dF(perm,:)),[-0.5 0.5]); axis xy ; hold on  %%% show sorted data
%






lower = min(dF(:)); upper = max(dF(:));
figure
imagesc(dF,[0 upper]); colormap gray; axis equal
hold on

%%% plot correlation coefficients
figure
imagesc(corrcoef(dF'));



%%% want some version of this...
%%% xselected = x(selecttrace(1:n)); yselected = y(selecttrace(1:n));


%xselected = x(order(1:n)); yselected = y(order(1:n)); %%% only keep cell positions for selected cells; you'll need to also do this again for any subsequent selections
%%% xselected = xselected(orderdf(1:n)); yselected = yselected(orderdf(1:n));

%  xselecteddf = x(orderdf(1:n)); yselecteddf = y(orderdf(1:n));


nclust =input('# of clusters : '); %%% set to however many you want
c= cluster(Z,'maxclust',nclust);
colors = 'rgbcmy';

figure
col='rgbcmy';
imagesc(stdImg,[0 prctile(stdImg(:),99)*1.2]); colormap gray; axis equal;hold on
for clust=1:nclust
    plot(x(c==clust),y(c==clust),[colors(clust) 'o']);
end

nstim = input('num stim per repeat : ');
totalframes = cycLength*nstim;

reps = floor(size(dF,2)/totalframes);

for rep = 1:reps
    dFrepeats(:,:,rep) = dF(:,(1:totalframes) + (rep-1)*totalframes);
end

figure
plot((1:totalframes)/cycLength + 1, squeeze(mean(dFrepeats,1)))
xlabel('stim #'); xlim([1 nstim+1])
title('mean trace for each repeat');



for clust = 1:nclust
    figure
    subplot(2,2,1);
    imagesc(stdImg,[0 prctile(stdImg(:),99)*1.2]); axis equal; hold on;colormap gray;freezeColors;
    title(sprintf('cluster %d',clust));
    
    plot(x(c==clust),y(c==clust),'go')%%'Color',colors(c));
    subplot(2,2,2);
    imagesc(selecttrace(c==clust,:),[-0.1 1]); axis xy % was df
    title(sprintf('clust %d',clust)); hold on
    totalT = size(dF,2);
    ncyc = floor(totalT/cycLength);
    for i = 1:ncyc
        plot([i*cycLength i*cycLength],[1 sum(clust==c)],'k');
    end
    colormap jet;freezeColors;colormap gray;
    
    subplot(2,2,4);
plot((1:totalframes)/cycLength + 1, squeeze(mean(dFrepeats(c==clust,:,:),1)))
xlabel('stim #'); xlim([1 nstim+1])
title('mean of cluster, multiple repeats');

    
    subplot(2,2,3);
    plot((1:size(selecttrace,2))*dt,selecttrace(c==clust,:)');
    xlim([1 size(selecttrace,2)*dt]); xlabel('secs');
end

figure
hold on
for clust = 1:nclust
    plot(mean(dF(c==clust,:),1));
end


% commented out
% [f p] = uiputfile('*.mat','save results');
% save(fullfile(p,f),'dF','greenframe','x','y');