pixFig = figure; set(gcf,'Name',figLabel);
traceFig = figure; set(gcf,'Name',figLabel);
for i = (1:npanel)+offset
    meanimg = median(trialmean(:,:,stimOrder==i),3);
    figure(pixFig); subplot(nrow,ncol,loc(i-offset));
    imagesc(meanimg,range); axis equal; axis off; colormap jet
    figure(traceFig); subplot(nrow,ncol,loc(i-offset));
    plot(1:8, trialTcourse(:,stimOrder==i)); hold on; plot(median(trialTcourse(:,stimOrder==i),2),'g','Linewidth',2); xlim([1 8]);ylim(range)
    
end

figure(pixFig);colorbar; if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
figure(traceFig); if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
