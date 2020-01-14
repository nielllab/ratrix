%%% plot retinotopy based on 6x4 spots

szx = ncol; szy=nrow;
%szx=6; szy=4;
filt = fspecial('gaussian',[10  10],1);
trialmeanfilt = imfilter(trialmean,filt);

nstim = 2*szx*szy;
nloc = szx*szy;
x = ones(nstim,1);
y= ones(nstim,1);
onoff = ones(nstim,1);onoff(1:nloc)=0;

for xpos = 1:szx;
    x(((xpos-1)*szy+1):(xpos*szy))=xpos;
end
x(nloc +(1:nloc))=x(1:nloc);

for ypos = 1:szy;
    y(ypos:szy:end)=ypos;
end

clear meanImg
for i = 1:nstim;
    meanImg(:,:,i) = nanmean(trialmeanfilt(:,:,stimOrder==i),3);
end
meanImg(meanImg<0.025)=0;

for rep=1:2 %%% off and on
    xmap = 0; ymap =0;
    onrange = nloc*(rep-1) + (1:nloc) ;
    for i = onrange %%% only take on (or off) responses
        xmap = xmap+meanImg(:,:,i)*x(i);
        ymap = ymap+meanImg(:,:,i)*y(i);
    end
    amp = sum(meanImg(:,:,onrange),3);
    amp(amp<=0)=0.001;
    ymap = ymap./amp;
    xmap = xmap./amp;
    amp = amp/0.3;
    amp(amp>1)=1;
    
    topoAmp = amp;
%     figure
%     imagesc(amp)
%     figure
%     imagesc(xmap,[1 szx]);colormap hsv
%     figure
%     imagesc(ymap,[1 szy]); colormap hsv
    
    xmap(isnan(xmap))=0;
    xpolar = mat2im(xmap,hsv,[1.5 szx-0.5]);
    xpolar = xpolar.*repmat(amp,[1 1 3]);
    topox = figure;
    imshow(imresize(xpolar,2));
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    ymap(isnan(ymap))=0;
    ypolar = mat2im(ymap,hsv,[1.5 szy-0.5]);
    ypolar = ypolar.*repmat(amp,[1 1 3]);
    topoy = figure;
    imshow(imresize(ypolar,2));
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    xphase{rep} = xmap; yphase{rep} = ymap;
    overlay = zeros(size(topoAmp,1),size(topoAmp,2),3);
    
    overlay = meanGreenImg;
    %overlay(:,:,2) = overlay(:,:,2).*topoAmp;
    overlay(:,:,1) = overlay(:,:,1).*(1- topoAmp).^2;
    overlay(:,:,3) = overlay(:,:,3).*(1 - topoAmp).^2;
    
%     figure
%     imshow(overlay);
%     
%     figure
%     imshow(topoAmp)
%     
%     if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
%     
    
    xpolarImg{rep} = xpolar;
    ypolarImg{rep} = ypolar;
    topoOverlayImg{rep} = overlay;
    topoAmpImg{rep} = topoAmp;
end
% 
% figure
% for i= 26:50;
%     subplot(5,5,i-25);
%     imagesc(meanImg(:,:,i),[0 0.1])
% end
% 
% figure
% imshow(xpolar);
% [y x] = ginput(2);
% [xgrid ygrid] = meshgrid(1:size(xpolar,2),1:size(xpolar,1));
% 
% vector = [x(2)-x(1) y(2)-y(1)];
% vector = vector/sqrt(vector(1)^2 + vector(2)^2);
% xgrid = xgrid-x(1);
% ygrid = ygrid-y(1);
% dist = xgrid*vector(1) + ygrid*vector(2);
% figure
% imagesc(dist)
% figure
% plot(dist(amp>0.75), xmap(amp>0.75),'.')
% 
% dvals = dist(amp>0.75); xvals = (xmap(amp>0.75)-2.4)*10;
% dvals = dvals(:); xvals = xvals(:);
% binx = -25:25:150;
% clear mapMean mapStd
% for i = 1:length(binx)-1
%     mapMean(i) = median(xvals(dvals>binx(i) & dvals<binx(i+1)));
%     mapStd(i) =std(xvals(dvals>binx(i) & dvals<binx(i+1)))/ sqrt(25);
% end
% figure
% errorbar((binx(1:end-1)+25)*400/256, mapMean,mapStd);
% xlim([-25 250]); xlabel('distance (um)');
% ylabel('RF azimuth (deg)')
% figure
% imshow(ypolar);
% [y x] = ginput(2);
% [xgrid ygrid] = meshgrid(1:size(xpolar,2),1:size(xpolar,1));
% 
% vector = [x(2)-x(1) y(2)-y(1)];
% vector = vector/sqrt(vector(1)^2 + vector(2)^2);
% xgrid = xgrid-x(1);
% ygrid = ygrid-y(1);
% dist = xgrid*vector(1) + ygrid*vector(2);
% figure
% imagesc(dist)
% figure
% plot(dist(amp>0.5), ymap(amp>0.5),'.')
