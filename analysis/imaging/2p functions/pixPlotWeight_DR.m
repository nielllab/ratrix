%% pixPlotWeight.m
% Green-anatomy-weighted pixel response maps and weighted trial timecourses.
%
% PURPOSE:
%   Identical in structure to pixPlot.m, but uses green-fluorescence-weighted
%   versions of the pixel images and timecourses. Weighting by the anatomy image
%   suppresses responses in dim/non-tissue regions and emphasizes signals in
%   bright (tissue-rich) areas.
%
%   Produces two figures:
%   (1) A grid of green-weighted pixel response images (printed to PDF).
%   (2) A grid of green-weighted trial timecourses (printed to PDF).
%
% This script is called as a script (not a function), reading/writing the
% calling workspace directly.
%
% REQUIRED WORKSPACE VARIABLES (must be set before calling pixPlotWeight):
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

% Create the two output figures
pixFig   = figure; set(gcf, 'Name', figLabel);   % green-weighted pixel map figure
traceFig = figure; set(gcf, 'Name', figLabel);   % green-weighted timecourse figure

% Get number of frames per trial timecourse
tl = size(trialTcourse, 1);

% Loop over each condition in the current panel
for i = (1:npanel) + offset

    % --- Weighted Pixel Map Panel ---
    % Compute median pixel-wise mean response image for this condition
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

% ---- FIGURE (figLabel): Weighted Pixel Map ----
% Green-anatomy-weighted pixel response images per condition.
figure(pixFig);
% colorbar;
sgtitle([figLabel ': Weighted Pixel Map'], 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE (figLabel): Weighted Trial Timecourses ----
% Grid of green-anatomy-weighted trial timecourses, one subplot per condition.
% Each colored line = one trial. Green line = median timecourse.
figure(traceFig);
sgtitle([figLabel ': Weighted Trial Timecourses'], 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
