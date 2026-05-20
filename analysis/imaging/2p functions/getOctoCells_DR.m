%% getOctoCells_DR.m  v1.3 — 2026-05-19
% Selects ROI (region of interest) points from a 2-photon imaging dataset.
%
% PURPOSE:
%   Identifies cells or pixels to use as ROIs for further analysis.
%   Supports four selection modes, controlled by the selectPts variable.
%   After selection, extracts dF/F traces for each ROI from dfofInterp.
%
% SELECTION MODES:
%   0 = Automatic: detects local fluorescence peaks, ranks by brightness,
%       user sets a brightness threshold to filter them.
%   1 = Manual: user clicks on cells in a reference figure (green, max, or merge).
%   2 = suite2p: loads ROI masks and fluorescence from suite2p output (.mat file).
%   3 = suite2p red/green: same as mode 2 but uses F/F_chan2 (green/red) ratio for dF/F.
%
% This script is called as a script (not a function), reading/writing the
% calling workspace directly.
%
% REQUIRED WORKSPACE VARIABLES:
%   figNum       - integer figure counter. On entry, figNum is already set to the
%                  value for this script's first exported figure (caller pre-increments).
%                  This script increments figNum for each export.
%   Opt          - options struct (may contain selectPts, s2p_fname, mindF, selectCrop)
%   dfofInterp   - [Y x X x T] dF/F movie (temporally resampled)
%   greenCrop    - [Y x X] mean green fluorescence image (cropped, double)
%   greenFig     - figure handle to green channel image (for manual mode)
%   maxFig       - figure handle to max dF/F image (for manual mode)
%   mergeFig     - figure handle to merge image (for manual mode)
%   pts_range    - range of pixel offsets for averaging around each ROI center
%   startTrim    - frame index used to align suite2p fluorescence with dfofInterp
%   psfile       - (optional) path to output PDF file for appending
%
% OUTPUTS (returned to calling workspace):
%   dF      - [nCells x T] dF/F traces for selected ROIs
%   x, y    - pixel x/y coordinates of each ROI center
%   xpts, ypts - copies of x, y (renamed for downstream compatibility)
%   figNum  - updated figure counter
%
% ADDITIONAL OUTPUTS (suite2p modes only):
%   F, stat, ncells, goodcells
%
% FIGURES EXPORTED:
%   Mode 0/1: 2 figures
%     Fig N  : ROI Brightness Cutoff (mode 0); ROI Points on anatomy (mode 1, first view)
%     Fig N+1: Selected ROI Points (mode 0 and 1)
%   Mode 2/3: 4 figures
%     Fig N  : Suite2p Cell Classifier Scores
%     Fig N+1: Suite2p Max Projection
%     Fig N+2: Suite2p Good Cell Masks
%     Fig N+3: Suite2p k-means Cluster Histogram
%
% figNum SCHEME:
%   This script increments figNum for each export. On entry, figNum should be
%   at the last exported figure from the calling script. This script does NOT
%   expect the caller to pre-increment — it owns all its own increments.
%   On return, figNum reflects the last figure exported. The caller does NOT
%   advance figNum after this call.


%% =========================================================================
%% MODE SELECTION
%% =========================================================================

if isfield(Opt,'selectPts')
    selectPts = Opt.selectPts;
else
    selectPts = input('select points automatically (0) by hand (1) or suite2p (2) or red/green suite2p (3): ');
end


%% =========================================================================
%% MODE 1: MANUAL SELECTION
%% =========================================================================

if selectPts == 1

    chooseFig = input('select based on 1) mean image, 2) max image, 3) merge image : ');
    if     chooseFig == 1; selectFig = greenFig;
    elseif chooseFig == 2; selectFig = maxFig;
    else;                  selectFig = mergeFig;
    end

    range      = -2:2;
    rightclick = 0;
    clear x y
    fprintf('Select points on image. Rightclick to exit.\n');
    i = 0;
    while rightclick ~= 3
        i = i + 1;
        figure(selectFig); hold on
        [x(i), y(i), rightclick] = ginput(1);
        x = round(x); y = round(y);
        plot(x(i), y(i), 'b*');
        dF(i,:) = squeeze(mean(mean(dfofInterp(y(i)+range, x(i)+range, :), 2, 'omitnan'), 1, 'omitnan'));
    end

    % ---- FIGURE: ROI Brightness Cutoff placeholder (Fig N) ----
    % Mode 1 has no brightness cutoff step. Consume slot N with a labeled figure
    % so the page numbering stays consistent with mode 0 (which always exports 2 figs).
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - ROI Selection (Manual Mode)', figNum));
    imagesc(greenCrop, [0 prctile(greenCrop(:),98)]); colormap gray; hold on;
    plot(x, y, 'b*');
    title(sprintf('Fig %d: Selected ROI Points  (%d cells, manual)', figNum, length(x)));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE: Selected ROI Points (Fig N+1) ----
    % Second export slot matching mode 0's two-figure layout.
    % Shows the smoothed green image with ROI markers (same content, separate page).
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Selected ROI Points (Manual)', figNum));
    imagesc(greenCrop, [0 prctile(greenCrop(:),98)]); colormap gray; hold on;
    plot(x, y, 'b*', 'MarkerSize', 8);
    title(sprintf('Fig %d: Selected ROI Points  (%d cells, manual) — overlay', figNum, length(x)));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% MODE 0: AUTOMATIC PEAK DETECTION
%% =========================================================================

elseif selectPts == 0

    img = greenCrop;
    img(isnan(img)) = 0;
    img(isinf(img)) = 0;

    filt   = fspecial('gaussian', 5, 1);
    stdImg = imfilter(img, filt);

    % Local maximum detection
    region = ones(3,3); region(2,2) = 0;
    maxStd = stdImg > imdilate(stdImg, region);
    maxStd(1:3,:) = 0; maxStd(end-2:end,:) = 0;
    maxStd(:,1:3) = 0; maxStd(:,end-2:end) = 0;

    pts = find(maxStd);
    fprintf('%d max points\n', length(pts));
    [y, x] = ind2sub(size(maxStd), pts);

    % Crop to region of interest
    if isfield(Opt,'selectCrop') && Opt.selectCrop == 1
        disp('Select area in figure to include in the analysis');
        figure('Name', 'ROI Crop Selection (not printed)');
        imagesc(stdImg, [0 prctile(stdImg(:),98)]); colormap gray; hold on; plot(x, y, 'o');
        [xrange, yrange] = ginput(2);
    else
        b      = pts_range(end) + 1;
        xrange = [b size(img,2)-b];
        yrange = [b size(img,1)-b];
    end
    pts = pts(x>xrange(1) & x<xrange(2) & y>yrange(1) & y<yrange(2));

    % Rank by brightness
    [brightness, ~] = sort(img(pts), 1, 'descend');
    fprintf('%d points in ROI\n', length(pts));

    % Get brightness threshold
    if isfield(Opt,'mindF')
        mindF = Opt.mindF;
    else
        % Show unlabeled preview to help user choose cutoff (not exported)
        figure('Name', 'Brightness cutoff preview (not printed)');
        plot(brightness); xlabel('N'); ylabel('brightness');
        title('Brightness by rank — choose cutoff');
        mindF = input('dF cutoff : ');
    end

    pts = pts(img(pts) > mindF);
    fprintf('%d points in ROI over cutoff\n', length(pts));
    [y, x] = ind2sub(size(maxStd), pts);

    % ---- FIGURE: ROI Point Brightness Cutoff (Fig N) ----
    % Brightness vs. rank for all detected peaks; blue line = cutoff.
    % Title shows how many points are above the cutoff.
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - ROI Brightness Cutoff', figNum));
    plot(brightness); xlabel('N'); ylabel('brightness');
    hold on; plot([1 length(brightness)], [mindF mindF], 'b');
    title(sprintf('Fig %d: ROI Brightness Cutoff  (%d points above threshold)', figNum, length(pts)));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE: Selected ROI Points (Fig N+1) ----
    % Smoothed green image with selected ROI centers marked.
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Selected ROI Points', figNum));
    imagesc(stdImg, [0 prctile(stdImg(:),98)]); hold on; colormap gray;
    plot(x, y, 'o');
    title(sprintf('Fig %d: Selected ROI Points  (%d pts, range %d)', figNum, length(pts), pts_range(end)));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % Extract dF/F traces
    clear dF
    for i = 1:length(x)
        dF(i,:) = mean(mean(dfofInterp(y(i)+pts_range, x(i)+pts_range, :), 2, 'omitnan'), 1, 'omitnan');
    end
    xpts = x; ypts = y;


%% =========================================================================
%% MODE 2 / 3: SUITE2P ROI SELECTION
%% =========================================================================

elseif selectPts == 2 || selectPts == 3

    % Load suite2p output
    if isfield(Opt,'s2p_fname')
        load(Opt.s2p_fname)
    else
        [s2p_file, s2p_path] = uigetfile('*.mat', 'suite2p .mat file');
        iscell = 0;
        load(fullfile(s2p_path, s2p_file));
    end

    F      = F(:, startTrim:end);
    meanF  = mean(F(logical(iscell(:,1)),:), 2);

    % ---- FIGURE: Suite2p Cell Classifier Scores (Fig N) ----
    % Histogram of iscell(:,2) confidence scores for all detected ROIs.
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Suite2p Cell Classifier Scores', figNum));
    histogram(iscell(:,2)); xlabel('iscell score'); ylabel('n');
    title(sprintf('Fig %d: Suite2p Cell Classifier Scores  (n=%d, good=%d)', ...
        figNum, length(iscell), sum(iscell(:,1))));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    stdImg = imresize(ops.meanImg, 0.5);

    % Accept cells with iscell score > 0.2 AND mean fluorescence > 50% of median
    goodcells = find(iscell(:,2) > 0.2 & mean(F,2) > 0.5 * median(meanF));
    ncells    = length(goodcells);

    % Build good cell mask image (6-color cycling palette)
    cols = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
    img  = zeros(size(stdImg,1), size(stdImg,2), 3);
    for c = 1:ncells
        xpix = stat{goodcells(c)}.xpix + 1;   % suite2p uses 0-based pixel coords; +1 for MATLAB
        ypix = stat{goodcells(c)}.ypix + 1;
        lam  = stat{goodcells(c)}.lam;
        xpts(c) = round(mean(xpix - 1)) / 2;  % centre in original (0-based) space, then scale
        ypts(c) = round(mean(ypix - 1)) / 2;
        for i = 1:length(xpix)
            img(ypix(i), xpix(i), :) = cols(mod(c,6)+1, :) * lam(i)/max(lam);
        end
    end
    x = xpts; y = ypts;

    % ---- FIGURE: Suite2p Max Projection (Fig N+1) ----
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Suite2p Max Projection', figNum));
    imshow(1.5 * ops.max_proj / max(ops.max_proj(:))); colormap gray; axis equal;
    title(sprintf('Fig %d: Suite2p Max Projection', figNum));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE: Suite2p Good Cell Masks (Fig N+2) ----
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Suite2p Good Cell Masks', figNum));
    imshow(img);
    title(sprintf('Fig %d: Suite2p Good Cell Masks  (%d cells)', figNum, ncells));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % Compute dF/F traces
    if selectPts == 2
        clear dF
        for c = 1:ncells
            dF(c,:) = (F(goodcells(c),:) - mean(F(goodcells(c),:))) / mean(F(goodcells(c),:));
        end
        F    = F(goodcells,:);
        stat = stat(goodcells);
    elseif selectPts == 3
        [s2p_redfile, s2p_path] = uigetfile('*.mat', 'red suite2p .mat file');
        iscell = 0;
        load(fullfile(s2p_path, s2p_redfile));
        for c = 1:ncells
            greenred = F ./ F_chan2;
            dF(c,:) = (greenred(goodcells(c),:) - mean(greenred(goodcells(c),:))) / ...
                       mean(greenred(goodcells(c),:));
        end
        green = F(goodcells,:);
        red   = F_chan2(goodcells,:);
        F     = greenred(goodcells,:);
    end

    dF(dF > 1) = 1;

    % k-means clustering on median-filtered traces (for diagnostic use)
    dFmed = medfilt1(dF, 5);
    nk    = 5;
    k     = kmeans(dFmed, nk);
    for i = 1:nk
        dFk(i,:) = mean(dFmed(k==i,:), 1, 'omitnan');
    end

    % ---- FIGURE: Suite2p k-means Cluster Histogram (Fig N+3) ----
    % Histogram of k-means cluster assignments across all good cells.
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Suite2p k-means Cluster Histogram', figNum));
    histogram(k);
    xlabel('cluster'); ylabel('cell count');
    title(sprintf('Fig %d: Suite2p k-means Cluster Histogram  (%d cells, %d clusters)', ...
        figNum, ncells, nk));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

end  % end if/elseif selectPts
