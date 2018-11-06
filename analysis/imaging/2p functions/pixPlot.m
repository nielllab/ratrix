pixFig = figure; set(gcf,'Name',figLabel);
traceFig = figure; set(gcf,'Name',figLabel);
tl = size(trialTcourse,1);

for i = (1:npanel)+offset
    meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
    figure(pixFig); subplot(nrow,ncol,loc(i-offset));
    imagesc(meanimg,range); axis equal; axis off; colormap jet
    figure(traceFig); subplot(nrow,ncol,loc(i-offset));
    set(gcf,'defaultAxesColorOrder',jet(sum(stimOrder==i)));
    plot(1:tl, trialTcourse(:,stimOrder==i)); hold on; plot(nanmedian(trialTcourse(:,stimOrder==i),2),'g','Linewidth',2); xlim([1 tl]);ylim(range/2)
    
end

figure(pixFig);
%colorbar; 
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
figure(traceFig); if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
