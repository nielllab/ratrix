function [dfofInterp, meanImg, greenframe, figNum] = subtractSidebandNoise_DR(dfofInterp, meanImg, psfile, mv, figNum)
% subtractSidebandNoise_DR  v1.0 — 2026-05-19
% Remove sideband (out-of-focus z-plane) noise from dF/F.
%
% Estimates noise from the image sidebands (left/right edge columns, which contain
% out-of-focus signal rather than in-focus tissue), then subtracts a row-wise
% version of that noise from every frame.
%
% USAGE:
%   [dfofInterp, meanImg, greenframe, figNum] = ...
%       subtractSidebandNoise_DR(dfofInterp, meanImg, psfile, mv, figNum)
%
% INPUTS:
%   dfofInterp  [nY x nX x nFrames]  dF/F movie
%   meanImg     [nY x nX]            baseline fluorescence image
%   psfile      char                 accumulating PDF path (optional)
%   mv          [nFrames x 2]        rigid-alignment displacements
%   figNum      integer              figure counter from calling script
%
% OUTPUTS:
%   dfofInterp  noise-corrected dF/F movie
%   meanImg     unchanged (returned for signature consistency)
%   greenframe  new mean image computed from noise-corrected data
%   figNum      updated figure counter (incremented by number of exports)
%
% FIGURES EXPORTED (2):
%   Fig N  : Sideband Noise Heatmap — row x frame image of estimated noise
%   Fig N+1: Sideband Noise Trace   — mean noise per frame over time

display('subtracting off noise')

% Reconstruct absolute fluorescence from dF/F and baseline
F = (1 + dfofInterp) .* repmat(meanImg, [1 1 size(dfofInterp, 3)]);

% Estimate noise from sideband columns (edges = out-of-focus signal)
offset = squeeze(mean(F(:, [1:20 end-20:end], :), 2, 'omitnan'));
offset = offset - median(offset(:));
offset(:, abs(mv(:,2)) > 20) = 0;   % zero out frames with large y-displacement

% ---- FIGURE: Sideband Noise Heatmap (Fig N) ----
% Row-by-frame image of estimated sideband noise. Reveals structured noise
% (e.g. z-plane bleed) as horizontal bands. Used to verify subtraction is sensible.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Sideband Noise Heatmap', figNum));
imagesc(offset); colorbar;
title(sprintf('Fig %d: Sideband Noise Heatmap', figNum));
xlabel('frame'); ylabel('row');
if exist('psfile','var') && ~isempty(psfile)
    exportgraphics(gcf, psfile, 'Append', true);
end

% ---- FIGURE: Sideband Noise Trace (Fig N+1) ----
% Mean noise per frame over the full recording. Reveals temporal drift or
% sudden z-jumps in the sideband signal.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Sideband Noise Trace', figNum));
plot(mean(offset, 1, 'omitnan'));
xlabel('frame'); ylabel('sideband value');
title(sprintf('Fig %d: Sideband Noise Trace', figNum));
if exist('psfile','var') && ~isempty(psfile)
    exportgraphics(gcf, psfile, 'Append', true);
end

% Subtract noise: broadcast row-wise offset across x-dimension
offset_full = repmat(offset, [1 1 size(F, 2)]);
offset_full = permute(offset_full, [1 3 2]);

% Recompute dF/F from noise-corrected fluorescence
F_fix      = F - offset_full;
greensmall = median(F_fix(:,:,5:5:end), 3, 'omitnan');
F0         = repmat(greensmall, [1 1 size(dfofInterp, 3)]);

greenframe = imresize(greensmall, 2);
dfofInterp = (F_fix - F0) ./ F0;
