
%%% load in points for analysis
%[f p] = uigetfile('*.mat','pts file');
f=0;
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
%downsamp = input('binning ratio (default = 4) : ');
downsamp=2;
x= round(x/downsamp); y= round(y/downsamp);

%%% create an empty ps file for pdf
psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

%cropImg = input('crop images? 0/1 : ');
cropImg=0;
%flipImg =input('flip image along horiz? 0/1 : ');


for f= 1:length(use)
   flipImg=files(use(f)).flip;
   display('loading data')
    clear dfof_bg sp
    tic
    load([pathname files(use(f)).darkness],'dfof_bg','sp');
    
    if flipImg
        dfof_bg = flip(dfof_bg,2);
    end
    
    blueImg = imread([pathname files(use(f)).darknessdata]);
    blueImg = blueImg(23:end,:);  %%%% remove timestamp, to match dfof_bg
    
    
        blueImg=fliplr(blueImg);
   
    toc
    
    figure
    imagesc(blueImg,[0 prctile(blueImg(:),95)*1.2]); colormap gray; axis equal
    
    display('click on lambda');
    [lambday lambdax] = ginput(1);
    hold on
    plot(lambday,lambdax,'g*');
    
    display('click on anterior midline');
    [midy midx] = ginput(1);
    plot([midy lambday],[midx lambdax]);
    
    display('click on diameter of ring (two points)');
    for i = 1:2
        [dy(i) dx(i)] = ginput(1);
        plot(dy(i),dx(i),'g*');
    end
    plot(dy,dx)

    ringRadius = sqrt(diff(dx)^2 + diff(dy)^2)
    
    theta = atand((midx-lambdax)/(midy-lambday))
    blueRot = imrotate(blueImg,theta);
    blueRot = imresize(blueRot,128/ringRadius);
    
    figure
    imagesc(blueRot,[0 prctile(blueImg(:),95)*1.2]); colormap gray; axis equal
    display('click on lambda');
    [lambday lambdax] = ginput(1);
    hold on
    plot(lambday,lambdax,'g*');
    
    zm = size(dfof_bg,1)/size(blueImg,1);
    ringRadiusZm = zm*ringRadius;
    finalZoom = 128/ringRadiusZm
    
    dfof_bgAlign = imrotate(dfof_bg,theta);
    dfof_bgAlign = imresize(dfof_bgAlign,finalZoom);
    
    figure
    imagesc(prctile(dfof_bgAlign(:,:,10:10:end),99,3))
    hold on
    plot(lambday,lambdax,'g*')
    
 
    im= imresize(dfof_bgAlign(lambdax-64:lambdax+63,lambday-27:lambday+100,:),1/downsamp,'box');
    
    figure
    imagesc(prctile(im(:,:,10:10:end),99,3)); axis equal
    hold on
    plot([1 128],[64 64],'r')
    
    if cropImg
      im = im(1:size(im,1)/2,:,:);
    end
    stdImg = std(im(:,:,10:10:end),[],3);
    figure; imagesc(stdImg,[0 0.1]); colormap jet; axis equal;
    
    %%% if points weren't loaded in, then select
    if npts ==0;
        npts = input('number of points to select (0=auto grid) : ')
        if npts>0 %%% manually select point
            figure
            imagesc(stdImg,[0 0.1]); colormap jet
            hold on
            for i = 1:npts
                [y(i) x(i)] = ginput(1);
                plot(y,x,'g*')
            end
            x=round(x); y= round(y);
        else %%% auto select points on grid
            gridspace = input('grid spacing : ');
            clear x y ptstd
            for xi = gridspace:gridspace:size(im,1);
                for yi = gridspace:gridspace:size(im,2);
                    npts = npts+1;
                    x(npts)=xi; y(npts)=yi;
                    ptstd(npts) = stdImg(xi,yi);
                end
            end
            npts = sum(ptstd>0.02); x = x(ptstd>0.02); y= y(ptstd>0.02);
           
            figure
            imagesc(stdImg,[0 0.1]); colormap gray; hold on
            plot(y,x,'g*')
            done = 0;
            while ~done
                [yi xi b] = ginput(1);
                if b==3
                    done=1;
                else
                    ind = find(x==round(xi)&y==round(yi));
                    
                    x=x(setdiff(1:length(x),ind)); y = y(setdiff(1:length(y),ind));
                    hold off
                    imagesc(stdImg,[0 0.1]); colormap gray; hold on
                    plot(y,x,'g*')
                end
            end
            npts = length(y);
                    
        end
        
    end
    
%     figure
%     hold on
    col = repmat('bgrcmyk',[1 200]);  %%% color scheme
    
    %%% plot trace of selected points
    clear trace
    for i = 1:npts
        trace(:,i) = squeeze(im(x(i),y(i),:));
 %       plot(squeeze(im(x(i),y(i),:))+i*0.2,col(i))
    end
 %   title(sprintf('%s %s raw',files(use(f)).subj, files(use(f)).expt));
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfilename,'-append');
%     
    %%% correlation coefficient matrix for selected points
%     figure
%     imagesc(imresize(corrcoef(trace),10,'nearest'),[0.5 1]); colorbar
%     title('corr pre-decor')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfilename,'-append');
    
    
    %%% plot rms value
    sig = std(im,[],3);
%     figure
%     imagesc(sig,[0 0.075]); colorbar
%     hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
%     title('std dev')
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfilename,'-append');
%     
    %
    %     imsmooth= imfilter(im,filt); %%% highpass filter
    %     im = im-0.5*imsmooth;
    
    %%% reshape into a 2-d matrix for pca
    obs = reshape(im,size(im,1)*size(im,2),size(im,3));
    sigcol = reshape(sig,size(im,1)*size(im,2),1);
    obs(sigcol<0.01,:)=0;  %%% remove pts with low variance to select brain from bkground
    
    %%% PCA
    [coeff score latent] = pca(obs');
    
    %%% show loading of PCA components
    figure
    plot(1:10,latent(1:10)/sum(latent))
    xlabel('component'); ylabel('latent')
    
    %%% show first 12 spatial components
    figure
    for i = 1:12
        subplot(3,4,i);
        range = max(abs(coeff(:,i)));
        imagesc(reshape(coeff(:,i),size(im,1),size(im,2)),[-range range])
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
        
        for i = 1:3
        figure
        plot(-120:0.1:120,xcorr(sp,score(:,i),1200,'coeff'));
%         title('sp comp1 xcorr'); xlabel('secs'); ylim([-0.5 0.5])
%         set(gcf, 'PaperPositionMode', 'auto');     print('-dpsc',psfilename,'-append');
        end
    end
    
    %%% remove first component, which dominates
    %%% I call this decorrelation, though not exactly true
    tcourse = coeff(:,1)*score(:,1)' ; %+ coeff(:,2)*score(:,2)' + coeff(:,4)*score(:,4)';
    obs = obs-tcourse;

    
    obs_im = reshape(obs,size(im));
    
    %%% calculate correlation coeff matrix for whole frame
    cc = corrcoef(obs');
    
    %%% plot timecourse for selected points after decorrelation
   % figure; hold on
    clear decorrTrace
    for i = 1:npts
        decorrTrace(:,i) = squeeze(obs_im(x(i),y(i),:));
     %   plot(decorrTrace(:,i)+0.1*i,col(i));
    end
  %  title(sprintf('%s %s decorr',files(use(f)).subj, files(use(f)).expt));
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfilename,'-append');
    
    %%% correlation matrix for selected points
%     figure
%     imagesc(imresize(corrcoef(decorrTrace),10,'nearest'),[-1 1]); colorbar
%     title('area decorrelated')
    traceCorr = corrcoef(decorrTrace);
    % traceCorr(traceCorr<=0)=0.01;
    
    %%% convert correlation coeff back into matrix
    cc_im = reshape(cc,size(im,1),size(im,2),size(im,1),size(im,2));
    decorrSig = std(obs_im,[],3);
    
    %%% kmeans clustering
    nclust = 6;
    tic
    idx = kmeans(decorrTrace',nclust,'distance','correlation');
    toc
    
    maxim = prctile(im,95,3); %%% 95th percentile makes a good background image
    
    traceCorr = corrcoef(decorrTrace);
%     figure
%     imagesc(traceCorr)
   
        %%% plot clustered points with connectivity
    clustcol = 'wgrcmyk'; %%% color scheme for clusters
    figure
    imagesc(maxim) ; colormap gray; axis equal
    hold on
    clear dist contra 
    for i = 1:npts
        for j= 1:npts
            dist(i,j) = sqrt((x(i)-x(j))^2 + (y(i)-y(j))^2);
            contra(i,j) = (x(i)-size(im,2)/2) * (x(j)-size(im,2)/2) <0 & ~(x(i)==33) & ~(x(j)==33) ; %%% does it cross the midline
            if traceCorr(i,j)>0.6 && contra(i,j)
                plot([y(i) y(j)],[x(i) x(j)],'Linewidth',8*(traceCorr(i,j)-0.6),'Color','b')
            end
        end
    end
  
    for i = 1:npts
        plot(y(i),x(i),[clustcol(idx(i)) 'o'],'Markersize',8,'Linewidth',2)
        plot(y(i),x(i),[clustcol(idx(i)) '*'],'Markersize',8,'Linewidth',2)
    end
    plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
    axis ij
    axis equal
    
    
    %%% plot clustered points with connectivity
    clustcol = 'wgrcmyk'; %%% color scheme for clusters
    figure
    imagesc(maxim) ; colormap gray; axis equal
    hold on
  
    for i = 1:npts
        for j= 1:npts
            
            if traceCorr(i,j)>0.5 && dist(i,j) > gridspace*2 &&~contra(i,j)
                plot([y(i) y(j)],[x(i) x(j)],'Linewidth',8*(traceCorr(i,j)-0.5),'Color','b')
            end
        end
    end  
    for i = 1:npts
        plot(y(i),x(i),[clustcol(idx(i)) 'o'],'Markersize',8,'Linewidth',2)
        plot(y(i),x(i),[clustcol(idx(i)) '*'],'Markersize',8,'Linewidth',2)
    end
    plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
    axis ij
    axis equal
    
    dist = dist(:);
    traceCorr = traceCorr(:);
    contra = contra(:);
    
    distbins = gridspace/2:gridspace:60;
    for i = 1:length(distbins)-1;
        meanC(i) = mean(traceCorr(dist>distbins(i) & dist<=distbins(i+1) & ~contra));
    end
    meanC(i+1) = mean(traceCorr(contra & dist>2*gridspace));
    
    figure
    bar(meanC)
    xlabel('distance'); ylabel('correlation')
    
    figure
     hold on
    plot(dist(contra),traceCorr(contra),'r*')
    plot(dist(~contra),traceCorr(~contra),'o');
    xlabel('distance'); ylabel('correlation')

    
%     set(gcf, 'PaperPositionMode', 'auto');
%     print('-dpsc',psfilename,'-append');
    

    
    %%% show correlation images for selected points
%     figure
%     subplot(ceil(sqrt(npts+1)),ceil(sqrt(npts+1)),1)
%     imagesc(decorrSig,[0 0.025])
%     hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
%     axis equal;axis off;
%     for i = 1:npts
%         subplot(ceil(sqrt(npts+1)),ceil(sqrt(npts+1)),i+1)
%         imagesc(squeeze(cc_im(x(i),y(i),:,:))); hold on
%         plot(y(i),x(i),'g*');
%         hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
%         axis equal;
%         axis off;
%     end
    
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    %%% store results for this subject
    conn(f).meanC=meanC;
    conn(f).trace=trace;
    conn(f).decorrTrace=decorrTrace;
   conn(f).x=x; conn(f).y=y; conn(f).dist=dist; conn(f).contra=contra;
   conn(f).maxim=maxim;
   conn(f).traceCorr=traceCorr;
   npts=0;

end

allMeanC = mean(vertcat(conn.meanC)) + 0.5;
allMeanCerr = std(vertcat(conn.meanC))/sqrt(length(conn));
figure
bar(allMeanC);
hold on
errorbar(allMeanC,allMeanCerr,'k.')



%%% figures for averaged data
