function export_mat_notes(folder, includeRawNote)
% EXPORT_MAT_NOTES  Pull the user notes out of every Scanbox .mat file in a
% folder and save them to MatFileInfoNotes_<session>.pdf and
% MatFileInfoNotes_<session>.xlsx (same name, one PDF and one Excel file per session).
%
% Usage:
%   export_mat_notes                       % folder picker, then asks if you want a 2nd folder
%   export_mat_notes('D:\data\111326')     % use one specific folder
%   export_mat_notes({'D:\a', 'D:\b'})     % use two folders (files from both are combined)
%   export_mat_notes(folder, true)         % also print the raw note under each entry
%
% With two folders, the .mat files from both are read together, so a session
% whose files are split between them (e.g. the main folder and its zstacks
% folder) still gets one PDF and one Excel file. The outputs are saved in the
% FIRST folder. The matching .sbx file for the Acq date is looked for in the
% .mat file's own folder first, then in the other folder. If the same acq
% appears in both folders, the copy from the first folder is used.
%
% File names must look like  [date_]session_000_NNN.mat, for example
%   111326_ASW172E3_000_028.mat   ->  session ASW172E3, acq 028
% The session name in the PDF name is taken from the file names, so it always
% matches the files. Files with no "info" variable (e.g. stimulus files such as
% acq2.mat) are skipped and listed in the command window.
%
% Each acquisition is written as:
%   acq NNN
%   * [any comment that came before the coordinates]
%   * x y z coordinates
%   * laser L gpmt G rpmt R
%   * everything else in the note, one idea per bullet
%   * wavelength (always last, if the note has one)
%
% The Excel sheet has one row per acquisition with the columns
%   Acq # | Notes | Test | Stimulus | Location number | Location coordinates |
%   Response | Laser % | Green pmt | Red pmt | Temp | Type | Acq date |
%   Raw note
% Location number and Response are left blank for you to fill in by hand.
% Temp is filled in when the note mentions one. Acq date comes from the date
% modified of the matching .sbx file (blank if none).
% Wavelength has no column of its own; it stays in the Raw note.
% The Stimulus column (one option) is filled from keywords in the note, and that
% stimulus wording is then left out of the Notes column (it stays in the Raw
% note). Test
% follows the Stimulus (Visual stimuli, Spontaneous activity, preKCL zstack,
% postKCl zstack, Zstack), and Type follows the Test (Structural for the
% z-stack tests, Functional for the rest).
% Every cell has text wrapping turned on (needs Windows + Excel; otherwise a
% warning is shown and the sheet is saved unwrapped).
% Acq numbers missing between the first and last file get their own row with
% the note 'no .mat file found in folder' and everything else blank.
%
% Requires MATLAB R2020a or newer (exportgraphics, writecell). No toolboxes needed.
% Typos in the notes are NOT corrected; set includeRawNote = true to compare.

if nargin < 1 || isempty(folder)
    folder = {uigetdir(pwd, 'Select the folder containing the .mat files')};
    if isequal(folder{1}, 0), return; end
    choice = questdlg('Add a second folder?', 'export_mat_notes', 'Yes', 'No', 'No');
    if strcmp(choice, 'Yes')
        f2 = uigetdir(folder{1}, 'Select the second folder');
        if ~isequal(f2, 0), folder{end+1} = f2; end
    end
end
folders = cellstr(folder);
if nargin < 2, includeRawNote = false; end
outFolder = folders{1};                 % PDF and Excel files are saved here

% [date_]session_scan_acq.mat
pat = '^(?:\d{6,7}_)?(.+?)_(\d{3})_(\d{3})\.mat$';

rows = struct('prefix', {}, 'base', {}, 'folder', {}, 'session', {}, ...
              'acqStr', {}, 'acqNum', {}, 'scanNum', {}, 'note', {});
skipped = {};
nFiles = 0;

for fi = 1:numel(folders)
    files = dir(fullfile(folders{fi}, '*.mat'));
    nFiles = nFiles + numel(files);
    for k = 1:numel(files)
        fn    = files(k).name;
        label = fn;
        if numel(folders) > 1, label = fullfile(folders{fi}, fn); end
        tok = regexp(fn, pat, 'tokens', 'once');
        if isempty(tok)
            skipped{end+1} = sprintf('%s (name is not session_000_NNN.mat)', label); %#ok<AGROW>
            continue
        end
        full = fullfile(folders{fi}, fn);
        w = whos('-file', full);
        if ~any(strcmp({w.name}, 'info'))
            skipped{end+1} = sprintf('%s (no "info" variable)', label); %#ok<AGROW>
            continue
        end
        S = load(full, 'info');
        if ~isstruct(S.info) || ~isfield(S.info, 'usernotes')
            skipped{end+1} = sprintf('%s (no usernotes field)', label); %#ok<AGROW>
            continue
        end
        r = struct('prefix',  regexprep(fn, '_\d{3}_\d{3}\.mat$', ''), ...
                   'base',    regexprep(fn, '\.mat$', ''), ...
                   'folder',  folders{fi}, ...
                   'session', tok{1}, ...
                   'acqStr',  tok{3}, ...
                   'acqNum',  str2double(tok{3}), ...
                   'scanNum', str2double(tok{2}), ...
                   'note',    noteToString(S.info.usernotes));
        rows(end+1) = r; %#ok<AGROW>
    end
end

if nFiles == 0
    error('No .mat files found in %s', strjoin(folders, ' or '));
end
if isempty(rows)
    error('No files with user notes were found in %s', strjoin(folders, ' or '));
end

% the same acq in both folders: keep the first copy
keys = arrayfun(@(q) sprintf('%s|%d|%d', q.prefix, q.scanNum, q.acqNum), ...
                rows, 'UniformOutput', false);
[~, keepIdx] = unique(keys, 'stable');
if numel(keepIdx) < numel(rows)
    warning('export_mat_notes:duplicates', ...
            '%d duplicate acq file(s) found in both folders; using the first copy.', ...
            numel(rows) - numel(keepIdx));
    rows = rows(keepIdx);
end

% one PDF and one Excel file per session
prefixes = unique({rows.prefix}, 'stable');
sess = cellfun(@(p) rows(find(strcmp({rows.prefix}, p), 1)).session, ...
               prefixes, 'UniformOutput', false);
useFull = numel(unique(sess)) < numel(sess);   % same session name on two dates

for g = 1:numel(prefixes)
    sel = rows(strcmp({rows.prefix}, prefixes{g}));
    [~, order] = sortrows([[sel.scanNum]' [sel.acqNum]']);
    sel = sel(order);

    name = sess{g};
    if useFull, name = prefixes{g}; end
    name = regexprep(name, '[^\w\-]', '_');
    pdfFile  = fullfile(outFolder, ['MatFileInfoNotes_' name '.pdf']);
    xlsxFile = fullfile(outFolder, ['MatFileInfoNotes_' name '.xlsx']);

    writeNotesPdf(pdfFile, sess{g}, strjoin(folders, '; '), sel, includeRawNote);
    writeNotesXlsx(xlsxFile, sel, folders);
    fprintf('Wrote %d acquisitions to %s and %s\n', numel(sel), pdfFile, xlsxFile);
end

if ~isempty(skipped)
    fprintf('\nSkipped %d file(s):\n', numel(skipped));
    fprintf('  %s\n', skipped{:});
end
end


%% ------------------------------------------------------------------------
function s = noteToString(u)
% Turn usernotes (char, char matrix, or cell array) into one clean line.
if isempty(u), s = ''; return; end
if iscell(u)
    u = cellfun(@(c) char(c), u(:)', 'UniformOutput', false);
    u = strjoin(u, ' ');
elseif ischar(u) && size(u, 1) > 1
    u = strjoin(cellstr(u)', ' ');
end
s = strtrim(regexprep(char(u), '\s+', ' '));
end


%% ------------------------------------------------------------------------
function p = parseNote(note)
% Break a note into its parts. Fields: pre (comment before the coordinates),
% coords, laser, g (gpmt), r (rpmt), post (everything else), wl (wavelength).
p = struct('pre', {{}}, 'coords', '', 'laser', '', 'g', '', 'r', '', ...
           'post', {{}}, 'wl', '');
if isempty(note), return; end
rest = note;

% 1) wavelength -> goes last
wlExpr = '(?:laser\s+)?wavelength\s*(?:laser\s+)?\d+';
wl = regexp(rest, wlExpr, 'match', 'once', 'ignorecase');
rest = regexprep(rest, wlExpr, ' ', 'once', 'ignorecase');
wl = strtrim(regexprep(wl, '\s+', ' '));

% 2) laser power
laser = '';
t = regexp(rest, 'laser\s*(\d+)', 'tokens', 'once', 'ignorecase');
if ~isempty(t)
    laser = t{1};
    rest = regexprep(rest, 'laser\s*\d+', ' ', 'once', 'ignorecase');
end

% 3) PMT gains
g = ''; r = '';
t = regexp(rest, 'gpmt\s+and\s+rpmt\s+(?:now\s+)?(\d+)', 'tokens', 'once', 'ignorecase');
if ~isempty(t)
    g = t{1}; r = t{1};
    rest = regexprep(rest, 'gpmt\s+and\s+rpmt\s+(?:now\s+)?\d+', ' ', 'once', 'ignorecase');
else
    t = regexp(rest, 'gpmt\s+only\s*(\d+)', 'tokens', 'once', 'ignorecase');
    if ~isempty(t)
        g = t{1};
        rest = regexprep(rest, 'gpmt\s+only\s*\d+', ' ', 'once', 'ignorecase');
    else
        t = regexp(rest, 'gpmt\s*(\d+)', 'tokens', 'once', 'ignorecase');
        if ~isempty(t)
            g = t{1};
            rest = regexprep(rest, 'gpmt\s*\d+', ' ', 'once', 'ignorecase');
        end
        t = regexp(rest, 'r[pm]{1,2}t\s*(\d+)', 'tokens', 'once', 'ignorecase');
        if ~isempty(t)
            r = t{1};
            rest = regexprep(rest, 'r[pm]{1,2}t\s*\d+', ' ', 'once', 'ignorecase');
        end
    end
end

% 4) coordinates = three numbers in a row
coordExpr = '(?<![\w.])-?\d+(?:\.\d+)?\s+-?\d+(?:\.\d+)?\s+-?\d+(?:\.\d+)?(?![\w.])';
[s, e] = regexp(rest, coordExpr, 'start', 'end', 'once');
if isempty(s)
    pre = ''; coords = ''; post = rest;
else
    pre    = rest(1:s-1);
    coords = regexprep(rest(s:e), '\s+', ' ');
    post   = rest(e+1:end);
end

p.pre    = fragments(pre);
p.coords = coords;
p.laser  = laser;
p.g      = g;
p.r      = r;
p.post   = fragments(post);
p.wl     = wl;
end

function bullets = formatNote(note)
% Bullets in the usual order: comment, coordinates, laser/pmt, rest, wavelength.
p = parseNote(note);
parts = {};
if ~isempty(p.laser), parts{end+1} = ['laser ' p.laser]; end
if ~isempty(p.g),     parts{end+1} = ['gpmt ' p.g];      end
if ~isempty(p.r),     parts{end+1} = ['rpmt ' p.r];      end
bullets = [p.pre, nonEmpty(p.coords), nonEmpty(strjoin(parts, ' ')), ...
           p.post, nonEmpty(p.wl)];
end

function c = nonEmpty(s)
if isempty(s), c = {}; else, c = {s}; end
end

function f = fragments(txt)
% One bullet per comma / semicolon / sentence.
f = {};
txt = strtrim(txt);
if isempty(txt), return; end
parts = regexp(txt, '\s*[;,|]\s*|\.\s+(?=[A-Za-z])', 'split');
for i = 1:numel(parts)
    p = regexprep(parts{i}, '^[\s.,;:]+|[\s.,;:\-]+$', '');
    p = regexprep(p, '\s+', ' ');
    if ~isempty(p), f{end+1} = p; end %#ok<AGROW>
end
end


%% ------------------------------------------------------------------------
function writeNotesXlsx(xlsxFile, rows, folders)
% One row per acquisition. Columns follow the Notion table so it can be
% imported there. Test, Stimulus, Location number, Response, Type and Acq date
% are left blank for you to fill in by hand.
hdr = {'Acq #', 'Notes', 'Test', 'Stimulus', 'Location number', ...
       'Location coordinates', 'Response', 'Laser %', 'Green pmt', 'Red pmt', ...
       'Temp', 'Type', 'Acq date', 'Raw note'};
data = cell(0, numel(hdr));
for sc = unique([rows.scanNum])
    sub  = rows([rows.scanNum] == sc);
    have = [sub.acqNum];
    for a = min(have):max(have)          % every acq number between first and last
        idx = find(have == a, 1);
        if isempty(idx)                  % gap: no .mat file for this acq
            row = repmat({''}, 1, numel(hdr));
            row{1} = a;
            row{2} = 'no .mat file found in folder';
        else
            row = buildRow(sub(idx), folders);
        end
        data(end+1, :) = row; %#ok<AGROW>
    end
end
if exist(xlsxFile, 'file'), delete(xlsxFile); end
writecell([hdr; data], xlsxFile);
formatXlsx(xlsxFile);
end

function formatXlsx(xlsxFile)
% Turn on text wrapping in every cell, top-align, and set sensible column
% widths so the rows stay readable. Uses Excel itself (COM), so this needs
% Windows with Excel installed; otherwise the sheet is left unformatted.
[~, info] = fileattrib(xlsxFile);
fullFile = info.Name;
xl = [];
try
    xl = actxserver('Excel.Application');
    xl.DisplayAlerts = false;
    wb = xl.Workbooks.Open(fullFile);
    ws = wb.Sheets.Item(1);
    rng = ws.UsedRange;
    rng.WrapText = true;
    rng.VerticalAlignment = -4160;                    % xlTop
    widths = [7 45 12 14 10 24 12 9 10 9 7 10 12 60]; % one per column
    for c = 1:numel(widths)
        ws.Columns.Item(c).ColumnWidth = widths(c);
    end
    ws.Rows.Item(1).Font.Bold = true;
    rng.Rows.AutoFit;
    wb.Save;
    wb.Close(false);
    xl.Quit;
    delete(xl);
catch err
    warning('export_mat_notes:format', ...
        'Could not turn on text wrapping (%s). The sheet was saved without it.', err.message);
    try, xl.Quit; delete(xl); catch, end %#ok<NOCOM>
end
end

function row = buildRow(r, folders)
% One Excel row for one acquisition (blank cells are filled in by hand).
p = parseNote(r.note);
row = cell(1, 14);
row{1}  = r.acqNum;
stim    = classifyStimulus(r.note);
frags   = [p.pre, p.post];                    % Notes = note minus the stimulus wording
keep    = {};
for i = 1:numel(frags)
    f = stripStimulus(frags{i}, stim);
    if ~isempty(f), keep{end+1} = f; end %#ok<AGROW>
end
row{2}  = strjoin(keep, '; ');
test    = classifyTest(stim, r.note);
row{3}  = test;                               % Test (follows the Stimulus)
row{4}  = stim;                               % Stimulus
row{5}  = '';                                 % Location number (manual)
row{6}  = p.coords;
row{7}  = '';                                 % Response
row{8}  = numOrBlank(p.laser);
row{9}  = numOrBlank(p.g);
row{10} = numOrBlank(p.r);
row{11} = numOrBlank(extractTemp(r.note));
row{12} = testToType(test);                   % Type (follows the Test)
row{13} = sbxDate(folders, r);                 % Acq date
row{14} = r.note;
end

function d = sbxDate(folders, r)
% Acq date from the "date modified" of the matching .sbx file, written as
% "November 13, 2026" (the format Notion reads as a date). The .mat file's own
% folder is searched first, then the other folder. Blank if no .sbx is found.
d = '';
f = [];
search = [{r.folder}, folders(:)'];
for i = 1:numel(search)
    f = dir(fullfile(search{i}, [r.base '.sbx']));
    if ~isempty(f), break; end
end
if isempty(f), return; end
months = {'January','February','March','April','May','June','July', ...
          'August','September','October','November','December'};
v = datevec(f(1).datenum);
d = sprintf('%s %d, %d', months{v(2)}, v(3), v(1));
end

function s = stripStimulus(s, stim)
% Remove the wording that the Stimulus (and Test) column already says, so the
% Notes column only keeps the extra information. The Raw note is not changed.
switch stim
    case 'zstack'
        expr = '(?:(?:pre|post)\s*-?\s*kcl\s*)?z\s*-?\s*stack|(?:pre|post)\s*-?\s*kcl';
    case {'6x4 darkmode', '6x4 dark mode contrast 50%'}
        expr = ['6[xz]4|dark\s*mode|dark|contrast\s*0?\.5|0?\.5\s*contrast|' ...
                'contrast\s*50\s*%?'];
    case '6x4'
        expr = '6[xz]4(?:\s*norm(?:al)?(?:\s*mode)?)?';
    case '8-way gratings'
        expr = '8\s*-?\s*way(?:\s*gratings?)?|gratings?';
    case 'Sparse noise'
        expr = 'sparse\s*-?\s*noise|(?<![A-Za-z0-9])SN1(?![A-Za-z0-9])';
    case 'no stim spont'
        expr = 'no\s*stim\w*|spon\w*(?:\s+for)?';
    case 'abort'
        expr = 'abort';
    case 'big white flashing square for searching'
        expr = 'big\s+white\s+(?:flashing\s+)?square|flash\w*\s+square|white\s+square';
    otherwise
        return
end
s = regexprep(s, expr, ' ', 'ignorecase');
s = regexprep(s, '\s+', ' ');
s = regexprep(s, '^[\s.,;:]+|[\s.,;:\-]+$', '');
end

function t = classifyStimulus(note)
% Fill the Notion "Stimulus" select with ONE option, picking the first rule
% that matches (most specific first). Option names must match Notion exactly.
% Blank when nothing matches.
has = @(expr) ~isempty(regexpi(note, expr, 'once'));
has6x4 = has('6[xz]4');
if has('abort')
    t = 'abort';
elseif has('sparse\s*-?\s*noise|(?<![A-Za-z0-9])SN1(?![A-Za-z0-9])')
    t = 'Sparse noise';
elseif has('8\s*-?\s*way|grating')
    t = '8-way gratings';
elseif has6x4 && has('contrast\s*0?\.5|0?\.5\s*contrast|contrast\s*50|50\s*%')
    t = '6x4 dark mode contrast 50%';
elseif has6x4 && has('dark')
    t = '6x4 darkmode';
elseif has6x4
    t = '6x4';
elseif has('big\s+white|flash\w*\s+square|white\s+square')
    t = 'big white flashing square for searching';
elseif has('no\s*stim|spon')
    t = 'no stim spont';
elseif has('z\s*-?\s*stack')
    t = 'zstack';
else
    t = '';
end
end

function t = classifyTest(stim, note)
% Fill the Notion "Test" from the Stimulus that was chosen:
%   Sparse noise, 6x4 darkmode, 6x4, 8-way gratings, 6x4 dark mode contrast 50%
%                          -> Visual stimuli
%   no stim spont          -> Spontaneous activity
%   zstack                 -> preKCL zstack / postKCl zstack if the note says
%                             pre or post, otherwise Zstack
%   anything else (abort, big white flashing square, blank) -> blank
% The option names must match Notion exactly.
switch stim
    case {'Sparse noise', '6x4 darkmode', '6x4', '8-way gratings', ...
          '6x4 dark mode contrast 50%'}
        t = 'Visual stimuli';
    case 'no stim spont'
        t = 'Spontaneous activity';
    case 'zstack'
        hasPost = ~isempty(regexpi(note, ...
            'post\s*-?\s*kcl|(?<![A-Za-z])post(?![A-Za-z])', 'once'));
        hasPre  = ~isempty(regexpi(note, ...
            'pre\s*-?\s*kcl|(?<![A-Za-z])pre(?![A-Za-z])', 'once'));
        if hasPost
            t = 'postKCl zstack';
        elseif hasPre
            t = 'preKCL zstack';
        else
            t = 'Zstack';
        end
    otherwise
        t = '';
end
end

function t = testToType(test)
% Type is "Structural" for any z-stack Test (Zstack, preKCL zstack, postKCl
% zstack) and "Functional" for every other Test. Blank when Test is blank.
if isempty(test)
    t = '';
elseif ~isempty(regexpi(test, 'zstack', 'once'))
    t = 'Structural';
else
    t = 'Functional';
end
end

function t = extractTemp(note)
% First temperature in the note: a number after the word "temp", otherwise a
% number followed by a capital C (e.g. "15.0 C", "16C"). Blank if none.
t = '';
tok = regexp(note, 'temp\w*\s*(?:is\s+|was\s+|=|:)?\s*(\d+(?:\.\d+)?)', ...
             'tokens', 'once', 'ignorecase');
if isempty(tok)
    tok = regexp(note, '(\d+(?:\.\d+)?)\s*C(?![A-Za-z])', 'tokens', 'once');
end
if ~isempty(tok), t = tok{1}; end
end

function v = numOrBlank(s)
if isempty(s), v = []; else, v = str2double(s); end
end


%% ------------------------------------------------------------------------
function writeNotesPdf(pdfFile, session, folder, rows, includeRaw)
pageW = 8.5; pageH = 11; margin = 0.8;
bulletX = margin + 0.15;      % where the bullet glyph sits
textX   = margin + 0.33;      % where bullet text starts
bodyFS  = 10;
dot     = char(8226);

L = struct('txt', {}, 'fs', {}, 'bold', {}, 'x', {}, 'gap', {}, ...
           'bullet', {}, 'keep', {});

L = addLine(L, ['MatFileInfoNotes - ' session], 16, true, margin, 0, false, false);
fl = wrapText(['Folder: ' folder], 100);
for i = 1:numel(fl)
    L = addLine(L, fl{i}, 9, false, margin, 0.04 * (i == 1), false, false);
end
L = addLine(L, ['Generated: ' datestr(now, 'yyyy-mm-dd HH:MM')], 9, false, margin, 0, false, false);

for k = 1:numel(rows)
    b = formatNote(rows(k).note);
    L = addLine(L, ['acq ' rows(k).acqStr], 11, true, margin, 0.22, false, ~isempty(b));
    for j = 1:numel(b)
        w = wrapText(b{j}, 90);
        for i = 1:numel(w)
            L = addLine(L, w{i}, bodyFS, false, textX, 0.02 * (i == 1), i == 1, false);
        end
    end
    if includeRaw && ~isempty(rows(k).note)
        w = wrapText(['raw: ' rows(k).note], 110);
        for i = 1:numel(w)
            L = addLine(L, w{i}, 8, false, textX, 0.03 * (i == 1), false, false);
        end
    end
end

if exist(pdfFile, 'file'), delete(pdfFile); end

fig = []; ax = []; y = 0; pageIdx = 0;
for i = 1:numel(L)
    h   = L(i).fs / 72 * 1.4;
    gap = L(i).gap;
    extra = 0;
    if L(i).keep, extra = 2 * (bodyFS / 72 * 1.4); end   % keep header with its bullets
    if isempty(fig) || (y - gap - h - extra) < margin
        if ~isempty(fig), finishPage(fig, ax, pdfFile, pageIdx, pageW); end
        pageIdx = pageIdx + 1;
        [fig, ax] = newPage(pageW, pageH);
        y = pageH - margin;
        gap = 0;
    end
    y = y - gap;
    if L(i).bullet
        text(ax, bulletX, y, dot, 'FontName', 'Helvetica', 'FontSize', L(i).fs, ...
             'VerticalAlignment', 'top', 'Interpreter', 'none');
    end
    wt = 'normal'; if L(i).bold, wt = 'bold'; end
    text(ax, L(i).x, y, L(i).txt, 'FontName', 'Helvetica', 'FontSize', L(i).fs, ...
         'FontWeight', wt, 'VerticalAlignment', 'top', 'Interpreter', 'none');
    y = y - h;
end
finishPage(fig, ax, pdfFile, pageIdx, pageW);
end

function L = addLine(L, txt, fs, bold, x, gap, bullet, keep)
L(end+1) = struct('txt', txt, 'fs', fs, 'bold', bold, 'x', x, 'gap', gap, ...
                  'bullet', bullet, 'keep', keep);
end

function [fig, ax] = newPage(w, h)
fig = figure('Visible', 'off', 'Units', 'inches', 'Position', [0 0 w h], ...
             'Color', 'w', 'MenuBar', 'none', 'ToolBar', 'none');
ax = axes('Parent', fig, 'Units', 'normalized', 'Position', [0 0 1 1], ...
          'XLim', [0 w], 'YLim', [0 h], 'Visible', 'off');
end

function finishPage(fig, ax, pdfFile, pageIdx, pageW)
text(ax, pageW / 2, 0.45, sprintf('Page %d', pageIdx), 'FontName', 'Helvetica', ...
     'FontSize', 8, 'HorizontalAlignment', 'center', 'Interpreter', 'none');
try
    exportgraphics(fig, pdfFile, 'Append', pageIdx > 1, ...
                   'ContentType', 'vector', 'Padding', 'figure');
catch
    exportgraphics(fig, pdfFile, 'Append', pageIdx > 1, 'ContentType', 'vector');
end
close(fig);
end

function out = wrapText(s, n)
words = strsplit(s, ' ');
out = {}; cur = '';
for i = 1:numel(words)
    w = words{i};
    if isempty(cur)
        cur = w;
    elseif numel(cur) + 1 + numel(w) <= n
        cur = [cur ' ' w]; %#ok<AGROW>
    else
        out{end+1} = cur; %#ok<AGROW>
        cur = w;
    end
end
if ~isempty(cur), out{end+1} = cur; end
if isempty(out), out = {''}; end
end
