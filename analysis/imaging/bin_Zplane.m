function [Indy] = bin_Zplane(Img_Seq, fwidth, idx)
% This function takes a series of 2p images that have motion artifacts in
% the z-plane and outputs the indices of the frames that don't move from
% out of the z-plane. 

Indy = [];
nFrames = size(Img_Seq,3);
CorrCutoff = 0;
CorrCoeff = zeros(nFrames,1);

filt = fspecial('gaussian',5,fwidth);

% for iFrame = 1:nFrames
%     % Downsample from 256x256 to 128x128 to decrease computing time &
%     % decrease noise that may effect correlation measure
%     %iiImg = imresize(Img_Seq(:,:,ii),0.5);
%     iiImg = imfilter(Img_Seq(:,:,iFrame),filt);
%     % Start at jj = ii because correlation matrix is symmetric
%     for jj = iFrame:nFrames
%         %jjImg = imresize(Img_Seq(:,:,jj),0.5);
%         jjImg = imfilter(Img_Seq(:,:,jj),filt);
%         CorrCoeff(iFrame,jj) = corr2(iiImg,jjImg);
%     end
% end

disp('Oiy');

% Vectorize each frame in the sequence and create a 2D matrix with each row
% corresponding to a frame and each column corresponding to a particular
% pixel in the image
Img_Seq2D = zeros(nFrames,size(Img_Seq,1)*size(Img_Seq,2));
for iFrame = 1:nFrames
    % Apply Gaussian Filter to increase SNR
    %iiImg = imfilter(Img_Seq(:,:,iFrame),filt);
    iiImg = Img_Seq(:,:,iFrame);
    
    %Add to 2D sequence
    Img_Seq2D(iFrame,:) = iiImg(:);
end

D = pdist(Img_Seq2D,'correlation');

Z = linkage(D,'ward'); 

[h t perm] = dendrogram(Z,0,'Orientation','Left','ColorThreshold' ,3);

T = cluster(Z,'maxclust',5);
figure
colormap gray
for iFrame = 1:1000
    if T(iFrame) == 4
        imagesc(Img_Seq(:,:,iFrame))
        drawnow
        
        Indy = [Indy iFrame]
    end
end

% figure
% subplot(3,4,[1 5 9 ])
% display('doing dendrogram')
% 
% axis off
% subplot(3,4,[2 3 4 6 7 8 10 11 12 ]);
% imagesc(dFmean(perm,:),[0 0.4]); axis xy ; xlabel('selected traces based on dF'); colormap jet ;   %%% show sorted data
% hold on;
% totalT = size(dF,2);
% ncyc = floor(totalT/cycLength);
% for i = 1:ncyc
%     plot([i*cycLength i*cycLength]+1.5,[1 length(perm)],'k');
% end
% 
% %%% select number of clusters you want
% nclust =input('# of clusters : '); %%% set to however many you want
% c= cluster(Z,'maxclust',nclust);
% colors = hsv(nclust+1); %%% color code for each cluster


end

