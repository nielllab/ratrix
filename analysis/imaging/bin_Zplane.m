function [Indy] = bin_Zplane(fname, idx)
% This function takes a series of 2p images that have motion artifacts in
% the z-plane and outputs the indices of the frames that don't move from
% out of the z-plane. 

% Get Image Size
Img_Info = imfinfo(fname);
nframes = length(idx);

% PreAllocate
Img_Seq = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes);
Img_Corrected = zeros(Img_Info(1).Height,Img_Info(1).Width,nframes);

figure
colormap gray
for iFrame = 1:length(idx)
   Img_Seq(:,:,iFrame) = double(imread(fname,(iFrame-1)*2+1)); 
   
   Img_Corrected(:,:,iFrame) = imwarp( Img_Seq(:,:,iFrame),r.T{1,iFrame});
   
   imagesc(Img_Corrected(:,:,iFrame)),hold on
   drawnow 
    
end

T = adaptthresh(Img_Corrected(:,:,1),0.7);
BW = imbinarize(Img_Corrected(:,:,1));
figure
imshowpair(Img_Corrected(:,:,1), mean_corrected, 'montage')

imresize
end

