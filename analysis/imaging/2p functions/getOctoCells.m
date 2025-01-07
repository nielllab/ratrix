if isfield(Opt,'selectPts')
    selectPts = Opt.selectPts;
else
    selectPts = input('select points automatically (0) by hand (1) or suite2p (2) or red/green suite2p (3): ');
end

if selectPts==1
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
    
elseif selectPts==0
    
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
        pts = pts(x>xrange(1) & x<xrange(2) & y>yrange(1) & y<yrange(2));
    else
        
        b = pts_range(end)+1;  %%% previously 5
        xrange = [b size(img,2)-b];
        yrange = [b size(img,1)-b];
        pts = pts(x>xrange(1) & x<xrange(2) & y>yrange(1) & y<yrange(2));
    end
    
    
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
    plot(x,y,'o');title(sprintf('df pts_range %d',pts_range(end)))
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

    %%% average df/f in a box around each selected point
    
    clear dF
    for i = 1:length(x)
        dF(i,:) = mean(mean(dfofInterp(y(i)+pts_range,x(i)+pts_range,:),2),1);
    end
    xpts = x; ypts = y; %%% new names so they don't get overwritten
    
    
elseif selectPts ==2 | selectPts==3
    %%% suite2p
    if isfield(Opt,'s2p_fname')
        load(Opt.s2p_fname)
    else
        [s2p_file s2p_path] = uigetfile('*.mat','suite2p .mat file');
        iscell = 0; %%% need to initialize so matlab doesn't think this is a function
        load(fullfile(s2p_path, s2p_file));
    end
    %%%% select out cells
    
    F = F(:,startTrim:end);  %%% removes times before initial stim,same as done for dfofInterp
    meanF = mean(F(find(iscell(:,1)),:),2);
    
    figure
    hist(iscell(:,2)); xlabel('iscell'); ylabel('n')
    title(sprintf('n = %d good = %d',length(iscell), sum(iscell(:,1))));
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
   % stdImg =  imresize( ops.max_proj,0.5);
    stdImg =  imresize( ops.meanImg,0.5);  % changed on 121224 from max project
    
    %%% all masks, color coded by iscell
    img = zeros(size(ops.meanImg,1),size(ops.meanImg,2),3);
    cols = jet(100);
    for c = 1:length(iscell)
        xpix = stat{c}.xpix;
        ypix = stat{c}.ypix;
        lam = stat{c}.lam;
        
        for i = 1:length(xpix);
            img(ypix(i),xpix(i),:) = cols(ceil(iscell(c,2)*100),:)*lam(i)/max(lam);
        end
    end
    
    figure
    imshow(img);
    title('masks coded by iscell'); colormap jet; colorbar
    
    goodcells = find(iscell(:,1) & mean(F,2)>0.5 *median(meanF));
    
    figure
    plot(iscell(:,2),mean(F,2),'.')
    hold on; plot([0 1],[ 0.5 *median(meanF) 0.5 *median(meanF)])
    
    figure
    plot(iscell(:,2),std(diff(F,[],2),[],2)./mean(F,2),'.')
    
    figure
    plot(iscell(:,2),std(F,[],2)./mean(F,2),'.')
    
    % hold on; plot([0 1],[ 0.5 *median(meanF) 0.5 *median(meanF)])
    
    ncells = length(goodcells);
    
    %%% compute image of good cell masks
    cols = [ 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
    img = zeros(size(stdImg,1),size(stdImg,2),3);
    for c = 1:ncells
        xpix = stat{goodcells(c)}.xpix;
        ypix = stat{goodcells(c)}.ypix;
        lam = stat{goodcells(c)}.lam;
        xpts(c) = round(mean(xpix))/2;  %%% since other image data is downsampled 2x
        ypts(c) = round(mean(ypix))/2;
        
        
        for i = 1:length(xpix);
            img(ypix(i),xpix(i),:) = cols(mod(c,6)+1,:)*lam(i)/max(lam);
        end
    end
    x = xpts; y = ypts;
    %show max and masks side by side
    figure
    imshow(1.5*ops.max_proj/max(ops.max_proj(:))); colormap gray; axis equal; title('max projection')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure
    imshow(img)
    title(sprintf('masks %d good cells',ncells))
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    maxProj = zeros(size(ops.meanImg));
    maxProj(ops.yrange(1):ops.yrange(2)-1, ops.xrange(1):ops.xrange(2)-1)= ops.max_proj;
    figure
    imagesc(maxProj); colormap gray; axis equal
    
    
    %%% calculate dF/F
    if selectPts ==2
        clear dF
        for c = 1:ncells
            dF(c,:) = (F(goodcells(c),:) - mean(F(goodcells(c),:)))/mean(F(goodcells(c,:)));
        end
        F = F(goodcells,:);
        stat = stat(goodcells);
    elseif selectPts ==3
        [s2p_redfile s2p_path] = uigetfile('*.mat','red suite2p .mat file');
        iscell = 0; %%% need to initialize so matlab doesn't think this is a function
        load(fullfile(s2p_path, s2p_redfile));
        for c = 1:ncells
            greenred = F./F_chan2;
            dF(c,:) = (greenred(goodcells(c),:) - mean(greenred(goodcells(c),:)))/mean(greenred(goodcells(c,:)));
            
        end
        green = F(goodcells,:);
        red = F_chan2(goodcells,:);
        F = greenred(goodcells,:);
        
    end
    
    %%% plot dF/F traces for random subset
    dF(dF>1)=1;
    figure
    hold on
    range = 1:min(3000,length(dF));
    dtr= 0.1;
    np=32;
    for i = 1:np;
        plot(range*dtr,2*dF(ceil(rand*ncells),range)+i);
    end
    %     np=size(dF,1);
    %     for i = 1:np;
    %         plot(range*dt,dF(i,range)+i);
    %     end
    ylim([0 np+2])
    xlabel('secs'); ylabel('cell #');  title('dF/F')
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    %     figure
    %     for i = 1:np
    %         subplot(np,1,i);
    %         plot(red(i,:));
    %         hold on
    %         plot(green(i,:))
    %     end
end  %%% if/else



