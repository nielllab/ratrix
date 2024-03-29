function varargout = sutterOctoSTA(varargin)
%% reads in sutter data, extracts cell traces, and aligns to stim
% optimized for octopus optic lobe with cal520 label
% if sutterOctoNeural is called as a function
%%
% close all
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
    % Opt.mindF = 5000;
    %%% number of clusters from hierarchical analysis
    Opt.nclust = 5;
    
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
    pts_range = -3:3; %%% was -3:3 before 011123
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
[dfofInterp meanImg greenframe] = subtractSidebandNoise(dfofInterp,meanImg, psfile,mv);    
end

%%% do zbinning (always)
[dfofInterp meanImg greenframe] = zbinCorr(dfofInterp, meanImg, greenframe, Opt,psfile);

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

stimTimes = stimTimes(stimTimes<size(dfofInterp,3)*dt - 5);
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




%%% Judit took out to run through batch file without user input
figure
display('which movie file?')
if isfield(Opt,'noiseFile')
    movienum = Opt.noiseFile;
else
    display('1) octo_sparse_flash_10min')
    display('2) sparse_20min_1-8')
    movienum = input('1 or 2 : ');
end


if movienum==1
    load('C:\data\octo_sparse_flash_10min.mat')
    crange = [-0.1 0.1];
    tau = 9; tau_range = -4:4;
else
    load('C:\data\sparse_20min_1-8.mat');
    crange = [-0.05 0.05];
    tau = 7; tau_range = -3:3;
end

baserange=0:2;
%baserange =2;

%%% box size for 'cell body' points
%pts_range = -3:3; now set above

for rep =1:2 %%% 4 conditions: On, Off, fullfield On, fullfield off; currently skipping fullfield since it's not interesting
    
    STAfig = figure;
    STAfig.NextPlot = 'new';
    %%% select movie aspects to analyze
    m = (double(moviedata)-127)/128;
    if rep ==1 || rep ==3 %%% ON
        m(m<0)=0;
    elseif rep ==2 | rep==4; %%% OFF
        m(m>0)=0;
    end
    
    if rep==1 | rep ==2  %%% spots (remove fullfield)
        m(sz_mov==255)=0;    %%% keeps fullfield from overwhelming, but means timecourse of fullfield is broken
        m= imresize(m,0.5,'box');
    elseif rep ==3 | rep==4  %%% fullfield
        m(sz_mov~=255)=0; m = m(1,1,:); %%% only need one pixel
    end
    
    movie_mn = mean(m,3);
    %%% calculate timecourse for entire image
    dFclip = dfofInterp;  dFclip(dFclip>0.5)=0.5;  dFclip(dFclip<-0.5)=-0.5;  %%% get rid of extreme dF values (mostly from outside tissue)
    dF = squeeze(mean(mean(dFclip,2),1));
    framerange = 0:2*cycWindow;
    clear dFalign
    baserange=0:2;
    %baserange = [0 1];
    %   baserange = 2;
    for i = 1:length(stimTimes)-2;
        dFalign(i,:) = dF(stimFrames(i) +framerange)- nanmean(dF(stimFrames(i)+baserange));
    end
    
    figure
    plot(nanmean(dFalign,1));
    title('mean timecourse all pixels all stim')
    xlabel('frame'); ylabel('dfof')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    figure; set(gcf,'Name',sprintf('rep %d timecourse',rep));
    %range = -2:2;
    range = 0;
    
    clear stas
    for taus = 1:30;
        resp = nanmean(dFalign(:,taus+range),2);
        %resp = resp-nanmin(resp);
        %resp = resp-mean(resp);
        sta =0;
        npts = min(length(resp),size(moviedata,3));
        for i = 1:min(length(resp),size(moviedata,3));
            if ~isnan(resp(i))
                sta = sta+resp(i)*(m(:,:,i)-movie_mn);
            end
        end
        sta = sta/nansum(abs(resp(1:npts)));
        stas(:,:,taus)=sta;
        %sta = sta/sum(resp);
        subplot(5,6,taus);
        imagesc(sta',crange);colormap jet; axis equal; axis off
    end
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    %%% svd based RF estimate
%     rf_flat = reshape(stas,size(stas,1)*size(stas,2),size(stas,3));
% %     mnrf = nanmean(rf_flat,2);
% %     for i  =1:size(rf_flat,2)
% %      rf_flat(:,i) = rf_flat(:,i)-mnrf;
% %     end
%     
%         display('doing svd')
%     tic
%     [u s v ] =svd(rf_flat,'econ');
%     toc
%     t_course = v(:,1);
%     rf_est = reshape(u(:,1),size(stas,1),size(stas,2)) *s(1,1);
%     if sum(t_course)<0
%         t_course = -t_course;
%         rf_est = -rf_est;
%     end
%     
%     figure
%     subplot(2,2,1);
%     imagesc(rf_est'*max(t_course),2*crange); colormap jet
%     title('svd rf estimate')
%     subplot(2,2,2)
%     imagesc(nanmean(stas(:,:,tau+tau_range),3)',2*crange); colormap jet
%     title('rf estimate from peak')
%     subplot(2,2,3:4);
%     plot(t_course);
%     title('timecourse')
%     xlabel('frame')
%     if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
%     
    
    %%% calculate STA at peak time (tau) at gridpoints on 2p image
    
    blocksize=25
    xrange = 1:blocksize:size(dfofInterp,1); xrange = xrange(1:end-1); %%% last one will be off the edge
    yrange = 1:blocksize:size(dfofInterp,2);  yrange = yrange(1:end-1);
    clear dFalign tcourseAll
    %     pnum=0; % index for plots
    %     STAfig = figure; set(gcf,'Visible','off'); set(gcf,'Name',sprintf('rep %d map',rep));
    %     tcourseFig = figure;  set(gcf,'Visible','off');% tcourseFig.NextPlot = 'new'; %set(gcf,'Name',sprintf('rep %d timecourse',rep));
    %    %
    for nx = 1:length(xrange);
        for ny = 1:length(yrange)
            % sprintf('%d %d',nx,ny)
            %  pnum=pnum+1;
            
            range = 0:(blocksize-1);
            dF = squeeze(mean(mean(dfofInterp(xrange(nx)+range,yrange(ny)+range,:),2),1));
            
            framerange = 0:cycWindow;
            
            for i = 1:length(stimTimes)-4;
                dFalign(i,:) = dF(stimFrames(i) +framerange)- nanmean(dF(stimFrames(i)+baserange));
            end
            
            range = -2:2;
            resp = nanmean(dFalign(:,tau+tau_range),2);
            %resp(resp<0)=0;
            % resp = resp-nanmin(resp);
            sta =zeros(size(m,1),size(m,2));
            npts = min(length(resp),size(moviedata,3));
            for i = 1:npts;
                if ~isnan(resp(i))
                    sta = sta+resp(i)*(m(:,:,i)-movie_mn);
                end
            end
            sta = sta/(nansum(abs(resp(1:npts)))); %%% normalize sta by total amount of neural activity (like dividing by # of spikes in standard STA)
            staAll(:,:,nx,ny,rep) = sta';
            %             figure(STAfig)
            %             subplot(length(xrange),length(yrange),pnum,'Parent',STAfig);
            %             imagesc(imresize(sta',0.25),[-0.1 0.1]); colormap jet;  set(gca,'Visible','off');
            %             set(gca,'LooseInset',get(gca,'TightInset'));
            %
            xprofile = max(abs(sta),[],1); [mx xmax] = max(xprofile);
            yprofile = max(abs(sta),[],2); [mx ymax] = max(yprofile);
            
            if movienum==1
                sz=[2 4 8 255]; col = 'bcrg'; nt = 4;
            else
                sz=[0.8 2 4 8 255]; col = 'kbcrg'; nt = 5;
            end
            
            %%% mean traces
            %             figure(tcourseFig)
            %            subplot(length(xrange),length(yrange),pnum,'Parent',tcourseFig);
            %             hold on
            %             %%% mean traces
            for i = 1:length(sz)
                if i<length(sz)
                    eps = find(abs(m(ymax,xmax,:))>0.9 & sz_mov(ymax*2,xmax*2,:)==sz(i)); %%% because sz_mov is twice as large!
                else
                    eps = find(sz_mov(ymax*2,xmax*2,:)==sz(i)); %%% for fullfield (since these are excluded from m; note this will get both on/off
                end
                eps = eps(eps<=size(dFalign,1));
                % plot(nanmean(dFalign(eps,:),1),col(i),'Linewidth',2);
                %tcourseAll(i,:,nx,ny,rep) = nanmean(dFalign(eps,:),1);
                tcourseAll(i,:,nx,ny,rep) = nanmedian(dFalign(eps,:),1);
            end
            %             ylim([-0.025 0.1]); xlim([1 20]);  set(gca,'Xtick',[]); set(gca,'Ytick',[]);
            %             set(gca,'LooseInset',get(gca,'TightInset'));
            
        end
    end
    
    %%% plot STAs
    
    display('drawing STAs')
    tic
    figure; set(gcf,'Visible','on');
    pnum = 0;
    for nx = 1:length(xrange)
        nx
        for ny = 1:length(yrange)
            pnum = pnum+1;
            subplot(length(xrange),length(yrange),pnum);
            imagesc(imresize(staAll(:,:,nx,ny,rep),0.5),crange); colormap jet;  set(gca,'Visible','off');
            set(gca,'LooseInset',get(gca,'TightInset'));
        end
    end
    toc
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    figure
    imagesc(staAll(:,:,6,6,rep),crange); title('sta at 6,6'); colorbar
    
    %%% plot timecourse
    display('drawing timecourses')
    tic
    figure; set(gcf,'Visible','on');
    pnum = 0;
    for nx = 1:length(xrange)
        nx
        for ny = 1:length(yrange)
            pnum = pnum+1;
            subplot(length(xrange),length(yrange),pnum);
            if rep<3
                for i = 1:nt-1  %%% skip fullfield
                    hold on
                    plot(squeeze(tcourseAll(i,:,nx,ny,rep)),col(i),'LineWidth',2);
                end
            else
                plot(squeeze(tcourseAll(nt,:,nx,ny,rep)),col(nt),'LineWidth',2);
            end
            ylim([-0.025 0.1]); xlim([1 20]);  set(gca,'Xtick',[]); set(gca,'Ytick',[]);
            set(gca,'LooseInset',get(gca,'TightInset'));
        end
    end
    toc
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    drawnow
    
    figure
    for i = 1:nt-1  %%% skip fullfield
        hold on
        plot(squeeze(tcourseAll(i,:,6,6,rep)),col(i),'LineWidth',2);
    end
    title('timecourse at 6,6');
    
end

figure
imagesc(greenCrop); colormap gray;  hold on
for i = 1:length(xrange);
    plot([0 yrange(end)+blocksize],[xrange(i)+blocksize xrange(i)+blocksize],'b')
end
for i = 1:length(yrange);
    plot([yrange(i)+blocksize yrange(i)+blocksize],[0 xrange(end)+blocksize],'b')
end
title('grid pattern')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

%%% on/off sta plots
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
    end
end

if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end



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

clear dF
for i = 1:length(x)
    dF(i,:) = mean(mean(dfofInterp(y(i)+pts_range,x(i)+pts_range,:),2),1);
end
xpts = x; ypts = y; %%% new names so they don't get overwritten



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

framerange = tau+tau_range;
clear dFclust
for i = 1:length(stimTimes)-2;
    dFclust(:,i) = nanmean(dF(:,stimFrames(i) +framerange),2)- nanmean(dF(:,stimFrames(i)+baserange),2);
end

dFclust(dFclust>0.25) = 0.25;

figure
imagesc(dF);
figure
dFclust(isnan(dFclust))=0; %%% no NaNs in clustering
imagesc(dFclust);
colorbar


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
%baserange=0:2;


tau

for clust = 1:nclust
    clustfig = figure;
    
    
    %%% spatial location of cells in this cluster
    figure(clustfig)
    subplot(2,3,1);
    imagesc(stdImg,[0 prctile(stdImg(:),99)*1.2]); axis equal; hold on;colormap gray;freezeColors;
    title(sprintf('cluster %d',clust));
    plot(x(c==clust),y(c==clust),'go')%%'Color',colors(c));
    
    for i = 1:length(stimTimes)-2;
        dFalign(i,:) = nanmean(dF(c==clust,stimFrames(i) +framerange),1)- nanmean(mean(dF(c==clust,stimFrames(i)+baserange),2),1);
    end
    
    
    sta=0; clear stas
    
    for rep = 1:2
        m= (double(moviedata)-127)/128;
        if rep==1
            m(m<0)=0;
        else
            m(m>0)=0;
        end
        %m(sz_mov==255)=0;
        
        figure;
        range = -2:2
        for taus = 3:16;
            resp = nanmean(dFalign(:,taus+range),2);
            %resp(resp<0)=0;
            %resp = resp-mean(resp);
            sta =0;
            npts = min(length(resp),size(moviedata,3));
            for i = 1:npts;
                if ~isnan(resp(i))
                    sta = sta+resp(i)*m(:,:,i);
                end
            end
            sta = sta/nansum(abs(resp(1:npts)));
            stas(:,:,taus)=sta;
            %sta = sta/sum(resp);
            subplot(4,5,taus);
            imagesc(sta',crange);colormap jet; axis equal;title(sprintf('lag %d',tau));
        end
        title(sprintf('clust %d rep %d',clust,rep));
        
        %%% get at optimal tau
        resp = nanmean(dFalign(:,tau+tau_range),2);
        sta =0;
        npts = min(length(resp),size(moviedata,3));
        for i = 1:npts;
            if ~isnan(resp(i))
                sta = sta+resp(i)*m(:,:,i);
            end
        end
        sta = sta/nansum(abs(resp(1:npts)));
        
        figure(clustfig)
        subplot(2,3,1+rep);
        imagesc(sta',1.5*crange); hold on; axis equal; colormap jet; colormap(cbrewer('div','RdBu',64))
        xprofile = max(abs(sta),[],1); [mx xmax] = max(xprofile);
        yprofile = max(abs(sta),[],2); [mx ymax] = max(yprofile);
        xmax
        ymax

%         plot(ymax,xmax,'ko');

        
        if movienum==1
            sz=[2 4 8 255]; col = 'bcrg'
        else
            sz=[0.8 2 4 8 255]; col = 'kbcrg';
        end
        
        onoffLabel = {'ON','OFF'};
        figure
        hold on
        for i = 1:length(sz)
            eps = find(m(ymax,xmax,:)~=0 & sz_mov(ymax,xmax,:)==sz(i));
            eps = eps(eps<=size(dFalign,1));
            subplot(2,3,i); hold on
            cmap = jet(length(eps));
            for j = 1:length(eps)
                plot(dFalign(eps(j),:)','Color',cmap(j,:));
            end
            plot(nanmean(dFalign(eps,:),1),col(i),'Linewidth',2);
            title(sprintf('%s sz %d',onoffLabel{rep},sz(i))); ylim([-0.1 0.1])
            
        end
        title(sprintf('cluster %d rep %d',clust,rep));
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
        %%% mean traces
        figure(clustfig)
        subplot(2,3,4+rep);
        hold on
        %%% mean traces
        for i = 1:length(sz)
            eps = find(m(ymax,xmax,:)~=0 & sz_mov(ymax,xmax,:)==sz(i));
            eps = eps(eps<=size(dFalign,1));
            plot(nanmean(dFalign(eps,:),1),col(i),'Linewidth',2);
        end
        if rep==2
            if movienum==1
                legend('2','4','8','full')
            else
                legend('1','2','4','8','full')
            end
            
        end
        ylim([-0.025 0.1]); xlim([1 20])
        
    end
    
    %%% heatmap average timecourse
    subplot(2,3,4);
    imagesc(dFclust(c==clust,:),[-0.1 0.4]); axis xy % was df
    title(sprintf('clust %d',clust)); hold on
    
    figure(clustfig)
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
end %end of for clust



clear stas
display('calculating cell STAs')

for n = 1:size(dF,1)
    if n/10 == round(n/10)
        %sprintf('done %d / %d cells',n,size(dF,1))
    end
    for i = 1:length(stimTimes)-2;
        dFalign(i,:) = dF(n,stimFrames(i) +framerange) - nanmean(dF(n,stimFrames(i)+baserange),2);
    end
    
    sta=0;
    
    for rep = 1:2
        m= (double(moviedata)-127)/128;
        if rep==1
            m(m<0)=0;
        else
            m(m>0)=0;
        end
        % m(sz_mov==255)=0;
        resp = nanmean(dFalign(:,tau+tau_range),2);
        %resp(resp<0)=0;
        %resp = resp-mean(resp);
        sta =0;
        npts = min(length(resp),size(moviedata,3));
        for i = 1:npts;
            if ~isnan(resp(i))
                sta = sta+resp(i)*m(:,:,i);
            end
        end
        sta = sta/nansum(abs(resp(1:npts)));
        stas(:,:,n,rep)=sta;
        xprofile = max(abs(sta),[],1); [mx xmax(n,rep)] = max(xprofile);
        yprofile = max(abs(sta),[],2); [mx ymax(n,rep)] = max(yprofile);
        zscore(n,rep) = (sta(ymax(n,rep),xmax(n,rep)) - mean(sta(:)))/std(sta(:));
        
        for i = 1:length(sz)
            eps = find(m(ymax(n,rep),xmax(n,rep),:)~=0 & sz_mov(ymax(n,rep),xmax(n,rep),:)==sz(i));
            eps = eps(eps<=size(dFalign,1));
            tuning(n,rep,i,:) = nanmean(dFalign(eps,:),1);
        end
    end
end

amp = nanmean(nanmean(tuning(:,:,1:3,8:15),4),3);
tcourseAll = squeeze(nanmean(nanmean(tuning(:,:,1:3,:),3),1));
figure
plot(tcourseAll'); title('mean timecourse'); legend('on','off');
figure
plot(ymax,xmax,'.'); title('all rf locations'); axis equal; axis ij

zthresh = 5.5;
use = zscore(:,1)>zthresh | zscore(:,2)<-zthresh;
useN= find(use);

useOn = find(zscore(:,1)>zthresh);
useOff = find(zscore(:,2)<-zthresh);

figure
plot(ymax(useOn,1),xmax(useOn,1),'r.'); hold on;
plot(ymax(useOff,2),xmax(useOff,2),'b.');
title('all rf locations'); axis equal; axis ij
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


rfx = ymax;  %%% reversed due to rows/columns of movie matrix
rfy = xmax;


%%% previously used Off to get center, now use both
% x0 = median(rfx(useOff,2));
% y0 = median(rfy(useOff,2));
rfxs = [rfx(useOn,1); rfx(useOff,2)];
rfys = [rfy(useOn,1); rfy(useOff,2)];
x0 = nanmedian(rfxs);
y0 = nanmedian(rfys);


figure
subplot(1,2,1)
plot(xpts(useOn),rfx(useOn,1)-x0,'r.'); hold on;
plot(xpts(useOff),rfx(useOff,2)-x0,'b.'); ylim([-30 30]); axis square
title('X topography'); legend('ON','OFF')
xlabel('x location'); ylabel('x RF');

subplot(1,2,2)
plot(ypts(useOn),rfy(useOn,1)-y0,'r.');hold on;
ylim([-30 30]); axis square
plot(ypts(useOff),rfy(useOff,2)-y0,'b.');
title('Y topography'); legend('ON','OFF')
xlabel('y location'); ylabel('y RF');

if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


useOnOff = intersect(useOn,useOff);

figure
subplot(1,2,1);
plot(rfx(useOnOff,1)-x0,rfx(useOnOff,2)-x0,'o');axis([-20 20 -20 20]);axis square
title('X RF center'); xlabel('On'); ylabel('Off');


subplot(1,2,2);
plot(rfy(useOnOff,1)-y0,rfy(useOnOff,2)-y0,'o');axis([-20 20 -20 20]); axis square
title('Y RF center'); xlabel('On'); ylabel('Off');



axLabel = {'X','Y'};
onoffLabel = {'On','Off'}
figure
for ax = 1:2
    for rep = 1:2;
        subplot(2,2,2*(rep-1)+ax)
        
        imagesc(meanGreenImg(:,:,1)); colormap gray; axis equal
        hold on
        if rep==1
            data = useOn;
        else data = useOff;
        end
        
        for i = 1:length(data)
            if ax ==1
                plot(xpts(data(i)),ypts(data(i)),'.','Color',cmapVar(rfx(data(i),rep)-x0,-25, 25, jet));
            else
                plot(xpts(data(i)),ypts(data(i)),'.','Color',cmapVar(rfy(data(i),rep)-y0,-25, 25, jet));
            end
        end
        title(sprintf('%s %s',axLabel{ax},onoffLabel{rep}))
    end
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

sz_tune = nanmean(tuning(:,:,:,8:15),4);
figure
for i = 1:2
    subplot(1,2,i)
    plot(squeeze(sz_tune(useN,i,:))')
end

notOn = find(zscore(:,1)<zthresh);
notOff = find(zscore(:,2)>-zthresh);
ampPos = amp; ampPos(ampPos<0)=0;
onOff = (ampPos(:,1)-ampPos(:,2))./(ampPos(:,1)+ampPos(:,2));
onOff(notOn)=-1; onOff(notOff)=1;


figure
imagesc(meanGreenImg(:,:,1),[-0.5 1]); colormap gray; axis equal
hold on
for i = 1:length(useN)
    plot(xpts(useN(i)),ypts(useN(i)),'o','Color',cmapVar(onOff(useN(i)),-0.5, 0.5, jet));
end
title('on off ratio')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


szPref = squeeze(sz_tune(:,:,1)+ sz_tune(:,:,2)*2 + sz_tune(:,:,3)*3)./sum(sz_tune(:,:,1:3),3);

figure
imagesc(meanGreenImg(:,:,1),[-0.5 1]); colormap gray; axis equal
hold on
for i = 1:length(useOn)
    plot(xpts(useOn(i)),ypts(useOn(i)),'o','Color',cmapVar(szPref(useOn(i),1),1.5 , 2.5, jet));
end
title('size pref On')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


figure
imagesc(meanGreenImg(:,:,1),[-0.5 1]); colormap gray; axis equal
hold on
for i = 1:length(useOff)
    plot(xpts(useOff(i)),ypts(useOff(i)),'o','Color',cmapVar(szPref(useOff(i),2),1.5 , 2.5, jet));
end
title('size pref OFF')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end


%%% mean size tuning curves
figure
subplot(2,2,1)
plot(squeeze(mean(tuning(useOn,1,:,:),1))');
title('ON')

subplot(2,2,2)
plot(squeeze(mean(tuning(useOff,2,:,:),1))');
title('OFF')

subplot(2,2,3)
plot(squeeze(mean(tuning(useOn,1,:,:),1))','r'); hold on
plot(squeeze(mean(tuning(useOff,2,:,:),1))','b');
title('On - red, Off - blue, all sizes')

subplot(2,2,4) %%% spaceholder for legend
for i = 1:length(sz); plot(1,1);hold on; end
if movienum ==1
    legend('2','4','8','full')
else
    legend('1','2','4','8','full')
end

if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

% n= ceil(rand(48,1)*size(stas,3));
%
% figure
% for rep = 1:2
%     figure
%     for i = 1:48
%         subplot(6,8,i);
%         imagesc(stas(:,:,n(i),rep)',[-0.1 0.1]); axis off; axis equal; colormap jet; title(sprintf('%0.2f',zscore(n(i),rep)));
%     end
% end


n= ceil(rand(48,1)*length(useN));

%%% plot location of all 48 points on their own figure
%%% probably want to comment this out!!!!
% for i= 1:length(n)
% figure
% imagesc(meanGreenImg(:,:,1),[-0.5 1]); colormap gray; axis equal; hold on
% plot(xpts(useN(n(i))),ypts(useN(n(i))),'o'); title(sprintf('%d %0.2f',i, zscore(useN(n(i)),1)));
% end
%
%Judit commented out for speed
%
% figure
% for rep = 1:2
%     figure
%     for i = 1:48
%         subplot(6,8,i);
%         imagesc(stas(:,:,useN(n(i)),rep)',[-0.1 0.1]); axis off; axis equal; colormap jet; title(sprintf('%0.2f',zscore(useN(n(i)),rep)));
%     end
%
%      if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
% end

n= ceil(rand(48,1)*length(useN));

figure
for rep = 1:2
    figure
    for i = 1:48
        subplot(6,8,i);
        imagesc(stas(:,:,useN(n(i)),rep)',[-0.1 0.1]); axis off; axis equal; colormap (cbrewer2('RdBu')); title(sprintf('%0.2f',zscore(useN(n(i)),rep)));
    end
end
%colormap was jet

onoffLabel = {'ON','OFF'};

figure
for i = 1:2
    subplot(1,2,i);
    plot(zscore(:,i),amp(:,i),'.'); hold on; xlabel('zscore'), ylabel('response amp'); title(onoffLabel{i})
    plot(zscore(use,i),amp(use,i),'r.');
end
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end



figure
subplot(2,1,1)
plot(zscore(:,1),rfx(:,1),'.');title('on'); xlabel('zscore'); ylabel('rf X'); hold on; plot([zthresh zthresh], [ 0 250],'r')
subplot(2,1,2);
plot(zscore(:,2),rfx(:,2),'.'); title('off'); xlabel('zscore'); ylabel('rf X'); hold on; plot([-zthresh -zthresh], [ 0 250],'r')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end





figure
for rep= 1:2
    for sz = 1:4;
        subplot(2,4,4*(rep-1)+sz)
        plot(squeeze(tuning(useN,rep,sz,:))');
        hold on
        plot(mean(squeeze(tuning(useN,rep,sz,:)),1),'g','LineWidth',2);
        ylim([-0.1 0.25]); xlim([0 20])
    end
end

%%% correlation map (shows how good the clustering is
figure
imagesc(corrcoef(dFclust(perm,:)'),[-1 1]); colormap jet
title('correlation across cells after clustering')
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

close all

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
save(outfile, 'moviedata','sz_mov',  'c', 'xpts','ypts','stdImg','meanGreenImg','dF','stimTimes','stimFrames','tuning','zscore','rfx','rfy','stas')


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