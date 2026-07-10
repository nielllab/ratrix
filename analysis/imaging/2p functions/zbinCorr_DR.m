function [dfofInterp, meanImg, greenframe, mv, figNum] = zbinCorr_DR(dfofInterp, meanImg, greenframe, Opt, psfile, mv, figNum)
% zbinCorr_DR  v1.1 — 2026-05-19
% Z-plane binning correction for octopus 2-photon data.
%
% Removes imaging frames whose pixel content is poorly correlated with the
% session median image (indicating the focal plane drifted to a different
% z-position). Frames below the correlation threshold are set to NaN in the
% dF/F stack, and meanImg/greenframe are recomputed from good frames only.
%
% USAGE:
%   [dfofInterp, meanImg, greenframe, mv, figNum] = ...
%       zbinCorr_DR(dfofInterp, meanImg, greenframe, Opt, psfile, mv, figNum)
%
% INPUTS:
%   dfofInterp  [nY x nX x nFrames]  dF/F movie
%   meanImg     [nY x nX]            baseline fluorescence image
%   greenframe  [nY x nX]            downsampled mean image
%   Opt         struct               Opt.binningThresh skips interactive prompt
%   psfile      char                 accumulating PDF path (optional)
%   mv          [nFrames x 2]        rigid-alignment displacements (optional)
%   figNum      integer              figure counter from calling script
%
% OUTPUTS:
%   dfofInterp  cleaned dF/F (bad frames set to NaN)
%   meanImg     recomputed from good frames only
%   greenframe  updated mean image (2x upsampled) from good frames
%   mv          input mv with bad-frame rows set to NaN
%   figNum      updated figure counter (incremented by number of exports)
%
% FIGURES EXPORTED (2):
%   Fig N  : Correlation Threshold — per-frame correlation with red threshold line
%   Fig N+1: Mean of Good Frames  — mean image from frames above threshold

display('doing correlation-based zbinning')

% Warn if dfofInterp already contains NaN frames (suggests workspace not cleared)
nNaNFrames = sum(squeeze(any(any(isnan(dfofInterp), 1), 2)));
if nNaNFrames > 0
    fprintf('WARNING zbinCorr_DR: dfofInterp has %d NaN frame(s) on entry.\n', nNaNFrames);
    fprintf('  Likely cause: workspace not cleared between runs. Reload data for a clean result.\n');
else
    fprintf('zbinCorr_DR: dfofInterp clean -- %d frames, 0 NaN frames.\n', size(dfofInterp,3));
end

% Reconstruct absolute fluorescence
F = (1 + dfofInterp) .* repmat(meanImg, [1 1 size(dfofInterp, 3)]);

% Compute per-frame correlation with session median (cropped to avoid edge effects)
smallDf   = imresize(F(50:350, 50:350, :), 1/2);
nanmedianPath = fileparts(which('nanmedian'));
if ~isempty(nanmedianPath); rmpath(nanmedianPath); end
smallMean = median(smallDf, 3, 'omitnan');
if ~isempty(nanmedianPath); addpath(nanmedianPath); end

dist = zeros(1, size(smallDf, 3));
for i = 1:size(smallDf, 3)
    im    = smallDf(:,:,i);
    cc    = corrcoef(im(:), smallMean(:));
    dist(i) = cc(2,1);
end

fprintf('zbinCorr_DR: dist  -- mean=%.4f  median=%.4f  min=%.4f  max=%.4f\n', ...
    mean(dist), median(dist), min(dist), max(dist));

% Get threshold from Opt or prompt user
if isfield(Opt,'binningThresh')
    ccthresh = Opt.binningThresh;
else
    % Show unlabeled preview figure to help user choose threshold (not exported)
    figure('Name', 'zbinCorr: correlation preview (not printed)');
    plot(dist); ylim([0 1]); title('correlation with median — choose threshold');
    ccthresh = input('enter correlation threshold : ');
end

% ---- FIGURE: Correlation Threshold (Fig N) ----
% Per-frame correlation with session median image.
% Red dashed line = threshold. Frames below threshold are excluded.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Z-Plane Correlation Threshold', figNum));
plot(dist); ylim([0 1]);
hold on; plot([1 length(dist)], [ccthresh ccthresh], 'r:');
xlabel('frame'); ylabel('corr coef');
title(sprintf('Fig %d: Z-Plane Correlation Threshold  (thresh = %.2f,  %.0f%% frames used)', ...
    figNum, ccthresh, 100*mean(dist > ccthresh)));
if exist('psfile','var') && ~isempty(psfile)
    exportgraphics(gcf, psfile, 'Append', true);
end

% Apply threshold: exclude frames below ccthresh
useframes = dist > ccthresh;
fprintf('zbinCorr_DR: threshold=%.4f  used %d/%d frames (%.1f%%)\n', ...
    ccthresh, sum(useframes), numel(useframes), 100*mean(useframes));

% Recompute dF/F using only good frames
meanImg    = median(F(:,:,useframes(3:3:end)), 3);
F0         = repmat(meanImg, [1 1 size(F, 3)]);
dfofInterp = (F - F0) ./ F0;
dfofInterp(isnan(dfofInterp)) = 0;
dfofInterp(:,:,~useframes) = NaN;

% Null bad-frame rows in mv
if nargin >= 6 && ~isempty(mv)
    mv(~useframes, :) = NaN;
end

greenframe = imresize(median(F(:,:,useframes), 3), 2);

% ---- FIGURE: Mean of Good Frames (Fig N+1) ----
% Mean fluorescence image computed from frames above threshold only.
% Verify that the resulting image looks like clean tissue (no motion blur).
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Z-Plane Mean of Good Frames', figNum));
rng = [prctile(greenframe(:),1)  prctile(greenframe(:),98)*1.2];
if rng(2) <= rng(1); rng(2) = rng(1) + max(1, abs(rng(1))*0.01); end
imagesc(greenframe, rng); colormap gray;
title(sprintf('Fig %d: Z-Plane Mean of Good Frames  (thresh = %.2f,  %.0f%% used)', ...
    figNum, ccthresh, 100*mean(useframes)));
if exist('psfile','var') && ~isempty(psfile)
    exportgraphics(gcf, psfile, 'Append', true);
end
