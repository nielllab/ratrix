%% pixPlot.m
% Pixel-wise mean response maps and individual trial timecourses per stimulus condition.
%
% PURPOSE:
%   For each stimulus condition in a subset of conditions, produces:
%   (1) A grid of pixel-wise mean dF/F response images (one per condition).
%   (2) A grid of individual trial timecourses (one per condition),
%       with the median timecourse overlaid in green.
%   Both figures are printed to the PDF.
%
% This script is called as a script (not a function), so it reads and writes
% directly from the calling workspace.
%
% REQUIRED WORKSPACE VARIABLES (must be set before calling pixPlot):
%   trialmean    - [Y x X x nTrials] pixel-wise mean dF/F per trial (spatially smoothed)
%   trialTcourse - [T x nTrials] spatially-averaged dF/F timecourse per trial
%   stimOrder    - [1 x nTrials] stimulus condition index for each trial
%   figLabel     - string label for both figure windows (Name property)
%   npanel       - number of conditions to plot
%   nrow         - number of subplot rows
%   ncol         - number of subplot columns
%   loc          - [1 x npanel] mapping from condition index to subplot position
%   offset       - integer offset to add to condition index (for multi-block stimuli)
%   range        - [1 x 2] colormap/y-axis limits [min max]
%   gratingTitle - 1 to add SF/orientation labels to subplot titles, 0 to skip
%   psfile       - (optional) path to PostScript output file for appending
%
% OPTIONAL WORKSPACE VARIABLES:
%   freq         - [1 x nstim] spatial frequency per condition (for gratingTitle)
%   orient       - [1 x nstim] orientation per condition (for gratingTitle)
%   titles       - cell array of custom title strings per condition
%
% OUTPUTS (figures printed to psfile):
%   pixFig   - figure handle: grid of pixel-wise mean response images
%   traceFig - figure handle: grid of individual trial timecourses
%
% FIGURE NAMES:
%   Both figures are named with figLabel (set in calling script).
%   The pixel map figure is titled "figLabel: Pixel Map"
%   The timecourse figure is titled "figLabel: Trial Timecourses"

% Create the two output figures and assign names for identification
pixFig   = figure; set(gcf, 'Name', figLabel);   % pixel-wise response map figure
traceFig = figure; set(gcf, 'Name', figLabel);   % trial timecourse figure

% Get the number of frames in each trial timecourse
tl = size(trialTcourse, 1);

% Loop over each condition in the current panel (e.g., conditions 1:npanel, offset by offset)
for i = (1:npanel) + offset

    % --- Pixel Map Panel ---
    % Compute the median pixel-wise mean response image across all presentations
    % of this stimulus condition. Median is more robust to outlier trials.
    meanimg = median(trialmean(:,:,stimOrder==i), 3, 'omitnan');

    figure(pixFig);
    subplot(nrow, ncol, loc(i-offset));   % place in correct grid position
    imagesc(meanimg, range);              % display with fixed color scale
    axis equal; axis off;                 % equal pixel aspect, no axes
    colormap jet;

    % Optionally add grating parameter label (SF and orientation) to subplot title
    if gratingTitle && exist('freq','var')
        title(sprintf('theta %0.0f sf %0.2f', orient(i), freq(i)), 'Fontsize', 8);
    end

    % Optionally use custom title strings if provided
    if exist('titles','var')
        title(titles{i})
    end

    % --- Timecourse Panel ---
    % Plot all individual trial timecourses for this condition (colored by trial number),
    % then overlay the median timecourse in green.
    figure(traceFig);
    subplot(nrow, ncol, loc(i-offset));
    set(gcf, 'defaultAxesColorOrder', jet(sum(stimOrder==i)));   % color each trial differently
    plot(1:tl, trialTcourse(:, stimOrder==i));                    % individual trial timecourses
    hold on;
    plot(median(trialTcourse(:, stimOrder==i), 2, 'omitnan'), 'g', 'Linewidth', 2);  % median in green
    xlim([1 tl]);
    ylim(range/2);   % y-axis range is half the colormap range (timecourses are smaller signal)

end

% ---- FIGURE (figLabel): Pixel Map ----
% Grid of pixel-wise mean dF/F response images, one per stimulus condition.
% Colormap: jet; scale: range. Subplots arranged spatially per stim layout.
figure(pixFig);
% colorbar;   % (commented out - uncomment to add shared colorbar)
sgtitle([figLabel ': Pixel Map'], 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE (figLabel): Trial Timecourses ----
% Grid of individual trial timecourses, one subplot per stimulus condition.
% Each colored line = one trial. Green line = median timecourse.
figure(traceFig);
sgtitle([figLabel ': Trial Timecourses'], 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
