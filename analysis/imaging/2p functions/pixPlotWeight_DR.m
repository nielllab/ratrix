%% pixPlotWeight.m
% Green-anatomy-weighted pixel response maps and weighted trial timecourses.
%
% PURPOSE:
%   Identical in structure to pixPlot.m, but uses green-fluorescence-weighted
%   versions of the pixel images and timecourses. Weighting by the anatomy image
%   suppresses responses in dim/non-tissue regions and emphasizes signals in
%   bright (tissue-rich) areas.
%
%   Produces two figures, of which ONE is printed to the PDF:
%   (1) A grid of green-weighted pixel response images  [NOT printed — display only]
%   (2) A grid of green-weighted trial timecourses      [printed to PDF]
%
% This script is called as a script (not a function), reading/writing the
% calling workspace directly.
%
% REQUIRED WORKSPACE VARIABLES (must be set before calling pixPlotWeight_DR):
%   figNum       - integer figure counter managed by the calling script.
%                  On entry: figNum holds the number for the (sole) exported figure.
%                  This script reads figNum but does NOT modify it.
%                  Caller pattern:  figNum = figNum + 1; pixPlotWeight_DR;
%                  (No trailing increment — only 1 figure is exported.)
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
%   psfile       - (optional) path to PostScript output file
%
% figNum SCHEME (this script does NOT modify figNum):
%   Caller pattern:  figNum = figNum + 1; pixPlotWeight_DR;
%   On entry:  figNum = N  → used for traceFig label (the sole exported figure)
%   pixFig is created for display only and carries no Fig N label.
%
% FIGURE NAMES:
%   pixFig   window Name: '<figLabel>: Weighted Pixel Map (not printed)'
%   traceFig window Name: 'Fig N - <figLabel>: Weighted Trial Timecourses'

% ---- Figure 1 of 2: Weighted Pixel Map (display only, NOT exported) ----
% No Fig N label — this figure is not printed to the PDF.
pixFig = figure('Name', sprintf('%s: Weighted Pixel Map (not printed)', figLabel));

% ---- Figure 2 of 2: Weighted Trial Timecourses (Fig N — the sole export) ----
% figNum was pre-incremented by the caller and is used here for the exported figure.
traceFig = figure('Name', sprintf('Fig %d - %s: Weighted Trial Timecourses', figNum, figLabel));

% Get number of frames per trial timecourse
tl = size(trialTcourse, 1);

% Loop over each condition in the current panel
for i = (1:npanel) + offset

    % --- Weighted Pixel Map Panel (display only) ---
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

% ---- FIGURE (not printed): Weighted Pixel Map ----
% Green-anatomy-weighted pixel response images per condition.
% This figure is created for interactive inspection but is NOT exported to the PDF.
% colorbar;

% ---- FIGURE (Fig N): Weighted Trial Timecourses ----
% Grid of green-anatomy-weighted trial timecourses, one subplot per condition.
% Each colored line = one trial. Green line = median timecourse.
figure(traceFig);
sgtitle(sprintf('Fig %d: %s: Weighted Trial Timecourses', figNum, figLabel), 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
