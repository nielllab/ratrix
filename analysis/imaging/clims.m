function [Range] = clims(Img_Seq, nSample)
%This function calculates a representative range to use for imagesc, rather
%than taking the percentile of the mean of an image stack
%
% Input:
%   3D image matrix (i.e. two image channel movies)
%   nSample: integer of how many frames you want to perform the mean over
% Output:
%   Grn/RedRange: 2D vector containing percentile values to use for imagesc

%% Calculate Range for scaled image display
nframes = size(Img_Seq,3);
sm = floor(nframes/nSample) - 1;
Range = zeros(1,2);

for iFrame = 1:sm:nframes
    
    tmp = Img_Seq(:,:,iFrame,1);
    Range(1) = Range(1) + prctile(tmp(:),2);
    Range(2) = Range(2) + prctile(tmp(:),98);

end

Range = Range./nSample;

end

