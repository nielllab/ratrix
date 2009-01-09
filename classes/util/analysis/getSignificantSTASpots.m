function [sigSpots2D sigSpots3D]=getSignificantSTASpots(sta,spikeCount,contrast,medianFilter,alpha);
%     getSignificantSTASpots(sta,spikeCount,contrast=1,medianFilter=logical(ones(3)),alpha=.05);
% sigSpots2D labels of the spots that are siginifcant in the time slice.  
% 0= not signifcant
% 1= belongs to group 1
% 2= belongs to group 2... etc 
% with the most significant pixels
% sig spots3D is returned but might not be used yet by any users,
% it contains the labels for each 2D processed time slice.  spot #1:N in time slice t 
% do NOT have unique values across time slices (ie. there are many ID==1's)
% and may or may not be contiguous in space-time. 

if ~exist('contrast','var') || isempty(contrast)
    contrast=1;
end

if ~exist('medianFilter','var') || isempty(medianFilter)
    medianFilter=logical(ones(3));
end

if ~exist('alpha','var') || isempty(alpha)
    alpha=.05;
end

nullStd=sqrt(spikeCount)*contrast; % double check this
zscore = erf(abs(sta/nullStd));
significant = zscore > (1 - alpha/2);

% do the calculation now
% sta, spikeCount, stim, numFrames, contrast, alpha, rf
%                 sta = mean(triggers,3);
% denoise significant to see if we have a good receptive field
% use a 3x3 box median filter, followed by bwlabel (to count the number of spots left)
%                 box = ones(3,3);
%                 cross = zeros(3,3); cross([2,4,5,6,8]) = 1;

midpoint=ceil(length(medianFilter(:))/2);
sigSpots3D=nan(size(sta));
T=size(sta,3);
for t=1:T
    filtered = ordfilt2(significant(:,:,t),midpoint,medianFilter);
    [sigSpots3D(:,:,t) numSpots] = bwlabel(filtered,8); % use 8-connected (count diagonal connections)
end

%num significant pixels per time step
sigPixels=reshape(sum(sum(sigSpots3D,1), 2),T,[]); 

%push to 2D
%only earliest time if there is a tie for the max number of significant pixels
whichTime=find(sigPixels==max(sigPixels));
sigSpots2D=mean(sigSpots3D(:,:,whichTime(1))>0,3)>0;
