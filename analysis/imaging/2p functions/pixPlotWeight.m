pixFig = figure; set(gcf,'Name',figLabel);
traceFig = figure; set(gcf,'Name',figLabel);
tl = size(trialTcourse,1);

for i = (1:npanel)+offset
    meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
    figure(pixFig); subplot(nrow,ncol,loc(i-offset));
    data_im = mat2im(meanimg,jet,range);
    imshow(imresize(data_im.*normgreen,0.5)); axis equal; axis off; colormap jet
    figure(traceFig); subplot(nrow,ncol,loc(i-offset));
    set(gcf,'defaultAxesColorOrder',jet(sum(stimOrder==i)));
    plot(1:tl, weightTcourse(:,stimOrder==i)); hold on; plot(nanmedian(weightTcourse(:,stimOrder==i),2),'g','Linewidth',2); xlim([1 tl]);ylim(range/2)
    
end

figure(pixFig);
%colorbar;
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
figure(traceFig); if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

if showAll
    for i = (1:npanel)+offset
        meanimg = nanmedian(trialmean(:,:,stimOrder==i),3);
        figure
        data_im = mat2im(meanimg,jet,range);
        imshow(imresize(data_im.*normgreen,0.5)); axis equal; axis off; colormap jet
        if gratingTitle & exist('freq','var')
            title(sprintf('theta %0.0f sf %0.2f',orient(i),freq(i)),'Fontsize',8);
        end
        if exist('titles','var')
            title(titles{i})
        end
        %%% label the large panel with its position in the nrow x ncol grid
        gp = loc(i-offset); gr = ceil(gp/ncol); gc = mod(gp-1,ncol)+1;   %%% subplot index -> grid row/col
        posStr = sprintf('row %d, col %d',gr,gc);
        if nrow==4 && ncol==6   %%% 6x4 stim sets: edge / interior / center-4 flags
            if gr>=2 && gr<=3 && gc>=3 && gc<=4
                posStr = [posStr ' - not on edge! centered!'];
            elseif gr>=2 && gr<=3 && gc>=2 && gc<=5
                posStr = [posStr ' - not on edge!'];
            end
        end
        oldT = get(get(gca,'Title'),'String');
        if isempty(oldT)
            title(posStr,'Fontsize',10);
        else
            title({oldT; posStr},'Fontsize',8);
        end
        if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
        
    end
end

