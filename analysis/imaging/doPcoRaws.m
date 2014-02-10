function doPcoRaws(p)
dbstop if error

if ~exist('p','var') || isempty(p)
    p = fullfile('D:\');
    p = fullfile('D:\data\pcoraw tests');
end

arrayfun(@(x) doPcoRaw(p,x),dir(p));
end

function doPcoRaw(d,f)
close all

sfx = '.pcoraw';
p = fullfile(d,f.name);
if f.isdir && ~ismember(f.name,{'.' '..'})
    fprintf('.')
    %    drawnow
    doPcoRaws(p);
elseif length(f.name)>length(sfx) && strcmp(f.name(end-length(sfx)+1:end),sfx)
    if false
        [sz, info] = loadPcoraw(p);
        [~, ~, bStamps, bFrameNums, data] = loadPcoraw(p,info,1,[]);
    else
        [~, ~, bStamps, bFrameNums, data] = loadPcoraw(p,[],1);
        keyboard
    end
    fprintf('\n')
end
end

function [sz, info, bStamps, bFrameNums, data] = loadPcoraw(path, info, maxGB, ROI)
% path = 'D:\33hz95pcTbaMSB6d.pcoraw'; % only one with OK binary or ascii timestamps, but only for first 75%, ascii library ok
%D--fast-test-2 thru 3  -- a few OK ascii and binary at beginning, ascii lib ok
%D--fast-test-4 thru 6  -- a few OK binary at beginning

path = 'D:\data\pcoraw tests\fast pc\test';

pcoraw = isscalar(dir(path));

if ~pcoraw
    ids = dir([path '_*.tif']);
    
    if isempty(ids)
        path
        error('no such file')
    else
        warning('pcoraw preferred')
        ids = {ids.name};
        [bPath,base] = fileparts(path);
        % cellfun(@(s) textscan(s,[base '_%u.tif'],'CollectOutput',true),ids)
        if any (1:length(ids) ~= sort(cellfun(@(s) sscanf(s,[base '_%u.tif']),ids)))
            error('nonconsecutive files')
        end
    end
end

if ~exist('info','var')
    info = [];
end
if ~exist('maxGB','var')
    maxGB = [];
end
if ~exist('ROI','var')
    ROI = [];
end

mfn = '';

if all(cellfun(@isempty,{info maxGB ROI})) % all(cellfun(@(f) f(info),{@isscalar @isnan})) && nargin == 2
    [pathstr,name,ext] = fileparts(path);
    d = dir(fullfile(pathstr,[name ext '*.mat']));
    if isscalar(d)
        mfn = fullfile(pathstr,d.name);
        sz = [];
    elseif isempty(d)
        % pass
    else
        d.name
        error('didn''t find unique match')
    end
end

warnings = {};
lastwarn('');
[outDir, p] = getPaths(path);
diary(fullfile(outDir,[p '-' datestr(now,30)]));
maxGB 
ROI 

    function fn = getTifName(ind)
        fn = sprintf('%s_%04d.tif',base,ind);
        if ~ismember(fn,ids)
            fn = sprintf('%s_%06d.tif',base,ind);
            if ~ismember(fn,ids)
                error('hmmm')
            end
        end
    end

if isempty(mfn)
    if isempty(info)
        if pcoraw
            path1=path;
        else            
            path1=fullfile(bPath,getTifName(1));
        end
        fprintf('imfinfo on %s ',path1)
        lastwarn('')
        tic
        info = imfinfo(path1);
        % usually produces Warning: The datatype for tag Software should be TIFF_ASCII instead of TIFF_SHORT.
        toc
        recordWarning;
    elseif ~all(cellfun(@(f) f(info),{@isvector @isstruct}))
        error('info must be empty or struct array result of imfinfo')
    end
        
    sz = cellfun(@(x)unique([info.(x)]),{'Height','Width'},'UniformOutput',false);
    if ~all(cellfun(@isscalar,sz))
        error('height or width varies')
    else
        sz = cell2mat(sz);
        if pcoraw
            sz(3) = length(info);
        else
            sz(3) = length(ids);
        end
    end
    
    if nargout <= 2
        return
    end
    
    if isempty(ROI)
        ROI = [ones(1,3); sz];
    else
        if ~all(size(ROI) == [2 3])
            ROI
            error('ROI must be 2x3 [row1 col1 frame1; rowN colN frameN]')
        end
        
        for i = 1:3
            if all(btw(ROI(:,i),[0 1])) && any(ROI(:,i)~=1)
                ROI(:,i) = 1 + round(ROI(:,i) * (sz(i)-1));
            end
            
            if ~all(btw(ROI(:,i),[1 sz(i)]))
                ROI(:,i)
                sz(i)
                error('ROI out of bounds')
            end
        end
        
        if any(mod(ROI(:),1)~=0)
            ROI
            error('ROI entries must be natural')
        end
    end
    
    stampHeight = 7;
    stampWidth = 6;
    numStampChars = 50;
    ROI(1,1) = max(ROI(1,1),stampHeight+1);
    
    if any(diff(ROI) < 0)
        ROI
        error('ROI row2 entries can''t be smaller than row1 entries (we have automatically removed timestamp rows)')
    end
    
    szROI = diff(ROI) + 1;
    
    if isempty(maxGB)
        scale = 1;
    else
        if ~all(cellfun(@(f) f(maxGB),{@isscalar @isreal @(x)x>0}))
            maxGB
            error('maxGB must be scalar positive real')
        end
        
        bytesPerPix = 2;
        pixPerFrame = maxGB*1000*1000*1000/szROI(3)/bytesPerPix;
        
        scale = pixPerFrame/prod(szROI(1:2));
    end
    
    newSz = szROI;
    if scale < 1
        newSz(1:2) = round(sqrt(scale)*newSz(1:2));
    end
    
    mfn = [path intercalate('_',[newSz ROI(:)']) '.mat'];
end

    function recordWarning %no way to capture more than last one if many issued at once?
        if false
            [wm, wi] = lastwarn;
            if ~isempty(wm)
                warnings{end+1} = {wm wi};
                lastwarn('')
            end
        end
    end

if exist(mfn,'file')
    fprintf('loading preshrunk %s ',mfn)
    tic
    f = load(mfn);
    toc
    
    data = f.data; %probably doubles memory requirement :(
    stamps = f.stamps;
    
    clear f
else
    fprintf('reading from scratch %s\n',mfn)
    
    if verLessThan('matlab', '8.1') %2013a
        warning('use >= 2013a, or else loading tiffs is slow/can''t read bigtiffs (maybe 2012b can?)')
    end
    
    data = zeros(newSz(1),newSz(2),newSz(3),'uint16');
    stamps = zeros(stampHeight,stampWidth*numStampChars,sz(3),'uint16'); %~1.5GB for 1 hour at 100hz to keep the raw stamps
    %TODO: at high binning image may not be this wide.
    
    % warning('off', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')
    tic
    if pcoraw
        t = Tiff(path,'r');
        cds = nan(1,sz(3));
    end
    recordWarning;
    
    % have to use Tiff object (faster anyway) -- imread dies on bigtiffs at high frame numbers with:
    % Error using rtifc
    % TIFF library error - 'TIFFFetchDirectory:  Sanity check on directory count failed, this is probably not a valid IFD offset.'
        
    for i = 1:sz(3) %something in this loop is leaking
        if rand>.95
            fprintf('%d\t%d\t%g%% done\n',i,szROI(3),100*(i-ROI(1,3))/szROI(3))
        end
        if btw(i,ROI(:,3))
            if pcoraw
                frame = t.read();
            else
                fn = sprintf('%s_%04d.tif',base,i);
                if ~ismember(fn,ids)
                    fn = sprintf('%s_%06d.tif',base,i);
                    if ~ismember(fn,ids)
                        error('hmmm')
                    end
                end
                if true
                    frame = imread(fullfile(bPath,fn),'PixelRegion',{[1 ROI(2,1)] [1 ROI(2,2)]}); % must include upper left for timestamps
                else %this method slower
                    t = Tiff(fullfile(bPath,fn),'r');
                    frame = t.read();
                    t.close();
                end
            end
            recordWarning;
            % can get lots of:
            % TIFF library error - 'TIFFFillStrip:  Read error on strip 2159; got 18446744073706816440 bytes, expected 5120.' - file may be corrupt.
            % MATLAB:imagesci:tiffmexutils:libtiffErrorAsWarning
            
            if ~ismatrix(frame)
                error('frames not monochrome?')
            end
            
            %keep track of range of values seen?  i've noticed that binning
            %reduces dynamic range when it should increase it?  (well, std
            %may decrease, but range should increase, correct?)
            
            if all(size(frame) == diff(ROI(:,1:2))+1) %never happens cuz we cut off stamp height and read upper left corner
                data(:,:,i) = imresize(frame,newSz(1:2)); %is imresize smart about unity?  how do our data depend on method?  (we use default 'bicubic' -- "weighted average of local 4x4" (w/antialiasing) -- we can specify kernel if desired)
            else
                data(:,:,i) = imresize(frame(ROI(1,1):ROI(2,1),ROI(1,2):ROI(2,2)),newSz(1:2));
            end
            stamps(:,:,i) = frame(1:stampHeight,1:size(stamps,2));
        end
        
        if pcoraw && i < sz(3)
            cds(i) = t.currentDirectory; %wraps around as a uint16
            t.nextDirectory();
        end
    end
    
    if false && pcoraw
        t.close(); %on huge pcoraw this crashes matlab!
    end
    toc
    % warning('on', 'MATLAB:imagesci:tiffmexutils:libtiffWarning')
    
    if pcoraw
        figure
        plot(diff(cds))
        ylabel('\Delta tiff directory')
        xlabel('frame')
        title(sprintf('tiff directory wraps like a uint16 (65k) (%s)',path),'Interpreter','none')
        
        find(diff(cds)~=1)
    end
    
    fprintf('saving: ')
    tic
    save(mfn,'data','stamps','warnings','-v7.3') %7.3 required for >2GB vars
    toc
end

[bStamps, bFrameNums] = readStamps(stamps,path);
diary off
end

function saveFig(f,p,t)
[imDir, p] = getPaths(p);
saveas(f,fullfile(imDir,[t '.' p '.fig']))
end

function [imDir, p] = getPaths(p)
imDir = 'C:\Users\nlab\Desktop\pcoraw summaries';
[a,b] = fileparts(p);
p = fullfile(a,b);
p(~isstrprop(p,'alphanum')) = '-';
end

function [bStamps, bFrameNums, figs] = readStamps(stamps,path)
w = 6;
n = size(stamps,3);

fig = figure;
d = 100;
imagesc(reshape(permute(stamps(:,:,round(linspace(1,n,d))),[1 3 2]),[d*size(stamps,1),size(stamps,2)]))
% title(sprintf('ascii (%s)',path),'Interpreter','none')
title('ascii')
axis equal
saveFig(fig,path,'ascii stamps');

% imagesc(reshape(permute(stamps,[1 3 2]),[size(stamps,3)*size(stamps,1),size(stamps,2)]))

% http://en.wikipedia.org/wiki/Binary-coded_decimal
%
% pixel
% 1 - image num MSB (00-99)
% 2 - image num
% 3 - image num
% 4 - image num LSB
% 5 - year MSB (20)
% 6 - year LSB (03-99)
% 7 - month (01-12)
% 8 - day (01-31)
% 9 - hour (00-23)
% 10 - min (00-59)
% 11 - sec (00-59)
% 12 - us*10000 (00-99)
% 13 - us*100
% 14 - us

t = 14;
x = squeeze(stamps(1,1:t,:));

d = ceil(sqrt(t));
fig = figure;
for i=1:t
    subplot(d,d,i)
    imagesc(dec2bin(x(i,:),16)=='1',[0 1])
    title(['pixel ' num2str(i)])
    ylabel('frame')
    xlabel('bit')
end
saveFig(fig,path,'binary pixels');

f = dec2bin(x,16);

if any(any(f(:,1:8)~='0'))
    warning('bad bcd')
end

x = reshape([bin2dec(f(:,9:12)) bin2dec(f(:,13:16))]*10.^[1 0]',[t n])';
bStamps = x(:,9:14)*[60.^[2 1] 10.^(0 : -2 : -6)]';
bFrameNums = x(:,1:4)*10.^(2*(3 : -1 : 0))';

fig = figure;
subplot(2,1,1)
plot(1./diff(bStamps))
title('binary frame times')
ylabel('hz')
xlabel('frame')

subplot(2,1,2)
plot(diff(bFrameNums)-1)
title('drops by binary frame num')
xlabel('frame')
ylabel('drops')
saveFig(fig,path,'binary hz and drops');

inds = (1:w+2:size(stamps,2))-3;
inds = inds(inds>0);
inds = inds(1:end-1);

fig = figure;
subplot(1,3,1)
sn = double(stamps(:, inds(3) : inds(end)+w-1, :));
bins = double(0:intmax('uint16'));
h = hist(sn(:),bins);
%sn(sn <= intmax('uint16')/2) = sn(sn <= intmax('uint16')/2) - 0;
sn(sn >  intmax('uint16')/2) = sn(sn >  intmax('uint16')/2) - double(intmax('uint16'));
imagesc(reshape(permute(sn,[1 3 2]),[size(sn,3)*size(sn,1),size(sn,2)]))
colorbar
title(sprintf('pix > 0 or < 2^{16}'))
axis equal
subplot(1,3,2)
binds = 1:max(sn(:))+1;
semilogy(bins(binds),h(binds)); 
subplot(1,3,3)
binds = length(bins) + (min(sn(:)) : 0);
semilogy(bins(binds),h(binds));
saveFig(fig,path,'weird pix')

stamps = stamps > intmax('uint16')/2;  % for some reason stamp pixels have small deviations from 0 and 2^16-1  -- compression artifacts?

f = 9;
lib = stamps(:,inds(f)+(0:w-1),1:10);

fig = figure;
imagesc(reshape(permute(lib,[1 3 2]),[size(stamps,1)*10,w]))
axis equal
title('ascii library')
saveFig(fig,path,'ascii library');

out = nan(n,length(inds));

fprintf('reading timestamps: ')
tic
for i = 1:n
    for j = 1:length(inds)
        this = stamps(:,inds(j)+(0:w-1),i);
        match = findPlane(this,lib);
        if isscalar(match)
            out(i,j) = match;
        end
    end
end
toc

out(out==10)=0;

hrs = 22:23;
mn = 25:26;
sec = 28:29;
frc = 31:36;

aStamps = sum(cell2mat(cellfun(@convert,{hrs mn sec frc},'UniformOutput',false)) .* repmat([60.^(2 : -1 : 0) 10^-length(frc)],size(out,1),1),2);

aFrameNums = 3:9;
aFrameNums = convert(aFrameNums);

    function x = convert(x)
        x = sum(out(:,x).*repmat(10.^(length(x)-1 : -1 : 0),size(out,1),1),2);
    end

k = 4;
fig = figure;
subplot(k,1,1)
plot(aStamps)
title('ascii frametimes')

subplot(k,1,2)
plot(isnan(aStamps))
title('ascii frametimes unreadable')

subplot(k,1,3)
plot(aStamps-bStamps)
title('ascii vs binary frametimes')

subplot(k,1,4)
plot(aFrameNums-bFrameNums)
title('ascii vs binary framenums')
saveFig(fig,path,'ascii analysis');

if any(isnan(aStamps))
    warning('ascii stamps didn''t work, returning binaries')
    aStamps = [];
    aFrameNums = [];
else
    if any(abs(aStamps-bStamps) > 10^-10) %why aren't these exact?  they differ by 8x10^-12
        error('bad')
    end
    
    if ~all(aFrameNums == bFrameNums)
        error('ascii and binary frame nums didn''t match')
    end
end
end

function out = findPlane(in,lib)
out = [];

for i=1:size(lib,3)
    test = lib(:,:,i)==in;
    if all(test(:))
        out(end+1) = i;
    end
end
end

function out = btw(in,rng)
out = in>=rng(1) & in<=rng(2);
end

function out = intercalate(s,n)
out = '';
for i = n
    out = [out s num2str(i)];
end
end