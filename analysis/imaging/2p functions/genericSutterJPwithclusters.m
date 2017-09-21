%%% generic sutter 2p analysis

clear all
close all

%%% frame rate for resampling
dt = 0.5;
framerate=1/dt;

twocolor = input('how many colors? 1 / 2 : ')-1;
makeFigs = input('make pdf file 0 / 1 :');
if makeFigs
    psfile = 'c:\temp.ps';
    if exist(psfile,'file')==2;delete(psfile);end
end

%%% get sutter data
%%% will ask for tif file - performs image registration and resamples at requested framerate
%%% will ask for ttl .mat file - uses this to find first frame of imaging after stim comes on
%%% returns dfofInterp(x,y,t) = timeseries at requested framerate, with pre-stim frames clipped off
%%% greenframe = mean fluorescence image
get2pSession
dfofInterp = dfofInterp(49:end-32,37:end-36,:);
%cycLength = cycLength/dt;
cycF = mean(diff(stimPulse))/dt;
nstim = input('num stim per repeat : ');
totalframes = cycLength*nstim;
reps = floor(size(dfofInterp,3)/totalframes);

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

figure
plot((1:size(dfofInterp,3))*dt,squeeze(mean(mean(dfofInterp,2),1)));
title('full image mean'); hold on
for i = 1:reps;
    plot([i*nstim*cycLength*dt  i*nstim*cycLength*dt], [0 0.5],'g');
end
xlabel('secs');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


greenFig = figure;
title('mean')
stdImg = greenframe(49:end-32,37:end-36);
imagesc(stdImg,[prctile(stdImg(:),1) prctile(stdImg(:),99)*1.2]); hold on; axis equal; colormap gray; title('mean')
normgreen = (stdImg - prctile(stdImg(:),1))/ (prctile(stdImg(:),99)*1.5 - prctile(stdImg(:),1));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


maxFig = figure;
stdImg = max(dfofInterp,[],3); stdImg = medfilt2(stdImg);
imagesc(stdImg,[prctile(stdImg(:),1) 2]); hold on; axis equal; colormap gray; title('max')
normMax = (stdImg - prctile(stdImg(:),1))/ (prctile(stdImg(:),98) - prctile(stdImg(:),1));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

merge = zeros(size(stdImg,1),size(stdImg,2),3);
merge(:,:,1)= normMax;
merge(:,:,2) = normgreen;
mergeFig = figure;
imshow(merge); title('merge')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

selectPts = input('select points by hand (1) or automatic (0) : ');
if selectPts
    chooseFig = input('select based on 1) mean image, 2) max image, 3) merge image : ');
    if chooseFig==1, selectFig = greenFig, elseif chooseFig==2, selectFig=maxFig, else selectFig=mergeFig, end;
    range = -2:2
    clear x y npts
    npts = input('how many points ? ');
    for i =1:npts
        figure(selectFig); hold on
        [x(i) y(i)] = ginput(1); x=round(x); y = round(y);
        plot(x(i),y(i),'b*');
        dF(i,:) = squeeze(mean(mean(dfofInterp(y(i)+range,x(i)+range,:),2),1));
    end
    
else
    
    %%% select points based on peaks in brightness
    img = max(dfofInterp,[],3);
    filt = fspecial('gaussian',5,3);
    stdImg = imfilter(img,filt);
    figure
    imagesc(stdImg,[0 2]); colormap gray
    
    %%% compare each point to the dilation of the region around it - if greater, it's a peak
    region = ones(3,3); region(2,2)=0;
    maxStd = stdImg > imdilate(stdImg,region);
    maxStd(1:3,:) = 0; maxStd(end-2:end,:)=0; maxStd(:,1:3)=0; maxStd(:,end-2:end)=0; %%% no points on border
    pts = find(maxStd);
    sprintf('%d max points', length(pts))
    
    %%% show max points
    [y x] = ind2sub(size(maxStd),pts);
    figure
    imagesc(stdImg,[0 2]); hold on; colormap gray
    plot(x,y,'o');
    
    [xrange yrange] = ginput(2);
    pts = pts(x>xrange(1) & x<xrange(2) & y>yrange(1) & y<yrange(2));
    
    [brightness order] = sort(img(pts),1,'descend');
    figure
    plot(brightness); xlabel('N'); ylabel('brightness');
    sprintf('%d points in ROI',length(pts))
    
    mindF= input('dF cutoff : ');
    pts = pts(img(pts)>mindF);
    sprintf('%d points in ROI over cutoff',length(pts))
    
    [y x] = ind2sub(size(maxStd),pts);
    figure
    imagesc(stdImg,[0 2]); hold on; colormap gray
    plot(x,y,'o');
    
    
    range = -2:2;
    clear dF
    for i = 1:length(x)
        dF(i,:) = mean(mean(dfofInterp(y(i)+range,x(i)+range,:),2),1);
    end
    
    %%% show selected points
    
    
end


dF(dF>2)=2;
%%% plot all fluorescence traces
figure
plot((1:size(dF,2))*dt,dF');
hold on
plot((1:size(dF,2))*dt,mean(dF,1),'g','Linewidth',2);
xlabel('secs'); xlim([0 size(dF,2)*dt]);
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


if exist('mv','var')
    figure
    plot(mv);
    title('alignement')
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% heatmap of fluorescence traces
figure
imagesc(dF);


%%% cluster responses from selected traces
dist = pdist(dF,'correlation');  %%% sort based on correlation coefficient
display('doing cluster')
tic, Z = linkage(dist,'ward'); toc
figure
subplot(3,4,[1 5 9 ])
display('doing dendrogram')
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,3);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(dF(perm,:),[-0.1 1]); axis xy ; xlabel('selected traces based on dF'); colormap jet ;   %%% show sorted data
hold on;
totalT = size(dF,2);
ncyc = floor(totalT/cycLength);
for i = 1:ncyc
    plot([i*cycLength i*cycLength]+0.5,[1 length(perm)],'k');
end

if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


% %%% plot correlation coefficients
% figure
% imagesc(corrcoef(dF'));

nclust =input('# of clusters : '); %%% set to however many you want
c= cluster(Z,'maxclust',nclust);
colors = hsv(nclust+1);

figure

imagesc(stdImg,[0 prctile(stdImg(:),99)*1.2]); colormap gray; axis equal;hold on
for clust=1:nclust
    plot(x(c==clust),y(c==clust),'o','Color',colors(clust,:));
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


clear dFrepeats
for rep = 1:reps
    dFrepeats(:,:,rep) = dF(:,(1:totalframes) + round((rep-1)*totalframes));
end

dFrepeats(dFrepeats>2)=2;

figure
plot((0:totalframes-1)/cycLength+1, squeeze(mean(dFrepeats,1)))
xlabel('stim #'); xlim([1 nstim+1])
title('mean trace for each repeat');
hold on; legend('1','2','3','4')
%plot((0:totalframes-1)/cycLength +1, squeeze(mean(mean(dFrepeats,3),1)),'g','Linewidth',2)
for i = 1:nstim;
    plot([i i ],[0.3 0.6],'k:');
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


for clust = 1:nclust
    figure
    subplot(2,2,1);
    imagesc(stdImg,[0 prctile(stdImg(:),99)*1.2]); axis equal; hold on;colormap gray;freezeColors;
    title(sprintf('cluster %d',clust));
    
    plot(x(c==clust),y(c==clust),'go')%%'Color',colors(c));
    subplot(2,2,2);
    imagesc(dF(c==clust,:),[-0.1 1]); axis xy % was df
    title(sprintf('clust %d',clust)); hold on
    totalT = size(dF,2);
    ncyc = floor(totalT/cycLength);
    for i = 1:ncyc
        plot([i*cycLength i*cycLength]+0.5,[1 sum(clust==c)],'k');
    end
    colormap jet;freezeColors;colormap gray;
    
    subplot(2,2,4);
    plot((0:totalframes-1)/cycLength + 1, squeeze(mean(dFrepeats(c==clust,:,:),1))); hold on
     plot((0:totalframes-1)/cycLength + 1, squeeze(mean(mean(dFrepeats(c==clust,:,:),3),1)),'g','LineWidth',2)
    xlabel('stim #'); xlim([1 nstim+1])
    title('mean of cluster, multiple repeats');
    for i = 1:nstim;
    plot([i i ],[0  0.5],'k:');
end
    
    subplot(2,2,3);
    plot((1:size(dF,2))*dt,dF(c==clust,:)'); hold on; 
    xlim([1 size(dF,2)*dt]); xlabel('secs'); ylim([-0.2 2.1])
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end

figure
hold on
for clust = 1:nclust
    plot(mean(dF(c==clust,:),1));
end; title('mean for each cluster)')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

if makeFigs
    [f p] = uiputfile('*.pdf','save pdf file');
    newpdfFile = fullfile(p,f)
    try
        dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )
        
    catch
        display('couldnt generate pdf');
    end
end


%%% commented out
[f p] = uiputfile('*.mat','save results');
if f~=0
    save(fullfile(p,f),'dF','greenframe','x','y','dFrepeats','cycLength','nstim');
end