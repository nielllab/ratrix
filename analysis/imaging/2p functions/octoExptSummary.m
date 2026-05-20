function octoExptSummary(exptDir, outFile, Opt)
%% octoExptSummary - Experiment-level summary PDF for octopus 2-photon recordings
%
% PURPOSE:
%   Generates a single multi-page PDF summary of an entire experiment.
%   One page is produced per acquisition, ordered by acquisition number.
%   Each page includes pre/post z-stack image placeholders, an activity GIF
%   frame, and stimulus-specific analysis panels drawn from the saved .mat
%   analysis outputs.
%
% USAGE:
%   octoExptSummary()                      % prompts for directory and output file
%   octoExptSummary(exptDir)               % uses specified experiment directory
%   octoExptSummary(exptDir, outFile)
%   octoExptSummary(exptDir, outFile, Opt) % Opt.recordID: optional sample record ID string
%
% FILE NAMING CONVENTIONS (assumed):
%   Stimulus records   : *Acq{N}.mat             (in exptDir)
%   Analysis outputs   : *Acq{N}*.mat            (in exptDir, longer name)
%   Raw imaging        : *{00N}.sbx              (in exptDir)
%   AVI movies         : *{00N}.avi              (in exptDir, same base as .sbx)
%
% STIMULUS TYPES HANDLED:
%   Spontaneous noise  : header only (zstack placeholders + GIF)
%   Aborted/unknown    : header + warning note
%   6x4 spots          : nstim == 48 or 50; weighted pixel maps + traces
%   8-way gratings     : nstim == 17; population timecourse + pixel map + traces
%   Sparse noise (STA) : StimulusStr contains 'sparse'; STA panels + traces + RF locations
%
% OUTPUTS:
%   Multi-page PDF saved to outFile
%   GIF files auto-generated alongside each AVI (if not already present)
%
% DEPENDENCIES:
%   Analysis .mat files produced by sbxOctoNeural_DR_commented_v6.m and/or
%   sbxOctoSTA_DR_v2.m (must contain nstim, StimulusStr, StimulusNum,
%   weightTcourse, trialmean, stimOrder, stdImg, c, xpts, ypts,
%   cycPolarImg, xpolarImg, ypolarImg, lagStas, zscore,
%   rfx, rfy, meanGreenImg as applicable).
%   No Image Processing Toolbox required (imresize replaced with interp2).
%   GIF files auto-generated from AVI files and shown in col 3 of each page.

%% =========================================================================
%% SECTION 1: SETUP  -  DIRECTORIES AND OUTPUT FILE
%% =========================================================================

if nargin < 1 || isempty(exptDir)
    exptDir = uigetdir('', 'Select experiment directory');
    if isequal(exptDir, 0); return; end
end

[~, exptName] = fileparts(exptDir);

if nargin < 2 || isempty(outFile)
    defaultName = fullfile(exptDir, [exptName '_Summary.pdf']);
    [fOut, pOut] = uiputfile('*.pdf', 'Save experiment summary PDF', defaultName);
    if isequal(fOut, 0); return; end
    outFile = fullfile(pOut, fOut);
end

% Delete any existing output file so exportgraphics starts fresh
if exist(outFile, 'file'); delete(outFile); end

% Sample record ID  -  use Opt.recordID if provided, otherwise prompt the user
if nargin >= 3 && isstruct(Opt) && isfield(Opt, 'recordID') && ~isempty(Opt.recordID)
    recordID = char(Opt.recordID);
else
    answer = inputdlg('Enter sample record ID:', 'Sample Record ID', 1, {''});
    if isempty(answer)
        % User cancelled dialog  -  leave blank
        recordID = '';
    else
        recordID = strtrim(answer{1});
    end
end

display(['Generating experiment summary: ' exptName]);

%% =========================================================================
%% SECTION 2: BUILD ACQUISITION LIST
%% =========================================================================
% Strategy: use stimulus record files (*Acq{N}.mat, exactly) as the primary
% index of analysed acquisitions. Then find .sbx files for all acquisitions
% (analysed and spontaneous/aborted).
%
% Stimulus records : filename matches /Acq\d+\.mat$/ (e.g. 021621_Acq2.mat)
% Analysis outputs : filename matches /Acq\d+.+\.mat$/ (longer, same Acq#)
% Raw imaging      : *.sbx; trailing digits give acquisition number
% AVI movies       : same base name as .sbx

allMats  = dir(fullfile(exptDir, '*Acq*.mat'));
sbxFiles = dir(fullfile(exptDir, '*.sbx'));
if isempty(sbxFiles)
    error('No .sbx files found in: %s', exptDir);
end

% ---- Identify stimulus records (end exactly with Acq{N}.mat) ----
isStimRec = ~cellfun(@isempty, regexp({allMats.name}, 'Acq\d+\.mat$'));
stimRecs  = allMats(isStimRec);
analysisMats = allMats(~isStimRec);   % longer names = analysis outputs

% Build a map: acqNum -> stimulus record filename
stimMap = containers.Map('KeyType','int32','ValueType','char');
for i = 1:length(stimRecs)
    tok = regexp(stimRecs(i).name, 'Acq(\d+)\.mat$', 'tokens');
    if ~isempty(tok)
        stimMap(int32(str2double(tok{1}{1}))) = fullfile(exptDir, stimRecs(i).name);
    end
end

% Build a map: acqNum -> analysis output filename (most recent if >1)
analysisMap = containers.Map('KeyType','int32','ValueType','char');
for i = 1:length(analysisMats)
    tok = regexp(analysisMats(i).name, 'Acq(\d+)', 'tokens');
    if ~isempty(tok)
        n = int32(str2double(tok{1}{1}));
        if ~isKey(analysisMap, n) || analysisMats(i).datenum > ...
                dir(analysisMap(n)).datenum
            analysisMap(n) = fullfile(exptDir, analysisMats(i).name);
        end
    end
end

% Collect all unique acquisition numbers (from sbx files + stimulus records)
sbxNums = zeros(1, length(sbxFiles));
sbxMap  = containers.Map('KeyType','int32','ValueType','char');
for i = 1:length(sbxFiles)
    tok = regexp(sbxFiles(i).name, '(\d+)\.sbx$', 'tokens');
    if ~isempty(tok)
        n = int32(str2double(tok{1}{1}));
        sbxNums(i) = n;
        sbxMap(n)  = fullfile(exptDir, sbxFiles(i).name);
    end
end
if stimMap.Count > 0
    stimKeys = double(cell2mat(stimMap.keys));
else
    stimKeys = [];
end
allNums = unique([double(sbxNums) stimKeys]);

% Build a map: acqNum -> AVI file (searches directory independently of .sbx names)
aviFiles = dir(fullfile(exptDir, '*.avi'));
aviMap   = containers.Map('KeyType','int32','ValueType','char');
for i = 1:length(aviFiles)
    tok = regexp(aviFiles(i).name, '(\d+)\.avi$', 'tokens');
    if ~isempty(tok)
        n = int32(str2double(tok{1}{1}));
        % Keep most recently modified if multiple match same number
        if ~isKey(aviMap, n) || aviFiles(i).datenum > dir(aviMap(n)).datenum
            aviMap(n) = fullfile(exptDir, aviFiles(i).name);
        end
    end
end

% ---- Build acquisition struct ----
acqs = struct('acqNum',{}, 'sbxFile',{}, 'aviFile',{}, ...
              'stimFile',{}, 'analysisFile',{}, ...
              'StimulusStr',{}, 'StimulusNum',{}, 'nstim',{});

for i = 1:length(allNums)
    n   = int32(allNums(i));
    idx = i;
    acqs(idx).acqNum = double(n);

    % sbx file
    if isKey(sbxMap, n)
        acqs(idx).sbxFile = sbxMap(n);
    else
        acqs(idx).sbxFile = '';
    end

    % AVI file  -  from directory scan keyed by acquisition number
    if isKey(aviMap, n)
        acqs(idx).aviFile = aviMap(n);
    elseif isKey(sbxMap, n)
        % Fallback: same base name as .sbx
        sbxBase = sbxMap(n); sbxBase = sbxBase(1:end-4);
        fallbackAvi = [sbxBase '.avi'];
        if exist(fallbackAvi, 'file')
            acqs(idx).aviFile = fallbackAvi;
        else
            acqs(idx).aviFile = '';
        end
    else
        acqs(idx).aviFile = '';
    end

    % Stimulus record
    if isKey(stimMap, n)
        acqs(idx).stimFile = stimMap(n);
        try
            tmp = load(acqs(idx).stimFile, 'StimulusStr', 'StimulusNum');
            ss = tmp.StimulusStr;
            if iscell(ss); ss = ss{1}; end
            acqs(idx).StimulusStr  = char(ss);
            acqs(idx).StimulusNum  = double(tmp.StimulusNum);
        catch
            acqs(idx).StimulusStr  = 'unknown';
            acqs(idx).StimulusNum  = -1;
        end
    else
        acqs(idx).stimFile    = '';
        acqs(idx).StimulusStr = 'spontaneous';
        acqs(idx).StimulusNum = 0;
    end

    % Analysis output + nstim
    acqs(idx).analysisFile = '';
    acqs(idx).nstim        = NaN;
    if isKey(analysisMap, n)
        acqs(idx).analysisFile = analysisMap(n);
        % Try loading nstim; fall back to deriving from stimOrder
        try
            tmp2 = load(acqs(idx).analysisFile, 'nstim');
            acqs(idx).nstim = double(tmp2.nstim);
        catch
            try
                tmp3 = load(acqs(idx).analysisFile, 'stimOrder');
                acqs(idx).nstim = double(max(tmp3.stimOrder));
            catch
                % Leave as NaN  -  will fall through to 'unknown' page type
            end
        end
    end
end

% Sort by acquisition number
[~, sortIdx] = sort([acqs.acqNum]);
acqs = acqs(sortIdx);
display(sprintf('Found %d acquisitions', length(acqs)));

%% =========================================================================
%% SECTION 2b: COLLECT PRE / POST EXPERIMENT Z-STACK IMAGES
%% =========================================================================
% Ask once for a single pre-experiment and post-experiment z-stack image.
% These appear only on the experiment summary page (page 1).
% Press Cancel to skip either image.

display('Select pre- and post-experiment z-stack images for the summary page.');
display('Press Cancel to skip either image.');

imgFilter = {'*.tif;*.tiff;*.png;*.jpg;*.bmp', 'Images (*.tif,*.tiff,*.png,*.jpg,*.bmp)'};

[f, p] = uigetfile(imgFilter, 'PRE-experiment z-stack  (Cancel to skip)', exptDir);
if ~isequal(f, 0)
    exptPreZstack = fullfile(p, f);
else
    exptPreZstack = '';
end

[f, p] = uigetfile(imgFilter, 'POST-experiment z-stack  (Cancel to skip)', exptDir);
if ~isequal(f, 0)
    exptPostZstack = fullfile(p, f);
else
    exptPostZstack = '';
end

%% =========================================================================
%% SECTION 3: GENERATE EXPERIMENT SUMMARY PAGE (PAGE 1)
%% =========================================================================

% Build date string from experiment folder name (first 6 digits) or today
dateMatch = regexp(exptName, '^\d{6}', 'match');
if ~isempty(dateMatch)
    d = dateMatch{1};
    dateStr = sprintf('20%s-%s-%s', d(1:2), d(3:4), d(5:6));
else
    dateStr = datestr(now, 'yyyy-mm-dd');
end

% Build title string
if isempty(recordID)
    summaryTitle = sprintf('%s experiment summary', dateStr);
else
    summaryTitle = sprintf('%s experiment summary - %s', dateStr, recordID);
end

figSum = figure('Units', 'inches', 'Position', [0 0 17 11], ...
                'Color', 'w', 'PaperOrientation', 'landscape', ...
                'PaperUnits', 'inches', 'PaperSize', [17 11], ...
                'PaperPosition', [0 0 17 11]);

% Page margin constants (1 cm on 17x11 inches, normalized)
% mX = 1cm/17in = 0.0232,  mY = 1cm/11in = 0.0358
mX_sum = 1 / (2.54 * 17);   % 0.02315
mY_sum = 1 / (2.54 * 11);   % 0.03584

% Title bar sits at top with 1cm margin above and below
% Top of title = 1 - mY_sum, height = labelH_sum
labelH_sum  = 0.05;
titleTop_sum = 1 - mY_sum;
titleY_sum   = titleTop_sum - labelH_sum;

annotation('textbox', [mX_sum, titleY_sum, 1 - 2*mX_sum, labelH_sum], ...
           'String', summaryTitle, 'FontSize', 14, 'FontWeight', 'bold', ...
           'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
           'Interpreter', 'none', 'VerticalAlignment', 'middle', ...
           'Color', 'k');

% Z-stack panels:
%   Usable x: mX_sum to 1-mX_sum
%   1 cm gap between panels
%   Usable y: mY_sum (bottom) to titleY_sum - mY_sum (below title with 1cm gap)
zUsableW = 1 - 2*mX_sum;
zGapX    = mX_sum;
zPanW    = (zUsableW - zGapX) / 2;
zPanY    = mY_sum;
zPanH    = titleY_sum - 2*mY_sum;

% Pre z-stack (left)
axPre = axes('Position', [mX_sum, zPanY, zPanW, zPanH], 'Parent', figSum);
showZstack(axPre, exptPreZstack, 'PRE-experiment Z-stack');

% Post z-stack (right)
axPost = axes('Position', [mX_sum + zPanW + zGapX, zPanY, zPanW, zPanH], 'Parent', figSum);
showZstack(axPost, exptPostZstack, 'POST-experiment Z-stack');

% White patch spanning full figure -- gives exportgraphics a content boundary
% that matches the full page, preserving margins.
axBorder = axes('Position', [0 0 1 1], 'Parent', figSum, ...
                'XLim', [0 1], 'YLim', [0 1], 'Visible', 'off', 'HitTest', 'off');
patch(axBorder, [0 1 1 0], [0 0 1 1], 'white', 'EdgeColor', 'none');
uistack(axBorder, 'bottom');

exportgraphics(figSum, outFile, 'ContentType', 'vector', ...
               'BackgroundColor', 'white', 'Append', false);
close(figSum);
display('  Summary page done (page 1)');

%% =========================================================================
%% SECTION 4: GENERATE ONE PAGE PER ACQUISITION
%% =========================================================================

for i = 1:length(acqs)
    acq      = acqs(i);
    stimStr  = lower(acq.StimulusStr);
    display(sprintf('  Acq %d: %s', acq.acqNum, acq.StimulusStr));

    % Classify stimulus type
    isSpontaneous = isempty(acq.stimFile) || contains(stimStr, 'spontaneous');

    % Detect sparse noise (STA script output) by variable content, not StimulusStr.
    % STA outputs contain 'stas' and 'rfx'; the neural script never produces these.
    % Fall back to StimulusStr keyword check if no analysis file is present.
    isSparseNoise = false;
    if ~isempty(acq.analysisFile) && exist(acq.analysisFile, 'file')
        try
            fileVars = {whos('-file', acq.analysisFile).name};
            if any(strcmp(fileVars, 'stas')) || any(strcmp(fileVars, 'rfx'))
                isSparseNoise = true;
            end
        catch
            % whos failed  -  fall back to name check
            isSparseNoise = contains(stimStr, 'sparse') || contains(stimStr, 'noise');
        end
    end
    if ~isSparseNoise
        isSparseNoise = contains(stimStr, 'sparse') || contains(stimStr, 'noise');
    end

    is6x4  = ~isempty(acq.analysisFile) && ~isSparseNoise && ismember(acq.nstim, [48 50]);
    is8way = ~isempty(acq.analysisFile) && ~isSparseNoise && acq.nstim == 17;
    % Aborted: has stimulus record but no analysis file
    isAborted = ~isSpontaneous && ~isSparseNoise && ~is6x4 && ~is8way && ...
                ~isempty(acq.stimFile) && isempty(acq.analysisFile);
    isUnknownNstim = ~isSpontaneous && ~isSparseNoise && ~is6x4 && ~is8way && ...
                     ~isAborted && ~isempty(acq.analysisFile) && isnan(acq.nstim);

    % Build human-readable type label for page title
    if isSpontaneous
        stimTypeLabel = 'Spontaneous';
    elseif is6x4
        stimTypeLabel = sprintf('6 by 4 Spots  (nstim = %d)', acq.nstim);
    elseif is8way
        stimTypeLabel = '8-Way Gratings';
    elseif isSparseNoise
        stimTypeLabel = 'Sparse Noise (STA)';
    elseif isAborted
        stimTypeLabel = sprintf('%s  [no analysis output]', acq.StimulusStr);
    elseif isUnknownNstim
        stimTypeLabel = sprintf('%s  (nstim unknown)', acq.StimulusStr);
    else
        stimTypeLabel = sprintf('%s  (nstim = %g)', acq.StimulusStr, acq.nstim);
    end

    % ---- Create figure (landscape, A3-ish for density) ----
    fig = figure('Units', 'inches', 'Position', [0 0 17 11], ...
                 'Color', 'w', 'PaperOrientation', 'landscape', ...
                 'PaperUnits', 'inches', 'PaperSize', [17 11], ...
                 'PaperPosition', [0 0 17 11]);

    % Page margin constants (1 cm, normalized)
    mX = 1 / (2.54 * 17);   % 0.02315  horizontal
    mY = 1 / (2.54 * 11);   % 0.03584  vertical

    % Title bar: 1cm margin on all sides, sits at top of page
    titleH = 0.05;
    titleY = 1 - mY - titleH;
    annotation(fig, 'textbox', [mX, titleY, 1 - 2*mX, titleH], ...
               'String', sprintf('Acq %d  -  %s  |  %s', acq.acqNum, stimTypeLabel, exptName), ...
               'FontSize', 14, 'FontWeight', 'bold', ...
               'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
               'Interpreter', 'none', 'VerticalAlignment', 'middle', ...
               'Color', 'k');

    % ---- Derive GIF path and auto-generate if needed ----
    if ~isempty(acq.aviFile) && exist(acq.aviFile, 'file')
        [aviDir, aviBase] = fileparts(acq.aviFile);
        gifFile = fullfile(aviDir, [aviBase '.gif']);
        if ~exist(gifFile, 'file')
            try; generateGif(acq.aviFile, gifFile); catch; gifFile = ''; end
        end
    else
        gifFile = '';
    end

    % ---- Stimulus-specific panels (full page below title bar) ----
    if isSpontaneous
        annotation(fig, 'textbox', [mX 0.40 1-2*mX 0.18], ...
                   'String', 'Spontaneous noise  -  no stimulus record', ...
                   'FontSize', 14, 'HorizontalAlignment', 'center', ...
                   'VerticalAlignment', 'middle', 'EdgeColor', [0.75 0.75 0.75], ...
                   'BackgroundColor', [0.96 0.96 0.96], 'Interpreter', 'none', 'Color', 'k');

    elseif isAborted
        annotation(fig, 'textbox', [mX 0.40 1-2*mX 0.18], ...
                   'String', sprintf('Stimulus: %s\nNo analysis output found  -  acquisition may have ended prematurely.', ...
                                     acq.StimulusStr), ...
                   'FontSize', 12, 'HorizontalAlignment', 'center', ...
                   'VerticalAlignment', 'middle', 'EdgeColor', [0.85 0.72 0.3], ...
                   'BackgroundColor', [1.0 0.97 0.87], 'Interpreter', 'none', 'Color', 'k');

    elseif is6x4
        panelSpotsPage(acq.analysisFile, fig, acq.nstim, acq.aviFile, gifFile);

    elseif is8way
        panelGratingsPage(acq.analysisFile, fig, acq.nstim, acq.aviFile, gifFile);

    elseif isSparseNoise
        panelSTAPage(acq.analysisFile, fig, acq.aviFile, gifFile);

    elseif isUnknownNstim
        annotation(fig, 'textbox', [mX 0.40 1-2*mX 0.18], ...
                   'String', sprintf(['Analysis file found but nstim could not be determined.\n' ...
                                      'StimulusStr: %s\n' ...
                                      'Cannot classify stimulus type  -  check that stimOrder is saved in the .mat file.'], ...
                                     acq.StimulusStr), ...
                   'FontSize', 11, 'HorizontalAlignment', 'center', ...
                   'VerticalAlignment', 'middle', 'EdgeColor', [0.85 0.72 0.3], ...
                   'BackgroundColor', [1.0 0.97 0.87], 'Interpreter', 'none', 'Color', 'k');

    else
        annotation(fig, 'textbox', [mX 0.40 1-2*mX 0.18], ...
                   'String', sprintf('Stimulus: %s  (nstim = %g)\nStimulus type not recognised  -  no panels defined.', ...
                                     acq.StimulusStr, acq.nstim), ...
                   'FontSize', 12, 'HorizontalAlignment', 'center', ...
                   'VerticalAlignment', 'middle', 'EdgeColor', [0.68 0.68 0.88], ...
                   'BackgroundColor', [0.93 0.93 1.00], 'Interpreter', 'none', 'Color', 'k');
    end

    % White patch spanning full figure preserves margins in exportgraphics.
    axBorder = axes('Position', [0 0 1 1], 'Parent', fig, ...
                    'XLim', [0 1], 'YLim', [0 1], 'Visible', 'off', 'HitTest', 'off');
    patch(axBorder, [0 1 1 0], [0 0 1 1], 'white', 'EdgeColor', 'none');
    uistack(axBorder, 'bottom');

    exportgraphics(fig, outFile, 'ContentType', 'vector', ...
                   'BackgroundColor', 'white', 'Append', true);
    close(fig);
    display(sprintf('    Page %d/%d done', i+1, length(acqs)+1));
end

display(['Summary PDF saved: ' outFile]);

end   % ---- end main function ----


%% =========================================================================
%% LOCAL HELPER: placeholderAxes
%% =========================================================================
function placeholderAxes(ax, txt)
    set(ax, 'Color', [0.92 0.92 0.92], 'XTick', [], 'YTick', [], 'Box', 'on');
    text(0.5, 0.5, txt, 'Units', 'normalized', 'Parent', ax, ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
         'FontSize', 9, 'Color', [0.4 0.4 0.4], 'Interpreter', 'none');
end


%% =========================================================================
%% LOCAL HELPER: showGifFrame
%% Display first frame of GIF or AVI, or a placeholder if neither is available
%% =========================================================================
function showGifFrame(ax, gifFile, aviFile)
    shown = false;

    if ~isempty(gifFile) && exist(gifFile, 'file')
        try
            frame = imread(gifFile, 1);
            showFrame(ax, frame);
            title(ax, 'Activity (GIF  -  frame 1)', 'Interpreter', 'none', 'FontSize', 8);
            shown = true;
        catch; end
    end

    if ~shown && ~isempty(aviFile) && exist(aviFile, 'file')
        try
            v     = VideoReader(aviFile);
            frame = readFrame(v);
            showFrame(ax, frame);
            title(ax, 'Activity (AVI  -  frame 1)', 'Interpreter', 'none', 'FontSize', 8);
            shown = true;
        catch; end
    end

    if ~shown
        placeholderAxes(ax, 'AVI / GIF not found');
    end
end

function showFrame(ax, frame)
% Display an image frame in axes ax without requiring Image Processing Toolbox
    if size(frame, 3) == 3
        % RGB: use image() which accepts uint8 truecolor natively
        image(frame, 'Parent', ax);
    else
        % Grayscale
        imagesc(frame, 'Parent', ax);
        colormap(ax, 'gray');
    end
    set(ax, 'XTick', [], 'YTick', []);
    axis(ax, 'image');
end


%% =========================================================================
%% LOCAL HELPER: showZstack
%% Display a z-stack image (tif/png/jpg) or a placeholder if none selected
%% =========================================================================
function showZstack(ax, imgFile, titleStr)
    if ~isempty(imgFile) && exist(imgFile, 'file')
        try
            info = imfinfo(imgFile);
            % For multi-page tif, find the middle page (best representative)
            pageIdx = max(1, round(length(info) / 2));
            if length(info) > 1
                frame = imread(imgFile, pageIdx);
            else
                frame = imread(imgFile);
            end
            showFrame(ax, frame);
            [~, fname] = fileparts(imgFile);
            if length(info) > 1
                titleStr = sprintf('%s\n%s  [pg %d/%d]', titleStr, fname, pageIdx, length(info));
            else
                titleStr = sprintf('%s\n%s', titleStr, fname);
            end
            title(ax, titleStr, 'Interpreter', 'none', 'FontSize', 7);
            return;
        catch ME
            placeholderAxes(ax, sprintf('%s\n(load failed: %s)', titleStr, ME.message));
            return;
        end
    end
    placeholderAxes(ax, sprintf('%s\n\nInsert image here', titleStr));
end


%% =========================================================================
%% LOCAL HELPER: generateGif
%% Convert an AVI file to an animated GIF (max 60 frames, grayscale).
%% No Image Processing Toolbox required  -  grayscale conversion is inline.
%% =========================================================================
function generateGif(aviFile, gifFile)
    v           = VideoReader(aviFile);
    totalFrames = max(1, floor(v.Duration * v.FrameRate));
    targetFrames = min(totalFrames, 60);
    frameStep   = max(1, floor(totalFrames / targetFrames));
    delayTime   = frameStep / v.FrameRate;

    % Build a 256-level grayscale colormap manually (no toolbox needed)
    grayLevels = linspace(0, 1, 256)';
    cmap       = [grayLevels, grayLevels, grayLevels];

    frameIdx = 0;
    gifIdx   = 0;
    while hasFrame(v)
        frame    = readFrame(v);
        frameIdx = frameIdx + 1;
        if mod(frameIdx - 1, frameStep) ~= 0; continue; end
        gifIdx   = gifIdx + 1;

        % Convert to grayscale without Image Processing Toolbox
        if size(frame, 3) == 3
            gframe = 0.299*double(frame(:,:,1)) + ...
                     0.587*double(frame(:,:,2)) + ...
                     0.114*double(frame(:,:,3));
        else
            gframe = double(frame);
        end
        % Normalise to 0-255 and cast to uint8 indexed
        gMin = min(gframe(:)); gMax = max(gframe(:));
        if gMax > gMin
            ind = uint8(round(255 * (gframe - gMin) / (gMax - gMin)));
        else
            ind = uint8(zeros(size(gframe)));
        end

        if gifIdx == 1
            imwrite(ind, cmap, gifFile, 'gif', 'LoopCount', Inf, 'DelayTime', delayTime);
        else
            imwrite(ind, cmap, gifFile, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
        end
    end
end


%% =========================================================================
%% LOCAL HELPER: panelSpotsPage  (nstim == 48 / 50)
%%
%% Layout: 3 columns across the full page (below title bar, y=0.01-0.95).
%%
%%   Col 1 (x=0.010-0.333): OFF pixel maps (4x6) + OFF weighted timecourses (4x6)
%%   Col 2 (x=0.343-0.666): ON  pixel maps (4x6) + ON  weighted timecourses (4x6)
%%   Col 3 (x=0.676-0.990): GIF placeholder (top 18%) +
%%                          Retinotopy Summary OFF 2x2 grid (38%) +
%%                          Retinotopy Summary ON  2x2 grid (38%)
%%                          (~6% used by gaps between blocks)
%%                          Each 2x2: anatomy | overlay // X map | Y map
%%
%% Within each data column (bottom to top):
%%   TC grid   : 4 rows x panH_tc each
%%   TC label  : labelH strip
%%   Pix grid  : 4 rows x panH_pix each
%%   Pix label : labelH strip at top
%%
%% Key variable shapes (from sbxOctoNeural_DR_commented_v5.m):
%%   trialmean      : [nY x nX x nPresentations]   -  smoothed pixel response per trial
%%   stimOrder      : [1 x nPresentations]          -  condition index (1:nstim) per trial
%%   weightTcourse  : [tcRange x nPresentations]    -  anatomy-weighted timecourse per trial
%%   xpolarImg      : cell{1=OFF, 2=ON}             -  HSV X (azimuth) retinotopy map
%%   ypolarImg      : cell{1=OFF, 2=ON}             -  HSV Y (elevation) retinotopy map
%%   topoOverlayImg : cell{1=OFF, 2=ON}             -  retinotopy overlay on anatomy (RGB)
%%   meanGreenImg   : [nY x nX x nCh]              -  mean green anatomy image (uint8 RGB)
%%
%% loc maps condition index (1:nHalf) to 4x6 subplot position to preserve
%% the spatial arrangement of the spot grid on screen (matches pixPlot_DR /
%% pixPlotWeight_DR used in the full analysis PDF).
%% =========================================================================
function panelSpotsPage(analysisFile, fig, nstim, aviFile, gifFile)
    try
        D = load(analysisFile, 'weightTcourse', 'trialmean', 'stdImg', ...
                 'stimOrder', 'xpolarImg', 'ypolarImg', 'topoOverlayImg', 'meanGreenImg');
    catch ME
        annotation(fig, 'textbox', [0.02 0.05 0.96 0.85], ...
                   'String', ['Could not load analysis data: ' ME.message], ...
                   'FontSize', 10, 'EdgeColor', 'r', 'Interpreter', 'none', ...
                   'Color', 'k');
        return;
    end

    % Reconstruct normgreen from stdImg (matches sbxOctoNeural_DR_commented_v5.m lines 468-474).
    % normgreen is not saved to the mat file; stdImg is.
    % normgreen is a 3-channel [0,1] RGB weighting image derived from the standard
    % deviation image. Multiplying jet-coloured pixel maps by normgreen suppresses
    % responses in dim/non-tissue regions and emphasises signals in bright areas.
    if isfield(D, 'stdImg')
        ng = (D.stdImg - prctile(D.stdImg(:), 1)) / ...
             (prctile(D.stdImg(:), 99) * 1.5 - prctile(D.stdImg(:), 1));
        ng = ng * 2;
        ng(ng < 0) = 0;
        ng(ng > 1) = 1;
        normgreen = repmat(ng, [1 1 3]);
        hasNormgreen = true;
    else
        hasNormgreen = false;
    end

    nHalf   = nstim / 2;
    nrow    = 4;
    ncol    = 6;
    loc     = [1 7 13 19 2 8 14 20 3 9 15 21 4 10 16 22 5 11 17 23 6 12 18 24];
    range   = [-0.05 0.20];
    tcRange = size(D.weightTcourse, 1);
    t       = 1:tcRange;

    % ---- Layout constants ----
    mX      = 1 / (2.54 * 17);    % 1 cm horizontal margin
    mY      = 1 / (2.54 * 11);    % 1 cm vertical margin
    titleH  = 0.05;
    titleY  = 1 - mY - titleH;    % bottom of title bar

    top     = titleY - mY;         % top of content area (1 cm below title)
    bottom  = mY;                  % bottom of content area
    left    = mX;
    right   = 1 - mX;

    usable_w = right - left;

    % Three equal columns. Gap between columns is halved (mX/2) so all three
    % fit within the margins at equal width.
    gap     = mX / 2;
    colW    = (usable_w - 2*gap) / 3;
    col1_left = left;
    col2_left = col1_left + colW + gap;
    col3_left = col2_left + colW + gap;

    % Within each data column: two row-groups stacked (pix maps top, TC bottom)
    labelH    = 0.030;
    panW      = colW / ncol;
    panH      = panW * (17 / 11);   % near-square on 17x11 page

    % Vertical positions top-to-bottom; empty space accumulates at bottom
    yPixLabel = top - labelH;
    yPixGrid  = yPixLabel - nrow * panH;
    yTCLabel  = yPixGrid - labelH;
    yTCGrid   = yTCLabel - nrow * panH;   % bottom of TC grid

    % ---- Retino column geometry (used for side-by-side X/Y images in col 3) ----
    ret_hgap  = mX / 4;             % narrow horizontal gap between X and Y subpanels

    % =====================================================================
    % COLS 1 and 2: Weighted pixel maps + weighted timecourses (OFF and ON)
    % Pixel maps: jet colormap applied to trialmean, multiplied by normgreen.
    % Falls back to plain imagesc if stdImg was absent.
    % =====================================================================
    for grp = 1:2
        condOffset = (grp - 1) * nHalf;
        xBase      = [col1_left, col2_left];
        xBase      = xBase(grp);
        if grp == 1
            pixStr = 'OFF Spots: Weighted Pixel Map';
            tcStr  = 'OFF Spots: Weighted Trial Timecourses';
        else
            pixStr = 'ON Spots: Weighted Pixel Map';
            tcStr  = 'ON Spots: Weighted Trial Timecourses';
        end

        annotation(fig, 'textbox', [xBase yPixLabel colW labelH], ...
                   'String', pixStr, 'FontSize', 8, 'FontWeight', 'bold', ...
                   'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
                   'Interpreter', 'none', 'VerticalAlignment', 'middle', 'Color', 'k');

        annotation(fig, 'textbox', [xBase yTCLabel colW labelH], ...
                   'String', tcStr, 'FontSize', 8, 'FontWeight', 'bold', ...
                   'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
                   'Interpreter', 'none', 'VerticalAlignment', 'middle', 'Color', 'k');

        for i = 1:nHalf
            subPos = loc(i);
            subRow = ceil(subPos / ncol);
            subCol = mod(subPos - 1, ncol) + 1;
            xPos   = xBase + (subCol - 1) * panW;
            cond   = i + condOffset;

            % Weighted pixel map: jet RGB * normgreen (matches pixPlotWeight_DR)
            yPosPix = yPixLabel - subRow * panH;
            ax = axes('Position', [xPos+0.0005 yPosPix+0.0005 panW*0.98 panH*0.97], ...
                      'Parent', fig); %#ok<LAXES>
            meanimg = median(D.trialmean(:,:, D.stimOrder == cond), 3, 'omitnan');
            if hasNormgreen
                scaled = (meanimg - range(1)) / (range(2) - range(1));
                scaled = max(0, min(1, scaled));
                jmap   = jet(256);
                idx    = round(scaled * 255) + 1;
                rgbImg = reshape(jmap(idx(:), :), [size(meanimg,1) size(meanimg,2) 3]);
                ngRes  = normgreen;
                if ~isequal(size(ngRes,1), size(rgbImg,1)) || ~isequal(size(ngRes,2), size(rgbImg,2))
                    [xi,yi] = meshgrid(linspace(1,size(ngRes,2),size(rgbImg,2)), ...
                                       linspace(1,size(ngRes,1),size(rgbImg,1)));
                    [xi0,yi0] = meshgrid(1:size(ngRes,2), 1:size(ngRes,1));
                    ngRes = cat(3, interp2(xi0,yi0,ngRes(:,:,1),xi,yi,'linear',0), ...
                                   interp2(xi0,yi0,ngRes(:,:,2),xi,yi,'linear',0), ...
                                   interp2(xi0,yi0,ngRes(:,:,3),xi,yi,'linear',0));
                end
                image(ax, rgbImg .* ngRes);
            else
                imagesc(ax, meanimg, range);
                colormap(ax, 'jet');
            end
            axis(ax, 'off');

            % Weighted timecourse -- small visible axes with white background
            % Leftmost column (subCol==1) shows y-axis scale; others hide it.
            yPosTC = yTCLabel - subRow * panH;
            ax = axes('Position', [xPos+0.0005 yPosTC+0.0005 panW*0.98 panH*0.97], ...
                      'Parent', fig); %#ok<LAXES>
            set(ax, 'Color', 'w', 'Box', 'on', 'XTick', [], ...
                'XColor', 'k', 'YColor', 'k', 'LineWidth', 0.5);
            traceData = D.weightTcourse(:, D.stimOrder == cond);
            if ~isempty(traceData)
                nTr  = size(traceData, 2);
                cmap = jet(max(nTr, 1));
                hold(ax, 'on');
                for tr = 1:nTr
                    plot(ax, t, traceData(:, tr), 'Color', cmap(tr,:), 'LineWidth', 0.5);
                end
                plot(ax, t, median(traceData, 2, 'omitnan'), 'g', 'LineWidth', 1.5);
            end
            xlim(ax, [1 tcRange]);
            ylim(ax, range / 2);
            if subCol == 1
                % Show y-axis with 2 ticks (min and max of range/2)
                yLims = range / 2;
                set(ax, 'YTick', [yLims(1) 0 yLims(2)], 'YTickLabel', ...
                    {sprintf('%.2f', yLims(1)), '0', sprintf('%.2f', yLims(2))}, ...
                    'FontSize', 5, 'TickLength', [0.03 0.03], 'TickDir', 'out');
            else
                set(ax, 'YTick', []);
            end
        end
    end

    % =====================================================================
    % COL 3: GIF placeholder (top) + Retinotopy Summary OFF + ON (below)
    %
    % Each Retinotopy Summary is a 2x2 grid matching the sbxOctoNeural figure:
    %   top-left:  meanGreenImg          ("Mean Green Anatomy")
    %   top-right: topoOverlayImg{rep}   ("Retinotopy Overlay")
    %   bot-left:  xpolarImg{rep}        ("X (Azimuth) Map")
    %   bot-right: ypolarImg{rep}        ("Y (Elevation) Map")
    % rep=1 = OFF, rep=2 = ON  (matching sbxOctoNeural repLabels order)
    % =====================================================================
    hasRetino = isfield(D, 'xpolarImg')      && iscell(D.xpolarImg)      && length(D.xpolarImg)      >= 2 && ...
                isfield(D, 'ypolarImg')      && iscell(D.ypolarImg)      && length(D.ypolarImg)      >= 2 && ...
                isfield(D, 'topoOverlayImg') && iscell(D.topoOverlayImg) && length(D.topoOverlayImg) >= 2 && ...
                isfield(D, 'meanGreenImg')   && ~isempty(D.meanGreenImg);

    contentH  = top - bottom;
    gifH      = contentH * 0.18;   % GIF placeholder: 18% of column height
    retinoH   = contentH * 0.38;   % each Retinotopy Summary block: 38% (2x mY gaps fill remaining ~6%)
    retLabelH = 0.022;

    % GIF placeholder (top of col 3)
    gifTop = top;
    gifBot = gifTop - gifH;
    axGif = axes('Position', [col3_left, gifBot, colW, gifH], 'Parent', fig); %#ok<LAXES>
    showGifFrame(axGif, gifFile, aviFile);
    title(axGif, 'Activity (GIF)', 'FontSize', 8, 'Color', 'k', 'Interpreter', 'none');

    % Two Retinotopy Summary blocks: rep=1 (OFF) then rep=2 (ON)
    retinoLabels = {'Retinotopy Summary  -  OFF', 'Retinotopy Summary  -  ON'};
    retinoTops   = [gifBot - mY,  gifBot - mY - retinoH - mY];

    subTitles = {{'Mean Green Anatomy', 'Retinotopy Overlay'}, ...
                 {'X (Azimuth) Map',    'Y (Elevation) Map'}};

    for rep = 1:2
        blkTop = retinoTops(rep);
        blkBot = blkTop - retinoH;
        imgH   = retinoH - retLabelH - 0.004;
        imgW   = (colW - ret_hgap) / 2;   % left and right panels equal width

        annotation(fig, 'textbox', [col3_left, blkTop - retLabelH, colW, retLabelH], ...
                   'String', retinoLabels{rep}, 'FontSize', 8, 'FontWeight', 'bold', ...
                   'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
                   'Interpreter', 'none', 'VerticalAlignment', 'middle', 'Color', 'k');

        if hasRetino
            % 2x2 grid: top row (anatomy | overlay), bottom row (X map | Y map)
            rowH   = imgH / 2;
            panelImgs = {D.meanGreenImg,        D.topoOverlayImg{rep}; ...
                         D.xpolarImg{rep},       D.ypolarImg{rep}};
            panelTitles = {subTitles{1}{1}, subTitles{1}{2}; ...
                           subTitles{2}{1}, subTitles{2}{2}};
            for pr = 1:2
                for pc = 1:2
                    xPos = col3_left + (pc - 1) * (imgW + ret_hgap);
                    yPos = blkTop - retLabelH - pr * rowH;
                    ax = axes('Position', [xPos+0.001, yPos+0.001, imgW*0.98, rowH*0.96], ...
                              'Parent', fig); %#ok<LAXES>
                    showFrame(ax, panelImgs{pr, pc});
                    set(ax, 'XTick', [], 'YTick', []);
                    title(ax, panelTitles{pr, pc}, 'FontSize', 6, 'Color', 'k', ...
                          'Interpreter', 'none');
                end
            end
        else
            axPh = axes('Position', [col3_left, blkBot, colW, imgH], 'Parent', fig); %#ok<LAXES>
            placeholderAxes(axPh, sprintf('Retinotopy Summary %s not available', retinoLabels{rep}(end-2:end)));
        end
    end
end


%% =========================================================================
%% LOCAL HELPER: panelGratingsPage  (nstim == 17)
%%
%% Layout (top to bottom):
%%   Top row:    Polar map (cycPolarImg) | Mean pixel map with cluster overlay
%%   Middle row: Weighted pixel maps (8 cols x nRow grid)
%%   Bottom row: Weighted trial timecourses (same grid)
%%
%% Variables from sbxOctoNeural_DR_commented_v5.m:
%%   cycPolarImg  : HSV polar map image
%%   trialmean    : [nY x nX x nPresentations]
%%   weightTcourse: [tcRange x nPresentations]
%%   stimOrder    : [1 x nPresentations]
%%   stdImg       : for normgreen reconstruction
%%   xpts, ypts, c : for mean pixel map + cluster overlay
%% =========================================================================
function panelGratingsPage(analysisFile, fig, nstim, aviFile, gifFile)
    try
        D = load(analysisFile, 'cycPolarImg', 'trialmean', 'weightTcourse', ...
                 'stimOrder', 'stdImg', 'xpts', 'ypts', 'c', 'meanGreenImg');
    catch ME
        annotation(fig, 'textbox', [0.02 0.05 0.96 0.64], ...
                   'String', ['Could not load analysis data: ' ME.message], ...
                   'FontSize', 10, 'EdgeColor', 'r', 'Interpreter', 'none', 'Color', 'k');
        return;
    end

    % ---- Page margins ----
    mX     = 1 / (2.54 * 17);
    mY     = 1 / (2.54 * 11);
    titleH = 0.05;
    titleY = 1 - mY - titleH;
    left   = mX;
    right  = 1 - mX;
    top    = titleY - mY;
    bottom = mY;

    % ---- Reconstruct normgreen from stdImg ----
    if isfield(D, 'stdImg')
        ng = (D.stdImg - prctile(D.stdImg(:), 1)) / ...
             (prctile(D.stdImg(:), 99) * 1.5 - prctile(D.stdImg(:), 1));
        ng = ng * 2; ng(ng < 0) = 0; ng(ng > 1) = 1;
        normgreen    = repmat(ng, [1 1 3]);
        hasNormgreen = true;
    else
        hasNormgreen = false;
    end

    % ---- Three equal columns ----
    usableW   = right - left;
    gap       = mX / 2;
    colW      = (usableW - 2*gap) / 3;
    col1_left = left;
    col2_left = col1_left + colW + gap;
    col3_left = col2_left + colW + gap;

    labelH = 0.025;
    range  = [-0.05 0.20];

    nCond  = nstim - 1;   % exclude blank condition
    nCol   = 8;
    nRow   = ceil(nCond / nCol);

    % Panel size within col 2 (8-wide grid)
    panW   = colW / nCol;
    panH   = panW * (17 / 11);

    tcRange = size(D.weightTcourse, 1);
    t       = 1:tcRange;

    % =====================================================================
    % COL 1: Polar map (cycPolarImg / frame cycle + amplitude)
    % =====================================================================
    ax = axes('Position', [col1_left, top - (top - bottom), colW, top - bottom], ...
              'Parent', fig); %#ok<LAXES>
    if isfield(D, 'cycPolarImg') && ~isempty(D.cycPolarImg)
        showFrame(ax, D.cycPolarImg);
    else
        set(ax, 'Color', [0.85 0.85 0.85]);
    end
    axis(ax, 'off');
    title(ax, 'Polar Map (frame cycle + amp)', 'FontSize', 9, 'Color', 'k', 'Interpreter', 'none');

    % =====================================================================
    % COL 2: Weighted Pixel Maps (top) + Weighted Trial Timecourses (bottom)
    % Grid: nRow rows x 8 cols
    % =====================================================================
    yPixLabel = top - labelH;
    yPixGrid  = yPixLabel - nRow * panH;
    yTCLabel  = yPixGrid - labelH;
    yTCGrid   = yTCLabel - nRow * panH;

    annotation(fig, 'textbox', [col2_left, yPixLabel, colW, labelH], ...
               'String', 'Gratings: Weighted Pixel Map', 'FontSize', 8, ...
               'FontWeight', 'bold', 'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
               'Interpreter', 'none', 'VerticalAlignment', 'middle', 'Color', 'k');

    annotation(fig, 'textbox', [col2_left, yTCLabel, colW, labelH], ...
               'String', 'Gratings: Weighted Trial Timecourses', 'FontSize', 8, ...
               'FontWeight', 'bold', 'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
               'Interpreter', 'none', 'VerticalAlignment', 'middle', 'Color', 'k');

    for cond = 1:nCond
        col = mod(cond - 1, nCol) + 1;
        row = ceil(cond / nCol);
        xPos = col2_left + (col - 1) * panW;

        % Weighted pixel map
        yPosPix = yPixLabel - row * panH;
        ax = axes('Position', [xPos+0.0005 yPosPix+0.0005 panW*0.98 panH*0.97], ...
                  'Parent', fig); %#ok<LAXES>
        meanimg = median(D.trialmean(:,:, D.stimOrder == cond), 3, 'omitnan');
        if hasNormgreen && ~isempty(meanimg)
            scaled = (meanimg - range(1)) / (range(2) - range(1));
            scaled = max(0, min(1, scaled));
            jmap   = jet(256);
            idx    = round(scaled * 255) + 1;
            rgbImg = reshape(jmap(idx(:),:), [size(meanimg,1) size(meanimg,2) 3]);
            ngRes  = normgreen;
            if ~isequal(size(ngRes,1), size(rgbImg,1)) || ~isequal(size(ngRes,2), size(rgbImg,2))
                [xi,yi] = meshgrid(linspace(1,size(ngRes,2),size(rgbImg,2)), ...
                                   linspace(1,size(ngRes,1),size(rgbImg,1)));
                [xi0,yi0] = meshgrid(1:size(ngRes,2), 1:size(ngRes,1));
                ngRes = cat(3, interp2(xi0,yi0,ngRes(:,:,1),xi,yi,'linear',0), ...
                               interp2(xi0,yi0,ngRes(:,:,2),xi,yi,'linear',0), ...
                               interp2(xi0,yi0,ngRes(:,:,3),xi,yi,'linear',0));
            end
            image(ax, rgbImg .* ngRes);
        else
            imagesc(ax, meanimg, range);
            colormap(ax, 'jet');
        end
        axis(ax, 'off');

        % Weighted timecourse
        yPosTC = yTCLabel - row * panH;
        ax = axes('Position', [xPos+0.0005 yPosTC+0.0005 panW*0.98 panH*0.97], ...
                  'Parent', fig); %#ok<LAXES>
        set(ax, 'Color', 'w', 'Box', 'on', 'XTick', [], ...
            'XColor', 'k', 'YColor', 'k', 'LineWidth', 0.5);
        traceData = D.weightTcourse(:, D.stimOrder == cond);
        if ~isempty(traceData)
            nTr  = size(traceData, 2);
            cmap = jet(max(nTr, 1));
            hold(ax, 'on');
            for tr = 1:nTr
                plot(ax, t, traceData(:,tr), 'Color', cmap(tr,:), 'LineWidth', 0.5);
            end
            plot(ax, t, median(traceData, 2, 'omitnan'), 'g', 'LineWidth', 1.5);
        end
        xlim(ax, [1 tcRange]);
        ylim(ax, range / 2);
        if col == 1
            yLims = range / 2;
            set(ax, 'YTick', [yLims(1) 0 yLims(2)], ...
                'YTickLabel', {sprintf('%.2f',yLims(1)), '0', sprintf('%.2f',yLims(2))}, ...
                'FontSize', 5, 'TickLength', [0.03 0.03], 'TickDir', 'out');
        else
            set(ax, 'YTick', []);
        end
    end

    % =====================================================================
    % COL 3: GIF placeholder (full column height)
    % =====================================================================
    axGif = axes('Position', [col3_left, bottom, colW, top - bottom], 'Parent', fig); %#ok<LAXES>
    showGifFrame(axGif, gifFile, aviFile);
    title(axGif, 'Activity (GIF)', 'FontSize', 8, 'Color', 'k', 'Interpreter', 'none');
end


%% =========================================================================
%% LOCAL HELPER: panelSTAPage  (sparse noise / STA)
%%
%% Layout: 3 columns
%%   Col 1: Lag maps ON (top half) + Lag maps OFF (bottom half)
%%          Each half: 4-col x 2-row square grid of lag images at taus 3,5,...,17
%%   Col 2: RF Position Map on Anatomy (recreated from saved variables)
%%          2x2 grid: top=ON (X|Y), bot=OFF (X|Y); anatomy overlaid with RF-pos colour
%%   Col 3: GIF / AVI placeholder (full column height)
%%
%% Variables loaded from mat file (requires sbxOctoSTA_DR_v2.m):
%%   lagStas    : [nY x nX x 18 x 2]    -- per-lag STA (taus 1:18, rep1=ON, rep2=OFF)
%%   zscore     : [nCells x 2]           -- ON/OFF z-scores
%%   rfx, rfy   : [nCells x 2]           -- RF centre positions
%%   xpts, ypts : [nCells x 1]           -- cell anatomy positions
%%   meanGreenImg : [nY x nX x nCh]      -- anatomy image for RF overlay
%% =========================================================================
function panelSTAPage(analysisFile, fig, aviFile, gifFile)
%% panelSTAPage  (sparse noise / STA) -- 3-column layout
%%
%%   Col 1: Lag maps ON (top half) + Lag maps OFF (bottom half)
%%          Each half: 2-row x 4-col grid of lag images (4x4 square formation)
%%   Col 2: RF Position Map on Anatomy (recreated from saved variables)
%%          2x2 grid: X/Y x ON/OFF, anatomy image with cells coloured by RF pos
%%   Col 3: GIF placeholder (full column height)
    try
        D = load(analysisFile, 'lagStas', 'stas', 'zscore', ...
                 'rfx', 'rfy', 'xpts', 'ypts', 'meanGreenImg');
    catch ME
        annotation(fig, 'textbox', [0.02 0.05 0.96 0.90], ...
                   'String', ['Could not load STA data: ' ME.message], ...
                   'FontSize', 10, 'EdgeColor', 'r', 'Interpreter', 'none', 'Color', 'k');
        return;
    end

    % ---- Page margins ----
    mX     = 1 / (2.54 * 17);
    mY     = 1 / (2.54 * 11);
    titleH = 0.05;
    titleY = 1 - mY - titleH;
    left   = mX;
    right  = 1 - mX;
    top    = titleY - mY;
    bottom = mY;

    % ---- Three equal columns ----
    usableW   = right - left;
    gap       = mX / 2;
    colW      = (usableW - 2*gap) / 3;
    col1_left = left;
    col2_left = col1_left + colW + gap;
    col3_left = col2_left + colW + gap;

    contentH = top - bottom;
    labelH   = 0.022;

    taus_show  = 3:2:18;   % every other lag: 3,5,7,9,11,13,15,17
    nTaus      = length(taus_show);   % 8 lags

    % =====================================================================
    % COL 1: Lag maps ON (top half) + Lag maps OFF (bottom half)
    % Each block arranged in a 4-col x 2-row square formation.
    % lagStas: [nY x nX x 18 x 2], rep1=ON, rep2=OFF
    % =====================================================================
    hasLagStas = isfield(D, 'lagStas') && ~isempty(D.lagStas);

    % Divide col1 height into two equal halves (ON and OFF)
    lagH      = (contentH - mY - 2*labelH) / 2;   % image area per block
    lagOnTop  = top;
    lagOffTop = lagOnTop - lagH - labelH - mY/2;

    repLabels = {'ON', 'OFF'};
    yLagTop   = [lagOnTop, lagOffTop];

    nLagCols = 4;
    nLagRows = ceil(nTaus / nLagCols);

    for rep = 1:2
        rowTop = yLagTop(rep);
        annotation(fig, 'textbox', [col1_left, rowTop - labelH, colW, labelH], ...
                   'String', sprintf('STA Lag Maps  -  %s', repLabels{rep}), ...
                   'FontSize', 7, 'FontWeight', 'bold', 'EdgeColor', 'none', ...
                   'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
                   'Interpreter', 'none', 'Color', 'k');

        lagImgW = colW / nLagCols;
        lagImgH = lagH / nLagRows;

        for ti = 1:nTaus
            tau    = taus_show(ti);
            lagCol = mod(ti - 1, nLagCols) + 1;
            lagRow = ceil(ti / nLagCols);
            xPos   = col1_left + (lagCol - 1) * lagImgW;
            yPos   = rowTop - labelH - lagRow * lagImgH;

            ax = axes('Position', [xPos+0.001 yPos+0.001 lagImgW*0.97 lagImgH*0.96], ...
                      'Parent', fig); %#ok<LAXES>
            if hasLagStas && size(D.lagStas, 3) >= tau
                img = D.lagStas(:,:,tau,rep);
                cr  = max(abs(prctile(img(:), [2 98])));
                if cr == 0; cr = 0.01; end
                imagesc(ax, img', [-cr cr]);
                colormap(ax, 'jet');
            else
                set(ax, 'Color', [0.85 0.85 0.85]);
            end
            axis(ax, 'off');
            title(ax, sprintf('lag %d', tau), 'FontSize', 6, 'Color', 'k', ...
                  'Interpreter', 'none');
        end
    end

    % =====================================================================
    % COL 2: RF Position Map on Anatomy (Fig 43 equivalent)
    % 2x2 grid: top row = ON (X | Y), bottom row = OFF (X | Y)
    % Anatomy image with cells coloured by RF position using jet colormap.
    % Falls back to scatter plot if meanGreenImg is absent.
    % =====================================================================
    hasRF  = isfield(D,'rfx') && isfield(D,'rfy') && isfield(D,'zscore') && ...
              isfield(D,'xpts') && isfield(D,'ypts');
    hasGrn = isfield(D,'meanGreenImg') && ~isempty(D.meanGreenImg);

    annotation(fig, 'textbox', [col2_left, top - labelH, colW, labelH], ...
               'String', 'RF Position Map on Anatomy', 'FontSize', 8, 'FontWeight', 'bold', ...
               'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
               'Interpreter', 'none', 'VerticalAlignment', 'middle', 'Color', 'k');

    rfPanW = (colW - mX/4) / 2;
    rfPanH = (contentH - labelH - mY/2) / 2;

    % Grid order: [1=X ON, 2=Y ON, 3=X OFF, 4=Y OFF]
    rfTitles = {'X RF Map  (ON)', 'Y RF Map  (ON)', 'X RF Map  (OFF)', 'Y RF Map  (OFF)'};
    zthresh  = 5.5;

    useOn = []; useOff = []; x0 = 0; y0 = 0;
    if hasRF
        nRef    = size(D.zscore, 1);
        useOn   = find(D.zscore(1:nRef, 1) >  zthresh);
        useOff  = find(D.zscore(1:nRef, 2) < -zthresh);
        rfxs    = [D.rfx(useOn,1); D.rfx(useOff,2)];
        rfys    = [D.rfy(useOn,1); D.rfy(useOff,2)];
        x0 = median(rfxs, 'omitnan');
        y0 = median(rfys, 'omitnan');
    end

    for ri = 1:4
        rfCol = mod(ri - 1, 2) + 1;
        rfRow = ceil(ri / 2);
        xPos  = col2_left + (rfCol - 1) * (rfPanW + mX/4);
        yPos  = top - labelH - mY/4 - rfRow * rfPanH;

        ax = axes('Position', [xPos, yPos, rfPanW, rfPanH*0.93], 'Parent', fig); %#ok<LAXES>

        isX  = (ri == 1 || ri == 3);
        isOn = (ri <= 2);
        cells = useOn; if ~isOn; cells = useOff; end
        rep   = 1;     if ~isOn; rep   = 2;      end

        if hasRF && hasGrn
            gImg   = D.meanGreenImg(:,:,1);
            gRange = prctile(gImg(:), [1 99]);
            if gRange(2) <= gRange(1); gRange(2) = gRange(1) + 0.01; end
            imagesc(ax, gImg, gRange);
            colormap(ax, 'gray');
            hold(ax, 'on');
            if ~isempty(cells)
                if isX; rfVals = D.rfx(cells, rep) - x0;
                else;   rfVals = D.rfy(cells, rep) - y0; end
                cmap64 = jet(64);
                rfMin  = -25; rfMax = 25;
                for ci = 1:length(cells)
                    cv   = max(0, min(1, (rfVals(ci) - rfMin) / (rfMax - rfMin)));
                    cidx = max(1, min(64, round(cv * 63) + 1));
                    plot(ax, D.xpts(cells(ci)), D.ypts(cells(ci)), 'o', ...
                         'Color', cmap64(cidx,:), 'MarkerSize', 4, 'LineWidth', 0.5);
                end
            end
            axis(ax, 'equal'); axis(ax, 'off');
        elseif hasRF
            hold(ax, 'on');
            if ~isempty(cells)
                if isX; rfVals = D.rfx(cells, rep) - x0;
                else;   rfVals = D.rfy(cells, rep) - y0; end
                scatter(ax, D.xpts(cells), D.ypts(cells), 10, rfVals, 'filled');
                colormap(ax, 'jet'); caxis(ax, [-25 25]);
            end
            set(ax, 'YDir', 'reverse'); axis(ax, 'equal'); axis(ax, 'off');
        else
            placeholderAxes(ax, rfTitles{ri});
        end
        title(ax, rfTitles{ri}, 'FontSize', 7, 'Color', 'k', 'Interpreter', 'none');
    end

    % =====================================================================
    % COL 3: GIF placeholder (full column height)
    % =====================================================================
    axGif = axes('Position', [col3_left, bottom, colW, top - bottom], 'Parent', fig); %#ok<LAXES>
    showGifFrame(axGif, gifFile, aviFile);
    title(axGif, 'Activity (GIF)', 'FontSize', 8, 'Color', 'k', 'Interpreter', 'none');
end
