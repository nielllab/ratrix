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
%   Analysis .mat files produced by sbxOctoNeural_DR_commented_v5.m and/or
%   sbxOctoSTA_commented_v1.m (must contain nstim, StimulusStr, StimulusNum,
%   weightTcourse, trialmean, c, xpts, ypts, meanGreenImg, dFrepeats, stas,
%   tuning, rfx, rfy as applicable).

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
% Raw imaging      : *.sbx
% Sbx sidecars     : *_000_NNN.mat (same base name as .sbx, contain only 'info')
% Analysis outputs : any other .mat containing StimulusStr/stimOrder/nstim
% AVI movies       : same base name as .sbx

sbxFiles = dir(fullfile(exptDir, '*.sbx'));
if isempty(sbxFiles)
    error('No .sbx files found in: %s', exptDir);
end

% ---- Build sbxMap: acqNum -> sbx path ----
% SBX files named like: ExptName_000_NNN.sbx  (NNN = acq number, zero-padded)
% or: ExptName_acqN.sbx  (fallback pattern)
sbxNums = zeros(1, length(sbxFiles));
sbxMap  = containers.Map('KeyType','int32','ValueType','char');
for i = 1:length(sbxFiles)
    % Try _000_NNN or _NNN pattern (last underscore-separated number block)
    tok = regexp(sbxFiles(i).name, '_0*?(\d+)\.sbx$', 'tokens');
    if isempty(tok)
        tok = regexp(sbxFiles(i).name, 'acq(\d+)', 'tokens', 'ignorecase');
    end
    if ~isempty(tok)
        n = int32(str2double(tok{1}{1}));
        sbxNums(i) = n;
        sbxMap(n)  = fullfile(exptDir, sbxFiles(i).name);
    end
end

% ---- Build stimRecMap and analysisMap from all .mat files ----
% Three types of mat files in directory:
%   Stimulus records : ExptName_Acq{N}.mat  -- StimulusStr/StimulusNum, no nstim
%   Sbx sidecars    : ExptName_000_{NNN}.mat -- 'info' struct only, skip these
%   Analysis outputs : longer names with 'acq' -- nstim/stimOrder/weightTcourse etc.
allMats     = dir(fullfile(exptDir, '*.mat'));
stimRecMap  = containers.Map('KeyType','int32','ValueType','char');
analysisMap = containers.Map('KeyType','int32','ValueType','char');
stimMap     = stimRecMap;   % alias kept for any legacy references

for i = 1:length(allMats)
    fname = allMats(i).name;
    fpath = fullfile(exptDir, fname);

    % Skip sbx sidecar files: _000_NNN.mat pattern (two underscore-digit groups at end)
    if ~isempty(regexp(fname, '_\d+_\d+\.mat$', 'once'))
        continue;
    end

    % Stimulus record: ends exactly with Acq{N}.mat (case-insensitive)
    tok = regexp(fname, 'Acq(\d+)\.mat$', 'tokens', 'ignorecase');
    if ~isempty(tok)
        n = int32(str2double(tok{1}{1}));
        stimRecMap(n) = fpath;
        continue;
    end

    % Analysis output: new naming convention is *_acq{N}_*_analysis.mat
    % Also accept older files that contain 'acq{N}' and pass a StimulusStr check.
    isNewStyle = ~isempty(regexp(fname, '_acq\d+_.*_analysis\.mat$', 'once', 'ignorecase'));
    tok = regexp(fname, 'acq(\d+)', 'tokens', 'ignorecase');
    if isempty(tok)
        continue;
    end
    n = int32(str2double(tok{1}{1}));

    if ~isNewStyle
        % Old-style: confirm it's an analysis file by checking for StimulusStr.
        % Check last 2MB (HDF5 heap) and first 512KB.
        try
            fInfo  = dir(fpath);
            fsize  = fInfo.bytes;
            fid    = fopen(fpath, 'rb');
            probe  = fread(fid, 512*1024, '*uint8');
            hasStr = ~isempty(strfind(char(probe'), 'StimulusStr'));  %#ok<STREMP>
            if ~hasStr && fsize > 512*1024
                tailBytes = min(2*1024*1024, fsize - 512*1024);
                fseek(fid, -tailBytes, 'eof');
                tail   = fread(fid, tailBytes, '*uint8');
                hasStr = ~isempty(strfind(char(tail'), 'StimulusStr'));  %#ok<STREMP>
            end
            fclose(fid);
            if ~hasStr; continue; end
        catch
            continue;
        end
    end

    if ~isKey(analysisMap, n) || allMats(i).datenum > dir(analysisMap(n)).datenum
        analysisMap(n) = fpath;
    end
end

if analysisMap.Count > 0
    analysisKeys = double(cell2mat(analysisMap.keys));
else
    analysisKeys = [];
end
if stimRecMap.Count > 0
    stimRecKeys = double(cell2mat(stimRecMap.keys));
else
    stimRecKeys = [];
end
allNums = unique([double(sbxNums(sbxNums > 0)) analysisKeys stimRecKeys]);

% Build a map: acqNum -> AVI file (searches directory independently of .sbx names)
aviFiles = dir(fullfile(exptDir, '*.avi'));
aviMap   = containers.Map('KeyType','int32','ValueType','char');
for i = 1:length(aviFiles)
    % Prefer acq{N} pattern; fall back to last number before extension
    tok = regexp(aviFiles(i).name, 'acq(\d+)', 'tokens', 'ignorecase');
    if isempty(tok)
        tok = regexp(aviFiles(i).name, '(\d+)\.avi$', 'tokens');
    end
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

    % Load StimulusStr/StimulusNum from stimulus record (ground truth).
    % Load nstim/stimOrder from analysis file.
    % Both may be absent if acquisition was spontaneous or not yet analysed.
    acqs(idx).stimFile     = '';
    acqs(idx).analysisFile = '';
    acqs(idx).StimulusStr  = 'spontaneous';
    acqs(idx).StimulusNum  = 0;
    acqs(idx).nstim        = NaN;

    % Stimulus record -> StimulusStr, StimulusNum
    if isKey(stimRecMap, n)
        acqs(idx).stimFile = stimRecMap(n);
        try
            tmp = load(stimRecMap(n), 'StimulusStr', 'StimulusNum');
            if isfield(tmp, 'StimulusStr')
                ss = tmp.StimulusStr;
                if iscell(ss); ss = ss{1}; end
                acqs(idx).StimulusStr = char(ss);
            end
            if isfield(tmp, 'StimulusNum')
                acqs(idx).StimulusNum = double(tmp.StimulusNum);
            end
        catch; end
    end

    % Analysis file -> nstim (and StimulusStr fallback if no stimulus record)
    if isKey(analysisMap, n)
        acqs(idx).analysisFile = analysisMap(n);
        warnTmp = warning('off', 'MATLAB:load:variableNotFound');
        try
            tmp = load(analysisMap(n), 'StimulusStr', 'StimulusNum', 'nstim', 'stimOrder');
            % Only use StimulusStr from analysis file if stimulus record absent
            if ~isKey(stimRecMap, n) && isfield(tmp, 'StimulusStr')
                ss = tmp.StimulusStr;
                if iscell(ss); ss = ss{1}; end
                acqs(idx).StimulusStr = char(ss);
            end
            if ~isKey(stimRecMap, n) && isfield(tmp, 'StimulusNum')
                acqs(idx).StimulusNum = double(tmp.StimulusNum);
            end
            if isfield(tmp, 'nstim')
                acqs(idx).nstim = double(tmp.nstim);
            elseif isfield(tmp, 'stimOrder') && ~isempty(tmp.stimOrder)
                acqs(idx).nstim = double(max(tmp.stimOrder(:)));
            end
        catch; end
        warning(warnTmp);
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

    % Detect sparse noise (STA script output) by file content.
    % STA outputs contain 'lagStas' and 'rfx'; the neural script never saves these.
    % whos('-file') silently returns empty for v7.3 HDF5 files, so we use a raw
    % byte search instead -- fast and reliable regardless of mat format version.
    % Detect sparse noise.
    % New-style files: *_sparsenoise_analysis.mat -- unambiguous from filename alone.
    % Old-style files: byte-search for 'lagStas', or keyword match on filename/StimulusStr.
    [~, afName] = fileparts(acq.analysisFile);
    isNewStyleSparse = ~isempty(regexp(afName, '_sparsenoise_analysis$', 'once', 'ignorecase'));
    isSparseNoise = isNewStyleSparse;
    if ~isSparseNoise && ~isempty(acq.analysisFile) && exist(acq.analysisFile, 'file')
        try
            fid = fopen(acq.analysisFile, 'rb');
            rawBytes = fread(fid, 2*1024*1024, '*uint8');
            fclose(fid);
            isSparseNoise = ~isempty(strfind(char(rawBytes'), 'lagStas'));  %#ok<STREMP>
        catch
        end
    end
    if ~isSparseNoise
        isSparseNoise = contains(stimStr,  'sparse', 'IgnoreCase', true) || ...
                        contains(stimStr,  'noise',  'IgnoreCase', true) || ...
                        contains(afName,   'sparse', 'IgnoreCase', true) || ...
                        contains(afName,   'noise',  'IgnoreCase', true);
    end

    % New-style filenames make type detection unambiguous even if nstim load failed
    isNewStyle6x4  = ~isempty(regexp(afName, '_6x4_analysis$',  'once', 'ignorecase'));
    isNewStyle8way = ~isempty(regexp(afName, '_8way_analysis$', 'once', 'ignorecase'));
    is6x4  = ~isempty(acq.analysisFile) && ~isSparseNoise && ...
              (isNewStyle6x4  || ismember(acq.nstim, [48 50]));
    is8way = ~isempty(acq.analysisFile) && ~isSparseNoise && ...
              (isNewStyle8way || acq.nstim == 17);
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

    % ---- Derive GIF path from AVI; auto-generate if needed ----
    aviFile = acq.aviFile;
    if ~isempty(aviFile) && exist(aviFile, 'file')
        [aviDir, aviBase] = fileparts(aviFile);
        gifFile = fullfile(aviDir, [aviBase '.gif']);
        if ~exist(gifFile, 'file')
            try
                generateGif(aviFile, gifFile);
            catch
                gifFile = '';
            end
        end
    else
        gifFile = '';
    end

    % ---- Create figure (landscape, A3-ish for density) ----
    fig = figure('Units', 'inches', 'Position', [0 0 17 11], ...
                 'Color', 'w', 'PaperOrientation', 'landscape', ...
                 'PaperUnits', 'inches', 'PaperSize', [17 11], ...
                 'PaperPosition', [0 0 17 11]);

    % Page margin constants (1 cm, normalized)
    mX = 1 / (2.54 * 17);   % 0.02315  horizontal
    mY = 1 / (2.54 * 11);   % 0.03584  vertical

    % Title bar: compact strip at top of page
    titleH = 0.032;
    titleY = 1 - mY - titleH;
    annotation(fig, 'textbox', [mX, titleY, 1 - 2*mX, titleH], ...
               'String', sprintf('Acq %d  -  %s  |  %s', acq.acqNum, stimTypeLabel, exptName), ...
               'FontSize', 11, 'FontWeight', 'bold', ...
               'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
               'Interpreter', 'none', 'VerticalAlignment', 'middle', ...
               'Color', 'k');

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
        panelSpotsPage(acq.analysisFile, fig, acq.nstim, gifFile, aviFile);

    elseif is8way
        panelGratingsPage(acq.analysisFile, fig, acq.nstim, gifFile, aviFile);

    elseif isSparseNoise
        panelSTAPage(acq.analysisFile, fig, gifFile, aviFile);

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
%%   Col 3 (x=0.676-0.990): Retinotopy 2x2 subpanel grid
%%                              top-left:  Retino X OFF  | top-right:  Retino Y OFF
%%                              bot-left:  Retino X ON   | bot-right:  Retino Y ON
%%
%% Within each data column (bottom to top):
%%   TC grid   : 4 rows x panH_tc each
%%   TC label  : labelH strip
%%   Pix grid  : 4 rows x panH_pix each
%%   Pix label : labelH strip at top
%%
%% Key variable shapes (from sbxOctoNeural_DR_commented_v5.m):
%%   trialmean    : [nY x nX x nPresentations]   -  smoothed pixel response per trial
%%   stimOrder    : [1 x nPresentations]          -  condition index (1:nstim) per trial
%%   weightTcourse: [tcRange x nPresentations]    -  anatomy-weighted timecourse per trial
%%   xpolarImg    : cell{1=OFF, 2=ON}             -  HSV azimuth retinotopy map
%%   ypolarImg    : cell{1=OFF, 2=ON}             -  HSV elevation retinotopy map
%%
%% loc maps condition index (1:nHalf) to 4x6 subplot position to preserve
%% the spatial arrangement of the spot grid on screen (matches pixPlot_DR /
%% pixPlotWeight_DR used in the full analysis PDF).
%% =========================================================================
function panelSpotsPage(analysisFile, fig, nstim, gifFile, aviFile)
    try
        D = load(analysisFile, 'weightTcourse', 'trialmean', 'stdImg', ...
                 'stimOrder', 'xpolarImg', 'ypolarImg', ...
                 'topoOverlayImg', 'meanGreenImg');
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
    titleH  = 0.032;
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
                    ngRes = imresize(ngRes, [size(rgbImg,1) size(rgbImg,2)]);
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
    % COL 3: GIF (top 20%) + Retinotopy Summary OFF (middle) + ON (bottom)
    % Each retino panel is a 2x2 grid matching the neural script figures:
    %   {meanGreenImg, topoOverlayImg, xpolarImg, ypolarImg}
    % Sub-image labels: 'Mean Green', 'Retino Overlay', 'X Map', 'Y Map'
    % =====================================================================
    hasRetino = isfield(D, 'topoOverlayImg') && iscell(D.topoOverlayImg) && ...
                isfield(D, 'xpolarImg')      && iscell(D.xpolarImg) && ...
                isfield(D, 'ypolarImg')      && iscell(D.ypolarImg) && ...
                isfield(D, 'meanGreenImg')   && ...
                length(D.topoOverlayImg) >= 2;

    % Total col3 height from top of content to bottom margin
    col3_h    = yPixLabel - bottom;

    % GIF panel: top 20% of col3 height
    gifFrac   = 0.20;
    gifH      = col3_h * gifFrac;
    gifY      = yPixLabel - gifH;        % bottom of GIF axes

    annotation(fig, 'textbox', [col3_left yPixLabel colW labelH], ...
               'String', 'Activity', 'FontSize', 8, 'FontWeight', 'bold', ...
               'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
               'Interpreter', 'none', 'VerticalAlignment', 'middle', 'Color', 'k');
    axGif = axes('Position', [col3_left gifY colW gifH], 'Parent', fig); %#ok<LAXES>
    showGifFrame(axGif, gifFile, aviFile);

    % Remaining height split equally between OFF and ON summary panels
    remainH    = gifY - bottom;          % height available below GIF
    panelGap   = labelH;                 % gap between OFF and ON blocks
    blockH     = (remainH - panelGap) / 2;  % height per retino block (label + 2x2 grid)
    ret_hgap   = mX / 4;                % horizontal gap between the two sub-images
    subLblH    = labelH * 0.75;         % label strip above each sub-image
    imgRowGap  = 0.004;                 % vertical gap between the two image rows
    gridH      = blockH - labelH - subLblH - imgRowGap;  % total height for 2 image rows
    imgH       = gridH / 2;             % height per image row
    imgW       = (colW - ret_hgap) / 2; % width per image

    % Block y positions (OFF on top, ON below)
    offBlockTop = gifY - labelH;         % bottom of OFF header label
    onBlockTop  = offBlockTop - blockH - panelGap;  % bottom of ON header label

    retinoSubLabels = {'Mean Green', 'Retino Overlay', 'X Map', 'Y Map'};
    repLabels       = {'OFF', 'ON'};
    blockTops       = [offBlockTop, onBlockTop];

    if hasRetino
        retinoSets = { ...
            {D.meanGreenImg, D.topoOverlayImg{1}, D.xpolarImg{1}, D.ypolarImg{1}}, ...
            {D.meanGreenImg, D.topoOverlayImg{2}, D.xpolarImg{2}, D.ypolarImg{2}} };
    end

    for rr = 1:2
        blkTop = blockTops(rr);  % bottom of this block's header label

        % Block header
        annotation(fig, 'textbox', [col3_left blkTop colW labelH], ...
                   'String', sprintf('Retinotopy Summary  %s', repLabels{rr}), ...
                   'FontSize', 8, 'FontWeight', 'bold', 'EdgeColor', 'none', ...
                   'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
                   'Interpreter', 'none', 'Color', 'k');

        if ~hasRetino
            annotation(fig, 'textbox', [col3_left blkTop-blockH colW blockH], ...
                       'String', 'Retinotopy data not available', ...
                       'FontSize', 8, 'HorizontalAlignment', 'center', ...
                       'VerticalAlignment', 'middle', ...
                       'EdgeColor', [0.75 0.75 0.75], 'BackgroundColor', [0.96 0.96 0.96], ...
                       'Interpreter', 'none', 'Color', 'k');
            continue;
        end

        imgs = retinoSets{rr};
        % Row 1: sub-images 1 and 2; Row 2: sub-images 3 and 4
        % Layout top-to-bottom within the block:
        %   subLblH  (row1 label)
        %   imgH     (row1 images)
        %   imgRowGap
        %   subLblH  (row2 label)
        %   imgH     (row2 images)
        row1LblBot = blkTop - subLblH;
        row1ImgBot = row1LblBot - imgH;
        row2LblBot = row1ImgBot - imgRowGap - subLblH;
        row2ImgBot = row2LblBot - imgH;

        rowBots = [row1ImgBot, row2ImgBot];
        lblBots = [row1LblBot, row2LblBot];
        xLefts  = [col3_left, col3_left + imgW + ret_hgap];

        for si = 1:4
            row = ceil(si / 2);  col = mod(si-1, 2) + 1;
            ax = axes('Position', [xLefts(col) rowBots(row) imgW imgH], ...
                      'Parent', fig); %#ok<LAXES>
            showFrame(ax, imgs{si});
            set(ax, 'XTick', [], 'YTick', [], 'XColor', 'k', 'YColor', 'k');
            annotation(fig, 'textbox', [xLefts(col) lblBots(row) imgW subLblH], ...
                       'String', retinoSubLabels{si}, 'FontSize', 6, ...
                       'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
                       'VerticalAlignment', 'bottom', 'Interpreter', 'none', 'Color', 'k');
        end
    end
end



%% =========================================================================
%% LOCAL HELPER: panelGratingsPage  (nstim == 17)
%%
%% Layout -- 3 columns, col2 ~25% wider (ratio 2:5:2):
%%   Col 1: Polar map (cycPolarImg), full column height
%%   Col 2: Weighted pixel maps (8-col x 2-row, top) +
%%          Weighted trial timecourses (8-col x 2-row, bottom)
%%          Identical panel style to panelSpotsPage (panH = panW*(17/11))
%%   Col 3: GIF/AVI activity frame
%%
%% Variables from sbxOctoNeural_DR_commented_v6.m:
%%   cycPolarImg  : HSV polar map image
%%   trialmean    : [nY x nX x nPresentations]
%%   weightTcourse: [tcRange x nPresentations]
%%   stimOrder    : [1 x nPresentations]
%%   stdImg       : for normgreen reconstruction
%% =========================================================================
function panelGratingsPage(analysisFile, fig, nstim, gifFile, aviFile)
    try
        D = load(analysisFile, 'cycPolarImg', 'trialmean', 'weightTcourse', ...
                 'stimOrder', 'stdImg');
    catch ME
        annotation(fig, 'textbox', [0.02 0.05 0.96 0.64], ...
                   'String', ['Could not load analysis data: ' ME.message], ...
                   'FontSize', 10, 'EdgeColor', 'r', 'Interpreter', 'none', 'Color', 'k');
        return;
    end

    % ---- Page margins ----
    mX     = 1 / (2.54 * 17);
    mY     = 1 / (2.54 * 11);  %#ok<NASGU>
    titleH = 0.032;
    titleY = 1 - mY - titleH;
    bottom = mY;
    top    = titleY - mY;
    colH   = top - bottom;

    % ---- 3-column layout: col2 25% wider, ratio 2:5:2 ----
    gap      = mX / 2;
    fullW    = 1 - 2*mX;
    unit     = (fullW - 2*gap) / 9;   % 9 units total (2+5+2)
    col1W    = 2 * unit;
    col2W    = 5 * unit;
    col3W    = 2 * unit;
    col1_left = mX;
    col2_left = col1_left + col1W + gap;
    col3_left = col2_left + col2W + gap;

    % =====================================================================
    % COL 1: Polar map -- full column height
    % =====================================================================
    ax = axes('Position', [col1_left bottom col1W colH], 'Parent', fig); %#ok<LAXES>
    if isfield(D, 'cycPolarImg') && ~isempty(D.cycPolarImg)
        showFrame(ax, D.cycPolarImg);
    else
        placeholderAxes(ax, 'Polar Map');
    end
    axis(ax, 'image'); axis(ax, 'off');
    title(ax, 'Polar Map (frame cycle)', 'FontSize', 9, 'Color', 'k', 'Interpreter', 'none');

    % =====================================================================
    % COL 2: Weighted pixel maps (top) + timecourse panels (bottom)
    % 16 conditions in 8-col x 2-row, same style as panelSpotsPage.
    % =====================================================================

    % Reconstruct normgreen from stdImg
    if isfield(D, 'stdImg')
        ng = (D.stdImg - prctile(D.stdImg(:), 1)) / ...
             (prctile(D.stdImg(:), 99) * 1.5 - prctile(D.stdImg(:), 1));
        ng = ng * 2; ng(ng < 0) = 0; ng(ng > 1) = 1;
        normgreen    = repmat(ng, [1 1 3]);
        hasNormgreen = true;
    else
        hasNormgreen = false;
    end

    nCond   = nstim - 1;   % 16 conditions (exclude blank)
    nCol    = 8;
    nRow    = ceil(nCond / nCol);   % 2 rows
    panW    = col2W / nCol;
    panH    = panW * (17 / 11);    % square pixels on 17x11 paper

    labelH  = 0.030;
    dRange  = [-0.05 0.20];
    tcRange = size(D.weightTcourse, 1);
    t       = 1:tcRange;

    yPixLabel = top - labelH;
    yTCLabel  = yPixLabel - nRow * panH - labelH;

    annotation(fig, 'textbox', [col2_left yPixLabel col2W labelH], ...
               'String', 'Weighted Pixel Maps (8-way gratings)', 'FontSize', 8, ...
               'FontWeight', 'bold', 'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
               'Interpreter', 'none', 'VerticalAlignment', 'middle', 'Color', 'k');

    annotation(fig, 'textbox', [col2_left yTCLabel col2W labelH], ...
               'String', 'Weighted Trial Timecourses (8-way gratings)', 'FontSize', 8, ...
               'FontWeight', 'bold', 'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
               'Interpreter', 'none', 'VerticalAlignment', 'middle', 'Color', 'k');

    for cond = 1:nCond
        subCol = mod(cond - 1, nCol) + 1;
        subRow = ceil(cond / nCol);
        xPos   = col2_left + (subCol - 1) * panW;

        % ---- Weighted pixel map ----
        yPosPix = yPixLabel - subRow * panH;
        ax = axes('Position', [xPos+0.0005 yPosPix+0.0005 panW*0.98 panH*0.97], ...
                  'Parent', fig); %#ok<LAXES>
        meanimg = median(D.trialmean(:,:, D.stimOrder == cond), 3, 'omitnan');
        if hasNormgreen && ~isempty(meanimg)
            scaled = (meanimg - dRange(1)) / (dRange(2) - dRange(1));
            scaled = max(0, min(1, scaled));
            jmap   = jet(256);
            cidx   = round(scaled * 255) + 1;
            rgbImg = reshape(jmap(cidx(:),:), [size(meanimg,1) size(meanimg,2) 3]);
            ngRes  = normgreen;
            if ~isequal(size(ngRes,1), size(rgbImg,1)) || ~isequal(size(ngRes,2), size(rgbImg,2))
                ngRes = imresize(ngRes, [size(rgbImg,1) size(rgbImg,2)]);
            end
            image(ax, rgbImg .* ngRes);
        else
            imagesc(ax, meanimg, dRange);
            colormap(ax, 'jet');
        end
        axis(ax, 'image'); axis(ax, 'off');

        % ---- Timecourse panel -- axes matching analysis output ----
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
                plot(ax, t, traceData(:,tr), 'Color', cmap(tr,:), 'LineWidth', 0.5);
            end
            plot(ax, t, median(traceData, 2, 'omitnan'), 'g', 'LineWidth', 1.5);
        end
        xlim(ax, [1 tcRange]);
        ylim(ax, dRange / 2);
        if subCol == 1
            yLims = dRange / 2;
            set(ax, 'YTick', [yLims(1) 0 yLims(2)], ...
                'YTickLabel', {sprintf('%.2f',yLims(1)), '0', sprintf('%.2f',yLims(2))}, ...
                'FontSize', 5, 'TickLength', [0.03 0.03], 'TickDir', 'out');
        else
            set(ax, 'YTick', []);
        end
    end

    % =====================================================================
    % COL 3: GIF/AVI activity frame -- full column height
    % =====================================================================
    annotation(fig, 'textbox', [col3_left top col3W titleH*0.6], ...
               'String', 'Activity', 'FontSize', 8, 'FontWeight', 'bold', ...
               'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
               'Interpreter', 'none', 'VerticalAlignment', 'middle', 'Color', 'k');
    axGif = axes('Position', [col3_left bottom col3W colH], 'Parent', fig); %#ok<LAXES>
    showGifFrame(axGif, gifFile, aviFile);
end


%% =========================================================================
%% LOCAL HELPER: panelSTAPage  (sparse noise / STA)
%%
%% Layout (top to bottom):
%%   Row 1: Lag maps ON  -- taus 3,5,7,9,11,13,15,17 (8 maps, every other lag)
%%   Row 2: Lag maps OFF -- same taus
%%   Row 3: Block STA ON | Block STA OFF | RF scatter (ON=red, OFF=blue)
%%   Row 4: X topo ON/OFF | Y topo ON/OFF
%%
%% Variables loaded from mat file (requires sbxOctoSTA_commented_v1.m v2+):
%%   lagStas  : [nY x nX x 18 x 2]          -- per-lag STA (taus 3:18, rep1=ON, rep2=OFF)
%%   staAll   : [nY x nX x nXblk x nYblk x 2] -- block STA maps at peak lag
%%   stas     : [nY x nX x nCells x 2]      -- cell-level STA (fallback for mean map)
%%   zscore   : [nCells x 2]                -- ON/OFF z-scores
%%   rfx, rfy : [nCells x 2]                -- RF centre positions
%%   xpts, ypts : [nCells x 1]              -- cell anatomy positions
%% =========================================================================
function panelSTAPage(analysisFile, fig, gifFile, aviFile)
    % Suppress "Variable not found" warnings for older mat files lacking lagStas/staAll.
    % whos('-file') cannot enumerate v7.3 variables, so we suppress instead.
    % Load small variables first, then attempt the large lagStas separately.
    % Splitting prevents a single bad variable from blocking everything else.
    warnState = warning('off', 'MATLAB:load:variableNotFound');
    try
        D = load(analysisFile, 'stas', 'zscore', 'rfx', 'rfy', 'xpts', 'ypts', 'meanGreenImg');
    catch ME
        warning(warnState);
        annotation(fig, 'textbox', [0.05 0.40 0.90 0.18], ...
                   'String', ['Could not load STA data: ' ME.message], ...
                   'FontSize', 10, 'EdgeColor', 'r', 'BackgroundColor', [1 0.9 0.9], ...
                   'Interpreter', 'none', 'Color', 'k', ...
                   'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        display(['panelSTAPage load error: ' ME.message]);
        return;
    end
    % Load lagStas separately -- it is large and may fail independently
    try
        tmp = load(analysisFile, 'lagStas');
        if isfield(tmp, 'lagStas')
            D.lagStas = tmp.lagStas;
        end
    catch ME2
        display(['panelSTAPage: lagStas load failed: ' ME2.message]);
        % D.lagStas simply won't be set; hasLagStas will be false
    end
    warning(warnState);

    % ---- Page margins ----
    mX     = 1 / (2.54 * 17);
    mY     = 1 / (2.54 * 11);
    titleH = 0.032;
    titleY = 1 - mY - titleH;
    bottom = mY;
    top    = titleY - mY;

    % ---- Equal 3-column layout ----
    gap       = mX / 2;
    fullW     = 1 - 2*mX;
    colW      = (fullW - 2*gap) / 3;
    col1_left = mX;
    col2_left = col1_left + colW + gap;
    col3_left = col2_left + colW + gap;
    colH      = top - bottom;

    % =====================================================================
    % COL 1: ON lag block (top half) + OFF lag block (bottom half)
    % Each block: label strip + 8 near-square images across colW
    % lagStas: [nY x nX x 18 x 2], taus 3:2:18 (indices 3,5,7,9,11,13,15,17)
    % =====================================================================
    % Extract lagStas to a plain double array; isnumeric guards against the
    % rare case where a MATLAB version returns it as a non-numeric type.
    hasLagStas  = false;
    lagStasData = [];
    if isfield(D, 'lagStas') && isnumeric(D.lagStas) && ~isempty(D.lagStas)
        lagStasData = double(D.lagStas);
        hasLagStas  = size(lagStasData, 3) >= 17;
    end

    taus_show  = 3:2:18;    % 8 lags: 3,5,7,9,11,13,15,17
    nTaus      = length(taus_show);   % 8
    nGridCols  = 4;                   % 2x4 square grid per polarity
    nGridRows  = 2;
    lagW       = colW / nGridCols;
    % Near-square: height = width * page_aspect so image pixels are square on 17x11 paper
    lagImgH    = lagW * (17 / 11);
    labelH     = 0.022;
    innerGap   = mY / 4;              % vertical gap between the 2 tile rows within a block
    blockH     = labelH + nGridRows * lagImgH + (nGridRows - 1) * innerGap;  %#ok<NASGU>
    blockGap   = mY / 2;             % gap between ON block and OFF block

    % Shared color range: match the analysis script's fixed crange behaviour.
    % The analysis script uses crange = [-0.05 0.05] (movie 2) or [-0.1 0.1]
    % (movie 1) -- a fixed wide range where most of the image sits near zero,
    % giving the characteristic light-blue background with a single hotspot.
    % We approximate this by taking the 99.9th percentile of |lagStas| across
    % ALL lags (3:18) and both reps, then applying a minimum floor of 0.05 so
    % the scale is never tighter than the analysis script's narrower crange.
    % This reproduces the "mostly blue, one red hotspot" appearance.
    lagCR = 0.05;   % minimum floor matching analysis script narrow crange
    if hasLagStas
        allPix = lagStasData(:, :, 3:min(18, size(lagStasData,3)), :);
        lagCR  = max(lagCR, max(abs(prctile(allPix(:), 99.9))));
    end

    % Pack two blocks from the top of the column
    onLabelBot   = top - labelH;
    onBlockBot   = onLabelBot - nGridRows * lagImgH - (nGridRows - 1) * innerGap;
    offLabelBot  = onBlockBot - blockGap - labelH;
    offBlockBot  = offLabelBot - nGridRows * lagImgH - (nGridRows - 1) * innerGap;

    repLabels  = {'ON', 'OFF'};
    labelBots  = [onLabelBot,  offLabelBot];
    blockBots  = [onBlockBot,  offBlockBot];

    for rep = 1:2
        annotation(fig, 'textbox', [col1_left labelBots(rep) colW labelH], ...
                   'String', sprintf('STA Lag Maps  -  %s', repLabels{rep}), ...
                   'FontSize', 7, 'FontWeight', 'bold', 'EdgeColor', 'none', ...
                   'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
                   'Interpreter', 'none', 'Color', 'k');

        for ti = 1:nTaus
            tau     = taus_show(ti);
            gridCol = mod(ti - 1, nGridCols);          % 0-based column index (0..3)
            gridRow = floor((ti - 1) / nGridCols);     % 0-based row index (0..1), row 0 = top
            xPos    = col1_left + gridCol * lagW;
            % Row 0 sits at the top of the block; row 1 sits one step below
            yPos    = blockBots(rep) + (nGridRows - 1 - gridRow) * (lagImgH + innerGap);
            ax      = axes('Position', [xPos+0.001 yPos+0.001 lagW*0.98 lagImgH*0.97], ...
                           'Parent', fig); %#ok<LAXES>
            if hasLagStas && size(lagStasData, 3) >= tau
                img = lagStasData(:,:,tau,rep);
                imagesc(ax, img', [-lagCR lagCR]);
                colormap(ax, 'jet');
                axis(ax, 'image');
                axis(ax, 'off');
            else
                placeholderAxes(ax, sprintf('lag %d', tau));
            end
            title(ax, sprintf('lag %d', tau), 'FontSize', 6, 'Color', 'k', ...
                  'Interpreter', 'none');
        end
    end

    % =====================================================================
    % COL 2: RF Position Map on Anatomy -- 2x2 grid
    %   (1,1) X RF Map  ON  | (1,2) Y RF Map  ON
    %   (2,1) X RF Map  OFF | (2,2) Y RF Map  OFF
    % Anatomy (meanGreenImg) as grayscale background; cells coloured by RF
    % position using a jet colourmap scaled to [-25 25] pixels.
    % =====================================================================
    hasRFmap = isfield(D, 'rfx') && isfield(D, 'rfy') && ...
               isfield(D, 'zscore') && isfield(D, 'xpts') && isfield(D, 'ypts') && ...
               isfield(D, 'meanGreenImg');

    rfmapH    = colH;               % full column height
    rfmapGap  = mX / 4;            % gap between the 2 sub-columns
    rfmapImgW = (colW - rfmapGap) / 2;
    rfmapRowGap = mY / 4;
    rfmapImgH = (rfmapH - rfmapRowGap) / 2;

    axTitles = {'X RF Map  ON', 'Y RF Map  ON'; ...
                'X RF Map  OFF', 'Y RF Map  OFF'};
    % row 1 = ON (top), row 2 = OFF (bottom)
    rowBots = [bottom + rfmapImgH + rfmapRowGap, bottom];
    colLefts = [col2_left, col2_left + rfmapImgW + rfmapGap];

    zthresh = 5.5;
    if hasRFmap
        useOn  = find(D.zscore(:,1) >  zthresh);
        useOff = find(D.zscore(:,2) < -zthresh);
        rfxs   = [D.rfx(useOn,1); D.rfx(useOff,2)];
        rfys   = [D.rfy(useOn,1); D.rfy(useOff,2)];
        x0     = median(rfxs, 'omitnan');
        y0     = median(rfys, 'omitnan');
        rfRange = 25;   % colour axis half-range in pixels
        cmap64  = jet(64);
        useIdx  = {useOn, useOff};
        rfCol   = [1, 2];   % rfx/rfy column index (ON=1, OFF=2)
    end

    for row = 1:2   % row 1 = ON, row 2 = OFF
        for col = 1:2   % col 1 = X, col 2 = Y
            ax = axes('Position', [colLefts(col) rowBots(row) rfmapImgW rfmapImgH], ...
                      'Parent', fig); %#ok<LAXES>
            if hasRFmap
                % Anatomy background: green channel of meanGreenImg
                anatImg = D.meanGreenImg(:,:,1);
                imagesc(ax, anatImg);
                colormap(ax, gray(256));
                hold(ax, 'on');
                % Overlay cells coloured by RF position
                cellIdx = useIdx{row};
                for ci = 1:length(cellIdx)
                    n = cellIdx(ci);
                    if col == 1
                        val = D.rfx(n, rfCol(row)) - x0;
                    else
                        val = D.rfy(n, rfCol(row)) - y0;
                    end
                    % Map val in [-rfRange rfRange] to colourmap index 1:64
                    cmapIdx = round((val + rfRange) / (2*rfRange) * 63) + 1;
                    cmapIdx = max(1, min(64, cmapIdx));
                    plot(ax, D.xpts(n), D.ypts(n), 'o', ...
                         'Color', cmap64(cmapIdx,:), 'MarkerSize', 3, ...
                         'MarkerFaceColor', cmap64(cmapIdx,:));
                end
                axis(ax, 'image'); axis(ax, 'off');
            else
                placeholderAxes(ax, axTitles{row, col});
            end
            title(ax, axTitles{row, col}, 'FontSize', 7, 'Color', 'k', ...
                  'Interpreter', 'none');
        end
    end

    % =====================================================================
    % COL 3: GIF/AVI frame (top 20%), remainder blank
    % =====================================================================
    gifH  = colH * 0.20;
    gifY  = top - gifH;

    annotation(fig, 'textbox', [col3_left top colW labelH], ...
               'String', 'Activity', 'FontSize', 8, 'FontWeight', 'bold', ...
               'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
               'Interpreter', 'none', 'VerticalAlignment', 'middle', 'Color', 'k');
    axGif = axes('Position', [col3_left gifY colW gifH], 'Parent', fig); %#ok<LAXES>
    showGifFrame(axGif, gifFile, aviFile);
end
