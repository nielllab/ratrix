pixFig = figure; set(gcf,'Name',figLabel);
traceFig = figure; set(gcf,'Name',figLabel);
tl = size(trialTcourse,1);

for i = (1:npanel)+offset
    meanimg = nanmean(trialmean(:,:,stimOrder==i),3);
    figure(pixFig); subplot(nrow,ncol,loc(i-offset));
    data_im = mat2im(meanimg,jet,range);
    imshow(imresize(data_im.*normgreen,0.5)); axis equal; axis off; colormap jet
    figure(traceFig); subplot(nrow,ncol,loc(i-offset));
    plot(1:tl, weightTcourse(:,stimOrder==i)); hold on; plot(nanmedian(weightTcourse(:,stimOrder==i),2),'g','Linewidth',2); xlim([1 tl]);ylim(range/2)
    
end

figure(pixFig);
%colorbar; 
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
figure(traceFig); if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
