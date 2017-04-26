close all; clear all;

batch_widefield_eyes;
useSess = 1:length(files);

load('\\angie\Angie_analysis\DetectionStim2contrast_LOW_7_25min.mat')
contrast = contrast(1:end-5); xpos = xpos(1:end-5); ypos=ypos(1:end-5);

for sess = 1:length(useSess);
    
    %load([pathname '\' files(i).dir '\' files(i).moviename]);
    clear alignTheta
    load([pathname '\' files(sess).dir '\' files(sess).detection],'dfof_bg','frameT','cycMap','sp','stimRec','xEye','yEye','xFilt','yFilt','sp','rad','X','Y','R');
    load([pathname '\' files(sess).dir '\' files(sess).detection],'alignTheta','alignZoom','alignLambda');
    
    %%% align data
    redoAlign=0;
    if ~exist('alignTheta','var') | redoAlign
        blueImg = max(dfof_bg,[],3);
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
        clear dx dy
        for i = 1:2
            [dy(i) dx(i)] = ginput(1);
            plot(dy(i),dx(i),'g*');
        end
        plot(dy,dx)
        
        ringRadius = sqrt(diff(dx)^2 + diff(dy)^2)
        alignTheta = atand((midx-lambdax)/(midy-lambday))
        blueRot = imrotate(blueImg,alignTheta);
        blueRot = imresize(blueRot,128/ringRadius);
        
        figure
        imagesc(blueRot,[0 prctile(blueImg(:),95)*1.2]); colormap gray; axis equal
        display('click on lambda');
        [alignLambda(2) alignLambda(1)] = ginput(1);
        hold on
        plot(lambday,lambdax,'g*');
        
        zm = size(dfof_bg,1)/size(blueImg,1);
        ringRadiusZm = zm*ringRadius;
        alignZoom = 128/ringRadiusZm
        save([pathname '\' files(sess).dir '\' files(sess).detection],'alignTheta','alignZoom','alignLambda','-append');
    end
    
    dfof_bgAlign = imrotate(dfof_bg,alignTheta);
    dfof_bgAlign = imresize(dfof_bgAlign,alignZoom);
    
    figure
    imagesc(prctile(dfof_bgAlign(:,:,10:10:end),99,3))
    hold on
    plot(alignLambda(2),alignLambda(1),'g*')
    
    downsamp=1;
    dfof_bg= imresize(dfof_bgAlign(alignLambda(1)-64:alignLambda(1)+63,alignLambda(2)-110:alignLambda(2)+17,:),1/downsamp,'box');
    
    figure
    imagesc(prctile(dfof_bg(:,:,10:10:end),99,3)); axis equal
    hold on
    plot([1 128],[64 64],'r'); plot(109, 64,'g*')
    drawnow
    
    %%% crop and downsize dF data to make it run faster
    %dfof_bg= dfof_bg(15:160,50:190,:);
    dfof_bg = imresize(dfof_bg,0.25);
    % contrast = contrast(1:end-5); %%% cut off last few in case imaging stopped early
    
    %%% median filter eye and speed data to remove transients
    x = medfilt1(xEye,5); y= medfilt1(yEye,5);
    v = medfilt1(sp,9); r = medfilt1(rad,7);
    
    Xfilt = medfilt1(X,5); Yfilt = medfilt1(Y,5);
    %%% show raw and filtered data
    figure
    plot(xEye); hold on; plot(x); title('x'); legend('raw','filtered')
    figure
    plot(rad); hold on; plot(r); title('r'); legend('raw','filtered')
    figure
    plot(sp); hold on; plot(v); title('v'); legend('raw','filtered')
    
    %%% normalize eye/speed data (custom function nrm)
    %x = nrm(x); y = nrm(y); r= nrm(r); v = nrm(v);
    x = x/100; y = y/100; r = r/40; v =v/3000;
    
   im = dfof_bg;
   clear dfof_bg;
   
    stdImg = std(im(:,:,10:10:end),[],3);
    figure; imagesc(stdImg,[0 0.1]); colormap jet; axis equal;
    
    if ~exist('npts','var'); npts=0; end
    
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
    
    col = repmat('bgrcmyk',[1 200]);  %%% color scheme
    clear trace
    for i = 1:npts
        trace(:,i) = squeeze(im(x(i),y(i),:));
    end
 
    
    %%% reshape into a 2-d matrix for pca
    obs = reshape(im,size(im,1)*size(im,2),size(im,3));
    sigcol = reshape(stdImg,size(im,1)*size(im,2),1);
    obs(sigcol<0.01,:)=0;  %%% remove pts with low variance to select brain from bkground
    useTime = sp<10;
    obs = obs(:,useTime);
    
    %%% PCA
    [coeff score latent] = pca(obs');
    
    %%% show loading of PCA components
    figure
    plot(1:10,latent(1:10)/sum(latent))
    xlabel('component'); ylabel('latent')
   
       figure
    for i = 1:24
        subplot(4,6,i);
        range = max(abs(coeff(:,i)));
        imagesc(reshape(coeff(:,i),size(im,1),size(im,2)),[-range range])
       % hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
    end
    
      figure
    for i = 1:5
        subplot(5,1,i);
        plot(score(:,i)); axis off
    end
    
      if exist('sp','var') && sum(sp~=0)
        figure
        subplot(3,1,1)
        plot(sp(useTime)); ylabel('speed')
        subplot(3,1,2);
        plot(score(:,1)); ylabel('component1')
        subplot(3,1,3)
        plot(sp(useTime)/max(sp(useTime)),'g'); hold on; plot(score(:,1)/max(score(:,1)));

        for i = 1:3
        figure
        plot(-120:0.1:120,xcorr(sp(useTime),score(:,i),1200,'coeff'));
%         title('sp comp1 xcorr'); xlabel('secs'); ylim([-0.5 0.5])
%         set(gcf, 'PaperPositionMode', 'auto');     print('-dpsc',psfilename,'-append');
        end
      end
    
      if exist('r','var') && sum(sp~=0)
          figure
          subplot(3,1,1)
          plot(r(useTime)); ylabel('speed')
          subplot(3,1,2);
          plot(score(:,1)); ylabel('component1')
          subplot(3,1,3)
          plot(r(useTime)/max(r(useTime)),'g'); hold on; plot(score(:,1)/max(score(:,1)));
          
          for i = 1:3
              figure
              plot(-120:0.1:120,xcorr(r(useTime),score(:,i),1200,'coeff'));
              %         title('sp comp1 xcorr'); xlabel('secs'); ylim([-0.5 0.5])
              %         set(gcf, 'PaperPositionMode', 'auto');     print('-dpsc',psfilename,'-append');
          end
      end
      
       tcourse = coeff(:,1)*score(:,1)' ; %+ coeff(:,2)*score(:,2)' + coeff(:,4)*score(:,4)';
    obs = obs-tcourse;

    
    obs_im = reshape(obs,size(im(:,:,useTime)));
    
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
        ypts = [];
        xpts = [];
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
    legend('contra','ipsi');
      
    corrAll(:,:,sess) = corr;
end




