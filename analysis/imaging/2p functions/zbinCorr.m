%%% remove frames based on correlation with mean image
%%% new method of binning to account for z-movement

display('doing clustering')
%%% recreate small version of absolute fluorescence
greensmall = double(imresize(greenframe,0.5));
F = (1 + dfofInterp).*repmat(greensmall,[1 1 size(dfofInterp,3)]);

%%% resize and reshape images into vectors, to calculate distance
smallDf = imresize(F(50:350,50:350,:),1/2); %%% remove edges for boundary effects
% smallDf = reshape(smallDf,size(smallDf,1)*size(smallDf,2),size(smallDf,3));
smallMean = nanmedian(smallDf,3);
figure
imagesc(smallMean);

for i = 1:size(smallDf,3);
    
    im = smallDf(:,:,i);
    cc = corrcoef(im(:),smallMean(:));
    dist(i) = cc(2,1);
end

figure
plot(dist), ylim([0 1]); title('correlation with median')
%ccthresh = 0.9;
ccthresh = input('enter correlation threshold : ')
figure
plot(dist); ylim([0 1])
title('correlation of images with median'); xlabel('frame'); ylabel('corr coef')
hold on
plot([1 length(dist)], [ccthresh ccthresh],'r:');
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end

useframes = dist>ccthresh;
figure
imagesc(mean(F(:,:,dist>ccthresh),3)); title(sprintf('mean of frames above thresh %0.2f used',mean(useframes)));

display('redoing dfofinterp')
F0 = repmat(prctile(F(:,:,useframes),10,3),[1 1 size(F,3)]);
dfofInterp = (F-F0)./F0;

dfofInterp(:,:,~useframes)=NaN;
mv(~useframes,:)=NaN;
greenframe = imresize(mean(F(:,:,useframes),3),2);

figure
range =[prctile(greenframe(:),1) prctile(greenframe(:),98)*1.2];
imagesc(greenframe,range); colormap gray
title(sprintf('mean of binned thresh = %0.2f used %0.2f',ccthresh, mean(useframes)))
if exist('psfile','var'); set(gcf, 'PaperPositionMode', 'auto'); print('-dpsc',psfile,'-append'); end
