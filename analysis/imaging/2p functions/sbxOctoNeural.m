function varargout = sutterOctoNeural(varargin)
%% reads in sutter data, extracts cell traces, and aligns to stim
% optimized for octopus optic lobe with cal520 label
% if sutterOctoNeural is called as a function
close all
if ~isempty(varargin)
    Opt = varargin{1};
else
    %     % option of one or two color data (sutter stores 2-color as interleaved frames)
    %     Opt.NumChannels = 2;
    % option to save figures to pdf file; make sure C:/temp/ folder exists
    Opt.SaveFigs = 1;
    Opt.psfile = 'C:\temp\TempFigs.ps';
    %%% manually select points?
    Opt.selectPts=0;
    %%% manually choose region to crop full image in selecting points
    Opt.selectCrop =1;
    %%% minimum brightness of selected points
    % Opt.mindF = 200;
    %%% number of clusters from hierarchical analysis
    %Opt.nclust = 5;
    
    %     % option to create movies of non-aligned and aligned image sequences
    %     Opt.MakeMov = 0;
    %     % option for gaussian filter standard deviation
    %     Opt.fwidth = 0.5;
    %     % option to align or not
    %     Opt.align = 1;
    %     % channel for alignment
    %     Opt.AlignmentChannel=2;
    %     % Option to resample at a different framerate
    %     Opt.Resample = 1;
    Opt.Resample_dt = 0.1;
    %     % Option to read in ttl-file
    %     Opt.ttl_file = 1;
    %     %Option to output results structure
    %     %Set to 0 if you want to run as script
    %     Opt.SaveOutput = 0;
end


%%% frame rate for resampling
% dt = 0.5;
% framerate=1/dt;

if Opt.SaveFigs
    psfile = Opt.psfile
    if exist(psfile,'file')==2;delete(psfile);end
end
dt = Opt.Resample_dt;
cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters eff
cfg.syncToVid=0; cfg.saveDF=0;

sessionName=0; %%% don't save session data itself
if isfield(Opt,'fSbx')
    fileName = fullfile(Opt.pSbx,Opt.fSbx);
end


get2pSession_sbx;  %%% returns dfofInterp, and phasetimes (time in secs each stim started)


global info
mv = info.aligned.T;

if ~isfield(Opt,'sub_noise');
    Opt.sub_noise = input('subtract noise from sidebands? 0/1 ');
end

if Opt.sub_noise==1
    display('subtracting off noise')
    %%% subtract off noise as measured from sideband %%%
    greensmall = double(imresize(greenframe,0.5));
    F = (1 + dfofInterp).*repmat(greensmall,[1 1 size(dfofInterp,3)]);
    offset = squeeze(nanmean(F(:,[1:20 end-20:end],:),2));
    offset = offset-mean(offset(:));
    figure
    imagesc(offset); colorbar; title('noise measured from sidebands'); xlabel('frame'); ylabel('row');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure
    plot(nanmean(offset(:,1:1000),1));
    xlabel('frame'); ylabel('sideband value'); title('sideband noise over time');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
            figure
    plot(nanmean(offset,1));
    xlabel('frame'); ylabel('sideband value'); title('sideband noise over time');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    offset_full = repmat(offset,[1 1 size(F,2)]);
    offset_full = permute(offset_full, [1 3 2]);
    
    F_fix = F-offset_full;
    greensmall = prctile(F_fix,10,3);
    F0 = repmat(greensmall,[1 1 size(dfofInterp,3)]);
    
    greenframe = imresize(greensmall,2);
    dfofInterp = (F_fix - F0)./F0;
    
end


if isfield(Opt,'zbinning');
    zbin = Opt.zbinning
else
    zbin = input('do zbinning? 0/1 : ');
end

if zbin
    display('doing clustering')
    %%% recreate small version of absolute fluorescence
    greensmall = double(imresize(greenframe,0.5));
    F = (1 + dfofInterp).*repmat(greensmall,[1 1 size(dfofInterp,3)]);
    
    %%% resize and reshape images into vectors, to calculate distance
    smallDf = imresize(F(50:350,50:350,:),1/2); %%% remove edges for boundary effects
    % smallDf = reshape(smallDf,size(smallDf,1)*size(smallDf,2),size(smallDf,3));
    smallMean = nanmedian(smallDf,3);
    figure
    imagesc(smallMean);
    
    for i = 1:size(smallDf,3);
        
        im = smallDf(:,:,i);
        cc = corrcoef(im(:),smallMean(:));
        dist(i) = cc(2,1);
    end
    
    figure
    plot(dist), ylim([0 1]); title('correlation with median')
    %ccthresh = 0.9;
    if isfield(Opt,'binningThresh')
        ccthresh = Opt.binningThresh;
    else
        ccthresh = input('enter correlation threshold : ')
    end
    
    figure
    plot(dist); ylim([0 1])
    title('correlation of images with median'); xlabel('frame'); ylabel('corr coef')
    hold on
    plot([1 length(dist)], [ccthresh ccthresh],'r:');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    useframes = dist>ccthresh;
    figure
    imagesc(mean(F(:,:,dist>ccthresh),3)); title(sprintf('mean of frames above thresh %0.2f used',mean(useframes)));
    
    
    display('redoing dfofinterp')
    F0 = repmat(prctile(F(:,:,useframes),10,3),[1 1 size(F,3)]);
    dfofInterp = (F-F0)./F0;
    
    dfofInterp(isnan(dfofInterp))=0;
    
    dfofInterp(:,:,~useframes)=NaN;
    mv(~useframes,:)=NaN;
    greenframe = imresize(mean(F(:,:,useframes),3),2);
    
    for junk=1:0 %%% compress out old z-bin cluster code
        %     %%% old cluster-based binning
        %     D = pdist(smallDf','euclidean');
        %
        %     %Create hierarchical cluster tree based on D
        %     Z = linkage(D,'ward');
        %     %Create figure of hierarchical cluster tree for visualization purposes
        %     figure
        %     [h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,3);
        %     title('Hierarchical Cluster tree of Image Sequence');
        %
        %     nclust = input('How many z-plane clusters do you want?: ');
        %     T = cluster(Z,'maxclust',nclust);
        %
        %     %%% compare clusters and movement
        %     figure
        %     plot(T*5); hold on; plot(mv)
        %     legend('clusters','x movement','y movement')
        %     if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        %
        %     figure
        %     for i = 1:nclust;
        %         subplot(2,3,i)
        %         imagesc(mean(F(:,:,T==i),3));
        %         title(sprintf('clust %d n = %d',i,sum(T==i)));
        %     end
        %     if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        %     useBin = input('which bin to use : ');
        %     display('redoing dfofinterp')
        %     F0 = repmat(prctile(F(:,:,T==useBin),10,3),[1 1 size(F,3)]);
        %     dfofInterp = (F-F0)./F0;
        %
        %     dfofInterp(:,:,T~=useBin)=NaN;
        %     mv(T~=useBin,:)=NaN;
        %     greenframe = imresize(mean(F(:,:,T==useBin),3),2);
    end
    
    figure
    range =[prctile(greenframe(:),1) prctile(greenframe(:),98)*1.2];
    imagesc(greenframe,range); colormap gray
    title(sprintf('mean of binned thresh = %0.2f used %0.2f',ccthresh, mean(useframes)))
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end


buffer(:,1) = max(mv,[],1)/cfg.spatialBin+1; buffer(buffer<1)=1;
buffer(:,2) = max(-mv,[],1)/cfg.spatialBin+1; buffer(buffer<0)=0;
buffer=round(buffer)
buffer(2,:) = buffer(2,:)+32 %%% to account for deadbands;

dfofInterp= dfofInterp(buffer(1,1):(end-buffer(1,2)),buffer(2,1):(end-buffer(2,2)),:);

stdImg = imresize(greenframe,1/cfg.spatialBin);
stdImg= stdImg(buffer(1,1):(end-buffer(1,2)),buffer(2,1):(end-buffer(2,2)),:);
greenCrop = double(stdImg);

thresh = prctile(greenCrop(:),95)/50; %%% cut out points that are 100x dimmer than peak
dfofInterp(repmat(greenCrop,[1 1 size(dfofInterp,3)])<thresh)=0;


figure
imagesc(greenCrop>thresh);

% number of frames per cycle
cycLength = median(diff(phasetimes))/dt
% number of frames in window around each cycle. min of 4 secs, or actual cycle length + 2
cycWindow = round(max(2/dt,cycLength));

stimTimes = phasetimes;   %%% we call them phasetimes in behavior, but better to call it stimTimes here
startFrame = round((stimTimes(1)-1)/dt);
dfofInterp = dfofInterp(:,:,startFrame:end);   %%% movie starts 1 sec before first stim
stimTimesOld = stimTimes-stimTimes(1)+1;
% stimTimesOld = stimTimesOld(1:end-3);
% stimTimes = stimTimes(stimTimes/dt < size(dfofInterp,3)-cycWindow - 1);
%%% hack to account for bad stimtimes
stimTimes = 1:cycLength*dt:(size(dfofInterp,3)-cycWindow - 30)*dt;  %%% make sure you have one cycle, plus 3sec padding to be safe, at end
stimTimes = stimTimes(stimTimes<max(stimTimesOld));


figure
plot(diff(stimTimes)); hold on; plot(diff(stimTimesOld)); title(sprintf('time between stim on 2p trigs, median %0.03f',median(diff(stimTimes))));ylabel('secs');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

% Get File Path for stimulus record file


fileName
if ~isfield(Opt,'fStim')
    %Get tif file input
    [Opt.fStim, Opt.pStim] = uigetfile('*.mat','stimulus record');
end

%%% need to figure out whether to trim off beginning
load(fullfile(Opt.pStim,Opt.fStim),'stimRec','freq','orient');
alignRecs =1;
%nCycles = floor(size(dfofInterp,3)/cycLength)-ceil((cycWindow-cycLength)/cycLength)-2;  %%% trim off last stims to allow window for previous stim
nCycles  = length(stimTimes);
stimT = stimRec.ts - stimRec.ts(1);
for i = 1:length(stimRec.cond)
    if stimRec.cond(i) == 0
        stimRec.cond(i) = pastCond;
    else
        pastCond = stimRec.cond(i);
    end
end

figure
plot(stimT(1:end-1),diff(stimRec.cond));
hold on
plot(cycLength*dt*(1:nCycles),0,'*');

figure
plot(diff(stimT(stimT>0)));
title('differencee of psychstim frames'); ylabel('secs')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end



for i = 1:nCycles
    stimOrder(i) = stimRec.cond(min(find(stimT>((i-1)*cycLength*dt+0.1))));
end

figure
hold on
plot(stimOrder)
plot(stimRec.cond(1:2:end));
ylabel('stimulus cond')
legend('stimOrder','stimRec.cond');
title('should overlap except end')


nCycles = min(length(stimTimes),nCycles); %%% trim to length of video or length of stimrech, whichever is shorter
stimTimes = stimTimes(1:nCycles);
nstim = max(stimOrder);

stimOrder = stimOrder(1:nCycles);
for i = 1:nstim
    nStimRep(i) = sum(stimOrder==i);
end
totalframes = cycLength*nstim;
reps = floor(size(dfofInterp,3)/totalframes);  %%% number of times the whole stimulus set was repeated



%% generate periodic map
filt = fspecial('gaussian',10,1);
xy = size(dfofInterp(:,:,1));
map = zeros(xy);
nUsed = 0;
for iFrame = round(stimTimes(1)/dt):size(dfofInterp,3)
    %Only include the frames that aren't NaN; i.e. the frames that we kept
    %after z-plane sorting
    if ~isnan(dfofInterp(floor(xy(1)/2),floor(xy(2)/2),iFrame))
        nUsed = nUsed+1;
        map = map+imfilter(dfofInterp(:,:,iFrame),filt)*exp(2*pi*sqrt(-1)*iFrame/cycLength);
    end
end
map = map/nUsed; map(isnan(map)) = 0;
amp = abs(map);
maxAmp = prctile(amp(:),99);
maxAmp = 0.025;
amp=amp/maxAmp; amp(amp>1)=1;
cycPhase = mod(angle(map),2*pi);
img = mat2im(cycPhase,hsv,[0 2*pi]);
img = img.*repmat(amp,[1 1 3]);
cycAmp = amp;

cycPolarImg = img;
figure
imshow(imresize(img,2))
colormap(hsv); colorbar

title(sprintf('%.03f frame cycle %0.3f amp',cycLength,maxAmp));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


% some debugging to look at traces of individual pixesl
% keyboard
%
% figure
% subplot(2,1,1)
% imagesc(greenCrop); colormap gray; axis equal; hold on
% for i = 1:20
%     subplot(2,1,1)
%     [y x] = ginput(1);
%     plot(y,x,'g*')
%     subplot(2,1,2)
%     range = -10:10
%     d = squeeze(mean(dfofInterp(round(x+range),round(y+range),:),[1,2]))
%     plot((1:length(d))*dt,d)
%     xlim([0 60]); ylim([-0.2 0.2])
% end


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


% %%% mean fluorescence in ROI
% range= 20;
% mfluorescence = squeeze(mean(mean(dfofInterp(yp+range,xp+range,:),2),1));
% figure
% plot((1:size(dfofInterp,3))*dt,mfluorescence);
% title('full image mean'); hold on
% for i = 1:reps
%     plot([i*nstim*cycLength*dt  i*nstim*cycLength*dt], [0 0.5],'g');
% end
% xlabel('secs');ylabel('dfof');
% if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%% calculate two reference images for choosing points on ...
%%% absolute green fluorescence, and max df/f of each pixel
greenFig = figure;

stdImg = imresize(greenframe,1/cfg.spatialBin);
stdImg= stdImg(buffer(1,1):(end-buffer(1,2)),buffer(2,1):(end-buffer(2,2)),:);
greenCrop = double(stdImg);
%imagesc(stdImg,[prctile(stdImg(:),1) prctile(stdImg(:),99)*1.2]); hold on; axis equal; colormap gray;
imagesc(stdImg,[min(stdImg(:)) prctile(stdImg(:),95)*1.2]); hold on; axis equal; colormap gray;
meanGreenImg = mat2im(greenCrop,gray,[prctile(greenCrop(:),1) prctile(greenCrop(:),99)*1.2]);

title('Mean Green Channel');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

stdImg = double(stdImg);
normgreen = (stdImg - prctile(stdImg(:),1))/ (prctile(stdImg(:),99)*1.5 - prctile(stdImg(:),1));
normgreenraw = normgreen;

normgreen = normgreen*2;
normgreen(normgreen<0)=0; normgreen(normgreen>1)=1;
normgreen = repmat(normgreen,[1 1 3]);

%%% max df/f of each pixel
maxFig = figure;
stdImg = max(dfofInterp,[],3); stdImg = medfilt2(stdImg);
imagesc(stdImg,[prctile(stdImg(:),1) prctile(stdImg(:),99)]); hold on; axis equal; colormap gray; title('max df/f')
normMax = (stdImg - prctile(stdImg(:),1))/ (prctile(stdImg(~isinf(stdImg(:))),98) - prctile(stdImg(:),1));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% create merge overlay of absolute fluorescence and max change
merge = zeros(size(stdImg,1),size(stdImg,2),3);
merge(:,:,1)= normMax;
merge(:,:,2) = normgreenraw;
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
    %img = nanmax(dfofInterp,[],3);
    img = greenCrop;
    img(isnan(img(:))) = 0;
    img(isinf(img(:))) = 0;
    filt = fspecial('gaussian',5,1);
    stdImg = imfilter(img,filt);
    figure
    imagesc(stdImg); colormap gray
    
    %%% compare each point to the dilation of the region around it - if greater, it's a peak
    region = ones(3,3); region(2,2)=0;
    maxStd = stdImg > imdilate(stdImg,region);
    maxStd(1:3,:) = 0; maxStd(end-2:end,:)=0; maxStd(:,1:3)=0; maxStd(:,end-2:end)=0; %%% no points on border
    pts = find(maxStd);
    fprintf('%d max points\n', length(pts));
    
    %%% show max points
    [y, x] = ind2sub(size(maxStd),pts);
    figure
    imagesc(stdImg,[0 prctile(stdImg(:),98)]);hold on; colormap gray
    plot(x,y,'o');
    
    %%% crop image to avoid points near border that may have artifact
    if isfield(Opt,'selectCrop') && Opt.selectCrop ==1
        disp('Select area in figure to include in the analysis');
        [xrange, yrange] = ginput(2);
    else
        b = 5;
        xrange = [b size(img,2)-b];
        yrange = [b size(img,1)-b];
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
    pts = pts(img(pts)>mindF);
    fprintf('%d points in ROI over cutoff\n',length(pts))
    
    hold on
    plot([1 length(brightness)],[mindF mindF],'b');
    title(sprintf('%d points in ROI over cutoff\n',length(pts)))
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    %%% plot selected points
    [y, x] = ind2sub(size(maxStd),pts);
    figure
    imagesc(stdImg,[0 prctile(stdImg(:),98)]); hold on; colormap gray
    plot(x,y,'o');
    
    %%% average df/f in a box around each selected point
    range = -2:2;
    clear dF
    for i = 1:length(x)
        dF(i,:) = mean(mean(dfofInterp(y(i)+range,x(i)+range,:),2),1);
    end
    xpts = x; ypts = y; %%% new names so they don't get overwritten
end  %%% if/else


%% Plotting
dF(dF>2)=2; %%% clip abnormally large values

%%% plot all fluorescence traces
figure
plot((1:size(dF,2))*dt,dF');
hold on
plot((1:size(dF,2))*dt,nanmean(dF,1),'g','Linewidth',2);
xlabel('secs');ylabel('df/f');title('Fluorescence Traces'); xlim([0 size(dF,2)*dt]);
%if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

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
hold on;
%plot((0:totalframes-1)/cycLength+1, squeeze(mean(mean(dFrepeats,3),1)),)
plot((0:size(dFrepeats,2)-1)/cycWindow, squeeze(mean(nanmedian(dFrepeats,3),1)),'g','Linewidth',2)
for i = 1:nstim;
    plot([i i ],[0 0.3],'k:');
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

startFrames = round(stimTimes/dt)-10;
%%% calculate cycle averages (timecourse for each individual stim)
clear cycAvgAll cycAvg cycImg
for i=1:cycWindow;
    cycAvgAll(:,i) = nanmean(dF(:,startFrames+i),2); %%% cell-wise average across all stim
    cycAvg(i) = mean(mean(nanmean(dfofInterp(:,:,startFrames+i),3),2),1); %%% average for all cells and stim
    cycImg(:,:,i) = nanmean(dfofInterp(:,:,startFrames+i),3); %%% pixelwise average across all stim
    
end

%%% plot pixel-wise cycle average
figure
for i = 1:min(cycLength,30)
    subplot(5,6,i);
    % imagesc(cycImg(:,:,i)-min(cycImg,[],3),[0 0.1]); axis equal
    data = cycImg(:,:,i)-mean(cycImg(:,:,1:10),3);
    datafilt = imfilter(data,fspecial('gaussian',[10 10],2));
    imagesc(datafilt,[0 0.1]); axis equal; axis off
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% plot weighted pixel-wise cycle average
figure
for i = 1:min(cycLength,30)
    subplot(5,6,i);
    % imagesc(cycImg(:,:,i)-min(cycImg,[],3),[0 0.1]); axis equal
    data = cycImg(:,:,i)-mean(cycImg(:,:,1:10),3);
    datafilt = imfilter(data,fspecial('gaussian',[10 10],2));
    datafilt(isnan(datafilt))=0;
    data_im = mat2im(datafilt,jet,[0 0.05]);
    imshow(data_im.*normgreen);
    axis equal; axis off
end

if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% plot  mean timecourse
cycAvgAll = cycAvgAll - repmat(cycAvgAll(:,1),[1 size(cycAvgAll,2)]);
figure
plot((1:length(cycAvg))*dt,cycAvg); title('cycle average all cells'); xlabel('time'); ylabel('dF')
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
dFclust = imresize(dFclust,[size(dFclust,1) 0.5*size(dFclust,2)]);   %%% downsample to improve SNR
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

display('doing pixel plots')

gratingTitle=0; %%% titles for grating figs?
evRange = 10:20; baseRange = 1:5; %%% timepoints for evoked and baseline activity
dfInterpsm = imresize(dfofInterp,0.25);
dfWeight = dfInterpsm.* repmat(imresize(normgreen(:,:,1),0.25),[1 1 size(dfofInterp,3)]);
for i = 1:length(stimOrder); %%% get pixel-wise evoked activity on each individual stim presentation
    startFrame = (stimTimes(i)-0.5)/dt;
    trialmean(:,:,i) = nanmean(dfofInterp(:,:,round(startFrame + evRange)),3)- nanmean(dfofInterp(:,:,round(startFrame + baseRange)),3);
    trialTcourse(:,i) = squeeze(mean(mean(dfofInterp(:,:,round(startFrame + (1:30))),2),1)) - mean(mean(dfofInterp(:,:,round(startFrame + 1)),2),1) ;
    weightTcourse(:,i) = (squeeze(mean(mean(dfWeight(:,:,round(startFrame + (1:30))),2),1)) - mean(mean(mean(dfWeight(:,:,round(startFrame + baseRange)),3),2),1))/mean(normgreen(:)) ;
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
    range = [-0.05 0.2]; %%% colormap range
    loc = [1 5 9 2 6 10 3 7 11 4 8 12]; %%% map stim order onto subplot
    figLabel = 'gratings';
    npanel = 12; nrow = 3; ncol = 4; offset = 0;
    gratingTitle = 1; pixPlot;
    pixPlotWeight;
    
    figLabel = 'flicker';
    npanel = 1; nrow = 1; ncol = 1; offset = 12;
    gratingTitle=0;
    pixPlot;
    pixPlotWeight;
    
    mapGratingsOcto;
    figure
    subplot(2,2,1); imshow(meanGreenImg);
    subplot(2,2,2); imshow(overlayImg);
    subplot(2,2,3); imshow(cycPolarImg); title('timecourse')
    subplot(2,2,4); imshow(hvImg); title('h vs v')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end


if nstim==17 %%% gratings 1 tf; either 4sfx4orient, or 2sf x 8 orient
    range = [-0.05 0.2]; %%% colormap range
    loc = [1 5 9 13 2 6 10 14 3 7 11 15 4 8 12 16]; %%% map stim order onto subplot
    figLabel = 'gratings';
    npanel = 16; nrow = 4; ncol = 4; offset = 0;
    gratingTitle = 1;
    pixPlot;
    pixPlotWeight;
    
    figLabel = 'flicker';
    npanel = 1; nrow = 1; ncol = 1; offset = 16;
    gratingTitle=0;
    pixPlot;
    pixPlotWeight;
    
end

for i = 1:nstim;
    meanResp(i) = nanmean(nanmedian(weightTcourse(8:25,stimOrder==i),2),1);
end


if nstim==29 %%% gratings 1 tf; either 4sfx4orient, or 2sf x 8 orient
    range = [-0.05 0.2]; %%% colormap range
    loc = [1 5 9 13 17 21 25 2 6 10 14 18 22 26 3 7 11 15 19 23 27 4 8 12 16 20 24 28]; %%% map stim order onto subplot
    figLabel = 'gratings';
    npanel = 28; nrow = 7; ncol = 4; offset = 0;
    gratingTitle = 1;
    pixPlot;
    pixPlotWeight;
    
    figLabel = 'flicker';
    npanel = 1; nrow = 1; ncol = 1; offset = 28;
    gratingTitle=0;
    pixPlot;
    pixPlotWeight;
    
    %%% plot tuning curve
    for i = 1:7;
        tuning(i+1)= nanmean(meanResp(i+0:7:21));
    end
    tuning(1) = meanResp(29);
    figure
    plot(tuning);
    xlabel('SF');
    ylabel('mean dF/F');
    ylim([0 0.05])
    title('weighted mean response');
    set(gca,'Xtick',1:8);
    set(gca,'Xticklabel',{'0', '0.01','0.02','0.04','0.08','0.16','0.32','0.64'})
    
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    
end

if nstim==48 %%% 4x6 spots
    range = [-0.05 0.2];
    loc = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24]; %%% map stim order onto subplot
    
    figLabel = 'OFF spots';
    npanel = 24; nrow = 4; ncol = 6; offset = 0;
    pixPlot;
    pixPlotWeight;
    
    figLabel = 'ON spots';
    npanel = 24; nrow = 4; ncol = 6; offset = 24;
    pixPlot;
    pixPlotWeight;
    
    octoRetinotopy;
    
    for rep=1:2
        figure
        subplot(2,2,1); imshow(meanGreenImg);
        subplot(2,2,2); imshow(topoOverlayImg{rep});
        subplot(2,2,3); imshow(xpolarImg{rep});
        subplot(2,2,4); imshow(ypolarImg{rep});
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    end
    
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
    
    octoRetinotopy;
    
    for rep=1:2
        figure
        subplot(2,2,1); imshow(meanGreenImg);
        subplot(2,2,2); imshow(topoOverlayImg{rep});
        subplot(2,2,3); imshow(xpolarImg{rep});
        subplot(2,2,4); imshow(ypolarImg{rep});
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
    end
    
    
end

display('saving pdf')
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

display('saving data')
outfile = newpdfFile(1:end-4);
save(outfile, 'trialmean', 'trialTcourse', 'stimOrder', 'c', 'dFrepeats','xpts','ypts','stdImg','cycPolarImg','cycImg','meanGreenImg','weightTcourse')
if exist('freq','var')
    save(outfile,'freq','orient','-append');
end

if nstim==48 | nstim==50  %%% spots
    save(outfile,'topoOverlayImg','xpolarImg','ypolarImg','xphase','yphase','-append')
end
if nstim ==13 %%% gratings
    save(outfile,'overlayImg','hvImg','-append');
end

psfile
%
% if Opt.SaveOutput
%     Output.R = Rigid;
%     Output.NR = Rotation;
%     Output.dfof = dfofInterp;
%     Output.dF = dF;
%     varargout{1} = Output;
% end
%close all

end