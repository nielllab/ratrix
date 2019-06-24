function varargout = sutterOctoSTA(varargin)
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
buffer(:,1) = max(mv,[],1)/cfg.spatialBin+1; buffer(buffer<1)=1;
buffer(:,2) = max(-mv,[],1)/cfg.spatialBin+1; buffer(buffer<0)=0;
buffer=round(buffer)
buffer(2,:) = buffer(2,:)+32 %%% to account for deadbands;

dfofInterp= dfofInterp(buffer(1,1):(end-buffer(1,2)),buffer(2,1):(end-buffer(2,2)),:);


% number of frames per cycle
cycLength = median(diff(vidframetimes))/dt;
% number of frames in window around each cycle. min of 4 secs, or actual cycle length + 2
cycWindow = round(max(2/dt,cycLength));

stimTimes = vidframetimes;   %%% we call them phasetimes in behavior, but better to call it stimTimes here
startFrame = round((stimTimes(1)-1)/dt);
dfofInterp = dfofInterp(:,:,startFrame:end);   %%% movie starts 1 sec before first stim
stimTimes = stimTimes-stimTimes(1)+1;
stimFrames = round(stimTimes/dt);

figure
plot(diff(stimTimes)); title('diff of vidframetimes in 2p');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%%


%% calculate two reference images for choosing points on ...
%%% absolute green fluorescence, and max df/f of each pixel
greenFig = figure;

stdImg = imresize(greenframe,1/cfg.spatialBin);
stdImg= stdImg(buffer(1,1):(end-buffer(1,2)),buffer(2,1):(end-buffer(2,2)),:);
greenCrop = double(stdImg);
imagesc(stdImg,[prctile(stdImg(:),1) prctile(stdImg(:),99)*1.2]); hold on; axis equal; colormap gray;
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




%%%
%figure
load('C:\data\octo_sparse_flash_10min.mat')

for rep =1:4 %%% 4 conditions: On, Off, fullfield On, fullfield off
    
    %%% select movie aspects to analyze
    m = (double(moviedata)-127)/128;
    if rep ==1 | rep ==3 %%% ON
        m(m<0)=0;
    elseif rep ==2 | rep==4; %%% OFF
        m(m>0)=0;
    end
    
    if rep==1 | rep ==2  %%% spots (remove fullfield)
        m(sz_mov==255)=0;     m= imresize(m,0.5,'box');
    elseif rep ==3 | rep==4  %%% fullfield
        m(sz_mov~=255)=0; m = m(1,1,:); %%% only need one pixel
    end
    
    %%% calculate timecourse for entire image
    dFclip = dfofInterp;  dFclip(dFclip>1)=1;   %%% get rid of extreme dF values (mostly from outside tissue)
    dF = squeeze(mean(mean(dFclip,2),1));
    framerange = 0:cycWindow;
    baserange=0:2;
    for i = 1:length(stimTimes)-2;
        dFalign(i,:) = dF(stimFrames(i) +framerange)- mean(dF(stimFrames(i)+baserange));
    end
    
    sta=0;
    
    figure; set(gcf,'Name',sprintf('rep %d timecourse',rep));
    range = -2:2
    for tau = 3:18;
        resp = mean(dFalign(:,tau+range),2);
        %resp = resp-mean(resp);
        sta =0;
       npts = min(length(resp),size(moviedata,3));
       for i = 1:min(length(resp),size(moviedata,3));
            sta = sta+resp(i)*m(:,:,i);
        end
        sta = sta/sum(abs(resp(1:npts)));
        stas(:,:,tau)=sta;
        %sta = sta/sum(resp);
        subplot(4,5,tau);
        imagesc(sta',[-0.1 0.1]);colormap jet; axis equal;title(sprintf('lag %d',tau));
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    %%% calculate STA at peak time (tau) at gridpoints on 2p image
    tau = 8;
    
    blocksize=25
    xrange = 1:blocksize:size(dfofInterp,1); xrange = xrange(1:end-1); %%% last one will be off the edge
    yrange = 1:blocksize:size(dfofInterp,2);  yrange = yrange(1:end-1);
    pnum=0; % index for plots
    figure; set(gcf,'Name',sprintf('rep %d map',rep));
    for nx = 1:length(xrange);
        for ny = 1:length(yrange)
            sprintf('%d %d',nx,ny)
            pnum=pnum+1;
            
            range = 0:(blocksize-1);
            dF = squeeze(mean(mean(dfofInterp(xrange(nx)+range,yrange(ny)+range,:),2),1));
            
            framerange = 0:cycWindow;
            baserange=0:2;
            for i = 1:length(stimTimes)-2;
                dFalign(i,:) = dF(stimFrames(i) +framerange)- mean(dF(stimFrames(i)+baserange));
            end
            
            range = -2:2;
            resp = mean(dFalign(:,tau+range),2);
            sta =0;
            npts = min(length(resp),size(moviedata,3));
            for i = 1:npts;
                sta = sta+resp(i)*m(:,:,i);
            end
            sta = sta/(sum(abs(resp(1:npts)))); %%% normalize sta by total amount of neural activity (like dividing by # of spikes in standard STA)
            subplot(length(xrange),length(yrange),pnum);

            imagesc(sta',[-0.1 0.1]); colormap jet;  set(gca,'Visible','off');
            set(gca,'LooseInset',get(gca,'TightInset'));
            
            staAll(:,:,nx,ny,rep) = sta';
        end
    end

    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    drawnow
end


pnum=0;
figure
for nx = 1:length(xrange);
    for ny = 1:length(yrange)
        pnum =pnum+1;
        subplot(length(xrange),length(yrange),pnum);
        im = zeros(size(staAll,1),size(staAll,2),3);
        im(:,:,1) = staAll(:,:,nx,ny,1)/0.1;
        im(:,:,2) = -staAll(:,:,nx,ny,2)/0.1;
        im(:,:,3) = staAll(:,:,nx,ny,1)/0.1; % magenta
        imshow(imresize(im,0.5));
        set(gca,'LooseInset',get(gca,'TightInset'))
        drawnow
    end
end

    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% time to select points! either by hand or automatic
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

framerange = 8:12
baserange=0:2;
clear dFclust
for i = 1:length(stimTimes)-2;
    dFclust(:,i) = mean(dF(:,stimFrames(i) +framerange),2)- mean(dF(:,stimFrames(i)+baserange),2);
end


figure
imagesc(dF);
figure
imagesc(dFclust);


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
imagesc(dFclust(perm,:),[-0.1 0.4]); axis xy ; xlabel('selected traces based on dF'); colormap jet ;   %%% show sorted data
hold on;

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
m= (double(moviedata)-127)/128;
%m(m<0)=0;
framerange = 0:cycWindow;
baserange=0:2;

for clust = 1:nclust
    clustfig = figure;
    
    
        %%% spatial location of cells in this cluster
    figure(clustfig)
    subplot(2,3,1);
    imagesc(stdImg,[0 prctile(stdImg(:),99)*1.2]); axis equal; hold on;colormap gray;freezeColors;
    title(sprintf('cluster %d',clust));
    plot(x(c==clust),y(c==clust),'go')%%'Color',colors(c));
    
    for i = 1:length(stimTimes)-2;
        dFalign(i,:) = mean(dF(c==clust,stimFrames(i) +framerange),1)- mean(mean(dF(c==clust,stimFrames(i)+baserange),2),1);
    end
    
    
    sta=0; clear stas
    
    for rep = 1:2
       m= (double(moviedata)-127)/128;
 if rep==1
       m(m<0)=0;   
 else
     m(m>0)=0;
 end
    
    figure;
    range = -1:1
    for tau = 3:18;
        resp = mean(dFalign(:,tau+range),2);
        %resp(resp<0)=0;
        %resp = resp-mean(resp);
        sta =0;
        npts = min(length(resp),size(moviedata,3));
        for i = 1:npts;
            sta = sta+resp(i)*m(:,:,i);
        end
        sta = sta/sum(abs(resp(1:npts)));
        stas(:,:,tau)=sta;
        %sta = sta/sum(resp);
        subplot(4,5,tau);
        imagesc(sta',[-0.2 0.2]);colormap jet; axis equal;title(sprintf('lag %d',tau));
    end
        title(sprintf('clust %d rep %d',clust,rep));
    tau = 8;
    
    sta = stas(:,:,tau);
    figure(clustfig)
    
    subplot(2,3,1+rep);
    imagesc(sta',[-0.2 0.2]); hold on; axis equal; colormap jet;
    xprofile = max(abs(sta),[],1); [mx xmax] = max(xprofile);
    yprofile = max(abs(sta),[],2); [mx ymax] = max(yprofile);
    xmax
    ymax
    plot(ymax,xmax,'ko');
    
    sz=[2 4 8 255]; col = 'bcrg'
    figure
    eps = find(m(ymax,xmax,:)~=0);
    eps = eps(eps<=size(dFalign,1));
    
    plot(dFalign(eps,:)')
    hold on
    for i = 1:4
        eps = find(m(ymax,xmax,:)~=0 & sz_mov(ymax,xmax,:)==sz(i));
        eps = eps(eps<=size(dFalign,1));
        plot(mean(dFalign(eps,:),1),col(i),'Linewidth',2);
        
    end
    title(sprintf('cluster %d rep %d',clust,rep));

    %%% mean traces
    figure(clustfig)
    subplot(2,3,4+rep);
    hold on
    %%% mean traces
    for i = 1:4
        eps = find(m(ymax,xmax,:)~=0 & sz_mov(ymax,xmax,:)==sz(i));
         eps = eps(eps<=size(dFalign,1));
        plot(mean(dFalign(eps,:),1),col(i),'Linewidth',2);
    end
     if rep==2
        legend('2','4','8','full')
    end
    ylim([-0.05 0.2]); xlim([1 20])
   
    end
    
    %%% heatmap average timecourse
    subplot(2,3,4);
    imagesc(dFclust(c==clust,:),[-0.1 0.4]); axis xy % was df
    title(sprintf('clust %d',clust)); hold on

    figure(clustfig)
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
   
end %end of for clust



%%% correlation map (shows how good the clustering is
figure
imagesc(corrcoef(dFclust(perm,:)'),[-1 1]); colormap jet
title('correlation across cells after clustering')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


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
%save(outfile, 'trialmean', 'trialTcourse', 'stimOrder', 'c', 'dFrepeats','xpts','ypts','stdImg','cycPolarImg','cycImg','meanGreenImg')


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