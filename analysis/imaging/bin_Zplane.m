function [Indy] = bin_Zplane(Img_Seq, MeanImg, idx)
% This function takes a series of 2p images that have motion artifacts in
% the z-plane and outputs the indices of the frames that don't move from
% out of the z-plane. 

Indy = [];
nFrames = size(Img_Seq,3);
CorrCutoff = 0.5;
CorrCoeff = zeros(nFrames,1);

figure
colormap bone
for iFrame = 1:nFrames
   
    CorrCoeff(iFrame,1) = corr2(Img_Seq(:,:,iFrame),MeanImg);
    if CorrCoeff(iFrame) > CorrCutoff
        Indy = [Indy, idx(iFrame)];
        imagesc(Img_Seq(:,:,iFrame)),hold on
        ss = sprintf('Frame #%u',iFrame);
        title(ss);
        drawnow
    end

end

for ii = 1:nFrames
    for jj = 1:nFrames
         CorrCoeff(ii,jj) = corr2(Img_Seq(:,:,ii),Img_Seq(:,:,jj));
%         if CorrCoeff(ii) > CorrCutoff
%             Indy = [Indy, idx(ii)];
%         end
    end
end

end

