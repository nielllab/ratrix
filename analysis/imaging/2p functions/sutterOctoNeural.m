%%% reads in sutter data, extracts cell traces, and aligns to stim
%%% optimized for octopus optic lobe with cal520 label

clear all
close all

%%% frame rate for resampling
% dt = 0.5;
% framerate=1/dt;

%%% option of one or two color data (sutter stores 2-color as interleaved frames)
%twocolor = input('how many colors? 1 / 2 : ')-1;
twocolor = 2;
%makeFigs = input('make pdf file 0 / 1 :');
makeFigs = 0;
if makeFigs
    psfile = 'c:\temp.ps';
    if exist(psfile,'file')==2;delete(psfile);end
end

%%  get sutter data 
% Following ~70 lines of code used to be contained within get2pSession.m script
% Get File Path for tiff Image
% [f, p] = uigetfile({'*.mat;*.tif'},'.mat or .tif file');
% cycLength = input('cycle length : ');

f = '6w_3x2blocks_random008.tif';
p = 'C:\Users\nlab\Documents\Wyrick\101617_Octopus_Cal520\';
cycLength = 5.033;

%Get Image acquisition frame rate
%resampleHZ = input('Resample framerate (enter 0 to keep acquisition framerate) : ');
resampleHZ = 0;
if resampleHZ == 0
    Img_Info = imfinfo(fullfile(p,f));
    eval(Img_Info(1).ImageDescription);
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
%     [ttlf, ttlp] = uigetfile('*.mat','ttl file');
    ttlf = '6w_3x2blocks_random009-20171016T162728.mat';
    ttlp = 'C:\Users\nlab\Documents\Wyrick\101617_Octopus_Cal520\';
    try
        [stimPulse, framePulse] = getTTL(fullfile(ttlp,ttlf));
        figure
        plot(diff(stimPulse)); title('stimPulse cycle time');hold on
        plot(1:length(stimPulse),ones(size(stimPulse))*cycLength); ylabel('secs');xlabel('stim #')
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

        startTime = round(stimPulse(1)/dt)-1;
    catch
        disp('couldnt read TTLs')
        stimPulse=[]; framePulse=[]; startTime = 1;
    end
    
    ttlFname = fullfile(ttlp,ttlf);

    %% Performs Image registration and resample at requested frame rate
    % returns dfofInterp(x,y,t) = timeseries at requested framerate, with pre-stim frames clipped off
    % greenframe = mean fluorescence image
    if twocolor
        [dfofInterp, dtRaw, redframe, greenframe, mv] = get2colordata(fullfile(p,f),dt,cycLength);
    else
        [dfofInterp, dtRaw, greenframe] = get2pdata(fullfile(p,f),dt,cycLength);
    end
    
    figure
    timecourse = squeeze(mean(mean(dfofInterp(:,:,1:end),2),1));
    plot(timecourse);
        
    hold on
    for st = 0:10
        plot(st*cycLength/dt+ [startTime startTime],[0.2 1],'g:')
    end
    
    sprintf('estimated start time %f',startTime)
    % startTime = input('start time : ');
    
    for st = 0:10
        plot(st*cycLength+ [startTime*dt startTime*dt],[0.2 1],'k:')
    end
    
    dfofInterp = dfofInterp(:,:,startTime:end);
end

%% crop to get rid of edges that have motion artifact
% dfofInterp = dfofInterp(49:end-32,37:end-36,:);

%%% get duration of each stim (called a cycle) in terms of frames, based on ttl interval
cycLength = mean(diff(stimPulse))/dt;
cycF = mean(diff(stimPulse))/dt;

nstim = input('num stim per repeat : '); %%% total number of stimuli in the set
totalframes = cycLength*nstim;
reps = floor(size(dfofInterp,3)/totalframes);  %%% number of times the whole stimulus set was repeated

%%% generate periodic map

map = 0;
for i= 1:size(dfofInterp,3)
    map = map+dfofInterp(:,:,i)*exp(2*pi*sqrt(-1)*i/cycLength);
end
map = map/size(dfofInterp,3); map(isnan(map))=0;
amp = abs(map);
prctile(amp(:),99)
amp=amp/prctile(amp(:),98); amp(amp>1)=1;
img = mat2im(mod(angle(map),2*pi),hsv,[pi/2  (2*pi -pi/4)]);
img = img.*repmat(amp,[1 1 3]);
mapimg = figure
figure
imshow(imresize(img,0.5))
colormap(hsv); colorbar
title(sprintf('fourier map at %d frame cycle',cycLength));


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
stdImg = greenframe(49:end-32,37:end-36);
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
    clear x y npts
    npts = input('how many points ? ');
    for i =1:npts
        figure(selectFig); hold on
        [x(i) y(i)] = ginput(1); x=round(x); y = round(y);
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
clear dFrepeats
for rep = 1:reps
    dFrepeats(:,:,rep) = dF(:,(1:totalframes) + round((rep-1)*totalframes));
end
dFrepeats(dFrepeats>2)=2;

%%% average across repetitions, and subtract the minimum value for each
%%% cell (to correct for baseline offsets)
dFmean = mean(dFrepeats,3);
dFmean = dFmean - repmat(min(dFmean,[],2),[1 size(dFmean,2)]);


%%% cluster responses from selected traces
%dist = pdist(dF,'correlation');  %%% sort based on whole timecourse 
dist = pdist(mean(dFrepeats,3),'correlation');  %%% sort based on average across repeats (averages away artifact on individual trials)
display('doing cluster')
tic, Z = linkage(dist,'ward'); toc
figure
subplot(3,4,[1 5 9 ])
display('doing dendrogram')
[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,3);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
imagesc(dFmean(perm,:),[0 0.4]); axis xy ; xlabel('selected traces based on dF'); colormap jet ;   %%% show sorted data
hold on;
totalT = size(dF,2);
ncyc = floor(totalT/cycLength);
for i = 1:ncyc
    plot([i*cycLength i*cycLength]+1.5,[1 length(perm)],'k');
end

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

%%% mean response of whole population, for each repetition
figure
plot((0:totalframes-1)/cycLength+1, squeeze(mean(dFrepeats,1)))
xlabel('stim #'); xlim([1 nstim+1])
title('mean trace for each repeat');
hold on; legend('1','2','3','4')
%plot((0:totalframes-1)/cycLength+1, squeeze(mean(mean(dFrepeats,3),1)),)
plot((0:totalframes-1)/cycLength +1, squeeze(mean(mean(dFrepeats,3),1)),'g','Linewidth',2)
for i = 1:nstim;
    plot([i i ],[0.3 0.6],'k:');
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% calculate cycle averages (timecourse for each individual stim)
clear cycAvgAll cycAvg cycImg
for i=1:cycLength;
    cycAvgAll(:,i) = mean(dF(:,i:cycLength:end),2); %%% cell-wise average across all stim
    cycAvg(i) = mean(mean(median(dfofInterp(:,:,i:cycLength:end),3),2),1); %%% average for all cells and stim
    cycImg(:,:,i) = mean(dfofInterp(:,:,i:cycLength:end),3); %%% pixelwise average across all stim
end

%%% plot pixel-wise cycle average
figure
for i = 1:cycLength
    subplot(2,5,i);
    imagesc(cycImg(:,:,i)-min(cycImg,[],3),[0 0.1])
end

%%% plot mean timecourse
cycAvgAll = cycAvgAll - repmat(cycAvgAll(:,end),[1 size(cycAvgAll,2)]);
figure
plot(cycAvg); title('cycle average'); xlabel('frames')

%%% summary plots for each cluster
for clust = 1:nclust
    
    %%% spatial location of cells in this cluster
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
    
    %%% timecourse of this cluster, for each repeat
    subplot(2,2,4);
    plot((0:totalframes-1)/cycLength + 1, squeeze(mean(dFrepeats(c==clust,:,:),1))); hold on
    plot((0:totalframes-1)/cycLength + 1, squeeze(mean(mean(dFrepeats(c==clust,:,:),3),1)),'g','LineWidth',2)
    xlabel('stim #'); xlim([1 nstim+1])
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
    plot((0:totalframes-1)/cycLength+1,mean(dFmean(c==clust,:,:),1),'Color',colors(clust,:));
end;
hold on
for i = 1:nstim;
    plot([i i ],[0.2 0.4],'k:');
end
title('mean resp for each cluster');xlabel('stim #'); xlim([1 nstim+1])
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% correlation map (shows how good the clustering is
figure
imagesc(corrcoef(dFmean(perm,:)'))
title('correlation across cells after clustering')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% calculate pixel-wise maps of activity for different stim

evRange = 4:6; baseRange = 1:2; %%% timepoints for evoked and baseline activity
figure
for i = 1:(nstim*reps); %%% get pixel-wise evoked activity on each individual stim presentation
    trialmean(:,:,i) = mean(dfofInterp(:,:,round(cycLength*(i-1) + evRange)),3)- mean(dfofInterp(:,:,round(cycLength*(i-1) + baseRange)),3);
end

%%% plot mean for each stim condition, with layout corresponding to the stim
if nstim==12 %%% spots
    loc = [1 4 2 5 3 6]; %%% map stim order onto subplot
    figure; set(gcf,'Name','OFF spots');
    for i = 1:6
        meanimg = median(trialmean(:,:,i:nstim:end),3);
        subplot(2,3,loc(i));
        imagesc(meanimg,[0 0.25]);
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','ON spots');
    for i = 7:12
        meanimg = median(trialmean(:,:,i:nstim:end),3);
        subplot(2,3,loc(i-6));
        imagesc(meanimg,[0 0.25]);
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end

range = [-0.05 0.25]; %%% colormap range
if nstim==14 %%% gratings
    loc = 1:6; %%% map stim order onto subplot
    figure; set(gcf,'Name','vert gratings');
    for i = 1:6
        meanimg = median(trialmean(:,:,i:nstim:end),3);
        subplot(2,3,loc(i));
        imagesc(meanimg,range);
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure;set(gcf,'Name','horiz gratings');
    for i = 7:12
        meanimg = median(trialmean(:,:,i:nstim:end),3);
        subplot(2,3,loc(i-6));
        imagesc(meanimg,range);
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure; set(gcf,'Name','flicker');
    for i = 13:14
        meanimg = median(trialmean(:,:,i:nstim:end),3);
        subplot(1,2,i-12);
        imagesc(meanimg,range); if i ==13; title('low tf flicker'); else title('high tf flicker'); end
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end

%%% save out pdf file!
if makeFigs
    [f p] = uiputfile('*.pdf','save pdf file');
    newpdfFile = fullfile(p,f)
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