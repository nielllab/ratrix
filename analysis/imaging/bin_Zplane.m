function [Indy] = bin_Zplane(Img_Seq, fwidth, idx)
% This function takes a series of 2p images that have motion artifacts in
% the z-plane and outputs the indices of the frames that don't move from
% out of the z-plane. 

Indy = [];
nFrames = size(Img_Seq,3);
CorrCutoff = 0;
CorrCoeff = zeros(nFrames,1);

filt = fspecial('gaussian',5,fwidth);

for ii = 1:nFrames
    % Downsample from 256x256 to 128x128 to decrease computing time &
    % decrease noise that may effect correlation measure
    %iiImg = imresize(Img_Seq(:,:,ii),0.5);
    iiImg = imfilter(Img_Seq(:,:,ii),filt);
    % Start at jj = ii because correlation matrix is symmetric
    for jj = ii:nFrames
        %jjImg = imresize(Img_Seq(:,:,jj),0.5);
        jjImg = imfilter(Img_Seq(:,:,jj),filt);
        CorrCoeff(ii,jj) = corr2(iiImg,jjImg);
    end
end

disp('Oiy');
end

