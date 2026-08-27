%% pixPlotWeight_DR.m  v1.1 — 2026-05-19
% Green-anatomy-weighted pixel response maps and weighted trial timecourses.
%
% PURPOSE:
%   Identical in structure to pixPlot.m, but uses green-fluorescence-weighted
%   versions of the pixel images and timecourses. Weighting by the anatomy image
%   suppresses responses in dim/non-tissue regions and emphasizes signals in
%   bright (tissue-rich) areas.
%
%   Produces two figures, both printed to the PDF:
%   (1) A grid of green-weighted pixel response images   (Fig N)
%   (2) A grid of green-weighted trial timecourses       (Fig N+1)
%
% This script is called as a script (not a function), reading/writing the
% calling workspace directly.
%
% REQUIRED WORKSPACE VARIABLES (must be set before calling pixPlotWeight_DR):
%   figNum       - integer figure counter managed by the calling script.
%                  On entry: figNum holds the number for the weighted pixel map figure.
%                  This script reads figNum (for pixFig) and figNum+1 (for traceFig).
%                  This script does NOT modify figNum.
%                  Caller pattern:  figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;
%   trialmean    - [Y x X x nTrials] pixel-wise mean dF/F per trial
%   weightTcourse- [T x nTrials] anatomy-weighted, spatially-averaged timecourse per trial
%   normgreen    - [Y x X x 3] normalized green anatomy image (RGB, values 0-1)
%   stimOrder    - [1 x nTrials] stimulus condition index for each trial
%   figLabel     - string label for both figure windows
%   npanel       - number of conditions to plot
%   nrow         - number of subplot rows
%   ncol         - number of subplot columns
%   loc          - [1 x npanel] mapping from condition index to subplot position
%   offset       - integer offset to add to condition index
%   range        - [1 x 2] colormap/y-axis limits [min max]
%   psfile       - (optional) path to output PDF file for appending
%
% figNum SCHEME (this script does NOT modify figNum):
%   Caller pattern:  figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;
%   On entry:  figNum = N    → used for pixFig  (weighted pixel map)
%   At export: figNum+1 = N+1 → used for traceFig (weighted timecourses)
%   The caller's trailing increment runs after this script returns, so
%   figNum+1 is computed here at export time.
%
% FIGURE NAMES:
%   pixFig   window Name: 'Fig N   - <figLabel>: Weighted Pixel Map'
%   traceFig window Name: 'Fig N+1 - <figLabel>: Weighted Trial Timecourses'

% ---- Figure 1 of 2: Weighted Pixel Map (Fig N) ----
% figNum was pre-incremented by the caller. Use it directly for the pixel map figure.
pixFig = figure('Name', sprintf('Fig %d - %s: Weighted Pixel Map', figNum, figLabel));

% ---- Figure 2 of 2: Weighted Trial Timecourses (Fig N+1) ----
% The caller will do 'figNum = figNum + 1' AFTER this script returns (trailing increment).
% Pre-compute that label now so traceFig gets the correct Fig number on both the
% window Name and the sgtitle, keeping them in sync with the PDF page order.
traceFig = figure('Name', sprintf('Fig %d - %s: Weighted Trial Timecourses', figNum + 1, figLabel));

% Get number of frames per trial timecourse
tl = size(trialTcourse, 1);

% Loop over each condition in the current panel
for i = (1:npanel) + offset

    % --- Weighted Pixel Map Panel ---
    % Compute median pixel-wise mean response image for this condition.
    meanimg = median(trialmean(:,:,stimOrder==i), 3, 'omitnan');

    figure(pixFig);
    subplot(nrow, ncol, loc(i-offset));

    % Convert response image to RGB using jet colormap and the specified range,
    % then multiply element-wise by the normalized green image (downsampled 0.5x).
    % This weights each pixel's color by how bright that pixel is in the anatomy,
    % emphasizing responses in tissue-rich areas.
    data_im = mat2im(meanimg, jet, range);
    imshow(imresize(data_im .* normgreen, 0.5));
    axis equal; axis off; colormap jet

    % --- Weighted Timecourse Panel ---
    % Plot all individual weighted trial timecourses for this condition,
    % then overlay the median in green.
    % weightTcourse is the anatomy-weighted version of trialTcourse.
    figure(traceFig);
    subplot(nrow, ncol, loc(i-offset));
    set(gcf, 'defaultAxesColorOrder', jet(sum(stimOrder==i)));
    plot(1:tl, weightTcourse(:, stimOrder==i));                          % individual trials
    hold on;
    plot(median(weightTcourse(:, stimOrder==i), 2, 'omitnan'), 'g', 'Linewidth', 2);  % median in green
    xlim([1 tl]);
    ylim(range/2);

end

% ---- FIGURE (Fig N): Weighted Pixel Map ----
% Green-anatomy-weighted pixel response images per condition.
% Colormap: jet; scale: range. Weighted by normgreen anatomy image.
figure(pixFig);
% colorbar;
sgtitle(sprintf('Fig %d: %s: Weighted Pixel Map', figNum, figLabel), 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE (Fig N+1): Weighted Trial Timecourses ----
% Grid of green-anatomy-weighted trial timecourses, one subplot per condition.
% Each colored line = one trial. Green line = median timecourse.
% figNum+1 here matches the caller's trailing increment that runs after this script
% returns — so PDF page N+1 and window Name 'Fig N+1' will agree.
figure(traceFig);
sgtitle(sprintf('Fig %d: %s: Weighted Trial Timecourses', figNum + 1, figLabel), 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
