function S = readTifStack(fname)
%READTIFSTACK  Read every page of a multi-page TIFF into a height x width x pages array.
%   S = readTifStack('stack_000_007_1.tif')
%   Keeps the original bit depth (the sbx2stack tifs are 16-bit).

info = imfinfo(fname);
n = numel(info);
h = info(1).Height;
w = info(1).Width;

first = imread(fname, 1, 'Info', info);
S = zeros(h, w, n, 'like', first);
S(:, :, 1) = first;
for k = 2:n
    S(:, :, k) = imread(fname, k, 'Info', info);
end
end
