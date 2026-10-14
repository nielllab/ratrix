function writeImageJComposite(fname, planes, nCh, nZ, displayRange, lutColors)
%WRITEIMAGEJCOMPOSITE  Write a 16-bit multi-channel z-stack as an ImageJ/Fiji composite TIFF.
%
%   writeImageJComposite(fname, planes, nCh, nZ, displayRange, lutColors)
%
%   planes        height x width x (nCh*nZ) uint16, channel varies fastest
%                 (c1z1, c2z1, c1z2, c2z2, ...)
%   displayRange  [min max], applied to every channel
%   lutColors     nCh x 3 array of channel colours, e.g. [1 0 0; 0 1 0]
%
%   The file opens in Fiji as a composite hyperstack with these display
%   ranges and colours, like the output of Merge Channels... + Save as Tiff.
%   The pixel data is stored contiguously after a single IFD, which is what
%   ImageJ expects for files with an "images=" entry in the description.

[h, w, np] = size(planes);
if np ~= nCh * nZ
    error('writeImageJComposite:size', 'planes has %d pages but nCh*nZ = %d.', np, nCh * nZ);
end
if ~isa(planes, 'uint16')
    planes = uint16(planes);
end
lo = displayRange(1);
hi = displayRange(2);

%% ImageJ description string
desc = sprintf(['ImageJ=1.53t\nimages=%d\nchannels=%d\nslices=%d\n' ...
    'hyperstack=true\nmode=composite\nloop=false\nmin=%.1f\nmax=%.1f\n'], ...
    np, nCh, nZ, lo, hi);
descBytes = [uint8(desc) uint8(0)];

%% ImageJ metadata block: per-channel display ranges and LUTs
rangeBytes = toBE(repmat([lo hi], 1, nCh));          % doubles, big-endian
ramp = (0:255);
lutBytes = cell(1, nCh);
for c = 1:nCh
    lutBytes{c} = uint8([ramp * lutColors(c, 1), ramp * lutColors(c, 2), ramp * lutColors(c, 3)]);
end
items = [{rangeBytes}, lutBytes];
header = [uint8('IJIJ'), uint8('rang'), toBE(uint32(1)), uint8('luts'), toBE(uint32(nCh))];
md = [header, items{:}];
byteCounts = uint32([numel(header), cellfun(@numel, items)]);
bcBytes = toBE(byteCounts);

%% Layout of the file
nEntries = 12;
ifdOffset = 8;
pos = ifdOffset + 2 + 12 * nEntries + 4;
descOffset = pos;
pos = pos + numel(descBytes);
pad1 = mod(pos, 2);
pos = pos + pad1;
bcOffset = pos;
pos = pos + numel(bcBytes);
mdOffset = pos;
pos = pos + numel(md);
pad2 = mod(pos, 2);
pos = pos + pad2;
dataOffset = pos;

%% Write
fid = fopen(fname, 'w', 'ieee-be');
if fid < 0
    error('writeImageJComposite:open', 'Could not open %s for writing.', fname);
end
closer = onCleanup(@() fclose(fid));

fwrite(fid, uint8('MM'), 'uint8');
fwrite(fid, 42, 'uint16');
fwrite(fid, ifdOffset, 'uint32');

fwrite(fid, nEntries, 'uint16');
writeEntry(fid, 256, 4, 1, w);                        % ImageWidth
writeEntry(fid, 257, 4, 1, h);                        % ImageLength
writeEntry(fid, 258, 3, 1, 16);                       % BitsPerSample
writeEntry(fid, 259, 3, 1, 1);                        % Compression: none
writeEntry(fid, 262, 3, 1, 1);                        % Photometric: black is zero
writeEntry(fid, 270, 2, numel(descBytes), descOffset);% ImageDescription
writeEntry(fid, 273, 4, 1, dataOffset);               % StripOffsets
writeEntry(fid, 277, 3, 1, 1);                        % SamplesPerPixel
writeEntry(fid, 278, 4, 1, h);                        % RowsPerStrip
writeEntry(fid, 279, 4, 1, h * w * 2);                % StripByteCounts
writeEntry(fid, 50838, 4, numel(byteCounts), bcOffset); % IJMetadataByteCounts
writeEntry(fid, 50839, 1, numel(md), mdOffset);       % IJMetadata
fwrite(fid, 0, 'uint32');                             % no next IFD

fwrite(fid, descBytes, 'uint8');
if pad1, fwrite(fid, 0, 'uint8'); end
fwrite(fid, bcBytes, 'uint8');
fwrite(fid, md, 'uint8');
if pad2, fwrite(fid, 0, 'uint8'); end

for k = 1:np
    fwrite(fid, planes(:, :, k).', 'uint16');         % TIFF rows are stored row by row
end
end

function writeEntry(fid, tag, type, count, value)
fwrite(fid, tag, 'uint16');
fwrite(fid, type, 'uint16');
fwrite(fid, count, 'uint32');
if type == 3                                          % SHORT is left-justified in the 4 value bytes
    fwrite(fid, value, 'uint16');
    fwrite(fid, 0, 'uint16');
else
    fwrite(fid, value, 'uint32');
end
end

function b = toBE(x)
% bytes of x in big-endian order, as a uint8 row vector
[~, ~, endian] = computer;
if endian == 'L'
    x = swapbytes(x);
end
b = reshape(typecast(x(:).', 'uint8'), 1, []);
end
