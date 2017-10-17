function [Indy] = bin_Zplane(Img_Seq, MeanImg)
% This function takes a series of 2p images that have motion artifacts in
% the z-plane and outputs the indices of the frames that don't move from
% out of the z-plane. 


for iFrame = 1:size(Img_Seq, 3)
   
   CorrCoeff(iFrame,1) = corr2(Img_Seq(:,:,iFrame),MeanImg);

   
end


end

