function [dfofInterp meanImg greenframe mv] = zbinCorr_DR(dfofInterp, meanImg, greenframe, Opt, psfile, mv)
% zbinCorr_DR  Z-plane binning correction for octopus 2-photon data.
%
% Removes imaging frames whose pixel content is poorly correlated with the
% session median image (indicating the focal plane drifted to a different
% z-position).  Frames below the user-supplied correlation threshold are
% excluded: the dF/F stack has those frames set to NaN, and the mean
% fluorescence image (meanImg) is recomputed from good frames only.
%
% This is the DR-customised version of zbinCorr:
%   - Uses exportgraphics() instead of print('-dpsc') for PDF export.
%   - smallMean computed with nanmedian, matching the original zbinCorr exactly.
%   - Accepts and returns mv so bad-frame rows are NaN-ed in the caller.
%   - Adds a startup diagnostic to confirm dfofInterp is clean.
%
% USAGE:
%   [dfofInterp, meanImg, greenframe, mv] = ...
%       zbinCorr_DR(dfofInterp, meanImg, greenframe, Opt, psfile, mv)
%
% INPUTS:
%   dfofInterp  [nY x nX x nFrames]  dF/F movie
%   meanImg     [nY x nX]            baseline fluorescence image
%   greenframe  [nY x nX]            downsampled mean image
%   Opt         struct               Opt.binningThresh skips interactive prompt
%   psfile      char                 accumulating PDF path (optional)
%   mv          [nFrames x 2]        rigid-alignment displacements (optional)
%
% OUTPUTS:
%   dfofInterp  cleaned dF/F (bad frames set to NaN)
%   meanImg     recomputed from good frames only
%   greenframe  updated mean image (2x upsampled) from good frames
%   mv          input mv with bad-frame rows set to NaN

display('doing correlation-based zbinning')

%%% DIAGNOSTIC: warn if dfofInterp already contains NaN frames.
%%% A non-zero count means the workspace was not cleared between runs --
%%% clear the workspace and reload data before re-running.
nNaNFrames = sum(squeeze(any(any(isnan(dfofInterp), 1), 2)));
if nNaNFrames > 0
    fprintf('WARNING zbinCorr_DR: dfofInterp has %d NaN frame(s) on entry.\n', nNaNFrames);
    fprintf('  Likely cause: workspace not cleared between script runs.\n');
    fprintf('  Clear workspace (or reload from .mat/.sbx) for a clean result.\n');
else
    fprintf('zbinCorr_DR: dfofInterp clean -- %d frames, 0 NaN frames.\n', size(dfofInterp,3));
end

%%% Recreate small version of absolute fluorescence
F = (1 + dfofInterp).*repmat(meanImg,[1 1 size(dfofInterp,3)]);

%%% Resize and compute per-frame correlation (crop edges for boundary effects)
smallDf   = imresize(F(50:350,50:350,:), 1/2);
nanmedianPath = fileparts(which('nanmedian'));
if ~isempty(nanmedianPath); rmpath(nanmedianPath); end
smallMean = nanmedian(smallDf, 3);
if ~isempty(nanmedianPath); addpath(nanmedianPath); end
figure
imagesc(smallMean);

dist = zeros(1, size(smallDf,3));
for i = 1:size(smallDf,3)
    im = smallDf(:,:,i);
    cc = corrcoef(im(:), smallMean(:));
    dist(i) = cc(2,1);
end

%%% DIAGNOSTIC: print dist statistics so we can compare with original zbinCorr
fprintf('zbinCorr_DR: dist stats -- mean=%.4f  median=%.4f  min=%.4f  max=%.4f\n', ...
    mean(dist), median(dist), min(dist), max(dist));
fprintf('zbinCorr_DR: smallMean stats -- mean=%.4f  std=%.4f  min=%.4f  max=%.4f\n', ...
    mean(smallMean(:)), std(smallMean(:)), min(smallMean(:)), max(smallMean(:)));

figure
plot(dist), ylim([0 1]); title('correlation with median')

if isfield(Opt,'binningThresh')
    ccthresh = Opt.binningThresh;
else
    ccthresh = input('enter correlation threshold : ');
end

figure
plot(dist); ylim([0 1])
title('correlation of images with median'); xlabel('frame'); ylabel('corr coef')
hold on
plot([1 length(dist)], [ccthresh ccthresh], 'r:');
if exist('psfile','var') && ~isempty(psfile)
    exportgraphics(gcf, psfile, 'Append', true);
end

%%% Apply threshold
useframes = dist > ccthresh;
fprintf('zbinCorr_DR: threshold=%.4f  frames above=%.0f/%.0f  used=%.4f\n', ...
    ccthresh, sum(useframes), numel(useframes), mean(useframes));
figure
imagesc(mean(F(:,:,dist>ccthresh), 3));
title(sprintf('mean of frames above thresh %0.2f used', mean(useframes)));

display('redoing dfofinterp')
meanImg    = median(F(:,:,useframes(3:3:end)), 3);
F0         = repmat(meanImg,[1 1 size(F,3)]);
dfofInterp = (F - F0) ./ F0;
dfofInterp(isnan(dfofInterp)) = 0;

dfofInterp(:,:,~useframes) = NaN;

%%% Null bad-frame rows in mv if supplied
if nargin >= 6 && ~isempty(mv)
    mv(~useframes,:) = NaN;
end

greenframe = imresize(median(F(:,:,useframes),3), 2);

figure
rng = [prctile(greenframe(:),1)  prctile(greenframe(:),98)*1.2];
if rng(2) <= rng(1)
    rng(2) = rng(1) + max(1, abs(rng(1))*0.01);
end
imagesc(greenframe, rng); colormap gray
title(sprintf('mean of binned thresh = %0.2f used %0.2f', ccthresh, mean(useframes)))
if exist('psfile','var') && ~isempty(psfile)
    exportgraphics(gcf, psfile, 'Append', true);
end
