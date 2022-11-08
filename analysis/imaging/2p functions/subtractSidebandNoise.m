function [dfofInterp meanImg greenframe] = subtractSidebandNoise(dfofInterp,meanImg, psfile,mv);
    display('subtracting off noise')
    %%% subtract off noise as measured from sideband %%%
    %greensmall = double(imresize(greenframe,0.5));
    F = (1 + dfofInterp).*repmat(meanImg,[1 1 size(dfofInterp,3)]);

    offset = squeeze(nanmean(F(:,[1:20 end-20:end],:),2));
    offset = offset-median(offset(:));
    offset(:,abs(mv(:,2))>20) = 0;
    figure
    imagesc(offset); colorbar; title('noise measured from sidebands'); xlabel('frame'); ylabel('row');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    figure
    plot(nanmean(offset(:,1:1000),1));
    xlabel('frame'); ylabel('sideband value'); title('sideband noise over time');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
        figure
    plot(nanmean(offset,1));
    xlabel('frame'); ylabel('sideband value'); title('sideband noise over time');
    if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
    
    
    offset_full = repmat(offset,[1 1 size(F,2)]);
    offset_full = permute(offset_full, [1 3 2]);
    
    F_fix = F-offset_full;
    greensmall = nanmedian(F_fix(:,:,5:5:end),3);
    F0 = repmat(greensmall,[1 1 size(dfofInterp,3)]);
    
    greenframe = imresize(greensmall,2);
    dfofInterp = (F_fix - F0)./F0;