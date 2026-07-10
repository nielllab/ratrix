% Original function signature (converted to script — call as a script, not a function):
% function varargout = sutterOctoNeural(varargin)
%% sutterOctoNeural - Main analysis function for octopus optic lobe 2-photon imaging data
% sbxOctoNeural_DR_commented_v7 — 2026-07-10
%
% CHANGELOG:
%   v7 (2026-07-10): No more manual 'clear all' required between runs.
%     - Added a self-clean block right at the top of the script (before
%       'close all'): if Opt exists in the workspace it is stashed, everything
%       else is cleared with clearvars, then Opt is restored. If Opt does not
%       exist, clearvars runs unconditionally. This prevents stale variables
%       from a previous run (figNum, dF, nstim, xpts, mv, etc.) from ever
%       leaking into this run's exist()/isfield() checks, which was the whole
%       reason 'clear all' used to be necessary before every call.
%   v6 (2026-05-19): figNum correctness fixes.
%     - getOctoCells_DR call site: removed erroneous caller pre-increment. The
%       caller was doing figNum+1 before the call AND getOctoCells_DR was doing
%       figNum+1 again internally before its first export, wasting one slot (was
%       Fig 11 in a typical nstim==50 run).
%     - octoRetinotopy_DR call sites (nstim==48 and nstim==50): same pre-increment
%       bug — removed both. octoRetinotopy_DR owns all its own increments.
%     - get2pSession_sbx_DR: all 3 exported figures (baseline image, mean
%       timecourse, cycle average) now use figNum and carry Fig N labels.
%       These were the first 3 PDF pages but had no numbers, causing every
%       subsequent page to be off by 3.
%     - getOctoCells_DR mode 1: was exporting only 1 figure but consuming 1 figNum
%       slot, causing all subsequent figures to be mis-numbered by 1. Now exports
%       2 figures (anatomy + overlay) to match mode 0's 2-slot footprint.
%     - Rigid Alignment Values exportgraphics: was outside the if exist('mv') block,
%       causing a wrong figure to be appended when mv exists, or a stale-gcf append
%       when mv is absent. Moved inside the if block.
%     - subtractSidebandNoise: file renamed subtractSidebandNoise_DR.m to match call
%       site (was silently failing to call the function).
%     - All Pg N comments in main script updated (+3) to reflect correct page numbers.
%
% PURPOSE:
%   Reads in .sbx (Sutter 2-photon) imaging data, extracts fluorescence traces
%   from selected ROIs (regions of interest), aligns responses to stimulus
%   presentations, clusters cells by response profile, and generates a multi-page
%   PDF of analysis figures. Optimized for octopus optic lobe preparations
%   labeled with Cal520 calcium indicator.
%
% USAGE:
%   sutterOctoNeural()           % run interactively, prompts for all inputs
%   sutterOctoNeural(Opt)        % run with options struct Opt
%
% INPUT (optional struct Opt fields):
%   Opt.SaveFigs      - 1 to save figures to PDF (default: 1)
%   Opt.psfile        - path to temporary PDF accumulation file (default: 'C:\temp\TempFigs.pdf')
%   Opt.selectPts     - ROI selection mode: 0=auto, 1=manual, 2=suite2p, 3=red/green suite2p
%   Opt.selectCrop    - 1 to manually crop the image before auto ROI selection
%   Opt.mindF         - minimum brightness threshold for auto ROI selection
%   Opt.nclust        - number of clusters for hierarchical clustering
%   Opt.Resample_dt   - temporal resampling interval in seconds (default: 0.1)
%   Opt.fSbx          - filename of .sbx file
%   Opt.pSbx          - path to .sbx file
%   Opt.fStim         - filename of stimulus record .mat file
%   Opt.pStim         - path to stimulus record .mat file
%   Opt.fPDF          - output PDF filename
%   Opt.pPDF          - output PDF path
%   Opt.cellrange     - pixel range around each ROI center for averaging (default: -2:2)
%   Opt.sub_noise     - 1 to subtract sideband noise from dF/F traces
%   Opt.zbinning      - 1 to apply z-plane binning correction
%
% STIMULUS TYPES (determined by nstim and StimulusNum loaded from stimulus record):
%   nstim=12          : 6-spot OFF/ON receptive field mapping (6 OFF + 6 ON)
%   nstim=13          : gratings (4 orient x 3 SF, 1 TF) + flicker
%   nstim=14          : gratings (horiz/vert, 3 SF, 2 TF) + flicker
%   nstim=16,SNum=2   : bars (8 directions x 2 contrast)
%   nstim=17          : gratings (4 SF x 4 orient or 2 SF x 8 orient) + flicker
%   nstim=17,2SF      : additional spatial frequency tuning maps
%   nstim=24,SNum=1   : gratings (4 orient x 2 SF x 3 TF)
%   nstim=24,SNum=7   : 4x6 ON-only spots
%   nstim=26          : gratings (4 directions x 3 SF x 2 TF) + flicker
%   nstim=29          : gratings (4 SF x 7 orient) + flicker + SF tuning curve
%   nstim=32,SNum=2   : moving spots (4 directions x 4 locations x 2 sizes)
%   nstim=48          : 6x4 OFF+ON spot grid (retinotopy)
%   nstim=50          : 5x5 OFF+ON spot grid (retinotopy)
%   nstim=10          : contrast gratings (one-time condition)
%
% OUTPUTS:
%   Multi-page PDF saved to Opt.pPDF/Opt.fPDF
%   .mat file with analysis results saved alongside PDF
%   (Optional) varargout{1} = Output struct (currently commented out)
%
% DEPENDENCIES (scripts called, must be on MATLAB path):
%   get2pSession_sbx_DR   - loads .sbx file, returns dfofInterp, phasetimes
%   subtractSidebandNoise_DR - removes sideband noise from dF/F data (optional)
%   zbinCorr              - z-plane binning correction (optional)
%   getOctoCells          - selects ROI points, returns dF, x, y, xpts, ypts
%   pixPlot               - pixel-wise mean response maps + trial timecourses
%   pixPlotWeight         - green-weighted pixel maps + weighted timecourses
%   octoRetinotopy        - computes and plots retinotopic maps from spot stimuli
%   mapGratingsOcto       - computes and plots grating preference/overlay maps
%
% NOTE ON FIGURE NAMING:
%   Figures are numbered by approximate page order in the output PDF.
%   Per-cluster figures shift in page number depending on nclust (determined at runtime).
%   Stimulus-specific figures appear after the cluster loop.
%
%   figNum counter: every figure exported to PDF is preceded by 'figNum = figNum + 1'
%   and uses figure('Name', sprintf('Fig %d - Description', figNum)) plus an updated
%   title/sgtitle. Non-printed figures use a descriptive Name with '(not printed)'.
%
%   Sub-scripts (pixPlot_DR, pixPlotWeight_DR):
%     Each pixPlot_DR call exports 2 figures (pixel map + timecourses).
%     Each pixPlotWeight_DR call exports 2 figures (weighted pixel map + weighted timecourses).
%     figNum is advanced with bracketing increments in both cases:
%       figNum = figNum + 1; pixPlot_DR;       figNum = figNum + 1;
%       figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;
%     To add figure numbers inside pixPlot_DR/pixPlotWeight_DR themselves,
%     add sgtitle(sprintf('Fig %d: ...', figNum), 'Interpreter', 'none') inside
%     those scripts at their exportgraphics calls.
%
%   getOctoCells_DR: produces 2 figures (auto/manual) or 4 figures (suite2p).
%     Manages figNum entirely internally. Do NOT pre-increment before calling.
%   octoRetinotopy_DR: produces 4 figures (X/Y map × OFF/ON).
%     Manages figNum entirely internally. Do NOT pre-increment before calling.

% Self-clean the workspace at the top of every run so stale variables from a
% previous run (figNum, dF, nstim, xpts, mv, etc.) can never leak into this
% run's exist()/isfield() checks. This removes the need to manually run
% 'clear all' before each call.
% Opt is preserved if the user set it before calling the script (per the
% documented usage pattern above); everything else set by a prior run is wiped.
if exist('Opt', 'var')
    OptTemp_ = Opt;
    clearvars -except OptTemp_
    Opt = OptTemp_;
    clear OptTemp_
else
    clearvars
end

close all

% Figure numbering counter.
% Incremented once for each figure that is exported to the output PDF.
% Figures that are displayed but NOT printed use a descriptive Name but no number.
% This counter is used throughout the script to set figure window names and
% PDF page labels via the figure 'Name' property, making each PDF page
% directly referenceable (e.g. "see Fig 3" in the experimental summary).
figNum = 0;

%% =========================================================================
%% SECTION 1: INITIALIZE OPTIONS
%% =========================================================================

% If Opt is not already set in the calling workspace, initialize with defaults.
% To customise a run, set Opt fields before calling this script, e.g.:
%   Opt.psfile = 'C:\mydata\output.pdf';
%   Opt.selectPts = 2;   % use suite2p ROIs
%   sbxOctoNeural_DR_commented_v6
if ~exist('Opt', 'var')
    % Save all figures to a temporary PDF file which is later copied to the output location
    Opt.SaveFigs = 1;
    Opt.psfile = 'C:\temp\TempFigs.pdf';

    % Manual crop of image before auto ROI selection (1=yes, 0=no)
    Opt.selectCrop = 1;

    % Temporal resampling interval: 0.1 sec = 10 Hz effective frame rate
    Opt.Resample_dt = 0.1;

    %%% Additional options (currently commented out - uncomment to use):
    % Opt.NumChannels = 2;     % for two-color (interleaved frame) data
    % Opt.selectPts = 0;       % 0=auto ROI, 1=manual, 2=suite2p, 3=red/green suite2p
    % Opt.mindF = 200;         % minimum pixel brightness for auto ROI selection
    % Opt.nclust = 5;          % number of clusters for hierarchical clustering
    % Opt.MakeMov = 0;         % make movies of aligned/unaligned image sequences
    % Opt.fwidth = 0.5;        % Gaussian filter standard deviation
    % Opt.align = 1;           % perform rigid alignment
    % Opt.AlignmentChannel=2;  % channel used for alignment
    % Opt.Resample = 1;        % resample at different frame rate
    % Opt.ttl_file = 1;        % read TTL timing file
    % Opt.SaveOutput = 0;      % output results struct (set 0 to run as script)
end

%% =========================================================================
%% SECTION 2: SET UP PARAMETERS
%% =========================================================================

% Define pixel range (half-width) for averaging around each ROI center point
if isfield(Opt,'cellrange')
    pts_range = Opt.cellrange;
else
    pts_range = -2:2;   % 5x5 pixel box (was -2:2 before 011123)
end

% Delete existing temp PDF file if it exists (start fresh)
if Opt.SaveFigs
    psfile = Opt.psfile;
    % Create the output directory if it doesn't exist (e.g. C:\temp\ on a fresh machine)
    psdir = fileparts(psfile);
    if ~isempty(psdir) && ~exist(psdir, 'dir')
        mkdir(psdir);
    end
    if exist(psfile,'file')==2; delete(psfile); end
end

% Set temporal resampling interval (seconds per frame after resampling)
dt = Opt.Resample_dt;

% Configuration struct for get2pSession_sbx_DR:
%   dt          = resampling interval (sec)
%   spatialBin  = spatial downsampling factor (2 = half resolution)
%   temporalBin = temporal downsampling factor
%   syncToVid   = whether to sync to video timestamps
%   saveDF      = whether to save dF/F inside get2pSession
cfg.dt = dt; cfg.spatialBin = 2; cfg.temporalBin = 1;
cfg.syncToVid = 0; cfg.saveDF = 0;

% Suppress saving the full session data (we save our own output at the end)
sessionName = 0;

% Construct full file path to .sbx file if provided in Opt
if isfield(Opt,'fSbx')
    fileName = fullfile(Opt.pSbx, Opt.fSbx);
end


%% =========================================================================
%% SECTION 3: LOAD IMAGING DATA
%% =========================================================================

% Load the .sbx imaging data, perform alignment, compute dF/F.
% Returns:
%   dfofInterp  - [Y x X x T] dF/F movie, temporally resampled to dt
%   phasetimes  - [1 x nStims] vector of stimulus onset times (seconds)
%   meanImg     - mean fluorescence image
%   greenframe  - raw green channel reference frame
%   info        - global struct with metadata including alignment values (info.aligned.T)
get2pSession_sbx_DR;

% Retrieve rigid alignment (motion correction) displacement values
global info
mv = info.aligned.T;   % [T x 2] matrix of x/y displacements per frame


%% =========================================================================
%% SECTION 4: OPTIONAL SIDEBAND NOISE SUBTRACTION
%% =========================================================================

% Sideband noise arises from out-of-focus fluorescence in adjacent z-planes.
% subtractSidebandNoise_DR removes this by computing and subtracting a scaled
% version of the sideband signal from dfofInterp.
if ~isfield(Opt,'sub_noise')
    Opt.sub_noise = input('subtract noise from sidebands? 0/1 ');
end

if Opt.sub_noise == 1
    [dfofInterp, meanImg, greenframe, figNum] = subtractSidebandNoise_DR(dfofInterp, meanImg, psfile, mv, figNum);
end


%% =========================================================================
%% SECTION 5: OPTIONAL Z-PLANE BINNING CORRECTION
%% =========================================================================

% zbinCorr accounts for z-plane motion artifacts by binning frames into
% z-position groups and computing corrected dF/F per group.
if isfield(Opt,'zbinning')
    zbin = Opt.zbinning;
else
    zbin = input('do zbinning? 0/1 : ');
end

if zbin
    [dfofInterp, meanImg, greenframe, mv, figNum] = zbinCorr_DR(dfofInterp, meanImg, greenframe, Opt, psfile, mv, figNum);
end


%% =========================================================================
%% SECTION 6: CROP IMAGE TO REMOVE ALIGNMENT BORDER ARTIFACTS
%% =========================================================================

% Compute how many pixels to discard on each edge based on max motion
% correction displacement. This removes the "rolled" border introduced by
% rigid alignment. spatialBin accounts for the downsampling applied during loading.
buffer(:,1) = max(mv,[],1)/cfg.spatialBin + 1;   buffer(buffer<1) = 1;
buffer(:,2) = max(-mv,[],1)/cfg.spatialBin + 1;  buffer(buffer<0) = 0;
buffer = round(buffer)
buffer(2,:) = buffer(2,:) + 32   % add 32-pixel deadband buffer on the second dimension

% Crop dF/F movie to remove alignment border artifacts
dfofInterp = dfofInterp(buffer(1,1):(end-buffer(1,2)), buffer(2,1):(end-buffer(2,2)), :);

% Crop the green (reference) channel image to match
stdImg = imresize(greenframe, 1/cfg.spatialBin);
stdImg = stdImg(buffer(1,1):(end-buffer(1,2)), buffer(2,1):(end-buffer(2,2)), :);
greenCrop = double(stdImg);   % convert to double for math operations

% Threshold mask: pixels dimmer than 1/50th of the 95th-percentile brightness
% are set to zero (they are likely outside the tissue or in very dim regions).
thresh = prctile(greenCrop(:), 95) / 50;
dfofInterp(repmat(greenCrop, [1 1 size(dfofInterp,3)]) < thresh) = 0;

% ---- FIGURE (not printed): Threshold Mask ----
% Shows which pixels pass the brightness threshold (white = included).
% Used for visual inspection only; not saved to PDF.
figure('Name', 'Threshold Mask (not printed)');
imagesc(greenCrop > thresh);


%% =========================================================================
%% SECTION 7: STIMULUS TIMING
%% =========================================================================

% cycLength: median number of imaging frames between stimulus onsets.
% This is the fundamental period of the stimulus cycle.
cycLength = median(diff(phasetimes)) / dt

% cycWindow: number of frames to extract around each cycle for analysis.
% At least 2 seconds worth, or the full cycle length (whichever is larger).
cycWindow = round(max(2/dt, cycLength));

% Rename phasetimes to stimTimes for clarity
stimTimes = phasetimes;

% Trim the dF/F movie to start ~1 second before the first stimulus
startFrame = round((stimTimes(1) - 1) / dt);
startTrim = startFrame;   % also store for use in suite2p ROI trimming
dfofInterp = dfofInterp(:, :, startFrame:end);

% Save the original stimulus times (before regularization below)
stimTimesOld = stimTimes - stimTimes(1) + 1;

% Regularize stimulus times: replace with evenly-spaced times derived from
% cycLength. This handles cases where recorded trigger times are slightly off.
% Trim to ensure at least one full cycWindow plus 3 sec padding remains at end.
stimTimes = 1:cycLength*dt:(size(dfofInterp,3) - cycWindow - 30) * dt;
stimTimes = stimTimes(stimTimes < max(stimTimesOld));

% ---- FIGURE Pg 4: Stimulus Timing Check ----
% Shows the time between consecutive stimulus triggers (both regularized and
% original), to verify consistent stimulus delivery. Title shows median ISI.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Stimulus Timing Check', figNum));
plot(diff(stimTimes)); hold on; plot(diff(stimTimesOld));
title(sprintf('Fig %d: Time Between Stim Triggers, median %0.03f s', figNum, median(diff(stimTimes))));
ylabel('secs');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 8: LOAD STIMULUS RECORD
%% =========================================================================

% Display file name for logging/debugging
fileName

% Prompt for stimulus record file if not provided
if ~isfield(Opt,'fStim')
    [Opt.fStim, Opt.pStim] = uigetfile('*.mat', 'stimulus record');
end

% Load stimulus record variables:
%   stimRec    - struct with fields: cond (condition per frame), ts (timestamps)
%   freq       - spatial frequency for each condition
%   orient     - orientation for each condition
%   contrast   - contrast for each condition
%   positionX  - x position for each condition (moving spots)
%   StimulusStr- string name of stimulus type
%   StimulusNum- integer code for stimulus type (used to disambiguate same nstim)
%   TempFreq   - temporal frequency for each condition
load(fullfile(Opt.pStim, Opt.fStim), 'stimRec', 'freq', 'orient', 'contrast', ...
     'positionX', 'StimulusStr', 'StimulusNum', 'TempFreq');

alignRecs = 1;

% Number of complete stimulus cycles available in the data
nCycles = length(stimTimes);

% Compute stimulus record timestamps relative to experiment start
stimT = stimRec.ts - stimRec.ts(1);

% Forward-fill any zero-valued condition codes (zeros indicate "same as previous")
for i = 1:length(stimRec.cond)
    if stimRec.cond(i) == 0
        stimRec.cond(i) = pastCond;
    else
        pastCond = stimRec.cond(i);
    end
end

% ---- FIGURE (not printed): Stimulus Order Overlap Check ----
% Plots the derivative of stimRec.cond alongside the 2-photon trigger times
% to verify that stimulus transitions align with trigger pulses.
figure('Name', 'Stimulus Order Overlap Check (not printed)');
plot(stimT(1:end-1), diff(stimRec.cond));
hold on
plot(cycLength*dt*(1:nCycles), 0, '*');

% ---- FIGURE Pg 5: Difference of PsychStim Frames ----
% Shows the inter-frame intervals from the stimulus computer's timestamps.
% Used to detect dropped frames or timing irregularities in the stimulus software.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Diff of PsychStim Frames', figNum));
plot(diff(stimT(stimT > 0)));
title(sprintf('Fig %d: Diff of PsychStim Frames', figNum)); ylabel('secs')
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 9: BUILD STIMULUS ORDER VECTOR
%% =========================================================================

% For each imaging cycle, determine which stimulus condition was presented
% by looking up the stimRec.cond at 0.1 sec after cycle onset.
for i = 1:nCycles
    stimOrder(i) = stimRec.cond(min(find(stimT > ((i-1)*cycLength*dt + 0.1))));
end

% ---- FIGURE (not printed): Stimulus Order vs stimRec.cond Overlap ----
% Plots stimOrder (derived above) against every-other-frame stimRec.cond.
% They should overlap for most cycles; divergence at the end is expected.
figure('Name', 'Stimulus Order vs stimRec.cond Overlap (not printed)');
hold on
plot(stimOrder)
plot(stimRec.cond(1:2:end));
ylabel('stimulus cond')
legend('stimOrder','stimRec.cond');
title('should overlap except end')

% Trim to the shorter of: number of trigger times or number of stimulus record cycles
nCycles = min(length(stimTimes), nCycles);
stimTimes = stimTimes(1:nCycles);

% Total number of unique stimulus conditions
nstim = max(stimOrder);
stimOrder = stimOrder(1:nCycles);

% Count how many times each stimulus was presented
for i = 1:nstim
    nStimRep(i) = sum(stimOrder == i);
end

% Compute total frames per full stimulus set, and number of complete repetitions
totalframes = cycLength * nstim;
reps = floor(size(dfofInterp,3) / totalframes);


%% =========================================================================
%% SECTION 10: CYCLIC PHASE/AMPLITUDE MAP (INTRINSIC SIGNAL ANALYSIS)
%% =========================================================================

% Compute the Fourier component at the stimulus cycle frequency for each pixel.
% This is a standard intrinsic signal imaging analysis that reveals which pixels
% respond at the stimulus frequency.
%   map     - complex image; abs = response amplitude, angle = response phase
%   cycPhase- phase of the periodic response (which part of cycle each pixel peaks)
%   cycAmp  - normalized amplitude of the periodic response
%   cycPolarImg - HSV color image of phase, weighted by amplitude

filt = fspecial('gaussian', 10, 1);   % Gaussian kernel for spatial smoothing
xy = size(dfofInterp(:,:,1));
map = zeros(xy);
nUsed = 0;

for iFrame = round(stimTimes(1)/dt):size(dfofInterp,3)
    % Only use frames that are not NaN (e.g. excluded by z-plane sorting)
    if ~isnan(dfofInterp(floor(xy(1)/2), floor(xy(2)/2), iFrame))
        nUsed = nUsed + 1;
        % Accumulate Fourier component at the cycle frequency
        map = map + imfilter(dfofInterp(:,:,iFrame), filt) * exp(2*pi*sqrt(-1)*iFrame/cycLength);
    end
end
map = map / nUsed;
map(isnan(map)) = 0;

amp = abs(map);               % amplitude image
maxAmp = prctile(amp(:), 99);
maxAmp = 0.025;               % fixed normalization (overrides percentile)
amp = amp / maxAmp;
amp(amp > 1) = 1;             % clip to [0, 1]

cycPhase = mod(angle(map), 2*pi);          % wrap phase to [0, 2pi]
img = mat2im(cycPhase, hsv, [0 2*pi]);     % map phase to HSV colormap
img = img .* repmat(amp, [1 1 3]);         % weight color by amplitude

cycAmp = amp;
cycPolarImg = img;

% ---- FIGURE Pg 6: Cyclic Phase/Amplitude Polar Map ----
% HSV color image showing the phase of periodic response at each pixel.
% Hue = which part of the stimulus cycle the pixel responds to.
% Saturation/value weighted by response amplitude (dim = weak response).
% Title shows cycle length and normalization amplitude.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Cyclic Phase/Amplitude Polar Map', figNum));
imshow(imresize(img, 2))
colormap(hsv); colorbar
title(sprintf('Fig %d: Cyclic Phase/Amplitude Polar Map  (%.03f frame cycle, %0.3f amp)', figNum, cycLength, maxAmp));
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 11: FULL IMAGE MEAN FLUORESCENCE TRACE
%% =========================================================================

% Compute mean dF/F across all pixels at each time point.
% This gives a population-level view of overall activity throughout the recording.
mfluorescence = squeeze(mean(mean(dfofInterp, 2), 1));

% ---- FIGURE Pg 7: Full Image Mean Fluorescence Over Time ----
% Line plot of spatially-averaged dF/F vs. time.
% Green vertical lines mark the end of each complete stimulus repetition set.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Full Image Mean Fluorescence Over Time', figNum));
plot((1:size(dfofInterp,3))*dt, mfluorescence);
title(sprintf('Fig %d: Full Image Mean Fluorescence Over Time', figNum)); hold on
for i = 1:reps
    plot([i*nstim*cycLength*dt  i*nstim*cycLength*dt], [0 0.5], 'g');
end
xlabel('secs'); ylabel('dfof');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 12: REFERENCE IMAGES (Green, Max dF/F, Merge)
%% =========================================================================

% ---- FIGURE Pg 8: Mean Green Channel ----
% Absolute fluorescence image of the preparation. Shows anatomy.
% Scaled between 1st and 95th percentiles of brightness.
% Also creates greenFig handle (used in manual ROI selection mode).
figNum = figNum + 1;
greenFig = figure('Name', sprintf('Fig %d - Mean Green Channel', figNum));

stdImg = imresize(greenframe, 1/cfg.spatialBin);
stdImg = stdImg(buffer(1,1):(end-buffer(1,2)), buffer(2,1):(end-buffer(2,2)), :);
greenCrop = double(stdImg);

imagesc(stdImg, [min(stdImg(:)) prctile(stdImg(:),95)*1.2]);
hold on; axis equal; colormap gray;

% Create normalized RGB version of green image for overlays
meanGreenImg = mat2im(greenCrop, gray, [prctile(greenCrop(:),1) prctile(greenCrop(:),99)*1.2]);

title(sprintf('Fig %d: Mean Green Channel', figNum));
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% Build a normalized green weighting image for green-weighted overlays.
% normgreen will be used in pixPlotWeight to weight pixel responses by anatomy.
stdImg = double(stdImg);
normgreen = (stdImg - prctile(stdImg(:),1)) / (prctile(stdImg(:),99)*1.5 - prctile(stdImg(:),1));
normgreenraw = normgreen;   % save raw version before scaling

normgreen = normgreen * 2;
normgreen(normgreen < 0) = 0;
normgreen(normgreen > 1) = 1;
normgreen = repmat(normgreen, [1 1 3]);   % expand to 3 channels for RGB operations

% ---- FIGURE Pg 9: Max dF/F Image ----
% Pixel-wise maximum dF/F across all time points, median-filtered for noise reduction.
% Highlights the most responsive pixels. Also creates maxFig handle.
figNum = figNum + 1;
maxFig = figure('Name', sprintf('Fig %d - Max dF/F Image', figNum));
stdImg = max(dfofInterp, [], 3);
stdImg = medfilt2(stdImg);
imagesc(stdImg, [prctile(stdImg(:),1) prctile(stdImg(:),99)]);
hold on; axis equal; colormap gray; title(sprintf('Fig %d: Max dF/F Image', figNum))
normMax = (stdImg - prctile(stdImg(:),1)) / (prctile(stdImg(~isinf(stdImg(:))),98) - prctile(stdImg(:),1));
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE Pg 10: Mean/Max Green Channel Merge ----
% RGB overlay combining anatomy (green channel, G) and max response (red channel, R).
% Red = high dF/F pixels, Green = bright anatomy pixels.
% Also creates mergeFig handle (used in manual ROI selection mode).
figNum = figNum + 1;
merge = zeros(size(stdImg,1), size(stdImg,2), 3);
merge(:,:,1) = normMax;        % Red channel = normalized max dF/F
merge(:,:,2) = normgreenraw;   % Green channel = anatomy
mergeFig = figure('Name', sprintf('Fig %d - Mean/Max Green Channel Merge', figNum));
imshow(merge); title(sprintf('Fig %d: Mean/Max Green Channel Merge', figNum))
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 13: ROI SELECTION
%% =========================================================================

% Call getOctoCells to select ROI points (cells/pixels to analyze).
% This script uses Opt.selectPts to determine the selection mode:
%   0 = automatic peak detection on the green image
%   1 = manual clicking on a reference figure
%   2 = suite2p output (fluorescence traces from suite2p segmentation)
%   3 = red/green ratio using suite2p output
%
% Returns (into workspace):
%   dF      - [nCells x T] dF/F traces for selected ROIs
%   x, y    - pixel coordinates of each ROI center
%   xpts, ypts - same as x, y (renamed copies)
%
% Figures produced by getOctoCells (page numbers continue from above):
%   selectPts==0/1: 2 figures — ROI Brightness Cutoff, Selected ROI Points
%   selectPts==2/3: 4 figures — Cell Classifier Scores, Max Projection, Good Cell Masks, k-means Histogram
% getOctoCells_DR manages figNum entirely internally — do NOT pre-increment here.
getOctoCells_DR


%% =========================================================================
%% SECTION 14: BASIC dF/F VISUALIZATION
%% =========================================================================

% Clip abnormally large dF/F values (can arise from movement artifacts)
dF(dF > 2) = 2;

% ---- FIGURE Pg 11 (selectPts==0 or 1): Fluorescence Traces ----
% All individual ROI dF/F traces overlaid in color.
% Green trace = population mean. X-axis in seconds.
% NOTE: print call is commented out in original - this may not appear in PDF.
figure('Name', 'Fluorescence Traces (not printed)')
plot((1:size(dF,2))*dt, dF');
hold on
plot((1:size(dF,2))*dt, mean(dF, 1, 'omitnan'), 'g', 'Linewidth', 2);
xlabel('secs'); ylabel('df/f'); title('Fluorescence Traces');
xlim([0 size(dF,2)*dt]);
%if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE Pg 12: Rigid Alignment Values ----
% X and Y displacement traces from the rigid motion correction algorithm.
% Large values indicate periods of significant animal movement.
if exist('mv','var')
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Rigid Alignment Values', figNum));
    plot(mv);
    title(sprintf('Fig %d: Rigid Alignment Values', figNum))
    xlabel('x displacement'); ylabel('y displacement');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
end


%% =========================================================================
%% SECTION 15: SORT DATA INTO STIMULUS REPEATS
%% =========================================================================

% dFrepeats(cell, time, rep): raw dF/F aligned to each stimulus presentation.
%   Dimensions: [nCells x (cycWindow * nstim) x max(nStimRep)]
%   Baseline-subtracted: each window is offset by its own first frame.
dFrepeats = zeros(size(dF,1), cycWindow*nstim, max(nStimRep)) + NaN;

% dFrepsAll(cell, time, stim, rep): same data organized per stimulus condition.
%   Dimensions: [nCells x cycWindow x nstim x max(nStimRep)]
%   Baseline-subtracted by median of first 5 frames.
dFrepsAll = zeros(size(dF,1), cycWindow, nstim, max(nStimRep)) + NaN;

for i = 1:nstim
    repList = find(stimOrder == i);
    for r = 1:nStimRep(i)
        startFrame = stimTimes(repList(r)) / dt;
        % Subtract frame at stimulus onset as baseline
        dFrepeats(:, (i-1)*cycWindow + (1:cycWindow), r) = ...
            dF(:, round(startFrame + (1:cycWindow))) - ...
            repmat(dF(:, round(startFrame+1)), [1 floor(cycWindow)]);
        % Subtract median of first 5 frames as baseline
        dFrepsAll(:, :, i, r) = ...
            dF(:, round(startFrame + (1:cycWindow))) - ...
            repmat(median(dF(:, round(startFrame + (1:5))), 2, 'omitnan'), [1 floor(cycWindow)]);
    end
end

% Clip extreme outliers in both arrays
dFrepeats(dFrepeats > 1)  =  1;
dFrepeats(dFrepeats < -1) = -1;
dFrepsAll(dFrepsAll > 1)  =  1;
dFrepsAll(dFrepsAll < -1) = -1;

% ---- FIGURE Pg 13: Mean Trace for Each Repeat ----
% Population mean dF/F timecourse for each individual repetition (colored lines).
% Green line = median across repetitions. Vertical dashed lines separate stimuli.
% X-axis units = stimulus number.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Mean Trace for Each Repeat', figNum));
plot((0:size(dFrepeats,2)-1)/cycWindow, squeeze(mean(dFrepeats,1)))
xlabel('stim #'); xlim([1 nstim+1]); ylim([-0.05 0.15])
title(sprintf('Fig %d: Mean Trace for Each Repeat', figNum));
hold on;
plot((0:size(dFrepeats,2)-1)/cycWindow, squeeze(mean(median(dFrepeats, 3, 'omitnan'),1)), 'g', 'Linewidth', 2)
for i = 1:nstim
    plot([i i], [0 0.3], 'k:');
end
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 16: CYCLE AVERAGES
%% =========================================================================

% Compute cycle averages: average response across all stimulus presentations
% aligned to a common time base.
%   cycAvgAll(cell, time) : mean timecourse per cell, averaged over all stims
%   cycAvg(time)          : grand mean over all cells and stims
%   cycImg(y, x, time)    : pixel-wise average across all stims (for pixel plots)

startFrames = round(stimTimes/dt) - 10;   % 10-frame pre-stim lead

clear cycAvgAll cycAvg cycImg
for i = 1:cycWindow
    cycAvgAll(:,i) = mean(dF(:, startFrames+i), 2, 'omitnan');         % mean across all stim for each cell
    cycAvg(i) = mean(mean(mean(dfofInterp(:,:,startFrames+i), 3, 'omitnan'), 2), 1);  % grand mean
    cycImg(:,:,i) = mean(dfofInterp(:,:,startFrames+i), 3, 'omitnan'); % pixel-wise mean
end

% ---- FIGURE Pg 14: Pixel-wise Cycle Average (Unweighted) ----
% Grid of up to 60 frames showing the pixel-wise mean dF/F timecourse.
% Each subplot is one frame of the average cycle. Baseline-subtracted.
% Layout: 5x6 grid (cycLength<=30) or 8x8 grid (cycLength>30).
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Pixel-wise Cycle Average (Unweighted)', figNum));
for i = 1:min(cycLength, 60)
    if cycLength <= 30
        subplot(5,6,i);
    else
        subplot(8,8,i)
    end
    data = cycImg(:,:,i) - mean(cycImg(:,:,1), 3);
    datafilt = imfilter(data, fspecial('gaussian',[10 10],2));
    imagesc(datafilt, [0 0.1]); axis equal; axis off
end
colorbar
sgtitle(sprintf('Fig %d: Pixel-wise Cycle Average (Unweighted)', figNum), 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE Pg 15: Pixel-wise Cycle Average (Green-weighted) ----
% Same as Pg 11 but each frame is multiplied by the normalized green anatomy image.
% This suppresses responses in non-tissue regions, highlighting tissue-specific signals.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Pixel-wise Cycle Average (Green-weighted)', figNum));
for i = 1:min(cycLength, 60)
    if cycLength <= 30
        subplot(5,6,i);
    else
        subplot(8,8,i)
    end
    data = cycImg(:,:,i) - mean(cycImg(:,:,1), 3);
    datafilt = imfilter(data, fspecial('gaussian',[10 10],2));
    datafilt(isnan(datafilt)) = 0;
    data_im = mat2im(datafilt, jet, [0 0.05]);
    imshow(data_im .* normgreen);
    axis equal; axis off
end
sgtitle(sprintf('Fig %d: Pixel-wise Cycle Average (Green-weighted)', figNum), 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE Pg 16: Cycle Average All Cells ----
% Single line plot of the population-mean cycle average timecourse.
% Shows the average temporal profile of dF/F across all cells and stims.
cycAvgAll = cycAvgAll - repmat(cycAvgAll(:,1), [1 size(cycAvgAll,2)]);  % baseline subtract
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Cycle Average All Cells', figNum));
plot((1:length(cycAvg))*dt, cycAvg);
title(sprintf('Fig %d: Cycle Average All Cells', figNum)); xlabel('time'); ylabel('dF')
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 17: PREPARE DATA FOR CLUSTERING
%% =========================================================================

% Compute median response across repetitions for each cell x time bin
dFmean = median(dFrepeats, 3, 'omitnan');   % [nCells x (cycWindow*nstim)]

% Build a trimmed/downsampled version of dFmean for clustering.
% Trimming: removes 2 frames from start and end of each cycle window (reduces edge artifacts).
% Downsampling: 0.5x temporal downsampling to improve SNR.
dFclust = zeros(size(dF,1), floor(cycWindow-4)*nstim, max(nStimRep)) + NaN;
for i = 1:nstim
    repList = find(stimOrder == i);
    for r = 1:nStimRep(i)
        dFclust(:, (i-1)*floor(cycWindow-4) + (1:floor(cycWindow-4)), r) = ...
            dF(:, round((repList(r)-1)*cycLength) + (3:floor(cycWindow-2))) - ...
            repmat(mean(dF(:, round((repList(r)-1)*cycLength) + (1:2)), 2), [1 floor(cycWindow-4)]);
    end
end
dFclust = median(dFclust, 3, 'omitnan');                     % median across repetitions
dFclust = imresize(dFclust, [size(dFclust,1) 0.5*size(dFclust,2)]);  % 2x temporal downsample
dFclust(dFclust > 0.2) = 0.2;
dFclust(dFclust < 0) = 0;                            % clip to [0, 0.2]

% ---- FIGURE (not printed): dFclust Heatmap ----
% Raw heatmap of the clustering input matrix (cells x time). Used for inspection.
figure('Name', 'dFclust Heatmap (not printed)');
imagesc(dFclust, [-0.05 0.2])


%% =========================================================================
%% SECTION 18: HIERARCHICAL CLUSTERING
%% =========================================================================

% Compute pairwise Euclidean distances between cells based on their average
% response timecourses, then build a hierarchical dendrogram.
dist = pdist(dFclust, 'euclidean');
display('doing cluster')
tic; Z = linkage(dist, 'ward'); toc   % Ward linkage minimizes within-cluster variance

% ---- FIGURE Pg 17: Sorted Cell Heatmap with Dendrogram ----
% Left panel (1/4 width): dendrogram showing hierarchical cluster structure.
% Right panel (3/4 width): dFmean heatmap with cells sorted by dendrogram leaf order.
%   Rows = cells (sorted), columns = time, color = dF/F magnitude.
%   Black vertical lines separate stimulus conditions.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Sorted Cell Heatmap with Dendrogram', figNum));
subplot(3,4,[1 5 9])
display('doing dendrogram')
[h, t, perm] = dendrogram(Z, 0, 'Orientation','Left', 'ColorThreshold', 1);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12]);
imagesc(dFmean(perm,:), [-0.1 0.4]); axis xy; xlabel('selected traces based on dF'); colormap jet;
hold on;
for i = 1:nstim
    plot([i*cycWindow i*cycWindow]+0.5, [1 length(perm)], 'k');
end
sgtitle(sprintf('Fig %d: Sorted Cell Heatmap with Dendrogram', figNum), 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 19: CLUSTER ASSIGNMENT
%% =========================================================================

% Get number of clusters from Opt or prompt user.
% Opt.nclust is consumed (removed) after use so it cannot silently carry over
% from a previous run in the same workspace and bypass the input prompt.
if isfield(Opt, 'nclust') && ~isempty(Opt.nclust)
    nclust = Opt.nclust;
    fprintf('Using Opt.nclust = %d (set before this run)\n', nclust);
    Opt = rmfield(Opt, 'nclust');   % consume so next run always prompts
else
    nclust = input('# of clusters : ');
end

% Iteratively increase the number of requested clusters until at least nclust
% clusters have more than 5 members. Clusters with <= 5 cells are relabeled
% as "noise cluster" (nclust+1).
%
% NOTE: cluster() uses 'maxclust' name-value syntax from the Statistics Toolbox.
% If a local cluster.m exists on the path (e.g. from ratrix/matlabClub), it will
% shadow the toolbox version and cause "Too many input arguments". The rmpath/addpath
% pair below temporarily suppresses any such shadowing file, then restores the path.
matlabClubPath = fileparts(which('cluster'));  % find the folder containing the shadowing cluster.m
if ~isempty(matlabClubPath)
    rmpath(matlabClubPath);
end

done = 0; ncAll = nclust;
while ~done
    c = cluster(Z, 'maxclust', ncAll);
    clear nc
    for i = 1:ncAll
        nc(i) = sum(c == i);
    end
    nc
    newc = c;
    if sum(nc > 5) >= nclust || ncAll > 20
        done = 1;
        goodclust = find(nc > 5);
        for i = 1:length(goodclust)
            newc(c == goodclust(i)) = i;
        end
        badclust = find(nc <= 5);
        if ~isempty(badclust)
            for i = 1:length(badclust)
                newc(c == badclust(i)) = nclust + 1;
            end
            nclust = nclust + 1;
        end
        c = newc;
    else
        ncAll = ncAll + 1
    end
end

% Restore the previously removed path entry
if ~isempty(matlabClubPath)
    addpath(matlabClubPath);
end

% Define a distinct color for each cluster using HSV colormap
colors = hsv(nclust + 1);

% ---- FIGURE Pg 18: Cluster Spatial Map ----
% Anatomy image (gray) with each cell's position marked by a colored circle.
% Color indicates cluster membership. Title shows total number of clusters.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Cluster Spatial Map', figNum));
imagesc(stdImg, [0 prctile(stdImg(:),95)]); colormap gray; axis equal; hold on
for clust = 1:nclust
    plot(x(c==clust), y(c==clust), 'o', 'Color', colors(clust,:));
end
title(sprintf('Fig %d: Cluster Spatial Map  (%u Clusters)', figNum, nclust));
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% Define cluster colors (re-using HSV but without the extra noise cluster)
cols = hsv(nclust);

% ---- FIGURE (suite2p only): Suite2p Cluster ROI Overlay ----
% Only produced when selectPts==2. Shows suite2p ROI masks color-coded by
% cluster assignment, overlaid on the mean green image (2x resolution).
if selectPts == 2
    img = imresize(meanGreenImg, 2);
    for j = 1:length(c)
        xpix = stat{j}.xpix;
        ypix = stat{j}.ypix;
        lam = stat{j}.lam;
        for i = 1:length(xpix)
            img(ypix(i), xpix(i), :) = cols(c(j),:) * lam(i)/max(lam);
        end
    end
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Suite2p Cluster ROI Overlay', figNum));
    imshow(img); title(sprintf('Fig %d: Suite2p Cluster ROI Overlay', figNum))
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
end


%% =========================================================================
%% SECTION 20: dF/F TRACES FOR RANDOM CELL SUBSET
%% =========================================================================

% Select 5 random cells from each cluster for the trace display.
% Cells are color-coded by their cluster membership.
np = 5;
for clust = 1:nclust
    cells = find(c == clust);
    cell_list((1:np) + (clust-1)*np) = cells(ceil(rand(np,1)*length(cells)));
    color_list((1:np) + (clust-1)*np, :) = repmat(cols(clust,:), [np 1]);
end

% ---- FIGURE Pg 19: dF/F Traces for Random Subset of Cells ----
% Stack of median-filtered dF/F traces, one per selected cell.
% Each trace is color-coded by its cluster. Traces are vertically offset.
% First 3000 frames shown; x-axis in seconds.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - dF/F Traces for Random Subset of Cells', figNum));
hold on
range = 1:min(3000, length(dF));
dtr = 0.1;
for i = 1:length(cell_list)
    plot(range*dtr - 50, medfilt1(3*dF(cell_list(i),range), 5) + (length(cell_list)+1) - i, ...
         'Color', 0.9*color_list(i,:));
end
ylim([0 np*nclust+2]); xlim([0 180]); xticks(0:60:180);
xlabel('secs'); ylabel('cell #'); title(sprintf('Fig %d: dF/F Traces (Random Subset)', figNum))
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 21: ORIENTATION SELECTIVITY MAP (suite2p + nstim==17 only)
%% =========================================================================

% This block only runs when using suite2p ROI selection with 17-condition gratings.
% Computes an orientation selectivity index (horiz vs. vert preference) per cell
% and maps it spatially onto the ROI masks.
if selectPts == 2 && nstim == 17

    dFrepsMn = median(dFrepsAll, 4, 'omitnan');                              % median over reps
    dFrepsTuning = squeeze(mean(dFrepsMn(:,10:20,:), 2, 'omitnan'));        % mean over evoked window

    vert  = mean(dFrepsTuning(:, [5 7 9]), 2, 'omitnan');                   % mean response to vertical gratings
    horiz = mean(dFrepsTuning(:, [13 15]), 2, 'omitnan');                   % mean response to horizontal gratings
    ds = (horiz - vert) ./ (horiz + vert);                          % direction selectivity index
    ds(ds < -1) = NaN;
    ds(ds > 1)  = NaN;

    % Histogram of DS index for cluster 2 (no print)
    figure('Name', 'DS Index Histogram Cluster 2 (not printed)');
    histogram(ds(c==2), -1:0.1:1);

    % Build spatial map of orientation preference on ROI masks.
    % Each cell's mask is colored by its preferred orientation (circular vector sum).
    img = zeros(size(ops.max_proj,1), size(ops.max_proj,2), 3);
    for j = 1:length(c)
        xpix = stat{j}.xpix;
        ypix = stat{j}.ypix;
        lam  = stat{j}.lam;
        onresp = dFrepsTuning(j, 1:2:15);
        amp(j) = max(onresp);
        onresp = onresp - min([0 onresp]);
        cv(j)  = sum(onresp .* exp((1:8)*pi/4 * sqrt(-1))) / sum(onresp);  % circular vector
        mag(j) = (abs(cv(j)) - 0.3) * 3;  mag(mag>1)=1; mag(mag<0)=0;
        ph(j)  = angle(cv(j)) / (2*pi);
        cm = interp1(-0.5:0.01:0.49, hsv(100), ph(j));              % phase -> color
        cm = cm * mag(j) + [1 1 1]*(1 - mag(j));                    % blend with white by magnitude
        for i = 1:length(xpix)
            img(ypix(i), xpix(i), :) = cm * lam(i)/max(lam);
        end
    end

    % ---- FIGURE (suite2p + nstim==17): Orientation Selectivity Map ----
    % ROI masks colored by orientation preference (HSV hue) and selectivity (saturation).
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Orientation Selectivity Map', figNum));
    imshow(img); title(sprintf('Fig %d: Orientation Selectivity Map', figNum))
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

end


%% =========================================================================
%% SECTION 22: PRE-CLUSTER SPOT TIMECOURSE FIGURES (nstim==48 only)
%% =========================================================================

% For 48-condition spot stimulus, plot population-level OFF and ON timecourses
% organized by spatial grid position. These appear before the per-cluster loop.
if nstim == 48
    loc = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24];
    for rep = 0:1
        % ---- FIGURE (nstim==48): Population Timecourses for OFF/ON Spots ----
        % 4x6 grid of subplots (one per spot location), arranged by spatial position.
        % rep=0 = OFF spot timecourses; rep=1 = ON spot timecourses.
        % Each subplot shows population-mean timecourse across all repetitions.
        % Color-coded by repetition number (jet colormap).
        if rep == 0; repLabel = 'OFF'; else; repLabel = 'ON'; end
        figNum = figNum + 1;
        figure('Name', sprintf('Fig %d - All Units %s Spot Timecourses (nstim=48)', figNum, repLabel));
        set(gcf, 'defaultAxesColorOrder', jet(size(dFrepsAll,4)));
        for cond = 1:24
            subplot(4,6,loc(cond))
            plot(squeeze(mean(dFrepsAll(:,:,cond + rep*24,:), 1, 'omitnan')));
            ylim([-0.05 0.25]);
        end
        sgtitle(sprintf('Fig %d: All Units  -  %s Spot Timecourses', figNum, repLabel), 'Interpreter', 'none');
        if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
    end
end


%% =========================================================================
%% SECTION 23: PER-CLUSTER SUMMARY FIGURES
%% =========================================================================
%
% For each cluster (1:nclust), produces a 4-panel summary figure plus
% optional stimulus-specific per-cluster figures.
% Page numbers shift with nclust; figures are named by cluster number.

for clust = 1:nclust

    % ---- FIGURE Cluster N Summary: Anatomy / Heatmap / Repeats / Cycle Average ----
    % 4-panel figure:
    %   Top-left    (2,2,1): Anatomy image with this cluster's cells marked.
    %   Top-right   (2,2,2): dFmean heatmap for this cluster (cells x time, jet colormap).
    %                         Black vertical lines separate stimulus conditions.
    %   Bottom-right(2,2,4): Mean timecourse for each repetition (colored), plus
    %                         median across reps (green). Vertical dotted lines = stim boundaries.
    %   Bottom-left (2,2,3): Individual cell cycle average timecourses (colored),
    %                         plus population mean (green).
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Cluster %d Summary', figNum, clust));

    subplot(2,2,1);
    imagesc(stdImg, [0 prctile(stdImg(:),99)*1.2]); axis equal; hold on; colormap gray; freezeColors;
    title(sprintf('Fig %d: Cluster %d  -  Anatomy', figNum, clust));
    plot(x(c==clust), y(c==clust), 'o', 'Color', cols(clust,:))

    subplot(2,2,2);
    imagesc(dFmean(c==clust,:), [-0.1 0.4]); axis xy
    title(sprintf('Cluster %d  -  dF/F Heatmap', clust)); hold on
    for i = 1:nstim
        plot([i*cycWindow i*cycWindow]+0.5, [1 sum(clust==c)], 'k');
    end
    colormap jet; freezeColors; colormap gray;

    subplot(2,2,4);
    plot((0:size(dFrepeats,2)-1)/cycWindow + 1, squeeze(mean(dFrepeats(c==clust,:,:), 1))); hold on
    plot((0:size(dFrepeats,2)-1)/cycWindow + 1, squeeze(mean(median(dFrepeats(c==clust,:,:), 3, 'omitnan'),1)), 'g','LineWidth',2)
    xlabel('stim #'); xlim([1 nstim+1]); ylim([-0.05 0.2])
    title(sprintf('Cluster %d  -  Mean by Repeat', clust));
    for i = 1:nstim
        plot([i i], [0 0.5], 'k:');
    end
    colormap jet; freezeColors; colormap gray;

    subplot(2,2,3);
    plot(cycAvgAll(c==clust,:)');
    hold on
    plot(mean(cycAvgAll(c==clust,:), 1, 'omitnan'), 'g', 'Linewidth', 2);
    title(sprintf('Cluster %d  -  Cycle Average', clust));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


    %% --- Stimulus-specific per-cluster figures ---

    if nstim == 16
        % ---- FIGURE Cluster N (nstim==16): 3x3 Condition Grid (rep=1, rep=0) ----
        % Two figures per cluster (one for each contrast polarity).
        % 3x3 grid layout (positions 1-9, center=5 is cluster label).
        % Each subplot: population mean timecourse for one direction x contrast condition.
        loc = [2 3 6 9 8 7 4 1];
        for rep = 1:-1:0
            if rep == 1; repLabel = 'High Contrast'; else; repLabel = 'Low Contrast'; end
            figNum = figNum + 1;
            figure('Name', sprintf('Fig %d - Cluster %d Direction Tuning %s', figNum, clust, repLabel));
            set(gcf, 'defaultAxesColorOrder', jet(size(dFrepsAll,4)));
            for cond = 1:8
                subplot(3,3,loc(cond))
                plot(squeeze(mean(dFrepsAll(c==clust,:,cond*2-rep,:), 1, 'omitnan')));
                ylim([-0.05 0.2]);
                title(sprintf('c %0.2f th %d', contrast(cond*2-rep), orient(cond*2-rep)))
            end
            subplot(3,3,5); title(sprintf('clust %d', clust))
            sgtitle(sprintf('Fig %d: Cluster %d  -  Direction Tuning (%s)', figNum, clust, repLabel), 'Interpreter', 'none');
            if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
        end
    end

    if nstim == 17
        % ---- FIGURE Cluster N (nstim==17): 3x3 Orientation Grid + Polar Tuning ----
        % Two figures per cluster (one per spatial frequency).
        % 3x3 grid layout with orientations arranged spatially (compass rose).
        % Center panel (pos 5): polar plot of orientation tuning curve.
        % Also produces a separate tuning curve line plot.
        tuning(clust,:) = median(mean(dFrepsAll(c==clust,5:15,:,:), [2 4], 'omitnan'), 1);

        loc = [3 2 1 4 7 8 9 6];
        r = 1:size(dFrepsAll,2);
        for rep = 1:-1:0
            if rep == 1; sfLabel = 'SF 1'; else; sfLabel = 'SF 2'; end
            figNum = figNum + 1;
            figure('Name', sprintf('Fig %d - Cluster %d Orientation Tuning %s', figNum, clust, sfLabel));
            set(gcf, 'defaultAxesColorOrder', jet(size(dFrepsAll,4)));
            for cond = 1:8
                subplot(3,3,loc(cond))
                plot((0:(length(r)-1))*dt, squeeze(mean(dFrepsAll(c==clust,r,cond*2-rep,:), 1, 'omitnan')));
                ylim([-0.05 0.25]);
            end
            subplot(3,3,8); xlabel('secs');
            subplot(3,3,4); ylabel('dF/F');
            subplot(3,3,5)
            ths = (45:45:405)*pi/180;
            polarplot(ths, tuning(clust,([2:2:16 2]) - rep), 'Color', 0.9*cols(clust,:));
            ax = gca; ax.RLim = [0 0.12]; ax.ThetaTick = 0:45:315; ax.RTick = [];
            sgtitle(sprintf('Fig %d: Cluster %d  -  Orientation Tuning (%s)', figNum, clust, sfLabel), 'Interpreter', 'none');
            if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

            % ---- FIGURE Cluster N (nstim==17): Orientation Tuning Curve ----
            % Line plot of mean dF/F vs. orientation angle (0-360 deg).
            figNum = figNum + 1;
            figure('Name', sprintf('Fig %d - Cluster %d Orientation Tuning Curve %s', figNum, clust, sfLabel));
            subplot(2,2,3);
            orient2 = [0, 45, 90, 135, 180, 225, 270, 315, 360];
            plot(orient2, tuning(clust,([2:2:16 2]) - rep), 'o-', 'Color', 0.9*cols(clust,:), ...
                 'LineWidth', 2, 'MarkerSize', 6);
            xlabel('Orientation (degrees)');
            ylabel('Tuning Strength (dF/F)');
            title(sprintf('Fig %d: Cluster %d  -  Tuning Curve (%s)', figNum, clust, sfLabel));
            xlim([0 360]); ylim([-0.01 0.15]); grid on;
            if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
        end
    end  % end nstim==17

    if nstim == 32 && StimulusNum == 2
        % ---- FIGURE Cluster N (nstim==32): 4x4 Direction Grid ----
        % Two figures per cluster (one per spot size/contrast).
        % 4x4 grid of subplots (one per direction x location condition).
        % Each subplot: population mean timecourse with title showing
        % contrast, position, and direction.
        loc = [1 9 8 16 2 10 7 15 3 11 6 14 4 12 5 13];
        for rep = 1:-1:0
            if rep == 1; repLabel = 'Size 1'; else; repLabel = 'Size 2'; end
            figNum = figNum + 1;
            figure('Name', sprintf('Fig %d - Cluster %d Direction x Position %s', figNum, clust, repLabel));
            set(gcf, 'defaultAxesColorOrder', jet(size(dFrepsAll,4)));
            for cond = 1:16
                subplot(4,4,loc(cond))
                plot(squeeze(mean(dFrepsAll(c==clust,:,cond*2-rep,:), 1, 'omitnan')));
                title(sprintf('c %0.1f loc %i dir %i', contrast(cond*2-rep), positionX(cond*2-rep), orient(cond*2-rep)));
                ylim([-0.05 0.25]);
            end
            sgtitle(sprintf('Fig %d: Cluster %d  -  Direction x Position (%s)', figNum, clust, repLabel), 'Interpreter', 'none');
            if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
        end
    end  % end nstim==32

    if nstim == 24 && StimulusNum == 1
        % ---- FIGURE Cluster N (nstim==24, SNum=1): 4x6 Condition Grid (cell mean) ----
        % 4x6 grid of subplots; one per grating condition (orientation x SF x TF).
        % Each subplot: per-cell mean timecourse for cells in this cluster.
        % Title per subplot shows orientation, SF, temporal frequency.
        figNum = figNum + 1;
        figure('Name', sprintf('Fig %d - Cluster %d Grating Timecourses Cell Mean', figNum, clust));
        set(gcf, 'defaultAxesColorOrder', jet(size(dFrepsAll,4)));
        for cond = 1:24
            subplot(4,6,cond)
            plot(squeeze(mean(dFrepsAll(c==clust,:,cond,:), 1, 'omitnan')));
            ylim([-0.025 0.1]);
            title(sprintf('%d %0.2f %d', orient(cond), freq(cond), TempFreq(cond)))
        end
        sgtitle(sprintf('Fig %d: Cluster %d  -  Grating Timecourses (Cell Mean)', figNum, clust), 'Interpreter', 'none');
        if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

        % ---- FIGURE Cluster N (nstim==24, SNum=1): 4x6 Condition Grid (pixel mean) ----
        % Same layout as above but averages over both cells and repetitions together.
        figNum = figNum + 1;
        figure('Name', sprintf('Fig %d - Cluster %d Grating Timecourses Pixel Mean', figNum, clust));
        for cond = 1:24
            subplot(4,6,cond)
            plot(squeeze(mean(dFrepsAll(c==clust,:,cond,:), [1 4], 'omitnan')));
            ylim([-0.025 0.1]);
            title(sprintf('%d %0.2f %d', orient(cond), freq(cond), TempFreq(cond)))
        end
        sgtitle(sprintf('Fig %d: Cluster %d  -  Grating Timecourses (Pixel Mean)', figNum, clust), 'Interpreter', 'none');
        if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
    end

    if nstim == 48
        % ---- FIGURE Cluster N (nstim==48): 4x6 OFF/ON Spot Timecourse Grid ----
        % Two figures per cluster (OFF spots: rep=0, ON spots: rep=1).
        % 4x6 grid of subplots arranged by spatial position in the spot grid.
        % Each subplot: cluster mean timecourse across all repetitions for that spot location.
        loc = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24];
        for rep = 0:1
            if rep == 0; repLabel = 'OFF'; else; repLabel = 'ON'; end
            figNum = figNum + 1;
            figure('Name', sprintf('Fig %d - Cluster %d %s Spot Timecourses', figNum, clust, repLabel));
            set(gcf, 'defaultAxesColorOrder', jet(size(dFrepsAll,4)));
            for cond = 1:24
                subplot(4,6,loc(cond))
                plot(squeeze(mean(dFrepsAll(c==clust,:,cond + rep*24,:), 1, 'omitnan')));
                ylim([-0.05 0.25]);
            end
            sgtitle(sprintf('Fig %d: Cluster %d  -  %s Spot Timecourses', figNum, clust, repLabel), 'Interpreter', 'none');
            if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
        end
    end

end  % end of for clust loop


%% =========================================================================
%% SECTION 24: POST-CLUSTER SUMMARY FIGURES (ALL CLUSTERS)
%% =========================================================================

% ---- FIGURE: Cycle Average Timecourse for All Clusters ----
% Overlaid line plots of the mean cycle-average timecourse for each cluster.
% Each cluster drawn in its HSV color. Shows differences in response timing.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Cycle Average All Clusters', figNum));
hold on
for clust = 1:nclust
    plot(mean(cycAvgAll(c==clust,:), 1, 'omitnan'), 'Color', colors(clust,:));
end
title(sprintf('Fig %d: Cycle Average Timecourse  -  All Clusters', figNum))
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE: Mean Response for Each Cluster Across All Stimuli ----
% Overlaid line plots of mean dF/F vs. stimulus number for each cluster.
% Vertical dotted lines separate stimulus conditions.
% Reveals which clusters respond to which stimuli.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Mean Response Per Cluster All Stimuli', figNum));
hold on
for clust = 1:nclust
    plot((0:size(dFrepeats,2)-1)/cycWindow + 1, mean(dFmean(c==clust,:,:), 1), 'Color', colors(clust,:));
end
for i = 1:nstim
    plot([i i], [0 0.2], 'k:');
end
title(sprintf('Fig %d: Mean Response Per Cluster  -  All Stimuli', figNum)); xlabel('stim #'); xlim([1 nstim+1])
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE: Correlation Matrix Across Cells After Clustering ----
% Pairwise correlation matrix of dFclust, with cells sorted by dendrogram order.
% Reveals the block structure introduced by clustering (similar cells group together).
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Correlation Matrix After Clustering', figNum));
imagesc(corrcoef(dFclust(perm,:)'), [-1 1]); colormap jet
title(sprintf('Fig %d: Correlation Matrix Across Cells After Clustering', figNum)); colorbar
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE (not printed): Max dF/F Histogram ----
% Distribution of each cell's maximum dF/F value across the clustering window.
% Used to inspect the range of response amplitudes across the population.
figure('Name', 'Max dF/F Histogram (not printed)');
histogram(max(dFclust,[],2))


%% =========================================================================
%% SECTION 25: PIXEL-WISE STIMULUS RESPONSE MAPS (STIMULUS-SPECIFIC)
%% =========================================================================
% The following section computes pixel-wise mean response images and
% timecourses for each stimulus condition, then calls pixPlot / pixPlotWeight
% to produce grids of these maps. The specific figures depend on nstim.

display('doing pixel plots')

% Flags and time window parameters for pixel plot computation
gratingTitle = 0;                   % 1 = add grating parameter labels to subplot titles
evRange  = 10:20;                   % frames for evoked response window
baseRange = 1:5;                    % frames for baseline window
tcRange  = cycWindow + 5;           % timecourse range
tcRange  = max(30, tcRange);
evRange  = 6:tcRange;

if cycWindow > 50
    evRange = 10:50;
    tcRange = cycWindow + 10;
end

% Clip extreme dF/F values before pixel analysis
dfofInterp(dfofInterp > 1)  = 1;
dfofInterp(dfofInterp < -1) = -1;

% Spatially downsample dF/F for pixel plots (0.25x = much faster)
dfInterpsm = imresize(dfofInterp, 0.25);

% Green-weighted version: multiply downsampled dF/F by anatomy weight at each pixel
dfWeight = dfInterpsm .* repmat(imresize(normgreen(:,:,1), 0.25), [1 1 size(dfofInterp,3)]);

% Compute pixel-wise evoked response and timecourse for each stimulus presentation
for i = 1:length(stimOrder)
    startFrame = (stimTimes(i) - 0.5) / dt;
    % trialmean: mean evoked response minus baseline, per stimulus presentation
    trialmean(:,:,i)  = mean(dfofInterp(:,:,round(startFrame + evRange)), 3, 'omitnan') - ...
                        mean(dfofInterp(:,:,round(startFrame + baseRange)), 3, 'omitnan');
    % trialTcourse: spatially-averaged dF/F timecourse per stimulus presentation
    trialTcourse(:,i) = squeeze(mean(mean(dfofInterp(:,:,round(startFrame + (1:tcRange))), 2), 1)) - ...
                        mean(mean(dfofInterp(:,:,round(startFrame + 1)), 2), 1);
    % weightTcourse: anatomy-weighted version of trialTcourse
    weightTcourse(:,i) = (squeeze(mean(mean(dfWeight(:,:,round(startFrame + (1:tcRange))), 2), 1)) - ...
                          mean(mean(mean(dfWeight(:,:,round(startFrame + baseRange)), 3), 2), 1)) / mean(normgreen(:));
end
filt = fspecial('gaussian', 5, 1.5);
trialmean = imfilter(trialmean, filt);   % spatial smoothing of response maps


%% --- nstim==12: 6 OFF + 6 ON spot locations ---
range = [-0.02 0.1];
if nstim == 12
    loc = [1 4 2 5 3 6];   % map stimulus condition number to 2x3 subplot position

    % ---- FIGURE (nstim==12): OFF Spots Grid ----
    % 2x3 grid of pixel-wise mean dF/F maps for the 6 OFF spot positions.
    % Subplot positions arranged to correspond to spatial screen layout.
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - OFF Spots Pixel Map (nstim=12)', figNum));
    for i = 1:6
        meanimg = median(trialmean(:,:,stimOrder==i), 3);
        subplot(2,3,loc(i));
        imagesc(meanimg, range); axis equal
        stimImg(:,:,i) = meanimg;
    end
    sgtitle(sprintf('Fig %d: OFF Spots Pixel Map', figNum), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE (nstim==12): ON Spots Grid ----
    % Same layout as above for the 6 ON spot positions (conditions 7-12).
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - ON Spots Pixel Map (nstim=12)', figNum));
    for i = 7:12
        meanimg = median(trialmean(:,:,stimOrder==i), 3);
        subplot(2,3,loc(i-6));
        imagesc(meanimg, range); axis equal
        stimImg(:,:,i) = meanimg;
    end
    sgtitle(sprintf('Fig %d: ON Spots Pixel Map', figNum), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
end


%% --- nstim==14: gratings (horiz/vert, 3 SF, 2 TF) + flicker ---
range = [-0.05 0.2];
if nstim == 14
    % ---- FIGURE (nstim==14): Vertical Gratings Pixel Map + Timecourses ----
    % pixPlot produces 2 figures: (1) 2x3 grid of pixel-wise mean response maps,
    % (2) 2x3 grid of individual trial timecourses. Both labeled 'vert gratings'.
    loc = 1:6;
    figLabel = 'vert gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 0;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;   % pixPlot_DR prints 2 figs

    % ---- FIGURE (nstim==14): Horizontal Gratings Pixel Map + Timecourses ----
    loc = 1:6;
    figLabel = 'horiz gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 6;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==14): Flicker Pixel Map + Timecourses ----
    loc = 1:2;
    figLabel = 'flicker';
    npanel = 2; nrow = 1; ncol = 2; offset = 12;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==14, not printed): RGB Overlay (Vert / Horiz / Flicker) ----
    % RGB image where R=vert1, G=horiz1, B=flicker response. Shows which pixels
    % respond to each grating type. Not printed to PDF.
    overlay(:,:,1) = median(trialmean(:,:,stimOrder==1), 3, 'omitnan');
    overlay(:,:,2) = median(trialmean(:,:,stimOrder==7), 3, 'omitnan');
    overlay(:,:,3) = median(trialmean(:,:,stimOrder==13), 3, 'omitnan');
    overlay(overlay < 0) = 0; overlay = overlay / range(2);
    figure('Name', 'RGB Overlay Vert/Horiz/Flicker (not printed)');
    imshow(imresize(overlay, 2));

    % ---- FIGURE (nstim==14, not printed): RGB Overlay (Vert / Horiz only) ----
    % Same as above but blue channel set to zero (R=vert, G=horiz only).
    figure('Name', 'RGB Overlay Vert/Horiz only (not printed)');
    overlay(:,:,3) = 0;
    imshow(imresize(overlay, 2));
end


%% --- nstim==26: gratings (4 directions, 3 SF, 2 TF) + flicker ---
range = [-0.05 0.2];
if nstim == 26
    % ---- FIGURE (nstim==26): Vertical 1 Gratings Pixel Map + Timecourses ----
    loc = 1:6; figLabel = 'vert1 gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 0;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==26): Horizontal 1 Gratings Pixel Map + Timecourses ----
    loc = 1:6; figLabel = 'horiz1 gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 6;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==26): Vertical 2 Gratings Pixel Map + Timecourses ----
    loc = 1:6; figLabel = 'vert2 gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 12;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==26): Horizontal 2 Gratings Pixel Map + Timecourses ----
    loc = 1:6; figLabel = 'horiz2 gratings';
    npanel = 6; nrow = 2; ncol = 3; offset = 18;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==26): Flicker Pixel Map + Timecourses ----
    loc = 1:2; figLabel = 'flicker';
    npanel = 2; nrow = 1; ncol = 2; offset = 24;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;
end


%% --- nstim==13: gratings (4 orient x 3 SF, 1 TF) + flicker ---
if nstim == 13
    range = [-0.05 0.2];
    loc = [1 5 9 2 6 10 3 7 11 4 8 12];   % map stim order to 3x4 grid position

    % ---- FIGURE (nstim==13): Gratings Pixel Map ----
    % pixPlot: 3x4 grid of pixel-wise mean response maps per grating condition.
    % ---- FIGURE (nstim==13): Gratings Trial Timecourses ----
    % pixPlot: 3x4 grid of individual trial timecourses per grating condition.
    figLabel = 'gratings'; npanel = 12; nrow = 3; ncol = 4; offset = 0;
    gratingTitle = 1;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==13): Gratings Weighted Timecourses ----
    % pixPlotWeight: 3x4 grid of green-weighted pixel maps + timecourses per grating condition.
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==13): Flicker Pixel Map ----
    % ---- FIGURE (nstim==13): Flicker Trial Timecourses ----
    figLabel = 'flicker'; npanel = 1; nrow = 1; ncol = 1; offset = 12;
    gratingTitle = 0;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==13): Flicker Weighted Timecourses ----
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;

    % Run the grating preference overlay analysis
    mapGratingsOcto_DR;

    % ---- FIGURE (nstim==13): mapGratingsOcto Summary Panel ----
    % 2x2 panel combining:
    %   Top-left     : Mean green anatomy image
    %   Top-right    : Phase/green channel overlay (from mapGratingsOcto: overlayImg)
    %   Bottom-left  : Cyclic phase polar map (cycPolarImg)
    %   Bottom-right : Horizontal vs. vertical grating preference color map (hvImg)
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Grating Preference Summary Panel (nstim=13)', figNum));
    subplot(2,2,1); imshow(meanGreenImg);
    subplot(2,2,2); imshow(overlayImg);
    subplot(2,2,3); imshow(cycPolarImg); title('Cyclic Phase Polar Map')
    subplot(2,2,4); imshow(hvImg); title('Horiz vs Vert Preference')
    sgtitle(sprintf('Fig %d: Grating Preference Summary', figNum), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
end


%% --- nstim==16, StimulusNum==2: 16-condition bars (8 directions x 2 contrast) ---
if nstim == 16 && StimulusNum == 2
    range = [-0.05 0.2];
    figLabel = 'bars';
    loc = [1 9 2 10 3 11 4 12 5 13 6 14 7 15 8 16];  % interleave low/high contrast
    npanel = 16; nrow = 4; ncol = 4; offset = 0;
    gratingTitle = 0;
    for i = 1:16; titles{i} = sprintf('c %0.1f th %d', contrast(i), orient(i)); end

    % ---- FIGURE (nstim==16): Bars Pixel Map ----
    % pixPlot: 4x4 grid of pixel-wise mean response maps for each bar condition.
    % ---- FIGURE (nstim==16): Bars Trial Timecourses ----
    % pixPlot: 4x4 grid of trial timecourses for each bar condition.
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==16): Bars Weighted Timecourses ----
    % pixPlotWeight: 4x4 grid of green-weighted timecourses.
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==16): OFF Mean Response Map ----
    % Mean pixel response across all OFF (contrast=-1) bar conditions.
    off_mn = mean(trialmean(:,:,contrast(stimOrder)==-1), 3, 'omitnan');
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - OFF Mean Response Map (nstim=16)', figNum));
    imagesc(off_mn, [-0.01 0.1]); title(sprintf('Fig %d: OFF Mean Response Map', figNum)); colormap jet; colorbar
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE (nstim==16): ON Mean Response Map ----
    % Mean pixel response across all ON (contrast=+1) bar conditions.
    on_mn = mean(trialmean(:,:,contrast(stimOrder)==1), 3, 'omitnan');
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - ON Mean Response Map (nstim=16)', figNum));
    imagesc(on_mn, [-0.01 0.1]); title(sprintf('Fig %d: ON Mean Response Map', figNum)); colormap jet; colorbar
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE (nstim==16): Vertical Mean Response Map ----
    % Mean pixel response for vertical bars (0 or 180 deg), ON contrast only.
    vert_mn = mean(trialmean(:,:,(orient(stimOrder)==0 | orient(stimOrder)==180) & contrast(stimOrder)==1), 3, 'omitnan');
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Vertical Mean Response Map (nstim=16)', figNum));
    imagesc(vert_mn, [-0.01 0.1]); title(sprintf('Fig %d: Vertical Mean Response Map', figNum)); colormap jet; colorbar
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE (nstim==16): Horizontal Mean Response Map ----
    % Mean pixel response for horizontal bars (90 or 270 deg), ON contrast only.
    horiz_mn = mean(trialmean(:,:,orient(stimOrder)==90 | orient(stimOrder)==270 & contrast(stimOrder)==1), 3, 'omitnan');
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Horizontal Mean Response Map (nstim=16)', figNum));
    imagesc(horiz_mn, [-0.01 0.1]); title(sprintf('Fig %d: Horizontal Mean Response Map', figNum)); colormap jet; colorbar
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE (nstim==16): Horizontal Minus Vertical Difference Map ----
    % Pixel-wise difference of horizontal and vertical mean responses.
    % Positive = horizontal preference, negative = vertical preference.
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Horiz Minus Vert Difference Map (nstim=16)', figNum));
    imagesc(horiz_mn - vert_mn, [-0.1 0.1]); title(sprintf('Fig %d: Horizontal Minus Vertical Response', figNum)); colormap jet; colorbar
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % Compute mean tuning per cluster (used for tuning curves below)
    for cl = 1:nclust
        tuning(cl,:) = mean(dFrepsAll(c==cl, 10:end, :, :), [1 2 4], 'omitnan');
    end

    % ---- FIGURE (nstim==16): OFF/ON Tuning Curves by Cluster ----
    % Two subplots: (top) OFF tuning curves per cluster vs. direction;
    %               (bottom) ON tuning curves per cluster vs. direction.
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - OFF/ON Tuning Curves by Cluster (nstim=16)', figNum));
    subplot(2,1,1)
    plot(0:45:315, tuning(:,1:2:16)); ylim([-0.025 0.1])
    title('OFF Tuning by Cluster'); xlabel('theta');
    subplot(2,1,2)
    plot(0:45:315, tuning(:,2:2:16)); ylim([-0.05 0.2])
    title('ON Tuning by Cluster'); xlabel('theta')
    sgtitle(sprintf('Fig %d: OFF/ON Tuning Curves by Cluster', figNum), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
end


%% --- nstim==17: gratings (4 SF x 4 orient or 2 SF x 8 orient) + flicker ---
if nstim == 17
    range = [-0.05 0.2];
    loc = [1 5 9 13 2 6 10 14 3 7 11 15 4 8 12 16];   % map stim to 4x4 grid

    % ---- FIGURE (nstim==17): Gratings Pixel Map ----
    % pixPlot: 4x4 grid of pixel-wise mean response maps.
    % ---- FIGURE (nstim==17): Gratings Trial Timecourses ----
    % pixPlot: 4x4 grid of individual trial timecourses.
    figLabel = 'gratings'; npanel = 16; nrow = 4; ncol = 4; offset = 0;
    gratingTitle = 1;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==17): Gratings Weighted Timecourses ----
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==17): Flicker Pixel Map ----
    % ---- FIGURE (nstim==17): Flicker Trial Timecourses ----
    figLabel = 'flicker'; npanel = 1; nrow = 1; ncol = 1; offset = 16;
    gratingTitle = 0;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==17): Flicker Weighted Timecourses ----
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;
end

% Additional 2-SF tuning maps (only when nstim==17 AND exactly 2 unique SFs)
if nstim == 17 && length(unique(freq)) == 2
    sfs   = unique(freq);
    freqs = [freq 0];       % append 0 for the flicker condition
    orients = [orient NaN]; % append NaN for flicker

    % ---- FIGURE (nstim==17, 2SF): SF Map 1 (low SF mean response) ----
    % Pixel-wise mean response for all conditions at the first (lower) SF.
    % ---- FIGURE (nstim==17, 2SF): SF Map 2 (high SF mean response) ----
    % Same for the second (higher) SF.
    for i = 1:2
        meanimg(:,:,i) = median(trialmean(:,:,freqs(stimOrder)==sfs(i)), 3, 'omitnan');
        figNum = figNum + 1;
        figure('Name', sprintf('Fig %d - SF %d Mean Response Map (nstim=17)', figNum, i));
        imagesc(meanimg(:,:,i), [-0.05 0.1]); colormap jet;
        title(sprintf('Fig %d: SF %d Mean Response Map  (sf = %0.02f)', figNum, i, sfs(i)));
        if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
    end

    % Compute SF preference index: (highSF - lowSF) / (highSF + lowSF)
    mn = mean(meanimg, 3);
    sfpref = (meanimg(:,:,2) - meanimg(:,:,1)) ./ (meanimg(:,:,2) + meanimg(:,:,1));
    sfpref(isnan(sfpref)) = 0;
    im = mat2im(sfpref, jet, [-0.5 0.5]);
    amp = mn/0.1; amp(amp<0)=0; amp(amp>1)=1;
    sf_img = im .* repmat(amp,[1 1 3]);
    sf_mean = meanimg;
    sf_amp  = sf_mean/0.1; sf_mean(sf_mean<0)=0; sf_mean(sf_mean>1)=1;

    % ---- FIGURE (nstim==17, 2SF): SF Preference Map ----
    % Color image of SF preference index weighted by mean response amplitude.
    % Blue = low SF preference, yellow = high SF preference.
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - SF Preference Map (nstim=17)', figNum));
    imshow(sf_img); title(sprintf('Fig %d: SF Preference Map  (blue=low SF, yellow=high SF)', figNum))
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % Compute flicker response map
    maxamp = 0.1;
    flicker = median(trialmean(:,:,stimOrder==17), 3, 'omitnan');
    flicker_amp = flicker/maxamp; flicker_amp(flicker_amp<0)=0; flicker_amp(flicker_amp>1)=1;

    % ---- FIGURE (nstim==17, 2SF): Flicker Response Map (imagesc, not printed) ----
    figure('Name', 'Flicker Response Map raw (not printed)');
    imagesc(flicker)   % raw flicker response - not printed

    % ---- FIGURE (nstim==17, 2SF): Full-field Flicker Response Map ----
    % Color image of flicker response amplitude, parula colormap weighted by amplitude.
    im = mat2im(flicker, parula, [0 0.2]);
    flicker_img = im .* repmat(flicker_amp, [1 1 3]);
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Full-field Flicker Response Map (nstim=17)', figNum));
    imshow(flicker_img); colorbar; title(sprintf('Fig %d: Full-field Flicker Response Map', figNum))
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE (nstim==17, 2SF): SF + Flicker Merge Map ----
    % RGB image where: R = flicker response, G = low SF response, B = high SF response.
    % Shows relative dominance of each response type across pixels.
    sf_flick = zeros(size(flicker_img));
    sf_flick(:,:,1) = flicker_amp;
    sf_mean_amp = sf_mean/maxamp; sf_mean_amp(sf_mean_amp<0)=0; sf_mean_amp(sf_mean_amp>1)=1;
    sf_flick(:,:,2:3) = sf_mean_amp;
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - SF + Flicker Merge Map (nstim=17)', figNum));
    imshow(sf_flick); title(sprintf('Fig %d: SF + Flicker Merge  (red=full-field; green=low SF; blue=high SF; amp=%0.1f)', figNum, maxamp));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE (nstim==17, 2SF): Orientation Preference Vertical Map ----
    % Pixel-wise mean response for vertical gratings (0 or 180 deg), both SFs.
    vert  = median(trialmean(:,:,orients(stimOrder)==0  | orients(stimOrder)==180), 3, 'omitnan');
    horiz = median(trialmean(:,:,orients(stimOrder)==90 | orients(stimOrder)==270), 3, 'omitnan');
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Vertical Grating Mean Response (nstim=17)', figNum));
    imagesc(vert, [-0.05 0.1]); colormap jet; title(sprintf('Fig %d: Vertical Grating Mean Response', figNum)); colorbar
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE (nstim==17, 2SF): Orientation Preference Horizontal Map ----
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Horizontal Grating Mean Response (nstim=17)', figNum));
    imagesc(horiz, [-0.05 0.1]); colormap jet; title(sprintf('Fig %d: Horizontal Grating Mean Response', figNum)); colorbar
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE (nstim==17, 2SF): Orientation Preference Map ----
    % Color image of vert/horiz preference index weighted by mean amplitude.
    % Blue = horizontal preference, yellow = vertical preference.
    mn = 0.5*(vert + horiz);
    orientpref = (vert - horiz) ./ (vert + horiz);
    orientpref(isnan(orientpref)) = 0;
    im = mat2im(orientpref, jet, [-0.5 0.5]);
    amp = mn/0.1; amp(amp<0)=0; amp(amp>1)=1;
    orient_img = im .* repmat(amp,[1 1 3]);
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Orientation Preference Map (nstim=17)', figNum));
    imshow(orient_img); title(sprintf('Fig %d: Orientation Preference Map  (blue=horiz, yellow=vert)', figNum));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % ---- FIGURE Cluster N (nstim==17, 2SF): 4x4 Condition Grid (per cluster) ----
    % One figure per cluster. 4x4 grid showing heatmap of mean response
    % (cells x time) for each of the 16 grating conditions.
    for cl = 1:nclust
        figNum = figNum + 1;
        figure('Name', sprintf('Fig %d - Cluster %d 4x4 Grating Heatmaps (nstim=17)', figNum, cl));
        for cond = 1:16
            subplot(4,4,cond);
            imagesc(squeeze(mean(dFrepsAll(c==cl,:,cond,:), 1))', [-0.05 0.2]);
        end
        sgtitle(sprintf('Fig %d: Cluster %d  -  Grating Condition Heatmaps', figNum, cl), 'Interpreter', 'none');
    end

    % Compute per-cluster tuning
    for cl = 1:nclust
        tuning(cl,:) = median(mean(dFrepsAll(c==cl, 10:20, :, :), [2 4], 'omitnan'), 1);
    end

    % ---- FIGURE (nstim==17, 2SF): Low/High SF Tuning Curves by Cluster ----
    % Two subplots: (top) tuning curves at low SF per cluster;
    %               (bottom) tuning curves at high SF per cluster.
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Low/High SF Tuning Curves by Cluster (nstim=17)', figNum));
    subplot(2,1,1)
    plot(0:45:315, tuning(:,1:2:16)); ylim([-0.05 0.2])
    title('Low SF Tuning by Cluster'); xlabel('theta');
    subplot(2,1,2)
    plot(0:45:315, tuning(:,2:2:16)); ylim([-0.05 0.2])
    title('High SF Tuning by Cluster'); xlabel('theta')
    sgtitle(sprintf('Fig %d: Low/High SF Tuning Curves by Cluster', figNum), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
end


%% --- Mean weighted response per stimulus (used for tuning curves below) ---
for i = 1:nstim
    meanResp(i) = mean(median(weightTcourse(8:25, stimOrder==i), 2, 'omitnan'), 1, 'omitnan');
end


%% --- nstim==24, StimulusNum==1: gratings (4 orient x 2 SF x 3 TF) ---
if nstim == 24 && StimulusNum == 1
    loc = 1:24; figLabel = 'gratings';
    npanel = 24; nrow = 4; ncol = 6; offset = 0;
    gratingTitle = 1;

    % ---- FIGURE (nstim==24, SNum=1): Gratings Pixel Map ----
    % pixPlot: 4x6 grid of pixel-wise mean response maps.
    % ---- FIGURE (nstim==24, SNum=1): Gratings Trial Timecourses ----
    % pixPlot: 4x6 grid of trial timecourses.
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==24, SNum=1): Gratings Weighted Timecourses ----
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;

    % Add orientation/SF/TF labels to the weighted timecourse subplots
    for i = 1:24
        subplot(4,6,i);
        title(sprintf('%d %0.2f %d', orient(i), freq(i), TempFreq(i)));
    end
end


%% --- nstim==29: gratings (4 SF x 7 orient) + flicker + SF tuning curve ---
if nstim == 29
    range = [-0.05 0.2];
    loc = [1 5 9 13 17 21 25 2 6 10 14 18 22 26 3 7 11 15 19 23 27 4 8 12 16 20 24 28];

    % ---- FIGURE (nstim==29): Gratings Pixel Map ----
    % pixPlot: 7x4 grid of pixel-wise mean response maps.
    % ---- FIGURE (nstim==29): Gratings Trial Timecourses ----
    figLabel = 'gratings'; npanel = 28; nrow = 7; ncol = 4; offset = 0;
    gratingTitle = 1;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==29): Gratings Weighted Timecourses ----
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==29): Flicker Pixel Map ----
    % ---- FIGURE (nstim==29): Flicker Trial Timecourses ----
    figLabel = 'flicker'; npanel = 1; nrow = 1; ncol = 1; offset = 28;
    gratingTitle = 0;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==29): Flicker Weighted Timecourses ----
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==29): SF Tuning Curve ----
    % Population mean weighted response vs. spatial frequency (log scale).
    % X-axis: 8 SF values from 0 (flicker) to 0.64 cpd.
    for i = 1:7
        tuning(i+1) = mean(meanResp(i+0:7:21), 'omitnan');
    end
    tuning(1) = meanResp(29);
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - SF Tuning Curve (nstim=29)', figNum));
    plot(tuning);
    xlabel('SF'); ylabel('mean dF/F'); ylim([0 0.05])
    title(sprintf('Fig %d: SF Tuning Curve  -  Weighted Mean Response', figNum));
    set(gca,'Xtick',1:8);
    set(gca,'Xticklabel',{'0','0.01','0.02','0.04','0.08','0.16','0.32','0.64'})
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
end


%% --- nstim==32, StimulusNum==2: moving spots (4 directions x 4 locations x 2 sizes) ---
if nstim == 32 && StimulusNum == 2
    range = [-0.05 0.2];
    loc = 1:32;
    loc(1:2:end) = 1:16; loc(2:2:end) = 17:32;   % interleave two spot sizes in grid
    figLabel = 'spots'; offset = 0;
    npanel = 32; ncol = 8; nrow = 4;

    % ---- FIGURE (nstim==32): Spots Pixel Map ----
    % pixPlot: 4x8 grid of pixel-wise mean response maps.
    % ---- FIGURE (nstim==32): Spots Trial Timecourses ----
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==32): Spots Weighted Timecourses ----
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;

    % Add contrast/position/direction labels to weighted timecourse subplots
    for i = 1:32
        subplot(4,8,i);
        title(sprintf('c %0.1f loc %i dir %i', contrast(i), positionX(i), orient(i)));
    end
end


%% --- nstim==48: 6x4 spot grid (OFF + ON retinotopy) ---
if nstim == 48
    range = [-0.05 0.2];
    loc = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24];

    % ---- FIGURE (nstim==48): OFF Spots Pixel Map ----
    % pixPlot: 4x6 grid of pixel-wise mean response maps for OFF spot locations.
    % ---- FIGURE (nstim==48): OFF Spots Trial Timecourses ----
    figLabel = 'OFF spots'; npanel = 24; nrow = 4; ncol = 6; offset = 0;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==48): OFF Spots Weighted Timecourses ----
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==48): ON Spots Pixel Map ----
    % ---- FIGURE (nstim==48): ON Spots Trial Timecourses ----
    figLabel = 'ON spots'; npanel = 24; nrow = 4; ncol = 6; offset = 24;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==48): ON Spots Weighted Timecourses ----
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;

    % octoRetinotopy_DR exports 4 figures (X/Y map x OFF/ON) and manages
    % figNum entirely internally — do NOT pre-increment here.
    octoRetinotopy_DR;

    % ---- FIGURE (nstim==48): Retinotopy Summary Panel (rep 1 = OFF) ----
    % ---- FIGURE (nstim==48): Retinotopy Summary Panel (rep 2 = ON) ----
    % Each: 2x2 panel combining anatomy, retinotopy overlay, X map, Y map.
    % Manual axes positioning for tight inter-column spacing.
    %
    % Design notes:
    %   - axis(ax,'image') is NOT used: it re-insets the axes box internally,
    %     overriding the Position we set and cropping/hiding panels (especially
    %     the X and Y maps in rows 2).  Instead we lock XLim/YLim to pixel
    %     extents and set DataAspectRatio=[1 1 1] so pixels are square without
    %     the axes resizing itself.
    %   - title() steals space from inside the axes box when the box is small.
    %     Labels are placed as annotation textboxes ABOVE each panel so they
    %     sit in the gap between the panel top and the row above.
    repLabels48 = {'OFF', 'ON'};
    retinoImgs48 = { {meanGreenImg, topoOverlayImg{1}, xpolarImg{1}, ypolarImg{1}}, ...
                     {meanGreenImg, topoOverlayImg{2}, xpolarImg{2}, ypolarImg{2}} };
    retinoSubTitles = {'Mean Green Anatomy', 'Retinotopy Overlay', ...
                       'X (Azimuth) Map', 'Y (Elevation) Map'};
    for rep = 1:2
        figNum = figNum + 1;
        fRet = figure('Name', sprintf('Fig %d - Retinotopy Summary %s (nstim=48)', figNum, repLabels48{rep}));

        % Layout constants (normalised figure coordinates)
        marg    = 0.03;   % outer margin on all sides
        colgap  = 0.01;   % horizontal gap between the two columns
        lblH    = 0.045;  % height reserved above each panel row for the label
        rowgap  = 0.01;   % vertical gap between bottom of label and top of row below
        titH    = 0.06;   % height consumed by sgtitle at top

        % Image aspect ratio (rows/cols) and figure pixel aspect ratio.
        % Use meanGreenImg because all four images share the same pixel grid.
        imgSz  = size(meanGreenImg);    % [nRows nCols (nChan)]
        imgAR  = imgSz(1) / imgSz(2);  % height/width in image pixels
        figPos = get(fRet, 'Position'); % [x y w h] in screen pixels
        figAR  = figPos(4) / figPos(3); % figure height/width ratio

        % Panel width: split usable width evenly across two columns
        totalW = 1 - 2*marg - colgap;
        panW   = totalW / 2;

        % Vertical layout (top to bottom):
        %   sgtitle occupies titH below the top margin
        %   Row 1: label strip (lblH) then image (panH)
        %   rowgap between rows
        %   Row 2: label strip (lblH) then image (panH)
        topY     = 1 - marg - titH;          % top of usable content area

        % Panel height: preserve pixel aspect ratio, but cap so both rows fit.
        panH_ideal = panW * imgAR / figAR;
        usableH    = topY - marg - 2*lblH - rowgap;
        panH       = min(panH_ideal, usableH / 2);
        row1LblY = topY - lblH;              % bottom of row-1 label strip
        row1ImgY = row1LblY - panH;          % bottom of row-1 image
        row2LblY = row1ImgY - rowgap - lblH; % bottom of row-2 label strip
        row2ImgY = row2LblY - panH;          % bottom of row-2 image

        xL = [marg,  marg + panW + colgap];  % left edges of col 1 and col 2

        % Label positions (annotation textbox above each panel)
        lblPos = { [xL(1) row1LblY panW lblH], [xL(2) row1LblY panW lblH], ...
                   [xL(1) row2LblY panW lblH], [xL(2) row2LblY panW lblH] };
        % Image axes positions
        imgPos = { [xL(1) row1ImgY panW panH], [xL(2) row1ImgY panW panH], ...
                   [xL(1) row2ImgY panW panH], [xL(2) row2ImgY panW panH] };

        imgs48 = retinoImgs48{rep};
        for pi = 1:4
            % Label as annotation so it does not consume axes space
            annotation(fRet, 'textbox', lblPos{pi}, ...
                       'String', retinoSubTitles{pi}, 'FontSize', 9, ...
                       'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
                       'VerticalAlignment', 'bottom', 'Interpreter', 'none', 'Color', 'k');

            ax = axes('Position', imgPos{pi}, 'Parent', fRet); %#ok<LAXES>
            image(ax, imgs48{pi});
            % Lock pixel extents so DataAspectRatio=[1 1 1] keeps pixels square
            % without axis('image') resizing the axes box.
            nR = size(imgs48{pi}, 1);  nC = size(imgs48{pi}, 2);
            set(ax, 'XLim', [0.5 nC+0.5], 'YLim', [0.5 nR+0.5], ...
                'DataAspectRatio', [1 1 1], 'XTick', [], 'YTick', []);
        end
        sgtitle(sprintf('Fig %d: Retinotopy Summary  -  %s', figNum, repLabels48{rep}), 'Interpreter', 'none');
        if exist('psfile','var'); exportgraphics(fRet, psfile, 'Append', true); end
    end
end


%% --- nstim==24, StimulusNum==7: 4x6 ON-only spot grid ---
if nstim == 24 && StimulusNum == 7
    range = [-0.05 0.2];
    loc = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24];

    % ---- FIGURE (nstim==24, SNum=7): Spots Pixel Map ----
    % ---- FIGURE (nstim==24, SNum=7): Spots Trial Timecourses ----
    figLabel = 'spots'; npanel = 24; nrow = 4; ncol = 6; offset = 0;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==24, SNum=7): Spots Weighted Timecourses ----
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;
end


%% --- nstim==10: contrast gratings (one-time condition) ---
if nstim == 10
    range = [-0.05 0.2];
    loc = 1:10;

    % ---- FIGURE (nstim==10): Bars Pixel Map ----
    % pixPlot: 2x5 grid of pixel-wise mean response maps.
    % ---- FIGURE (nstim==10): Bars Trial Timecourses ----
    figLabel = 'bars'; npanel = 10; nrow = 2; ncol = 5; offset = 0;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==10): Bars Weighted Timecourses ----
    figNum = figNum + 1; pixPlotWeight_DR; figNum = figNum + 1;

    % Add contrast/orientation labels to weighted timecourse subplots
    for i = 1:10
        subplot(2,5,i);
        title(sprintf('c %0.2f ori %d', contrast(i), orient(i)))
    end
end


%% --- nstim==50: 5x5 spot grid (OFF + ON retinotopy) ---
if nstim == 50
    range = [-0.02 0.1];
    loc = [1 6 11 16 21 2 7 12 17 22 3 8 13 18 23 4 9 14 19 24 5 10 15 20 25];

    % ---- FIGURE (nstim==50): OFF Spots Pixel Map ----
    % pixPlot: 5x5 grid of pixel-wise mean response maps for OFF spot locations.
    % ---- FIGURE (nstim==50): OFF Spots Trial Timecourses ----
    figLabel = 'OFF spots'; npanel = 25; nrow = 5; ncol = 5; offset = 0;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % ---- FIGURE (nstim==50): ON Spots Pixel Map ----
    % ---- FIGURE (nstim==50): ON Spots Trial Timecourses ----
    figLabel = 'ON spots'; npanel = 25; nrow = 5; ncol = 5; offset = 25;
    figNum = figNum + 1; pixPlot_DR; figNum = figNum + 1;

    % octoRetinotopy_DR exports 4 figures (X/Y map x OFF/ON) and manages
    % figNum entirely internally — do NOT pre-increment here.
    octoRetinotopy_DR;

    % ---- FIGURE (nstim==50): Retinotopy Summary Panel (rep 1 = OFF) ----
    % ---- FIGURE (nstim==50): Retinotopy Summary Panel (rep 2 = ON) ----
    % Manual axes positioning for tight inter-column spacing (identical logic to nstim==48).
    %
    % Design notes: see nstim==48 block above for full rationale.
    %   axis('image') is replaced by explicit XLim/YLim + DataAspectRatio=[1 1 1].
    %   Labels are annotation textboxes above each panel rather than title().
    repLabels50 = {'OFF', 'ON'};
    retinoImgs50 = { {meanGreenImg, topoOverlayImg{1}, xpolarImg{1}, ypolarImg{1}}, ...
                     {meanGreenImg, topoOverlayImg{2}, xpolarImg{2}, ypolarImg{2}} };
    retinoSubTitles50 = {'Mean Green Anatomy', 'Retinotopy Overlay', ...
                         'X (Azimuth) Map', 'Y (Elevation) Map'};
    for rep = 1:2
        figNum = figNum + 1;
        fRet = figure('Name', sprintf('Fig %d - Retinotopy Summary %s (nstim=50)', figNum, repLabels50{rep}));

        marg    = 0.03;
        colgap  = 0.01;
        lblH    = 0.045;
        rowgap  = 0.01;
        titH    = 0.06;

        imgSz  = size(meanGreenImg);
        imgAR  = imgSz(1) / imgSz(2);
        figPos = get(fRet, 'Position');
        figAR  = figPos(4) / figPos(3);

        totalW   = 1 - 2*marg - colgap;
        panW     = totalW / 2;
        topY     = 1 - marg - titH;
        panH_ideal = panW * imgAR / figAR;
        usableH    = topY - marg - 2*lblH - rowgap;
        panH       = min(panH_ideal, usableH / 2);
        row1LblY = topY - lblH;
        row1ImgY = row1LblY - panH;
        row2LblY = row1ImgY - rowgap - lblH;
        row2ImgY = row2LblY - panH;

        xL = [marg,  marg + panW + colgap];

        lblPos50 = { [xL(1) row1LblY panW lblH], [xL(2) row1LblY panW lblH], ...
                     [xL(1) row2LblY panW lblH], [xL(2) row2LblY panW lblH] };
        imgPos50 = { [xL(1) row1ImgY panW panH], [xL(2) row1ImgY panW panH], ...
                     [xL(1) row2ImgY panW panH], [xL(2) row2ImgY panW panH] };

        imgs50 = retinoImgs50{rep};
        for pi = 1:4
            annotation(fRet, 'textbox', lblPos50{pi}, ...
                       'String', retinoSubTitles50{pi}, 'FontSize', 9, ...
                       'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
                       'VerticalAlignment', 'bottom', 'Interpreter', 'none', 'Color', 'k');

            ax = axes('Position', imgPos50{pi}, 'Parent', fRet); %#ok<LAXES>
            image(ax, imgs50{pi});
            nR = size(imgs50{pi}, 1);  nC = size(imgs50{pi}, 2);
            set(ax, 'XLim', [0.5 nC+0.5], 'YLim', [0.5 nR+0.5], ...
                'DataAspectRatio', [1 1 1], 'XTick', [], 'YTick', []);
        end
        sgtitle(sprintf('Fig %d: Retinotopy Summary  -  %s', figNum, repLabels50{rep}), 'Interpreter', 'none');
        if exist('psfile','var'); exportgraphics(fRet, psfile, 'Append', true); end
    end
end


%% =========================================================================
%% SECTION 26: SAVE PDF AND DATA
%% =========================================================================

display('saving pdf')

% Build informative output filename: {ExptBase}_acq{N}_{type}_analysis
% Derive from fileName (always set) rather than Opt.fSbx/pSbx which may not be.
% ExptBase = sbx filename up to the _LOC_NNN separator
% N        = acquisition number from _000_NNN pattern
% Resolve sbx file path -> outDir and sbxBase.
% Priority: Opt.fSbx/pSbx (explicit) > fileName (set by get2pSession_sbx_DR) > pwd.
if isfield(Opt,'fSbx') && isfield(Opt,'pSbx') && ~isempty(Opt.pSbx)
    outDir  = Opt.pSbx;
    sbxBase = Opt.fSbx(1:end-4);
elseif exist('fileName','var') && ~isempty(fileName)
    [outDir, sbxBase] = fileparts(fileName);
    if isempty(outDir)   % fileName was just a bare name with no path
        outDir = pwd;
    end
else
    outDir  = pwd;
    sbxBase = 'expt_000_000';
end

% Extract expt base name and acq number from _LOC_NNN suffix pattern
% e.g. 021621_Octopus_Cal520_000_002 -> base=021621_Octopus_Cal520, acqNum=2
sepTok = regexp(sbxBase, '^(.*?)_(\d+)_(\d+)$', 'tokens');
if ~isempty(sepTok)
    exptBase = sepTok{1}{1};
    acqNum   = str2double(sepTok{1}{3});
else
    acqTok = regexp(sbxBase, 'acq(\d+)', 'tokens', 'ignorecase');
    if ~isempty(acqTok)
        acqNum = str2double(acqTok{1}{1});
    else
        acqNum = 0;
    end
    exptBase = sbxBase;
end

% Map nstim to stimulus type string (used in filename and info page)
if ismember(nstim, [48, 50])
    stimType     = '6x4';
    stimTypeDesc = sprintf('6x4 Spots  (nstim=%d)', nstim);
elseif ismember(nstim, [17, 13])
    stimType     = '8way';
    stimTypeDesc = sprintf('8-Way Gratings  (nstim=%d)', nstim);
else
    stimType     = sprintf('stim%d', nstim);
    stimTypeDesc = sprintf('%s  (nstim=%d)', StimulusStr, nstim);
end

outBase    = sprintf('%s_acq%d_%s_analysis', exptBase, acqNum, stimType);
newpdfFile = fullfile(outDir, [outBase '.pdf']);
outfile    = fullfile(outDir, outBase);

% -------------------------------------------------------------------------
% Acquisition info page -- build and append to psfile BEFORE copyfile
% so the page is included in the final PDF.
% -------------------------------------------------------------------------
infoFig = figure('Color', 'white', 'Name', 'Acquisition Info');
infoAx = axes('Parent', infoFig, 'Position', [0 0 1 1], ...
              'XLim', [0 1], 'YLim', [0 1], 'Visible', 'off');

selectPtsLabels = {'0=auto ROI', '1=manual', '2=suite2p', '3=red/green suite2p'};
spLabel = '';
spVal = NaN;
if exist('selectPts','var')
    spVal = selectPts;
elseif isfield(Opt,'selectPts')
    spVal = Opt.selectPts;
end
if ~isnan(spVal) && spVal >= 0 && spVal <= 3
    spLabel = sprintf('  (%s)', selectPtsLabels{spVal + 1});
end

if iscell(StimulusStr);  StimulusStr = StimulusStr{1}; end
if iscell(StimulusNum);  StimulusNum = StimulusNum{1}; end

infoLines = {};
infoLines{end+1} = '=== Acquisition Info ===';
infoLines{end+1} = '';
infoLines{end+1} = sprintf('File        : %s', outfile);
infoLines{end+1} = sprintf('Date        : %s', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
infoLines{end+1} = '';
infoLines{end+1} = '--- Stimulus ---';
infoLines{end+1} = sprintf('Stimulus    : %s', stimTypeDesc);
infoLines{end+1} = sprintf('StimulusStr : %s', StimulusStr);
infoLines{end+1} = sprintf('StimulusNum : %d', StimulusNum);
infoLines{end+1} = sprintf('nstim       : %d', nstim);
infoLines{end+1} = '';
infoLines{end+1} = '--- User-Selected Parameters ---';
if ~isnan(spVal)
    infoLines{end+1} = sprintf('selectPts   : %d%s', spVal, spLabel);
else
    infoLines{end+1} = 'selectPts   : (unknown)';
end
infoLines{end+1} = sprintf('nclust      : %d', nclust);
infoLines{end+1} = sprintf('sub_noise   : %d', Opt.sub_noise);
if isfield(Opt, 'zbinning')
    infoLines{end+1} = sprintf('zbinning    : %d', Opt.zbinning);
end
if isfield(Opt, 'binningThresh')
    infoLines{end+1} = sprintf('binningThresh: %.3f', Opt.binningThresh);
end
if isfield(Opt, 'cellrange')
    infoLines{end+1} = sprintf('cellrange   : %d:%d', Opt.cellrange(1), Opt.cellrange(end));
end
infoLines{end+1} = sprintf('Resample_dt : %.3f s', Opt.Resample_dt);
infoLines{end+1} = '';
infoLines{end+1} = '--- Cell Counts ---';
infoLines{end+1} = sprintf('nCells      : %d', size(dF, 1));
infoLines{end+1} = sprintf('nFigures    : %d (printed to PDF)', figNum);

text(infoAx, 0.05, 0.95, strjoin(infoLines, '\n'), ...
    'Units', 'normalized', 'VerticalAlignment', 'top', ...
    'FontName', 'Courier', 'FontSize', 10, 'Interpreter', 'none', 'Color', 'k');

if exist('psfile','var'); exportgraphics(infoFig, psfile, 'Append', true); end

% Now copy the complete psfile (including info page) to the final output location
if Opt.SaveFigs
    try
        copyfile(psfile, newpdfFile);
    catch
        display('couldnt copy pdf to output location');
    end
end

% Save analysis results to .mat file
display('saving data')
save(outfile, 'trialmean', 'trialTcourse', 'stimOrder', 'c', 'dFrepeats', ...
     'xpts', 'ypts', 'stdImg', 'cycPolarImg', 'cycImg', 'meanGreenImg', 'weightTcourse', ...
     'nstim', 'StimulusStr', 'StimulusNum', '-v7.3');

if exist('freq','var')
    save(outfile, 'freq', 'orient', '-append');
end
if nstim == 48 || nstim == 50
    save(outfile, 'topoOverlayImg', 'xpolarImg', 'ypolarImg', 'xphase', 'yphase', '-append');
end
if nstim == 13
    save(outfile, 'overlayImg', 'hvImg', '-append');
end

% Display path to temporary PostScript file for debugging
psfile

% (Commented out) Optional: return results struct as function output
% if Opt.SaveOutput
%     Output.dF = dF;
%     Output.R = Rigid;
%     Output.NR = Rotation;
%     Output.dfof = dfofInterp;
%     Output.dF = dF;
%     varargout{1} = Output;
% end
