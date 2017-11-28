%%% reads in sutter data, extracts cell traces, and aligns to stim
%%% optimized for octopus optic lobe with cal520 label

clear all
close all

%%% frame rate for resampling
dt = 0.5;
framerate=1/dt;

%%% option of one or two color data (sutter stores 2-color as interleaved frames)
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

%%%crop to get rid of edges that have motion artifact
buffer = max(abs(mv(:)))+2; %% what is largest offset?
topbuffer = buffer+12;
dfofInterp = dfofInterp(topbuffer:end-buffer,buffer:end-buffer,:);
cycLength = mean(diff(stimPulse))/dt;
cycWindow = round(max(4/dt,cycLength));  %%% number of frames in window around each cycle. min of 4 secs, or actual cycle length + 2
[f p] = uigetfile('*.mat','stimulus record');
if f~=0
    alignRecs =1;
    load(fullfile(p,f),'stimRec');
    nCycles = floor(size(dfofInterp,3)/cycLength)-ceil((cycWindow-cycLength)/cycLength)-1;  %%% trim off last stims to allow window for previous stim
    stimT = stimRec.ts - stimRec.ts(1);
    if min(stimRec.cond)==0  %%% new stimRec style, cond==0 during isi
        starts = find(diff([0; stimRec.cond])>0);
        stimOrder = stimRec.cond(starts);
        stimOrder = stimOrder(1:nCycles);
    else  %%% old stimRec style
        for i = 1:nCycles
            stimOrder(i) = stimRec.cond(min(find(stimT>((i-1)*cycLength*dt+0.1))));
        end
    end
    %stimOrder = stimRec.cond(stimRec.f==2); %%% find second frame of each stim, and see what condition it was (don't use frame 1, because stays at frame=1 at stim end)
    nstim = max(stimOrder);
    
    stimOrder = stimOrder(1:nCycles);
    for i = 1:nstim
        nStimRep(i) = sum(stimOrder==i);
    end
    totalframes = cycLength*nstim;
    reps = floor(size(dfofInterp,3)/totalframes);  %%% number of times the whole stimulus set was repeated
    
else
    alignRecs=0;
    nstim = input('num stim per repeat : '); %%% total number of stimuli in the set
    totalframes = cycLength*nstim;
    reps = floor(size(dfofInterp,3)/totalframes);  %%% number of times the whole stimulus set was repeated
    stimOrder = repmat(1:nstim,[1 reps]); nStimRep(1:nstim)=reps;
end
%%% get duration of each stim (called a cycle) in terms of frames, based on ttl interval

%%% generate periodic map
filt = fspecial('gaussian',5,1);

map = 0;
for i= 1:size(dfofInterp,3);
    map = map+imfilter(dfofInterp(:,:,i),filt)*exp(2*pi*sqrt(-1)*i/cycLength);
end
map = map/size(dfofInterp,3); map(isnan(map))=0;
amp = abs(map);
prctile(amp(:),99)
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[pi/2  (2*pi -pi/4)]);
img = img.*repmat(amp,[1 1 3]);
mapimg= figure
figure
imshow(imresize(img,2))
colormap(hsv); colorbar
title(sprintf('fourier map at %d frame cycle',cycLength));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% mean fluorescence of the entire image
figure
plot((1:size(dfofInterp,3))*dt,squeeze(mean(mean(dfofInterp,2),1)));
title('full image mean'); hold on
for i = 1:reps;
    plot([i*nstim*cycLength*dt  i*nstim*cycLength*dt], [0 0.5],'g');
end
xlabel('secs');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% calculate two reference images for choosing points on ...
%%% absolute green fluorescence, and max df/f of each pixel

%%% absolute green fluorescence
greenFig = figure;
title('mean')
stdImg = greenframe(topbuffer:end-buffer,buffer:end-buffer);
imagesc(stdImg,[prctile(stdImg(:),1) prctile(stdImg(:),99)*1.2]); hold on; axis equal; colormap gray; title('mean')
normgreen = (stdImg - prctile(stdImg(:),1))/ (prctile(stdImg(:),99)*1.5 - prctile(stdImg(:),1));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% max df/f of each pixel
maxFig = figure;
stdImg = max(dfofInterp,[],3); stdImg = medfilt2(stdImg);
imagesc(stdImg,[prctile(stdImg(:),1) 2]); hold on; axis equal; colormap gray; title('max')
normMax = (stdImg - prctile(stdImg(:),1))/ (prctile(stdImg(:),98) - prctile(stdImg(:),1));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% create merge overlay of absolute fluorescence and max change
merge = zeros(size(stdImg,1),size(stdImg,2),3);
merge(:,:,1)= normMax;
merge(:,:,2) = normgreen;
mergeFig = figure;
imshow(merge); title('merge')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% time to select points! either by hand or automatic
selectPts = input('select points by hand (1) or automatic (0) : ');
if selectPts
    chooseFig = input('select based on 1) mean image, 2) max image, 3) merge image : ');
    if chooseFig==1, selectFig = greenFig, elseif chooseFig==2, selectFig=maxFig, else selectFig=mergeFig, end;
    range = -2:2
    clear x y npts dF
    npts = input('how many points ? ');
    for i =1:npts
        figure(selectFig); hold on
        [x(i) y(i) button] = ginput(1); x=round(x); y = round(y);
        if button==3
            x = x(1:end-1); y =y(1:end-1);
            break
        end
        plot(x(i),y(i),'b*');
        dF(i,:) = squeeze(mean(mean(dfofInterp(y(i)+range,x(i)+range,:),2),1));
    end
    
else
    
    %%% select points based on peaks of max df/f
    
    %%%calculate max df/f image
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
    
    %%% crop image to avoid points near border that may have artifact
    [xrange yrange] = ginput(2);
    pts = pts(x>xrange(1) & x<xrange(2) & y>yrange(1) & y<yrange(2));
    
    %%% sort points based on their value (max df/f)
    [brightness order] = sort(img(pts),1,'descend');
    figure
    plot(brightness); xlabel('N'); ylabel('brightness');
    sprintf('%d points in ROI',length(pts))
    
    %%% choose points over a cutoff, to eliminate noise / nonresponsive
    mindF= input('dF cutoff : ');
    pts = pts(img(pts)>mindF);
    sprintf('%d points in ROI over cutoff',length(pts))
    
    %%% plot selected points
    [y x] = ind2sub(size(maxStd),pts);
    figure
    imagesc(stdImg,[0 2]); hold on; colormap gray
    plot(x,y,'o');
    
    %%% average df/f in a box around each selected point
    range = -2:2;
    clear dF
    for i = 1:length(x)
        dF(i,:) = mean(mean(dfofInterp(y(i)+range,x(i)+range,:),2),1);
    end
    
end  %%% if/else


dF(dF>2)=2; %%% clip abnormally large values

%%% plot all fluorescence traces
figure
plot((1:size(dF,2))*dt,dF');
hold on
plot((1:size(dF,2))*dt,mean(dF,1),'g','Linewidth',2);
xlabel('secs'); xlim([0 size(dF,2)*dt]);
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% plot movement correction trace
if exist('mv','var')
    figure
    plot(mv);
    title('alignement')
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% playing with pca analysis ...
% [coeff score latent] = pca(dF');
% figure
% plot(latent(1:10));
% figure
% plot(score(:,1:3))
% figure
% imagesc(coeff(:,1:10),[-0.25 0.25])
%
% figure
% imagesc((score*coeff')');
% figure
% imagesc(dF)

%%% sort data into repeats - dFrepeats(cell, time, rep #);

dFrepeats=zeros(size(dF,1),cycWindow*nstim,max(nStimRep))+NaN;
for i = 1:nstim
    repList = find(stimOrder==i);
    for r = 1:nStimRep(i)
        dFrepeats(:,(i-1)*cycWindow + (1:cycWindow),r) = dF(:,round((repList(r)-1)*cycLength)+(1:cycWindow)) - repmat(dF(:,round((repList(r)-1)*cycLength)+1),[1 floor(cycWindow)]);
    end
end
dFrepeats(dFrepeats>1) =1; %%% clip major outliers
dFrepeats(dFrepeats<-1) = -1;

%%% mean response of whole population, for each repetition
figure
plot((0:size(dFrepeats,2)-1)/cycWindow, squeeze(mean(dFrepeats,1)))
xlabel('stim #'); xlim([1 nstim+1]); ylim([-0.05 0.15])
title('mean trace for each repeat');
hold on; legend('1','2','3','4')
%plot((0:totalframes-1)/cycLength+1, squeeze(mean(mean(dFrepeats,3),1)),)
plot((0:size(dFrepeats,2)-1)/cycWindow, squeeze(mean(nanmedian(dFrepeats,3),1)),'g','Linewidth',2)
for i = 1:nstim;
    plot([i i ],[0 0.3],'k:');
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% calculate cycle averages (timecourse for each individual stim)
clear cycAvgAll cycAvg cycImg
for i=1:cycWindow;
    cycAvgAll(:,i) = mean(dF(:,i:cycLength:end),2); %%% cell-wise average across all stim
    cycAvg(i) = mean(mean(median(dfofInterp(:,:,i:cycLength:end),3),2),1); %%% average for all cells and stim
    cycImg(:,:,i) = mean(dfofInterp(:,:,i:cycLength:end),3); %%% pixelwise average across all stim
end

%%% plot pixel-wise cycle average
figure
for i = 1:min(cycLength,10)
    subplot(2,5,i);
    imagesc(cycImg(:,:,i)-min(cycImg,[],3),[0 0.025]); axis equal
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% plot mean timecourse
cycAvgAll = cycAvgAll - repmat(cycAvgAll(:,end),[1 size(cycAvgAll,2)]);
figure
plot(cycAvg); title('cycle average'); xlabel('frames')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end



%%% average across repetitions, and subtract the minimum value for each
%%% cell (to correct for baseline offsets)
dFmean = nanmedian(dFrepeats,3);
%dFmean = dFmean - repmat(min(dFmean,[],2),[1 size(dFmean,2)]);

%%% make dF matrix for clustering

%%% this version trims off two timepoints at beginning and end
dFclust=zeros(size(dF,1),floor(cycWindow-4)*nstim,max(nStimRep))+NaN;
for i = 1:nstim
    repList = find(stimOrder==i);
    for r = 1:nStimRep(i)
        dFclust(:,(i-1)*floor(cycWindow-4) + (1:floor(cycWindow-4)),r) = dF(:,round((repList(r)-1)*cycLength)+(3:floor(cycWindow-2))) - repmat(mean(dF(:,round((repList(r)-1)*cycLength)+(1:2)),2),[1 floor(cycWindow-4)]);
    end
end

%dFclust = dFmean; %%% or just use full dFmean
dFclust = nanmedian(dFclust,3);

% dFclust = dFclust./repmat(max(dFclust,[],2),[1 size(dFclust,2)]);  %% normalize by max response
% dFclust = imresize(dFclust,[size(dFclust,1) size(dFclust,2)*0.5]); %%% downsample to improve SNR
dFclust(dFclust>0.2) = 0.2; dFclust(dFclust<0)=0;
figure
imagesc(dFclust,[-0.05 0.2])
%imagesc(dFclust,[-1 1])

%%% cluster responses from selected traces
%dist = pdist(dF,'correlation');  %%% sort based on whole timecourse
dist = pdist(dFclust,'euclidean');  %%% sort based on average across repeats (averages away artifact on individual trials)
display('doing cluster')
tic, Z = linkage(dist,'ward'); toc
figure
subplot(3,4,[1 5 9 ])
display('doing dendrogram')
%leafOrder = optimalleaforder(Z,dist);
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,1);%,'reorder',leafOrder);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(dFmean(perm,:),[-0.1 0.4]); axis xy ; xlabel('selected traces based on dF'); colormap jet ;   %%% show sorted data
hold on;

for i = 1:nstim
    plot([i*cycWindow i*cycWindow]+0.5,[1 length(perm)],'k');
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% select number of clusters you want
nclust =input('# of clusters : '); %%% set to however many you want
c= cluster(Z,'maxclust',nclust);
colors = hsv(nclust+1); %%% color code for each cluster

%%% plot spatial location of cells in each cluster
figure
imagesc(stdImg,[0 prctile(stdImg(:),99)*1.2]); colormap gray; axis equal;hold on
for clust=1:nclust
    plot(x(c==clust),y(c==clust),'o','Color',colors(clust,:));
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% summary plots for each cluster
for clust = 1:nclust
    
    %%% spatial location of cells in this cluster
    figure
    subplot(2,2,1);
    imagesc(stdImg,[0 prctile(stdImg(:),99)*1.2]); axis equal; hold on;colormap gray;freezeColors;
    title(sprintf('cluster %d',clust));
    plot(x(c==clust),y(c==clust),'go')%%'Color',colors(c));
    
    %%% heatmap average timecourse
    subplot(2,2,2);
    imagesc(dFmean(c==clust,:),[-0.1 0.4]); axis xy % was df
    title(sprintf('clust %d',clust)); hold on
    
    for i = 1:nstim
        plot([i*cycWindow i*cycWindow]+0.5,[1 sum(clust==c)],'k');
    end
    colormap jet;freezeColors;colormap gray;
    
    %%% timecourse of this cluster, for each repeat
    subplot(2,2,4);
    plot((0:size(dFrepeats,2)-1)/cycWindow + 1, squeeze(mean(dFrepeats(c==clust,:,:),1))); hold on
    plot((0:size(dFrepeats,2)-1)/cycWindow + 1, squeeze(mean(nanmedian(dFrepeats(c==clust,:,:),3),1)),'g','LineWidth',2)
    xlabel('stim #'); xlim([1 nstim+1]); ylim([-0.05 0.2])
    title('mean of cluster, multiple repeats');
    for i = 1:nstim;
        plot([i i ],[0  0.5],'k:');
    end
    
    %%% cycleaverage timecourse for each cell in this cluster
    subplot(2,2,3);
    plot(cycAvgAll(c==clust,:)');
    hold on
    plot(mean(cycAvgAll(c==clust,:),1),'g','Linewidth',2);
    %     plot((1:size(dF,2))*dt,dF(c==clust,:)'); hold on;
    %     xlim([1 size(dF,2)*dt]); xlabel('secs'); ylim([-0.2 2.1])
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end

%%% cycle average timecourse for each cluster
figure
hold on
for clust = 1:nclust
    plot(mean(cycAvgAll(c==clust,:),1),'Color',colors(clust,:));
end; title('mean cyc avg for each cluster)')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% mean response for each cluster
figure
hold on
for clust = 1:nclust
    plot((0:size(dFrepeats,2)-1)/cycWindow+1,mean(dFmean(c==clust,:,:),1),'Color',colors(clust,:));
end;
hold on
for i = 1:nstim;
    plot([i i ],[0 0.2],'k:');
end
title('mean resp for each cluster');xlabel('stim #'); xlim([1 nstim+1])
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% correlation map (shows how good the clustering is
figure
imagesc(corrcoef(dFclust(perm,:)'),[-1 1]); colormap jet
title('correlation across cells after clustering')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

figure
hist(max(dFclust,[],2))
%%% calculate pixel-wise maps of activity for different stim

evRange = 5:6; baseRange = 2:3; %%% timepoints for evoked and baseline activity
figure
for i = 1:length(stimOrder); %%% get pixel-wise evoked activity on each individual stim presentation
    trialmean(:,:,i) = mean(dfofInterp(:,:,round(cycLength*(i-1) + evRange)),3)- mean(dfofInterp(:,:,round(cycLength*(i-1) + baseRange)),3);
end
filt = fspecial('gaussian',5,1.5);
trialmean = imfilter(trialmean,filt);

%%% plot mean for each stim condition, with layout corresponding to the stim
range = [-0.02 0.1];
if nstim==12 %%% spots
    loc = [1 4 2 5 3 6]; %%% map stim order onto subplot
    figure; set(gcf,'Name','OFF spots');
    for i = 1:6
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i));
        imagesc(meanimg,range); axis equal
        stimImg(:,:,i) = meanimg;
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','ON spots');
    for i = 7:12
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i-6));
        imagesc(meanimg,range); axis equal
        stimImg(:,:,i) = meanimg;
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    overlay(:,:,1) = mean(stimImg(:,:,6),3);
    overlay(:,:,2) = mean(stimImg(:,:,12),3);
    overlay(:,:,3)= 0;
    overlay(overlay<0)=0; overlay = overlay/0.15;
    figure
    imshow(imresize(overlay,2));
end

range = [-0.05 0.2]; %%% colormap range
if nstim==14 %%% gratings
    loc = 1:6; %%% map stim order onto subplot
    figure; set(gcf,'Name','vert gratings');
    for i = 1:6
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure;set(gcf,'Name','horiz gratings');
    for i = 7:12
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i-6));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','flicker');
    for i = 13:14
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(1,2,i-12);
        imagesc(meanimg,range); axis equal; if i ==13; title('low tf flicker'); else title('high tf flicker'); end
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    overlay(:,:,1) = median(trialmean(:,:,stimOrder==1),3);
    overlay(:,:,2) = median(trialmean(:,:,stimOrder==7),3);
    overlay(:,:,3)= median(trialmean(:,:,stimOrder==13),3);
    %overlay(:,:,3)=0;
    overlay(overlay<0)=0; overlay = overlay/range(2);
    figure
    imshow(imresize(overlay,2));
    
    figure
    overlay(:,:,3)=0;
    imshow(imresize(overlay,2));
end

clear overlay
overlay(:,:,1) = median(trialmean(:,:,stimOrder==15 | stimOrder==39),3);
overlay(:,:,2) = median(trialmean(:,:,stimOrder==19 | stimOrder==43),3);
overlay(:,:,3)=0;
overlay(overlay<0)=0; overlay= overlay/range(2);
figure
imshow(imresize(overlay,2));

clear overlay
overlay(:,:,1) = median(trialmean(:,:,stimOrder==19),3);
overlay(:,:,3) = median(trialmean(:,:,stimOrder==43 ),3)*1.5;
overlay(:,:,2)=0;
overlay(overlay<0)=0; overlay= 0.5*overlay/range(2);
figure
imshow(imresize(overlay,2))


range = [-0.05 0.2]; %%% colormap range
if nstim==26 %%% gratings
    loc = 1:6; %%% map stim order onto subplot
    figure; set(gcf,'Name','vert gratings');
    for i = 1:6
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure;set(gcf,'Name','horiz gratings');
    for i = 7:12
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i-6));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','vert gratings');
    for i = 13:18
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i-12));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure;set(gcf,'Name','horiz gratings');
    for i = 19:24
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i-18));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','flicker');
    for i = 25:26
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(1,2,i-24);
        imagesc(meanimg,range); axis equal; if i ==25; title('low tf flicker'); else title('high tf flicker'); end
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
end

%%% plot mean for each stim condition, with layout corresponding to the stim
range = [-0.02 0.1];
if nstim==48 %%% spots
    loc = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24]; %%% map stim order onto subplot
    figure; set(gcf,'Name','OFF spots');
    for i = 1:24
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(4,6,loc(i));
        imagesc(meanimg,range); axis equal; axis off
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','ON spots');
    for i = 25:48
        meanimg = median(trialmean(:,:,stimOrder==i),3);
        subplot(4,6,loc(i-24));
        imagesc(meanimg,range); axis equal; axis off
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end


%%% save out pdf file!
if makeFigs
    [f p] = uiputfile('*.pdf','save pdf file');
    newpdfFile = fullfile(p,f);
    try
        dos(['ps2pdf ' 'c:\temp.ps "' newpdfFile '"'] )
        
    catch
        display('couldnt generate pdf');
    end
end

%%% save out a .mat with some data (needs to be updated so currently commented)
% [f p] = uiputfile('*.mat','save results');
% if f~=0
%     save(fullfile(p,f),'dF','greenframe','x','y','dFrepeats','cycLength','nstim');
% end