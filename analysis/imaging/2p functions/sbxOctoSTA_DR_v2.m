function varargout = sutterOctoSTA(varargin)
%% sutterOctoSTA - STA (Spike-Triggered Average) analysis for octopus optic lobe 2-photon data
%
% PURPOSE:
%   Loads .sbx 2-photon imaging data and a sparse noise stimulus movie,
%   computes spike-triggered averages (STAs) to estimate receptive fields,
%   clusters cells by response profile, and produces a multi-page PDF output.
%   Designed for octopus optic lobe preparations labeled with Cal520.
%
% USAGE:
%   sutterOctoSTA()        % interactive mode, prompts for all inputs
%   sutterOctoSTA(Opt)     % run with options struct Opt
%
% INPUT (optional struct Opt fields):
%   Opt.SaveFigs    - 1 to save figures to PDF (default: 1)
%   Opt.psfile      - path to temporary PDF file (default: 'C:\temp\TempFigs.pdf')
%   Opt.selectCrop  - 1 to manually crop image before ROI selection (default: 1)
%   Opt.Resample_dt - temporal resampling interval in seconds (default: 0.1)
%   Opt.cellrange   - pixel range for ROI averaging (default: -3:3)
%   Opt.nclust      - number of clusters for hierarchical clustering
%   Opt.noiseFile   - 1 or 2, selects which sparse noise movie to load
%   Opt.fSbx        - filename of .sbx file
%   Opt.pSbx        - path to .sbx file
%   Opt.fPDF        - output PDF filename
%   Opt.pPDF        - output PDF path
%
% STIMULUS:
%   Sparse noise movie (either 10-min or 20-min version), loaded from disk.
%   Two conditions (reps) are analyzed: ON responses (positive contrast) and
%   OFF responses (negative contrast). Full-field flicker is treated separately.
%
% OUTPUTS:
%   Multi-page PDF saved to Opt.pPDF/Opt.fPDF
%   .mat file with analysis results (STAs, tuning, RF locations, clustering)
%
% DEPENDENCIES:
%   get2pSession_sbx_DR   - loads .sbx data (DR-customised version with exportgraphics fix)
%   subtractSidebandNoise - optional sideband noise removal
%   zbinCorr_DR           - z-plane binning correction (DR version with exportgraphics fix)
%   getOctoCells_DR          - ROI selection script
%   freezeColors          - third-party: freezes colormap for overlays
%   cbrewer / cbrewer2    - third-party: NOT required; replaced with inline RdBu construction
%   cmapVar               - custom function: maps a scalar to a colormap color
%
% NOTE ON HARD-CODED PATHS:
%   Stimulus movie files default to C:\data\. If not found there, a file dialog opens automatically.

%% =========================================================================
%% SECTION 1: INITIALIZE OPTIONS
%% =========================================================================

% close all  % (commented out - uncomment to close all figures at startup)

% If called as a function, use the passed Opt struct; otherwise use defaults
if ~isempty(varargin)
    Opt = varargin{1};
else
    % Save figures to a temporary PDF file (NOTE: changed from .ps to .pdf)
    Opt.SaveFigs = 1;
    Opt.psfile = 'C:\temp\TempFigs.pdf';

    % Manually select crop region before auto ROI selection (1=yes, 0=no)
    Opt.selectCrop = 1;

    % Temporal resampling interval (seconds per frame after resampling)
    Opt.Resample_dt = 0.1;

    %%% Additional options (currently commented out - uncomment to use):
    % Opt.NumChannels = 2;   % two-color (interleaved frame) data
    % Opt.selectPts = 0;     % 0=auto ROI, 1=manual, 2=suite2p
    % Opt.mindF = 5000;      % brightness threshold for auto ROI selection
    % Opt.nclust = 5;        % number of clusters for hierarchical clustering
    % Opt.MakeMov = 0;       % make movies
    % Opt.fwidth = 0.5;      % Gaussian filter standard deviation
    % Opt.align = 1;         % perform rigid alignment
    % Opt.AlignmentChannel = 2;
    % Opt.Resample = 1;
    % Opt.ttl_file = 1;
    % Opt.SaveOutput = 0;
end


%% =========================================================================
%% SECTION 2: SET UP PARAMETERS
%% =========================================================================

% Define pixel range for averaging around each ROI center point
% NOTE: default here is -3:3 (7x7 box), slightly larger than sutterOctoNeural (-2:2)
if isfield(Opt,'cellrange')
    pts_range = Opt.cellrange;
else
    pts_range = -3:3;   % 7x7 pixel box (was -3:3 before 011123)
end

% Delete existing temp PDF file if it exists (start fresh)
if Opt.SaveFigs
    psfile = Opt.psfile;
    if exist(psfile,'file')==2; delete(psfile); end
end

% Set temporal resampling interval
dt = Opt.Resample_dt;

% Figure numbering counter.
% Incremented once for each figure that is exported to the output PDF.
% Figures that are displayed but NOT printed use a descriptive Name but no number.
figNum = 0;

% Configuration struct for get2pSession_sbx:
%   dt          = resampling interval (sec)
%   spatialBin  = 2x spatial downsampling
%   temporalBin = no temporal binning
%   syncToVid   = no video sync
%   saveDF      = don't save dF/F inside session function
cfg.dt = dt; cfg.spatialBin = 2; cfg.temporalBin = 1;
cfg.syncToVid = 0; cfg.saveDF = 0;

% Suppress saving the full session data
sessionName = 0;

% Construct full path to .sbx file if provided in Opt
if isfield(Opt,'fSbx')
    fileName = fullfile(Opt.pSbx, Opt.fSbx);
end


%% =========================================================================
%% SECTION 3: LOAD IMAGING DATA
%% =========================================================================

% Calls get2pSession_sbx_DR (the DR-customised version with exportgraphics,
% meanImg fallback, and Interpreter fix). Previously called the base version
% get2pSession_sbx, which still uses print('-dpsc') and crashes on R2023b+.
% Returns: dfofInterp, phasetimes, meanImg, greenframe, vidframetimes, dt
get2pSession_sbx_DR;

% Retrieve rigid alignment displacement values for border cropping
global info
mv = info.aligned.T;   % [T x 2] matrix of x/y displacements per frame


%% =========================================================================
%% SECTION 4: OPTIONAL SIDEBAND NOISE SUBTRACTION
%% =========================================================================

% Sideband noise arises from out-of-focus fluorescence in adjacent z-planes.
if ~isfield(Opt,'sub_noise')
    Opt.sub_noise = input('subtract noise from sidebands? 0/1 ');
end

if Opt.sub_noise == 1
    [dfofInterp, meanImg, greenframe] = subtractSidebandNoise(dfofInterp, meanImg, psfile, mv);
end


%% =========================================================================
%% SECTION 5: Z-PLANE BINNING CORRECTION
%% =========================================================================

% NOTE: Unlike sutterOctoNeural, zbinCorr is called unconditionally here
% (no user prompt). It always applies the z-plane binning correction.
[dfofInterp, meanImg, greenframe, mv] = zbinCorr_DR(dfofInterp, meanImg, greenframe, Opt, psfile, mv);


%% =========================================================================
%% SECTION 6: CROP IMAGE TO REMOVE ALIGNMENT BORDER ARTIFACTS
%% =========================================================================

% Compute border buffer based on max motion correction displacement.
% spatialBin accounts for downsampling applied during loading.
buffer(:,1) = max(mv,[],1) / cfg.spatialBin + 1;   buffer(buffer < 1) = 1;
buffer(:,2) = max(-mv,[],1) / cfg.spatialBin + 1;  buffer(buffer < 0) = 0;
buffer = round(buffer)
buffer(2,:) = buffer(2,:) + 32   % add 32-pixel deadband buffer

% Crop dF/F movie to remove alignment border
dfofInterp = dfofInterp(buffer(1,1):(end-buffer(1,2)), buffer(2,1):(end-buffer(2,2)), :);


%% =========================================================================
%% SECTION 7: STIMULUS TIMING
%% =========================================================================

% For this script, stimulus times come from vidframetimes (video frame timestamps),
% not from phasetimes. Each entry is a time (in seconds) when a new stimulus frame
% was presented to the animal.

% cycLength: median number of imaging frames between successive video frames.
cycLength = median(diff(vidframetimes)) / dt;

% cycWindow: number of frames to extract around each cycle onset
cycWindow = round(max(2/dt, cycLength));

% Rename vidframetimes to stimTimes for clarity
stimTimes = vidframetimes;

% Trim dF/F to start ~1 sec before first stimulus
startFrame = round((stimTimes(1) - 1) / dt);
startTrim = startFrame;
dfofInterp = dfofInterp(:, :, startFrame:end);

% Re-reference stimulus times to start of trimmed movie
stimTimes = stimTimes - stimTimes(1) + 1;

% Remove stimulus times that fall too close to the end of the recording
stimTimes = stimTimes(stimTimes < size(dfofInterp, 3)*dt - 5);

% Convert stimulus times from seconds to frame indices
stimFrames = round(stimTimes / dt);

% ---- FIGURE Pg 1: Diff of Video Frame Times ----
% Plots time between consecutive video frames in the 2-photon recording.
% Used to verify consistent stimulus delivery. Irregular intervals suggest
% dropped frames or timing issues.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Diff of Video Frame Times', figNum));
plot(diff(stimTimes)); title(sprintf('Fig %d: Diff of Video Frame Times in 2p', figNum));
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 8: REFERENCE IMAGES (Green, Max dF/F, Merge)
%% =========================================================================

% ---- FIGURE Pg 2: Mean Green Channel ----
% Absolute fluorescence image showing anatomy.
% Also creates greenFig handle and meanGreenImg for overlays.
figNum = figNum + 1;
greenFig = figure('Name', sprintf('Fig %d - Mean Green Channel', figNum));

stdImg = imresize(greenframe, 1/cfg.spatialBin);
stdImg = stdImg(buffer(1,1):(end-buffer(1,2)), buffer(2,1):(end-buffer(2,2)), :);
greenCrop = double(stdImg);
imagesc(stdImg, [prctile(stdImg(:),1) prctile(stdImg(:),99)*1.2]); hold on; axis equal; colormap gray;

% Normalized RGB green image for anatomy overlays
meanGreenImg = mat2im(greenCrop, gray, [prctile(greenCrop(:),1) prctile(greenCrop(:),99)*1.2]);

title(sprintf('Fig %d: Mean Green Channel', figNum));
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% Build green weighting image for anatomy-weighted overlays
stdImg = double(stdImg);
normgreen = (stdImg - prctile(stdImg(:),1)) / (prctile(stdImg(:),99)*1.5 - prctile(stdImg(:),1));
normgreenraw = normgreen;   % save raw version

normgreen = normgreen * 2;
normgreen(normgreen < 0) = 0;
normgreen(normgreen > 1) = 1;
normgreen = repmat(normgreen, [1 1 3]);   % expand to 3-channel RGB

% ---- FIGURE Pg 3: Max dF/F Image ----
% Pixel-wise maximum dF/F across all time, median-filtered for noise reduction.
figNum = figNum + 1;
maxFig = figure('Name', sprintf('Fig %d - Max dF/F Image', figNum));
stdImg = max(dfofInterp, [], 3); stdImg = medfilt2(stdImg);
imagesc(stdImg, [prctile(stdImg(:),1) prctile(stdImg(:),99)]); hold on; axis equal; colormap gray; title(sprintf('Fig %d: Max dF/F Image', figNum))
normMax = (stdImg - prctile(stdImg(:),1)) / (prctile(stdImg(~isinf(stdImg(:))),98) - prctile(stdImg(:),1));
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE Pg 4: Mean/Max Green Channel Merge ----
% RGB overlay: Red = max dF/F, Green = anatomy.
merge = zeros(size(stdImg,1), size(stdImg,2), 3);
merge(:,:,1) = normMax;
merge(:,:,2) = normgreenraw;
figNum = figNum + 1;
mergeFig = figure('Name', sprintf('Fig %d - Mean/Max Green Channel Merge', figNum));
imshow(merge); title(sprintf('Fig %d: Mean/Max Green Channel Merge', figNum))
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 9: LOAD SPARSE NOISE STIMULUS MOVIE
%% =========================================================================

% Choose which sparse noise movie to analyze.
% NOTE: Hard-coded file paths below -- update for your system.
%   movienum==1: octo_sparse_flash_10min.mat (4 spot sizes: 2,4,8,255)
%   movienum==2: sparse_20min_1-8.mat       (5 spot sizes: 0.8,2,4,8,255)
% Variables loaded: moviedata, sz_mov
%   moviedata - [Y x X x T] uint8 stimulus movie (values 0-255, 127=gray)
%   sz_mov    - [Y x X x T] spot size labels per frame

display('which movie file?')
if isfield(Opt,'noiseFile')
    movienum = Opt.noiseFile;
else
    display('1) octo_sparse_flash_10min')
    display('2) sparse_20min_1-8')
    movienum = input('1 or 2 : ');
end

if movienum == 1
    % 10-minute sparse flash stimulus (4 spot sizes)
    sparseFile = 'C:\data\octo_sparse_flash_10min.mat';   % default path
    if ~exist(sparseFile, 'file')
        [f, p] = uigetfile('*.mat', 'Select sparse flash stimulus .mat file (octo_sparse_flash_10min)');
        if isequal(f, 0); error('No file selected -- sparse flash stimulus data required.'); end
        sparseFile = fullfile(p, f);
    end
    load(sparseFile)
    crange = [-0.1 0.1];    % colormap range for STA images
    tau = 9;                % peak lag (frames) for STA computation
    tau_range = -4:4;       % range of lags around tau for response averaging
else
    % 20-minute sparse noise stimulus (5 spot sizes)
    sparseFile = 'C:\data\sparse_20min_1-8.mat';          % default path
    if ~exist(sparseFile, 'file')
        [f, p] = uigetfile('*.mat', 'Select sparse noise stimulus .mat file (sparse_20min_1-8)');
        if isequal(f, 0); error('No file selected -- sparse noise stimulus data required.'); end
        sparseFile = fullfile(p, f);
    end
    load(sparseFile)
    crange = [-0.05 0.05];
    tau = 7;
    tau_range = -3:3;
end

% Baseline window: frames before stimulus onset used for baseline subtraction
baserange = 0:2;


%% =========================================================================
%% SECTION 10: PIXEL-LEVEL STA ANALYSIS (2 reps: ON and OFF)
%% =========================================================================

% For each rep (ON = rep 1, OFF = rep 2), compute:
%   (a) Population-average timecourse aligned to each stimulus frame
%   (b) STA grid (30 lags) for the whole-image mean response
%   (c) Block-level STA map and timecourse grid (25x25 pixel blocks)

for rep = 1:2   % rep 1 = ON, rep 2 = OFF
    if rep == 1; repLabel = 'ON'; else; repLabel = 'OFF'; end

    STAfig = figure;
    STAfig.NextPlot = 'new';

    % Convert uint8 movie to signed [-1, 1] range (127 = gray = 0)
    m = (double(moviedata) - 127) / 128;

    % Select polarity: ON keeps positive values, OFF keeps negative values
    if rep == 1 || rep == 3      % ON response
        m(m < 0) = 0;
    elseif rep == 2 || rep == 4  % OFF response
        m(m > 0) = 0;
    end

    % Isolate spots (exclude full-field): zero out full-field frames (sz_mov==255)
    % NOTE: This preserves spot responses but breaks the full-field timecourse.
    if rep == 1 || rep == 2       % spots
        m(sz_mov == 255) = 0;
        m = imresize(m, 0.5, 'box');   % downsample movie by 2x (box filter)
    elseif rep == 3 || rep == 4   % full-field only
        m(sz_mov ~= 255) = 0;
        m = m(1,1,:);   % only need one pixel for full-field
    end

    % Spatial mean of the movie (used for STA normalization)
    movie_mn = mean(m, 3);

    %% --- Compute whole-image mean timecourse aligned to each stimulus frame ---

    % Clip extreme dF/F values to reduce motion artifact influence
    dFclip = dfofInterp;
    dFclip(dFclip > 0.5) = 0.5;
    dFclip(dFclip < -0.5) = -0.5;

    % Spatially average to get a single timecourse for the whole image
    dF = squeeze(mean(mean(dFclip, 2), 1));

    % Align dF timecourse to each stimulus frame onset (baseline-subtracted)
    framerange = 0:2*cycWindow;
    clear dFalign
    baserange = 0:2;
    for i = 1:length(stimTimes)-2
        dFalign(i,:) = dF(stimFrames(i) + framerange) - mean(dF(stimFrames(i) + baserange), 'omitnan');
    end

    % ---- FIGURE Pg 5/7: Mean Timecourse All Pixels All Stim (rep 1 / rep 2) ----
    % Population-average dF/F timecourse aligned to all stimulus onsets.
    % Shows the overall temporal response profile for the ON or OFF condition.
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Mean Timecourse All Pixels All Stim (%s)', figNum, repLabel));
    plot(mean(dFalign, 1, 'omitnan'));
    title(sprintf('Fig %d: Mean Timecourse All Pixels  -  %s', figNum, repLabel))
    xlabel('frame'); ylabel('dfof')
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


    %% --- Compute STA grid (lags 3-18) for whole-image response ---

    % For each lag (3 to 18 frames), compute the STA:
    % STA = sum_over_frames( response(t) * [movie_frame(t) - mean_movie] ) / total_response
    % Displayed in a 5x6 subplot grid; panels 1-2 and 19-30 are intentionally left empty.
    % Each filled panel is labeled with its lag number.
    % NOTE: The original sbxOctoSTA.m loops taus=1:30 (all 30 panels). The 3:18 range is
    % used here to skip the weakest/noisiest early and late lags and reduce computation
    % time on slower workstations.
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - STA Lag Grid (%s)', figNum, repLabel));
    range = 0;   % no temporal averaging around each lag

    clear stas
    for taus = 3:18
        % Response at this lag: mean dF/F at frame taus (single frame)
        resp = mean(dFalign(:, taus + range), 2, 'omitnan');

        % Accumulate weighted stimulus frames
        sta = 0;
        npts = min(length(resp), size(moviedata, 3));
        for i = 1:npts
            if ~isnan(resp(i))
                sta = sta + resp(i) * (m(:,:,i) - movie_mn);
            end
        end
        sta = sta / sum(abs(resp(1:npts)), 'omitnan');   % normalize by total absolute response

        stas(:,:,taus) = sta;

        % Accumulate into lagStas for saving (rep 1=ON, rep 2=OFF)
        lagStas(:,:,taus,rep) = sta;

        subplot(5, 6, taus);
        imagesc(sta', crange); colormap jet; axis equal; axis off;
        title(sprintf('lag %d', taus));
    end
    sgtitle(sprintf('Fig %d: STA Lag Grid  -  %s  (lags 3-18)', figNum, repLabel), 'Interpreter', 'none');

    % ---- FIGURE Pg 6/8: STA Grid at Lags 3-18 (rep 1 / rep 2) ----
    % 5x6 grid; panels 3-18 filled, panels 1-2 and 19-30 empty.
    % Use to identify the peak response lag (tau) before running the cluster section.
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


    %% --- Block-level STA map and timecourse grid ---

    % Divide the imaging field into 25x25 pixel blocks and compute the STA
    % and size-tuning timecourse for each block.

    blocksize = 25;
    xrange = 1:blocksize:size(dfofInterp,1); xrange = xrange(1:end-1);   % x block starts (drop last, may be off edge)
    yrange = 1:blocksize:size(dfofInterp,2); yrange = yrange(1:end-1);   % y block starts
    clear dFalign tcourseAll

    for nx = 1:length(xrange)
        for ny = 1:length(yrange)

            % Compute mean dF/F within this block
            range = 0:(blocksize-1);
            dF = squeeze(mean(mean(dfofInterp(xrange(nx)+range, yrange(ny)+range, :), 2), 1));

            % Align block timecourse to each stimulus frame
            framerange = 0:cycWindow;
            for i = 1:length(stimTimes)-4
                dFalign(i,:) = dF(stimFrames(i) + framerange) - mean(dF(stimFrames(i) + baserange), 'omitnan');
            end

            % Compute STA for this block at the peak lag window
            range = -2:2;
            resp = mean(dFalign(:, tau + tau_range), 2, 'omitnan');

            sta = zeros(size(m,1), size(m,2));
            npts = min(length(resp), size(moviedata,3));
            for i = 1:npts
                if ~isnan(resp(i))
                    sta = sta + resp(i) * (m(:,:,i) - movie_mn);
                end
            end
            sta = sta / sum(abs(resp(1:npts)), 'omitnan');   % normalize by total activity

            % Store STA for this block
            staAll(:,:,nx,ny,rep) = sta';

            % Find the peak location within the STA for size-tuning analysis
            xprofile = max(abs(sta), [], 1); [mx, xmax] = max(xprofile);
            yprofile = max(abs(sta), [], 2); [mx, ymax] = max(yprofile);

            % Spot size labels (movienum determines available sizes)
            if movienum == 1
                sz = [2 4 8 255]; col = 'bcrg'; nt = 4;
            else
                sz = [0.8 2 4 8 255]; col = 'kbcrg'; nt = 5;
            end

            % Compute size-tuning timecourse at STA peak location
            % For each spot size, find frames where a spot of that size
            % was at the peak location and average the dF timecourse.
            for i = 1:length(sz)
                if i < length(sz)
                    % Spot stimuli: find frames with a spot of this size at the peak location
                    eps = find(abs(m(ymax,xmax,:)) > 0.9 & sz_mov(ymax*2, xmax*2, :) == sz(i));
                else
                    % Full-field: size==255; note sz_mov is at 2x resolution
                    eps = find(sz_mov(ymax*2, xmax*2, :) == sz(i));
                end
                eps = eps(eps <= size(dFalign, 1));
                tcourseAll(i,:,nx,ny,rep) = median(dFalign(eps,:), 1, 'omitnan');
            end

        end
    end

    %% --- Plot block STA map ---

    % ---- FIGURE Pg 9/11: Block STA Map (rep 1 / rep 2) ----
    % Grid of STA images, one per 25x25 pixel block of the imaging field.
    % Each panel shows the STA at the peak lag (tau), downsampled 0.5x.
    % Use to visualize the spatial structure of receptive fields across the tissue.
    display('drawing STAs')
    tic
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Block STA Map (%s)', figNum, repLabel));
    set(gcf, 'Visible', 'on');
    pnum = 0;
    for nx = 1:length(xrange)
        nx
        for ny = 1:length(yrange)
            pnum = pnum + 1;
            subplot(length(xrange), length(yrange), pnum);
            imagesc(imresize(staAll(:,:,nx,ny,rep), 0.5), crange);
            colormap jet;
            set(gca, 'Visible', 'off');
            set(gca, 'LooseInset', get(gca,'TightInset'));
        end
    end
    toc
    sgtitle(sprintf('Fig %d: Block STA Map  -  %s', figNum, repLabel), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

    % Single STA at block (6,6) for reference (not printed)
    figure('Name', sprintf('STA at block 6,6  -  %s (not printed)', repLabel));
    imagesc(staAll(:,:,6,6,rep), crange); title(sprintf('STA at block 6,6  -  %s', repLabel)); colorbar

    %% --- Plot block size-tuning timecourse map ---

    % ---- FIGURE Pg 10/12: Block Timecourse Map (rep 1 / rep 2) ----
    % Grid of size-tuning timecourses, one per block.
    % Each colored line = one spot size (b=small, r=medium, g=large, etc.).
    % X-axis: frames (1-20); Y-axis: dF/F. Shows spatial variation in size tuning.
    display('drawing timecourses')
    tic
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Block Timecourse Map (%s)', figNum, repLabel));
    set(gcf, 'Visible', 'on');
    pnum = 0;
    for nx = 1:length(xrange)
        nx
        for ny = 1:length(yrange)
            pnum = pnum + 1;
            subplot(length(xrange), length(yrange), pnum);
            if rep < 3
                for i = 1:nt-1   % skip full-field for spot conditions
                    hold on
                    plot(squeeze(tcourseAll(i,:,nx,ny,rep)), col(i), 'LineWidth', 2);
                end
            else
                plot(squeeze(tcourseAll(nt,:,nx,ny,rep)), col(nt), 'LineWidth', 2);
            end
            ylim([-0.025 0.1]); xlim([1 20]);
            set(gca, 'Xtick', []); set(gca, 'Ytick', []);
            set(gca, 'LooseInset', get(gca, 'TightInset'));
        end
    end
    toc
    sgtitle(sprintf('Fig %d: Block Timecourse Map  -  %s', figNum, repLabel), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
    drawnow

    % Timecourse at block (6,6) for reference (not printed)
    figure('Name', sprintf('Timecourse at block 6,6  -  %s (not printed)', repLabel));
    for i = 1:nt-1
        hold on
        plot(squeeze(tcourseAll(i,:,6,6,rep)), col(i), 'LineWidth', 2);
    end
    title(sprintf('Timecourse at block 6,6  -  %s', repLabel));

end  % end rep loop (ON / OFF)


%% =========================================================================
%% SECTION 11: BLOCK GRID OVERLAY ON ANATOMY
%% =========================================================================

% ---- FIGURE Pg 13: Block Grid on Green Image ----
% Anatomy image with overlaid grid showing the 25x25 pixel block boundaries
% used for the block-level STA analysis above.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Block Grid on Green Image', figNum));
imagesc(greenCrop); colormap gray; hold on
for i = 1:length(xrange)
    plot([0 yrange(end)+blocksize], [xrange(i)+blocksize xrange(i)+blocksize], 'b')
end
for i = 1:length(yrange)
    plot([yrange(i)+blocksize yrange(i)+blocksize], [0 xrange(end)+blocksize], 'b')
end
title(sprintf('Fig %d: 25x25 Pixel Block Grid on Anatomy', figNum))
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 12: ON/OFF STA OVERLAY MAP
%% =========================================================================

% ---- FIGURE Pg 14: ON/OFF STA Overlay Map ----
% RGB image where:
%   Red channel   = ON STA (rep 1) normalized to [0, 1]
%   Green channel = negative OFF STA (rep 2) normalized to [0, 1] (inverted sign)
%   Blue channel  = ON STA (same as red, giving magenta for purely ON regions)
% Shows spatial distribution of ON vs OFF responses across the tissue.
pnum = 0;
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - ON/OFF STA Overlay Map', figNum));
for nx = 1:length(xrange)
    for ny = 1:length(yrange)
        pnum = pnum + 1;
        subplot(length(xrange), length(yrange), pnum);
        im = zeros(size(staAll,1), size(staAll,2), 3);
        im(:,:,1) = staAll(:,:,nx,ny,1) / 0.1;    % ON -> Red
        im(:,:,2) = -staAll(:,:,nx,ny,2) / 0.1;   % OFF (inverted) -> Green
        im(:,:,3) = staAll(:,:,nx,ny,1) / 0.1;    % ON -> Blue (magenta for ON)
        imshow(imresize(im, 0.5));
        set(gca, 'LooseInset', get(gca, 'TightInset'))
    end
end
sgtitle(sprintf('Fig %d: ON/OFF STA Overlay Map  (red/magenta=ON, green=OFF)', figNum), 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 13: ROI SELECTION
%% =========================================================================

% Call getOctoCells_DR to select ROI points (cells/pixels) for single-cell analysis.
% Selection mode is determined by Opt.selectPts (or prompted interactively).
% Returns: dF [nCells x T], x, y, xpts, ypts
% NOTE: calls the non-commented version of getOctoCells_DR
getOctoCells_DR

% Account for figures produced inside getOctoCells_DR.
% selectPts==0 or 1: 2 figures printed (brightness cutoff + selected points).
% selectPts==2 or 3: 4 figures printed (classifier scores, max projection, cell masks, cluster histogram).
if selectPts == 2 || selectPts == 3
    figNum = figNum + 4;
else
    figNum = figNum + 2;
end


%% =========================================================================
%% SECTION 14: BASIC dF/F VISUALIZATION
%% =========================================================================

% Clip abnormally large dF/F values (can arise from movement artifacts)
dF(dF > 2) = 2;

% ---- FIGURE (not printed): Fluorescence Traces ----
% All individual ROI dF/F traces overlaid. Green = population mean.
% Print call is commented out (not saved to PDF).
figure('Name', 'Fluorescence Traces (not printed)')
plot((1:size(dF,2))*dt, dF');
hold on
plot((1:size(dF,2))*dt, mean(dF, 1, 'omitnan'), 'g', 'Linewidth', 2);
xlabel('secs'); ylabel('df/f'); title('Fluorescence Traces'); xlim([0 size(dF,2)*dt]);
%if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE Pg 15: Rigid Alignment Values ----
% X and Y displacement traces from rigid motion correction.
% Large values indicate periods of significant movement.
if exist('mv','var')
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Rigid Alignment Values', figNum));
    plot(mv);
    title(sprintf('Fig %d: Rigid Alignment Values', figNum))
    xlabel('x displacement'); ylabel('y displacement');
end
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 15: PREPARE dF MATRIX FOR CLUSTERING
%% =========================================================================

% Compute mean dF response at the peak lag window (tau +/- tau_range)
% for each cell and each stimulus presentation. Baseline-subtracted.
framerange = tau + tau_range;
clear dFclust
for i = 1:length(stimTimes)-2
    dFclust(:,i) = mean(dF(:, stimFrames(i) + framerange), 2, 'omitnan') - ...
                   mean(dF(:, stimFrames(i) + baserange), 2, 'omitnan');
end

% Clip to reasonable range
dFclust(dFclust > 0.25) = 0.25;

% ---- FIGURE (not printed): Full dF/F Heatmap ----
% Raw dF/F matrix (cells x time) for visual inspection.
figure('Name', 'Full dF/F Heatmap (not printed)');
imagesc(dF);

% ---- FIGURE (not printed): dFclust Heatmap ----
% Clustering input matrix (cells x stim presentations). NaNs set to 0.
figure('Name', 'dFclust Heatmap (not printed)');
dFclust(isnan(dFclust)) = 0;   % replace NaN with 0 (cluster() requires no NaNs)
imagesc(dFclust);
colorbar


%% =========================================================================
%% SECTION 16: HIERARCHICAL CLUSTERING
%% =========================================================================

% Compute pairwise Euclidean distances and build hierarchical dendrogram.
dist = pdist(dFclust, 'euclidean');
display('doing cluster')
tic; Z = linkage(dist, 'ward'); toc

% ---- FIGURE Pg 16: Sorted Cell Heatmap with Dendrogram ----
% Left panel: hierarchical dendrogram.
% Right panel: dFclust heatmap with cells sorted by dendrogram leaf order.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Sorted Cell Heatmap with Dendrogram', figNum));
subplot(3,4,[1 5 9])
display('doing dendrogram')
[h, t, perm] = dendrogram(Z, 0, 'Orientation', 'Left', 'ColorThreshold', 1);
axis off
subplot(3,4,[2 3 4 6 7 8 10 11 12]);
imagesc(dFclust(perm,:), [-0.1 0.4]); axis xy; xlabel('selected traces based on dF'); colormap jet;
hold on;
sgtitle(sprintf('Fig %d: Sorted Cell Heatmap with Dendrogram', figNum), 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 17: CLUSTER ASSIGNMENT
%% =========================================================================

% Get number of clusters from Opt or prompt user
if isfield(Opt,'nclust')
    nclust = Opt.nclust;
else
    nclust = input('# of clusters : ');
end

% NOTE: cluster() uses Statistics Toolbox. If a local cluster.m (e.g. from
% ratrix/matlabClub) is on the path, it will shadow the toolbox version and
% cause "Too many input arguments". The rmpath/addpath pair below temporarily
% suppresses any such shadowing file and restores the path afterward.
matlabClubPath = fileparts(which('cluster'));   % find the folder of any shadowing cluster.m
if ~isempty(matlabClubPath)
    rmpath(matlabClubPath);
end

% Use simple maxclust clustering -- gives exactly nclust clusters.
c = cluster(Z, 'maxclust', nclust);
% Restore path after clustering
if ~isempty(matlabClubPath)
    addpath(matlabClubPath);
end

% Cluster color palettes
colors = hsv(nclust + 1);
cols   = hsv(nclust);


%% =========================================================================
%% SECTION 18: POST-CLUSTER FIGURES (suite2p mode only)
%% =========================================================================

% ---- FIGURE (suite2p only): Suite2p Cluster ROI Overlay ----
% Only produced when selectPts==2 (suite2p ROI mode).
% Shows suite2p ROI masks color-coded by cluster assignment on anatomy image.
if selectPts == 2
    img = imresize(meanGreenImg, 2);
    for j = 1:length(c)
        xpix = stat{j}.xpix;
        ypix = stat{j}.ypix;
        lam  = stat{j}.lam;
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
%% SECTION 19: CLUSTER SPATIAL MAP
%% =========================================================================

% ---- FIGURE Pg 17: Cluster Spatial Map ----
% Anatomy image with each cell's position marked by a colored circle.
% Color indicates cluster membership. Title shows total number of clusters.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Cluster Spatial Map', figNum));
imagesc(stdImg, [0 prctile(stdImg(:),99)]); colormap gray; axis equal; hold on
for clust = 1:nclust
    plot(x(c==clust), y(c==clust), 'o', 'Color', cols(clust,:));
end
title(sprintf('Fig %d: Cluster Spatial Map  (%u Clusters)', figNum, nclust));
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE (suite2p only): Cluster Map on Max Projection ----
% Same as above but at 2x resolution using the full-frame max projection.
if selectPts == 2
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Cluster Map on Max Projection', figNum));
    imagesc(maxProj, [0 prctile(maxProj(:),99)]); colormap gray; axis equal; hold on
    for clust = 1:nclust
        plot(x(c==clust)*2, y(c==clust)*2, 'o', 'Color', colors(clust,:));
    end
    title(sprintf('Fig %d: Cluster Map on Max Projection  (%u Clusters)', figNum, nclust));
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
end


%% =========================================================================
%% SECTION 20: dF/F TRACE SAMPLE FIGURE
%% =========================================================================

% Select a random sample of cells from each cluster for visualization.
np = 5;   % cells per cluster
for clust = 1:nclust
    cells = find(c == clust);
    cell_list((1:np) + (clust-1)*np) = cells(ceil(rand(np,1) * length(cells)));
    color_list((1:np) + (clust-1)*np,:) = repmat(cols(clust,:), [np 1]);
end

% ---- FIGURE Pg 18: dF/F Trace Sample ----
% Random sample of ROI traces, color-coded by cluster. Each trace offset
% vertically. X-axis in seconds (0-180 sec window shown).
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - dF/F Trace Sample', figNum));
hold on
range = 1:min(3000, length(dF));
dtr = 0.1;
for i = 1:length(cell_list)
    plot(range*dtr - 50, medfilt1(3*dF(cell_list(i),range), 5) + (length(cell_list)+1) - i, ...
         'Color', 0.9*color_list(i,:));
end
ylim([0 np*nclust+2]); xlim([0 180]); xticks(0:60:180);
xlabel('secs'); ylabel('cell #'); title(sprintf('Fig %d: dF/F Trace Sample (Random Subset)', figNum))
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 21: PER-CLUSTER STA ANALYSIS
%% =========================================================================

% For each cluster, compute and display:
%   - Cluster anatomy map (subplot 1)
%   - ON and OFF STAs at the optimal lag tau (subplots 2 and 3)
%   - Size-tuning timecourses at the STA peak location (subplots 4-6)
%   - Heatmap of cluster's dFclust responses (subplot 4)

m = (double(moviedata) - 127) / 128;   % reset movie to signed [-1, 1] range
framerange = 0:cycWindow;

display(tau)   % print current tau value for reference

for clust = 1:nclust
    figNum = figNum + 1;
    clustFigNum = figNum;   % remember this figure's number for the sgtitle at the end
    clustfig = figure('Name', sprintf('Fig %d - Cluster %d STA Summary', figNum, clust));

    %% --- Cluster anatomy map ---
    figure(clustfig)
    subplot(2,3,1);
    imagesc(stdImg, [0 prctile(stdImg(:),99)*1.2]); axis equal; hold on;
    colormap gray;
    % NOTE: freezeColors is a third-party function (FEX: freezeColors).
    % It freezes the current colormap so subsequent subplots can use different colormaps.
    % If not installed, this will error -- install from MATLAB File Exchange.
    freezeColors;
    title(sprintf('Fig %d: Cluster %d  -  Anatomy', figNum, clust));
    plot(x(c==clust), y(c==clust), 'o', 'Color', cols(clust,:))

    % Align cluster mean dF/F to each stimulus onset
    for i = 1:length(stimTimes)-2
        dFalign(i,:) = mean(dF(c==clust, stimFrames(i) + framerange), 1, 'omitnan') - ...
                       mean(mean(dF(c==clust, stimFrames(i) + baserange), 2, 'omitnan'), 1, 'omitnan');
    end

    %% --- Per-cluster STA at multiple lags (ON and OFF) ---
    sta = 0; clear stas

    for rep = 1:2
        m = (double(moviedata) - 127) / 128;
        if rep == 1
            m(m < 0) = 0;   % ON: keep positive contrast
        else
            m(m > 0) = 0;   % OFF: keep negative contrast
        end

        % Per-cluster lag figure (4x5 grid, lags 3-16) skipped for performance.
        % To re-enable: uncomment the block in the original sbxOctoSTA.m (figure; range=-2:2;
        % for taus=3:16 ... subplot(4,5,taus) ... end; title('clust N rep N')).
        % The figure was window-only (never exported to PDF) and its stas array is not
        % used downstream -- the optimal-tau STA below is computed independently.

        %% --- STA at optimal lag tau ---

        resp = mean(dFalign(:, tau + tau_range), 2, 'omitnan');
        sta = 0;
        npts = min(length(resp), size(moviedata,3));
        for i = 1:npts
            if ~isnan(resp(i))
                sta = sta + resp(i) * m(:,:,i);
            end
        end
        sta = sta / sum(abs(resp(1:npts)), 'omitnan');

        % Place STA in cluster summary figure
        figure(clustfig)
        subplot(2,3,1+rep);
        % Diverging red-blue colormap (approximates ColorBrewer RdBu).
        % Constructed inline so cbrewer toolbox is not required.
        imagesc(sta', 1.5*crange); hold on; axis equal;
        n64 = 32;
        rdbu64 = [linspace(0.70,1,n64)', linspace(0.09,1,n64)', linspace(0.13,1,n64)'; ...
                  linspace(1,0.02,n64)', linspace(1,0.44,n64)', linspace(1,0.69,n64)'];
        colormap(flipud(rdbu64))

        % Find peak location in STA
        xprofile = max(abs(sta), [], 1); [mx, xmax] = max(xprofile);
        yprofile = max(abs(sta), [], 2); [mx, ymax] = max(yprofile);
        xmax
        ymax

        % Spot size parameters
        if movienum == 1
            sz = [2 4 8 255]; col = 'bcrg';
        else
            sz = [0.8 2 4 8 255]; col = 'kbcrg';
        end

        %% --- Size-tuning timecourses at STA peak location ---

        onoffLabel = {'ON', 'OFF'};
        figNum = figNum + 1;
        figure('Name', sprintf('Fig %d - Cluster %d Size-Tuning Timecourses (%s)', figNum, clust, onoffLabel{rep}));
        hold on
        for i = 1:length(sz)
            % Find frames where a spot of this size was at the peak location
            eps = find(m(ymax,xmax,:) ~= 0 & sz_mov(ymax,xmax,:) == sz(i));
            eps = eps(eps <= size(dFalign,1));
            subplot(2,3,i); hold on
            cmap = jet(length(eps));
            for j = 1:length(eps)
                plot(dFalign(eps(j),:)', 'Color', cmap(j,:));
            end
            plot(mean(dFalign(eps,:), 1, 'omitnan'), col(i), 'Linewidth', 2);
            title(sprintf('%s sz %d', onoffLabel{rep}, sz(i)));
            ylim([-0.1 0.1])
        end
        sgtitle(sprintf('Fig %d: Cluster %d  -  Size-Tuning Timecourses (%s)', figNum, clust, onoffLabel{rep}), 'Interpreter', 'none');

        % ---- FIGURE Pg 20+: Cluster Size-Tuning Timecourses (per rep) ----
        % 2x3 grid of individual trial timecourses at the STA peak location,
        % one subplot per spot size. Color = trial index (jet). Bold = mean.
        % Shown separately for ON (rep=1) and OFF (rep=2).
        if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

        %% --- Mean size-tuning timecourses in cluster summary figure ---
        figure(clustfig)
        subplot(2,3,4+rep);
        hold on
        for i = 1:length(sz)
            eps = find(m(ymax,xmax,:) ~= 0 & sz_mov(ymax,xmax,:) == sz(i));
            eps = eps(eps <= size(dFalign,1));
            plot(mean(dFalign(eps,:), 1, 'omitnan'), col(i), 'Linewidth', 2);
        end
        if rep == 2
            % Add legend on second rep only
            if movienum == 1
                legend('2','4','8','full')
            else
                legend('1','2','4','8','full')
            end
        end
        ylim([-0.025 0.1]); xlim([1 20])

    end  % end rep loop within per-cluster analysis

    %% --- Cluster heatmap ---
    subplot(2,3,4);
    imagesc(dFclust(c==clust,:), [-0.1 0.4]); axis xy
    title(sprintf('Cluster %d  -  dFclust Heatmap', clust)); hold on

    % ---- FIGURE Pg 21+: Cluster Summary Panel ----
    % 2x3 panel layout:
    %   [1] Anatomy with cluster cells marked
    %   [2] ON STA at peak lag tau
    %   [3] OFF STA at peak lag tau
    %   [4] dFclust heatmap for cluster
    %   [5] ON size-tuning timecourses
    %   [6] OFF size-tuning timecourses
    figure(clustfig)
    sgtitle(sprintf('Fig %d: Cluster %d  -  STA Summary', clustFigNum, clust), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

end  % end for clust


%% =========================================================================
%% SECTION 22: CELL-LEVEL STA COMPUTATION
%% =========================================================================

% For each individual cell (ROI), compute:
%   - STA for ON and OFF conditions at the peak lag tau
%   - RF center location (xmax, ymax) from STA
%   - Z-score of STA peak (measures RF significance)
%   - Size-tuning timecourse at RF center for each spot size

clear stas
display('calculating cell STAs')

for n = 1:size(dF, 1)

    % Progress display every 100 cells
    if n/100 == round(n/100)
        sprintf('done %d / %d cells', n, size(dF,1))
    end

    % Align this cell's dF/F to each stimulus onset
    for i = 1:length(stimTimes)-2
        dFalign(i,:) = dF(n, stimFrames(i) + framerange) - mean(dF(n, stimFrames(i) + baserange), 2, 'omitnan');
    end

    sta = 0;

    for rep = 1:2
        m = (double(moviedata) - 127) / 128;
        if rep == 1
            m(m < 0) = 0;   % ON
        else
            m(m > 0) = 0;   % OFF
        end

        % Response at peak lag window
        resp = mean(dFalign(:, tau + tau_range), 2, 'omitnan');

        % Compute STA
        sta = 0;
        npts = min(length(resp), size(moviedata,3));
        for i = 1:npts
            if ~isnan(resp(i))
                sta = sta + resp(i) * m(:,:,i);
            end
        end
        sta = sta / sum(abs(resp(1:npts)), 'omitnan');
        stas(:,:,n,rep) = sta;

        % Find STA peak location (RF center)
        xprofile = max(abs(sta), [], 1); [mx, xmax(n,rep)] = max(xprofile);
        yprofile = max(abs(sta), [], 2); [mx, ymax(n,rep)] = max(yprofile);

        % Z-score: peak STA value relative to mean and std of the STA image.
        % High positive zscore = significant ON RF; high negative = significant OFF RF.
        zscore(n,rep) = (sta(ymax(n,rep), xmax(n,rep)) - mean(sta(:))) / std(sta(:));

        % Size-tuning timecourse at RF center for each spot size
        for i = 1:length(sz)
            eps = find(m(ymax(n,rep), xmax(n,rep),:) ~= 0 & sz_mov(ymax(n,rep), xmax(n,rep),:) == sz(i));
            eps = eps(eps <= size(dFalign,1));
            tuning(n,rep,i,:) = mean(dFalign(eps,:), 1, 'omitnan');
        end

    end
end


%% =========================================================================
%% SECTION 23: RF POPULATION ANALYSIS
%% =========================================================================

% Mean response amplitude per cell per condition (across spot sizes 1-3, lags 8-15)
amp = mean(mean(tuning(:,:,1:3,8:15), 4, 'omitnan'), 3, 'omitnan');

% Mean timecourse across spot sizes (excluding full-field)
tcourseAll = squeeze(mean(mean(tuning(:,:,1:3,:), 3, 'omitnan'), 1, 'omitnan'));

% Population-level timecourse (not printed)
figure('Name', 'Mean Timecourse ON/OFF (not printed)');
plot(tcourseAll'); title('mean timecourse'); legend('on','off');

% RF location scatter (not printed)
figure('Name', 'All RF Locations scatter (not printed)');
plot(ymax, xmax, '.'); title('all rf locations'); axis equal; axis ij

% Z-score threshold for significant RF cells
zthresh = 5.5;
use    = zscore(:,1) > zthresh | zscore(:,2) < -zthresh;   % any significant RF
useN   = find(use);
useOn  = find(zscore(:,1) > zthresh);
useOff = find(zscore(:,2) < -zthresh);

% ---- FIGURE Pg (N): ON and OFF RF Center Locations ----
% Scatter plot of RF center (x,y) for all significant cells.
% Red = ON cells; Blue = OFF cells. Equal axes.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - ON and OFF RF Center Locations', figNum));
plot(ymax(useOn,1), xmax(useOn,1), 'r.'); hold on;
plot(ymax(useOff,2), xmax(useOff,2), 'b.');
title(sprintf('Fig %d: ON and OFF RF Center Locations  (red=ON, blue=OFF)', figNum)); axis equal; axis ij
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% Store RF x/y (note: reversed from row/col convention due to movie matrix orientation)
rfx = ymax;   % RF horizontal position
rfy = xmax;   % RF vertical position

% Compute median RF center (used to center topographic plots below)
rfxs = [rfx(useOn,1); rfx(useOff,2)];
rfys = [rfy(useOn,1); rfy(useOff,2)];
x0 = median(rfxs, 'omitnan');
y0 = median(rfys, 'omitnan');

% ---- FIGURE Pg (N+1): X and Y Topography ----
% Left: cell x-position vs. RF x-position (ON=red, OFF=blue).
% Right: cell y-position vs. RF y-position.
% A positive slope indicates retinotopic organization.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - X and Y Topography', figNum));
subplot(1,2,1)
plot(xpts(useOn), rfx(useOn,1)-x0, 'r.'); hold on;
plot(xpts(useOff), rfx(useOff,2)-x0, 'b.'); ylim([-30 30]); axis square
title(sprintf('Fig %d: X Topography', figNum)); legend('ON','OFF')
xlabel('x location'); ylabel('x RF');

subplot(1,2,2)
plot(ypts(useOn), rfy(useOn,1)-y0, 'r.'); hold on;
plot(ypts(useOff), rfy(useOff,2)-y0, 'b.'); ylim([-30 30]); axis square
title('Y Topography'); legend('ON','OFF')
xlabel('y location'); ylabel('y RF');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE (not printed): ON vs OFF RF Center Correlation ----
% For cells with both ON and OFF RFs, plots ON vs OFF RF center positions.
% Correlation indicates whether ON and OFF RFs are co-localized.
useOnOff = intersect(useOn, useOff);
figure('Name', 'ON vs OFF RF Center Correlation (not printed)');
subplot(1,2,1);
plot(rfx(useOnOff,1)-x0, rfx(useOnOff,2)-x0, 'o'); axis([-20 20 -20 20]); axis square
title('X RF center'); xlabel('On'); ylabel('Off');
subplot(1,2,2);
plot(rfy(useOnOff,1)-y0, rfy(useOnOff,2)-y0, 'o'); axis([-20 20 -20 20]); axis square
title('Y RF center'); xlabel('On'); ylabel('Off');

% ---- FIGURE Pg (N+2): RF Position Map on Anatomy (X and Y, ON and OFF) ----
% 2x2 grid of anatomy images, each with cells colored by their RF position.
% Color = RF x or y position (via cmapVar).
% NOTE: cmapVar is a custom function. If not installed, this will error.
axLabel   = {'X','Y'};
onoffLabel = {'On','Off'};
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - RF Position Map on Anatomy', figNum));
for ax = 1:2
    for rep = 1:2
        subplot(2,2,2*(rep-1)+ax)
        imagesc(meanGreenImg(:,:,1)); colormap gray; axis equal
        hold on
        if rep == 1
            data = useOn;
        else
            data = useOff;
        end
        for i = 1:length(data)
            if ax == 1
                plot(xpts(data(i)), ypts(data(i)), 'o', 'Color', cmapVar(rfx(data(i),rep)-x0, -25, 25, jet(64)));
            else
                plot(xpts(data(i)), ypts(data(i)), 'o', 'Color', cmapVar(rfy(data(i),rep)-y0, -25, 25, jet(64)));
            end
        end
        title(sprintf('%s %s RF Map', axLabel{ax}, onoffLabel{rep}))
    end
end
sgtitle(sprintf('Fig %d: RF Position Map on Anatomy', figNum), 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 24: SIZE TUNING ANALYSIS
%% =========================================================================

% Mean size-tuning response per cell (lags 8-15, averaged)
sz_tune = mean(tuning(:,:,:,8:15), 4, 'omitnan');

% Size-tuning curves for significant cells (not printed)
figure('Name', 'Size-Tuning Curves Significant Cells (not printed)');
for i = 1:2
    subplot(1,2,i)
    plot(squeeze(sz_tune(useN,i,:))')
end

% Compute ON/OFF index: positive = ON-dominated, negative = OFF-dominated
notOn  = find(zscore(:,1) < zthresh);
notOff = find(zscore(:,2) > -zthresh);
ampPos = amp; ampPos(ampPos < 0) = 0;
onOff = (ampPos(:,1) - ampPos(:,2)) ./ (ampPos(:,1) + ampPos(:,2));
onOff(notOn)  = -1;   % force non-ON cells to -1
onOff(notOff) =  1;   % force non-OFF cells to +1

% ---- FIGURE Pg (N+3): ON/OFF Ratio Map ----
% Anatomy image with significant cells color-coded by their ON/OFF index.
% Color via cmapVar: warm = ON-dominated, cool = OFF-dominated.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - ON/OFF Ratio Map', figNum));
imagesc(meanGreenImg(:,:,1), [-0.5 1]); colormap gray; axis equal
hold on
for i = 1:length(useN)
    plot(xpts(useN(i)), ypts(useN(i)), 'o', 'Color', cmapVar(onOff(useN(i)), -0.5, 0.5, jet(64)));
end
title(sprintf('Fig %d: ON/OFF Ratio Map', figNum))
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% Compute size preference index:
% Weighted average of spot size index (1=small, 2=medium, 3=large)
% weighted by response amplitude.
szPref = squeeze(sz_tune(:,:,1) + sz_tune(:,:,2)*2 + sz_tune(:,:,3)*3) ./ sum(sz_tune(:,:,1:3), 3);

% ---- FIGURE Pg (N+4): Size Preference Map (ON cells) ----
% Anatomy image with ON cells color-coded by their preferred spot size.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Size Preference Map ON cells', figNum));
imagesc(meanGreenImg(:,:,1), [-0.5 1]); colormap gray; axis equal
hold on
for i = 1:length(useOn)
    plot(xpts(useOn(i)), ypts(useOn(i)), 'o', 'Color', cmapVar(szPref(useOn(i),1), 1.5, 2.5, jet(64)));
end
title(sprintf('Fig %d: Size Preference Map  -  ON Cells', figNum))
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE Pg (N+5): Size Preference Map (OFF cells) ----
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Size Preference Map OFF cells', figNum));
imagesc(meanGreenImg(:,:,1), [-0.5 1]); colormap gray; axis equal
hold on
for i = 1:length(useOff)
    plot(xpts(useOff(i)), ypts(useOff(i)), 'o', 'Color', cmapVar(szPref(useOff(i),2), 1.5, 2.5, jet(64)));
end
title(sprintf('Fig %d: Size Preference Map  -  OFF Cells', figNum))
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE Pg (N+6): Mean Size Tuning Curves ----
% 2x2 panel: ON and OFF size-tuning curves averaged across significant cells.
%   Top-left: ON cells, all sizes
%   Top-right: OFF cells, all sizes
%   Bottom-left: ON (red) and OFF (blue) overlaid, all sizes
%   Bottom-right: Legend for spot sizes
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Mean Size Tuning Curves', figNum));
subplot(2,2,1)
plot(squeeze(mean(tuning(useOn,1,:,:), 1))');
title('ON')

subplot(2,2,2)
plot(squeeze(mean(tuning(useOff,2,:,:), 1))');
title('OFF')

subplot(2,2,3)
plot(squeeze(mean(tuning(useOn,1,:,:), 1))', 'r'); hold on
plot(squeeze(mean(tuning(useOff,2,:,:), 1))', 'b');
title('ON (red) and OFF (blue)')

subplot(2,2,4)
for i = 1:length(sz); plot(1,1); hold on; end
if movienum == 1
    legend('2','4','8','full')
else
    legend('1','2','4','8','full')
end
sgtitle(sprintf('Fig %d: Mean Size Tuning Curves', figNum), 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end


%% =========================================================================
%% SECTION 25: RANDOM SAMPLE STA PLOTS
%% =========================================================================

% Select 48 random significant cells for STA visualization
n = ceil(rand(48,1) * length(useN));

% ---- FIGURE Pg (N+7) and (N+8): Random Cell STAs (ON and OFF) ----
% For each rep (ON/OFF): 6x8 grid of STA images for 48 randomly sampled
% significant cells. Each panel titled with its z-score.
% Diverging red-blue colormap constructed inline (no cbrewer2 toolbox required).
for rep = 1:2
    figNum = figNum + 1;
    figure('Name', sprintf('Fig %d - Random Cell STAs (%s)', figNum, onoffLabel{rep}));
    for i = 1:48
        subplot(6,8,i);
        imagesc(stas(:,:,useN(n(i)),rep)', [-0.1 0.1]);
        axis off; axis equal;
        n48 = 32;
        rdbu48 = [linspace(0.70,1,n48)', linspace(0.09,1,n48)', linspace(0.13,1,n48)'; ...
                  linspace(1,0.02,n48)', linspace(1,0.44,n48)', linspace(1,0.69,n48)'];
        colormap(rdbu48);
        title(sprintf('%0.2f', zscore(useN(n(i)),rep)));
    end
    sgtitle(sprintf('Fig %d: Random Cell STAs  -  %s  (48 significant cells)', figNum, onoffLabel{rep}), 'Interpreter', 'none');
    if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end
end


%% =========================================================================
%% SECTION 26: Z-SCORE VS RESPONSE AMPLITUDE SCATTER
%% =========================================================================

% ---- FIGURE Pg (N+9): Z-Score vs Amplitude Scatter ----
% For ON (left) and OFF (right): scatter of z-score vs mean response amplitude.
% Gray = all cells; Red = significant cells (above z-score threshold).
% Helps verify that the z-score threshold selects responsive cells.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Z-Score vs Amplitude Scatter', figNum));
for i = 1:2
    subplot(1,2,i);
    plot(zscore(:,i), amp(:,i), '.'); hold on;
    xlabel('zscore'); ylabel('response amp'); title(onoffLabel{i})
    plot(zscore(use,i), amp(use,i), 'r.');
end
sgtitle(sprintf('Fig %d: Z-Score vs Amplitude Scatter', figNum), 'Interpreter', 'none');
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE Pg (N+10): Z-Score vs RF X-Position ----
% Top: ON cells z-score vs RF x-position. Vertical line = z-score threshold.
% Bottom: OFF cells z-score vs RF x-position.
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Z-Score vs RF X-Position', figNum));
subplot(2,1,1)
plot(zscore(:,1), rfx(:,1), '.'); title(sprintf('Fig %d: Z-Score vs RF X  -  ON', figNum)); xlabel('zscore'); ylabel('rf X');
hold on; plot([zthresh zthresh], [0 250], 'r')
subplot(2,1,2);
plot(zscore(:,2), rfx(:,2), '.'); title('OFF'); xlabel('zscore'); ylabel('rf X');
hold on; plot([-zthresh -zthresh], [0 250], 'r')
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

% ---- FIGURE (not printed): Size-Tuning Timecourses for All Significant Cells ----
% 2x4 grid (2 reps x 4 spot sizes), each showing all significant cells' timecourses
% with mean in green. Not printed (no exportgraphics call).
figure('Name', 'Size-Tuning Timecourses All Significant Cells (not printed)');
for rep = 1:2
    for sz = 1:4
        subplot(2,4,4*(rep-1)+sz)
        plot(squeeze(tuning(useN,rep,sz,:))');
        hold on
        plot(mean(squeeze(tuning(useN,rep,sz,:)), 1), 'g', 'LineWidth', 2);
        ylim([-0.1 0.25]); xlim([0 20])
    end
end


%% =========================================================================
%% SECTION 27: CORRELATION MAP
%% =========================================================================

% ---- FIGURE Pg (N+11): Correlation Map ----
% Pairwise correlation matrix of dFclust (cells sorted by dendrogram order).
% Shows how well-separated the clusters are. Jet colormap, range [-1 1].
figNum = figNum + 1;
figure('Name', sprintf('Fig %d - Correlation Matrix After Clustering', figNum));
imagesc(corrcoef(dFclust(perm,:)'), [-1 1]); colormap jet
title(sprintf('Fig %d: Correlation Across Cells After Clustering', figNum), 'Interpreter', 'none')
if exist('psfile','var'); exportgraphics(gcf, psfile, 'Append', true); end

close all


%% =========================================================================
%% SECTION 28: SAVE PDF AND DATA
%% =========================================================================

display('saving pdf')
if Opt.SaveFigs
    if ~isfield(Opt,'pPDF') || ~isfield(Opt,'fPDF')
        if isfield(Opt,'fSbx') && isfield(Opt,'pSbx')
            Opt.pPDF = Opt.pSbx;
            Opt.fPDF = [Opt.fSbx(1:end-4) '.pdf'];
        else
            [Opt.fPDF, Opt.pPDF] = uiputfile('*.pdf', 'save pdf file');
        end
    end
    newpdfFile = fullfile(Opt.pPDF, Opt.fPDF);
    try
        % Copy the accumulated PDF to the final output location
        copyfile(psfile, newpdfFile);
    catch
        display('couldnt copy pdf to output location');
    end
end

display('saving data')
outfile = newpdfFile(1:end-4);   % strip .pdf extension for .mat filename

% Stimulus identity fields -- hardcoded for sparse noise (STA script always runs sparse noise)
StimulusStr = 'sparse noise';
StimulusNum = 0;    % sentinel value (no StimulusNum for sparse noise)
nstim       = NaN;  % not applicable for STA analysis

% Use v7.3 (HDF5) format to support variables larger than 2GB
% lagStas: [nY x nX x 18 x 2] -- per-lag STA maps (taus 3:18, rep1=ON rep2=OFF)
% staAll:  [nY x nX x nXblocks x nYblocks x 2] -- block STA maps at peak lag
save(outfile, 'moviedata', 'sz_mov', 'c', 'xpts', 'ypts', 'stdImg', 'meanGreenImg', ...
     'dF', 'stimTimes', 'stimFrames', 'tuning', 'zscore', 'rfx', 'rfy', 'stas', ...
     'lagStas', 'staAll', ...
     'StimulusStr', 'StimulusNum', 'nstim', '-v7.3');


%% =========================================================================
%% SECTION 29: ACQUISITION INFO PAGE (PDF)
%% =========================================================================

% Append a plain-text summary page to the PDF recording stimulus identity
% and key user-selected parameters. Replaces the former _info.txt sidecar file.
% This keeps all analysis outputs in a single PDF document.

infoFig = figure('Color', 'white', 'Name', 'Acquisition Info');
axis off;

% Build the info string line by line
infoLines = {};
infoLines{end+1} = '=== Acquisition Info ===';
infoLines{end+1} = '';
infoLines{end+1} = sprintf('File        : %s', outfile);
infoLines{end+1} = sprintf('Date        : %s', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
infoLines{end+1} = '';
infoLines{end+1} = '--- Stimulus ---';
infoLines{end+1} = sprintf('StimulusStr : %s', StimulusStr);
infoLines{end+1} = sprintf('StimulusNum : %d', StimulusNum);
infoLines{end+1} = 'nstim       : N/A (STA script)';
if isfield(Opt, 'noiseFile')
    infoLines{end+1} = sprintf('noiseFile   : %d', Opt.noiseFile);
end
infoLines{end+1} = '';
infoLines{end+1} = '--- User-Selected Parameters ---';
if isfield(Opt, 'selectPts')
    selectPtsLabels = {'0=auto ROI', '1=manual', '2=suite2p', '3=red/green suite2p'};
    spLabel = '';
    if Opt.selectPts >= 0 && Opt.selectPts <= 3
        spLabel = sprintf('  (%s)', selectPtsLabels{Opt.selectPts + 1});
    end
    infoLines{end+1} = sprintf('selectPts   : %d%s', Opt.selectPts, spLabel);
end
infoLines{end+1} = sprintf('nclust      : %d', nclust);
if isfield(Opt, 'sub_noise')
    infoLines{end+1} = sprintf('sub_noise   : %d', Opt.sub_noise);
end
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
infoLines{end+1} = sprintf('nSig (ON)   : %d', sum(zscore(:,1) > zthresh));
infoLines{end+1} = sprintf('nSig (OFF)  : %d', sum(zscore(:,2) < -zthresh));
infoLines{end+1} = sprintf('nFigures    : %d (printed to PDF)', figNum);

text(0.05, 0.95, strjoin(infoLines, '\n'), ...
    'Units', 'normalized', 'VerticalAlignment', 'top', ...
    'FontName', 'Courier', 'FontSize', 10, 'Interpreter', 'none');

if exist('psfile','var'); exportgraphics(infoFig, psfile, 'Append', true); end
     