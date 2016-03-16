
%%% load in points for analysis
[f p] = uigetfile('*.mat','pts file');
if f~=0
    load(fullfile(p,f),'x','y');
else
    display('will select points later')
    x=[]; y=[];
end
npts = length(x);

%%% is there a map of visual areas?
if ~exist('xpts','var')
    xpts= []; ypts = [];
end

%%% factor to downsample images by
%%% (reduces noise and computational demand)
downsamp = 4;
x= round(x/downsamp); y= round(y/downsamp);

%%% create an empty ps file for pdf
psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

%need way to make sure this can use subset of files that have correct stim
%to load below

%newuse = find(strcmp({files.notes},'good imaging session')   & ~strcmp({files(use(f)).darkness},'') ); %


for f= 1:length(use)
    display('loading data')
    clear dfof_bg sp
     tic 
     %make sure this is stim that exists in each file included in use?
    load([pathname files(use(f)).darkness],'dfof_bg','sp');  %the stim to run correlation on
    toc
    
    display('aligning dfof')
    tic
    zoom = 260/size(dfof_bg,1);
    %%% alignment data is available then align
    if exist('allxshift','var')
        dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
    end
    toc
    
    %%% remove noisy outliers (ad hoc)
    dfof_bg(dfof_bg>0.2) = 0.2;
    
    %%% downsample
    im= imresize(dfof_bg,1/downsamp,'box');
    
    %%% if points weren't loaded in, then select
    if npts ==0;
        npts = input('number of points to select')
        figure
        imagesc(im(:,:,1),[-0.2 0.2]); colormap gray
        hold on
        for i = 1:npts
            [y(i) x(i)] = ginput(1);
            plot(y,x,'g*')
        end
        x=round(x); y= round(y);
    end
     
    figure
    hold on
    col = repmat('bgrcmyk',[1 20]);  %%% color scheme
    
    %%% plot trace of selected points
    for i = 1:npts
        trace(:,i) = squeeze(im(x(i),y(i),:));
        plot(squeeze(im(x(i),y(i),:))+i*0.2,col(i))
    end
    title(sprintf('%s %s raw',files(use(f)).subj, files(use(f)).expt));   
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    %%% correlation coefficient matrix for selected points
    figure
    imagesc(imresize(corrcoef(trace),10,'nearest'),[0.8 1]); colorbar
    title('corr pre-decor')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    
    %%% plot rms value
    sig = std(im,[],3);
    figure
    imagesc(sig,[0 0.075]); colorbar
    hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
    title('std dev')
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    %
    %     imsmooth= imfilter(im,filt); %%% highpass filter
    %     im = im-0.5*imsmooth;
    
    %%% reshape into a 2-d matrix for pca
    obs = reshape(im,size(im,1)*size(im,2),size(im,3));
    sigcol = reshape(sig,size(im,1)*size(im,2),1);
    obs(sigcol<0.02,:)=0;  %%% remove pts with low variance to select brain from bkground
    
    %%% PCA
    [coeff score latent] = pca(obs');
    
    %%% show loading of PCA components
    figure
    plot(1:10,latent(1:10))
    xlabel('component'); ylabel('latent')
    
    %%% show first 12 spatial components
    figure
    for i = 1:12
        subplot(3,4,i);
        imagesc(reshape(coeff(:,i),size(im,1),size(im,2)),[-0.1 0.1])
        hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
    end    
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    %%% plot timecourse of first 5 components
    figure
    for i = 1:5
        subplot(5,1,i);
        plot(score(:,i)); axis off
    end
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    %%% plot first component vs running speed (if available)
    if exist('sp','var') && sum(sp~=0)
        figure
        subplot(3,1,1)
        plot(sp); ylabel('speed')
        subplot(3,1,2);
        plot(score(:,1)); ylabel('component1')
        subplot(3,1,3)
        plot(sp/max(sp),'g'); hold on; plot(score(:,1)/max(score(:,1)));
        legend('speed','comp 1')
        set(gcf, 'PaperPositionMode', 'auto');     print('-dpsc',psfilename,'-append');
        
        figure
        plot(sp,score(:,1),'.')
        xlabel('speed'); ylabel('score1')
        sp(isnan(sp))=0;
        figure
        plot(-120:0.1:120,xcorr(sp,score(:,1),1200,'coeff'));
        title('sp comp1 xcorr'); xlabel('secs'); ylim([-0.2 0.2])
        set(gcf, 'PaperPositionMode', 'auto');     print('-dpsc',psfilename,'-append');
        
    end
    
    %%% remove first component, which dominates
    %%% I call this decorrelation, though not exactly true
    tcourse = coeff(:,1)*score(:,1)';
    obs = obs-tcourse;
    obs_im = reshape(obs,size(im));
    
    %%% calculate correlation coeff matrix for whole frame
    cc = corrcoef(obs');
    
    %%% plot timecourse for selected points after decorrelation
    figure; hold on
    for i = 1:npts
        decorrTrace(:,i) = squeeze(obs_im(x(i),y(i),:));
        plot(decorrTrace(:,i)+0.1*i,col(i));
    end
    title(sprintf('%s %s decorr',files(use(f)).subj, files(use(f)).expt));
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    %%% correlation matrix for selected points
    figure
    imagesc(imresize(corrcoef(decorrTrace),10,'nearest'),[-1 1]); colorbar
    title('area decorrelated')
    traceCorr = corrcoef(decorrTrace);
    % traceCorr(traceCorr<=0)=0.01;
    
    %%% convert correlation coeff back into matrix
    cc_im = reshape(cc,size(im,1),size(im,2),size(im,1),size(im,2));
    decorrSig = std(obs_im,[],3);
    
    %%% kmeans clustering
    nclust = 7;
    tic
    idx = kmeans(decorrTrace',nclust,'distance','correlation');
    toc
    
    maxim = prctile(im,95,3); %%% 95th percentile makes a good background image
    
    %%% plot clustered points with connectivity
    clustcol = 'wgrcmyk'; %%% color scheme for clusters
    figure
    imagesc(maxim) ; colormap gray; axis equal
    hold on
    for i = 1:npts
        for j= 1:npts
            if traceCorr(i,j)>0.5
                plot([y(i) y(j)],[x(i) x(j)],'Linewidth',8*(traceCorr(i,j)-0.5),'Color','b')
            end
        end
    end
    for i = 1:npts
        plot(y(i),x(i),[clustcol(idx(i)) 'o'],'Markersize',8,'Linewidth',2)
    end
    plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
    axis ij
    axis equal
    
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    %%% choose evenly spaced grid points for connectivity
%     n=0;
%     for i = 1:3:35
%         for j = 25:3:70
%             n=n+1; xall(n) = i; yall(n)=j;
%         end
%     end
%    
%     %%% plot connectivity of grid points
%     figure
%     imagesc(im(:,:,1),[-0.2 0.2]) ; colormap gray; axis equal
%     hold on
%     for i = 1:n
%         % plot(y(i),x(i),[col(i) 'o'],'Markersize',8,'Linewidth',2)
%         for j= 1:n
%             if cc_im(xall(i),yall(i),xall(j),yall(j))>0.75
%                 plot([yall(i) yall(j)],[xall(i) xall(j)],'b','Linewidth',8*(cc_im(xall(i),yall(i),xall(j),yall(j))-0.75))
%             end
%         end
%     end
%     plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
%     axis ij
%  
    
 %%% show correlation images for selected points   
    figure
    subplot(ceil(sqrt(npts+1)),ceil(sqrt(npts+1)),1)
    imagesc(decorrSig,[0 0.025])
    hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
    axis equal;axis off;
    for i = 1:npts
        subplot(ceil(sqrt(npts+1)),ceil(sqrt(npts+1)),i+1)
        imagesc(squeeze(cc_im(x(i),y(i),:,:))); hold on
        plot(y(i),x(i),'g*');
        hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
        axis equal;
        axis off;
    end
    
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    %%% store results for this subject
    decorrSigAll(:,:,f)=decorrSig;
    traceCorrAll(:,:,f)=traceCorr;
    cc_imAll(:,:,:,:,f) = cc_im;
end

%%% take mean over subjects
decorrSig = mean(decorrSigAll,3);
cc_imMn = mean(cc_imAll,5);
traceCorr = nanmeanMW(traceCorrAll,3);

%%% figures for averaged data

%%% mean correlation maps for first 7 pts
figure
subplot(2,4,1)
imagesc(decorrSig,[0 0.025])
hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
axis equal;axis off;
for i = 1:7
    subplot(2,4,i+1)
    imagesc(squeeze(cc_imMn(x(i),y(i),:,:))); hold on
    plot(y(i),x(i),'g*');
    hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
    axis equal;
    axis off;
end
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

%%% correlation matrix for selected points
figure
imagesc(imresize(traceCorr,10,'nearest'),[-1 1]);
title('avg corr post-decorr')
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');


%%% average connectivity map
figure
imagesc(im(:,:,1),[-0.2 0.2]) ; colormap gray; axis equal
hold on
for i = 1:npts
    plot(y(i),x(i),[col(i) 'o'],'Markersize',8,'Linewidth',2)
    for j= 1:npts
        if traceCorr(i,j)>0.02
            plot([y(i) y(j)],[x(i) x(j)],'Linewidth',8*traceCorr(i,j))
        end
    end
end
plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
axis ij
axis square; axis([10 50 10 50])
set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

%%% save pdf
[f p] = uiputfile('*.pdf','save pdf');
if f~=0
    try
        ps2pdf('psfile', psfilename, 'pdffile', fullfile(p,f));
    catch
        display('couldnt generate pdf');
    end
end
delete(psfilename);

%%% save group data
[f p ] = uiputfile('*.mat','save data?')
if f~=0
    save(fullfile(p,f),'decorrSigAll','traceCorrAll','cc_imAll','cc_imMn')
end
