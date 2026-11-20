function compileAcqSummaries(pdfFolder, outFile)
%% compileAcqSummaries
% Goes through every summary PDF in a folder (the PDFs written by
% sutterOctoNeural), pulls selected pages out of each one, and compiles them
% into ONE landscape page per acquisition in a single output PDF.
%
% Each output page has
%     - a header: acquisition number (from "Acq<number>" in the file name)
%       and the stimulus type
%     - the PDF file name in small print
%     - the contents of info.usernotes from the matching .mat file
%       (*_000_NNN.mat in the same folder, e.g. _000_004.mat for Acq4)
%     - a top row of images
%     - a bottom row of images (optionally split into labeled quadrants)
%
% The stimulus type (used only for the header text) is found from a phrase in
% the PDF file name. See "stimConfig" below.
%
% Which PDF pages are pulled is NOT hard-coded. The summary PDFs have a
% different number of pages for every acquisition (extra pages per cluster,
% one page per cell image, ...), so fixed page numbers only worked for some
% files. Instead every page's text is read and the pages are found by what
% they contain:
%     top row    : first page ("baseline (median) img"), the page titled
%                  "mean trace for each repeat", and the page titled
%                  "selected traces based on dF"
%     bottom row : after the "correlation across cells after clustering"
%                  page, each page of small trace plots ("10 20 30" x-axis)
%                  together with the page of image tiles directly before it
%                  (image tiles, traces, image tiles, traces)
%
% 6x4 normal: the bottom row is split into two labeled quadrants. The first
% four (image tiles, traces) pairs found after the correlation page are used:
% the first two pairs go in the left quadrant (OFF), the next two in the right
% quadrant (ON), each pair stacked with the image tiles above the traces.
%
% Exception: a stimulus type can be given fixed page numbers in stimConfig
% (fixedTop / fixedBottom). "8waygratings" does this: top row = pages 1, 15, 19
% and bottom row = pages 40-43. Fixed pages are not used for PDFs with
% "sidebandsub" in the name (their pages are shifted), which keep using the
% content-based search above.
%
% Usage:
%     compileAcqSummaries                      % asks for the folder
%     compileAcqSummaries('D:\pdfs')           % output = D:\pdfs\CompiledSummaries.pdf
%     compileAcqSummaries('D:\pdfs','D:\out\all.pdf')
%
% Pages are ordered by acquisition number.
% Requires Ghostscript (you already use it for ps2pdf). Each page is printed
% with print -dpdf onto a landscape letter page and the pages are merged with
% Ghostscript.

%% ---------------- settings ----------------
dpi     = 200;    % resolution used to rasterize the PDF pages
cropPad = 6;      % pixels of white margin kept around each cropped image
maxNoteChars = 700;   % usernotes longer than this are cut off with "..."

% Text that identifies the pages to pull (compared after collapsing white space)
topMarkers = {'baseline (median) img', ...          % top row, left
              'mean trace for each repeat', ...     % top row, middle
              'selected traces based on dF'};       % top row, right
anchorMarker = 'correlation across cells after clustering';  % bottom row starts after this page
traceMarker  = '10 20 30';    % x-axis labels of the small trace-plot pages
nBottomPairs = 2;             % how many (image tiles + traces) pairs to pull

% Each stimulus type lists the phrases that identify it in the PDF file name
% (only used for the page header). Types are checked in order, and the first
% one with a matching phrase wins.
% Optional fixedTop / fixedBottom = PDF page numbers to use instead of the
% content-based search (leave empty to search by content).
% Optional quadrants = labels for a bottom row split into labeled quadrants,
% left to right; each quadrant takes two (image tiles + traces) pairs, stacked.
stimConfig = struct('patterns', {}, 'label', {}, 'fixedTop', {}, 'fixedBottom', {}, 'quadrants', {});

stimConfig(1).patterns = {'6x4darkmode'};
stimConfig(1).label    = '6x4 dark mode';

% "6x4normal", or just "6x4" followed by an underscore ("6x4_")
stimConfig(2).patterns = {'6x4normal', '6x4_'};
stimConfig(2).label    = '6x4 normal';
% left quadrant = OFF, right quadrant = ON (the order the figures are
% generated in sutterOctoNeural: OFF spots first, then ON spots).
% Swap the labels here if that ever changes.
stimConfig(2).quadrants = {'OFF', 'ON'};

stimConfig(3).patterns    = {'8waygratings'};
stimConfig(3).label       = '8 way gratings';
stimConfig(3).fixedTop    = [1 15 19];        % top row, left to right
stimConfig(3).fixedBottom = [40 41 42 43];    % bottom row, left to right
%% -----------------------------------------

if nargin < 1 || isempty(pdfFolder)
    pdfFolder = uigetdir(pwd, 'Folder containing the summary PDFs');
    if isequal(pdfFolder, 0), return; end
end
if nargin < 2 || isempty(outFile)
    outFile = fullfile(pdfFolder, 'CompiledSummaries.pdf');
end

gs = findGhostscript();
if isempty(gs)
    error('Could not find Ghostscript (gswin64c / gswin32c / gs). Install it or add it to the PATH.');
end

files = dir(fullfile(pdfFolder, '*.pdf'));
[~, outName, outExt] = fileparts(outFile);
files = files(~strcmpi({files.name}, [outName outExt]));   % don't read our own output
if isempty(files)
    error('No PDF files found in %s', pdfFolder);
end

% order by acquisition number (ties keep alphabetical order)
acqNums = inf(1, numel(files));
for f = 1:numel(files)
    tok = regexp(files(f).name, 'Acq(\d+)', 'tokens', 'once');
    if ~isempty(tok), acqNums(f) = str2double(tok{1}); end
end
[~, order] = sort(acqNums);
files = files(order);  acqNums = acqNums(order);

if exist(outFile, 'file') == 2, delete(outFile); end
tmpDir = tempname; mkdir(tmpDir);
cleanupObj = onCleanup(@() rmdir(tmpDir, 's')); %#ok<NASGU>
accFile = fullfile(tmpDir, 'compiled_tmp.pdf');   % pages are merged into this file

figW = 1100; figH = 850;       % 11 x 8.5 landscape aspect (small enough to fit any screen)
nDone = 0;
for f = 1:numel(files)
    name = files(f).name;
    pdfFile = fullfile(pdfFolder, name);

    % ---- which layout for this stimulus type? ----
    row = 0;
    for k = 1:numel(stimConfig)
        if any(contains(lower(name), lower(stimConfig(k).patterns)))
            row = k; break;
        end
    end
    if row == 0
        fprintf('SKIPPED (no stimulus type in stimConfig matches): %s\n', name);
        continue
    end
    cfg = stimConfig(row);
    if isinf(acqNums(f)), acqStr = '?'; else, acqStr = sprintf('%d', acqNums(f)); end

    fprintf('Processing %s  (Acq %s, %s)\n', name, acqStr, cfg.label);
    fig = [];
    try
        % ---- user notes from the matching .mat file ----
        [noteLines, noteFound] = getUserNotes(pdfFolder, acqNums(f), maxNoteChars);

        % ---- find the pages to use from their content ----
        pageTexts = getPageTexts(gs, pdfFile, tmpDir);
        isSideband = contains(lower(name), 'sidebandsub');
        useFixed = ~isempty(cfg.fixedTop) && ~isempty(cfg.fixedBottom) && ~isSideband;
        if useFixed
            topPages    = cfg.fixedTop;
            bottomPages = cfg.fixedBottom;
            checkFixedPages(pageTexts, topPages, topMarkers);
            how = 'fixed pages';
        else
            nPairs = nBottomPairs;
            if ~isempty(cfg.quadrants), nPairs = 2 * numel(cfg.quadrants); end
            [topPages, bottomPages] = resolvePages(pageTexts, topMarkers, ...
                anchorMarker, traceMarker, nPairs);
            how = 'found by content';
        end
        fprintf('  top pages: %s | bottom pages: %s  (%s)\n', ...
            mat2str(topPages), mat2str(bottomPages), how);
        cfg.top = struct('label', '', 'cols', {num2cell(topPages)});
        if ~isempty(cfg.quadrants) && ~useFixed
            cfg.bottom = buildQuadrants(bottomPages, cfg.quadrants);
        else
            cfg.bottom = struct('label', '', 'cols', {num2cell(bottomPages)});
        end

        % ---- rasterize every page this layout needs ----
        imgs = containers.Map('KeyType', 'double', 'ValueType', 'any');
        imgs(0) = [];                                   % 0 = page not found
        allPages = unique([layoutPages(cfg.top), layoutPages(cfg.bottom)]);
        allPages = allPages(allPages > 0);
        for p = allPages
            imgs(p) = getPageImage(gs, pdfFile, p, dpi, cropPad, tmpDir);
        end

        % ---- build the landscape page ----
        fig = figure('Visible', 'off', 'Units', 'pixels', ...
            'Position', [30 30 figW figH], 'Color', 'w');
        % Use the figure's real size for the layout (Matlab shrinks figures
        % that are bigger than the screen, which can clip the export).
        pos = get(fig, 'Position');  curW = pos(3);  curH = pos(4);
        if abs(curW - figW) > 2 || abs(curH - figH) > 2
            fprintf('  NOTE: Matlab resized the figure to %dx%d px (asked for %dx%d).\n', ...
                round(curW), round(curH), figW, figH);
        end

        addText(fig, [0 0.950 1 0.045], sprintf('Acq %s  |  %s', acqStr, cfg.label), ...
            15, 'bold', [0 0 0], 'middle');
        addText(fig, [0 0.930 1 0.022], name, 7, 'normal', [0.4 0.4 0.4], 'middle');
        if noteFound
            addText(fig, [0.03 0.876 0.94 0.052], noteLines, 9.5, 'normal', [0 0 0], 'top');
        else
            addText(fig, [0.03 0.876 0.94 0.052], noteLines, 9, 'normal', [0.5 0.5 0.5], 'top');
        end

        % Top row: a little smaller, tucked up under the notes.
        placeBand(fig, cfg.top, imgs, [0.02 0.57 0.96 0.30], curW, curH);
        % Bottom row: a single row of panels needs little height, so it sits
        % right under the top row; stacked panels (6x4 normal) get more room.
        if stackDepth(cfg.bottom) > 1
            bottomBand = [0.02 0.05 0.96 0.49];
        else
            bottomBand = [0.02 0.26 0.96 0.30];
        end
        placeBand(fig, cfg.bottom, imgs, bottomBand, curW, curH);

        % print the whole figure onto one landscape letter page, then merge
        set(fig, 'PaperUnits', 'inches', 'PaperType', 'usletter', ...
            'PaperOrientation', 'landscape', 'PaperPositionMode', 'manual', ...
            'PaperPosition', [0 0 11 8.5]);
        pagePdf = fullfile(tmpDir, sprintf('page_%04d.pdf', nDone + 1));
        print(fig, pagePdf, '-dpdf', '-r200');
        close(fig);
        appendPdf(gs, accFile, pagePdf);
        delete(pagePdf);
        nDone = nDone + 1;
    catch ME
        if ~isempty(fig) && isgraphics(fig), close(fig); end
        fprintf('  FAILED on %s: %s\n', name, ME.message);
    end
end

if nDone > 0
    copyfile(accFile, outFile, 'f');
end
fprintf('Done. %d acquisition page(s) written to %s\n', nDone, outFile);
end


%% ===================== helper functions =====================

function addText(fig, pos, str, fontSize, weight, color, vAlign)
% Centered text box that stays exactly where it is placed.
annotation(fig, 'textbox', pos, 'String', str, 'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', vAlign, ...
    'Interpreter', 'none', 'FontSize', fontSize, 'FontWeight', weight, ...
    'Color', color, 'FitBoxToText', 'off');
end


function [lines, found] = getUserNotes(folder, acqNum, maxChars)
% Read info.usernotes from the *_000_NNN.mat file for this acquisition.
% Returns a cell array of text lines (or a gray placeholder message).
found = false;
if isinf(acqNum)
    lines = {'(no acquisition number in file name, so no usernotes)'};
    return
end
matFiles = dir(fullfile(folder, sprintf('*_000_%03d.mat', acqNum)));
if isempty(matFiles)
    lines = {sprintf('(no *_000_%03d.mat file found for usernotes)', acqNum)};
    fprintf('  WARNING: %s\n', lines{1});
    return
end
if numel(matFiles) > 1
    fprintf('  NOTE: %d files match *_000_%03d.mat; using %s\n', ...
        numel(matFiles), acqNum, matFiles(1).name);
end
matPath = fullfile(folder, matFiles(1).name);
try
    S = load(matPath, 'info');
    v = S.info.usernotes;
    lines = notesToLines(v);
    if isempty(lines)
        lines = {'(usernotes empty)'};
        return
    end
    % cut off very long notes
    joined = strjoin(lines, ' / ');
    if numel(joined) > maxChars
        joined = [joined(1:maxChars) '...'];
        lines = {joined};
    end
    found = true;
catch ME
    lines = {sprintf('(could not read info.usernotes from %s)', matFiles(1).name)};
    fprintf('  WARNING: %s (%s)\n', lines{1}, ME.message);
end
end


function lines = notesToLines(v)
% Turn whatever is stored in usernotes (char, char matrix, string, cell,
% number) into a cell array of non-empty text lines.
if isstring(v)
    v = cellstr(v(:));
elseif ischar(v)
    v = cellstr(v);                       % one entry per row of a char matrix
elseif iscell(v)
    v = cellfun(@(x) char(string(x)), v(:), 'UniformOutput', false);
elseif isnumeric(v) || islogical(v)
    v = {num2str(v)};
else
    v = {'(usernotes in an unrecognized format)'};
end
lines = {};
for i = 1:numel(v)
    s = strrep(v{i}, char(13), '');
    parts = strsplit(s, char(10));        % split embedded line breaks
    for j = 1:numel(parts)
        t = strtrim(strrep(parts{j}, char(9), ' '));
        if ~isempty(t), lines{end+1} = t; end %#ok<AGROW>
    end
end
end


function texts = getPageTexts(gs, pdfFile, tmpDir)
% Text of every page of pdfFile (cell array, one entry per page, white space
% collapsed) using Ghostscript's txtwrite device.
txtDir = fullfile(tmpDir, 'txt');
if exist(txtDir, 'dir') == 7, rmdir(txtDir, 's'); end
mkdir(txtDir);
cmd = sprintf(['%s -dNOPAUSE -dBATCH -dQUIET -sDEVICE=txtwrite ' ...
    '-sOutputFile="%s" "%s"'], gs, fullfile(txtDir, 'pg_%05d.txt'), pdfFile);
[~, ~] = system(cmd);
d = dir(fullfile(txtDir, 'pg_*.txt'));
[~, o] = sort({d.name});  d = d(o);
texts = cell(1, numel(d));
for k = 1:numel(d)
    fid = fopen(fullfile(txtDir, d(k).name), 'r');
    t = fread(fid, '*char')';
    fclose(fid);
    texts{k} = strtrim(regexprep(t, '\s+', ' '));
end
rmdir(txtDir, 's');
end


function checkFixedPages(texts, topPages, topMarkers)
% Warn (but still go ahead) if the fixed top-row pages do not contain the
% titles they should, e.g. because this PDF has a different page order.
nPg = numel(texts);
for i = 1:numel(topPages)
    p = topPages(i);
    if p > nPg
        fprintf('  WARNING: fixed page %d is past the end of this PDF (%d pages)\n', p, nPg);
    elseif ~contains(texts{p}, topMarkers{i})
        fprintf('  WARNING: fixed page %d does not contain "%s"; this PDF may have a different page order\n', ...
            p, topMarkers{i});
    end
end
end


function groups = buildQuadrants(bottomPages, labels)
% Split bottomPages (image tiles, traces, image tiles, traces, ...) into one
% labeled group per label: 4 pages each, as two columns of (tiles over traces).
groups = struct('label', {}, 'cols', {});
for q = 1:numel(labels)
    b = bottomPages(4*(q-1) + (1:4));
    groups(q).label = labels{q};
    groups(q).cols  = {b(1:2), b(3:4)};
end
end


function [topPages, bottomPages] = resolvePages(texts, topMarkers, anchorMarker, traceMarker, nPairs)
% Work out which PDF pages to use from what is printed on them.
% 0 in the result means "not found".
nPg = numel(texts);

% ---- top row: first page containing each marker ----
topPages = zeros(1, numel(topMarkers));
for i = 1:numel(topMarkers)
    k = find(contains(texts, topMarkers{i}), 1, 'first');
    if ~isempty(k), topPages(i) = k; end
end
if topPages(1) == 0 && nPg >= 1, topPages(1) = 1; end   % baseline image is always page 1

% ---- bottom row: (image tiles, traces) pairs after the correlation page ----
anchor = find(contains(texts, anchorMarker), 1, 'first');
if isempty(anchor), anchor = 0; end
isTrace = contains(texts, traceMarker) & (1:nPg) > anchor;
tracePages = find(isTrace, nPairs, 'first');
bottomPages = zeros(1, 2*nPairs);
for j = 1:numel(tracePages)
    bottomPages(2*j-1) = tracePages(j) - 1;   % image tiles are the page right before
    bottomPages(2*j)   = tracePages(j);
end
if numel(tracePages) < nPairs
    fprintf('  WARNING: found only %d of %d trace page(s) after "%s"\n', ...
        numel(tracePages), nPairs, anchorMarker);
end
end


function n = stackDepth(groups)
% largest number of pages stacked in any one column of a list of groups
n = 1;
for g = 1:numel(groups)
    for c = 1:numel(groups(g).cols)
        n = max(n, numel(groups(g).cols{c}));
    end
end
end


function appendPdf(gs, accFile, newPdf)
% Add the one-page newPdf to the end of accFile (created if missing) using
% Ghostscript, without downsampling or re-compressing the images lossily.
if exist(accFile, 'file') ~= 2
    copyfile(newPdf, accFile, 'f');
    return
end
merged = [accFile '.new.pdf'];
cmd = sprintf(['%s -dBATCH -dNOPAUSE -dQUIET -sDEVICE=pdfwrite ' ...
    '-dAutoRotatePages=/None -dPDFSETTINGS=/prepress ' ...
    '-dDownsampleColorImages=false -dDownsampleGrayImages=false ' ...
    '-dAutoFilterColorImages=false -dColorImageFilter=/FlateEncode ' ...
    '-sOutputFile="%s" "%s" "%s"'], gs, merged, accFile, newPdf);
[st, msg] = system(cmd);
if st ~= 0 || exist(merged, 'file') ~= 2
    error('Ghostscript could not merge the pages: %s', msg);
end
movefile(merged, accFile, 'f');
end


function pages = layoutPages(groups)
% all PDF page numbers used by a list of groups
pages = [];
for g = 1:numel(groups)
    for c = 1:numel(groups(g).cols)
        pages = [pages, groups(g).cols{c}(:)']; %#ok<AGROW>
    end
end
end


function placeBand(fig, groups, imgs, band, figW, figH)
% Lay out one band (a row of groups) inside band = [x y w h] (normalized).
% Columns share the width equally across all groups; pages within a column
% are stacked top to bottom. A labeled group gets a caption and a thin box.
nCols = 0;
for g = 1:numel(groups), nCols = nCols + numel(groups(g).cols); end
colW = band(3) / nCols;
labelH = 0.035;
gapX = 0.008; gapY = 0.008;

x = band(1);
for g = 1:numel(groups)
    G = groups(g);
    groupW = numel(G.cols) * colW;
    innerH = band(4);
    if ~isempty(G.label)
        innerH = band(4) - labelH;
        addText(fig, [x, band(2) + innerH, groupW, labelH], G.label, ...
            13, 'bold', [0 0 0], 'middle');
        annotation(fig, 'rectangle', [x + 0.003, band(2), groupW - 0.006, band(4)], ...
            'Color', [0.75 0.75 0.75]);
    end
    for c = 1:numel(G.cols)
        pgs = G.cols{c};
        np = numel(pgs);
        cellH = innerH / np;
        xc = x + (c-1) * colW;
        for k = 1:np
            cellBox = [xc + gapX/2, band(2) + innerH - k*cellH + gapY/2, ...
                       colW - gapX, cellH - gapY];
            placeImage(fig, imgs(pgs(k)), pgs(k), cellBox, figW, figH);
        end
    end
    x = x + groupW;
end
end


function placeImage(fig, img, pageNum, cellBox, figW, figH)
% Put img inside cellBox (normalized), scaled to fit without distortion.
if isempty(img)
    if pageNum == 0, msg = 'page not found'; else, msg = sprintf('page %d not found', pageNum); end
    addText(fig, cellBox, msg, 9, 'normal', [0 0 0], 'middle');
    return
end
imgAR  = size(img, 2) / size(img, 1);                    % width / height
cellAR = (cellBox(3)*figW) / (cellBox(4)*figH);
if imgAR > cellAR           % limited by width
    w = cellBox(3);  h = (w*figW/imgAR) / figH;
else                        % limited by height
    h = cellBox(4);  w = (h*figH*imgAR) / figW;
end
x = cellBox(1) + (cellBox(3)-w)/2;
y = cellBox(2) + (cellBox(4)-h)/2;
ax = axes('Parent', fig, 'Units', 'normalized', 'Position', [x y w h]);
image(ax, img);
axis(ax, 'image'); axis(ax, 'off');
end


function img = getPageImage(gs, pdfFile, pageNum, dpi, pad, tmpDir)
% Rasterize one page with Ghostscript and crop away the white border.
% Returns [] if the page does not exist.
outPng = fullfile(tmpDir, sprintf('page_%d.png', pageNum));
if exist(outPng, 'file') == 2, delete(outPng); end
cmd = sprintf(['%s -dNOPAUSE -dBATCH -dQUIET -sDEVICE=png16m -r%d ' ...
    '-dTextAlphaBits=4 -dGraphicsAlphaBits=4 -dFirstPage=%d -dLastPage=%d ' ...
    '-sOutputFile="%s" "%s"'], gs, dpi, pageNum, pageNum, outPng, pdfFile);
[~, ~] = system(cmd);
if exist(outPng, 'file') ~= 2
    img = [];
    fprintf('  WARNING: could not render page %d of %s\n', pageNum, pdfFile);
    return
end
img = imread(outPng);
delete(outPng);

mask = any(img < 245, 3);               % anything that is not (near) white
r = find(any(mask, 2));  c = find(any(mask, 1));
if isempty(r) || isempty(c), return; end  % blank page: leave as is
r1 = max(r(1)-pad, 1);   r2 = min(r(end)+pad, size(img,1));
c1 = max(c(1)-pad, 1);   c2 = min(c(end)+pad, size(img,2));
img = img(r1:r2, c1:c2, :);
end


function gs = findGhostscript()
% Find a Ghostscript command: on the PATH first, then the usual Windows install folders.
cands = {'gswin64c', 'gswin32c', 'gs'};
gs = '';
for i = 1:numel(cands)
    [st, ~] = system([cands{i} ' -v']);
    if st == 0, gs = cands{i}; return; end
end
roots = {'C:\Program Files\gs', 'C:\Program Files (x86)\gs'};
for i = 1:numel(roots)
    d = dir(fullfile(roots{i}, 'gs*', 'bin', 'gswin64c.exe'));
    if isempty(d), d = dir(fullfile(roots{i}, 'gs*', 'bin', 'gswin32c.exe')); end
    if ~isempty(d)
        d = d(end);                       % newest version
        gs = ['"' fullfile(d.folder, d.name) '"'];
        return
    end
end
end