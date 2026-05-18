%% getOctoCells.m
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
%   Opt          - options struct (may contain selectPts, s2p_fname, mindF, selectCrop)
%   dfofInterp   - [Y x X x T] dF/F movie (temporally resampled)
%   greenCrop    - [Y x X] mean green fluorescence image (cropped, double)
%   greenFig     - figure handle to green channel image (for manual mode)
%   maxFig       - figure handle to max dF/F image (for manual mode)
%   mergeFig     - figure handle to merge image (for manual mode)
%   pts_range    - range of pixel offsets for averaging around each ROI center
%   startTrim    - frame index used to align suite2p fluorescence with dfofInterp
%   psfile       - (optional) path to PostScript output file
%
% OUTPUTS (returned to calling workspace):
%   dF      - [nCells x T] dF/F traces for selected ROIs
%   x, y    - pixel x/y coordinates of each ROI center
%   xpts, ypts - copies of x, y (renamed for downstream compatibility)
%
% ADDITIONAL OUTPUTS (suite2p modes only):
%   F       - [nCells x T] raw fluorescence traces (good cells only)
%   stat    - cell array of suite2p ROI stat structs (good cells only)
%   ncells  - number of accepted cells
%   goodcells - indices of accepted cells in original suite2p ordering


%% =========================================================================
%% MODE SELECTION
%% =========================================================================

% Read selection mode from Opt struct, or prompt user if not specified
if isfield(Opt,'selectPts')
    selectPts = Opt.selectPts;
else
    selectPts = input('select points automatically (0) by hand (1) or suite2p (2) or red/green suite2p (3): ');
end


%% =========================================================================
%% MODE 1: MANUAL SELECTION
%% =========================================================================

if selectPts == 1

    % Ask which reference image to use for clicking
    chooseFig = input('select based on 1) mean image, 2) max image, 3) merge image : ');

    if chooseFig == 1
        selectFig = greenFig;    % mean green fluorescence
    elseif chooseFig == 2
        selectFig = maxFig;      % max dF/F
    else
        selectFig = mergeFig;    % red/green merge
    end

    % Range of pixels around each clicked point for averaging
    range = -2:2;
    clear x y npts
    rightclick = 0;

    fprintf('Select points on image. Rightclick to exit interactive ginput');
    i = 0;
    while rightclick ~= 3
        i = i + 1;
        figure(selectFig); hold on
        [x(i), y(i), rightclick] = ginput(1);    % get one click at a time
        x = round(x); y = round(y);
        plot(x(i), y(i), 'b*');                   % mark the selected point

        % Extract dF/F trace for this point as mean over a 5x5 pixel box
        dF(i,:) = squeeze(mean(mean(dfofInterp(y(i)+range, x(i)+range, :), 2, 'omitnan'), 1, 'omitnan'));
    end


%% =========================================================================
%% MODE 0: AUTOMATIC PEAK DETECTION
%% =========================================================================

elseif selectPts == 0

    %% --- Find local fluorescence peaks ---

    % Use the mean green channel image (anatomy) as the source image for peak detection
    img = greenCrop;
    img(isnan(img(:))) = 0;
    img(isinf(img(:))) = 0;

    % Smooth image to reduce pixel-level noise before peak detection
    filt  = fspecial('gaussian', 5, 1);
    stdImg = imfilter(img, filt);

    % Show smoothed image for visual reference (not printed)
    figure
    imagesc(stdImg); colormap gray

    % Local maximum detection: a pixel is a peak if it is greater than all
    % pixels in its 3x3 neighborhood (excluding itself), using morphological dilation.
    region = ones(3,3); region(2,2) = 0;   % 3x3 neighborhood mask, center excluded
    maxStd = stdImg > imdilate(stdImg, region);

    % Remove peaks within 3 pixels of any edge (these may be artifacts)
    maxStd(1:3,:) = 0; maxStd(end-2:end,:) = 0;
    maxStd(:,1:3) = 0; maxStd(:,end-2:end) = 0;

    pts = find(maxStd);   % linear indices of all detected peaks
    fprintf('%d max points\n', length(pts));

    % Show all detected peaks overlaid on the smoothed image (not printed)
    [y, x] = ind2sub(size(maxStd), pts);
    figure
    imagesc(stdImg, [0 prctile(stdImg(:),98)]); hold on; colormap gray
    plot(x, y, 'o');


    %% --- Crop to region of interest ---

    % Optionally restrict analysis to a user-selected crop region
    if isfield(Opt,'selectCrop') && Opt.selectCrop == 1
        disp('Select area in figure to include in the analysis');
        [xrange, yrange] = ginput(2);   % user draws a rectangle
        pts = pts(x>xrange(1) & x<xrange(2) & y>yrange(1) & y<yrange(2));
    else
        % Default: exclude border pixels based on pts_range
        b = pts_range(end) + 1;
        xrange = [b size(img,2)-b];
        yrange = [b size(img,1)-b];
        pts = pts(x>xrange(1) & x<xrange(2) & y>yrange(1) & y<yrange(2));
    end


    %% --- Rank by brightness and apply threshold ---

    % Sort remaining peaks by their brightness in the green image (descending)
    [brightness, order] = sort(img(pts), 1, 'descend');

    % ---- FIGURE: ROI Point Brightness Cutoff ----
    % Line plot of brightness vs. rank order for all detected peaks.
    % A horizontal blue line marks the user-defined cutoff threshold (mindF).
    % Title shows how many points remain above the cutoff.
    % Used to choose a cutoff that includes bright (likely responsive) pixels
    % while excluding dim background pixels.
    figure
    plot(brightness); xlabel('N'); ylabel('brightness');

    fprintf('%d points in ROI\n', length(pts))

    % Get brightness threshold from Opt or prompt user
    if isfield(Opt,'mindF')
        mindF = Opt.mindF;
    else
        mindF = input('dF cutoff : ');
    end

    % Apply threshold: keep only peaks brighter than mindF
    pts = pts(img(pts) > mindF);
    fprintf('%d points in ROI over cutoff\n', length(pts))

    % Add cutoff line to brightness plot and print
    hold on
    plot([1 length(brightness)], [mindF mindF], 'b');
    title(sprintf('%d points in ROI over cutoff\n', length(pts)))
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


    %% --- Show selected points and extract dF/F traces ---

    [y, x] = ind2sub(size(maxStd), pts);

    % ---- FIGURE: Selected ROI Points ----
    % Smoothed green image with circles marking all selected ROI centers.
    % Title shows the pts_range used. Useful for verifying that ROIs are
    % distributed across the tissue as expected.
    figure
    imagesc(stdImg, [0 prctile(stdImg(:),98)]); hold on; colormap gray
    plot(x, y, 'o'); title(sprintf('df pts_range %d', pts_range(end)))
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % Extract dF/F trace for each selected point:
    % average dfofInterp over a small box (pts_range x pts_range) around each center
    clear dF
    for i = 1:length(x)
        dF(i,:) = mean(mean(dfofInterp(y(i)+pts_range, x(i)+pts_range, :), 2), 1);
    end

    % Rename x/y so they don't get overwritten by subsequent ginput calls
    xpts = x; ypts = y;


%% =========================================================================
%% MODE 2 / 3: SUITE2P ROI SELECTION
%% =========================================================================

elseif selectPts == 2 || selectPts == 3

    %% --- Load suite2p output ---

    % Load suite2p .mat file (contains F, F_chan2, iscell, stat, ops)
    if isfield(Opt,'s2p_fname')
        load(Opt.s2p_fname)
    else
        [s2p_file, s2p_path] = uigetfile('*.mat', 'suite2p .mat file');
        iscell = 0;   % initialize iscell to avoid MATLAB treating it as a function
        load(fullfile(s2p_path, s2p_file));
    end

    % Trim fluorescence matrix to start from the same frame as dfofInterp
    % (removes pre-stimulus frames)
    F = F(:, startTrim:end);

    % Compute mean fluorescence for all cells classified as good (iscell(:,1)==1)
    meanF = mean(F(find(iscell(:,1)),:), 2);

    % ---- FIGURE: Suite2p Cell Classifier Scores ----
    % Histogram of iscell(:,2) confidence scores for all detected ROIs.
    % Title shows total ROI count and number classified as good cells.
    % Use this to verify the classifier is separating cells from non-cells.
    figure
    hist(iscell(:,2)); xlabel('iscell'); ylabel('n')
    title(sprintf('n = %d good = %d', length(iscell), sum(iscell(:,1))));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % Downsample the mean image by 2x (to match the spatial resolution of dfofInterp)
    stdImg = imresize(ops.meanImg, 0.5);   % changed from max_proj on 121224

    %% --- Visualize all masks colored by iscell score (not printed) ---

    % Build an RGB image where each pixel's color reflects its ROI's iscell confidence.
    % (Not printed - for interactive inspection only.)
    img = zeros(size(ops.meanImg,1), size(ops.meanImg,2), 3);
    cols = jet(100);
    for c = 1:length(iscell)
        xpix = stat{c}.xpix;
        ypix = stat{c}.ypix;
        lam  = stat{c}.lam;     % pixel weights from suite2p (lambda)
        for i = 1:length(xpix)
            img(ypix(i), xpix(i), :) = cols(ceil(iscell(c,2)*100), :) * lam(i)/max(lam);
        end
    end
    figure
    imshow(img);
    title('masks coded by iscell'); colormap jet; colorbar


    %% --- Select good cells ---

    % Accept cells where iscell score > 0.2 AND mean fluorescence > 50% of median.
    % This two-criterion filter catches cells that suite2p is reasonably confident
    % about AND that have sufficient fluorescence signal.
    % Note: the first goodcells line (using iscell(:,1)) is overwritten by the second.
    goodcells = find(iscell(:,1) & mean(F,2) > 0.5 * median(meanF));         % initial (overwritten)
    goodcells = find(iscell(:,2) > 0.2 & mean(F,2) > 0.5 * median(meanF));   % final criterion

    ncells = length(goodcells);   % number of accepted cells


    %% --- Diagnostic scatter plots (not printed) ---

    % iscell score vs. mean fluorescence (to inspect threshold placement)
    figure
    plot(iscell(:,2), mean(F,2), '.')
    hold on; plot([0 1], [0.5*median(meanF) 0.5*median(meanF)])

    % iscell score vs. noise (std of first-difference / mean fluorescence)
    figure
    plot(iscell(:,2), std(diff(F,[],2),[],2) ./ mean(F,2), '.')

    % iscell score vs. variability (std / mean fluorescence)
    figure
    plot(iscell(:,2), std(F,[],2) ./ mean(F,2), '.')


    %% --- Build good cell mask image ---

    % Create an RGB image with each good cell's mask colored by a cycling 6-color palette.
    % Also extract the centroid x/y coordinates for each good cell (downsampled by 2x
    % to match dfofInterp spatial resolution).
    cols = [1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];   % 6-color cycling palette
    img  = zeros(size(stdImg,1), size(stdImg,2), 3);

    for c = 1:ncells
        xpix = stat{goodcells(c)}.xpix;
        ypix = stat{goodcells(c)}.ypix;
        lam  = stat{goodcells(c)}.lam;

        % Store centroid (downsampled by 2x to match dfofInterp resolution)
        xpts(c) = round(mean(xpix)) / 2;
        ypts(c) = round(mean(ypix)) / 2;

        % Paint each pixel of this cell's mask with a cycling color
        for i = 1:length(xpix)
            img(ypix(i), xpix(i), :) = cols(mod(c,6)+1, :) * lam(i)/max(lam);
        end
    end
    x = xpts; y = ypts;   % rename for consistency with auto/manual modes

    % ---- FIGURE: Suite2p Max Projection ----
    % Max projection image from suite2p (ops.max_proj), normalized to [0, 1.5].
    % Used as a reference for ROI location. Printed at original (not downsampled) resolution.
    figure
    imshow(1.5 * ops.max_proj / max(ops.max_proj(:)));
    colormap gray; axis equal; title('max projection')
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE: Suite2p Good Cell Masks ----
    % RGB image of accepted cell masks, each colored by a 6-color cycling palette.
    % Title shows the number of accepted cells. Used to verify ROI coverage.
    figure
    imshow(img)
    title(sprintf('masks %d good cells', ncells))
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % Build a full-frame max projection image (padded to full ops.meanImg size)
    % using ops.yrange and ops.xrange to place the valid region correctly.
    maxProj = zeros(size(ops.meanImg));
    maxProj(ops.yrange(1):ops.yrange(2)-1, ops.xrange(1):ops.xrange(2)-1) = ops.max_proj;

    % Show full-frame max projection (not printed)
    figure
    imagesc(maxProj); colormap gray; axis equal


    %% --- Compute dF/F traces ---

    if selectPts == 2
        % Mode 2: standard dF/F = (F - mean(F)) / mean(F) for each good cell
        clear dF
        for c = 1:ncells
            dF(c,:) = (F(goodcells(c),:) - mean(F(goodcells(c),:))) / mean(F(goodcells(c,:)));
        end
        % Trim F and stat to good cells only
        F    = F(goodcells,:);
        stat = stat(goodcells);

    elseif selectPts == 3
        % Mode 3: red/green ratio dF/F = (F/F_chan2 - mean(ratio)) / mean(ratio)
        % Useful for ratiometric imaging where F_chan2 is a structural/reference channel.
        [s2p_redfile, s2p_path] = uigetfile('*.mat', 'red suite2p .mat file');
        iscell = 0;   % re-initialize
        load(fullfile(s2p_path, s2p_redfile));

        for c = 1:ncells
            greenred = F ./ F_chan2;   % green/red ratio per cell per frame
            dF(c,:) = (greenred(goodcells(c),:) - mean(greenred(goodcells(c),:))) / ...
                       mean(greenred(goodcells(c,:)));
        end
        % Store separated channel traces
        green = F(goodcells,:);
        red   = F_chan2(goodcells,:);
        F     = greenred(goodcells,:);
    end


    %% --- dF/F trace visualization ---

    % Clip extreme dF/F values
    dF(dF > 1) = 1;

    % Plot raw dF/F traces for a random subset of cells (not printed)
    % Each trace offset vertically by cell index for readability.
    figure
    hold on
    range = 1:min(3000, length(dF));
    dtr = 0.1;    % time resolution (sec/frame)
    np  = 32;     % number of cells to display
    for i = 1:np
        plot(range*dtr, 2*dF(ceil(rand*ncells), range) + i);
    end

    % Apply 5-frame median filter to smooth traces for k-means clustering
    dFmed = medfilt1(dF, 5);

    % Plot median-filtered traces for a larger subset (not printed)
    % Note: the loop below has a bug (uses dt instead of dtr), preserved from original.
    figure
    hold on
    range = 1:min(3000, length(dF));
    dtr = 0.1;
    np  = 64;
    for i = 1:np
        plot(range*dt, dF(i,range) + i);   % note: dt used here (may be from calling workspace)
    end

    % k-means clustering on median-filtered traces (for internal diagnostic use)
    nk = 5;
    k  = kmeans(dFmed, nk);

    % Plot k-means cluster mean timecourses with all member traces (not printed)
    figure
    for i = 1:nk
        dFk(i,:) = mean(dFmed(k==i,:), 1, 'omitnan');
        subplot(nk,1,i);
        plot(dFmed(k==i,:)');
        hold on
        plot(dFk(i,:), 'g', 'Linewidth', 2);
    end

    % Plot all cluster means overlaid (not printed)
    figure
    plot(dFk')

    % ---- FIGURE: Suite2p k-means Cluster Histogram ----
    % Histogram of k-means cluster assignments across all good cells.
    % The ylim/xlabel/ylabel/title printed here actually belongs to the hist(k) figure
    % (due to the ylim call that follows closing the dFmed loop above).
    % Printed because it is the last figure when psfile exists.
    figure
    hist(k)

    ylim([0 np+2])
    xlabel('secs'); ylabel('cell #'); title('dF/F')
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


    %% --- Show selected ROI centers on max projection (not printed) ---

    % Visualize the centroid locations of all accepted cells overlaid on the
    % full-frame max projection. Points are plotted at 2x coordinates (full resolution).
    figure
    imagesc(maxProj); colormap gray; axis equal
    hold on
    plot(x*2, y*2, '.')

end  % end if/elseif selectPts
