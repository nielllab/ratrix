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
    %%% manually select points? 0 = auto, 1 = manual, 2= suite2p
    %Opt.selectPts=0;
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

if isfield(Opt,'cellrange')
    pts_range = Opt.cellrange;
else
    pts_range = -2:2; %%% was -2:2 before 011123
end

%%% frame rate for resampling
% dt = 0.5;
% framerate=1/dt;

if Opt.SaveFigs
    psfile = Opt.psfile;
    if exist(psfile,'file')==2;delete(psfile);end
end
dt = Opt.Resample_dt;
cfg.dt = dt; cfg.spatialBin=2; cfg.temporalBin=1;  %%% configuration parameters eff
cfg.syncToVid=0; cfg.saveDF=0;

sessionName=0; %%% don't save session data itself
if isfield(Opt,'fSbx')
    fileName = fullfile(Opt.pSbx,Opt.fSbx);
end

%%% script extracted from old Sutter analysis that should read in scanimage
%%% tiffs and ttl data
%%% this will be the key point to check for compatibility!
getSutterData

global info
mv = info.aligned.T;


if ~isfield(Opt,'sub_noise')
    Opt.sub_noise = input('subtract noise from sidebands? 0/1 ');
end

if Opt.sub_noise==1
    [dfofInterp meanImg greenframe] = subtractSidebandNoise(dfofInterp,meanImg, psfile,mv);
end


if isfield(Opt,'zbinning')
    zbin = Opt.zbinning;
else
    zbin = input('do zbinning? 0/1 : ');
end

if zbin
    [dfofInterp meanImg greenframe] = zbinCorr(dfofInterp, meanImg, greenframe, Opt,psfile);
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
startTrim = startFrame;  %%% need this to trim suite2p data
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
load(fullfile(Opt.pStim,Opt.fStim),'stimRec','freq','orient', 'contrast','positionX','StimulusStr','StimulusNum','TempFreq');
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
getOctoCells

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
dFrepsAll = zeros(size(dF,1),cycWindow,nstim,max(nStimRep))+NaN;
for i = 1:nstim
    repList = find(stimOrder==i);
    for r = 1:nStimRep(i)
        startFrame = stimTimes(repList(r))/dt;
        dFrepeats(:,(i-1)*cycWindow + (1:cycWindow),r) = dF(:,round(startFrame+(1:cycWindow))) - repmat(dF(:,round(startFrame+1)),[1 floor(cycWindow)]);
        dFrepsAll(:,:,i,r) =  dF(:,round(startFrame+(1:cycWindow))) - repmat(nanmedian(dF(:,round(startFrame+(1:5))),2),[1 floor(cycWindow)]); %% update to average over baseline
        %dFrepeats(:,(i-1)*cycWindow + (1:cycWindow),r) = dF(:,round((repList(r)-1)*cycLength)+(1:cycWindow)) - repmat(dF(:,round((repList(r)-1)*cycLength)+1),[1 floor(cycWindow)]);
        
    end
end
dFrepeats(dFrepeats>1) =1; %%% clip major outliers
dFrepeats(dFrepeats<-1) = -1;
dFrepsAll(dFrepsAll>1) = 1;
dFrepsAll(dFrepsAll<-1) = -1;

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
%%%startFrames = round(stimTimes/dt)-5;  % tried shortening 10-frame buffer on 072324
%
% %%% misc analysis - movement relative to start times
% for i = 3:length(startFrames)-3
%     mv_x(i,:) = mv(startFrames(i)-5:startFrames(i)+15,1)- mv(startFrames(i),1);
%     mv_y(i,:) = mv(startFrames(i)-5:startFrames(i)+15,2) - mv(startFrames(i),2);
% end
%
% figure
% imagesc(mv_x)
% title('x movements')
% figure
% plot(mean(abs(mv_x),1))
% title('mean x movements')

%%% calculate cycle averages (timecourse for each individual stim)
clear cycAvgAll cycAvg cycImg
for i=1:cycWindow;
    cycAvgAll(:,i) = nanmean(dF(:,startFrames+i),2); %%% cell-wise average across all stim
    cycAvg(i) = mean(mean(nanmean(dfofInterp(:,:,startFrames+i),3),2),1); %%% average for all cells and stim
    cycImg(:,:,i) = nanmean(dfofInterp(:,:,startFrames+i),3); %%% pixelwise average across all stim
    
end

%%% plot pixel-wise cycle average
figure
for i = 1:min(cycLength,60)
    if cycLength<=30
        subplot(5,6,i);
    else
        subplot(8,8,i)
    end
    % imagesc(cycImg(:,:,i)-min(cycImg,[],3),[0 0.1]); axis equal
    data = cycImg(:,:,i)-mean(cycImg(:,:,1),3);
    datafilt = imfilter(data,fspecial('gaussian',[10 10],2));
    imagesc(datafilt,[0 0.1]); axis equal; axis off
end
colorbar
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% plot weighted pixel-wise cycle average
figure
for i = 1:min(cycLength,60)
    if cycLength<=30
        subplot(5,6,i);
    else
        subplot(8,8,i)
    end
    % imagesc(cycImg(:,:,i)-min(cycImg,[],3),[0 0.1]); axis equal
    data = cycImg(:,:,i)-mean(cycImg(:,:,1),3);
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

%%% select clusters
done = 0;ncAll = nclust;
while ~done
  c = cluster(Z,'maxclust',ncAll);
   clear nc
   for i = 1:ncAll;
      nc(i) = sum(c==i);
   end
  nc
  newc = c;
  if sum(nc>5)>=nclust | ncAll>20
      done=1;
      goodclust=find(nc>5);
      for i = 1:length(goodclust)
          newc(c==goodclust(i))=i;
      end
      badclust = find(nc<=5);
      if ~isempty(badclust)         
          for i = 1:length(badclust)
              newc(c==badclust(i))=nclust+1;
          end
          nclust = nclust+1;
      end
      c = newc; 
  else
      ncAll=ncAll+1
  end
end


%c = cluster(Z,'maxclust',nclust);
colors = hsv(nclust+1); %%% color code for each cluster

%%% plot spatial location of cells in each cluster
figure
imagesc(stdImg,[0 prctile(stdImg(:),95)]); colormap gray; axis equal;hold on
for clust=1:nclust
    plot(x(c==clust),y(c==clust),'o','Color',colors(clust,:));
end
title(sprintf('%u Clusters',nclust));
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

cols = hsv(nclust);
    
if selectPts==2;
    % img = zeros(size(ops.max_proj,1),size(ops.max_proj,2),3);
    img = imresize(meanGreenImg,2);
    for j = 1:length(c)
        xpix = stat{j}.xpix;
        ypix = stat{j}.ypix;
        lam = stat{j}.lam;
        for i = 1:length(xpix);
            img(ypix(i),xpix(i),:) = cols(c(j),:)*lam(i)/max(lam);
        end
    end
    figure
    imshow(img); title('cluster')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end  
end

%%% plot dF/F traces for random subediset
np = 5;
for clust = 1:nclust
    cells = find(c== clust);
    cell_list((1:np) + (clust-1)*np) = cells(ceil(rand(np,1)*length(cells)));
    color_list((1:np) + (clust-1)*np,:)= repmat(cols(clust,:),[np 1]);
end

figure
hold on
range = 1:min(3000,length(dF));
dtr= 0.1;
for i = 1:length(cell_list);
    plot(range*dtr - 50,medfilt1(3*dF(cell_list(i),range),5)+(length(cell_list)+1) - i,'Color',0.9*color_list(i,:));
end
ylim([0 np*nclust+2]); xlim([0 180]); xticks(0:60:180);
xlabel('secs'); ylabel('cell #');  title('dF/F')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end



if selectPts==2 & nstim ==17;  % some grating analysis
    
    dFrepsMn = nanmedian(dFrepsAll,4);
    dFrepsTuning = squeeze(nanmean(dFrepsMn(:,10:20,:),2));
    vert = nanmean(dFrepsTuning(:,[5 7 9]),2);
    horiz = nanmean(dFrepsTuning(:,[13 15]),2);
    ds = (horiz - vert)./(horiz + vert);
    ds(ds<-1)=NaN;
    ds(ds>1) = NaN;
    figure
    hist(ds(c==2),-1:0.1:1);
    img = zeros(size(ops.max_proj,1),size(ops.max_proj,2),3);
    for j = 1:length(c)
        xpix = stat{j}.xpix;
        ypix = stat{j}.ypix;
        lam = stat{j}.lam;
        onresp = dFrepsTuning(j,1:2:15);
        amp(j) = max(onresp);
        onresp = onresp - min([0 onresp]);
        cv(j) = sum(onresp.*exp((1:8)*pi/4 * sqrt(-1)))/sum(onresp);
        mag(j) = (abs(cv(j))-0.3)*3;  mag(mag>1) = 1;mag(mag<0) = 0;
        ph(j) = angle(cv(j))/(2*pi);
        %cm = interp1(-1:0.01:0.99,cbrewer('div','PiYG',200),ds(j));
        cm = interp1(0:0.01:0.99,jet(100),mag(j));
        cm = interp1(-0.5:0.01:0.49,hsv(100),ph(j));
        cm = cm *mag(j) + [1 1 1]*(1-mag(j));
        for i = 1:length(xpix);
            img(ypix(i),xpix(i),:) = cm*lam(i)/max(lam);
        end
    end
    figure
    imshow(img); title('cluster')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end

if nstim ==48
    %plot timecourse by cluster with orientation
    loc = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24];
    for rep = 0:1
        figure
        set(gcf,'defaultAxesColorOrder',jet(size(dFrepsAll,4)));
        for cond=1:24
            subplot(4,6,loc(cond))
            plot(squeeze(nanmean(dFrepsAll(:,:,cond + rep*24,:),1)));
            % title(sprintf('c %0.1f loc %i dir %i',contrast(cond*2-rep),positionX(cond*2-rep),orient(cond*2-rep)));
            ylim([-0.05 0.25]);
        end
        title('all units')
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    end
end

    
    

%%% summary plots for each cluster
for clust = 1:nclust
    
    %%% spatial location of cells in this cluster
    figure
    
    subplot(2,2,1);
    imagesc(stdImg,[0 prctile(stdImg(:),99)*1.2]); axis equal; hold on;colormap gray;freezeColors;
    title(sprintf('cluster %d',clust));
    plot(x(c==clust),y(c==clust),'o','Color',cols(clust,:))%%'Color',colors(c));
    
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
    
    if nstim==16
        loc = [2 3 6 9 8 7 4 1]
        for rep = 1:-1:0
            figure
            set(gcf,'defaultAxesColorOrder',jet(size(dFrepsAll,4)));
            for cond=1:8
                subplot(3,3,loc(cond))
                plot(squeeze(nanmean(dFrepsAll(c==clust,:,cond*2-rep,:),1)));
                ylim([-0.05 0.2]); title(sprintf('c %0.2f th %d',contrast(cond*2-rep),orient(cond*2-rep)))
            end
            subplot(3,3,5);  title(sprintf('clust %d',clust))
            if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        end
    end
    
    if nstim ==17
        %plot timecourse by cluster with orientation
        tuning(clust,:) = median(nanmean(dFrepsAll(c==clust,5:15,:,:),[2 4]),1);  %%% use median over trials
        
        % loc = [1 2 3 6 9 8 7 4]; %%% offsets by 4deg
        loc = [ 3 2 1 4 7 8 9 6]
        r = 1:size(dFrepsAll,2);
        for rep = 1:-1:0
            figure
             set(gcf,'defaultAxesColorOrder',jet(size(dFrepsAll,4)));
            for cond=1:8
                subplot(3,3,loc(cond))
               % plot((0:(length(r)-1))*dt,squeeze(nanmean(dFrepsAll(c==clust,r,cond*2-rep,:),1)),'Color',0.9*cols(clust,:));
                plot((0:(length(r)-1))*dt, squeeze(nanmean(dFrepsAll(c==clust,r,cond*2-rep,:),1))); %% heatmap temporal order
                ylim([-0.05 0.25]);%title(sprintf('sf %0.2f th %d',freq(cond*2-rep),orient(cond*2-rep)))
                % xlabel('secs'); ylabel('dF/F')
            end
            subplot(3,3,8); xlabel('secs'); subplot(3,3,4); ylabel('dF/F');
            subplot(3,3,5)
            %plot(squeeze(nanmean(dFrepsAll(c==clust,:,17,:),1)));
            %ylim([-0.05 0.25]); title('flicker')
            ths = (45:45:405)*pi/180;
            polarplot(ths,tuning(clust,([2:2:16 2]) - rep),'Color',0.9*cols(clust,:) );% axis off
            ax = gca; ax.RLim = [0 0.12]; ax.ThetaTick = 0:45:315; ax.RTick = []; %ax.TightInset = 1;%ax.ThetaTickLabel = {}; %ax.RTickLabel = {};
            if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        end
        
    end  % end of nstim == 17
    
    if nstim ==32 && StimulusNum ==2
        %plot timecourse by cluster with orientation
        loc = [1 9 8 16 2 10 7 15 3 11 6 14 4 12 5 13]
        for rep = 1:-1:0
            figure
            set(gcf,'defaultAxesColorOrder',jet(size(dFrepsAll,4)));
            for cond=1:16
                subplot(4,4,loc(cond))
                plot(squeeze(nanmean(dFrepsAll(c==clust,:,cond*2-rep,:),1)));
                title(sprintf('c %0.1f loc %i dir %i',contrast(cond*2-rep),positionX(cond*2-rep),orient(cond*2-rep)));
                ylim([-0.05 0.25]);
            end
            if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        end
        
    end  % end of nstim == 32
    
    
    
    if nstim ==24 & StimulusNum==1% 4ori 2sf 3tf
        %plot timecourse by cluster per condition
        
        
        figure
        set(gcf,'defaultAxesColorOrder',jet(size(dFrepsAll,4)));
        for cond=1:24
            subplot(4,6,cond)
            plot(squeeze(nanmean(dFrepsAll(c==clust,:,cond,:),1)));
            % title(sprintf('c %0.1f loc %i dir %i',contrast(cond*2-rep),positionX(cond*2-rep),orient(cond*2-rep)));
            ylim([-0.025 0.1]);
            title(sprintf('%d %0.2f %d', orient(cond),freq(cond),TempFreq(cond)))
        end
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
           figure
        
        for cond=1:24
            subplot(4,6,cond)
            plot(squeeze(nanmean(dFrepsAll(c==clust,:,cond,:),[1 4])));
            % title(sprintf('c %0.1f loc %i dir %i',contrast(cond*2-rep),positionX(cond*2-rep),orient(cond*2-rep)));
            ylim([-0.025 0.1]);
            title(sprintf('%d %0.2f %d', orient(cond),freq(cond),TempFreq(cond)))
        end
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
   
    
    end
    
        if nstim ==48
        %plot timecourse by cluster with orientation
        loc = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24];
        for rep = 0:1
            figure
            set(gcf,'defaultAxesColorOrder',jet(size(dFrepsAll,4)));
            for cond=1:24
                subplot(4,6,loc(cond))
                plot(squeeze(nanmean(dFrepsAll(c==clust,:,cond + rep*24,:),1)));
               % title(sprintf('c %0.1f loc %i dir %i',contrast(cond*2-rep),positionX(cond*2-rep),orient(cond*2-rep)));
                ylim([-0.05 0.25]);
            end
            if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        end
        
    end  
    
    
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
title('correlation across cells after clustering'); colorbar
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

figure
hist(max(dFclust,[],2))
%%% calculate pixel-wise maps of activity for different stim

display('doing pixel plots')

gratingTitle=0; %%% titles for grating figs?
evRange = 10:20; baseRange = 1:5; %%% timepoints for evoked and baseline activity
tcRange = 30; %original value
tcRange = cycWindow+5; %updated 012224
tcRange = max(30,tcRange);
evRange = 6:tcRange; baseRange = 1:5; %%% timepoints for evoked and baseline activity


if cycWindow>50
    evRange = 10:50;
    tcRange = cycWindow+10;
end

dfofInterp(dfofInterp>1) = 1; dfofInterp(dfofInterp<-1) = -1;
dfInterpsm = imresize(dfofInterp,0.25);
dfWeight = dfInterpsm.* repmat(imresize(normgreen(:,:,1),0.25),[1 1 size(dfofInterp,3)]);
for i = 1:length(stimOrder); %%% get pixel-wise evoked activity on each individual stim presentation
    startFrame = (stimTimes(i)-0.5)/dt;
    trialmean(:,:,i) = nanmean(dfofInterp(:,:,round(startFrame + evRange)),3)- nanmean(dfofInterp(:,:,round(startFrame + baseRange)),3);
    trialTcourse(:,i) = squeeze(mean(mean(dfofInterp(:,:,round(startFrame + (1:tcRange))),2),1)) - mean(mean(dfofInterp(:,:,round(startFrame + 1)),2),1) ;
    weightTcourse(:,i) = (squeeze(mean(mean(dfWeight(:,:,round(startFrame + (1:tcRange))),2),1)) - mean(mean(mean(dfWeight(:,:,round(startFrame + baseRange)),3),2),1))/mean(normgreen(:)) ;
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


if nstim==16 & StimulusNum ==2  %%% 16 cond bars (2 contrast 8 directions)
    range = [-0.05 0.2]; %%% colormap range
    %   loc = [2 3 6 9 8 7 4 1]; %%% map stim order onto subplot
    %     figLabel = 'OFF bars';
    %     npanel = 8; nrow = 3; ncol = 3; offset = 0;
    %     gratingTitle = 1;
    %     pixPlot;
    %     pixPlotWeight;
    %
    %     figLabel = 'ON bars';
    %     npanel = 8; nrow = 3; ncol = 3; offset = 8;
    %     gratingTitle=0;
    %     pixPlot;
    %     pixPlotWeight;
    figLabel = 'bars'
    loc = [1 9 2 10 3 11 4 12 5 13 6 14 7 15 8 16];
    npanel = 16; nrow = 4; ncol = 4; offset = 0;
    gratingTitle=0;
    for i = 1:16; titles{i} = sprintf('c %0.1f th %d',contrast(i),orient(i)); end
    pixPlot;
    pixPlotWeight;
    
    off_mn = nanmean(trialmean(:,:,contrast(stimOrder)==-1),3);
    figure
    imagesc(off_mn,[-0.01 0.1]); title('OFF mean'); colormap jet; colorbar
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    on_mn = nanmean(trialmean(:,:,contrast(stimOrder)==1),3);
    figure
    imagesc(on_mn,[-0.01 0.1]); title('ON mean'); colormap jet; colorbar
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    vert_mn = nanmean(trialmean(:,:,(orient(stimOrder)==0 | orient(stimOrder)==180) &contrast(stimOrder)==1),3);
    figure
    imagesc(vert_mn,[-0.01 0.1]); title('vertical mean'); colormap jet; colorbar
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    horiz_mn = nanmean(trialmean(:,:,orient(stimOrder)==90 | orient(stimOrder)==270 &contrast(stimOrder)==1),3);
    figure
    imagesc(horiz_mn,[-0.01 0.1]); title('horizontal mean'); colormap jet; colorbar
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure
    imagesc(horiz_mn - vert_mn,[-0.1 0.1]);title('horizontal minus vertical'); colormap jet; colorbar
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %tuning curves
    for cl = 1:nclust
        tuning(cl,:) = nanmean(dFrepsAll(c==cl,10:end,:,:),[1 2 4]); %%% use max over time range, median over trials
    end
    
    figure
    subplot(2,1,1)
    plot(0:45:315,tuning(:,1:2:16)); ylim([-0.025 0.1])
    title('off tuning by clusters'); xlabel('theta');
    subplot(2,1,2)
    plot(0:45:315,tuning(:,2:2:16)); ylim([-0.05 0.2])
    title('on tuning'); xlabel('theta')
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
if nstim==17 && length(unique(freq))==2  %%%% tuning maps for gratings, 2sfs
    sfs = unique(freq);
    freqs = [freq 0]; %%% add the flicker
    orients = [orient NaN];
    %%% calculate mean for each sf
    for i = 1:2
        meanimg(:,:,i) = nanmedian(trialmean(:,:,freqs(stimOrder)==sfs(i)),3);
        figure
        imagesc(meanimg(:,:,i),[-0.05 0.1]); colormap jet;
        title(sprintf('sf = %0.02f',sfs(i)));
    end
    
    %%% calculate sf preference index and map
    mn = mean(meanimg,3);
    sfpref = (meanimg(:,:,2) - meanimg(:,:,1))./(meanimg(:,:,2) + meanimg(:,:,1));
    %    figure
    %    imagesc(sfpref,[-1 1]); colormap jet
    sfpref(isnan(sfpref))=0;
    im = mat2im(sfpref,jet,[-0.5 0.5]);
    amp = mn/0.1; amp(amp<0) = 0; amp(amp>1) = 1;
    sf_img = im.*repmat(amp,[1 1 3]);
    sf_mean = meanimg;
    sf_amp = sf_mean/0.1; sf_mean(sf_mean<0)=0; sf_mean(sf_mean>1)=1;
    %%% sf pref map
    figure
    imshow(sf_img);
    title('sf pref: blue = 0.01 yellow = 0.16')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    maxamp = 0.1;
    flicker = nanmedian(trialmean(:,:,stimOrder==17),3);
    flicker_amp = flicker/maxamp; flicker_amp(flicker_amp<0)=0; flicker_amp(flicker_amp>1)=1;
    figure
    imagesc(flicker)
    im = mat2im(flicker,parula,[0 0.2]);
    flicker_img = im.*repmat(flicker_amp,[1 1 3]);
    figure
    imshow(flicker_img); colorbar; title('full-field flicker')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    %%% merge 2sf and flicker
    sf_flick = zeros(size(flicker_img));
    sf_flick(:,:,1) = flicker_amp;
    sf_mean_amp = sf_mean/maxamp; sf_mean_amp(sf_mean_amp<0)=0; sf_mean_amp(sf_mean_amp>1)=1;
    sf_flick(:,:,2:3) = sf_mean_amp;
    figure
    imshow(sf_flick); title(sprintf('red=full-field; green = 0.01cpd; blue=0.16; amp = %0.1f',maxamp));
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    %%% calculate orientation preference map
    vert = nanmedian(trialmean(:,:,orients(stimOrder)==0 | orients(stimOrder)==180),3);
    horiz = nanmedian(trialmean(:,:,orients(stimOrder)==90 | orients(stimOrder)==270),3);
    figure
    imagesc(vert,[-0.05 0.1]); colormap jet; title('vert'); colorbar
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure
    imagesc(horiz,[-0.05 0.1]); colormap jet; title('horiz'); colorbar
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    mn = 0.5*(vert+horiz);
    orientpref = (vert-horiz)./(vert+horiz);
    orientpref(isnan(orientpref))=0;
    %    figure
    %    imagesc(sfpref,[-1 1]); colormap jet
    im = mat2im(orientpref,jet,[-0.5 0.5]);
    amp = mn/0.1; amp(amp<0) = 0; amp(amp>1) = 1;
    orient_img = im.*repmat(amp,[1 1 3]);
    figure
    imshow(orient_img); title('orientation pref; blue = horiz, yellow = vert');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    for cl = 1:nclust
        figure
        for cond = 1:16
            subplot(4,4,cond);
            imagesc(squeeze(mean(dFrepsAll(c==cl,:,cond,:),1))',[-0.05 0.2]);
        end
    end
    
    %tuning curves
    for cl = 1:nclust
        tuning(cl,:) = median(nanmean(dFrepsAll(c==cl,10:20,:,:),[2 4]),1);  %%% use median over trials
    end
    
    figure
    subplot(2,1,1)
    plot(0:45:315,tuning(:,1:2:16)); ylim([-0.05 0.2])
    title('low sf tuning by clusters'); xlabel('theta');
    subplot(2,1,2)
    plot(0:45:315,tuning(:,2:2:16)); ylim([-0.05 0.2])
    title('high sf tuning'); xlabel('theta')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end

for i = 1:nstim;
    meanResp(i) = nanmean(nanmedian(weightTcourse(8:25,stimOrder==i),2),1);
end

if nstim==24 & StimulusNum==1
    loc = 1:24; figLabel = 'gratings';
    npanel = 24; nrow=4; ncol=6; offset =0;
    gratingTitle = 1;
    pixPlot;
    pixPlotWeight;
    for i= 1:24;
        subplot(4,6,i);
        title(sprintf('%d %0.2f %d',orient(i),freq(i),TempFreq(i)));
    end
    
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

if nstim ==32 & StimulusNum==2  %%% moving spots at 4 directions 4 locations
    range =[-0.05 0.2];
    loc = 1:32;
    loc(1:2:end) = 1:16; loc(2:2:end) = 17:32;
    figLabel = 'spots'; offset = 0;
    npanel = 32; ncol = 8; nrow = 4;
    pixPlot;
    pixPlotWeight;
    for i= 1:32;
        subplot(4,8,i);
        title(sprintf('c %0.1f loc %i dir %i',contrast(i),positionX(i),orient(i)));
    end
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

if nstim==24 & StimulusNum==7 %%% 4x6 spots, on only
    range = [-0.05 0.2];
    loc = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24]; %%% map stim order onto subplot
    
    figLabel = 'spots';
    npanel = 24; nrow = 4; ncol = 6; offset = 0;
    pixPlot;
    pixPlotWeight;
    
end

if nstim==10 %%% contrast gratings, one-time mistake
    range = [-0.05 0.2];
    loc = 1:10; %%% map stim order onto subplot
    
    figLabel = 'bars';
    npanel = 10; nrow =2; ncol = 5; offset = 0;
    pixPlot;
    pixPlotWeight;
    for i = 1:10;
        subplot(2,5,i);
        title(sprintf('c %0.2f ori %d',contrast(i), orient(i)))
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