function suite2pTracesStimOnset_AAClaude101226(fallMatPath, outPdfPath, varargin)
%SUITE2PTRACESSTIMONSET_AACLAUDE101226  Build a PDF of suite2p traces,
%   ranked by spike rate, with "slow rise" / non-neural-looking traces
%   removed, each page's cell masks overlaid on the mean image in
%   matching colors, and (optionally) stimulus onset times overlaid on
%   every trace panel.
%
%   This is generateActivityReport.m plus a stimulus-onset overlay: pass
%   'StimMatPath' to draw thin vertical lines at stimulus onset times,
%   read straight from a scanbox companion .mat file's digital sync
%   channel. Without 'StimMatPath' this behaves exactly like
%   generateActivityReport.m.
%
%   suite2pTracesStimOnset_AAClaude101226(fallMatPath, outPdfPath) loads
%   the suite2p output at fallMatPath (a Fall.mat file containing F,
%   spks, iscell, ops, stat) and writes a multi-page PDF to outPdfPath:
%       page 1 - explanation of the cell-selection methodology (and, if
%                a stim file was given, how the onset markers were found)
%       page 2 - mean image with every suite2p mask overlaid (muted
%                gray), plus NRandomCells randomly-chosen cells whose
%                centroid falls inside the tissue (the optic lobe, found
%                by thresholding the mean image), highlighted in color
%                with matching traces on the right - cells sitting in
%                the black background (stimulus-noise ROIs) are excluded
%       page 3 - cluster overview: mean image with masks for every cell
%                that passed both the slow-rise filter and the in-lobe
%                test, colored by cluster, plus a heatmap of all of
%                those cells' traces grouped by cluster. Clustering
%                follows sbxOctoNeural.m's approach (see below).
%       page 4+ - trace pages grouped by cluster (10 cells per page,
%                rainbow-colored per cell as before), each left panel
%                titled "N cells from cluster K". Any cluster with more
%                than CellsPerPage cells gets one extra page first,
%                showing ALL of that cluster's cells at once (however
%                many that is), individually rainbow-colored so each
%                trace matches its own mask, titled "All N cells in
%                cluster K"
%   Every page with a trace panel also gets the stimulus-onset lines,
%   drawn behind the traces (so the traces stay on top and readable),
%   with a note above the panel saying so, when 'StimMatPath' is given.
%   Each panel's x-axis is cut off shortly after the stimulus ends
%   (instead of padding to the full recording length) and its y-axis is
%   cut off shortly after the top trace's peak, so the panels are sized
%   to use their space rather than leaving blank margin.
%
%   suite2pTracesStimOnset_AAClaude101226(..., 'Name', Value, ...) allows:
%       'AnimalID'     - string shown in the page titles (default '')
%       'NPoolCells'   - how many of the top spike-rate "good cells" to
%                        consider before slow-rise filtering (default 360)
%       'CellsPerPage' - traces shown per page (default 10)
%       'VLFThresh'    - cells with more than this fraction of their
%                        spectral power below VLFCutoffHz are dropped as
%                        slow-rise / non-neural-looking (default 0.5)
%       'VLFCutoffHz'  - frequency cutoff defining "slow" (default 0.02)
%       'NRandomCells' - how many randomly-chosen, in-tissue cells to show
%                        on the page-2 overview (default 50)
%       'RandomSeed'   - seed for the page-2 random cell draw, so repeat
%                        runs can reproduce the same selection (default
%                        [], meaning "don't reseed, use whatever MATLAB's
%                        random state currently is")
%       'StimMatPath'  - path to the scanbox companion .mat file for this
%                        recording (the one next to the .sbx file, e.g.
%                        "100926_ASW150E28_000_007.mat"), whose "info"
%                        struct holds the digital sync channel used to
%                        find stimulus onset times. Default '' (empty),
%                        meaning no stimulus overlay is drawn.
%       'StimEventID'  - the info.event_id value that marks stimulus
%                        onset in that sync channel (default 5, matching
%                        this lab's scanbox rig wiring so far)
%       'StimEveryNth' - only draw every Nth onset, to avoid a cluttered
%                        plot when presentations are frequent/back-to-
%                        back (default 2, i.e. every other stimulus)
%       'StimEndBufferSec' - how many seconds past the last stimulus
%                        onset to keep visible on each trace panel's
%                        x-axis before cutting it off (default 10)
%       'NClusters'    - how many clusters to split the filtered, in-lobe
%                        cells into on page 3 onward (default 8), using
%                        the same clustering approach as sbxOctoNeural.m
%
%   Example (no stimulus overlay, same as generateActivityReport.m):
%       suite2pTracesStimOnset_AAClaude101226('D:\data\mouse42\Fall.mat', ...
%                               'D:\reports\mouse42_report.pdf', ...
%                               'AnimalID','mouse42');
%
%   Example (with stimulus onset overlay):
%       suite2pTracesStimOnset_AAClaude101226('D:\data\mouse42\Fall.mat', ...
%                               'D:\reports\mouse42_report.pdf', ...
%                               'AnimalID', 'mouse42', ...
%                               'StimMatPath', 'D:\data\mouse42\100926_ASW150E28_000_007.mat');
%
%   Requires the Signal Processing Toolbox (medfilt1, pwelch), the Image
%   Processing Toolbox (stdfilt/mat2gray/graythresh/imclose/imfill/
%   bwconncomp/imresize), the Statistics and Machine Learning Toolbox
%   (pdist/linkage/cluster - same as sbxOctoNeural.m already uses), and
%   MATLAB R2020a or newer (for exportgraphics 'Append').

% ---------------------------------------------------------------
% parse options
% ---------------------------------------------------------------
p = inputParser;
addParameter(p, 'AnimalID', '', @ischar);
addParameter(p, 'NPoolCells', 360, @isnumeric);
addParameter(p, 'CellsPerPage', 10, @isnumeric);
addParameter(p, 'VLFThresh', 0.5, @isnumeric);
addParameter(p, 'VLFCutoffHz', 0.02, @isnumeric);
addParameter(p, 'NRandomCells', 50, @isnumeric);
addParameter(p, 'RandomSeed', [], @(x) isempty(x) || isnumeric(x));
addParameter(p, 'StimMatPath', '', @ischar);
addParameter(p, 'StimEventID', 5, @isnumeric);
addParameter(p, 'StimEveryNth', 2, @isnumeric);
addParameter(p, 'StimEndBufferSec', 10, @isnumeric);
addParameter(p, 'NClusters', 8, @isnumeric);
parse(p, varargin{:});
animalID     = p.Results.AnimalID;
nPoolCells   = p.Results.NPoolCells;
perPage      = p.Results.CellsPerPage;
vlfThresh    = p.Results.VLFThresh;
vlfCutoffHz  = p.Results.VLFCutoffHz;
nRandomCells = p.Results.NRandomCells;
randomSeed   = p.Results.RandomSeed;
stimMatPath  = p.Results.StimMatPath;
stimEventID  = p.Results.StimEventID;
stimEveryNth = max(1, round(p.Results.StimEveryNth));
stimEndBufferSec = p.Results.StimEndBufferSec;
nClusters    = round(p.Results.NClusters);

% ---------------------------------------------------------------
% load suite2p output
% ---------------------------------------------------------------
S = load(fallMatPath);
F = S.F; spks = S.spks; iscell = S.iscell; ops = S.ops; stat = S.stat;

fs = ops.fs;
dt = 1/fs;
[nROIs, nframes] = size(F);

% ---------------------------------------------------------------
% stimulus onset times (optional). Read straight from the scanbox
% companion .mat file's digital sync channel: info.event_id==stimEventID
% marks each stimulus onset frame, already in imaging-frame units, so no
% separate clock alignment between the stimulus computer and the
% imaging computer is needed.
% ---------------------------------------------------------------
hasStim = ~isempty(stimMatPath);
onFramesAll = [];
onTimesAll  = [];
onTimesPlot = [];
if hasStim
    Sstim = load(stimMatPath);
    info = Sstim.info;
    onFramesAll = sort(double(info.frame(info.event_id == stimEventID)));
    onTimesAll  = onFramesAll * dt;
    onTimesPlot = onTimesAll(1:stimEveryNth:end);
end

if stimEveryNth == 1
    stimNoteStr = 'Vertical line = onset of every stimulus';
elseif stimEveryNth == 2
    stimNoteStr = 'Vertical line = onset of every other stimulus';
else
    stimNoteStr = sprintf('Vertical line = onset of every %dth stimulus', stimEveryNth);
end

% ---------------------------------------------------------------
% same "good cells" filter as getOctoCells.m:
%   iscell(:,2) > 0   (nonzero suite2p cell probability)
%   AND mean F > 50% of the median F among classifier-flagged cells
% ---------------------------------------------------------------
meanF_iscell = mean(F(iscell(:,1) > 0, :), 2);
mF = mean(F, 2);
goodcells = find(iscell(:,2) > 0 & mF > 0.5 * median(meanF_iscell));

Fg = F(goodcells, :);
dF = (Fg - mean(Fg,2)) ./ mean(Fg,2);
dF(dF > 2) = 2; % clip abnormally large values, same as the original script

spksG = spks(goodcells, :);
spikeRate = sum(spksG > 0, 2) / (nframes * dt); % naive spike rate, events/sec

% ---------------------------------------------------------------
% rank by spike rate, keep the top pool
% ---------------------------------------------------------------
[~, order] = sort(spikeRate, 'descend');
poolN = min(nPoolCells, numel(goodcells));
poolIdx = order(1:poolN);

roiPool  = goodcells(poolIdx);   % original suite2p ROI index (1-based in MATLAB)
dFPool   = dF(poolIdx, :);
ratePool = spikeRate(poolIdx);

% median-filter each trace (kernel = 5), used for both plotting and the
% slow-rise metric below
dFPoolSmooth = zeros(size(dFPool));
for i = 1:poolN
    dFPoolSmooth(i,:) = medfilt1(dFPool(i,:), 5);
end

% ---------------------------------------------------------------
% remove "slow rise" traces that don't resemble locked neural activity.
% suite2p's deconvolution will explain a slow drifting rise in
% fluorescence (bleaching, slow z-drift, etc.) with a train of small
% spike events, which can give a high naive spike rate even with no
% repeated fast structure. To catch this, compute the fraction of each
% trace's power spectrum that falls below vlfCutoffHz: real,
% stimulus-locked spiking traces have most of their power at higher
% frequencies, while slow-rise/drift traces concentrate almost all of
% their power below that cutoff.
% ---------------------------------------------------------------
fracVLF = zeros(poolN, 1);
for i = 1:poolN
    [pxx, f] = pwelch(dFPoolSmooth(i,:), [], [], [], fs);
    fracVLF(i) = sum(pxx(f < vlfCutoffHz)) / sum(pxx);
end

keepMask = fracVLF <= vlfThresh;
roiKept        = roiPool(keepMask);
dFKeptSmooth   = dFPoolSmooth(keepMask, :);
rateKept       = ratePool(keepMask);
nDropped       = sum(~keepMask);
nKept          = sum(keepMask);

t = (0:nframes-1) * dt;

% x-axis upper limit for every trace panel: cut off shortly after the
% stimulus ends (rather than padding out to the full recording length),
% so the panel isn't mostly empty space. Falls back to the recording's
% own length when there's no stimulus file.
if hasStim
    xMax = min(t(end), max(onTimesAll) + stimEndBufferSec);
else
    xMax = t(end);
end

% ---------------------------------------------------------------
% mean image background, mildly clipped for display
% ---------------------------------------------------------------
meanImg = double(ops.meanImg);
imgClip = localPercentile(meanImg(:), 99);
imgNorm = min(meanImg, imgClip);
imgNorm = imgNorm / max(imgNorm(:));

% ---------------------------------------------------------------
% tissue mask (the optic lobe), used to exclude ROIs that sit in the
% black background and are just mapping stimulus noise rather than
% real tissue. A plain intensity threshold doesn't work well here: it
% only catches the brightest specks and misses large stretches of dim
% but real tissue. Instead, threshold on LOCAL VARIANCE/texture - flat
% black background has ~zero local variance, while actual tissue (even
% dim regions) has texture - then keep only the single largest
% connected region.
% Requires the Image Processing Toolbox (stdfilt/mat2gray/graythresh/
% imclose/imfill/bwconncomp) - already used elsewhere in this pipeline.
% ---------------------------------------------------------------
localStd  = stdfilt(meanImg, true(7));
logVar    = mat2gray(log1p(localStd.^2));
tissueMask = logVar > graythresh(logVar);
tissueMask = imclose(tissueMask, strel('disk', 7));
tissueMask = imfill(tissueMask, 'holes');
cc = bwconncomp(tissueMask);
if cc.NumObjects > 1
    blobSizes = cellfun(@numel, cc.PixelIdxList);
    [~, biggest] = max(blobSizes);
    tissueMask = false(size(tissueMask));
    tissueMask(cc.PixelIdxList{biggest}) = true;
end

% which good cells have their centroid inside the tissue mask?
nGood = numel(goodcells);
inTissue = false(nGood, 1);
for i = 1:nGood
    cellStat = stat{goodcells(i)};
    cy = min(max(round(mean(cellStat.ypix)) + 1, 1), size(tissueMask, 1));
    cx = min(max(round(mean(cellStat.xpix)) + 1, 1), size(tissueMask, 2));
    inTissue(i) = tissueMask(cy, cx);
end

if ~isempty(randomSeed)
    rng(randomSeed);
end
tissueCandidates = find(inTissue);
nRandom = min(nRandomCells, numel(tissueCandidates));
randPickIdx = sort(tissueCandidates(randperm(numel(tissueCandidates), nRandom)));

randROI = goodcells(randPickIdx);
randTraceSmooth = zeros(nRandom, nframes);
for i = 1:nRandom
    randTraceSmooth(i,:) = medfilt1(dF(randPickIdx(i),:), 5);
end

% ---------------------------------------------------------------
% cluster the cells that passed BOTH the slow-rise filter (roiKept) AND
% the in-tissue test, following sbxOctoNeural.m's approach: cluster on
% each cell's stimulus-cycle-averaged response (median across repeats,
% baseline-subtracted using the first couple of frames of each cycle,
% downsampled 2x for SNR, clipped to [0, 0.2]), using Euclidean distance
% and Ward-linkage hierarchical clustering. Unlike sbxOctoNeural.m this
% always cuts the tree to exactly nClusters groups, skipping its
% adaptive step that lumps together clusters with under 5 cells.
% Without a stimulus file (no cycle timing available), it falls back to
% clustering directly on the smoothed dF/F traces instead.
% ---------------------------------------------------------------
keptInTissue = false(nKept, 1);
for i = 1:nKept
    cellStat = stat{roiKept(i)};
    cy = min(max(round(mean(cellStat.ypix)) + 1, 1), size(tissueMask, 1));
    cx = min(max(round(mean(cellStat.xpix)) + 1, 1), size(tissueMask, 2));
    keptInTissue(i) = tissueMask(cy, cx);
end

clusterROI    = roiKept(keptInTissue);
clusterRate   = rateKept(keptInTissue);
clusterTraces = dFKeptSmooth(keptInTissue, :); % already median-filtered
nClusterCells = numel(clusterROI);

usingCycleClustering = hasStim && numel(onFramesAll) >= 3 && nClusterCells >= nClusters;
if usingCycleClustering
    cycFrames = round(median(diff(onFramesAll)));
    nRep = numel(onFramesAll);
    [~, locInGood] = ismember(clusterROI, goodcells); % row of each clustered cell within dF
    dFclustRaw = NaN(nClusterCells, cycFrames, nRep);
    for r = 1:nRep
        startF = onFramesAll(r);
        endF   = startF + cycFrames - 1;
        if endF > nframes
            continue % skip an incomplete trailing cycle
        end
        seg = dF(locInGood, startF:endF); % nClusterCells x cycFrames
        baseline = mean(seg(:, 1:min(2, cycFrames)), 2);
        dFclustRaw(:, :, r) = seg - baseline;
    end
    dFclustCyc = localRobustToolboxCall('nanmedian', fullfile('toolbox', 'stats'), dFclustRaw, 3); % median across repeats
    newLen = max(1, floor(cycFrames / 2));
    dFclustCyc = imresize(dFclustCyc, [nClusterCells newLen]); % downsample 2x, same as sbxOctoNeural.m
    dFclustCyc(dFclustCyc > 0.2) = 0.2;
    dFclustCyc(dFclustCyc < 0) = 0;
    distC = pdist(dFclustCyc, 'euclidean');
else
    distC = pdist(clusterTraces, 'euclidean'); % fallback: cluster on the raw smoothed trace
end
Zc = linkage(distC, 'ward');
clustID = localRobustToolboxCall('cluster', fullfile('toolbox', 'stats'), Zc, 'maxclust', nClusters);
clusterColors = hsv(nClusters);


% ---------------------------------------------------------------
% start a fresh PDF
% ---------------------------------------------------------------
if exist(outPdfPath, 'file')
    delete(outPdfPath);
end

titlePrefix = '';
if ~isempty(animalID)
    titlePrefix = [animalID ' - '];
end

% ---- page 1: explanation of the methodology ----
fig = figure('Visible', 'off', 'Units', 'inches', 'Position', [0 0 11 8.5], 'Color', 'w');
axes('Position', [0 0 1 1], 'Visible', 'off'); hold on
text(0.5, 0.94, [titlePrefix 'How cells were selected for this document'], ...
    'FontSize', 16, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');

bodyLines = {
    '1. Starting pool (suite2p "good cells")'
    sprintf('   From all %d suite2p ROIs, cells were kept if suite2p''s classifier gave them', nROIs)
    '   a nonzero cell probability (iscell(:,2) > 0) AND their mean raw fluorescence was'
    '   at least 50% of the median fluorescence among classified cells. This is the same'
    sprintf('   filter used in getOctoCells.m. This left %d good cells.', numel(goodcells))
    ''
    '2. Ranking by spike rate'
    '   For each good cell, suite2p''s deconvolved spike trace (spks) was used to compute'
    '   a naive spike rate: the fraction of frames with a nonzero deconvolved value,'
    '   converted to events/sec. Cells were sorted by this rate, descending, and the'
    sprintf('   top %d cells were carried forward as the working pool for this document.', poolN)
    ''
    '3. Removing "slow rise" traces that do not resemble locked neural activity'
    '   Some high-ranked cells have high naive spike rates not because they show'
    '   repeated, fast calcium transients, but because suite2p''s deconvolution'
    '   assigns a train of small spike events to explain any slow, drifting rise in'
    '   fluorescence (e.g. bleaching, slow z-drift) - even with no repeated fast'
    '   structure at all.'
    ''
    '   To separate these out, each cell''s dF/F trace (median-filtered, kernel=5) was'
    '   passed through a power spectral density estimate (Welch''s method). The'
    '   fraction of each trace''s total spectral power found below the cutoff was'
    '   computed. True stimulus-locked, spiking traces have most of their power at'
    '   higher frequencies, while slow-rise/drift-dominated traces concentrate'
    '   almost all of their power below the cutoff.'
    ''
    sprintf('   Cells with more than %d%% of their spectral power below %.2f Hz were', ...
        round(vlfThresh*100), vlfCutoffHz)
    sprintf('   dropped as non-neural-looking. This removed %d of the %d cells in the', ...
        nDropped, poolN)
    sprintf('   working pool, leaving %d cells, still sorted by spike rate (highest', nKept)
    sprintf('   first) and shown %d cells per page below.', perPage)
    ''
    '   This is a heuristic, not a certainty - a small number of borderline cells may'
    '   be mis-classified in either direction. Re-run with a different ''VLFThresh'''
    '   if too many/few cells are being removed.'
    ''
    '4. Defining "within the optic lobe" for the random-cell overview (page 2)'
    '   To restrict the page-2 random cell sample to real tissue (and keep out the'
    '   black background, where a stray ROI would just be mapping stimulus noise),'
    '   the mean image was thresholded on LOCAL TEXTURE rather than raw brightness:'
    '   flat black background has ~zero local variance, while even dim real tissue'
    '   has texture. A local standard-deviation filter was run over the mean image,'
    '   log-transformed, and thresholded (Otsu''s method); only the single largest'
    '   connected region passing that threshold was kept as "the optic lobe." Only'
    '   good cells whose mask centroid falls inside that region were eligible for'
    '   the page-2 random draw.'
    ''
    '5. Clustering the filtered, in-lobe cells (page 3 onward)'
    sprintf('   The %d cells that passed both the slow-rise filter and the optic-lobe test', nClusterCells)
    sprintf('   were split into %d clusters, following the same approach as sbxOctoNeural.m:', nClusters)
    '   each cell''s response was averaged across stimulus presentations (median, time-'
    '   locked to stimulus onset and baseline-subtracted using the first couple of frames'
    '   of each cycle), downsampled 2x for SNR, and clipped to [0, 0.2]. Pairwise Euclidean'
    '   distance between these per-cell averaged response profiles was then clustered with'
    sprintf('   Ward-linkage hierarchical clustering, cut to exactly %d groups. Unlike', nClusters)
    '   sbxOctoNeural.m this skips its adaptive step that lumps together small (<5 cell)'
    '   clusters, since a fixed cluster count was requested here.'
    };
if ~usingCycleClustering
    bodyLines = [bodyLines; {
        '   (No stimulus file was given, so there was no cycle timing to average over -'
        '   clustering fell back to each cell''s full smoothed dF/F trace instead.)'
        }];
end

if hasStim
    stimLines = {
        ''
        '6. Stimulus onset markers overlaid on every trace panel'
        sprintf('   Stimulus timing was read directly from this recording''s scanbox companion')
        sprintf('   .mat file (%s): its digital sync channel marks the', localFileName(stimMatPath))
        sprintf('   frame at which each stimulus turned on (info.event_id == %d). Because', stimEventID)
        '   this is already expressed in imaging-frame units, no separate clock alignment'
        '   between the stimulus computer and the imaging computer is required - each'
        '   onset frame is simply converted to seconds using the frame rate (dt = 1/fs).'
        ''
        sprintf('   %d stimulus presentations were found in the sync channel. To keep the', numel(onTimesAll))
        sprintf('   trace panels readable, only every %d%s one is drawn as a thin vertical', ...
            stimEveryNth, localOrdinalSuffix(stimEveryNth))
        sprintf('   line (%d lines total) - this is noted above each trace panel as:', numel(onTimesPlot))
        sprintf('   "%s"', stimNoteStr)
        };
    bodyLines = [bodyLines; stimLines];
end

bodyText = strjoin(bodyLines, newline);
text(0.08, 0.88, bodyText, 'FontSize', 10, 'FontName', 'FixedWidth', ...
    'VerticalAlignment', 'top', 'Interpreter', 'none');
xlim([0 1]); ylim([0 1]);

exportgraphics(fig, outPdfPath, 'Append', true);
close(fig);

% ---- page 2: overview of every suite2p mask, plus 50 random in-tissue cells ----
fig = figure('Visible', 'off', 'Units', 'inches', 'Position', [0 0 11 8.5], 'Color', 'w');

% ---- left panel: mean image + every suite2p mask (muted gray), with
% the randomly-chosen cells highlighted in color on top ----
axImgAll = axes('Position', [0.04 0.05 0.40 0.85]);
imagesc(axImgAll, imgNorm); colormap(axImgAll, 'gray'); hold(axImgAll, 'on');
axis(axImgAll, 'image'); axis(axImgAll, 'off');

overlayAll   = zeros([size(imgNorm) 3]);
alphaAll     = zeros(size(imgNorm));
for r = 1:nROIs
    cellStat = stat{r};
    xpix = cellStat.xpix + 1;
    ypix = cellStat.ypix + 1;
    for k = 1:numel(xpix)
        overlayAll(ypix(k), xpix(k), :) = [0.7 0.7 0.7]; % all masks, muted gray
        alphaAll(ypix(k), xpix(k)) = 0.35;
    end
end
colorsRand = hsv(nRandom);
for c = 1:nRandom
    cellStat = stat{randROI(c)};
    xpix = cellStat.xpix + 1;
    ypix = cellStat.ypix + 1;
    lam  = cellStat.lam;
    a    = max(lam / max(lam), 0.5);
    for k = 1:numel(xpix)
        overlayAll(ypix(k), xpix(k), :) = colorsRand(c, :); % highlighted, full color
        alphaAll(ypix(k), xpix(k)) = a(k);
    end
end
hOverlayAll = image(axImgAll, overlayAll);
set(hOverlayAll, 'AlphaData', alphaAll);
title(axImgAll, sprintf('All %d suite2p masks (gray); %d random in-tissue cells highlighted', ...
    nROIs, nRandom), 'FontSize', 8);

% ---- right panel: the random in-tissue cells' traces, colored to
% match their highlighted masks ----
axRand = axes('Position', [0.47 0.05 0.50 0.85]); hold(axRand, 'on');
localDrawStimLinesBehind(axRand, onTimesPlot, hasStim); % drawn first, so traces layer on top
yTicksR  = zeros(nRandom, 1);
yLabelsR = cell(nRandom, 1);
topPeakR = -Inf; % tracks the actual peak of the topmost (first) trace
for i = 1:nRandom
    offset = nRandom - i + 1;
    tr = randTraceSmooth(i, :);
    trNorm = tr - median(tr);
    span = localPercentile(abs(trNorm), 99);
    if span <= 0
        span = 1;
    end
    trNorm = trNorm / span * 0.4;
    plot(axRand, t, trNorm + offset, 'Color', colorsRand(i, :), 'LineWidth', 0.5);
    if i == 1
        topPeakR = max(trNorm + offset);
    end
    yTicksR(i)  = offset;
    yLabelsR{i} = sprintf('%d', randROI(i));
end
xlim(axRand, [0 xMax]);
ylim(axRand, [0 topPeakR + 0.3]); % cuts off shortly after the top trace's actual peak
[sortedTicksR, tickOrderR] = sort(yTicksR);
set(axRand, 'YTick', sortedTicksR, 'YTickLabel', yLabelsR(tickOrderR), 'FontSize', 6);
xlabel(axRand, 'Time (s)'); ylabel(axRand, 'ROI #');
localAddStimNote(axRand, hasStim, stimNoteStr);

sgtitle(fig, sprintf('%s%d randomly selected in-tissue cells (optic lobe only, background-noise ROIs excluded)', ...
    titlePrefix, nRandom), 'FontSize', 11);

exportgraphics(fig, outPdfPath, 'Append', true);
close(fig);

% ---- page 3: cluster overview ----
% left: mean image + masks for every filtered, in-lobe cell, colored by
% cluster. right: a heatmap of all of those cells' traces, rows grouped
% by cluster, with a colored strip marking each cluster's rows.
fig = figure('Visible', 'off', 'Units', 'inches', 'Position', [0 0 11 8.5], 'Color', 'w');

axImgClust = axes('Position', [0.04 0.05 0.40 0.85]);
imagesc(axImgClust, imgNorm); colormap(axImgClust, 'gray'); hold(axImgClust, 'on');
axis(axImgClust, 'image'); axis(axImgClust, 'off');

overlayClust = zeros([size(imgNorm) 3]);
alphaClust   = zeros(size(imgNorm));
for c = 1:nClusterCells
    cellStat = stat{clusterROI(c)};
    xpix = cellStat.xpix + 1;
    ypix = cellStat.ypix + 1;
    lam  = cellStat.lam;
    a    = max(lam / max(lam), 0.4);
    thisColor = clusterColors(clustID(c), :);
    for k = 1:numel(xpix)
        overlayClust(ypix(k), xpix(k), :) = thisColor;
        alphaClust(ypix(k), xpix(k)) = max(alphaClust(ypix(k), xpix(k)), a(k));
    end
end
hOverlayClust = image(axImgClust, overlayClust);
set(hOverlayClust, 'AlphaData', alphaClust);
title(axImgClust, sprintf('%d filtered, in-lobe cells colored by cluster (%d clusters)', ...
    nClusterCells, nClusters), 'FontSize', 9);

axHeat = axes('Position', [0.47 0.05 0.50 0.85]); hold(axHeat, 'on');
[sortedClustID, heatOrder] = sort(clustID);
heatData = clusterTraces(heatOrder, :);
imagesc(axHeat, t, 1:nClusterCells, heatData, [0 localPercentile(heatData(:), 98)]);
colormap(axHeat, 'jet');
set(axHeat, 'YDir', 'normal');
boundaries = find(diff(sortedClustID) ~= 0);
for b = boundaries(:)'
    plot(axHeat, [0 xMax], [b + 0.5, b + 0.5], 'w-', 'LineWidth', 1);
end
clustTickPos = zeros(nClusters, 1);
for k = 1:nClusters
    rowsK = find(sortedClustID == k);
    if isempty(rowsK)
        clustTickPos(k) = NaN;
    else
        clustTickPos(k) = mean(rowsK);
    end
end
validK = ~isnan(clustTickPos);
set(axHeat, 'YTick', clustTickPos(validK), ...
    'YTickLabel', arrayfun(@(k) sprintf('Cluster %d', k), find(validK), 'UniformOutput', false), ...
    'FontSize', 7);
xlim(axHeat, [0 xMax]);
ylim(axHeat, [0.5 nClusterCells + 0.5]);
xlabel(axHeat, 'Time (s)');
if hasStim
    for k = 1:numel(onTimesPlot)
        xline(axHeat, onTimesPlot(k), 'Color', [1 1 1], 'LineWidth', 0.4);
    end
    localAddStimNote(axHeat, hasStim, stimNoteStr);
end

sgtitle(fig, sprintf('%sCluster overview: %d clusters among %d filtered, in-lobe cells', ...
    titlePrefix, nClusters, nClusterCells), 'FontSize', 11);

exportgraphics(fig, outPdfPath, 'Append', true);
close(fig);

% ---- trace + mask pages, grouped by cluster ----
totalPagesWritten = 0;
for k = 1:nClusters
    cellsInK = find(clustID == k);
    [~, ord] = sort(clusterRate(cellsInK), 'descend');
    cellsInK = cellsInK(ord); % cells in this cluster, highest spike rate first
    nInCluster = numel(cellsInK);
    if nInCluster == 0
        continue
    end

    % if this cluster has more cells than fit on one normal page, add a
    % single overview page first showing ALL of its cells at once (mask
    % + trace), each individually rainbow-colored so every trace matches
    % its own mask, however many cells that is
    if nInCluster > perPage
        localWriteTracePage(outPdfPath, imgNorm, stat, t, xMax, hasStim, onTimesPlot, stimNoteStr, ...
            clusterROI(cellsInK), clusterRate(cellsInK), clusterTraces(cellsInK, :), ...
            sprintf('All %d cells in cluster %d', nInCluster, k), ...
            sprintf('%sCluster %d of %d - all %d cells', titlePrefix, k, nClusters, nInCluster));
        totalPagesWritten = totalPagesWritten + 1;
    end

    nPagesK = ceil(nInCluster / perPage);
    for pk = 1:nPagesK
        if pk < nPagesK
            startIdx = (pk-1)*perPage + 1;
            endIdx   = pk*perPage;
        else
            % last page of this cluster: keep a full perPage cells on it
            % too (can repeat a few already shown on the prior page),
            % same trick used for the overall last page before
            endIdx   = nInCluster;
            startIdx = max(nInCluster - perPage + 1, 1);
        end
        pageIdx = cellsInK(startIdx:endIdx);
        nThis   = numel(pageIdx);

        localWriteTracePage(outPdfPath, imgNorm, stat, t, xMax, hasStim, onTimesPlot, stimNoteStr, ...
            clusterROI(pageIdx), clusterRate(pageIdx), clusterTraces(pageIdx, :), ...
            sprintf('%d cells from cluster %d', nThis, k), ...
            sprintf('%sCluster %d of %d - %d cells (page %d/%d within cluster)', ...
                titlePrefix, k, nClusters, nInCluster, pk, nPagesK));
        totalPagesWritten = totalPagesWritten + 1;
    end
end

fprintf('%s: %d good cells -> top %d by spike rate -> %d kept after slow-rise filtering -> %d filtered+in-lobe -> %d clusters -> %d pages\n', ...
    fallMatPath, numel(goodcells), poolN, nKept, nClusterCells, nClusters, totalPagesWritten);
if hasStim
    fprintf('Stimulus onsets: %d found, every %d%s drawn (%d lines per panel)\n', ...
        numel(onTimesAll), stimEveryNth, localOrdinalSuffix(stimEveryNth), numel(onTimesPlot));
end
fprintf('Wrote %s\n', outPdfPath);

end % suite2pTracesStimOnset_AAClaude101226


function localWriteTracePage(outPdfPath, imgNorm, stat, t, xMax, hasStim, onTimesPlot, stimNoteStr, ...
    pageROI, pageRate, pageTraces, imgTitleStr, sgTitleStr)
%LOCALWRITETRACEPAGE  Write one PDF page: a mean-image/mask panel on the
%   left and a stacked, per-cell-normalized trace panel on the right,
%   both individually rainbow-colored so each trace matches its own
%   mask. Used for every per-cluster trace page, including the
%   whole-cluster overview page added when a cluster has more cells than
%   fit on one normal page (nThis can be any size in that case, so the
%   y-tick label font shrinks a bit for very large cell counts to stay
%   legible).
nThis = numel(pageROI);
colors = hsv(nThis);
yFontSize = max(4, min(7, 150 / nThis));

fig = figure('Visible', 'off', 'Units', 'inches', 'Position', [0 0 11 8.5], 'Color', 'w');

% ---- left panel: mean image + colored masks ----
axImg = axes('Position', [0.04 0.05 0.40 0.85]);
imagesc(axImg, imgNorm); colormap(axImg, 'gray'); hold(axImg, 'on');
axis(axImg, 'image'); axis(axImg, 'off');

overlay   = zeros([size(imgNorm) 3]);
alphaMask = zeros(size(imgNorm));
for c = 1:nThis
    cellStat = stat{pageROI(c)};
    xpix = cellStat.xpix + 1; % suite2p pixel coords are 0-based
    ypix = cellStat.ypix + 1;
    lam  = cellStat.lam;
    a    = max(lam / max(lam), 0.4);
    for kk = 1:numel(xpix)
        overlay(ypix(kk), xpix(kk), :) = colors(c, :);
        alphaMask(ypix(kk), xpix(kk)) = max(alphaMask(ypix(kk), xpix(kk)), a(kk));
    end
end
hOverlay = image(axImg, overlay);
set(hOverlay, 'AlphaData', alphaMask);
title(axImg, imgTitleStr, 'FontSize', 9);

% ---- right panel: traces, normalized per-cell so amplitude
% differences don't cause neighboring traces to overlap ----
axTr = axes('Position', [0.47 0.05 0.50 0.85]); hold(axTr, 'on');
localDrawStimLinesBehind(axTr, onTimesPlot, hasStim); % drawn first, so traces layer on top
yTicks  = zeros(nThis, 1);
yLabels = cell(nThis, 1);
topPeak = -Inf; % tracks the actual peak of the topmost (first) trace
for i = 1:nThis
    offset = nThis - i + 1;
    tr = pageTraces(i, :);
    trNorm = tr - median(tr);
    span = localPercentile(abs(trNorm), 99);
    if span <= 0
        span = 1;
    end
    trNorm = trNorm / span * 0.4; % keep each trace within its own row
    plot(axTr, t, trNorm + offset, 'Color', colors(i, :), 'LineWidth', 0.5);
    if i == 1
        topPeak = max(trNorm + offset);
    end
    yTicks(i)  = offset;
    % NOTE: pageROI(i) is the 1-based MATLAB row index into F/stat.
    % Suite2p/Python tools number ROIs from 0, so this is that ROI's
    % python index + 1. Hz is on its own line, under the ROI number.
    yLabels{i} = sprintf('%d\n%.2f Hz', pageROI(i), pageRate(i));
end
xlim(axTr, [0 xMax]); % cuts off shortly after the stimulus ends
ylim(axTr, [0 topPeak + 0.3]); % cuts off shortly after the top trace's actual peak
[sortedTicks, tickOrder] = sort(yTicks);
set(axTr, 'YTick', sortedTicks, 'YTickLabel', yLabels(tickOrder), 'FontSize', yFontSize);
xlabel(axTr, 'Time (s)'); ylabel(axTr, 'ROI # (spike rate)');
localAddStimNote(axTr, hasStim, stimNoteStr);

sgtitle(fig, sgTitleStr, 'FontSize', 11);

exportgraphics(fig, outPdfPath, 'Append', true);
close(fig);
end


function localDrawStimLinesBehind(ax, onTimesPlot, hasStim)
%LOCALDRAWSTIMLINESBEHIND  Draw thin stimulus-onset lines. Call this
%   BEFORE plotting the cell traces on the same axes, so the traces are
%   layered on top of the stimulus lines rather than the other way round.
if ~hasStim
    return
end
for k = 1:numel(onTimesPlot)
    xline(ax, onTimesPlot(k), 'Color', [0.85 0.65 0.13], 'LineWidth', 0.5);
end
end


function localAddStimNote(ax, hasStim, stimNoteStr)
%LOCALADDSTIMNOTE  Add the small note just inside the top of a trace
%   panel explaining the stimulus-onset lines. Call this any time after
%   the axes exist. Placed just inside the axes (rather than above it)
%   so it doesn't collide with the figure-level sgtitle above the panel.
if ~hasStim
    return
end
text(ax, 0.5, 0.98, stimNoteStr, 'Units', 'normalized', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
    'FontSize', 7, 'FontAngle', 'italic');
end


function name = localFileName(fullPath)
%LOCALFILENAME  Just the file name (with extension), no folder path.
[~, n, e] = fileparts(fullPath);
name = [n e];
end


function suf = localOrdinalSuffix(n)
%LOCALORDINALSUFFIX  'st'/'nd'/'rd'/'th' for an integer, e.g. 2 -> 'nd'.
%   Only used for phrasing like "every 2nd stimulus"; stimEveryNth==1 and
%   ==2 are phrased specially elsewhere and don't rely on this.
if mod(n, 100) >= 11 && mod(n, 100) <= 13
    suf = 'th';
else
    switch mod(n, 10)
        case 1
            suf = 'st';
        case 2
            suf = 'nd';
        case 3
            suf = 'rd';
        otherwise
            suf = 'th';
    end
end
end


function out = localRobustToolboxCall(funcName, toolboxFolderHint, varargin)
%LOCALROBUSTTOOLBOXCALL  Call funcName(varargin{:}), defending against a
%   path collision where some other file of the same name earlier on the
%   user's path shadows the intended toolbox function (seen on this
%   lab's machine with both cluster.m and nanmedian.m being shadowed by
%   files under ratrix/matlabClub). If the normal call fails with a
%   mismatched-argument-count error, this looks up the toolbox's own copy
%   via "which <funcName> -all" (matched by toolboxFolderHint, e.g.
%   fullfile('toolbox','stats')), temporarily moves that copy's folder to
%   the front of the path for just this one call, then restores the
%   user's path exactly as it was.
try
    out = feval(funcName, varargin{:});
catch ME
    if ~contains(ME.message, 'Too many input arguments') && ...
       ~contains(ME.message, 'Not enough input arguments')
        rethrow(ME);
    end
    listing = evalc(['which ' funcName ' -all']);
    lines = strsplit(listing, newline);
    lines = lines(~cellfun(@isempty, lines));
    toolboxLine = '';
    for i = 1:numel(lines)
        if contains(lines{i}, toolboxFolderHint) && ~contains(lines{i}, '@')
            toolboxLine = lines{i};
            break
        end
    end
    if isempty(toolboxLine)
        error('suite2pTracesStimOnset:FunctionShadowed', ...
            ['%s() is being shadowed by another file on the path, and a copy under ' ...
             '''%s'' could not be found to work around it. Run "which %s -all" and ' ...
             'rename or move whatever non-toolbox version is listed first.'], ...
            funcName, toolboxFolderHint, funcName);
    end
    toolboxFile = strtrim(regexprep(toolboxLine, '\s*%.*$', '')); % drop a trailing "% Shadowed" note
    origPath = path;
    addpath(fileparts(toolboxFile), '-begin');
    out = feval(funcName, varargin{:});
    path(origPath); % restore the user's path exactly as it was
end
end


function p = localPercentile(x, pct)
%LOCALPERCENTILE  Simple percentile, avoids a Statistics Toolbox dependency.
xs = sort(x(:));
n = numel(xs);
if n == 0
    p = 0;
    return
end
idx = pct/100*(n-1) + 1;
lo = floor(idx);
hi = ceil(idx);
lo = max(lo, 1);
hi = min(hi, n);
if lo == hi
    p = xs(lo);
else
    frac = idx - lo;
    p = xs(lo)*(1-frac) + xs(hi)*frac;
end
end
