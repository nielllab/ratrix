function res = prepost_lineprofile(varargin)
%PREPOST_LINEPROFILE  Pre/post z-stack pipeline: sbx -> tif -> composites + gifs -> line profile app.
%
%   prepost_lineprofile
%       Asks you to pick the PRE .sbx, then the POST .sbx, then for each one:
%         1. runs sbx2stack_multichan to make <name>_1.tif and <name>_2.tif
%            (skipped if both already exist)
%         2. builds a red/green composite z-stack with the SAME display
%            range for pre and post (same as zstack_composite_to_gif.ijm):
%               acq#_zstack_composite_<min>min_<max>max.tif   (Fiji composite, 16-bit)
%               acq#_zstack_composite_<min>min_<max>max.gif   (animated, one frame per z-plane)
%         3. opens lineProfileApp with the raw 16-bit tifs.
%
%   Options (name-value):
%     'DisplayRange'  [min max] used for both composites/gifs   (default [300 30000])
%     'File1IsRed'    true if the _1 file is red, false if _2   (default false, as in the macro)
%     'GifDelay'      seconds per frame in the gif              (default 1/7)
%     'Overwrite'     redo sbx -> tif even if tifs exist        (default false)
%     'LaunchApp'     open the line profile app at the end      (default true)
%
%   Needs on the MATLAB path: sbx2stack_multichan.m, Scanbox's sbxread, and
%   the files in this folder (lineProfileApp, readTifStack, writeImageJComposite).
%   Each .sbx needs its .mat file in the same folder.

ip = inputParser;
addParameter(ip, 'DisplayRange', [300 30000], @(x) isnumeric(x) && numel(x) == 2 && x(2) > x(1));
addParameter(ip, 'File1IsRed', false, @(x) islogical(x) || isnumeric(x));
addParameter(ip, 'GifDelay', 1/7, @isnumeric);
addParameter(ip, 'Overwrite', false, @(x) islogical(x) || isnumeric(x));
addParameter(ip, 'LaunchApp', true, @(x) islogical(x) || isnumeric(x));
parse(ip, varargin{:});
o = ip.Results;

%% choose the two videos
tags = {'PRE', 'POST'};
files = cell(1, 2);
dirs = cell(1, 2);
startDir = pwd;
for k = 1:2
    [files{k}, dirs{k}] = uigetfile('*.sbx', sprintf('Select the %s video (.sbx)', tags{k}), startDir);
    if isequal(files{k}, 0)
        fprintf('Cancelled.\n');
        res = [];
        return
    end
    startDir = dirs{k};
end

%% convert + composite each one
bases = cell(1, 2);
out = cell(1, 2);
for k = 1:2
    [~, stem] = fileparts(files{k});
    fprintf('\n=== %s: %s ===\n', tags{k}, stem);
    convertSbx(dirs{k}, stem, o.Overwrite);
    out{k} = makeComposite(dirs{k}, stem, o.DisplayRange, logical(o.File1IsRed), o.GifDelay);
    bases{k} = fullfile(dirs{k}, stem);
end
res = struct('pre', out{1}, 'post', out{2});
fprintf('\nDone. Composite display range for both: %g to %g\n', o.DisplayRange(1), o.DisplayRange(2));

%% line profile app
if o.LaunchApp
    lineProfileApp(bases{1}, bases{2}, 'DisplayRange', o.DisplayRange, ...
        'File1IsRed', logical(o.File1IsRed), 'Names', {'Pre', 'Post'});
end
end


function convertSbx(folder, stem, overwrite)
% run sbx2stack_multichan in the sbx folder, unless the tifs are already there
t1 = fullfile(folder, [stem '_1.tif']);
t2 = fullfile(folder, [stem '_2.tif']);
if ~overwrite && isfile(t1) && isfile(t2)
    fprintf('  Found %s_1.tif and %s_2.tif, skipping sbx conversion.\n', stem, stem);
    return
end
if exist('sbx2stack_multichan', 'file') ~= 2
    error('prepost:missing', 'sbx2stack_multichan.m is not on the MATLAB path.');
end
if exist('sbxread', 'file') == 0
    error('prepost:missing', 'Scanbox sbxread is not on the MATLAB path.');
end
if ~isfile(fullfile(folder, [stem '.sbx']))
    error('prepost:missing', '%s.sbx not found in %s', stem, folder);
end
if ~isfile(fullfile(folder, [stem '.mat']))
    warning('prepost:nomat', 'No %s.mat next to the sbx file. sbxread needs it.', stem);
end

% sbx2stack_multichan appends to existing tifs, so clear out any old ones first
if isfile(t1), delete(t1); end
if isfile(t2), delete(t2); end

here = pwd;
back = onCleanup(@() cd(here));
cd(folder);
fprintf('  Converting %s.sbx to tif (this can take a while)...\n', stem);
sbx2stack_multichan(stem);
clear back

if ~isfile(t1)
    error('prepost:convert', 'Conversion did not produce %s', t1);
end
if ~isfile(t2)
    error('prepost:onechannel', ['Only one channel was found in %s. ' ...
        'The composite needs two channels (_1 and _2).'], stem);
end
end


function out = makeComposite(folder, stem, rng, file1IsRed, gifDelay)
% red/green composite tif + gif with a fixed display range (like the Fiji macro)
fprintf('  Reading tifs...\n');
c1 = readTifStack(fullfile(folder, [stem '_1.tif']));
c2 = readTifStack(fullfile(folder, [stem '_2.tif']));
if ~isequal(size(c1), size(c2))
    error('prepost:size', '%s_1.tif and %s_2.tif have different sizes.', stem, stem);
end
if file1IsRed
    red = c1;
    green = c2;
else
    red = c2;
    green = c1;
end
[h, w, nz] = size(red);

% name: acq<last underscore section as a number>_zstack_composite_<min>min_<max>max
parts = strsplit(stem, '_');
acq = str2double(parts{end});
if isnan(acq)
    tag = stem;
else
    tag = sprintf('acq%d', acq);
end
outName = sprintf('%s_zstack_composite_%gmin_%gmax', tag, rng(1), rng(2));
tifName = fullfile(folder, [outName '.tif']);
gifName = fullfile(folder, [outName '.gif']);

% composite tif: channel 1 = red, channel 2 = green, 16-bit, display range stored in the file
planes = zeros(h, w, 2 * nz, 'uint16');
planes(:, :, 1:2:end) = red;
planes(:, :, 2:2:end) = green;
writeImageJComposite(tifName, planes, 2, nz, rng, [1 0 0; 0 1 0]);
fprintf('  Wrote %s\n', tifName);

% gif: RGB with the same display range, one frame per z-plane
lo = rng(1);
hi = rng(2);
scale = @(x) uint8(round(255 * min(max((double(x) - lo) / (hi - lo), 0), 1)));
for z = 1:nz
    rgb = cat(3, scale(red(:, :, z)), scale(green(:, :, z)), zeros(h, w, 'uint8'));
    try
        [ind, map] = rgb2ind(rgb, 256, 'nodither');
        frameArgs = {ind, map};
    catch
        frameArgs = {rgb};          % imwrite quantizes RGB itself if rgb2ind is unavailable
    end
    if z == 1
        imwrite(frameArgs{:}, gifName, 'gif', 'LoopCount', Inf, 'DelayTime', gifDelay);
    else
        imwrite(frameArgs{:}, gifName, 'gif', 'WriteMode', 'append', 'DelayTime', gifDelay);
    end
end
fprintf('  Wrote %s\n', gifName);

out = struct('tif1', fullfile(folder, [stem '_1.tif']), 'tif2', fullfile(folder, [stem '_2.tif']), ...
    'compositeTif', tifName, 'compositeGif', gifName);
end
