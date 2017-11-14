%% reads in sutter data, extracts cell traces, and aligns to stim
% optimized for octopus optic lobe with cal520 label
clear all
close all

%% Edit Following options to match dataset
% option of one or two color data (sutter stores 2-color as interleaved frames)
Opt.NumChannels = 2; 
% option to save figures to pdf file; make sure C:/temp/ folder exists
Opt.SaveFigs = 1;
Opt.MakeMov = 0;


%Change filepath to match where you have ratrix
%Remove paths that have functions named after standard matlab functions
cd('C:\Users\nlab\Documents\GitHub\ratrix');
rmpath('./matlabClub');
rmpath('.\analysis\eflister\phys\new');
rmpath('.\analysis\eflister\phys\new\helpers');

%%% frame rate for resampling
% dt = 0.5;
% framerate=1/dt;

%%% option of one or two color data (sutter stores 2-color as interleaved frames)
%twocolor = input('how many colors? 1 / 2 : ')-1;
twocolor = 2;
%makeFigs = input('make pdf file 0 / 1 :');
makeFigs = 1;
if makeFigs
    psfile = 'C:\temp\TempFigs.ps';
    if exist(psfile,'file')==2;delete(psfile);end
end

%%  get sutter data
% Following ~70 lines of code used to be contained within get2pSession.m script
% Get File Path for tiff Image
[f, p] = uigetfile({'*.mat;*.tif'},'.mat or .tif file');

%Get Image acquisition frame rate
%resampleHZ = input('Resample framerate (enter 0 to keep acquisition framerate) : ');
resampleHZ = 0;
if resampleHZ == 0
    Img_Info = imfinfo(fullfile(p,f));
    trash = evalc(Img_Info(1).ImageDescription);
    framerate = state.acq.frameRate;
    dt = 1/framerate;
else
    framerate = resampleHZ;
    dt = 1/framerate;
end

if strcmp(f(end-3:end),'.mat')
    disp('loading data')
    sessionName = fullfile(p,f);
    load(sessionName)
    disp('done')
    if ~exist('cycLength','var')
        cycLength=8;
    end
else
    % Uses the ttl file to find first frame of imaging after stim comes on
    %     ttl_file = input('Do you have a ttl file to read in? (yes:1/no:0): ');
    [ttlf, ttlp] = uigetfile('*.mat','ttl file');

    ttlFname = fullfile(ttlp,ttlf);
    ttl_file = 1;
    
    if ttl_file
        [stimPulse, framePulse] = getTTL(fullfile(ttlp,ttlf));
        
        % number of frames per cycle
        cycLength = mean(diff(stimPulse))/dt;
        % number of frames in window around each cycle. min of 4 secs, or actual cycle length + 2
        cycWindow = round(max(4/dt,cycLength));
        
        %Plot the Cycle Time
        figure
        plot(diff(stimPulse)); title('stimPulse cycle time');hold on
        plot(1:length(stimPulse),ones(size(stimPulse))*cycLength*dt); ylabel('secs');xlabel('stim #')
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        startTime = round(stimPulse(1)/dt)-1;
    else
        stimPulse = []; framePulse = []; startTime = 1;
    end
    
    
    %% Performs Image registration and resample at requested frame rate
    % returns dfofInterp(x,y,t) = timeseries at requested framerate, with pre-stim frames clipped off
    % greenframe = mean fluorescence image
    if twocolor
        [dfofInterp, dtRaw, redframe, greenframe, mv] = get2colordata(fullfile(p,f),dt,cycLength, makeFigs);
    else
        [dfofInterp, dtRaw, greenframe] = get2pdata(fullfile(p,f),dt,cycLength);
    end
    
    %Reduce Aligned stack to include only the stimulus times
    dfofInterp = dfofInterp(:,:,startTime:end);
    
end

% Create index vector of NaN images
xy = size(dfofInterp(:,:,1));
FrameBool = zeros(size(dfofInterp,3),1);
NaNFrameIndices = [];
ValidFrameIndices = [];
for iFrame = 1:length(dfofInterp)
    if ~isnan(dfofInterp(floor(xy(1)/2),floor(xy(2)/2),iFrame))
        ValidFrameIndices = [ValidFrameIndices, iFrame];
        FrameBool(iFrame) = 1;
    else
        NaNFrameIndices = [NaNFrameIndices, iFrame];
        FrameBool(iFrame) = 0;
    end
end
%% Load in the stimulus record
[fStim, pStim] = uigetfile('*.mat','stimulus record');

if fStim ~= 0
    load(fullfile(pStim,fStim),'stimRec');
    nCycles = floor(size(dfofInterp,3)/cycLength)-ceil((cycWindow-cycLength)/cycLength);  %%% trim off last stims to allow window for previous stim
    stimT = stimRec.ts - stimRec.ts(1);
    for i = 1:nCycles
        stimOrder(i) = stimRec.cond(min(find(stimT>((i-1)*cycLength*dt+0.1))));
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

%% generate periodic map
filt = fspecial('gaussian',5,1);
xy = size(dfofInterp(:,:,1));
map = zeros(xy);
for iFrame = 1:size(dfofInterp,3)
    %Only include the frames that aren't NaN; i.e. the frames that we kept
    %after z-plane sorting
    if ~isnan(dfofInterp(floor(xy(1)/2),floor(xy(2)/2),iFrame))
        map = map+imfilter(dfofInterp(:,:,iFrame),filt)*exp(2*pi*sqrt(-1)*iFrame/cycLength);
    end
end
map = map/size(dfofInterp,3); map(isnan(map)) = 0;
amp = abs(map);
prctile(amp(:),99)
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[pi/2  (2*pi -pi/4)]);
img = img.*repmat(amp,[1 1 3]);

figure
imshow(imresize(img,2))
colormap(hsv); colorbar
title(sprintf('fourier map at %d frame cycle',cycLength));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% mean fluorescence of the entire image
figure
plot((1:size(dfofInterp,3))*dt,squeeze(nanmean(nanmean(dfofInterp,2),1)));
title('full image mean'); hold on
for i = 1:reps
    plot([i*nstim*cycLength*dt  i*nstim*cycLength*dt], [0 0.5],'g');
end
xlabel('secs')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%% calculate two reference images for choosing points on ...
%%% absolute green fluorescence, and max df/f of each pixel
greenFig = figure;
title('95th Pct Green Channel')
stdImg = greenframe;
imagesc(stdImg,[prctile(stdImg(:),1) prctile(stdImg(:),99)*1.2]); hold on; axis equal; colormap gray;
normgreen = (stdImg - prctile(stdImg(:),1))/ (prctile(stdImg(:),99)*1.5 - prctile(stdImg(:),1));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% max df/f of each pixel
maxFig = figure;
stdImg = max(dfofInterp,[],3); stdImg = medfilt2(stdImg);
imagesc(stdImg,[prctile(stdImg(:),1) 2]); hold on; axis equal; colormap gray; title('max df/f')
normMax = (stdImg - prctile(stdImg(:),1))/ (prctile(stdImg(:),98) - prctile(stdImg(:),1));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% create merge overlay of absolute fluorescence and max change
merge = zeros(size(stdImg,1),size(stdImg,2),3);
merge(:,:,1)= normMax;
merge(:,:,2) = normgreen;
mergeFig = figure;
imshow(merge); title('Mean/Max Green Channel Merge')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%% time to select points! either by hand or automatic
selectPts = input('select points by hand (1) or automatic (0) : ');
if selectPts
    chooseFig = input('select based on 1) mean image, 2) max image, 3) merge image : ');
    if chooseFig==1 
        selectFig = greenFig;
    elseif chooseFig==2
        selectFig = maxFig;
    else
        selectFig = mergeFig; 
    end
    range = -2:2;
    clear x y npts
    npts = input('how many points ? ');
    for i =1:npts
        figure(selectFig); hold on
        [x(i), y(i)] = ginput(1); x=round(x); y = round(y);
        plot(x(i),y(i),'b*');
        dF(i,:) = squeeze(nanmean(nanmean(dfofInterp(y(i)+range,x(i)+range,:),2),1));
    end
    
else
    
    %%% select points based on peaks of max df/f
    %%%calculate max df/f image
    img = nanmax(dfofInterp,[],3);
    filt = fspecial('gaussian',5,3);
    stdImg = imfilter(img,filt);
    figure
    imagesc(stdImg,[0 2]); colormap gray
    
    %%% compare each point to the dilation of the region around it - if greater, it's a peak
    region = ones(3,3); region(2,2)=0;
    maxStd = stdImg > imdilate(stdImg,region);
    maxStd(1:3,:) = 0; maxStd(end-2:end,:)=0; maxStd(:,1:3)=0; maxStd(:,end-2:end)=0; %%% no points on border
    pts = find(maxStd);
    fprintf('%d max points\n', length(pts));
    
    %%% show max points
    [y, x] = ind2sub(size(maxStd),pts);
    figure
    imagesc(stdImg,[0 2]); hold on; colormap gray
    plot(x,y,'o');
    
    %%% crop image to avoid points near border that may have artifact
    disp('Select area in figure to include in the analysis');
    [xrange, yrange] = ginput(2);
    pts = pts(x>xrange(1) & x<xrange(2) & y>yrange(1) & y<yrange(2));
    
    %%% sort points based on their value (max df/f)
    [brightness, order] = sort(img(pts),1,'descend');
    figure
    plot(brightness); xlabel('N'); ylabel('brightness');
    fprintf('%d points in ROI\n',length(pts))
    
    %%% choose points over a cutoff, to eliminate noise / nonresponsive
    mindF= input('dF cutoff : ');
    pts = pts(img(pts)>mindF);
    fprintf('%d points in ROI over cutoff\n',length(pts))
    
    %%% plot selected points
    [y, x] = ind2sub(size(maxStd),pts);
    figure
    imagesc(stdImg,[0 2]); hold on; colormap gray
    plot(x,y,'o');
    
    %%% average df/f in a box around each selected point
    range = -2:2;
    clear dF
    for i = 1:length(x)
        dF(i,:) = nanmean(nanmean(dfofInterp(y(i)+range,x(i)+range,:),2),1);
    end
    
end  %%% end of if selectPts

%% Plotting
dF(dF>2)=2; %%% clip abnormally large values

%%% plot all fluorescence traces
figure
plot((1:size(dF,2))*dt,dF');
hold on
plot((1:size(dF,2))*dt,nanmean(dF,1),'g','Linewidth',2);
xlabel('secs');ylabel('df/f');title('Fluorescence Traces'); xlim([0 size(dF,2)*dt]);
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% plot movement correction trace
if exist('mv','var')
    figure
    plot(mv);
    title('Rigid Alignment Values')
    xlabel('x displacement');ylabel('y displacement');
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
plot((0:size(dFrepeats,2)-1)/cycWindow, squeeze(nanmean(dFrepeats,1)))
xlabel('stim #'); xlim([1 nstim+1]); ylim([-0.05 0.15])
title('mean trace for each repeat');
hold on; legend('1','2','3','4')
%plot((0:totalframes-1)/cycLength+1, squeeze(mean(mean(dFrepeats,3),1)),'g','Linewidth',2)
plot((0:size(dFrepeats,2)-1)/cycWindow, squeeze(nanmean(nanmedian(dFrepeats,3),1)),'g','Linewidth',2)
for i = 1:nstim
    plot([i i ],[0 0.3],'k:');
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% calculate cycle averages (timecourse for each individual stim)
clear cycAvgAll cycAvg cycImg
for i=1:cycWindow
    cycAvgAll(:,i) = nanmean(dF(:,i:round(cycLength):end),2); %%% cell-wise average across all stim
    cycAvg(i) = nanmean(nanmean(nanmedian(dfofInterp(:,:,i:round(cycLength):end),3),2),1); %%% average for all cells and stim
    cycImg(:,:,i) = nanmean(dfofInterp(:,:,i:round(cycLength):end),3); %%% pixelwise average across all stim
end

%%% plot pixel-wise cycle average
figure
for i = 1:cycLength
    subplot(2,6,i);
    imagesc(cycImg(:,:,i)-min(cycImg,[],3),[0 0.1]); axis equal
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
        dFclust(:,(i-1)*floor(cycWindow-4) + (1:floor(cycWindow-4)),r) = dF(:,round((repList(r)-1)*cycLength)+(3:floor(cycWindow-2))) - repmat(nanmean(dF(:,round((repList(r)-1)*cycLength)+(1:2)),2),[1 floor(cycWindow-4)]);
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
disp('doing clustering')
Z = linkage(dist,'ward');
figure
subplot(3,4,[1 5 9 ])
disp('doing dendrogram')
leafOrder = optimalleaforder(Z,dist);
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,1,'reorder',leafOrder);
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
title(sprintf('%u Clusters',nclust));
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
    plot((0:size(dFrepeats,2)-1)/cycWindow + 1, squeeze(nanmean(dFrepeats(c==clust,:,:),1))); hold on
    plot((0:size(dFrepeats,2)-1)/cycWindow + 1, squeeze(nanmean(nanmedian(dFrepeats(c==clust,:,:),3),1)),'g','LineWidth',2)
    xlabel('stim #'); xlim([1 nstim+1]); ylim([-0.05 0.2])
    title('mean of cluster, multiple repeats');
    for i = 1:nstim
        plot([i i ],[0  0.5],'k:');
    end
    
    %%% cycleaverage timecourse for each cell in this cluster
    subplot(2,2,3);
    plot(cycAvgAll(c==clust,:)');
    hold on
    plot(nanmean(cycAvgAll(c==clust,:),1),'g','Linewidth',2);
    %     plot((1:size(dF,2))*dt,dF(c==clust,:)'); hold on;
    %     xlim([1 size(dF,2)*dt]); xlabel('secs'); ylim([-0.2 2.1])
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end %end of for clust

%%% cycle average timecourse for each cluster
figure
hold on
for clust = 1:nclust
    plot(nanmean(cycAvgAll(c==clust,:),1),'Color',colors(clust,:));
end; title('mean cyc avg for each cluster)')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% mean response for each cluster
figure
hold on
for clust = 1:nclust
    plot((0:size(dFrepeats,2)-1)/cycWindow+1,nanmean(dFmean(c==clust,:,:),1),'Color',colors(clust,:));
end
hold on
for i = 1:nstim
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

evRange = 4:5; baseRange = 1:2; %%% timepoints for evoked and baseline activity
figure
for i = 1:length(stimOrder) %%% get pixel-wise evoked activity on each individual stim presentation
    trialmean(:,:,i) = nanmean(dfofInterp(:,:,round(cycLength*(i-1) + evRange)),3)- nanmean(dfofInterp(:,:,round(cycLength*(i-1) + baseRange)),3);
end
filt = fspecial('gaussian',5,1.5);
trialmean = imfilter(trialmean,filt);

%%% plot mean for each stim condition, with layout corresponding to the stim
range = [-0.02 0.1];
if nstim==12 %%% spots
    loc = [1 4 2 5 3 6]; %%% map stim order onto subplot
    figure; set(gcf,'Name','OFF spots');
    for i = 1:6
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i));
        imagesc(meanimg,range); axis equal
        stimImg(:,:,i) = meanimg;
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','ON spots');
    for i = 7:12
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i-6));
        imagesc(meanimg,range); axis equal
        stimImg(:,:,i) = meanimg;
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    overlay(:,:,1) = nanmean(stimImg(:,:,6),3);
    overlay(:,:,2) = nanmean(stimImg(:,:,12),3);
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
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure;set(gcf,'Name','horiz gratings');
    for i = 7:12
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i-6));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','flicker');
    for i = 13:14
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        subplot(1,2,i-12);
        imagesc(meanimg,range); axis equal; if i ==13; title('low tf flicker'); else title('high tf flicker'); end
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    overlay(:,:,1) = nanmedian(trialmean(:,:,stimOrder==1),3);
    overlay(:,:,2) = nanmedian(trialmean(:,:,stimOrder==7),3);
    overlay(:,:,3)= nanmedian(trialmean(:,:,stimOrder==13),3);
    %overlay(:,:,3)=0;
    overlay(overlay<0)=0; overlay = overlay/range(2);
    figure
    imshow(imresize(overlay,2));
    
    figure
    overlay(:,:,3)=0;
    imshow(imresize(overlay,2));
end


range = [-0.05 0.2]; %%% colormap range
if nstim==26 %%% gratings
    loc = 1:6; %%% map stim order onto subplot
    figure; set(gcf,'Name','vert gratings');
    for i = 1:6
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure;set(gcf,'Name','horiz gratings');
    for i = 7:12
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i-6));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','vert gratings');
    for i = 13:18
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i-12));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure;set(gcf,'Name','horiz gratings');
    for i = 19:24
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        subplot(2,3,loc(i-18));
        imagesc(meanimg,range); axis equal
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','flicker');
    for i = 25:26
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
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
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        subplot(4,6,loc(i));
        imagesc(meanimg,range); axis equal; axis off
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','ON spots');
    for i = 25:48
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        subplot(4,6,loc(i-24));
        imagesc(meanimg,range); axis equal; axis off
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end


%%% save out pdf file!
if makeFigs
    [f p] = uiputfile('*.pdf','save pdf file');
    newpdfFile = fullfile(p,f)
    try
        dos(['ps2pdf ' 'c:\temp\TempFigs.ps "' newpdfFile '"'] )
        
    catch
        display('couldnt generate pdf');
    end
end