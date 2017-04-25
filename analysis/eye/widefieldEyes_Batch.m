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
    
    %X = nrm(Xfilt(:,60:180)); Y=nrm(Yfilt)
    figure
    hist(x,0.01:0.02:1); title('x position')
    % figure
    % hist(Xfilt,0.01:0.02:1)
    %%% plot a lot of comparisons!
    
    left=unique(xpos(3))
    right=unique(xpos(1))
    use01 = find(contrast==.01&xpos==right)
    use04 = find(contrast==.04&xpos==right)
    
    figure
    set(gcf,'Name','contrast= 0.04, Right Position')
    for i=1:length(use04)
        subplot(2,8,i)
        plot(R(use04(i),:)); axis square ; ylim([10 25]); xlim([0 180]); hold on;
        plot([60 60],[10 25],'g');  plot ([75 75],[10 25],'g');
        subplot(2,8,i+8)
        plot(Xfilt(use04(i),:),Yfilt(use04(i),:));hold on; axis square
        %xlim([40 70]);ylim([105 120])
        plot(Xfilt(use04(i),:),Yfilt(use04(i),:),'.r');
    end
    
    figure
    set(gcf,'Name','contrast= 0.01, Right Position')
    for i=1:length(use01)
        subplot(2,8,i)
        plot(R(use01(i),:)); axis square ; ylim([10 25]); xlim([0 180]); hold on;
        plot([60 60],[10 25],'g');  plot ([75 75],[10 25],'g');
        subplot(2,8,i+8)
        plot(Xfilt(use01(i),:),Yfilt(use01(i),:));hold on; axis square
        xlim([40 70]);ylim([105 120])
        plot(Xfilt(use01(i),:),Yfilt(use01(i),:),'.r');
    end
    
    
    figure
    plot(x,y); title('eye position'); hold on; plot(x,y,'r.')
    figure
    plot(Xfilt(contrast==0.01,:)');hold on; plot(Y(contrast==0.01,:)')
    figure
    plot(frameT(1:length(x)),x/max(x)); title('X')
    hold on
    plot(frameT,v/max(v))
    
    figure
    plot(nanmean(Xfilt(contrast==0.04,:)))
    figure
    plot(nanmean(R(contrast==0.04,:)))
    
    %%% mean radius for each contrast
    radiusAll(1,:,sess) = nanmean(R(contrast==0.01,:));
    radiusAll(2,:,sess) = nanmean(R(contrast==0.04,:));
    %%%mean X for each position
    xAll(1,:,sess) = nanmean(Xfilt(xpos==right & contrast==0.04,:));
    xAll(2,:,sess) = nanmean(Xfilt(xpos~=right & contrast==0.04,:));
    
    
    figure
    plot(frameT(1:length(y)),y/max(y)); title('Y')
    hold on
    plot(frameT,v/max(v))
    
    figure
    plot(frameT(1:length(r)),r/max(r)); title('radius')
    hold on
    plot(frameT,v/max(v))
    
    
    dF = squeeze(mean(mean(dfof_bg,2),1));
    dF = nrm(dF);
    figure
    plot(frameT,dF/max(dF)); title('dF')
    hold on
    plot(frameT,v/max(v))
    legend('dF','v')
    
    
      figure
    plot(frameT,r/max(r)); title('dF')
    hold on
    plot(frameT,v/max(v))
    legend('dF','v')
    
    
    figure
    plot(frameT,dF); title('dF')
    hold on
    plot(frameT,r)
    legend('dF','r')
    
    figure
    plot(r,dF,'.'); xlabel('r'); ylabel('dF');
    
    figure
    plot(v,dF,'.'); xlabel('v'); ylabel('dF');
    
    figure
    plot(x,dF,'.');xlabel('x'); ylabel('dF');
    
    figure
    plot(x,y,'.'); xlabel('x'); ylabel('y')
    
    figure
    plot(x,r,'.'); xlabel('x'); ylabel('r')
    
    
    %%% align data to stim onsets
    stimT = stimRec.ts - stimRec.ts(1);
    figure
    plot(diff(stimT))
    
    isiFrames = isi*10; durFrames = duration*10;
    vis = zeros(size(r));
    nstim=0;
    clear trialR trialV trialX trialY trialDF
    for trial = 1:length(contrast);
        trial
        start=  (trial-1)*(durFrames+isiFrames) + isiFrames;
        stop = start + durFrames;
        vis(start:stop) = contrast(trial);
        visPos(start:stop) = double(xpos(trial)==right);
        range = round((start-isiFrames+1):(stop + 30));
        trialR(trial,:) = r(range);
        trialV(trial,:) = v(range);
        trialX(trial,:) = x(range);
        trialY(trial,:) = y(range);
        trialDF(trial,:,:,:) = dfof_bg(:,:,(start-1):(stop+10));
        %%% add other variables here = position and orientation
    end
    
    %%% look at averages for contrast==1
    figure
    trials = find(contrast==0.04);
    for i = 1:16
        subplot(4,4,i);
        plot(trialX(trials(i),:)); xlim([1 size(trialV,2)])
        hold on; plot(trialR(trials(i),:));
        plot(isiFrames,0.5,'*');
        xlim([1 size(trialV,2)]); ylim([0 1])
        legend('eyeX', 'eyeR')
    end
    
    vis = vis(1:length(r));
    vis = vis/max(vis);
    %%% calculate change in variables (maybe better than actual position)
    dx = [0 ; diff(x)];
    dy = [0 ;diff(y) ];
    dr = [ 0 ; diff(r)];
    dv = [0 ; diff(v)];
    dvis = [0 ; diff(vis)];
    dvis(dvis<0)=0;
    
    figure
    imagesc(mean(dfof_bg(:,:,vis>0),3)- mean(dfof_bg(:,:,vis==0),3))
    title('mean visual activation')
    
    rdx = dx; rdx(rdx<0)=0;
    ldx = -dx; ldx(ldx<0)=0;
    %%% perform regression on behavioral variables at multiple lags, and covert
    %%% to images
    clear vfit xcorr mx
    for lag = -10:2:10;
        dfShift = circshift(dfof_bg,[0 0 lag]);
        clear vfit vcorr
        for i = 1:size(dfof_bg,1);
            i
            for j = 1:size(dfof_bg,2);
%                 [vfit(i,j,:) nil resid]= regress(squeeze(dfShift(i,j,:)),[v r   vis abs(dx) dx ones(size(r))]);
%                 vcorr(i,j,:) = partialcorri(squeeze(dfShift(i,j,:)),[v r   vis abs(dx) dx]);
                
                    [vfit(i,j,:) nil resid]= regress(squeeze(dfShift(i,j,:)),[v r   vis ldx rdx ones(size(r))]);
                vcorr(i,j,:) = partialcorri(squeeze(dfShift(i,j,:)),[v r   vis ldx rdx]);
            end
        end
        
        figure
        for i = 1:5
            subplot(2,3,i);
            if i<4
                im = mat2im(vfit(:,:,i),jet,[0 0.1]);
            elseif i==4
                im = mat2im(vfit(:,:,i),jet,[0 0.25]);
            elseif i==5
                im = mat2im(vfit(:,:,i),jet,[-0.1 0.1]);
            end
            vc = vcorr(:,:,i);
            range = max(0.05, prctile(abs(vc(:)),95));
            im = im.*repmat(abs(squeeze(vcorr(:,:,i))),[1 1 3])/range;
            timecourse(:,:,:,i,(lag+10)/2 +1) = im;
            imshow(imresize(im,5))
            mx(i,(lag+10)/2 +1) = prctile(abs(vc(:)),95);
            title(sprintf('r2 %0.2f',prctile(abs(vc(:)),95)));
        end
        set(gcf,'Name',sprintf('lag %d',lag));
        drawnow
        
        vfitAll(:,:,:,(lag+10)/2 + 1,sess)=vfit;
        vcorrAll(:,:,:,(lag+10)/2 + 1,sess) = vcorr;
        
    end
    
    figure
    plot(-1:0.2:1,mx(:,end:-1:1)'); xlabel('secs'); ylabel('partial correlation')
    legend('v','r','vis','abs(dx)','dx')
    
    titles = {'V','R','vis stim','abs(dx)','dx'};
    for i = 1:5
        figure
        for j = 1:11
            subplot(3,4,j)
            imshow(imresize(squeeze(timecourse(:,:,:,i,12-j)),2))
        end
        set(gcf,'Name',titles{i});
    end
    
    timecourseAll(:,:,:,:,:,sess)=timecourse;
    mxAll(:,:,sess)=mx;
    
end


figure
for i = 1:4
    subplot(2,2,i)
    imshow(squeeze(timecourseAll(:,:,:,5,5,i)));
end


figure
for i = 1:4
    subplot(2,2,i)
    imagesc(squeeze(vcorrAll(:,:,2,5,i)))
    colorbar
end


figure
for i = 1:4
    subplot(2,2,i)
    imagesc(squeeze(vfitAll(:,:,2,5,i)))
    colorbar
end

labels = {'V','R','vis','abs(dx)','dx'};
ranges = [0 0.25; 0 0.35; 0 0.05; 0 0.25; -0.05 0.05];
for d = 1:5
  figure
  for i = 1:11
    subplot(3,4,i)
    imagesc(squeeze(mean(vfitAll(:,:,d,i,:),5)),ranges(d,:))
  end
  set(gcf,'Name',[labels{d} ' fit']);  
end

%%% plot correlation coeff avg across sessions
ranges = [0 0.5; 0 0.5; 0 0.05; 0 0.25; -0.05 0.05];
for d = 1:5
  figure
  for i = 1:11
    subplot(3,4,i)
    imagesc(squeeze(mean(vcorrAll(:,:,d,i,:),5)),ranges(d,:))
  end
    set(gcf,'Name',[labels{d} ' corr']);
end


variable=5;
ranges = [0 0.5; 0 0.5; 0 0.05; 0 0.25; 0 0.25];
for d = 1:4
  figure
  for i = 1:11
    subplot(3,4,i)
    imagesc(squeeze(vcorrAll(:,:,variable,i,d)),[-0.1 0.1])
    end
end



