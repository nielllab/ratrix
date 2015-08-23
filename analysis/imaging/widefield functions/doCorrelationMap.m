[f p] = uigetfile('*.mat','pts file');
load(fullfile(p,f),'x','y');
downsamp = 4;
x= round(x/downsamp); y= round(y/downsamp);

psfilename = 'C:\tempPS.ps';
if exist(psfilename,'file')==2;delete(psfilename);end

for f= 1:length(use)
    display('loading data')
    
    clear dfof_bg sp
    tic
    load([pathname files(use(f)).darkness],'dfof_bg','sp');
    toc
    
    display('aligning dfof')
    tic
    zoom = 260/size(dfof_bg,1);
    dfof_bg = shiftImageRotate(dfof_bg,allxshift(f)+x0,allyshift(f)+y0,allthetashift(f),zoom,sz);
    toc
    
    dfof_bg(dfof_bg>0.2) = 0.2;
    
    im= imresize(dfof_bg,1/downsamp,'box');
    
    figure
    hold on
    col = 'bgrcmyk'
    for i = 1:7
        trace(:,i) = squeeze(im(x(i),y(i),:));
        plot(squeeze(im(x(i),y(i),:))+i*0.2,col(i))
    end
    
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    figure
    imagesc(corrcoef(trace),[0 1]); colorbar
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
    obs = reshape(im,size(im,1)*size(im,2),size(im,3));
    sigcol = reshape(sig,size(im,1)*size(im,2),1);
    obs(sigcol<0.025,:)=0;  %%% remove pts with no variance
    
    [coeff score latent] = pca(obs');
    figure
    plot(2:10,latent(2:10))
    xlabel('component'); ylabel('latent')
    
    figure
    for i = 1:12
        subplot(3,4,i);
        imagesc(reshape(coeff(:,i),size(im,1),size(im,2)),[-0.1 0.1])
        hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
    end
    
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    if exist('sp','var') && sum(sp~=0)
        figure
        plot(sp/max(sp),'g'); hold on; plot(score(:,1)/max(score(:,1)));
        legend('speed','comp 1')
        set(gcf, 'PaperPositionMode', 'auto');     print('-dpsc',psfilename,'-append');
        
        sp(isnan(sp))=0;
        figure
        plot(-60:0.1:60,xcorr(sp,score(:,1),600,'coeff'));
        title('sp comp1 xcorr'); xlabel('secs'); ylim([-0.2 0.2])
        set(gcf, 'PaperPositionMode', 'auto');     print('-dpsc',psfilename,'-append');
      
    end
    
    %%% remove first component, which dominates
    %%% probably correlates to running)
    tcourse = coeff(:,1)*score(:,1)';
    obs = obs-tcourse;
    obs_im = reshape(obs,size(im));
    
    cv=cov(obs');
    cc = corrcoef(obs');
    
    figure; hold on
    for i = 1:7
        decorrTrace(:,i) = squeeze(obs_im(x(i),y(i),:));
        plot(decorrTrace(:,i)+0.1*i,col(i));
    end
    
    figure
    imagesc(corrcoef(decorrTrace),[-1 1]); colorbar
    title('area decorrelated')
    traceCorr = corrcoef(decorrTrace);
    % traceCorr(traceCorr<=0)=0.01;
    
    cc_im = reshape(cc,size(im,1),size(im,2),size(im,1),size(im,2));
    decorrSig = std(obs_im,[],3);
    
    figure
    hold on
    for i = 1:7
        plot(y(i),x(i),[col(i) 'o'],'Markersize',8,'Linewidth',2)
        for j= 1:7
            if traceCorr(i,j)>0.02
                plot([y(i) y(j)],[x(i) x(j)],'Linewidth',8*traceCorr(i,j))
            end
        end
    end
    plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
    axis ij
    axis equal
    
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    n=0;
    for i = 15:3:45
        for j = 15:3:45
            n=n+1; xall(n) = i; yall(n)=j;
        end
    end
    
    figure
    hold on
    for i = 1:n
        % plot(y(i),x(i),[col(i) 'o'],'Markersize',8,'Linewidth',2)
        for j= 1:n
            if cc_im(xall(i),yall(i),xall(j),yall(j))>0.5
                plot([yall(i) yall(j)],[xall(i) xall(j)],'b','Linewidth',8*(cc_im(xall(i),yall(i),xall(j),yall(j))-0.5))
            end
        end
    end
    plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
    axis ij
    axis equal
    
    
    figure
    subplot(2,4,1)
    imagesc(decorrSig,[0 0.025])
    hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
    axis equal;axis off;
    for i = 1:7
        subplot(2,4,i+1)
        imagesc(squeeze(cc_im(x(i),y(i),:,:))); hold on
        plot(y(i),x(i),'g*');
        hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
        axis equal;
        axis off;
    end
    
    set(gcf, 'PaperPositionMode', 'auto');
    print('-dpsc',psfilename,'-append');
    
    decorrSigAll(:,:,f)=decorrSig;
    traceCorrAll(:,:,f)=traceCorr;
    cc_imAll(:,:,:,:,f) = cc_im;
end

decorrSig = mean(decorrSigAll,3);
cc_imAll = mean(cc_imAll,5);
traceCorr = nanmeanMW(traceCorrAll,3);

figure
subplot(2,4,1)
imagesc(decorrSig,[0 0.025])
hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2);
axis equal;axis off;
for i = 1:7
    subplot(2,4,i+1)
    imagesc(squeeze(cc_im(x(i),y(i),:,:))); hold on
    plot(y(i),x(i),'g*');
    hold on; plot(ypts/downsamp,xpts/downsamp,'k.','Markersize',2)
    axis equal;
    axis off;
end

set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');

figure
imagesc(traceCorr,[-1 1]);
title('avg corr post-decorr')

set(gcf, 'PaperPositionMode', 'auto');
print('-dpsc',psfilename,'-append');


figure
hold on
for i = 1:7
    plot(y(i),x(i),[col(i) 'o'],'Markersize',8,'Linewidth',2)
    for j= 1:7
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

[f p] = uiputfile('*.pdf','save pdf');
if f~=0
    try
        ps2pdf('psfile', psfilename, 'pdffile', fullfile(p,f));
    catch
        display('couldnt generate pdf');
    end
end
delete(psfilename);

[f p ] = uiputfile('*.mat','save data?')
if f~=0
    save(fullfile(p,f),'decorrSigAll','traceCorrAll','cc_imAll')
end
