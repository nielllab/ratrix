function varargout = sutterOctoNeural(varargin)
%% reads in sutter data, extracts cell traces, and aligns to stim
% optimized for octopus optic lobe with cal520 label
% if sutterOctoNeural is called as a function
if ~isempty(varargin)
    Opt = varargin{1};
else
    % option of one or two color data (sutter stores 2-color as interleaved frames)
    Opt.NumChannels = 2;
    % option to save figures to pdf file; make sure C:/temp/ folder exists
    Opt.SaveFigs = 1;
    Opt.psfile = 'C:\temp\TempFigs.ps';
    % option to create movies of non-aligned and aligned image sequences
    Opt.MakeMov = 0;
    % option for gaussian filter standard deviation
    Opt.fwidth = 0.5;
    % option to align or not
    Opt.align = 1;
    % channel for alignment
    Opt.AlignmentChannel=2;
    % Option to resample at a different framerate
    Opt.Resample = 1;
    Opt.Resample_dt = 0.5;
    % Option to read in ttl-file
    Opt.ttl_file = 1;
    %Option to output results structure
    %Set to 0 if you want to run as script
    Opt.SaveOutput = 0;
end


%%% frame rate for resampling
% dt = 0.5;
% framerate=1/dt;

if Opt.SaveFigs
    psfile = Opt.psfile;
    if exist(psfile,'file')==2;delete(psfile);end
end

%%  get sutter data
% Get File Path for tiff Image
if ~isfield(Opt,'fTif')
    %Get tif file input
    [Opt.fTif, Opt.pTif] = uigetfile({'*.tif'},'.tif file');
end

%Get Image acquisition frame rate
if Opt.Resample == 0
    Img_Info = imfinfo(fullfile(Opt.pTif,Opt.fTif));
    trash = evalc(Img_Info(1).ImageDescription);
    framerate = state.acq.frameRate;
    dt = 1/framerate;
else
    dt = Opt.Resample_dt;
    framerate = 1/dt;
end

%Read in ttl file if used
Opt.ttl_file = 1;
if Opt.ttl_file
    % Get File Path for ttl Image
    if ~isfield(Opt,'fTTL')
        %Get tif file input
        [Opt.fTTL, Opt.pTTL] = uigetfile('*.mat','ttl file');
    end
    
    [stimPulse, framePulse] = getTTL(fullfile(Opt.pTTL,Opt.fTTL));
    
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
if Opt.NumChannels == 2
    [dfofInterp, dtRaw, greenframe, Rigid, Rotation] = get2colordata(fullfile(Opt.pTif,Opt.fTif),dt,Opt);
else
    [dfofInterp, dtRaw, greenframe] = get2pdata(fullfile(Opt.pTif,Opt.fTif),dt,Opt);
end

%Reduce Aligned stack to include only the stimulus times
dfofInterp = dfofInterp(:,:,startTime:end);

%% Load in the stimulus record
% Get File Path for stimulus record file
if ~isfield(Opt,'fStim')
    %Get tif file input
    [Opt.fStim, Opt.pStim] = uigetfile('*.mat','stimulus record');
end

if Opt.fStim ~= 0
    load(fullfile(Opt.pStim,Opt.fStim),'stimRec');
  alignRecs =1;
    nCycles = floor(size(dfofInterp,3)/cycLength)-ceil((cycWindow-cycLength)/cycLength)-1;  %%% trim off last stims to allow window for previous stim
    stimT = stimRec.ts - stimRec.ts(1);
    for i = 1:length(stimRec.cond)
        if stimRec.cond(i) == 0
            stimRec.cond(i) = pastCond;
        else
            pastCond = stimRec.cond(i);
        end
    end

    for i = 1:nCycles
        stimOrder(i) = stimRec.cond(min(find(stimT>((i-1)*cycLength*dt+0.1))));
    end
    
    stimTimes = stimPulse-stimPulse(1);
    stimTimes = stimTimes(1:nCycles);
    
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

title(sprintf('fourier map at %.3f frame cycle',cycLength));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% mean fluorescence of the entire image
mfluorescence = squeeze(mean(mean(dfofInterp,2),1));
figure
plot((1:size(dfofInterp,3))*dt,mfluorescence);
title('full image mean'); hold on
for i = 1:reps
    plot([i*nstim*cycLength*dt  i*nstim*cycLength*dt], [0 0.5],'g');
end
xlabel('secs');ylabel('dfof');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%% calculate two reference images for choosing points on ...
%%% absolute green fluorescence, and max df/f of each pixel
greenFig = figure;

stdImg = greenframe;
imagesc(stdImg,[prctile(stdImg(:),1) prctile(stdImg(:),99)*1.2]); hold on; axis equal; colormap gray;
title('Mean Green Channel');

normgreen = (stdImg - prctile(stdImg(:),1))/ (prctile(stdImg(:),99)*1.5 - prctile(stdImg(:),1));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% max df/f of each pixel
maxFig = figure;
stdImg = max(dfofInterp,[],3); stdImg = medfilt2(stdImg);
imagesc(stdImg,[prctile(stdImg(:),1) 2]); hold on; axis equal; colormap gray; title('max df/f')
normMax = (stdImg - prctile(stdImg(:),1))/ (prctile(stdImg(~isinf(stdImg(:))),98) - prctile(stdImg(:),1));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% create merge overlay of absolute fluorescence and max change
merge = zeros(size(stdImg,1),size(stdImg,2),3);
merge(:,:,1)= normMax;
merge(:,:,2) = normgreen;
mergeFig = figure;
imshow(merge); title('Mean/Max Green Channel Merge')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%% time to select points! either by hand or automatic
if isfield(Opt,'selectPts')
    selectPts = Opt.selectPts;
else
    selectPts = input('select points by hand (1) or automatic (0) : ');
end

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
    rightclick = 0;
    fprintf('Select points on image. Rightclick to exit interactive ginput');
    i=0;
    while rightclick ~= 3
        i = i+1;
        figure(selectFig); hold on
        [x(i), y(i), rightclick] = ginput(1); x=round(x); y = round(y);
        plot(x(i),y(i),'b*');
        dF(i,:) = squeeze(nanmean(nanmean(dfofInterp(y(i)+range,x(i)+range,:),2),1));
     end
    
else
    
    %%% select points based on peaks of max df/f
    %%%calculate max df/f image
    img = nanmax(dfofInterp,[],3);
    img(isnan(img(:))) = 0;
    img(isinf(img(:))) = 0;
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
    if isfield(Opt,'selectPts')
        mv = Rigid.T;
        buffer = floor((max(abs(mv(:)))+2)/2);
        xrange = [buffer, size(img,2) - buffer];
        yrange = [buffer, size(img,1) - buffer];
    else
        [xrange, yrange] = ginput(2);
    end
    pts = pts(x>xrange(1) & x<xrange(2) & y>yrange(1) & y<yrange(2));
    
    %%% sort points based on their value (max df/f)
    [brightness, order] = sort(img(pts),1,'descend');
    figure
    plot(brightness); xlabel('N'); ylabel('brightness');
    fprintf('%d points in ROI\n',length(pts))
    
    %%% choose points over a cutoff, to eliminate noise / nonresponsive
    if isfield(Opt,'mindF')
        mindF = Opt.mindF;
    else
        mindF= input('dF cutoff : ');
    end
    if sum(img(pts)>mindF)<10
        mindF=0;
    end
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
        dF(i,:) = mean(mean(dfofInterp(y(i)+range,x(i)+range,:),2),1);
    end
    
end  %%% if/else


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
        startFrame = stimTimes(repList(r))/dt;
        dFrepeats(:,(i-1)*cycWindow + (1:cycWindow),r) = dF(:,round(startFrame+(1:cycWindow))) - repmat(dF(:,round(startFrame+1)),[1 floor(cycWindow)]);
        %dFrepeats(:,(i-1)*cycWindow + (1:cycWindow),r) = dF(:,round((repList(r)-1)*cycLength)+(1:cycWindow)) - repmat(dF(:,round((repList(r)-1)*cycLength)+1),[1 floor(cycWindow)]);
        
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

startFrames = round(stimTimes/dt);
%%% calculate cycle averages (timecourse for each individual stim)
clear cycAvgAll cycAvg cycImg
for i=1:cycWindow;
    cycAvgAll(:,i) = nanmean(dF(:,startFrames+i),2); %%% cell-wise average across all stim
    cycAvg(i) = mean(mean(nanmean(dfofInterp(:,:,startFrames+i),3),2),1); %%% average for all cells and stim
    cycImg(:,:,i) = nanmean(dfofInterp(:,:,startFrames+i),3); %%% pixelwise average across all stim
    
end

%%% plot pixel-wise cycle average
figure
for i = 1:min(cycLength,10)
    subplot(2,5,i);
    imagesc(cycImg(:,:,i)-min(cycImg,[],3),[0 0.025]); axis equal
    imagesc(cycImg(:,:,i)-mean(cycImg(:,:,1:2),3),[0 0.025]); axis equal
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% plot mean timecourse
cycAvgAll = cycAvgAll - repmat(cycAvgAll(:,1),[1 size(cycAvgAll,2)]);
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
if isfield(Opt,'nclust')
    nclust = Opt.nclust;
else
    nclust =input('# of clusters : ');
end

c = cluster(Z,'maxclust',nclust);
colors = hsv(nclust+1); %%% color code for each cluster

%%% plot spatial location of cells in each cluster
figure
imagesc(stdImg,[0 prctile(stdImg(:),95)]); colormap gray; axis equal;hold on
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
    plot((0:size(dFrepeats,2)-1)/cycWindow + 1, squeeze(mean(dFrepeats(c==clust,:,:),1))); hold on
    plot((0:size(dFrepeats,2)-1)/cycWindow + 1, squeeze(mean(nanmedian(dFrepeats(c==clust,:,:),3),1)),'g','LineWidth',2)
    xlabel('stim #'); xlim([1 nstim+1]); ylim([-0.05 0.2])
    title('mean of cluster, multiple repeats');
    for i = 1:nstim;
        plot([i i ],[0  0.5],'k:');        
    end
    colormap jet;freezeColors;colormap gray;

        %%% cycleaverage timecourse for each cell in this cluster
        subplot(2,2,3);
        plot(cycAvgAll(c==clust,:)');
        hold on
        plot(nanmean(cycAvgAll(c==clust,:),1),'g','Linewidth',2);
        title('Cycle Average Timecourse');
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

evRange = 4:6; baseRange = 1:2; %%% timepoints for evoked and baseline activity
for i = 1:length(stimOrder); %%% get pixel-wise evoked activity on each individual stim presentation
    startFrame = stimTimes(i)/dt;
    trialmean(:,:,i) = nanmean(dfofInterp(:,:,round(startFrame + evRange)),3)- nanmean(dfofInterp(:,:,round(startFrame + baseRange)),3);
    trialTcourse(:,i) = squeeze(mean(mean(dfofInterp(:,:,round(startFrame + (1:8))),2),1)) - mean(mean(dfofInterp(:,:,round(startFrame + 1)),2),1) ;
    
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
if nstim==14 %%% gratings , horiz/vert, 3sf, 2tf
    loc = 1:6 %%% map stim order onto subplot
    figLabel = 'vert gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 0;
    pixPlot;
    
    loc = 1:6 %%% map stim order onto subplot
    figLabel = 'horiz gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 6;
    pixPlot;
    
       loc = 1:2 %%% map stim order onto subplot
    figLabel = 'flicker';
    npanel = 2; nrow = 1; ncol = 2; offset = 12;
    pixPlot;
    
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
if nstim==26 %%% gratings , up/down/left/right, 3sf, 2tf
    loc = 1:6 %%% map stim order onto subplot
    figLabel = 'vert1 gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 0;
    pixPlot;
    
    loc = 1:6 %%% map stim order onto subplot
    figLabel = 'horiz1 gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 6;
    pixPlot;
    
       loc = 1:6 %%% map stim order onto subplot
    figLabel = 'vert2 gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 12;
    pixPlot;
    
    loc = 1:6 %%% map stim order onto subplot
    figLabel = 'horiz2 gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 18;
    pixPlot;
  
       loc = 1:2 %%% map stim order onto subplot
    figLabel = 'flicker';
    npanel = 2; nrow = 1; ncol = 2; offset = 24;
    pixPlot;
   
end



if nstim==13 %%% gratings 1 tf
    range = [-0.025 0.1]; %%% colormap range
    loc = [1 5 9 2 6 10 3 7 11 4 8 12]; %%% map stim order onto subplot
    figLabel = 'gratings';
    npanel = 12; nrow = 3; ncol = 4; offset = 0;
    pixPlot;
    
    figLabel = 'flicker';
    npanel = 1; nrow = 1; ncol = 1; offset = 12;
    pixPlot;
end


if nstim==48 %%% 4x6 spots
    range = [-0.05 0.2];
    loc = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24]; %%% map stim order onto subplot
    
    figLabel = 'OFF spots';
    npanel = 24; nrow = 4; ncol = 6; offset = 0;
    pixPlot;
    
    figLabel = 'ON spots';
    npanel = 24; nrow = 4; ncol = 6; offset = 24;
    pixPlot;
end

if nstim==50 %%% 5x5 spots
    range = [-0.02 0.1];
    loc = [1 6 11 16 21 2 7 12 17 22 3 8 13 18 23 4 9 14 19 24 5 10 15 20 25]; %%% map stim order onto subplot
    %loc = [21 16 11 6 1 22 17 12 7 2 23 18 13 8 3 24 19 14 9 4 25 20 15 10 5]; %%% flipped direction
    figLabel = 'OFF spots';
    npanel = 25; nrow = 5; ncol = 5; offset = 0;
    pixPlot;
    
    figLabel = 'ON spots';
    npanel = 25; nrow = 5; ncol = 5; offset = 25;
    pixPlot;
end


if Opt.SaveFigs
    if ~isfield(Opt,'pPDF')
        [Opt.fPDF, Opt.pPDF] = uiputfile('*.pdf','save pdf file');
    end
    
    newpdfFile = fullfile(Opt.pPDF,Opt.fPDF);
    try
        dos(['ps2pdf ' 'c:\temp\TempFigs.ps "' newpdfFile '"'] )
        
    catch
        display('couldnt generate pdf');
    end
end

if Opt.SaveOutput
    Output.R = Rigid;
    outfile = fullfile(Opt.pOut,Opt.fOut);
    save(outfile, 'trialmean', 'trialTcourse', 'stimOrder', 'c', 'dFrepeats','x','y','stdImg')
    
    varargout{1} = Output;
end
close all

end