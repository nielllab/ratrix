function [GrnRange, RedRange] = clims(Img_Seq)
%This function calculates a representative range to use for imagesc, rather
%than taking the percentile of the mean of an image stack
%
% Input:
%   4D image matrix (i.e. two image channel movies)
% Output:
%   Grn/RedRange: 2D vector containing percentile values to use for imagesc

%% Calculate Range for scaled image display
nframes = size(Img_Seq,3);
sm = floor(nframes/4) - 1;
GrnRange = zeros(1,2);
RedRange = zeros(1,2);
for iFrame = 1:sm:nframes
    tmp = Img_Seq(:,:,iFrame,1);
    GrnRange(1) = GrnRange(1) + prctile(tmp(:),2);
    GrnRange(2) = GrnRange(2) + prctile(tmp(:),98);
    
    tmp = Img_Seq(:,:,iFrame,2);
    RedRange(1) = RedRange(1) + prctile(tmp(:),2);
    RedRange(2) = RedRange(2) + prctile(tmp(:),98);
end

end

